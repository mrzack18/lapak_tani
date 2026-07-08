import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lapak_tani/models/chat_room_model.dart';
import 'package:lapak_tani/models/chat_message_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream of chat rooms for a specific user.
  // We sort locally to avoid requiring complex Firestore composite indexes.
  Stream<List<ChatRoomModel>> getUserChatRooms(String userId, String role) {
    final field = role == 'petani' ? 'sellerId' : 'buyerId';
    return _firestore
        .collection('chat_rooms')
        .where(field, isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final docs = snapshot.docs
          .map((doc) => ChatRoomModel.fromFirestore(doc))
          .toList();
      docs.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
      return docs;
    });
  }

  // Stream of messages for a specific chat room.
  Stream<List<ChatMessageModel>> getChatMessages(String roomId) {
    return _firestore
        .collection('chat_messages')
        .where('roomId', isEqualTo: roomId)
        .snapshots()
        .map((snapshot) {
      final docs = snapshot.docs
          .map((doc) => ChatMessageModel.fromFirestore(doc))
          .toList();
      docs.sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Newest first
      return docs;
    });
  }

  // Get or Create a chat room
  Future<String> getOrCreateRoom(
    String buyerId,
    String sellerId,
    String buyerName,
    String sellerName,
  ) async {
    final query = await _firestore
        .collection('chat_rooms')
        .where('buyerId', isEqualTo: buyerId)
        .where('sellerId', isEqualTo: sellerId)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      return query.docs.first.id;
    }

    // Create new room
    final docRef = _firestore.collection('chat_rooms').doc();
    final newRoom = ChatRoomModel(
      id: docRef.id,
      buyerId: buyerId,
      sellerId: sellerId,
      buyerName: buyerName,
      sellerName: sellerName,
      lastMessage: 'Memulai obrolan baru...',
      lastMessageTime: DateTime.now(),
    );

    await docRef.set(newRoom.toMap());
    return docRef.id;
  }

  // Send a message
  Future<void> sendMessage(ChatMessageModel message, String senderRole) async {
    final docRef = _firestore.collection('chat_messages').doc();
    final newMsg = ChatMessageModel(
      id: docRef.id,
      roomId: message.roomId,
      senderId: message.senderId,
      text: message.text,
      productId: message.productId,
      productName: message.productName,
      productImageUrl: message.productImageUrl,
      createdAt: DateTime.now(),
    );

    final batch = _firestore.batch();

    // Add message
    batch.set(docRef, newMsg.toMap());

    // Update chat room lastMessage and unread count
    final roomRef = _firestore.collection('chat_rooms').doc(message.roomId);
    final unreadField = senderRole == 'pembeli' ? 'unreadCountSeller' : 'unreadCountBuyer';

    batch.update(roomRef, {
      'lastMessage': message.text.isEmpty && message.productId != null
          ? 'Mengirim produk'
          : message.text,
      'lastMessageTime': Timestamp.fromDate(newMsg.createdAt),
      unreadField: FieldValue.increment(1),
    });

    await batch.commit();
  }

  // Reset unread count when user opens the chat
  Future<void> resetUnreadCount(String roomId, String role) async {
    final unreadField = role == 'pembeli' ? 'unreadCountBuyer' : 'unreadCountSeller';
    await _firestore.collection('chat_rooms').doc(roomId).update({
      unreadField: 0,
    });
  }
}
