import 'package:flutter/material.dart';
import 'package:lapak_tani/models/cart_item_model.dart';
import 'package:lapak_tani/services/cart_service.dart';

class CartProvider extends ChangeNotifier {
  final CartService _cartService = CartService();

  List<CartItemModel> _items = [];
  bool _isLoading = false;

  List<CartItemModel> get items => _items;
  bool get isLoading => _isLoading;
  int get itemCount => _items.length;
  double get totalAmount =>
      _items.fold(0, (sum, item) => sum + item.subtotal);

  /// Fetch all cart items for a user
  Future<void> fetchCart(String uid) async {
    try {
      _isLoading = true;
      notifyListeners();

      _items = await _cartService.getCartItems(uid);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add an item to cart
  Future<void> addToCart(String uid, CartItemModel item) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Check if the product already exists in cart
      final existingIndex =
          _items.indexWhere((i) => i.productId == item.productId);

      if (existingIndex != -1) {
        // Update quantity if already in cart
        final existingItem = _items[existingIndex];
        final newQty = existingItem.quantity + item.quantity;
        await _cartService.updateQuantity(uid, existingItem.id, newQty);
        _items[existingIndex] = existingItem.copyWith(quantity: newQty);
      } else {
        // Add new item to cart
        await _cartService.addToCart(uid, item);
        _items.add(item);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update quantity of a cart item
  Future<void> updateQuantity(String uid, String itemId, int qty) async {
    try {
      if (qty <= 0) {
        await removeFromCart(uid, itemId);
        return;
      }

      await _cartService.updateQuantity(uid, itemId, qty);

      final index = _items.indexWhere((i) => i.id == itemId);
      if (index != -1) {
        _items[index] = _items[index].copyWith(quantity: qty);
      }

      notifyListeners();
    } catch (e) {
      notifyListeners();
    }
  }

  /// Remove an item from cart
  Future<void> removeFromCart(String uid, String itemId) async {
    try {
      await _cartService.removeFromCart(uid, itemId);
      _items.removeWhere((i) => i.id == itemId);
      notifyListeners();
    } catch (e) {
      notifyListeners();
    }
  }

  /// Clear all items from cart (e.g. after checkout)
  Future<void> clearCart(String uid) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _cartService.clearCart(uid);
      _items = [];
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }
}
