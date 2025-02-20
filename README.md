Flutter SDK Merge

This documentation provides integration steps and usage instructions for incorporating the Flutter SDK 1.0.6 into your Flutter project. Follow these steps to initialize the SDK, record events, and manage attributes within your application.

## Integration Steps

1. Add mergn_flutter_plugin_sdk: in pubsec.yml

2. ## For IOS Run following commands

Run command flutter build iOS this will generate pod file.
Run pod install

## Usage

    import 'package:mergn_flutter_plugin/flutter_plugin_method_channel.dart';

### 1. Register API Key

Register your API Key:


MethodChannelFlutterPlugin().registerAPICall("API KEY");

### 2. Record Events

Use the EventManager to record events by providing an event name and properties:


    String eventName = "Event Name";
    // Map<String, String> eventProperties = {"propertyName": "PropertyValue"}; 
    // Optional property setup

    Map<String, String> eventProperties = Map(); // For empty properties

    MethodChannelFlutterPlugin().sendEvent(eventName, eventProperties);


### 3. Record Attributes

Use the AttributeManager to record attributes by providing an attribute name and value:


    String attributeName = "Email"; // eventName.text.toString()

    String attributeValue = "fluttersdk@mergn.com";

    MethodChannelFlutterPlugin().sendAttribute(attributeName, attributeValue);


### 4. Login

Record the login event when the user successfully logs in:

    MethodChannelFlutterPlugin().login("fluttersdk@mergn.com");  // Add unique Identifier


**Unique Identity (mandatory)**: This value represents the customer's unique identity in your database, such as an ID or email.

### 5. Firebase Token Registration

Register the Firebase token to receive MERGN notifications:

    MethodChannelFlutterPlugin().firebaseToken(fcmToken.toString());


This method should be called in any place where you would potentially land. Also, call this in onNewToken() and onRefreshToken() in your Firebase service.


### 6. IOS Notification and UI reference

Add the following code in app delegate under Runner folder

    import UIKit
    import Flutter
    import mergn_flutter_plugin

    @main
    @objc class AppDelegate: FlutterAppDelegate {

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        if let flutterViewController = window?.rootViewController as? FlutterViewController {
            SDKManager.shared.setCurrentViewController(flutterViewController)
        }
        UNUserNotificationCenter.current().delegate = self

        // Register Flutter plugins
        GeneratedPluginRegistrant.register(with: self)
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }




    override func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
         EventManager.shared.notificationViewed(notificationData: notification.request)
         completionHandler([.banner, .alert, .sound, .badge])
    }

    // Handle push notifications when the app is opened from a notification
    override func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("Notification tapped: \(response.notification.request.content.userInfo)")
        EventManager.shared.notificationTapped(notificationData: response.notification.request)
        completionHandler()
    }

    // Handle background notifications
    override func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // Process remote notification
        print("Received notification in the background: \(userInfo)")
        completionHandler(.newData)
    }
    }




### Important Case

There are three scenarios in the app where you need to send sign-in attributes and trigger the login event of the MERGN SDK:

1. When a new user creates a new account.
2. When existing users log into the app.
3. When the user is already logged in (important for capturing data of users who logged in previous versions of the app where the MERGN SDK was not integrated).


