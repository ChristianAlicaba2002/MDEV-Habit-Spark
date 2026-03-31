import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habit_spark/models/habit_log.dart';

class HabitLogService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get habit logs stream for a specific habit
  Stream<List<HabitLog>> getHabitLogsStream(String habitId) {
    return _firestore
        .collection('habit_logs')
        .where('habitId', isEqualTo: habitId)
        .orderBy('completedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return HabitLog.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  // Add a habit log entry
  Future<void> addHabitLog({
    required String habitId,
    required String userId,
    required bool isCompleted,
  }) async {
    await _firestore.collection('habit_logs').add({
      'habitId': habitId,
      'userId': userId,
      'completedAt': Timestamp.fromDate(DateTime.now()),
      'isCompleted': isCompleted,
    });
  }

  // Get completion count for a habit
  Future<int> getCompletionCount(String habitId) async {
    final logs = await _firestore
        .collection('habit_logs')
        .where('habitId', isEqualTo: habitId)
        .where('isCompleted', isEqualTo: true)
        .get();
    return logs.docs.length;
  }

  // Get completion rate for last 30 days
  Future<double> getCompletionRate(String habitId) async {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    
    final logs = await _firestore
        .collection('habit_logs')
        .where('habitId', isEqualTo: habitId)
        .where('completedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(thirtyDaysAgo))
        .get();
    
    if (logs.docs.isEmpty) return 0.0;
    
    final completedCount = logs.docs.where((doc) => doc.data()['isCompleted'] == true).length;
    return (completedCount / 30) * 100;
  }
}
