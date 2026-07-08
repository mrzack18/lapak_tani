import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lapak_tani/models/order_model.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Create a new order from cart items.
  /// Returns the auto-generated order ID.
  Future<String> createOrder(OrderModel order) async {
    try {
      final batch = _firestore.batch();

      final DocumentReference docRef =
          _firestore.collection('orders').doc();

      final OrderModel newOrder = order.copyWith(
        id: docRef.id,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // 1. Tambahkan pesanan ke batch
      batch.set(docRef, newOrder.toMap());

      // 2. Kurangi stok setiap produk di pesanan ini
      for (var item in order.items) {
        final productRef = _firestore.collection('products').doc(item.productId);
        batch.update(productRef, {
          'stock': FieldValue.increment(-item.quantity),
        });
      }

      // Jalankan batch
      await batch.commit();

      return docRef.id;
    } catch (e) {
      throw Exception('Gagal membuat pesanan: $e');
    }
  }

  /// Get all orders placed by a specific buyer, newest first.
  Future<List<OrderModel>> getOrdersByBuyer(String buyerId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('orders')
          .where('buyerId', isEqualTo: buyerId)
          .get();

      final docs = snapshot.docs
          .map((doc) => OrderModel.fromFirestore(doc))
          .toList();
      docs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return docs;
    } catch (e) {
      throw Exception('Gagal mengambil pesanan pembeli: $e');
    }
  }

  /// Get all orders assigned to a specific seller, newest first.
  Future<List<OrderModel>> getOrdersBySeller(String sellerId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('orders')
          .where('sellerId', isEqualTo: sellerId)
          .get();

      final docs = snapshot.docs
          .map((doc) => OrderModel.fromFirestore(doc))
          .toList();
      docs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return docs;
    } catch (e) {
      throw Exception('Gagal mengambil pesanan seller: $e');
    }
  }

  /// Update the status of an existing order.
  /// Also bumps `updatedAt`.
  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': status,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Gagal memperbarui status pesanan: $e');
    }
  }

  /// Get all orders across the system (admin view), newest first.
  Future<List<OrderModel>> getAllOrders() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('orders')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => OrderModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Gagal mengambil semua pesanan: $e');
    }
  }

  /// Get the total number of orders.
  Future<int> getTotalOrdersCount() async {
    try {
      final AggregateQuerySnapshot snapshot =
          await _firestore.collection('orders').count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      throw Exception('Gagal menghitung jumlah pesanan: $e');
    }
  }
}
