import 'package:flutter/material.dart';
import 'package:lapak_tani/models/user_model.dart';
import 'package:lapak_tani/models/product_model.dart';
import 'package:lapak_tani/services/user_service.dart';
import 'package:lapak_tani/services/product_service.dart';
import 'package:lapak_tani/widgets/product_card.dart';
import 'package:lapak_tani/screens/buyer/product_detail_screen.dart';
import 'package:lapak_tani/widgets/loading_widget.dart';

class StoreScreen extends StatefulWidget {
  final String sellerId;
  
  const StoreScreen({super.key, required this.sellerId});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  final _userService = UserService();
  final _productService = ProductService();
  
  UserModel? _seller;
  List<ProductModel> _products = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchStoreData();
  }

  Future<void> _fetchStoreData() async {
    try {
      final seller = await _userService.getUserById(widget.sellerId);
      final allSellerProducts = await _productService.getSellerProducts(widget.sellerId);
      
      // Hanya tampilkan produk yang aktif (karena ini dilihat oleh pembeli)
      final activeProducts = allSellerProducts.where((p) => p.isActive).toList();
      
      if (mounted) {
        setState(() {
          _seller = seller;
          _products = activeProducts;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Gagal memuat data toko';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Toko'),
      ),
      body: _isLoading 
        ? const LoadingWidget() 
        : _error != null 
          ? Center(child: Text(_error!))
          : _seller == null 
            ? const Center(child: Text('Toko tidak ditemukan'))
            : Column(
                children: [
                  // Store Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Theme.of(context).primaryColor,
                          child: const Icon(Icons.store, size: 40, color: Colors.white),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _seller!.name,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.phone, size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(_seller!.phone, style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                        if (_seller!.address.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    _seller!.address, 
                                    style: const TextStyle(color: Colors.grey),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  // Product List
                  Expanded(
                    child: _products.isEmpty
                      ? const Center(child: Text('Toko ini belum memiliki produk aktif.'))
                      : GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.7,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: _products.length,
                          itemBuilder: (context, index) {
                            final product = _products[index];
                            return ProductCard(
                              product: product,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ProductDetailScreen(productId: product.id),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                  ),
                ],
              ),
    );
  }
}
