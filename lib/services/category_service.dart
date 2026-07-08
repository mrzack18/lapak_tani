import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lapak_tani/models/category_model.dart';

class CategoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get all categories from the 'categories' collection, ordered by name.
  Future<List<CategoryModel>> getAllCategories() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('categories')
          .orderBy('name')
          .get();

      return snapshot.docs
          .map((doc) => CategoryModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Gagal mengambil daftar kategori: $e');
    }
  }

  /// Add a new category to Firestore.
  /// If the category already has a non-empty ID it is used as the document ID;
  /// otherwise Firestore auto-generates one.
  Future<void> addCategory(CategoryModel category) async {
    try {
      if (category.id.isNotEmpty) {
        await _firestore
            .collection('categories')
            .doc(category.id)
            .set(category.toMap());
      } else {
        await _firestore.collection('categories').add(category.toMap());
      }
    } catch (e) {
      throw Exception('Gagal menambahkan kategori: $e');
    }
  }
}
