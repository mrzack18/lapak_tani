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

        if (wishlist.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (wishlistedProducts.isEmpty) {
          return const Center(child: Text('Wishlist Anda kosong'));
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.7,
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
