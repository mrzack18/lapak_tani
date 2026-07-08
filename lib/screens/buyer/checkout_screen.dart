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
            builder: (ctx) => AlertDialog(
              title: const Text('Pesanan Berhasil'),
              content: const Text(
                'Pesanan Anda berhasil dibuat dan diteruskan ke petani.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: const Text('Selesai'),
                ),
              ],
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Beberapa pesanan gagal dibuat'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
      appBar: AppBar(title: const Text('Checkout')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Informasi Pengiriman',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
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

              const Divider(height: 32),

              const Text(
                'Metode Pembayaran',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _paymentMethod,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(
                    value: 'COD',
                    child: Text('Bayar di Tempat (COD)'),
                  ),
                  DropdownMenuItem(
                    value: 'Transfer Bank',
                    child: Text('Transfer Bank'),
                  ),
                ],
                onChanged: (v) => setState(() => _paymentMethod = v!),
              ),

              const Divider(height: 32),

              const Text(
                'Catatan (Opsional)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _notesController,
                label: 'Catatan untuk petani',
              ),

              const Divider(height: 32),

              const Text(
                'Ringkasan Pesanan',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: cart.items.length,
                itemBuilder: (context, index) {
                  final item = cart.items[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text('${item.quantity}x ${item.productName}'),
                        ),
                        Text(currencyFormat.format(item.subtotal)),
                      ],
                    ),
                  );
                },
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Subtotal'),
                  Text(currencyFormat.format(cart.totalAmount)),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('PPN Aplikasi (10%)'),
                  Text(currencyFormat.format(cart.totalAmount * 0.10)),
                ],
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Pembayaran',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    currencyFormat.format(cart.totalAmount * 1.10),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              if (_isProcessing)
                const LoadingWidget()
              else
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _processCheckout,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Buat Pesanan'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
