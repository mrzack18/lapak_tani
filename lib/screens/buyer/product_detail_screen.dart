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
import 'package:lapak_tani/screens/buyer/store_screen.dart';
import 'package:lapak_tani/screens/chat/chat_detail_screen.dart';
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

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _fetchReviews() async {
    try {
      final reviews = await _reviewService.getReviewsByProduct(
        widget.productId,
      );
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
      if (!mounted) return;
      _showSnackBar('Stok produk tidak mencukupi', Colors.red.shade600);
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
      if (!mounted) return;
      _showSnackBar(
        'Berhasil ditambahkan ke keranjang!',
        const Color(0xFF1B8040),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final user = context.read<AuthProvider>().user;

    return Consumer2<ProductProvider, WishlistProvider>(
      builder: (context, productProvider, wishlistProvider, child) {
        final product = productProvider.selectedProduct;

        if (productProvider.isLoading) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF1B8040)),
            ),
          );
        }

        if (product == null) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 64,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Produk tidak ditemukan',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                  ),
                ],
              ),
            ),
          );
        }

        final isWishlisted = wishlistProvider.isWishlisted(product.id);

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF1E293B),
            title: const Text(
              'Detail Produk',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            centerTitle: true,
            actions: [
              if (user != null && user.role == 'pembeli')
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: IconButton(
                    icon: Icon(
                      isWishlisted
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      size: 24,
                    ),
                    color: isWishlisted
                        ? Colors.red.shade500
                        : Colors.grey.shade500,
                    onPressed: () {
                      wishlistProvider.toggleWishlist(user.uid, product);
                    },
                  ),
                ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Product Image Edge-to-Edge ────────────────────────────
                Container(
                  color: Colors.grey.shade100,
                  width: double.infinity,
                  child: AspectRatio(
                    aspectRatio: 1, // 1:1 Square image for better product view
                    child: Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_not_supported_outlined,
                            size: 64,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Gambar tidak tersedia',
                            style: TextStyle(color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Product Details Body ───────────────────────────────────
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title & Price
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              product.name,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${currencyFormat.format(product.price)} / ${product.unit}',
                        style: const TextStyle(
                          fontSize: 20,
                          color: Color(0xFF1B8040),
                          fontWeight: FontWeight.w900,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ── Meta Info (Rating & Stock) ───────────────────────────
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.amber.shade100),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.star_rounded,
                                  size: 16,
                                  color: Colors.amber.shade600,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${product.rating.toStringAsFixed(1)} (${product.reviewCount} ulasan)',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: Colors.amber.shade900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: product.stock > 0
                                  ? Colors.green.shade50
                                  : Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: product.stock > 0
                                    ? Colors.green.shade100
                                    : Colors.red.shade100,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.inventory_2_rounded,
                                  size: 16,
                                  color: product.stock > 0
                                      ? Colors.green.shade600
                                      : Colors.red.shade600,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  product.stock > 0
                                      ? 'Stok: ${product.stock}'
                                      : 'Stok Habis',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: product.stock > 0
                                        ? Colors.green.shade700
                                        : Colors.red.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // ── Seller Info ──────────────────────────────────────────
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    StoreScreen(sellerId: product.sellerId),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.grey.shade200,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF1B8040,
                                    ).withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.storefront_rounded,
                                    color: Color(0xFF1B8040),
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Dijual oleh',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        product.sellerName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: Color(0xFF1E293B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  color: Colors.grey.shade400,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Divider(height: 1),
                      ),

                      // ── Description ──────────────────────────────────────────
                      const Text(
                        'Deskripsi Produk',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        product.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                          height: 1.6,
                        ),
                      ),

                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Divider(height: 1),
                      ),

                      // ── Reviews ──────────────────────────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Ulasan Pembeli',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          if (product.reviewCount > 0)
                            Text(
                              '${product.reviewCount} ulasan',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 13,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      if (_isLoadingReviews)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(
                              color: Color(0xFF1B8040),
                            ),
                          ),
                        )
                      else if (_reviews.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.grey.shade200,
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.rate_review_outlined,
                                size: 40,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Belum ada ulasan untuk produk ini',
                                style: TextStyle(color: Colors.grey.shade500),
                              ),
                            ],
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _reviews.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            return ReviewCard(review: _reviews[index]);
                          },
                        ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Bottom Navigation / Action Bar ────────────────────────────────
          bottomNavigationBar: user?.role == 'pembeli'
              ? SafeArea(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Quantity Selector
                        Container(
                          height: 48,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.remove_rounded,
                                  color: _quantity > 1
                                      ? Colors.black87
                                      : Colors.grey,
                                ),
                                onPressed: _quantity > 1
                                    ? () => setState(() => _quantity--)
                                    : null,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(minWidth: 40),
                              ),
                              Text(
                                '$_quantity',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.add_rounded,
                                  color: _quantity < product.stock
                                      ? Colors.black87
                                      : Colors.grey,
                                ),
                                onPressed: _quantity < product.stock
                                    ? () => setState(() => _quantity++)
                                    : null,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(minWidth: 40),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Chat Penjual Button
                        Container(
                          height: 48,
                          width: 48,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xFF1B8040),
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            color: const Color(0xFF1B8040).withValues(alpha: 0.05),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.chat_bubble_outline_rounded,
                              color: Color(0xFF1B8040),
                              size: 20,
                            ),
                            padding: EdgeInsets.zero,
                            tooltip: 'Chat Penjual',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChatDetailScreen(
                                    targetUserId: product.sellerId,
                                    targetUserName: product.sellerName,
                                    taggedProductId: product.id,
                                    taggedProductName: product.name,
                                    taggedProductImageUrl: product.imageUrl,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Add to cart button
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: ElevatedButton.icon(
                              icon: const Icon(
                                Icons.add_shopping_cart_rounded,
                                size: 20,
                              ),
                              label: const Text(
                                'Keranjang',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1B8040),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                disabledBackgroundColor: Colors.grey.shade300,
                              ),
                              onPressed: product.stock > 0 && product.isActive
                                  ? () => _addToCart(user!.uid, product)
                                  : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : null,
        );
      },
    );
  }
}
