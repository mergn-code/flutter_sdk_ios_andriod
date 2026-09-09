import UIKit

public class SDKManager {

    // Singleton pattern to ensure only one instance is used throughout the app
    public static let shared = SDKManager()

    // To store the current view controller
    private var currentViewController: UIViewController?

    // Private initializer to prevent instantiating more instances of SDKManager
    private init() {}

    // Method to set the current view controller
    public func setCurrentViewController(_ viewController: UIViewController?) {
        do {
            guard let viewController = viewController else {
                throw SDKManagerError.invalidViewController
            }
            self.currentViewController = viewController
        } catch {
            print("Error setting the view controller: \(error.localizedDescription)")
        }
    }

    // Method to get the current view controller
    public func getCurrentViewController() -> UIViewController? {
        do {
            guard let currentViewController = self.currentViewController else {
                throw SDKManagerError.viewControllerNotSet
            }
            return currentViewController
        } catch {
            print("Error getting the current view controller: \(error.localizedDescription)")
            return nil
        }
    }
}

// Custom error type to handle specific SDKManager errors
public enum SDKManagerError: Error {
    case invalidViewController
    case viewControllerNotSet
}