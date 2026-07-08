import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lapak_tani/providers/product_provider.dart';
import 'package:lapak_tani/providers/cart_provider.dart';
import 'package:lapak_tani/providers/wishlist_provider.dart';
import 'package:lapak_tani/providers/auth_provider.dart';
import 'package:lapak_tani/models/cart_item_model.dart';
import 'package:lapak_tani/services/review_service.dart';
import 'package:lapak_tani/models/review_model.dart';
import 'package:lapak_tani/widgets/review_card.dart';
import 'package:lapak_tani/widgets/loading_widget.dart';
import 'package:intl/intl.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final _reviewService = ReviewService();
  int _quantity = 1;
  List<ReviewModel> _reviews = [];
  bool _isLoadingReviews = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchProductById(widget.productId);
      final user = context.read<AuthProvider>().user;
      if (user != null) {
        context.read<WishlistProvider>().fetchWishlist(user.uid);
      }
      _fetchReviews();
    });
  }

  Future<void> _fetchReviews() async {
    try {
      final reviews = await _reviewService.getReviewsByProduct(widget.productId);
      if (mounted) {
        setState(() {
          _reviews = reviews;
          _isLoadingReviews = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingReviews = false);
    }
  }

  void _addToCart(String uid, dynamic product) {
    if (product.stock < _quantity) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stok tidak mencukupi'), backgroundColor: Colors.red),
      );
      return;
    }

    final item = CartItemModel(
      id: '', // Generated in service
      productId: product.id,
      productName: product.name,
      productImageUrl: product.imageUrl,
      productPrice: product.price,
      sellerId: product.sellerId,
      sellerName: product.sellerName,
      quantity: _quantity,
      addedAt: DateTime.now(),
    );

    context.read<CartProvider>().addToCart(uid, item).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Berhasil ditambahkan ke keranjang'), backgroundColor: Colors.green),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final user = context.read<AuthProvider>().user;
    
    return Consumer2<ProductProvider, WishlistProvider>(
      builder: (context, productProvider, wishlistProvider, child) {
        final product = productProvider.selectedProduct;
        
        if (productProvider.isLoading) {
          return const Scaffold(body: LoadingWidget());
        }
        
        if (product == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Produk tidak ditemukan')),
          );
        }

        final isWishlisted = wishlistProvider.isWishlisted(product.id);

        return Scaffold(
          appBar: AppBar(
            actions: [
              if (user != null && user.role == 'pembeli')
                IconButton(
                  icon: Icon(isWishlisted ? Icons.favorite : Icons.favorite_border),
                  color: isWishlisted ? Colors.red : null,
                  onPressed: () {
                    wishlistProvider.toggleWishlist(user.uid, product);
                  },
                ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image
                AspectRatio(
                  aspectRatio: 4 / 3,
                  child: Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported, size: 50),
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title & Price
                      Text(product.name, style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 8),
                      Text(
                        '${currencyFormat.format(product.price)} / ${product.unit}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      // Meta info
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.store, size: 20, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(product.sellerName, style: const TextStyle(color: Colors.grey)),
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(Icons.inventory, size: 20, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text('Stok: ${product.stock}', style: const TextStyle(color: Colors.grey)),
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(Icons.star, size: 20, color: Colors.amber),
                              const SizedBox(width: 4),
                              Text('${product.rating.toStringAsFixed(1)} (${product.reviewCount})'),
                            ],
                          ),
                        ],
                      ),
                      
                      const Divider(height: 32),
                      
                      // Description
                      Text('Deskripsi Produk', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(product.description),
                      
                      const Divider(height: 32),
                      
                      // Reviews
                      Text('Ulasan Pembeli (${product.reviewCount})', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      
                      if (_isLoadingReviews)
                        const LoadingWidget()
                      else if (_reviews.isEmpty)
                        const Text('Belum ada ulasan untuk produk ini.')
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _reviews.length,
                          itemBuilder: (context, index) {
                            return ReviewCard(review: _reviews[index]);
                          },
                        ),
                        
                      const SizedBox(height: 80), // Padding for bottom bar
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: user?.role == 'pembeli' ? SafeArea(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, -2))],
              ),
              child: Row(
                children: [
                  // Quantity
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                        ),
                        Text('$_quantity', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: _quantity < product.stock ? () => setState(() => _quantity++) : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Add to cart button
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.shopping_cart),
                      label: const Text('Tambah ke Keranjang'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: product.stock > 0 && product.isActive ? () => _addToCart(user!.uid, product) : null,
                    ),
                  ),
                ],
              ),
            ),
          ) : null,
        );
      },
    );
  }
}
