import 'package:flutter/material.dart';
import 'package:lapak_tani/models/order_model.dart';
import 'package:lapak_tani/services/order_service.dart';
import 'package:lapak_tani/services/notification_service.dart';

class OrderProvider extends ChangeNotifier {
  final OrderService _orderService = OrderService();
  final NotificationService _notificationService = NotificationService();

  List<OrderModel> _buyerOrders = [];
  List<OrderModel> _sellerOrders = [];
  List<OrderModel> _allOrders = [];
  bool _isLoading = false;
  String? _error;

  List<OrderModel> get buyerOrders => _buyerOrders;
  List<OrderModel> get sellerOrders => _sellerOrders;
  List<OrderModel> get allOrders => _allOrders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Fetch all orders for a buyer
  Future<void> fetchBuyerOrders(String buyerId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _buyerOrders = await _orderService.getOrdersByBuyer(buyerId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Gagal memuat pesanan: $e';
      notifyListeners();
    }
  }

  /// Fetch all orders for a seller
  Future<void> fetchSellerOrders(String sellerId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _sellerOrders = await _orderService.getOrdersBySeller(sellerId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Gagal memuat pesanan: $e';
      notifyListeners();
    }
  }

  /// Create a new order
  Future<bool> createOrder(OrderModel order) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final newOrderId = await _orderService.createOrder(order);

      // Add to local buyer orders list
      final newOrder = order.copyWith(id: newOrderId);
      _buyerOrders.insert(0, newOrder);

      // Trigger notifications
      await _notificationService.sendNotification(
        userId: order.sellerId,
        title: 'Pesanan Baru Masuk!',
        message: 'Pembeli ${order.buyerName} membuat pesanan baru.',
        type: 'order',
        relatedId: newOrderId,
      );
      await _notificationService.sendNotification(
        userId: 'admin',
        title: 'Pesanan Baru Masuk!',
        message: 'Pesanan baru dari ${order.buyerName} untuk lapak ${order.sellerName}.',
        type: 'order',
        relatedId: newOrderId,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = 'Gagal membuat pesanan: $e';
      notifyListeners();
      return false;
    }
  }
  /// Fetch all orders for admin
  Future<void> fetchAllOrders() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _allOrders = await _orderService.getAllOrders();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Gagal memuat pesanan (admin): $e';
      notifyListeners();
    }
  }

  /// Update order status (e.g., pending → dikonfirmasi → dikirim → selesai / dibatalkan)
  Future<bool> updateOrderStatus(String orderId, String status) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _orderService.updateOrderStatus(orderId, status);

      // Update local buyer orders
      final buyerIndex = _buyerOrders.indexWhere((o) => o.id == orderId);
      if (buyerIndex != -1) {
        _buyerOrders[buyerIndex] =
            _buyerOrders[buyerIndex].copyWith(status: status);
      }

      // Update local seller orders
      final sellerIndex = _sellerOrders.indexWhere((o) => o.id == orderId);
      if (sellerIndex != -1) {
        _sellerOrders[sellerIndex] =
            _sellerOrders[sellerIndex].copyWith(status: status);
      }

      // Find order to notify buyer
      final o = _allOrders.firstWhere((o) => o.id == orderId, 
          orElse: () => _sellerOrders.firstWhere((o) => o.id == orderId, 
          orElse: () => _buyerOrders.firstWhere((o) => o.id == orderId)));

      await _notificationService.sendNotification(
        userId: o.buyerId,
        title: 'Status Pesanan Diperbarui',
        message: 'Pesanan Anda dari ${o.sellerName} sekarang berstatus: ${status.toUpperCase()}.',
        type: 'order',
        relatedId: orderId,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = 'Gagal mengupdate status pesanan: $e';
      notifyListeners();
      return false;
    }
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
