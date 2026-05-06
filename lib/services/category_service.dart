import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habit_spark/models/category_model.dart';

class CategoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'categories';

  /// Get stream of all categories for a user
  Stream<List<CategoryModel>> getCategoriesStream(String userId) {
    if (userId.isEmpty) return Stream.value([]);
    
    return _firestore
        .collection(_collectionName)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final items = snapshot.docs.map((doc) {
        return CategoryModel.fromMap(doc.data(), doc.id);
      }).toList();
      
      // Sort by position
      items.sort((a, b) => a.position.compareTo(b.position));
      return items;
    }).handleError((error) {
      print('Error fetching categories: $error');
      return [];
    });
  }

  /// Add a new category
  Future<void> addCategory(String userId, String name, String iconCode, int colorValue) async {
    if (userId.isEmpty || name.isEmpty) {
      throw Exception('User ID and category name are required');
    }

    try {
      // Get current count to set position
      final snapshot = await _firestore
          .collection(_collectionName)
          .where('userId', isEqualTo: userId)
          .get();
      final position = snapshot.docs.length;

      await _firestore.collection(_collectionName).add({
        'name': name,
        'iconCode': iconCode,
        'colorValue': colorValue,
        'userId': userId,
        'position': position,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error adding category: $e');
      rethrow;
    }
  }

  /// Update an existing category
  Future<void> updateCategory(String categoryId, String name, String iconCode, int colorValue) async {
    if (categoryId.isEmpty) {
      throw Exception('Category ID is required');
    }

    try {
      await _firestore.collection(_collectionName).doc(categoryId).update({
        'name': name,
        'iconCode': iconCode,
        'colorValue': colorValue,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating category: $e');
      rethrow;
    }
  }

  /// Reorder categories
  Future<void> reorderCategories(List<CategoryModel> categories) async {
    final batch = _firestore.batch();
    for (int i = 0; i < categories.length; i++) {
      final docRef = _firestore.collection(_collectionName).doc(categories[i].id);
      batch.update(docRef, {'position': i});
    }
    await batch.commit();
  }

  /// Delete a category
  Future<void> deleteCategory(String categoryId) async {
    if (categoryId.isEmpty) {
      throw Exception('Category ID is required');
    }

    try {
      await _firestore.collection(_collectionName).doc(categoryId).delete();
    } catch (e) {
      print('Error deleting category: $e');
      rethrow;
    }
  }

  /// Check if category name already exists for user
  Future<bool> categoryExists(String userId, String name) async {
    if (userId.isEmpty || name.isEmpty) return false;

    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .where('userId', isEqualTo: userId)
          .where('name', isEqualTo: name)
          .limit(1)
          .get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking category existence: $e');
      return false;
    }
  }

  /// Preseed default categories if none exist
  Future<void> seedDefaultCategories(String userId) async {
    if (userId.isEmpty) return;

    try {
      final existing = await _firestore
          .collection(_collectionName)
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
          await addCategory(
            userId,
            cat['name'] as String,
            cat['icon'] as String,
            cat['color'] as int,
          );
        }
      }
    } catch (e) {
      print('Error seeding default categories: $e');
    }
  }
}
