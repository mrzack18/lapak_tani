import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lapak_tani/models/cart_item_model.dart';

class CartService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Path helper: carts/{uid}/items
  CollectionReference _itemsRef(String uid) =>
      _firestore.collection('carts').doc(uid).collection('items');

  /// Get all cart items for a user.
  Future<List<CartItemModel>> getCartItems(String uid) async {
    try {
      final QuerySnapshot snapshot =
          await _itemsRef(uid).orderBy('addedAt', descending: true).get();

      return snapshot.docs
          .map((doc) => CartItemModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Gagal mengambil keranjang: $e');
    }
  }

  /// Add an item to the cart.
  /// If the same product already exists in the cart, its quantity is
  /// incremented instead of adding a duplicate entry.
  Future<void> addToCart(String uid, CartItemModel item) async {
    try {
      // Check if the product is already in the cart
      final QuerySnapshot existing = await _itemsRef(uid)
          .where('productId', isEqualTo: item.productId)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        // Product already in cart — increment quantity
        final DocumentSnapshot existingDoc = existing.docs.first;
        final int currentQty =
            (existingDoc.data() as Map<String, dynamic>)['quantity'] as int? ??
                1;
        await existingDoc.reference.update({
          'quantity': currentQty + item.quantity,
        });
      } else {
        // New item — add with auto-generated ID
        final DocumentReference docRef = _itemsRef(uid).doc();
        final CartItemModel newItem = item.copyWith(id: docRef.id);
        await docRef.set(newItem.toMap());
      }
    } catch (e) {
      throw Exception('Gagal menambahkan ke keranjang: $e');
    }
  }

  /// Update the quantity of a specific cart item.
  /// If [quantity] is <= 0 the item is removed instead.
  Future<void> updateQuantity(
    String uid,
    String itemId,
    int quantity,
  ) async {
    try {
      if (quantity <= 0) {
        await removeFromCart(uid, itemId);
        return;
      }

      await _itemsRef(uid).doc(itemId).update({
        'quantity': quantity,
      });
    } catch (e) {
      throw Exception('Gagal memperbarui jumlah: $e');
    }
  }

  /// Remove a single item from the cart.
  Future<void> removeFromCart(String uid, String itemId) async {
    try {
      await _itemsRef(uid).doc(itemId).delete();
    } catch (e) {
      throw Exception('Gagal menghapus item dari keranjang: $e');
    }
  }

  /// Clear all items in the user's cart subcollection.
  Future<void> clearCart(String uid) async {
    try {
      final QuerySnapshot snapshot = await _itemsRef(uid).get();

      // Use a batched write for efficiency
      final WriteBatch batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Gagal mengosongkan keranjang: $e');
    }
  }
}
