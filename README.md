Flutter SDK Merge

This documentation provides integration steps and usage instructions for incorporating the Flutter SDK 3.0.0-beta.1 into your Flutter project. Follow these steps to initialize the SDK, record events, and manage attributes within your application.

## Integration Steps

1. Add mergn_flutter_plugin_sdk: in pubsec.yml

2. ## For IOS Run following commands

Run command flutter build iOS this will generate pod file.
Run pod install

### iOS dependency management

The plugin supports both **CocoaPods** and **Swift Package Manager**. Nothing extra
is needed for either — Flutter picks whichever your project is configured to use.

If your app has Swift Package Manager enabled (`flutter config --enable-swift-package-manager`),
use 3.0.0-beta.1 or later. Every earlier published version is CocoaPods-only and
produces this warning:

    The following plugins do not support Swift Package Manager for ios:
      - mergn_flutter_plugin

Because it is a prerelease, `^3.0.0` will not resolve to it. Depend on it
explicitly:

    dependencies:
      mergn_flutter_plugin: 3.0.0-beta.1

### iOS requirements

From 3.0.0-beta.1 the iOS plugin delegates to the native Mergn iOS SDK, shipped as a
prebuilt `mergn_ios.xcframework`, instead of carrying its own copy of the SDK
source. The plugin re-exports that module, so `import mergn_flutter_plugin` and
the `SDKManager` / `EventManager` calls below are unchanged.

The binary SDK imposes two requirements:

| Requirement | Minimum |
| --- | --- |
| Xcode | 26.0 |
| iOS deployment target | 15.0 |

The Xcode floor is a hard one. Swift binary frameworks are forward-compatible
only, so an app built with an older Xcode cannot import this module at all and
will fail with `module compiled with Swift ... cannot be imported`. If you are
not on Xcode 26 yet, stay on the 2.1.x line, which is distributed as source and
compiles with whatever toolchain you have.

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

If the property type is array, set value according to this:


    String eventName = "Event Name";
    // ✅ Map for event properties
    Map<String, String> eventPropertiesMap = {};

    List<String> stringArray = [
    "Value1",
    "Value2",
    "Value3"
    ]; // Example
    
Convert it into json

    eventPropertiesMap[
    "request-names"
    ] = jsonEncode(stringArray);

    MethodChannelFlutterPlugin().sendEvent(eventName, eventPropertiesMap);


### 3. Record Attributes

Use the AttributeManager to record attributes by providing an attribute name and value:


    String attributeName = "Email"; // eventName.text.toString()

    String attributeValue = "fluttersdk@mergn.com"; // Example

    MethodChannelFlutterPlugin().sendAttribute(attributeName, attributeValue);


### 4. Login

Record the login event when the user successfully logs in:

    MethodChannelFlutterPlugin().login("fluttersdk@mergn.com");  // Add unique Identifier


**Unique Identity (mandatory)**: This value represents the customer's unique identity in your database, such as an ID or email.

### 5. Firebase Token Registration

Register the Firebase token to receive MERGN notifications:

    MethodChannelFlutterPlugin().firebaseToken(fcmToken.toString()); // This firebase token


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
### 7. IOS Notification Extension Service for showing image

-Add the Notification Extension Service from xcode

    import UserNotifications
    

    class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        

        // Check for the media URL
        if let mediaUrlString = request.content.userInfo["image"] as? String,
           let mediaUrl = URL(string: mediaUrlString) {
            
            // Download the image
            downloadImage(from: mediaUrl) { imageData in
                if let imageData = imageData {
                    // Attach the image as a big picture to the notification
                    self.attachBigImageToNotification(imageData: imageData)
                }
                
                // Call the content handler to deliver the notification
                contentHandler(self.bestAttemptContent!)
            }
        } else {
            // If no image, just return the original notification content
            contentHandler(self.bestAttemptContent!)
        }
    }

    override func serviceExtensionTimeWillExpire() {
        // Called when the extension is about to time out
        if let contentHandler = contentHandler, let bestAttemptContent = bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

    // Helper function to download the image
    func downloadImage(from url: URL, completion: @escaping (Data?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error downloading image: \(error)")
                completion(nil)
            } else {
                completion(data)
            }
        }
        task.resume()
    }

    // Helper function to save the image to a temporary directory
    func saveImageToTempDirectory(data: Data) -> URL {
        let tempDirectory = FileManager.default.temporaryDirectory
        let fileURL = tempDirectory.appendingPathComponent(UUID().uuidString + ".jpg")
        try? data.write(to: fileURL)
        return fileURL
    }

    // Helper function to attach the image as a big picture to the notification
    func attachBigImageToNotification(imageData: Data) {
        let imageURL = saveImageToTempDirectory(data: imageData)

        if let attachment = try? UNNotificationAttachment(identifier: "image", url: imageURL, options: nil) {
            // Attach the image to the notification content
            bestAttemptContent?.attachments = [attachment]
        }
    }
    }




### Proguard Rules

    -keep,allowobfuscation,allowshrinking class kotlin.coroutines.Continuation


    -if interface * { @retrofit2.http.* public *** *(...); }
    -keep,allowoptimization,allowshrinking,allowobfuscation class <3>

    -keep,allowobfuscation,allowshrinking class retrofit2.Response
    -keep class com.google.gson.reflect.TypeToken { *; }
    -keep class * extends com.google.gson.reflect.TypeToken
    # Keep the Mergn Flutter plugin class
    -keep class com.mergn.flutter_plugin.FlutterPluginMergn { *; }

    -assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** i(...);
    public static *** w(...);
    public static *** e(...);
    public static *** v(...);
    public static *** wtf(...);
    }

### Important Case

There are four scenarios in the app where you need to send sign-in attributes and trigger the login event of the MERGN SDK:

1. When a new user creates a new account.
2. When existing users log into the app.
3. When the user is already logged in (important for capturing data of users who logged in previous versions of the app where the MERGN SDK was not integrated).
4. When setting up an attribute which is also a identity i.e. mobile number, should call login event before sending the attribute.

