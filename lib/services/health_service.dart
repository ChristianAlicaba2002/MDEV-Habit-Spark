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

  // READ: Get category for an activity type
  Future<String> getActivityCategory(String type) async {
    final snapshot = await _db
        .collection('health_logs')
        .where('userId', isEqualTo: _userId)
        .where('type', isEqualTo: type.toLowerCase())
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final data = snapshot.docs.first.data();
      if (data['metadata'] != null && data['metadata'] is Map) {
        return data['metadata']['category'] ?? '';
      }
    }
    return '';
  }

  // READ: Get category stream for an activity type
  Stream<String> getActivityCategoryStream(String type) {
    return _db
        .collection('health_logs')
        .where('userId', isEqualTo: _userId)
        .where('type', isEqualTo: type.toLowerCase())
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        if (data['metadata'] != null && data['metadata'] is Map) {
          return data['metadata']['category'] ?? '';
        }
      }
      return '';
    });
  }
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
        final tsData = data['timestamp'];
        final timestamp = tsData is Timestamp ? tsData.toDate() : (tsData is DateTime ? tsData : DateTime.now());
        if (timestamp.isAfter(start.subtract(const Duration(seconds: 1))) && 
            timestamp.isBefore(end)) {
          total += (data['value'] ?? 0).toDouble();
        }
      }
      return total;
    });
  }

  // READ: Monthly total + real stored unit for dashboard cards
  Stream<Map<String, dynamic>> getActivityMonthlyStats(String type) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 1);

    return _db
        .collection('health_logs')
        .where('userId', isEqualTo: _userId)
        .where('type', isEqualTo: type.toLowerCase())
        .snapshots()
        .map((snapshot) {
      double total = 0;
      String unit = '';
      String category = '';
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final tsData = data['timestamp'];
        final timestamp = tsData is Timestamp ? tsData.toDate() : (tsData is DateTime ? tsData : DateTime.now());
        if (timestamp.isAfter(start.subtract(const Duration(seconds: 1))) &&
            timestamp.isBefore(end)) {
          total += (data['value'] ?? 0).toDouble();
          if (unit.isEmpty) unit = (data['unit'] ?? '').toString();
          // Get category from metadata on first matching log
          if (category.isEmpty && data['metadata'] != null && data['metadata'] is Map) {
            category = data['metadata']['category'] ?? '';
          }
        }
      }
      return {'total': total, 'unit': unit, 'category': category};
    });
  }

  // READ: Per-day session counts for the current week (Mon=0 … Sun=6), normalized 0–1
  Stream<Map<int, double>> getWeeklyActivitySummary() {
    final now = DateTime.now();
    // Monday of current week
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final weekStart = DateTime(monday.year, monday.month, monday.day);
    final weekEnd = weekStart.add(const Duration(days: 7));

    return _db
        .collection('health_logs')
        .where('userId', isEqualTo: _userId)
        .snapshots()
        .map((snapshot) {
      final Map<int, double> counts = {0: 0, 1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0};
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final tsData = data['timestamp'];
        final timestamp = tsData is Timestamp ? tsData.toDate() : (tsData is DateTime ? tsData : DateTime.now());
        if (timestamp.isAfter(weekStart.subtract(const Duration(seconds: 1))) &&
            timestamp.isBefore(weekEnd)) {
          final dayIndex = timestamp.weekday - 1; // 0=Mon, 6=Sun
          counts[dayIndex] = (counts[dayIndex] ?? 0) + 1.0;
        }
      }
      // Normalize to 0-1 based on the busiest day
      final maxVal = counts.values.fold(0.0, (a, b) => a > b ? a : b);
      if (maxVal == 0) return counts;
      return counts.map((k, v) => MapEntry(k, v / maxVal));
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

  // READ: Get all unique activity types ever logged by this user
  Stream<List<Map<String, String>>> getAllActivityTypes() {
    return _db
        .collection('health_logs')
        .where('userId', isEqualTo: _userId)
        .snapshots()
        .map((snapshot) {
      final seen = <String>{};
      final result = <Map<String, String>>[];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final type = (data['type'] ?? '').toString().toLowerCase();
        final unit = (data['unit'] ?? '').toString();
        if (type.isNotEmpty && !seen.contains(type)) {
          seen.add(type);
          result.add({'type': type, 'unit': unit});
        }
      }
      return result;
    });
  }

  // READ: Get per-day totals for a given type and month (Map<dayOfMonth, total>)
  Stream<Map<int, double>> getMonthlyDailyTotals(String type, int year, int month) {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 1);

    return _db
        .collection('health_logs')
        .where('userId', isEqualTo: _userId)
        .where('type', isEqualTo: type.toLowerCase())
        .snapshots()
        .map((snapshot) {
      final Map<int, double> dailyTotals = {};
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final timestamp = (data['timestamp'] as Timestamp).toDate();
        if (timestamp.isAfter(start.subtract(const Duration(seconds: 1))) &&
            timestamp.isBefore(end)) {
          final day = timestamp.day;
          dailyTotals[day] = (dailyTotals[day] ?? 0) + (data['value'] ?? 0).toDouble();
        }
      }
      return dailyTotals;
    });
  }

  // READ: Check if a specific type is pinned
  Stream<bool> isActivityPinned(String type) {
    return _db
        .collection('pinned_activities')
        .doc('${_userId}_${type.toLowerCase()}')
        .snapshots()
        .map((snapshot) => snapshot.exists);
  }

  // READ: Get recent activity logs
  Stream<List<HealthLog>> getRecentLogsStream({int limit = 3}) {
    return _db
        .collection('health_logs')
        .where('userId', isEqualTo: _userId)
        .snapshots()
        .map((snapshot) {
      final logs = snapshot.docs.map((doc) => HealthLog.fromFirestore(doc)).toList();
      // Sort locally to avoid index requirement
      logs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return logs.take(limit).toList();
    });
  }

  // GOAL COMPLETION: Toggle a "done" status for an activity today
  Future<void> toggleGoalDone(String type, bool isDone) async {
    if (_userId.isEmpty) return;
    final now = DateTime.now();
    final dateId = "${now.year}-${now.month}-${now.day}";
    final docId = "${_userId}_${type.toLowerCase()}_$dateId";
    final goalLogId = "goal_log_$docId";

    if (isDone) {
      // 1. Mark as done for visual tracking
      await _db.collection('goal_completions').doc(docId).set({
        'userId': _userId,
        'type': type.toLowerCase(),
        'date': dateId,
        'timestamp': now, // Use local now for immediate stream updates
      });

      // 2. Add to health_logs with a fixed ID to avoid duplicates
      await _db.collection('health_logs').doc(goalLogId).set({
        'userId': _userId,
        'type': type.toLowerCase(),
        'value': 1.0,
        'unit': 'goal reached',
        'timestamp': now, // Use local now for immediate stream updates
        'metadata': {
          'isGoalCompletion': true,
          'activityName': type,
        },
      });
    } else {
      // UNDO: Delete both completion status and the activity log
      await _db.collection('goal_completions').doc(docId).delete();
      await _db.collection('health_logs').doc(goalLogId).delete();
    }
  }

  // GOAL COMPLETION: Check if activity is "done" today
  Stream<bool> getGoalDoneStream(String type) {
    if (_userId.isEmpty) return Stream.value(false);
    final now = DateTime.now();
    final dateId = "${now.year}-${now.month}-${now.day}";
    final docId = "${_userId}_${type.toLowerCase()}_$dateId";

    return _db.collection('goal_completions').doc(docId).snapshots().map((doc) => doc.exists);
  }
}
