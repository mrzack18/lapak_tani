import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lapak_tani/providers/product_provider.dart';
import 'package:lapak_tani/providers/order_provider.dart';
import 'package:lapak_tani/providers/auth_provider.dart';
import 'package:lapak_tani/screens/buyer/buyer_home_tab.dart';
import 'package:lapak_tani/screens/seller/my_products_screen.dart';
import 'package:lapak_tani/screens/seller/add_product_screen.dart';
import 'package:lapak_tani/screens/seller/seller_orders_screen.dart';
import 'package:lapak_tani/screens/chat/chat_list_screen.dart';
import 'package:lapak_tani/screens/notification_screen.dart';
import 'package:lapak_tani/services/chat_service.dart';
import 'package:lapak_tani/services/notification_service.dart';
import 'package:lapak_tani/models/chat_room_model.dart';
import 'package:lapak_tani/models/notification_model.dart';
import 'package:lapak_tani/screens/buyer/profile_screen.dart';
import 'package:intl/intl.dart';

class SellerDashboardScreen extends StatefulWidget {
  const SellerDashboardScreen({super.key});

  @override
  State<SellerDashboardScreen> createState() => _SellerDashboardScreenState();
}

class _SellerDashboardScreenState extends State<SellerDashboardScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().user;
      if (user != null) {
        context.read<ProductProvider>().fetchCategories();
        context.read<ProductProvider>().fetchSellerProducts(user.uid);
        context.read<OrderProvider>().fetchSellerOrders(user.uid);
      }
    });
  }

  Widget _buildDashboardTab() {
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    
    return Consumer2<ProductProvider, OrderProvider>(
      builder: (context, productProvider, orderProvider, child) {
        final totalProducts = productProvider.products.length;
        final orders = orderProvider.sellerOrders;
        final pendingOrders = orders.where((o) => o.status == 'pending').length;
        
        // Calculate total income from completed orders
        final completedOrders = orders.where((o) => o.status == 'selesai');
        double totalIncome = 0;
        for (var order in completedOrders) {
          totalIncome += order.items.fold(0.0, (sum, item) => sum + item.subtotal);
        }

        return RefreshIndicator(
          onRefresh: () async {
            final user = context.read<AuthProvider>().user;
            if (user != null) {
              await context.read<ProductProvider>().fetchSellerProducts(user.uid);
              await context.read<OrderProvider>().fetchSellerOrders(user.uid);
            }
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ringkasan Lapak', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: _SummaryCard(
                        title: 'Total Produk',
                        value: '$totalProducts',
                        icon: Icons.inventory,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _SummaryCard(
                        title: 'Pesanan Baru',
                        value: '$pendingOrders',
                        icon: Icons.receipt_long,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total Pendapatan', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(
                        currencyFormat.format(totalIncome),
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                      const SizedBox(height: 4),
                      const Text('*Dari pesanan selesai', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().user;
    final List<Widget> pages = [
      const BuyerHomeTab(),
      _buildDashboardTab(),
      const MyProductsScreen(),
      const SellerOrdersScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lapak Tani (Petani)'),
        actions: [
          if (user != null) ...[
            // Notification Bell
            StreamBuilder<List<NotificationModel>>(
              stream: NotificationService().getUserNotifications(user.uid, user.role),
              builder: (context, snapshot) {
                int unreadNotif = 0;
                if (snapshot.hasData) {
                  unreadNotif = snapshot.data!.where((n) => !n.isRead).length;
                }
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationScreen()));
                      },
                    ),
                    if (unreadNotif > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                          child: Text(
                            '$unreadNotif',
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              }
            ),
            
            // Chat Icon
            StreamBuilder<List<ChatRoomModel>>(
              stream: ChatService().getUserChatRooms(user.uid, user.role),
              builder: (context, snapshot) {
                int totalUnread = 0;
                if (snapshot.hasData) {
                  for (var room in snapshot.data!) {
                    totalUnread += room.unreadCountSeller; // since this is seller screen
                  }
                }
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chat),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatListScreen()));
                      },
                    ),
                    if (totalUnread > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                          child: Text(
                            '$totalUnread',
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ]
        ],
      ),
      body: pages[_selectedIndex],
      floatingActionButton: _selectedIndex == 2 ? FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AddProductScreen()));
        },
        child: const Icon(Icons.add),
      ) : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory), label: 'Produk Saya'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt), label: 'Pesanan'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}
