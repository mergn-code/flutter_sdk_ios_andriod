import Flutter
import UIKit

public class FlutterPluginMergn: NSObject, FlutterPlugin {
    private var flutterViewController: FlutterViewController?

    @objc(registerWithRegistrar:) public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_plugin", binaryMessenger: registrar.messenger())
        let instance = FlutterPluginMergn()

        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    // Updated to async
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        Task {
            do {
                switch call.method {
                case "getPlatformVersion":
                    result("iOS " + UIDevice.current.systemVersion)

                case "sendEvent":
                    try await handleSendEvent(call: call)
                    result("Event Sent")

                case "sendAttribute":
                    try await handleSendAttribute(call: call)
                    result("Attribute Sent")

                case "login":
                    try await handleLogin(call: call)
                    result("Identity Sent")

                case "registerAPI":
                    try await handleRegisterAPI(call: call)
                    result("registerAPI called")

                case "fcm_token":
                    try await handleFcmToken(call: call)
                    result("fcm_token called")

                default:
                    result(FlutterMethodNotImplemented)
                }
            } catch let error as FlutterPluginError {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: error.localizedDescription, details: nil))
            } catch {
                result(FlutterError(code: "UNKNOWN_ERROR", message: "An unexpected error occurred", details: nil))
            }
        }
    }

    // Refactored sendEvent function using async
    private func handleSendEvent(call: FlutterMethodCall) async throws {
        guard let args = call.arguments as? [String: Any] else {
            throw FlutterPluginError.invalidArguments("Arguments for 'sendEvent' are missing or invalid")
        }
        guard let eventName = args["eventName"] as? String else {
            throw FlutterPluginError.invalidArguments("Missing 'eventName' argument")
        }
        guard let eventProperties = args["eventProperties"] as? [String: String] else {
            throw FlutterPluginError.invalidArguments("Missing or invalid 'eventProperties' argument")
        }

        // Handle sending event asynchronously
        print("Event Name: \(eventName), Properties: \(eventProperties)")
        await EventManager.shared.sendEvent(eventName: eventName, properties: eventProperties)
    }

    // Refactored sendAttribute function using async
    private func handleSendAttribute(call: FlutterMethodCall) async throws {
        guard let args = call.arguments as? [String: Any] else {
            throw FlutterPluginError.invalidArguments("Arguments for 'sendAttribute' are missing or invalid")
        }
        guard let attributeName = args["attributeName"] as? String else {
            throw FlutterPluginError.invalidArguments("Missing 'attributeName' argument")
        }
        guard let attributeValue = args["attributeValue"] as? String else {
            throw FlutterPluginError.invalidArguments("Missing 'attributeValue' argument")
        }

        // Handle sending attribute asynchronously
        print("Attribute Name: \(attributeName), Value: \(attributeValue)")
        await EventManager.shared.sendAttribute(attributeName: attributeName, attributeValue: attributeValue)
    }

    // Refactored login function using async
    private func handleLogin(call: FlutterMethodCall) async throws {
        guard let args = call.arguments as? [String: Any] else {
            throw FlutterPluginError.invalidArguments("Arguments for 'login' are missing or invalid")
        }
        guard let email = args["email"] as? String else {
            throw FlutterPluginError.invalidArguments("Missing 'email' argument")
        }

        // Handle sending identity asynchronously
        print("Identity: \(email)")
        await EventManager.shared.postIdentification(identity: email)
    }

    // Refactored registerAPI function using async
    private func handleRegisterAPI(call: FlutterMethodCall) async throws {
        guard let arguments = call.arguments as? [String: Any] else {
            throw FlutterPluginError.invalidArguments("Arguments for 'registerAPI' are missing or invalid")
        }
        guard let apiKey = arguments["apiKey"] as? String else {
            throw FlutterPluginError.invalidArguments("Missing 'apiKey' argument")
        }

        // Handle register API asynchronously
        print("Received clientApiKey: \(apiKey)")
        await EventManager.shared.registerAPI(clientApiKey: apiKey)
    }

    // Refactored fcm_token function using async
    private func handleFcmToken(call: FlutterMethodCall) async throws {
        guard let arguments = call.arguments as? [String: Any] else {
            throw FlutterPluginError.invalidArguments("Arguments for 'fcm_token' are missing or invalid")
        }
        guard let token = arguments["token"] as? String else {
            throw FlutterPluginError.invalidArguments("Missing 'token' argument")
        }

        // Handle firebase token asynchronously
        print("Received token: \(token)")
        await EventManager.shared.firebaseToken(token: token)
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
