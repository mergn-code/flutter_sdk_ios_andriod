import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:io';

import 'flutter_plugin_platform_interface.dart';

/// An implementation of [FlutterPluginPlatform] that uses method channels.
class MethodChannelFlutterPlugin extends FlutterPluginPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_plugin');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  /// Initializes the Mergn SDK.
  ///
  /// This method invokes the native method `InitializeSdk` and prints the returned message.
  ///
  /// Throws a [PlatformException] if the initialization fails.
  Future<void> initializeSDK() async {

    if(Platform.isAndroid)
    {
      try {
        final String message = await methodChannel.invokeMethod('InitializeSdk');
        print(message);
      } on PlatformException catch (e) {
        print("Failed to initialize SDK: '${e.message}'.");
      }
    }
    else if(Platform.isIOS){

    }

  }

  /// Registers an API call with the provided [apiKey].
  ///
  /// This method invokes the native method `registerAPI` with the API key.
  ///
  /// Throws a [PlatformException] if the registration fails.
  ///
  /// [apiKey]: The API key to register.
  Future<void> registerAPICall(String apiKey) async {
    if(Platform.isAndroid){
      try {
        final String message =
        await methodChannel.invokeMethod('registerAPI', {"apiKey": apiKey});
        print(message);
      } on PlatformException catch (e) {
        print("Failed to get register API Method: '${e.message}'.");
      }}
    else if(Platform.isIOS){
      try {
        // Sending the clientApiKey to the iOS side via the platform channel
        await methodChannel.invokeMethod('registerAPI', {'apiKey': apiKey});
        print("API registered successfully with apiKey: $apiKey");
      } on PlatformException catch (e) {
        print("Failed to register API: '${e.message}'.");
      }
    }
  }

  /// Sends an event with the specified [eventName] and [eventProperties].
  ///
  /// This method invokes the native method `sendEvent`.
  ///
  /// Throws a [PlatformException] if the event sending fails.
  ///
  /// [eventName]: The name of the event to send.
  /// [eventProperties]: A map of properties associated with the event.
  Future<void> sendEvent(
      String eventName, Map<String, String> eventProperties) async {
    if(Platform.isAndroid){
      try {
        await methodChannel.invokeMethod('sendEvent',
            {"eventName": eventName, "eventProperties": eventProperties});
      } on PlatformException catch (e) {
        print("Failed to send event: '${e.message}'.");
      }}
    else if(Platform.isIOS){
      try {

        // Sending the event name and properties to the iOS side
        await methodChannel.invokeMethod('sendEvent', {
          'eventName': eventName,
          'eventProperties': eventProperties,
        });
        print("Event Sent: $eventName");
      } on PlatformException catch (e) {
        print("Failed to send event: '${e.message}'.");
      }
    }
  }

  /// Sends an attribute with the specified [attributeName] and [attributeValue].
  ///
  /// This method invokes the native method `sendAttribute`.
  ///
  /// Throws a [PlatformException] if the attribute sending fails.
  ///
  /// [attributeName]: The name of the attribute to send.
  /// [attributeValue]: The value of the attribute to send.
  Future<void> sendAttribute(
      String attributeName, String attributeValue) async {
    if(Platform.isAndroid){
      try {
        await methodChannel.invokeMethod('sendAttribute',
            {"attributeName": attributeName, "attributeValue": attributeValue});
      } on PlatformException catch (e) {
        print("Failed to send attribute: '${e.message}'.");
      }}
    else if(Platform.isIOS){
      try {

        // Sending the attribute to the iOS side
        await methodChannel.invokeMethod('sendAttribute', {
          'attributeName': attributeName,
          'attributeValue': attributeValue,
        });
        print("Attribute Sent: $attributeName = $attributeValue");
      } on PlatformException catch (e) {
        print("Failed to send attribute: '${e.message}'.");
      }
    }
  }

  /// Logs in with the specified [value].
  ///
  /// This method invokes the native method `login` with the provided email.
  ///
  /// Throws a [PlatformException] if the login fails.
  ///
  /// [value]: The email address of the user to log in.
  Future<void> login(String value) async {
    if(Platform.isAndroid){
      try {
        await methodChannel.invokeMethod('login', {"email": value});
      } on PlatformException catch (e) {
        print("Failed to send attribute: '${e.message}'.");
      }}
    else if(Platform.isIOS){
      try {
        // Sending the identity to the iOS side
        await methodChannel.invokeMethod('login', {'email': value});
        print("Identity Sent: $value");
      } on PlatformException catch (e) {
        print("Failed to send identity: '${e.message}'.");
      }
    }
  }

  /// Sends a Firebase token with the specified [value].
  ///
  /// This method invokes the native method `fcm_token`.
  ///
  /// Throws a [PlatformException] if sending the token fails.
  ///
  /// [value]: The Firebase Cloud Messaging token to send.
  Future<void> firebaseToken(String value) async {
    if(Platform.isAndroid){
      try {
        await methodChannel.invokeMethod('fcm_token', {"token": value});
      } on PlatformException catch (e) {
        print("Failed to send token: '${e.message}'.");
      }
    }}
}
