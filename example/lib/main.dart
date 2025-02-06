import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mergn_flutter_plugin/flutter_plugin_method_channel.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {

  } catch (e) {
    print("Failed to initialize Firebase: $e");
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
      await MethodChannelFlutterPlugin().registerAPICall(
          "");
    } on PlatformException catch (e) {
      print("Failed to register API: '${e.message}'.");
    } catch (e) {
      print("Unexpected error during API registration: $e");
    }
  }

  // Function to send Event to iOS with hardcoded event name 'Product_Clicked'
  Future<void> _sendEvent() async {
    final eventName = "Product_Clicked"; // Hardcoded event name
    final eventProperties = {
      "category": "test-flutter"
    }; // Sample event properties

    try {
      await MethodChannelFlutterPlugin().sendEvent(eventName, eventProperties);
      print("Event Sent: $eventName");
    } on PlatformException catch (e) {
      print("Failed to send event: '${e.message}'.");
    } catch (e) {
      print("Unexpected error while sending event: $e");
    }
  }

  // Function to send Attribute to iOS
  Future<void> _sendAttribute() async {
    final dynamicAttributeValue = _dynamicAttributeController.text;

    if (dynamicAttributeValue.isNotEmpty) {
      try {
        await MethodChannelFlutterPlugin().sendAttribute(
            "Email", dynamicAttributeValue);
        print("Attribute Sent: Email = $dynamicAttributeValue");
      } on PlatformException catch (e) {
        print("Failed to send attribute: '${e.message}'.");
      } catch (e) {
        print("Unexpected error while sending attribute: $e");
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
      // String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
      // print('APNS Token: $apnsToken');
      // await Future.delayed(Duration(seconds: 2));

      // Get the FCM token for the device
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
}
