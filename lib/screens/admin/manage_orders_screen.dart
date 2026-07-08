import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lapak_tani/providers/order_provider.dart';
import 'package:lapak_tani/widgets/loading_widget.dart';
import 'package:lapak_tani/widgets/order_status_badge.dart';
import 'package:intl/intl.dart';

class ManageOrdersScreen extends StatefulWidget {
  const ManageOrdersScreen({super.key});

  @override
  State<ManageOrdersScreen> createState() => _ManageOrdersScreenState();
}

class _ManageOrdersScreenState extends State<ManageOrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().fetchAllOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

    return Consumer<OrderProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: LoadingWidget());
        }
        
        if (provider.error != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Terjadi Kesalahan:\n${provider.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        }

        if (provider.allOrders.isEmpty) {
          return const Center(child: Text('Belum ada pesanan masuk.'));
        }

        return RefreshIndicator(
          onRefresh: () => provider.fetchAllOrders(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.allOrders.length,
            itemBuilder: (context, index) {
              final order = provider.allOrders[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Order #${order.id.substring(0, 8)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          OrderStatusBadge(status: order.status),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Waktu: ${dateFormat.format(order.createdAt)}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      const Divider(),
                      Text('Pembeli: ${order.buyerName}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('Penjual: ${order.sellerName}'),
                      const SizedBox(height: 8),
                      Text('Total: ${currencyFormat.format(order.totalAmount)}', 
                           style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
