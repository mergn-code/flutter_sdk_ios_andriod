import UIKit
import Flutter
import mergn_flutter_plugin

@main
@objc class AppDelegate: FlutterAppDelegate {
  
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        // Request permission for push notifications
        requestNotificationPermission()

        // Register for remote notifications
        application.registerForRemoteNotifications()

        // Set up FCM messaging delegate
       // Messaging.messaging().delegate = self

        // Make sure the FlutterViewController is accessible
        if let flutterViewController = window?.rootViewController as? FlutterViewController {
            // Set the FlutterViewController in SDKManager (If needed in your app)
            SDKManager.shared.setCurrentViewController(flutterViewController)
        }

        // Register Flutter plugins
        GeneratedPluginRegistrant.register(with: self)
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    // Request notification permissions
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else {
                print("Notification permission denied: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }

    // Handle incoming notifications when app is in the foreground
    override func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show notification in foreground
        //print("Notification tapped: \(response.notification.request.content.userInfo)")
        completionHandler([.alert, .sound])
    }

    // Handle push notifications when the app is opened from a notification
    override func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("Notification tapped: \(response.notification.request.content.userInfo)")
        completionHandler()
    }

    // Handle background notifications
    override func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // Process remote notification
        print("Received notification in the background: \(userInfo)")
        completionHandler(.newData)
    }
}
