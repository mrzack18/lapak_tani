import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lapak_tani/providers/cart_provider.dart';
import 'package:lapak_tani/providers/auth_provider.dart';
import 'package:lapak_tani/providers/order_provider.dart';
import 'package:lapak_tani/models/order_model.dart';
import 'package:lapak_tani/models/order_item_model.dart';
import 'package:lapak_tani/widgets/custom_text_field.dart';
import 'package:lapak_tani/widgets/loading_widget.dart';
import 'package:intl/intl.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  final _notesController = TextEditingController();
  String _paymentMethod = 'COD';
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _addressController = TextEditingController(text: user?.address ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
  }

  @override
  void dispose() {
    _addressController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _processCheckout() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);

    final cartProvider = context.read<CartProvider>();
    final orderProvider = context.read<OrderProvider>();
    final user = context.read<AuthProvider>().user!;

    // Group items by seller
    final itemsBySeller = <String, List<OrderItemModel>>{};
    final sellerNames = <String, String>{};

    for (var item in cartProvider.items) {
      if (!itemsBySeller.containsKey(item.sellerId)) {
        itemsBySeller[item.sellerId] = [];
        sellerNames[item.sellerId] = item.sellerName;
      }
      itemsBySeller[item.sellerId]!.add(
        OrderItemModel(
          productId: item.productId,
          productName: item.productName,
          productImageUrl: item.productImageUrl,
          productPrice: item.productPrice,
          quantity: item.quantity,
          subtotal: item.subtotal,
        ),
      );
    }

    bool allSuccess = true;

    for (var sellerId in itemsBySeller.keys) {
      final items = itemsBySeller[sellerId]!;
      final totalAmount = items.fold(0.0, (sum, item) => sum + item.subtotal);
      final taxAmount = totalAmount * 0.10;
      final totalWithTax = totalAmount + taxAmount;

      final order = OrderModel(
        id: '',
        buyerId: user.uid,
        buyerName: user.name,
        buyerAddress: _addressController.text.trim(),
        buyerPhone: _phoneController.text.trim(),
        sellerId: sellerId,
        sellerName: sellerNames[sellerId]!,
        items: items,
        totalAmount: totalWithTax,
        status: 'pending',
        paymentMethod: _paymentMethod,
        notes: _notesController.text.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final success = await orderProvider.createOrder(order);
      if (!success) allSuccess = false;
    }

    if (mounted) {
      setState(() => _isProcessing = false);

      if (allSuccess) {
        await cartProvider.clearCart(user.uid);

        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              backgroundColor: Colors.white,
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_circle_outline_rounded,
                        color: Colors.green.shade600,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Pesanan Berhasil!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Pesanan Anda berhasil dibuat dan telah diteruskan ke petani terkait.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1B8040),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          Navigator.of(
                            context,
                          ).popUntil((route) => route.isFirst);
                        },
                        child: const Text(
                          'Selesai',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Beberapa pesanan gagal dibuat',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  Widget _buildCheckoutSection({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withValues(alpha: 0.04), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        centerTitle: true,
        title: const Text(
          'Checkout',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Informasi Pengiriman ──────────────────────────────────
              _buildCheckoutSection(
                title: 'Informasi Pengiriman',
                icon: Icons.location_on_rounded,
                iconColor: const Color(0xFFEA580C),
                children: [
                  CustomTextField(
                    controller: _addressController,
                    label: 'Alamat Lengkap',
                    maxLines: 3,
                    validator: (v) =>
                        v!.isEmpty ? 'Alamat tidak boleh kosong' : null,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _phoneController,
                    label: 'Nomor Telepon',
                    keyboardType: TextInputType.phone,
                    validator: (v) =>
                        v!.isEmpty ? 'Nomor telepon tidak boleh kosong' : null,
                  ),
                ],
              ),

              // ── Metode Pembayaran ─────────────────────────────────────
              _buildCheckoutSection(
                title: 'Metode Pembayaran',
                icon: Icons.account_balance_wallet_rounded,
                iconColor: const Color(0xFF0284C7),
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: _paymentMethod,
                    decoration: InputDecoration(
                      labelText: 'Pilih Metode',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Colors.grey.shade300,
                          width: 1.5,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    icon: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Colors.grey.shade600,
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'COD',
                        child: Text(
                          'Bayar di Tempat (COD)',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'Transfer Bank',
                        child: Text(
                          'Transfer Bank',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                    onChanged: (v) => setState(() => _paymentMethod = v!),
                  ),
                ],
              ),

              // ── Catatan Tambahan ──────────────────────────────────────
              _buildCheckoutSection(
                title: 'Catatan (Opsional)',
                icon: Icons.edit_note_rounded,
                iconColor: const Color(0xFF8B5CF6),
                children: [
                  CustomTextField(
                    controller: _notesController,
                    label: 'Pesan untuk petani / kurir...',
                  ),
                ],
              ),

              // ── Ringkasan Pesanan ─────────────────────────────────────
              _buildCheckoutSection(
                title: 'Ringkasan Pesanan',
                icon: Icons.receipt_long_rounded,
                iconColor: const Color(0xFF1B8040),
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '${item.quantity}x',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      item.productName,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF1E293B),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              currencyFormat.format(item.subtotal),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Divider(height: 1, color: Colors.grey.shade200),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Subtotal',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        currencyFormat.format(cart.totalAmount),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'PPN Aplikasi (10%)',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        currencyFormat.format(cart.totalAmount * 0.10),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B8040).withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Pembayaran',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          currencyFormat.format(cart.totalAmount * 1.10),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Color(0xFF1B8040),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // ── Action Button ─────────────────────────────────────────
              if (_isProcessing)
                const LoadingWidget()
              else
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _processCheckout,
                    icon: const Icon(Icons.check_circle_outline_rounded),
                    label: const Text(
                      'Buat Pesanan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B8040),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
