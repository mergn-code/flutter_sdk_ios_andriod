import Flutter
import UIKit

public class FlutterPluginMergn: NSObject, FlutterPlugin {
    @objc(registerWithRegistrar:) public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_plugin", binaryMessenger: registrar.messenger())
    let instance = FlutterPluginMergn()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {

    case "getPlatformVersion":
        result("iOS " + UIDevice.current.systemVersion)

    case "sendEvent": do{
                 if let args = call.arguments as? [String: Any],
                    let eventName = args["eventName"] as? String,
                    let eventProperties = args["eventProperties"] as? [String: String] {
                   // Handle sending event here
                   print("Event Name: \(eventName), Properties: \(eventProperties)")
                     EventManager.shared.sendEvent(eventName: eventName, properties: eventProperties)
                   result("Event Sent")
                 }
               }

    case "sendAttribute" : do{
                  if let args = call.arguments as? [String: Any],
                     let attributeName = args["attributeName"] as? String,
                     let attributeValue = args["attributeValue"] as? String {
                    // Handle sending attribute here
                    print("Attribute Name: \(attributeName), Value: \(attributeValue)")
                      EventManager.shared.sendAttribute(attributeName: attributeName, attributeValue: attributeValue)
                    result("Attribute Sent")
                  }
                }
    case "login": do {
                 if let args = call.arguments as? [String: Any],
                    let email = args["email"] as? String {
                   // Handle sending identity here
                   print("Identity: \(email)")
                     EventManager.shared.postIdentification(identity: email)
                   result("Identity Sent")
                 }
               }

    case "registerAPI": do {
                   // Call your registerAPI logic here
                     // Extract the parameter from the call arguments
                          if let arguments = call.arguments as? [String: Any],
                             let apiKey = arguments["apiKey"] as? String {
                              // Now you can use clientApiKey in your logic
                              print("Received clientApiKey: \(apiKey)")
                              EventManager.shared.registerAPI(clientApiKey: apiKey)
                              // Call your registerAPI logic here
                              //EventManager.shared.registerAPI(clientApiKey:"wqe")
                              result("registerAPI called") // Send back a response
                          } else {
                              result(FlutterError(code: "INVALID_ARGUMENTS", message: "clientApiKey is missing or invalid", details: nil))
                          }
                   result("registerAPI called")
                 }
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
