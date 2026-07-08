import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lapak_tani/providers/wishlist_provider.dart';
import 'package:lapak_tani/providers/product_provider.dart';
import 'package:lapak_tani/widgets/product_card.dart';
import 'package:lapak_tani/screens/buyer/product_detail_screen.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<WishlistProvider, ProductProvider>(
      builder: (context, wishlist, productProvider, child) {
        // Find matching products from ProductProvider to show full details
        final wishlistedProducts = productProvider.products
            .where((p) => wishlist.isWishlisted(p.id))
            .toList();

        // ── Loading State ────────────────────────────────────────────────
        if (wishlist.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF1B8040)),
          );
        }

        // ── Empty State ──────────────────────────────────────────────────
        if (wishlistedProducts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.favorite_border_rounded,
                  size: 64,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 16),
                Text(
                  'Wishlist masih kosong',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Simpan produk favoritmu di sini',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                ),
              ],
            ),
          );
        }

        // ── Wishlist Grid ────────────────────────────────────────────────
        return GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio:
                0.7, // Rasio ini dijaga agar gambar produk tetap proporsional
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: wishlistedProducts.length,
          itemBuilder: (context, index) {
            final product = wishlistedProducts[index];
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
        );
      },
    );
  }
}
