import 'package:cloud_firestore/cloud_firestore.dart';

import 'order_item_model.dart';

class OrderModel {
  final String id;
  final String buyerId;
  final String buyerName;
  final String buyerAddress;
  final String buyerPhone;
  final String sellerId;
  final String sellerName;
  final List<OrderItemModel> items;
  final double totalAmount;
  final String status; // 'pending','dikonfirmasi','dikirim','selesai','dibatalkan'
  final String paymentMethod; // 'COD','Transfer Bank'
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  OrderModel({
    required this.id,
    required this.buyerId,
    required this.buyerName,
    this.buyerAddress = '',
    this.buyerPhone = '',
    required this.sellerId,
    required this.sellerName,
    required this.items,
    required this.totalAmount,
    this.status = 'pending',
    this.paymentMethod = 'COD',
    this.notes = '',
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id'] as String? ?? '',
      buyerId: map['buyerId'] as String? ?? '',
      buyerName: map['buyerName'] as String? ?? '',
      buyerAddress: map['buyerAddress'] as String? ?? '',
      buyerPhone: map['buyerPhone'] as String? ?? '',
      sellerId: map['sellerId'] as String? ?? '',
      sellerName: map['sellerName'] as String? ?? '',
      items: _parseItems(map['items']),
      totalAmount: (map['totalAmount'] as num?)?.toDouble() ?? 0.0,
      status: map['status'] as String? ?? 'pending',
      paymentMethod: map['paymentMethod'] as String? ?? 'COD',
      notes: map['notes'] as String? ?? '',
      createdAt: _parseDateTime(map['createdAt']),
      updatedAt: _parseDateTime(map['updatedAt']),
    );
  }

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return OrderModel.fromMap({
      'id': doc.id,
      ...data,
    });
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'buyerId': buyerId,
      'buyerName': buyerName,
      'buyerAddress': buyerAddress,
      'buyerPhone': buyerPhone,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'items': items.map((item) => item.toMap()).toList(),
      'totalAmount': totalAmount,
      'status': status,
      'paymentMethod': paymentMethod,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  OrderModel copyWith({
    String? id,
    String? buyerId,
    String? buyerName,
    String? buyerAddress,
    String? buyerPhone,
    String? sellerId,
    String? sellerName,
    List<OrderItemModel>? items,
    double? totalAmount,
    String? status,
    String? paymentMethod,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      buyerId: buyerId ?? this.buyerId,
      buyerName: buyerName ?? this.buyerName,
      buyerAddress: buyerAddress ?? this.buyerAddress,
      buyerPhone: buyerPhone ?? this.buyerPhone,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static List<OrderItemModel> _parseItems(dynamic value) {
    if (value is List) {
      return value
          .map((item) =>
              OrderItemModel.fromMap(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    } else if (value is DateTime) {
      return value;
    } else if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }

  @override
  String toString() {
    return 'OrderModel(id: $id, buyerName: $buyerName, status: $status, total: $totalAmount)';
  }
}
