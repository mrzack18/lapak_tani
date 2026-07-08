import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoomModel {
  final String id;
  final String buyerId;
  final String sellerId;
  final String buyerName;
  final String sellerName;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCountBuyer;
  final int unreadCountSeller;

  ChatRoomModel({
    required this.id,
    required this.buyerId,
    required this.sellerId,
    required this.buyerName,
    required this.sellerName,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCountBuyer = 0,
    this.unreadCountSeller = 0,
  });

  factory ChatRoomModel.fromMap(Map<String, dynamic> map, String id) {
    return ChatRoomModel(
      id: id,
      buyerId: map['buyerId'] ?? '',
      sellerId: map['sellerId'] ?? '',
      buyerName: map['buyerName'] ?? '',
      sellerName: map['sellerName'] ?? '',
      lastMessage: map['lastMessage'] ?? '',
      lastMessageTime: _parseDateTime(map['lastMessageTime']),
      unreadCountBuyer: map['unreadCountBuyer'] ?? 0,
      unreadCountSeller: map['unreadCountSeller'] ?? 0,
    );
  }

  factory ChatRoomModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ChatRoomModel.fromMap(data, doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'buyerId': buyerId,
      'sellerId': sellerId,
      'buyerName': buyerName,
      'sellerName': sellerName,
      'lastMessage': lastMessage,
      'lastMessageTime': Timestamp.fromDate(lastMessageTime),
      'unreadCountBuyer': unreadCountBuyer,
      'unreadCountSeller': unreadCountSeller,
    };
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }
}
