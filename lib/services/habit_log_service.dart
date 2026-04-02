import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habit_spark/models/habit_log.dart';

class HabitLogService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get habit logs stream for a specific habit
  Stream<List<HabitLog>> getHabitLogsStream(String habitId) {
    return _firestore
        .collection('habit_logs')
        .where('habitId', isEqualTo: habitId)
        .snapshots()
        .map((snapshot) {
      final logs = snapshot.docs.map((doc) {
        return HabitLog.fromMap(doc.data(), doc.id);
      }).toList();
      
      // Sort in memory instead of in query
      logs.sort((a, b) => b.completedAt.compareTo(a.completedAt));
      return logs;
    });
  }

  // Add a habit log entry
  Future<void> addHabitLog({
    required String habitId,
    required String userId,
    required bool isCompleted,
    double? distance,
    int? durationSeconds,
    String? notes,
  }) async {
    await _firestore.collection('habit_logs').add({
      'habitId': habitId,
      'userId': userId,
      'completedAt': Timestamp.fromDate(DateTime.now()),
      'isCompleted': isCompleted,
      if (distance != null) 'distance': distance,
      if (durationSeconds != null) 'durationSeconds': durationSeconds,
      if (notes != null) 'notes': notes,
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
