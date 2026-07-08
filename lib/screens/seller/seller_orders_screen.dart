import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lapak_tani/providers/order_provider.dart';
import 'package:lapak_tani/widgets/order_status_badge.dart';
import 'package:intl/intl.dart';

class SellerOrdersScreen extends StatelessWidget {
  const SellerOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Consumer<OrderProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.sellerOrders.isEmpty) {
          return const Center(child: Text('Belum ada pesanan masuk'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.sellerOrders.length,
          itemBuilder: (context, index) {
            final order = provider.sellerOrders[index];
            final dateStr = DateFormat('dd MMM yyyy, HH:mm').format(order.createdAt);
            
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: ExpansionTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(order.buyerName, style: const TextStyle(fontWeight: FontWeight.bold)),
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
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${item.quantity}x ${item.productName}'),
                              Text(currencyFormat.format(item.subtotal)),
                            ],
                          ),
                        )),
                        const Divider(),
                        Text('Alamat: ${order.buyerAddress}'),
                        Text('No. HP: ${order.buyerPhone}'),
                        Text('Pembayaran: ${order.paymentMethod}'),
                        if (order.notes.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text('Catatan: ${order.notes}', style: const TextStyle(fontStyle: FontStyle.italic)),
                        ],
                        
                        const SizedBox(height: 16),
                        // Action Buttons based on status
                        if (order.status == 'pending')
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => provider.updateOrderStatus(order.id, 'dikonfirmasi'),
                              child: const Text('Konfirmasi Pesanan'),
                            ),
                          )
                        else if (order.status == 'dikonfirmasi')
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => provider.updateOrderStatus(order.id, 'dikirim'),
                              child: const Text('Kirim Pesanan'),
                            ),
                          )
                        else if (order.status == 'dikirim')
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => provider.updateOrderStatus(order.id, 'selesai'),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                              child: const Text('Selesaikan Pesanan', style: TextStyle(color: Colors.white)),
                            ),
                          ),
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
