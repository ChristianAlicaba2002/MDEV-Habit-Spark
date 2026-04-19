import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:habit_spark/services/notification_service.dart';

class FCMService {
  static final FCMService _instance = FCMService._internal();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final NotificationService _notificationService = NotificationService();

  factory FCMService() {
    return _instance;
  }

  FCMService._internal();

  // Initialize FCM
  Future<void> initialize() async {
    try {
      // Request notification permissions
      await _requestNotificationPermissions();

      // Get FCM token
      final token = await _firebaseMessaging.getToken();
      if (token != null) {
        print('FCM Token: $token');
        // Store token in Firestore (backend will use this to send notifications)
        // This is handled by the auth service when user logs in
      }

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle background message tap
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

      // Handle terminated state message tap
      final initialMessage = await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        _handleMessageOpenedApp(initialMessage);
      }

      print('FCM initialized successfully');
    } catch (e) {
      print('Error initializing FCM: $e');
    }
  }

  // Request notification permissions
  Future<void> _requestNotificationPermissions() async {
    try {
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        provisional: false,
        criticalAlert: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('User granted notification permission');
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        print('User granted provisional notification permission');
      } else {
        print('User denied notification permission');
      }
    } catch (e) {
      print('Error requesting notification permissions: $e');
    }
  }

  // Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    print('Foreground message received:');
    print('Title: ${message.notification?.title}');
    print('Body: ${message.notification?.body}');

    // Show notification in app
    if (message.notification != null) {
      _showNotificationDialog(
        title: message.notification!.title ?? 'Notification',
        body: message.notification!.body ?? '',
      );
    }
  }

  // Handle message opened from background/terminated state
  void _handleMessageOpenedApp(RemoteMessage message) {
    print('Message opened from background/terminated:');
    print('Title: ${message.notification?.title}');
    print('Body: ${message.notification?.body}');

    // Handle notification tap - navigate to notifications page
    // This can be extended to handle different notification types
  }

  // Show notification dialog in app
  void _showNotificationDialog({
    required String title,
    required String body,
  }) {
    // This will be called from the main app context
    // For now, we'll just print it
    print('Showing notification: $title - $body');
  }

  // Get current FCM token
  Future<String?> getToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      print('Error getting FCM token: $e');
      return null;
    }
  }

  // Listen to token refresh
  void listenToTokenRefresh(Function(String) onTokenRefresh) {
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      print('FCM Token refreshed: $newToken');
      onTokenRefresh(newToken);
    });
  }

  // Subscribe to topic (for group notifications)
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      print('Subscribed to topic: $topic');
    } catch (e) {
      print('Error subscribing to topic: $e');
    }
  }

  // Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      print('Unsubscribed from topic: $topic');
    } catch (e) {
      print('Error unsubscribing from topic: $e');
    }
  }
}

// Background message handler (must be a top-level function)
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message: ${message.messageId}');
  print('Title: ${message.notification?.title}');
  print('Body: ${message.notification?.body}');
}
