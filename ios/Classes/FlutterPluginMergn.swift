import Flutter
import UIKit

public class FlutterPluginMergn: NSObject, FlutterPlugin {
    private var flutterViewController: FlutterViewController?

    @objc(registerWithRegistrar:) public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_plugin", binaryMessenger: registrar.messenger())
        let instance = FlutterPluginMergn()

        registrar.addMethodCallDelegate(instance, channel: channel)

        // Use guard to check if we have a valid FlutterViewController
            guard let flutterViewController = UIApplication.shared.delegate?.window??.rootViewController as? FlutterViewController else {
                // If rootViewController is not available or cannot be cast, log and exit
                print("Error: rootViewController is not of type FlutterViewController.")
                return // Exit early if condition fails
            }

            // Proceed with the next operation if guard passes
            do {
                // Now attempt to interact with the SDKManager (e.g., setting the current view controller)
                try SDKManager.shared.setCurrentViewController(flutterViewController)
                print("Successfully set the current view controller.")
            } catch {
                // Catch any errors that may occur during the SDKManager operation
                print("Error: Failed to set current view controller in SDKManager. \(error.localizedDescription)")
            }
            }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {

        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)

        case "sendEvent":
            do {
                guard let args = call.arguments as? [String: Any] else {
                    throw FlutterPluginError.invalidArguments("Arguments for 'sendEvent' are missing or invalid")
                }
                guard let eventName = args["eventName"] as? String else {
                    throw FlutterPluginError.invalidArguments("Missing 'eventName' argument")
                }
                guard let eventProperties = args["eventProperties"] as? [String: String] else {
                    throw FlutterPluginError.invalidArguments("Missing or invalid 'eventProperties' argument")
                }

                // Handle sending event
                print("Event Name: \(eventName), Properties: \(eventProperties)")
                EventManager.shared.sendEvent(eventName: eventName, properties: eventProperties)
                result("Event Sent")
            } catch let error as FlutterPluginError {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: error.localizedDescription, details: nil))
            } catch {
                result(FlutterError(code: "UNKNOWN_ERROR", message: "An unexpected error occurred", details: nil))
            }

        case "sendAttribute":
            do {
                guard let args = call.arguments as? [String: Any] else {
                    throw FlutterPluginError.invalidArguments("Arguments for 'sendAttribute' are missing or invalid")
                }
                guard let attributeName = args["attributeName"] as? String else {
                    throw FlutterPluginError.invalidArguments("Missing 'attributeName' argument")
                }
                guard let attributeValue = args["attributeValue"] as? String else {
                    throw FlutterPluginError.invalidArguments("Missing 'attributeValue' argument")
                }

                // Handle sending attribute
                print("Attribute Name: \(attributeName), Value: \(attributeValue)")
                EventManager.shared.sendAttribute(attributeName: attributeName, attributeValue: attributeValue)
                result("Attribute Sent")
            } catch let error as FlutterPluginError {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: error.localizedDescription, details: nil))
            } catch {
                result(FlutterError(code: "UNKNOWN_ERROR", message: "An unexpected error occurred", details: nil))
            }

        case "login":
            do {
                guard let args = call.arguments as? [String: Any] else {
                    throw FlutterPluginError.invalidArguments("Arguments for 'login' are missing or invalid")
                }
                guard let email = args["email"] as? String else {
                    throw FlutterPluginError.invalidArguments("Missing 'email' argument")
                }

                // Handle sending identity
                print("Identity: \(email)")
                EventManager.shared.postIdentification(identity: email)
                result("Identity Sent")
            } catch let error as FlutterPluginError {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: error.localizedDescription, details: nil))
            } catch {
                result(FlutterError(code: "UNKNOWN_ERROR", message: "An unexpected error occurred", details: nil))
            }

        case "registerAPI":
            do {
                guard let arguments = call.arguments as? [String: Any] else {
                    throw FlutterPluginError.invalidArguments("Arguments for 'registerAPI' are missing or invalid")
                }
                guard let apiKey = arguments["apiKey"] as? String else {
                    throw FlutterPluginError.invalidArguments("Missing 'apiKey' argument")
                }

                // Handle register API
                print("Received clientApiKey: \(apiKey)")
                EventManager.shared.registerAPI(clientApiKey: apiKey)
                result("registerAPI called")
            } catch let error as FlutterPluginError {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: error.localizedDescription, details: nil))
            } catch {
                result(FlutterError(code: "UNKNOWN_ERROR", message: "An unexpected error occurred", details: nil))
            }

        case "fcm_token":
             do {
                 guard let arguments = call.arguments as? [String: Any] else {
                              throw FlutterPluginError.invalidArguments("Arguments for 'fcm_token' are missing or invalid")
                            }
                            guard let token = arguments["token"] as? String else {
                                throw FlutterPluginError.invalidArguments("Missing 'token' argument")
                            }

                            // Handle register API
                            print("Received token: \(token)")
                            EventManager.shared.firebaseToken(token: token)
                            result("fcm_token called")
                        } catch let error as FlutterPluginError {
                            result(FlutterError(code: "INVALID_ARGUMENTS", message: error.localizedDescription, details: nil))
                        } catch {
                            result(FlutterError(code: "UNKNOWN_ERROR", message: "An unexpected error occurred", details: nil))
             }

        default:
            result(FlutterMethodNotImplemented)
        }
    }
}

// Custom error handling class to manage errors
enum FlutterPluginError: Error {
    case invalidArguments(String)

    var localizedDescription: String {
        switch self {
        case .invalidArguments(let message):
            return message
        }
    }
}
