import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lapak_tani/providers/product_provider.dart';
import 'package:lapak_tani/models/product_model.dart';
import 'package:lapak_tani/screens/seller/edit_product_screen.dart';
import 'package:intl/intl.dart';

class MyProductsScreen extends StatelessWidget {
  const MyProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Consumer<ProductProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.products.isEmpty) {
          return const Center(child: Text('Anda belum memiliki produk. Tambahkan sekarang!'));
        }

        final availableProducts = provider.products.where((p) => p.stock > 0).toList();
        final emptyProducts = provider.products.where((p) => p.stock <= 0).toList();

        return DefaultTabController(
          length: 2,
          child: Column(
            children: [
              Container(
                color: Theme.of(context).primaryColor,
                child: const TabBar(
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  indicatorColor: Colors.white,
                  tabs: [
                    Tab(text: 'Stok Tersedia'),
                    Tab(text: 'Stok Habis'),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildProductList(availableProducts, currencyFormat, provider),
                    _buildProductList(emptyProducts, currencyFormat, provider),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProductList(List<ProductModel> products, NumberFormat currencyFormat, ProductProvider provider) {
    if (products.isEmpty) {
      return const Center(child: Text('Tidak ada produk di kategori ini.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(8),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                product.imageUrl,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 60),
              ),
            ),
            title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${currencyFormat.format(product.price)} / ${product.unit}', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.inventory, size: 14, color: product.stock > 0 ? Colors.green : Colors.red),
                    const SizedBox(width: 4),
                    Text('Stok: ${product.stock}'),
                    const SizedBox(width: 8),
                    if (!product.isActive)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(4)),
                        child: const Text('Nonaktif', style: TextStyle(color: Colors.white, fontSize: 10)),
                      ),
                  ],
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {
                    // ignore: use_build_context_synchronously
                    Navigator.push(context, MaterialPageRoute(builder: (_) => EditProductScreen(product: product)));
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Hapus Produk'),
                        content: const Text('Yakin ingin menghapus produk ini?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              provider.deleteProduct(product.id);
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            child: const Text('Hapus'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
