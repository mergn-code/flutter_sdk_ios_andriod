import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mergn_flutter_plugin/flutter_plugin_method_channel.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    if (Platform.isAndroid) {
      await Firebase.initializeApp(
        options: FirebaseOptions(
          apiKey: 'AIzaSyCkwUhjvskWK6o19jnSC3yd2Nkk-juSfTE',
          appId: '1:301998040977:android:be0d9b2a1fe27b376ddc30',
          messagingSenderId: '301998040977',
          projectId: 'flutter-android-and-ios',
          storageBucket: 'flutter-android-and-ios.firebasestorage.app',
        ),
      );
    } else if (Platform.isIOS) {
      await Firebase.initializeApp(
        options: FirebaseOptions(
          apiKey: 'AIzaSyAWVV1FmwcgX5FCLVpFJND7i0OqWhe-QiQ',
          appId: '1:301998040977:ios:dc7a5a86ef16e3336ddc30',
          messagingSenderId: '301998040977',
          projectId: 'flutter-android-and-ios',
          storageBucket: 'flutter-android-and-ios.firebasestorage.app',
        ),
      );
    }
    await initLocalNotification();
  } catch (e) {
    print("Failed to initialize Firebase: $e");
  }
  runApp(MyApp());
}

Future<void> initLocalNotification() async {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  var android = AndroidInitializationSettings('app_icon');
  var ios = DarwinInitializationSettings();
  var initSettings = InitializationSettings(android: android, iOS: ios);

  await flutterLocalNotificationsPlugin.initialize(initSettings);
}

void showNotification(RemoteMessage message) async {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  final String? imageUrl = message.data['image'];

  AndroidNotificationDetails androidDetails;

  if (imageUrl != null && imageUrl.isNotEmpty) {
    try {
      final http.Response response = await http.get(Uri.parse(imageUrl));
      final Directory tempDir = await getTemporaryDirectory();
      final String filePath = '${tempDir.path}/image.jpg';
      final File file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      final BigPictureStyleInformation bigPicture = BigPictureStyleInformation(
        FilePathAndroidBitmap(filePath),
        contentTitle: message.data['title'],
        summaryText: message.data['body'],
      );

      androidDetails = AndroidNotificationDetails(
        'image_channel',
        'Image Notifications',
        channelDescription: 'Notifications with images',
        importance: Importance.max,
        priority: Priority.high,
        styleInformation: bigPicture,
      );
    } catch (e) {
      print("Image load failed: $e");
      androidDetails = AndroidNotificationDetails(
        'default_channel',
        'Default Notifications',
        importance: Importance.max,
        priority: Priority.high,
      );
    }
  } else {
    androidDetails = AndroidNotificationDetails(
      'default_channel',
      'Default Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
  }

  const ios = DarwinNotificationDetails();
  final platform = NotificationDetails(android: androidDetails, iOS: ios);

  await flutterLocalNotificationsPlugin.show(
    0,
    message.data['title'],
    message.data['body'],
    platform,
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Event Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: EventManagerScreen(),
    );
  }
}

class EventManagerScreen extends StatefulWidget {
  @override
  _EventManagerScreenState createState() => _EventManagerScreenState();
}

class _EventManagerScreenState extends State<EventManagerScreen> {
  String? _token;

  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _dynamicAttributeController =
  TextEditingController();
  final TextEditingController _identityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    requestPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event Manager'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _registerApi,
              child: Text('Register API'),
            ),
            SizedBox(height: 10),
            Text('Event Name:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            TextField(
              controller: _eventNameController,
              decoration: InputDecoration(
                hintText: 'Enter Event Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            Text('Dynamic Attribute:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            TextField(
              controller: _dynamicAttributeController,
              decoration: InputDecoration(
                hintText: 'Enter Dynamic Attribute Value',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            Text('Identity:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            TextField(
              controller: _identityController,
              decoration: InputDecoration(
                hintText: 'Enter Identity',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _sendEvent,
              child: Text('Send Event'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _sendAttribute,
              child: Text('Send Attribute'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _sendIdentity,
              child: Text('Send Identity'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _registerApi() async {
    final clientApiKey = 'api key';
    try {
      await MethodChannelFlutterPlugin().registerAPICall(
          "4f3f1e5562611f5a612c644d778a4a6cm238rgn4b5d59d9d1350b77f880425a7fcd88d0");

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Received a message: ${message.data['title']}');
        showNotification(message);
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('Notification clicked: ${message.notification?.title}');
      });
    } on PlatformException catch (e) {
      print("Failed to register API: '${e.message}'.");
    } catch (e) {
      print("Unexpected error during API registration: $e");
    }
  }

  Future<void> _sendEvent() async {
    final eventName = "Request Send";
    final eventProperties = {"category": "test-flutter"};

    try {
      await MethodChannelFlutterPlugin().sendEvent(eventName, eventProperties);
      print("Event Sent: $eventName");
    } on PlatformException catch (e) {
      print("Failed to send event: '${e.message}'.");
    } catch (e) {
      print("Unexpected error while sending event: $e");
    }
  }

  Future<void> _sendAttribute() async {
    final value = _dynamicAttributeController.text;
    if (value.isNotEmpty) {
      try {
        await MethodChannelFlutterPlugin().sendAttribute("email", value);
        print("Attribute Sent: email = $value");
      } on PlatformException catch (e) {
        print("Failed to send attribute: '${e.message}'.");
      } catch (e) {
        print("Unexpected error while sending attribute: $e");
      }
    } else {
      print("Dynamic Attribute cannot be empty");
    }
  }

  Future<void> _sendIdentity() async {
    final identity = _identityController.text;
    getToken();

    if (identity.isNotEmpty) {
      try {
        await MethodChannelFlutterPlugin().login(identity);
      } on PlatformException catch (e) {
        print("Failed to send identity: '${e.message}'.");
      } catch (e) {
        print("Unexpected error while sending identity: $e");
      }
    } else {
      print("Identity cannot be empty");
    }
  }

  void getToken() async {
    try {
      String? fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        print("FCM Token: $fcmToken");
        await MethodChannelFlutterPlugin().firebaseToken(fcmToken);
      } else {
        print("Failed to get FCM token");
      }
    } catch (e) {
      print("Failed to get tokens: $e");
    }
  }

  void requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    print('User granted permission: ${settings.authorizationStatus}');
  }
}
