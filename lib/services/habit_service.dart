import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habit_spark/models/habit.dart';

class HabitService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get habits stream for a user
  Stream<List<Habit>> getHabitsStream(String userId) {
    return _firestore
        .collection('habits')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Habit.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  // Add a new habit
  Future<void> addHabit(String userId, String habitName) async {
    await _firestore.collection('habits').add({
      'name': habitName,
      'isDone': false,
      'createdAt': FieldValue.serverTimestamp(),
      'userId': userId,
    });
  }

  // Toggle habit completion
  Future<void> toggleHabit(String habitId, bool currentStatus) async {
    await _firestore.collection('habits').doc(habitId).update({
      'isDone': !currentStatus,
    });
  }

  // Delete a habit
  Future<void> deleteHabit(String habitId) async {
    await _firestore.collection('habits').doc(habitId).delete();
  }

  // Reset all habits (for new day)
  Future<void> resetDailyHabits(String userId) async {
    final batch = _firestore.batch();
    final habits = await _firestore
        .collection('habits')
        .where('userId', isEqualTo: userId)
        .get();

    for (var doc in habits.docs) {
      batch.update(doc.reference, {'isDone': false});
    }

    await batch.commit();
  }
}
