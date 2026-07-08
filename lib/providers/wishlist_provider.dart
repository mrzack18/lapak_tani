import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lapak_tani/models/product_model.dart';

class WishlistProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<ProductModel> _wishlistItems = [];
  Set<String> _wishlistProductIds = {};
  bool _isLoading = false;

  List<ProductModel> get wishlistItems => _wishlistItems;
  Set<String> get wishlistProductIds => _wishlistProductIds;
  bool get isLoading => _isLoading;
  int get itemCount => _wishlistItems.length;

  /// Check if a product is in the wishlist
  bool isWishlisted(String productId) =>
      _wishlistProductIds.contains(productId);

  /// Fetch wishlist items from Firestore subcollection: wishlists/{uid}/items/{productId}
  Future<void> fetchWishlist(String uid) async {
    try {
      _isLoading = true;
      notifyListeners();

      final snapshot = await _firestore
          .collection('wishlists')
          .doc(uid)
          .collection('items')
          .get();

      _wishlistItems = [];
      _wishlistProductIds = {};

      for (final doc in snapshot.docs) {
        final data = doc.data();
        // Each wishlist item document stores product data directly
        final product = ProductModel.fromMap({
          'id': doc.id,
          ...data,
        });
        _wishlistItems.add(product);
        _wishlistProductIds.add(doc.id);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Toggle wishlist status: add if not wishlisted, remove if already wishlisted
  Future<void> toggleWishlist(String uid, ProductModel product) async {
    try {
      final docRef = _firestore
          .collection('wishlists')
          .doc(uid)
          .collection('items')
          .doc(product.id);

      if (_wishlistProductIds.contains(product.id)) {
        // Remove from wishlist
        await docRef.delete();
        _wishlistItems.removeWhere((p) => p.id == product.id);
        _wishlistProductIds.remove(product.id);
      } else {
        // Add to wishlist - store product data for easy retrieval
        await docRef.set({
          'sellerId': product.sellerId,
          'sellerName': product.sellerName,
          'categoryId': product.categoryId,
          'categoryName': product.categoryName,
          'name': product.name,
          'description': product.description,
          'price': product.price,
          'unit': product.unit,
          'stock': product.stock,
          'imageUrl': product.imageUrl,
          'rating': product.rating,
          'reviewCount': product.reviewCount,
          'isActive': product.isActive,
          'addedAt': FieldValue.serverTimestamp(),
        });
        _wishlistItems.add(product);
        _wishlistProductIds.add(product.id);
      }

      notifyListeners();
    } catch (e) {
      notifyListeners();
    }
  }

  /// Remove a specific product from wishlist
  Future<void> removeFromWishlist(String uid, String productId) async {
    try {
      await _firestore
          .collection('wishlists')
          .doc(uid)
          .collection('items')
          .doc(productId)
          .delete();

      _wishlistItems.removeWhere((p) => p.id == productId);
      _wishlistProductIds.remove(productId);
      notifyListeners();
    } catch (e) {
      notifyListeners();
    }
  }

  /// Clear all wishlist items
  Future<void> clearWishlist(String uid) async {
    try {
      _isLoading = true;
      notifyListeners();

      final snapshot = await _firestore
          .collection('wishlists')
          .doc(uid)
          .collection('items')
          .get();

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      _wishlistItems = [];
      _wishlistProductIds = {};
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }
}
