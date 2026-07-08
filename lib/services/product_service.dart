import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lapak_tani/models/product_model.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ---------------------------------------------------------------------------
  // READ
  // ---------------------------------------------------------------------------

  /// Get all active products, ordered by createdAt descending.
  Future<List<ProductModel>> getAllProducts() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('products')
          .where('isActive', isEqualTo: true)
          .get();

      final docs = snapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc))
          .toList();
      docs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return docs;
    } catch (e) {
      throw Exception('Gagal mengambil daftar produk: $e');
    }
  }

  /// Get a single product by its document ID.
  /// Returns null if the product does not exist.
  Future<ProductModel?> getProductById(String id) async {
    try {
      final DocumentSnapshot doc =
          await _firestore.collection('products').doc(id).get();

      if (!doc.exists) return null;

      return ProductModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Gagal mengambil detail produk: $e');
    }
  }

  /// Get all active products belonging to a specific category.
  Future<List<ProductModel>> getProductsByCategory(String categoryId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('products')
          .where('categoryId', isEqualTo: categoryId)
          .where('isActive', isEqualTo: true)
          .get();

      final docs = snapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc))
          .toList();
      docs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return docs;
    } catch (e) {
      throw Exception('Gagal mengambil produk berdasarkan kategori: $e');
    }
  }

  /// Search products by name.
  /// Because Firestore does not natively support case-insensitive full-text
  /// search, this fetches all active products and filters locally.
  Future<List<ProductModel>> searchProducts(String query) async {
    try {
      final String lowerQuery = query.toLowerCase().trim();

      if (lowerQuery.isEmpty) {
        return getAllProducts();
      }

      final QuerySnapshot snapshot = await _firestore
          .collection('products')
          .where('isActive', isEqualTo: true)
          .get();

      final docs = snapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc))
          .where((product) =>
              product.name.toLowerCase().contains(lowerQuery) ||
              product.description.toLowerCase().contains(lowerQuery))
          .toList();
      docs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return docs;
    } catch (e) {
      throw Exception('Gagal mencari produk: $e');
    }
  }

  /// Get all products belonging to a specific seller.
  Future<List<ProductModel>> getSellerProducts(String sellerId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('products')
          .where('sellerId', isEqualTo: sellerId)
          .get();

      final docs = snapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc))
          .toList();
      docs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return docs;
    } catch (e) {
      throw Exception('Gagal mengambil produk seller: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // WRITE
  // ---------------------------------------------------------------------------

  /// Add a new product. Firestore auto-generates the document ID.
  Future<void> addProduct(ProductModel product) async {
    try {
      final DocumentReference docRef =
          _firestore.collection('products').doc();

      final ProductModel newProduct = product.copyWith(
        id: docRef.id,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await docRef.set(newProduct.toMap());
    } catch (e) {
      throw Exception('Gagal menambahkan produk: $e');
    }
  }

  /// Update an existing product. Automatically bumps `updatedAt`.
  Future<void> updateProduct(ProductModel product) async {
    try {
      final ProductModel updatedProduct = product.copyWith(
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('products')
          .doc(product.id)
          .update(updatedProduct.toMap());
    } catch (e) {
      throw Exception('Gagal memperbarui produk: $e');
    }
  }

  /// Delete a product by its document ID.
  Future<void> deleteProduct(String productId) async {
    try {
      await _firestore.collection('products').doc(productId).delete();
    } catch (e) {
      throw Exception('Gagal menghapus produk: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // PARTIAL UPDATES
  // ---------------------------------------------------------------------------

  /// Update only the stock field of a product.
  Future<void> updateStock(String productId, int newStock) async {
    try {
      await _firestore.collection('products').doc(productId).update({
        'stock': newStock,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Gagal memperbarui stok: $e');
    }
  }

  /// Update the product's average rating and review count.
  /// Called after a new review is submitted.
  Future<void> updateProductRating(
    String productId,
    double newRating,
    int newCount,
  ) async {
    try {
      await _firestore.collection('products').doc(productId).update({
        'rating': newRating,
        'reviewCount': newCount,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Gagal memperbarui rating produk: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // AGGREGATION
  // ---------------------------------------------------------------------------

  /// Get the total number of products (active + inactive).
  Future<int> getTotalProductsCount() async {
    try {
      final AggregateQuerySnapshot snapshot =
          await _firestore.collection('products').count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      throw Exception('Gagal menghitung jumlah produk: $e');
    }
  }
}
