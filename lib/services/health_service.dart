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
        .snapshots()
        .map((snapshot) {
      final allLogs = snapshot.docs.map((doc) => HealthLog.fromFirestore(doc)).toList();
      // Filter for the specific day locally
      return allLogs.where((log) {
        return log.timestamp.isAfter(start.subtract(const Duration(seconds: 1))) && 
               log.timestamp.isBefore(end);
      }).toList();
    });
  }

  // READ: Get aggregated totals for a period (e.g., today's steps)
  Stream<double> getTypeTotalForPeriod(String type, DateTime start, DateTime end) {
    return _db
        .collection('health_logs')
        .where('userId', isEqualTo: _userId)
        .where('type', isEqualTo: type.toLowerCase())
        .snapshots()
        .map((snapshot) {
      double total = 0;
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final timestamp = (data['timestamp'] as Timestamp).toDate();
        if (timestamp.isAfter(start.subtract(const Duration(seconds: 1))) && 
            timestamp.isBefore(end)) {
          total += (data['value'] ?? 0).toDouble();
        }
      }
      return total;
    });
  }

  // DELETE: Remove a log
  Future<void> deleteLog(String logId) async {
    await _db.collection('health_logs').doc(logId).delete();
  }
}
