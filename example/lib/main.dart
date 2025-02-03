import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mergn_flutter_plugin/flutter_plugin_method_channel.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: 'YOUR_ANDROID_API_KEY',
        appId: '1:301998040977:android:be0d9b2a1fe27b376ddc30',
        messagingSenderId: '301998040977',
        projectId: 'flutter-android-and-ios',
        storageBucket: 'YOUR_ANDROID_STORAGE_BUCKET',
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
  runApp(MyApp());
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

  // Text field controllers
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _dynamicAttributeController = TextEditingController();
  final TextEditingController _identityController = TextEditingController();

  //static const platform = MethodChannel('mergnKotlinSDK'); // Channel for iOS communication

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event Manager'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Register API Button
            ElevatedButton(
              onPressed: _registerApi,
              child: Text('Register API'),
            ),
            SizedBox(height: 10),

            // Event Name Display
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

            // Dynamic Attribute TextField
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

            // Identity TextField
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

            // Send Event Button
            ElevatedButton(
              onPressed: _sendEvent,
              child: Text('Send Event'),
            ),
            SizedBox(height: 10),

            // Send Attribute Button
            ElevatedButton(
              onPressed: _sendAttribute,
              child: Text('Send Attribute'),
            ),
            SizedBox(height: 10),

            // Send Identity Button
            ElevatedButton(
              onPressed: _sendIdentity,
              child: Text('Send Identity'),
            ),
          ],
        ),
      ),
    );
  }

  // Function to register the API with a hardcoded clientApiKey
  Future<void> _registerApi() async {
    final clientApiKey = 'api key'; // Hardcoded API key

    try {
      MethodChannelFlutterPlugin().registerAPICall(
          "787bc5fb1f13150564d187eb0bfaf1fbm35rgn303e547cb2e3b758a2f4a7ce810b10e3");
    } on PlatformException catch (e) {
      print("Failed to register API: '${e.message}'.");
    }
  }

  // Function to send Event to iOS with hardcoded event name 'Product_Clicked'
  Future<void> _sendEvent() async {
    final eventName = "Product_Clicked"; // Hardcoded event name
    final eventProperties = {
      "category": "test-flutter"
    }; // Sample event properties

    try {
      MethodChannelFlutterPlugin().sendEvent(eventName, eventProperties);
      print("Event Sent: $eventName");
    } on PlatformException catch (e) {
      print("Failed to send event: '${e.message}'.");
    }
  }

  // Function to send Attribute to iOS
  Future<void> _sendAttribute() async {
    final dynamicAttributeValue = _dynamicAttributeController.text;

    if (dynamicAttributeValue.isNotEmpty) {
      try {
        MethodChannelFlutterPlugin().sendAttribute(
            "Email", dynamicAttributeValue);
        print("Attribute Sent: Email = $dynamicAttributeValue");
      } on PlatformException catch (e) {
        print("Failed to send attribute: '${e.message}'.");
      }
    } else {
      print("Dynamic Attribute cannot be empty");
    }
  }

  // Function to send Identity to iOS
  Future<void> _sendIdentity() async {
    final identity = _identityController.text;
    getToken();

    if (identity.isNotEmpty) {
      try {
        MethodChannelFlutterPlugin().login(identity);
      } on PlatformException catch (e) {
        print("Failed to send identity: '${e.message}'.");
      }
    } else {
      print("Identity cannot be empty");
    }
  }

  void getToken() async {

    String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
    print('APNS Token: $apnsToken');
    await Future.delayed(Duration(seconds: 2));
  /*  // Retrieve the APNs token
   // String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
    if (apnsToken != null) {
      print("APNs Token: $apnsToken");
    } else {
      print("Failed to get APNs token");
    }*/

    // Get the FCM token for the device
    String? fcmToken = await FirebaseMessaging.instance.getToken();

    if (fcmToken != null) {
      print("FCM Token: $fcmToken");
      MethodChannelFlutterPlugin().firebaseToken(fcmToken);
    } else {
      print("Failed to get FCM token");
    }


  }
}
