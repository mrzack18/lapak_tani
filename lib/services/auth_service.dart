import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lapak_tani/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Returns the currently signed-in Firebase user, or null.
  User? get currentUser => _auth.currentUser;

  /// Stream that emits whenever the auth state changes (sign-in / sign-out).
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Register a new user with email/password, then create a Firestore
  /// document in the 'users' collection.
  Future<UserModel> register({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String role,
  }) async {
    try {
      // 1. Create the Firebase Auth user
      final UserCredential credential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw Exception('Registrasi gagal: user tidak ditemukan.');
      }

      // 2. Build the UserModel
      final UserModel userModel = UserModel(
        uid: firebaseUser.uid,
        name: name,
        email: email,
        phone: phone,
        role: role,
      );

      // 3. Write to Firestore
      await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .set(userModel.toMap());

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapAuthErrorMessage(e.code));
    } catch (e) {
      throw Exception('Registrasi gagal: $e');
    }
  }

  /// Login with email and password, then fetch the full UserModel from
  /// the Firestore 'users' collection.
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      // 1. Sign in with Firebase Auth
      final UserCredential credential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw Exception('Login gagal: user tidak ditemukan.');
      }

      // 2. Fetch the UserModel from Firestore
      final UserModel? userModel = await getUserProfile(firebaseUser.uid);
      if (userModel == null) {
        throw Exception('Login gagal: profil user tidak ditemukan di database.');
      }

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapAuthErrorMessage(e.code));
    } catch (e) {
      throw Exception('Login gagal: $e');
    }
  }

  /// Fetch a user profile from Firestore by UID.
  /// Returns null if the document does not exist.
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      final DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();

      if (!doc.exists) return null;

      return UserModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Gagal mengambil profil user: $e');
    }
  }

  /// Sign out the currently authenticated user.
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Logout gagal: $e');
    }
  }

  /// Send a password-reset email to the given address.
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapAuthErrorMessage(e.code));
    } catch (e) {
      throw Exception('Reset password gagal: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Translate common Firebase Auth error codes into user-friendly messages.
  String _mapAuthErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Email sudah terdaftar. Silakan gunakan email lain.';
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'weak-password':
        return 'Password terlalu lemah. Gunakan minimal 6 karakter.';
      case 'user-not-found':
        return 'Email tidak terdaftar.';
      case 'wrong-password':
        return 'Password salah.';
      case 'user-disabled':
        return 'Akun ini telah dinonaktifkan.';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan. Coba lagi nanti.';
      case 'operation-not-allowed':
        return 'Operasi tidak diizinkan.';
      default:
        return 'Terjadi kesalahan autentikasi ($code).';
    }
  }
}
