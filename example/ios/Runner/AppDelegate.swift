import UIKit
import Flutter
import mergn_flutter_plugin

@main
@objc class AppDelegate: FlutterAppDelegate {
  
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        requestNotificationPermission()

        // Register for remote notifications
        application.registerForRemoteNotifications()

        // Make sure the FlutterViewController is accessible
        if let flutterViewController = window?.rootViewController as? FlutterViewController {
            // Set the FlutterViewController in SDKManager (If needed in your app)
            SDKManager.shared.setCurrentViewController(flutterViewController)
        }
        UNUserNotificationCenter.current().delegate = self

        // Register Flutter plugins
        GeneratedPluginRegistrant.register(with: self)
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }


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
