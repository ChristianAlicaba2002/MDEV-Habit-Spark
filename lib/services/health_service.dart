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

  // DELETE: Remove all logs of a specific type (Removes the activity from dashboard)
  Future<void> deleteActivityType(String type) async {
    if (_userId.isEmpty) return;
    final snapshot = await _db.collection('health_logs')
        .where('userId', isEqualTo: _userId)
        .where('type', isEqualTo: type.toLowerCase())
        .get();
    
    final batch = _db.batch();
    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  // UPDATE: Rename an activity across all logs
  Future<void> renameActivityType(String oldType, String newType) async {
    if (_userId.isEmpty) return;
    final snapshot = await _db.collection('health_logs')
        .where('userId', isEqualTo: _userId)
        .where('type', isEqualTo: oldType.toLowerCase())
        .get();
    
    final batch = _db.batch();
    for (var doc in snapshot.docs) {
      batch.update(doc.reference, {'type': newType.toLowerCase()});
    }
    await batch.commit();

    // Also update pinning if exists
    final pinDoc = await _db.collection('pinned_activities').doc('${_userId}_$oldType').get();
    if (pinDoc.exists) {
      await _db.collection('pinned_activities').doc('${_userId}_$newType').set({
        'userId': _userId,
        'type': newType.toLowerCase(),
        'pinnedAt': FieldValue.serverTimestamp(),
      });
      await _db.collection('pinned_activities').doc('${_userId}_$oldType').delete();
    }
  }

  // PINNING: Pin or unpin an activity to the dashboard
  Future<void> togglePinActivity(String type, bool isPinned) async {
    if (_userId.isEmpty) return;
    final docId = '${_userId}_${type.toLowerCase()}';
    
    if (isPinned) {
      await _db.collection('pinned_activities').doc(docId).set({
        'userId': _userId,
        'type': type.toLowerCase(),
        'pinnedAt': FieldValue.serverTimestamp(),
      });
    } else {
      await _db.collection('pinned_activities').doc(docId).delete();
    }
  }

  // READ: Get stream of pinned activity types
  Stream<List<String>> getPinnedActivitiesStream(String userId) {
    return _db
        .collection('pinned_activities')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()['type'] as String).toList());
  }

  // READ: Check if a specific type is pinned
  Stream<bool> isActivityPinned(String type) {
    return _db
        .collection('pinned_activities')
        .doc('${_userId}_${type.toLowerCase()}')
        .snapshots()
        .map((snapshot) => snapshot.exists);
  }
}
