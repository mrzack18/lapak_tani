import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lapak_tani/models/notification_model.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream of notifications.
  // We sort locally to avoid Firestore composite index requirements.
  Stream<List<NotificationModel>> getUserNotifications(String userId, String role) {
    final targetId = role == 'admin' ? 'admin' : userId;
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: targetId)
        .snapshots()
        .map((snapshot) {
      final docs = snapshot.docs
          .map((doc) => NotificationModel.fromFirestore(doc))
          .toList();
      docs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return docs;
    });
  }

  // Send a new notification
  Future<void> sendNotification({
    required String userId,
    required String title,
    required String message,
    required String type,
    String? relatedId,
  }) async {
    final docRef = _firestore.collection('notifications').doc();
    final notif = NotificationModel(
      id: docRef.id,
      userId: userId,
      title: title,
      message: message,
      type: type,
      createdAt: DateTime.now(),
      relatedId: relatedId,
    );
    await docRef.set(notif.toMap());
  }

  // Mark notification as read
  Future<void> markAsRead(String id) async {
    await _firestore.collection('notifications').doc(id).update({'isRead': true});
  }

  // Mark all as read
  Future<void> markAllAsRead(String userId, String role) async {
    final targetId = role == 'admin' ? 'admin' : userId;
    final batch = _firestore.batch();
    final snapshot = await _firestore
        .collection('notifications')
        .where('userId', isEqualTo: targetId)
        .where('isRead', isEqualTo: false)
        .get();
        
    for (var doc in snapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    
    if (snapshot.docs.isNotEmpty) {
      await batch.commit();
    }
  }
}
