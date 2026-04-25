import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:cloud_firestore/cloud_firestore.dart';

class ReminderService {
  static final ReminderService _instance = ReminderService._internal();
  late FlutterLocalNotificationsPlugin _notificationsPlugin;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  factory ReminderService() {
    return _instance;
  }

  ReminderService._internal() {
    _initializeNotifications();
  }

  void _initializeNotifications() {
    tzdata.initializeTimeZones();
    _notificationsPlugin = FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    _notificationsPlugin.initialize(initSettings);
  }

  /// Schedule a daily reminder for a habit
  Future<void> scheduleHabitReminder({
    required String habitId,
    required String habitName,
    required String userId,
    required TimeOfDay time,
  }) async {
    try {
      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );

      // If the time has already passed today, schedule for tomorrow
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      await _notificationsPlugin.zonedSchedule(
        habitId.hashCode,
        '⏰ Habit Reminder',
        'Don\'t forget to complete "$habitName" today!',
        scheduledDate,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'habit_reminders',
            'Habit Reminders',
            channelDescription: 'Reminders for your daily habits',
            importance: Importance.high,
            priority: Priority.high,
            enableVibration: true,
            playSound: true,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAndAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      // Save reminder to Firestore
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('reminders')
          .doc(habitId)
          .set({
        'habitId': habitId,
        'habitName': habitName,
        'time': '${time.hour}:${time.minute.toString().padLeft(2, '0')}',
        'enabled': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error scheduling reminder: $e');
    }
  }

  /// Cancel a reminder for a habit
  Future<void> cancelHabitReminder({
    required String habitId,
    required String userId,
  }) async {
    try {
      await _notificationsPlugin.cancel(habitId.hashCode);

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('reminders')
          .doc(habitId)
          .delete();
    } catch (e) {
      print('Error canceling reminder: $e');
    }
  }

  /// Get all reminders for a user
  Stream<List<Map<String, dynamic>>> getUserReminders(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('reminders')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  /// Get a specific reminder
  Future<Map<String, dynamic>?> getReminder(
    String userId,
    String habitId,
  ) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('reminders')
          .doc(habitId)
          .get();

      return doc.data();
    } catch (e) {
      print('Error getting reminder: $e');
      return null;
    }
  }

  /// Update reminder time
  Future<void> updateReminderTime({
    required String habitId,
    required String habitName,
    required String userId,
    required TimeOfDay newTime,
  }) async {
    try {
      // Cancel old reminder
      await cancelHabitReminder(habitId: habitId, userId: userId);

      // Schedule new reminder
      await scheduleHabitReminder(
        habitId: habitId,
        habitName: habitName,
        userId: userId,
        time: newTime,
      );
    } catch (e) {
      print('Error updating reminder: $e');
    }
  }

  /// Enable/disable a reminder
  Future<void> toggleReminder({
    required String habitId,
    required String userId,
    required bool enabled,
  }) async {
    try {
      if (enabled) {
        // Get the reminder details
        final reminder = await getReminder(userId, habitId);
        if (reminder != null) {
          final timeParts = (reminder['time'] as String).split(':');
          final time = TimeOfDay(
            hour: int.parse(timeParts[0]),
            minute: int.parse(timeParts[1]),
          );

          await scheduleHabitReminder(
            habitId: habitId,
            habitName: reminder['habitName'],
            userId: userId,
            time: time,
          );
        }
      } else {
        await cancelHabitReminder(habitId: habitId, userId: userId);
      }
    } catch (e) {
      print('Error toggling reminder: $e');
    }
  }
}
