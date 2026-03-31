import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habit_spark/models/habit.dart';
import 'package:habit_spark/services/notification_service.dart';
import 'package:habit_spark/services/streak_service.dart';

class HabitService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();
  final StreakService _streakService = StreakService();

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
  Future<void> addHabit(String userId, String habitName) async {
    await _firestore.collection('habits').add({
      'name': habitName,
      'isDone': false,
      'createdAt': Timestamp.fromDate(DateTime.now()),
      'userId': userId,
    });
  }

  // Toggle habit completion
  Future<void> toggleHabit(String habitId, bool currentStatus, String userId) async {
    await _firestore.collection('habits').doc(habitId).update({
      'isDone': !currentStatus,
    });
    
    // If habit is being marked as done, check for achievements
    if (!currentStatus) {
      await _checkHabitCompletion(userId, habitId);
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
