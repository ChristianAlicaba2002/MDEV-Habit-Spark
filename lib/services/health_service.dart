import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/health_log_model.dart';

class HealthService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId => _auth.currentUser?.uid ?? '';

  // CREATE: Log new health/activity data
  Future<void> logActivity({
    required String type,
    required double value,
    required String unit,
    Map<String, dynamic>? metadata,
    DateTime? timestamp,
  }) async {
    if (_userId.isEmpty) return;

    await _db.collection('health_logs').add(
      HealthLog(
        userId: _userId,
        type: type.toLowerCase(),
        value: value,
        unit: unit,
        timestamp: timestamp ?? DateTime.now(),
        metadata: metadata,
      ).toMap(),
    );
  }

  // READ: Get logs for a specific day
  Stream<List<HealthLog>> getDailyLogs(DateTime date) {
    DateTime start = DateTime(date.year, date.month, date.day);
    DateTime end = start.add(const Duration(days: 1));

    return _db
        .collection('health_logs')
        .where('userId', isEqualTo: _userId)
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('timestamp', isLessThan: Timestamp.fromDate(end))
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => HealthLog.fromFirestore(doc)).toList());
  }

  // READ: Get aggregated totals for a period (e.g., today's steps)
  Stream<double> getTypeTotalForPeriod(String type, DateTime start, DateTime end) {
    return _db
        .collection('health_logs')
        .where('userId', isEqualTo: _userId)
        .where('type', isEqualTo: type.toLowerCase())
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('timestamp', isLessThan: Timestamp.fromDate(end))
        .snapshots()
        .map((snapshot) {
      double total = 0;
      for (var doc in snapshot.docs) {
        total += (doc.data()['value'] ?? 0).toDouble();
      }
      return total;
    });
  }

  // DELETE: Remove a log
  Future<void> deleteLog(String logId) async {
    await _db.collection('health_logs').doc(logId).delete();
  }
}
