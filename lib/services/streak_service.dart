import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habit_spark/services/notification_service.dart';

class StreakService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();

  // Get or create user streak data
  Future<Map<String, dynamic>> getUserStreak(String userId) async {
    final doc = await _firestore.collection('streaks').doc(userId).get();
    
    if (!doc.exists) {
      // Create initial streak data
      final initialData = {
        'userId': userId,
        'currentStreak': 0,
        'longestStreak': 0,
        'lastCompletionDate': null,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };
      await _firestore.collection('streaks').doc(userId).set(initialData);
      return initialData;
    }
    
    return doc.data()!;
  }

  // Get streak stream for real-time updates
  Stream<Map<String, dynamic>> getStreakStream(String userId) {
    return _firestore
        .collection('streaks')
        .doc(userId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) {
        return {
          'currentStreak': 0,
          'longestStreak': 0,
          'lastCompletionDate': null,
        };
      }
      return snapshot.data()!;
    });
  }

  // Update streak when user completes habits
  Future<void> updateStreak(String userId, bool allHabitsCompleted) async {
    final streakData = await getUserStreak(userId);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    Timestamp? lastCompletion = streakData['lastCompletionDate'];
    DateTime? lastDate = lastCompletion?.toDate();
    DateTime? lastDateOnly = lastDate != null 
        ? DateTime(lastDate.year, lastDate.month, lastDate.day)
        : null;
    
    int currentStreak = streakData['currentStreak'] ?? 0;
    int longestStreak = streakData['longestStreak'] ?? 0;
    
    if (allHabitsCompleted) {
      // Check if this is a new day
      if (lastDateOnly == null || lastDateOnly.isBefore(today)) {
        // Check if streak continues (yesterday) or breaks
        if (lastDateOnly != null && 
            today.difference(lastDateOnly).inDays == 1) {
          // Continue streak
          currentStreak++;
        } else if (lastDateOnly == null || 
                   today.difference(lastDateOnly).inDays > 1) {
          // Start new streak
          currentStreak = 1;
        }
        
        // Update longest streak
        if (currentStreak > longestStreak) {
          longestStreak = currentStreak;
        }
        
        // Check for streak milestones and send notifications
        await _checkStreakMilestones(userId, currentStreak);
        
        // Update Firestore
        await _firestore.collection('streaks').doc(userId).set({
          'userId': userId,
          'currentStreak': currentStreak,
          'longestStreak': longestStreak,
          'lastCompletionDate': Timestamp.fromDate(now),
          'updatedAt': Timestamp.fromDate(now),
        });
      }
    }
  }

  // Check for streak milestones and trigger notifications
  Future<void> _checkStreakMilestones(String userId, int streakDays) async {
    // Milestone days: 7, 30, 100
    if (streakDays == 7 || streakDays == 30 || streakDays == 100) {
      await _notificationService.createStreakNotification(userId, streakDays);
    }
  }

  // Check and update streak on login
  Future<void> checkStreakOnLogin(String userId) async {
    final streakData = await getUserStreak(userId);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    Timestamp? lastCompletion = streakData['lastCompletionDate'];
    DateTime? lastDate = lastCompletion?.toDate();
    DateTime? lastDateOnly = lastDate != null 
        ? DateTime(lastDate.year, lastDate.month, lastDate.day)
        : null;
    
    int currentStreak = streakData['currentStreak'] ?? 0;
    
    // If last completion was more than 1 day ago, reset streak
    if (lastDateOnly != null && 
        today.difference(lastDateOnly).inDays > 1 && 
        currentStreak > 0) {
      await _firestore.collection('streaks').doc(userId).update({
        'currentStreak': 0,
        'updatedAt': Timestamp.fromDate(now),
      });
    }
  }
}
