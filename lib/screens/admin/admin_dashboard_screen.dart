import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lapak_tani/screens/admin/manage_users_screen.dart';
import 'package:lapak_tani/screens/admin/manage_products_screen.dart';
import 'package:lapak_tani/screens/admin/manage_orders_screen.dart';
import 'package:lapak_tani/screens/buyer/profile_screen.dart';
import 'package:lapak_tani/seeder/firestore_seeder.dart';
import 'package:lapak_tani/services/user_service.dart';
import 'package:lapak_tani/services/product_service.dart';
import 'package:lapak_tani/services/order_service.dart';
import 'package:intl/intl.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;
  
  final _userService = UserService();
  final _productService = ProductService();
  final _orderService = OrderService();
  
  int _totalUsers = 0;
  int _totalProducts = 0;
  int _totalOrders = 0;
  double _totalRevenue = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    setState(() => _isLoading = true);
    try {
      final users = await _userService.getTotalUsersCount();
      final products = await _productService.getTotalProductsCount();
      final orders = await _orderService.getTotalOrdersCount();
      
      final allOrdersList = await _orderService.getAllOrders();
      double revenue = 0.0;
      for (var o in allOrdersList) {
        if (o.status == 'selesai') {
          double subtotal = o.items.fold(0.0, (sum, item) => sum + item.subtotal);
          revenue += (subtotal * 0.10);
        }
      }
      
      if (mounted) {
        setState(() {
          _totalUsers = users;
          _totalProducts = products;
          _totalOrders = orders;
          _totalRevenue = revenue;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _runSeeder() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Sedang men-seed data... Mohon tunggu.'),
          ],
        ),
      ),
    );

    final seeder = FirestoreSeeder();
    final log = await seeder.seedAll();

    if (mounted) {
      Navigator.pop(context); // Close loading
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Hasil Seeder'),
          content: SingleChildScrollView(child: Text(log)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                _fetchStats(); // Refresh stats
              },
              child: const Text('Tutup'),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildDashboardTab() {
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return RefreshIndicator(
      onRefresh: _fetchStats,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Statistik Sistem', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(child: _StatCard(title: 'Pengguna', value: '$_totalUsers', icon: Icons.group, color: Colors.blue)),
                const SizedBox(width: 16),
                Expanded(child: _StatCard(title: 'Produk', value: '$_totalProducts', icon: Icons.inventory, color: Colors.green)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _StatCard(title: 'Total Pesanan', value: '$_totalOrders', icon: Icons.receipt, color: Colors.orange)),
                const SizedBox(width: 16),
                Expanded(child: _StatCard(title: 'PPN Admin', value: currencyFormat.format(_totalRevenue), icon: Icons.account_balance_wallet, color: Colors.purple)),
              ],
            ),
            
            const SizedBox(height: 32),
            
            Card(
              color: Colors.red.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.warning, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Development Tools', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('Gunakan tombol di bawah ini untuk mengisi database dengan data dummy lengkap (User, Kategori, Produk, Pesanan, Review).'),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.data_object),
                        label: const Text('Jalankan Seeder'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                        onPressed: _runSeeder,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildDashboardTab(),
      const ManageUsersScreen(),
      const ManageProductsScreen(),
      const ManageOrdersScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lapak Tani (Admin)'),
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Users'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory), label: 'Products'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt), label: 'Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.title, required this.value, required this.icon, required this.color});

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
