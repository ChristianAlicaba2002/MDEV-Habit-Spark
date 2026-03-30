import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habit_spark/models/notification_model.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get notifications stream for a user
  Stream<List<NotificationModel>> getNotificationsStream(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final notifications = snapshot.docs.map((doc) {
        return NotificationModel.fromMap(doc.data(), doc.id);
      }).toList();
      
      // Sort by createdAt in memory (newest first)
      notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return notifications;
    });
  }

  // Get unread notification count
  Stream<int> getUnreadCountStream(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Create a notification
  Future<void> createNotification({
    required String userId,
    required String title,
    required String message,
    required String type,
  }) async {
    await _firestore.collection('notifications').add({
      'userId': userId,
      'title': title,
      'message': message,
      'type': type,
      'isRead': false,
      'createdAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    await _firestore
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }

  // Mark all notifications as read
  Future<void> markAllAsRead(String userId) async {
    final batch = _firestore.batch();
    final notifications = await _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();

    for (var doc in notifications.docs) {
      batch.update(doc.reference, {'isRead': true});
    }

    await batch.commit();
  }

  // Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).delete();
  }

  // Delete all notifications for a user
  Future<void> deleteAllNotifications(String userId) async {
    final batch = _firestore.batch();
    final notifications = await _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .get();

    for (var doc in notifications.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  // Create achievement notification
  Future<void> createAchievementNotification(
    String userId,
    String achievement,
  ) async {
    await createNotification(
      userId: userId,
      title: '🎉 Achievement Unlocked!',
      message: achievement,
      type: 'achievement',
    );
  }

  // Create streak notification
  Future<void> createStreakNotification(
    String userId,
    int streakDays,
  ) async {
    await createNotification(
      userId: userId,
      title: '🔥 Streak Milestone!',
      message: 'You\'ve maintained a $streakDays-day streak! Keep it up!',
      type: 'streak',
    );
  }

  // Create reminder notification
  Future<void> createReminderNotification(
    String userId,
    String habitName,
  ) async {
    await createNotification(
      userId: userId,
      title: '⏰ Habit Reminder',
      message: 'Don\'t forget to complete "$habitName" today!',
      type: 'reminder',
    );
  }
}
