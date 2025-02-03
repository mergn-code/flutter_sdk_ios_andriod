import UIKit
import Flutter
import mergn_flutter_plugin

@main
@objc class AppDelegate: FlutterAppDelegate {
  
    override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

      // Get the FlutterViewController
        if let flutterViewController = window?.rootViewController as? FlutterViewController {
          // Set the FlutterViewController in SDKManager
          SDKManager.shared.setCurrentViewController(flutterViewController)
        }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    

override func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
            completionHandler([.alert, .sound])
        }

override func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
            completionHandler()
        }

        override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
            print("Opening deeplink", url)
            return true
        }
        
        override func application(_ application: UIApplication, willContinueUserActivityWithType userActivityType: String) -> Bool {
            print("Opening Universal link", userActivityType)
            return false
        }
}
