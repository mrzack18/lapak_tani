import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lapak_tani/providers/order_provider.dart';
import 'package:lapak_tani/providers/auth_provider.dart';
import 'package:lapak_tani/services/review_service.dart';
import 'package:lapak_tani/models/review_model.dart';
import 'package:lapak_tani/widgets/order_status_badge.dart';
import 'package:lapak_tani/widgets/custom_text_field.dart';
import 'package:intl/intl.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  final _reviewService = ReviewService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().user;
      if (user != null) {
        context.read<OrderProvider>().fetchBuyerOrders(user.uid);
      }
    });
  }

  void _showReviewDialog(BuildContext context, String orderId, String productId) {
    int rating = 5;
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Beri Ulasan'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 32,
                        ),
                        onPressed: () => setState(() => rating = index + 1),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: commentController,
                    label: 'Komentar',
                    maxLines: 3,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final user = context.read<AuthProvider>().user!;
                    final review = ReviewModel(
                      id: '',
                      productId: productId,
                      userId: user.uid,
                      userName: user.name,
                      orderId: orderId,
                      rating: rating,
                      comment: commentController.text.trim(),
                      createdAt: DateTime.now(),
                    );
                    
                    try {
                      await _reviewService.addReview(review);
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Terima kasih atas ulasan Anda!'), backgroundColor: Colors.green),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
                        );
                      }
                    }
                  },
                  child: const Text('Kirim'),
                ),
              ],
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final user = context.watch<AuthProvider>().user;

    return Consumer<OrderProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.buyerOrders.isEmpty) {
          return const Center(child: Text('Belum ada pesanan'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.buyerOrders.length,
          itemBuilder: (context, index) {
            final order = provider.buyerOrders[index];
            final dateStr = DateFormat('dd MMM yyyy, HH:mm').format(order.createdAt);
            
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: ExpansionTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Order #${order.id.substring(0, 6)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    OrderStatusBadge(status: order.status),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text(dateStr, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text('Total: ${currencyFormat.format(order.totalAmount)}', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                  ],
                ),
                children: [
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Detail Pesanan:', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        ...order.items.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            children: [
                              Text('${item.quantity}x ${item.productName}'),
                              const Spacer(),
                              if (order.status == 'selesai')
                                FutureBuilder<bool>(
                                  future: _reviewService.hasUserReviewed(user!.uid, order.id),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData && !snapshot.data!) {
                                      return TextButton(
                                        onPressed: () => _showReviewDialog(context, order.id, item.productId),
                                        child: const Text('Beri Ulasan', style: TextStyle(fontSize: 12)),
                                      );
                                    }
                                    return const SizedBox.shrink();
                                  },
                                ),
                            ],
                          ),
                        )),
                        const Divider(),
                        Text('Metode Pembayaran: ${order.paymentMethod}'),
                        Text('Penjual: ${order.sellerName}'),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
