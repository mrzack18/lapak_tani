import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lapak_tani/models/feedback_model.dart';

class FeedbackService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add new feedback
  Future<void> sendFeedback(FeedbackModel feedback) async {
    await _firestore.collection('feedbacks').add(feedback.toMap());
  }

  // Get all feedbacks stream for admin
  Stream<List<FeedbackModel>> getFeedbacksStream() {
    return _firestore
        .collection('feedbacks')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => FeedbackModel.fromFirestore(doc))
          .toList();
    });
  }

  // Mark feedback as read
  Future<void> markAsRead(String id) async {
    await _firestore.collection('feedbacks').doc(id).update({
      'isRead': true,
    });
  }
}
