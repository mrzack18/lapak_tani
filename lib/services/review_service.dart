import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lapak_tani/models/review_model.dart';

class ReviewService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Add review and update product rating
  Future<void> addReview(ReviewModel review) async {
    try {
      // 1. Add review to 'reviews' collection
      String docId = review.id;
      if (docId.isEmpty) {
        docId = _firestore.collection('reviews').doc().id;
      }
      final reviewData = review.toMap();
      reviewData['id'] = docId;
      await _firestore.collection('reviews').doc(docId).set(reviewData);
      
      // 2. Fetch all reviews for this product
      final snapshot = await _firestore
          .collection('reviews')
          .where('productId', isEqualTo: review.productId)
          .get();
          
      int totalRating = 0;
      int reviewCount = snapshot.docs.length;
      
      for (var doc in snapshot.docs) {
        totalRating += (doc.data()['rating'] as num).toInt();
      }
      
      // 3. Calculate new average rating
      double newRating = reviewCount > 0 ? totalRating / reviewCount : 0.0;
      
      // 4. Update product's rating and reviewCount fields
      await _firestore.collection('products').doc(review.productId).update({
        'rating': newRating,
        'reviewCount': reviewCount,
      });
    } catch (e) {
      throw Exception('Gagal menambahkan ulasan: $e');
    }
  }
  
  // Get reviews by product
  Future<List<ReviewModel>> getReviewsByProduct(String productId) async {
    try {
      final snapshot = await _firestore
          .collection('reviews')
          .where('productId', isEqualTo: productId)
          .get();
          
      final docs = snapshot.docs.map((doc) => ReviewModel.fromFirestore(doc)).toList();
      docs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return docs;
    } catch (e) {
      throw Exception('Gagal mengambil ulasan produk: $e');
    }
  }
  
  // Check if user already reviewed a product for an order
  Future<bool> hasUserReviewed(String userId, String orderId, String productId) async {
    try {
      final snapshot = await _firestore
          .collection('reviews')
          .where('userId', isEqualTo: userId)
          .where('orderId', isEqualTo: orderId)
          .where('productId', isEqualTo: productId)
          .limit(1)
          .get();
          
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      return false; // Safely return false if error
    }
  }
}
