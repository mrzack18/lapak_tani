import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lapak_tani/models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetch a single user by their UID.
  /// Returns null if the document does not exist.
  Future<UserModel?> getUserById(String uid) async {
    try {
      final DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();

      if (!doc.exists) return null;

      return UserModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Gagal mengambil data user: $e');
    }
  }

  /// Update the user's profile in Firestore.
  /// Automatically sets `updatedAt` to now.
  Future<void> updateProfile(UserModel user) async {
    try {
      final updatedUser = user.copyWith(updatedAt: DateTime.now());
      await _firestore
          .collection('users')
          .doc(user.uid)
          .update(updatedUser.toMap());
    } catch (e) {
      throw Exception('Gagal memperbarui profil: $e');
    }
  }

  /// Get all users from Firestore (admin use).
  /// Ordered by creation date, newest first.
  Future<List<UserModel>> getAllUsers() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('users')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Gagal mengambil daftar user: $e');
    }
  }

  /// Delete a user document from Firestore (admin use).
  /// Note: this does NOT delete the Firebase Auth account.
  Future<void> deleteUser(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).delete();
    } catch (e) {
      throw Exception('Gagal menghapus user: $e');
    }
  }

  /// Get the total number of registered users.
  Future<int> getTotalUsersCount() async {
    try {
      final AggregateQuerySnapshot snapshot =
          await _firestore.collection('users').count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      throw Exception('Gagal menghitung jumlah user: $e');
    }
  }
}
