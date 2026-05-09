import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habit_spark/models/habit.dart';
import 'package:habit_spark/services/notification_service.dart';
import 'package:habit_spark/services/streak_service.dart';
import 'package:habit_spark/services/habit_log_service.dart';
import 'package:habit_spark/services/error_handler.dart';

class HabitService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();
  final StreakService _streakService = StreakService();
  final HabitLogService _logService = HabitLogService();

  // Get habits stream for a user
  Stream<List<Habit>> getHabitsStream(String userId) {
    return _firestore
        .collection('habits')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final habits = snapshot.docs.map((doc) {
        return Habit.fromMap(doc.data(), doc.id);
      }).toList();
      
      // Sort by createdAt in memory instead of in query
      habits.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return habits;
    });
  }

  // Add a new habit
  Future<void> addHabit(
    String userId, 
    String habitName, {
    String? icon,
    String habitType = 'checkbox',
    double? targetValue,
    String? unit,
    String routine = 'General',
    String category = 'General',
  }) async {
    try {
      if (habitName.trim().isEmpty) {
        throw AppException(message: 'Habit name cannot be empty.');
      }
      
      await _firestore.collection('habits').add({
        'name': habitName,
        'isDone': false,
        'createdAt': Timestamp.fromDate(DateTime.now()),
        'userId': userId,
        if (icon != null) 'icon': icon,
        'habitType': habitType,
        if (targetValue != null) 'targetValue': targetValue,
        if (unit != null) 'unit': unit,
        'routine': routine,
        'category': category,
      });
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  // Update an existing habit
  Future<void> updateHabit(
    String habitId, 
    String habitName, {
    String? icon,
    String? habitType,
    double? targetValue,
    String? unit,
    String? routine,
  }) async {
    try {
      if (habitName.trim().isEmpty) {
        throw AppException(message: 'Habit name cannot be empty.');
      }
      
      final Map<String, dynamic> updateData = {
        'name': habitName,
      };
      if (icon != null) {
        updateData['icon'] = icon;
      }
      if (habitType != null) {
        updateData['habitType'] = habitType;
      }
      if (targetValue != null) {
        updateData['targetValue'] = targetValue;
      }
      if (unit != null) {
        updateData['unit'] = unit;
      }
      if (routine != null) {
        updateData['routine'] = routine;
      }
      await _firestore.collection('habits').doc(habitId).update(updateData);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  // Toggle habit completion
  Future<void> toggleHabit(
    String habitId, 
    bool currentStatus, 
    String userId, {
    double? distance,
    int? durationSeconds,
    double? weight,
    double? value,
    String? notes,
  }) async {
    await _firestore.collection('habits').doc(habitId).update({
      'isDone': !currentStatus,
    });
    
    // Log the habit completion/incompletion
    await _logService.addHabitLog(
      habitId: habitId,
      userId: userId,
      isCompleted: !currentStatus,
      distance: distance,
      durationSeconds: durationSeconds,
      weight: weight,
      value: value,
      notes: notes,
    );
    
    // If habit is being marked as done, log to health service and check for achievements
    if (!currentStatus) {
      // Log to health service for Daily Activity tracking
      await _logHealthData(userId, habitId, distance, durationSeconds, weight, value);
      await _checkHabitCompletion(userId, habitId);
    }
  }
  
  // Log health data when habit is completed
  Future<void> _logHealthData(
    String userId,
    String habitId,
    double? distance,
    int? durationSeconds,
    double? weight,
    double? value,
  ) async {
    try {
      // Get habit details to determine what to log
      final habitDoc = await _firestore.collection('habits').doc(habitId).get();
      final habitData = habitDoc.data();
      
      if (habitData == null) return;
      
      final habitName = (habitData['name'] ?? '').toString().toLowerCase();
      
      // Log completed task/habit
      await _firestore.collection('health_logs').add({
        'userId': userId,
        'type': 'completed tasks',
        'value': 1,
        'unit': 'task',
        'timestamp': Timestamp.fromDate(DateTime.now()),
        'metadata': {
          'habitId': habitId,
          'habitName': habitName,
        },
      });
      
      // Log distance if provided
      if (distance != null && distance > 0) {
        await _firestore.collection('health_logs').add({
          'userId': userId,
          'type': 'distance run',
          'value': distance,
          'unit': 'km',
          'timestamp': Timestamp.fromDate(DateTime.now()),
          'metadata': {
            'habitId': habitId,
            'habitName': habitName,
          },
        });
      }
      
      // Log workout/duration if provided
      if (durationSeconds != null && durationSeconds > 0) {
        await _firestore.collection('health_logs').add({
          'userId': userId,
          'type': 'workouts',
          'value': 1,
          'unit': 'session',
          'timestamp': Timestamp.fromDate(DateTime.now()),
          'metadata': {
            'habitId': habitId,
            'habitName': habitName,
            'durationSeconds': durationSeconds,
          },
        });
      }
      
      // Log calories if provided
      if (value != null && value > 0 && habitName.contains('calor')) {
        await _firestore.collection('health_logs').add({
          'userId': userId,
          'type': 'calories burned',
          'value': value,
          'unit': 'kcal',
          'timestamp': Timestamp.fromDate(DateTime.now()),
          'metadata': {
            'habitId': habitId,
            'habitName': habitName,
          },
        });
      }
    } catch (e) {
      print('Error logging health data: $e');
    }
  }
  
  // Check habit completion and trigger notifications
  Future<void> _checkHabitCompletion(String userId, String habitId) async {
    // Get the habit that was just completed
    final habitDoc = await _firestore.collection('habits').doc(habitId).get();
    final habitName = habitDoc.data()?['name'] ?? 'habit';
    
    // Send achievement notification for completing a habit
    await _notificationService.createAchievementNotification(
      userId,
      'You completed "$habitName"! Great job! 🎉',
    );
    
    // Check if all habits are completed
    final allHabits = await _firestore
        .collection('habits')
        .where('userId', isEqualTo: userId)
        .get();
    
    final allCompleted = allHabits.docs.every((doc) => doc.data()['isDone'] == true);
    
    // If all habits completed, send goal completion notification and update streak
    if (allCompleted && allHabits.docs.isNotEmpty) {
      await _notificationService.createNotification(
        userId: userId,
        title: '🎯 Goal Completed!',
        message: 'Amazing! You\'ve completed all your habits for today!',
        type: 'achievement',
      );
      
      // Update streak
      await _streakService.updateStreak(userId, true);
    }
  }

  // Delete a habit
  Future<void> deleteHabit(String habitId) async {
    try {
      await _firestore.collection('habits').doc(habitId).delete();
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
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

  /// Checks if the day has changed since the last reset, and resets all habits if so.
  /// Should be called on app open / tab entry. Safe to call multiple times.
  Future<void> checkAndResetDailyHabits(String userId) async {
    final today = DateTime.now();
    final todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    final resetRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('meta')
        .doc('daily_reset');

    final doc = await resetRef.get();

    if (!doc.exists || doc.data()?['lastResetDate'] != todayStr) {
      // New day — reset all habits and record today's date
      await resetDailyHabits(userId);
      await resetRef.set({'lastResetDate': todayStr});
    }
  }

  // Seed default running habits for new users
  Future<void> seedDefaultHabits(String userId) async {
    final existingHabits = await _firestore
        .collection('habits')
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();

    // Only seed if user has no habits
    if (existingHabits.docs.isEmpty) {
      final defaultHabits = [
        'Easy Run',
        'Tempo',
        'Intervals',
        'Hills',
        'Long Run',
        'Race',
        'parkrun',
      ];

      for (var habitName in defaultHabits) {
        await addHabit(userId, habitName);
      }
    }
  }
}
