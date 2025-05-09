/*
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class MergnNotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  // This method will initialize Firebase Messaging and Local Notifications
  Future<void> initialize() async {
    // Initialize Firebase Messaging
    await _firebaseMessaging.requestPermission();
    FirebaseMessaging.onMessage.listen(_onMessageReceived);
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Initialize Local Notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('ic_launcher');
    final InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Handler when a notification is received in the foreground
  Future<void> _onMessageReceived(RemoteMessage message) async {
    print("Message received: ${message.data['title']}, ${message.data['body']}");

    // Display notification
    await _showNotification(message);
  }

  // Handler when a notification is opened from the background
  Future<void> _onMessageOpenedApp(RemoteMessage message) async {
    print("Notification clicked: ${message.data['title']}");
    // Handle notification click (e.g., navigate to a specific screen)
  }

  // Background message handler
   static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    print("Background message received: ${message.data['title']}, ${message.data['body']}");

    await _showNotification(message);
  }

  // Show local notification
  static Future<void> _showNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'mergn', // channel id
      'mergn_channel', // channel name
      channelDescription: 'Mergn Channel',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.show(
      0,
      message.data['title'],
      message.data['body'],
      platformChannelSpecifics,
    );
  }
}
*/
