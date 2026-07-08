import 'package:cloud_firestore/cloud_firestore.dart';

class OrderItemModel {
  final String productId;
  final String productName;
  final String productImageUrl;
  final double productPrice;
  final int quantity;
  final double subtotal;

  OrderItemModel({
    required this.productId,
    required this.productName,
    this.productImageUrl = '',
    required this.productPrice,
    required this.quantity,
    double? subtotal,
  }) : subtotal = subtotal ?? (productPrice * quantity);

  factory OrderItemModel.fromMap(Map<String, dynamic> map) {
    final price = (map['productPrice'] as num?)?.toDouble() ?? 0.0;
    final qty = (map['quantity'] as num?)?.toInt() ?? 1;
    return OrderItemModel(
      productId: map['productId'] as String? ?? '',
      productName: map['productName'] as String? ?? '',
      productImageUrl: map['productImageUrl'] as String? ?? '',
      productPrice: price,
      quantity: qty,
      subtotal: (map['subtotal'] as num?)?.toDouble() ?? (price * qty),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'productImageUrl': productImageUrl,
      'productPrice': productPrice,
      'quantity': quantity,
      'subtotal': subtotal,
    };
  }

  @override
  String toString() {
    return 'OrderItemModel(productName: $productName, qty: $quantity, subtotal: $subtotal)';
  }
}
