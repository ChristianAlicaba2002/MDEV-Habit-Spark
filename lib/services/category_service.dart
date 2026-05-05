import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habit_spark/models/category_model.dart';

class CategoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<CategoryModel>> getCategoriesStream(String userId) {
    return _firestore
        .collection('categories')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return CategoryModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  Future<void> addCategory(String userId, String name, String iconCode, int colorValue) async {
    await _firestore.collection('categories').add({
      'name': name,
      'iconCode': iconCode,
      'colorValue': colorValue,
      'userId': userId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteCategory(String categoryId) async {
    await _firestore.collection('categories').doc(categoryId).delete();
  }

  // Preseed default categories if none exist
  Future<void> seedDefaultCategories(String userId) async {
    final existing = await _firestore
        .collection('categories')
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();

    if (existing.docs.isEmpty) {
      final defaults = [
        {'name': 'Fitness', 'icon': '58713', 'color': 0xFFFFC107}, // fitness_center
        {'name': 'Productivity', 'icon': '58933', 'color': 0xFF00B0FF}, // work
        {'name': 'Wellness', 'icon': '58374', 'color': 0xFF4CAF50}, // spa
        {'name': 'Mindfulness', 'icon': '62590', 'color': 0xFF7C4DFF}, // self_improvement
      ];

      for (var cat in defaults) {
        await addCategory(userId, cat['name'] as String, cat['icon'] as String, cat['color'] as int);
      }
    }
  }
}
