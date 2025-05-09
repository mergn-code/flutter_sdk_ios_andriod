//
//  EventManager.swift
//  mergn_ios
//
//  Created by Syed Hamza Hassan - Mergn on 05/11/2024.
//

import Foundation
import UIKit
import UserNotifications

public class EventManager {
    
    private let identifierKey = "com.example.uniqueIdentifier"
    private let customerMergnKey = "customer_mergn_key"
    public  let apiMergnKey = "api_mergn_key"
    private var uiViewController: UIViewController?
    private var campaing: Campaigns =  Campaigns(campaigns: [])
    private var campaignId = ""
    private var campaignInstanceId = ""
    private let firebaseTokenMergn = "mergn_firebase_token"
    private let appInstalledMergn = "mergn_app_installed"
    let installEventSemaphore = DispatchSemaphore(value: 0)
    
    let appEventQueue = DispatchQueue(label: "com.mergn.appEventQueue")

    // Static shared instance
    public static let shared = EventManager()

    // Private initializer to prevent external instantiation
    private init() {
        // You can set up default values or load configurations here
        print("EventManager initialized")
    }

    var eventsList: [String : Event] = [:]

    // Generate or retrieve a unique identifier
    public func registerAPI(clientApiKey: String) {
    //Do call app launch here
        do {
            self.fetchInstallDate()
            let apiKey = clientApiKey
            UserDefaults.standard.set(apiKey, forKey: apiMergnKey)
            postIdentification()
        } catch {
            print("Error registering API: \(error)")
        }
    }

    var eventMap: [String: Event] = [:]
    var attributeMap: [String: AttributeListResponse.Attribute] = [:]

    // Method to add an event
    func addEvent(_ name: String, _ event: Event) {
        eventMap[name] = event
      
    }

    // Method to get an event by name
    func getEvent(byName name: String) -> Event? {
        return eventMap[name]
    }

    // Method to add an attribute
    func addAttribute(_ name: String, _ attribute: AttributeListResponse.Attribute) {
        attributeMap[name] = attribute
    }

    // Method to get an attribute by name
    func getAttribute(byName name: String) -> AttributeListResponse.Attribute? {
        return attributeMap[name]
    }

    // Generate or retrieve a unique identifier
    public  func getUniqueIdentifier() -> String {
        if let savedIdentifier = UserDefaults.standard.string(forKey: identifierKey) {
                return savedIdentifier
            } else {
                let newIdentifier = UUID().uuidString
                UserDefaults.standard.set(newIdentifier, forKey: identifierKey)
                return newIdentifier
            }
        }

    // Save Unique Customer Id
    public func saveCustomerId(customerId : String) -> String {
       let saveCustomerId = customerId
            UserDefaults.standard.set(saveCustomerId, forKey: customerMergnKey)
            return saveCustomerId
    }

    // Save Firebase Token
    public func saveFirebaseToken(token : String) -> String {
        guard !token.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                print("Invalid token: Token is empty")
                return ""
            }

            UserDefaults.standard.set(token, forKey: firebaseTokenMergn)
            return token
        }

    public func getCustomerId() -> String {
        return UserDefaults.standard.string(forKey: customerMergnKey) ?? ""
    }

    public func getFirebaseToken() -> String {
        guard let firebaseToken = UserDefaults.standard.string(forKey: firebaseTokenMergn), !firebaseToken.isEmpty else {
            print("Firebase token not found or is empty")
            return ""
        }
        return firebaseToken
    }


    public func getEventList() {
        do {
            NetworkManager.shared.getEventList { result in
                switch result {
                case .success(let eventList):
                    for eventData in eventList.data {
                        EventManager.shared.addEvent(eventData.key, eventData.value)
                    }
                    self.addAppInstalledEvent()  // First, add app install event
                    self.addAppLaunchEvent()    // Then, add app launch event
//                    //Calling App launch here
//                    if(!AppConstantsMergn.shared.isAppLaunch){
//                    AppConstantsMergn.shared.isAppLaunch = true
//                    print("App Launched Successfully")
//                    self.sendEvent(eventName: AppConstantsMergn.shared.MERGN_APP_LAUNCHED, properties: [:]);
//                    }
                    //Calling App launch here
                    if self.attributeMap.isEmpty {
                        self.getAttributeList()
                    }
                case .failure(let error):
                    print("Error fetching event list: \(error)")
                }
            }
        } catch {
            print("Error in getEventList: \(error)")
        }
    }

   public func getAttributeList() {
       NetworkManager.shared.getAttributeList { result in
           switch result {
           case .success(let attributeList):
               do {
                   guard !attributeList.data.isEmpty else {
                       throw NSError(domain: "getAttributeList", code: 1001, userInfo: [NSLocalizedDescriptionKey: "No attribute data available."])
                   }

                   for attributeData in attributeList.data {
                       EventManager.shared.addAttribute(attributeData.key, attributeData.value)
                   }

               } catch let processingError {
                   print("Error processing attribute list: \(processingError.localizedDescription)")
               }

           case .failure(let error):
               print("Error fetching attribute list: \(error.localizedDescription)")
           }
       }
   }


public func getAttributeValue(attributeId : String) -> String {
        guard let attrbiuteValue = UserDefaults.standard.string(forKey: attributeId), !attrbiuteValue.isEmpty else {
            print("Attribute value is Empty")
            return ""
        }
        return attrbiuteValue
    }


    // Static method for posting identification
    public func postIdentification(identity: String? = nil) {
        do {
            var requestBody = SetIdentificationRequest(deviceId: getUniqueIdentifier(), os: "iOS")

            if let identity = identity, !identity.isEmpty {
                requestBody = SetIdentificationRequest(deviceId: getUniqueIdentifier(), os: "iOS", identity: identity)
            }

            NetworkManager.shared.postIdentification(requestBody: requestBody) { result in
                switch result {
                case .success(let response):
                    print("Post Identification Successful: \(response.data)")
                    self.saveCustomerId(customerId: String(response.data))
                    if self.eventMap.isEmpty {
                        self.getEventList()
                    }
                case .failure(let error):
                    print("Error posting identification: \(error)")
                }
            }
        } catch {
            print("Error in postIdentification: \(error)")
        }
    }

    public func sendEvent(eventName: String, properties: [String: Any]) {
        do {
            if eventMap.isEmpty {
                getEventList()
                return
            }

            if eventMap.keys.contains(eventName) {
                var eventDetails = EventManager.shared.getEvent(byName: eventName)
                var eventId: Int = eventDetails?.id ?? 0
                var eventProperties: [EventRequestModel.EventProperty] = []

                if let propertiesEvent = eventDetails?.eventProperty {
                    for (key, property) in propertiesEvent {
                        if properties.keys.contains(property.name) {
                            var newEventProperty = EventRequestModel.EventProperty(eventPropertyId: property.id, value: properties[property.name] as? String ?? "")
                            eventProperties.append(newEventProperty)
                        }
                    }

                    if propertiesEvent.keys.contains("Platform") {
                        var newEventProperty1 = EventRequestModel.EventProperty(eventPropertyId: propertiesEvent["Platform"]?.id ?? 0, value: "iOS")
                        eventProperties.append(newEventProperty1)
                    }

                    if propertiesEvent.keys.contains("sdk-version") {
                        var newEventProperty2 = EventRequestModel.EventProperty(eventPropertyId: propertiesEvent["sdk-version"]?.id ?? 0, value: "3")
                        eventProperties.append(newEventProperty2)
                    }
                }

                var eventModel = EventRequestModel.Event(
                    eventId: eventId,
                    eventProperties: eventProperties,
                    sessionId: getUniqueIdentifier()
                )

                var eventModelList: [EventRequestModel.Event] = [eventModel]
                var eventRequestModel = EventRequestModel.EventRequest(
                    customerId: getCustomerId(),
                    deviceId: getUniqueIdentifier(),
                    events: eventModelList
                )

                postEventToServer(eventRequestModel: eventRequestModel)
            }
        } catch {
            print("Error in sendEvent: \(error)")
        }
    }

    public func sendPopupEvent(eventName: String, popupActionProperty: String,
                                popupAction: String, actionValue: String) {
        do {
            if eventMap.isEmpty {
                getEventList()
                return
            }

            if eventMap.keys.contains(eventName) {
                let eventDetails = EventManager.shared.getEvent(byName: eventName)
                let eventId: Int = eventDetails?.id ?? 0
                var eventProperties: [EventRequestModel.EventProperty] = []

                if let propertiesEvent = eventDetails?.eventProperty {
                    if propertiesEvent.keys.contains(popupActionProperty) {
                        var newEventProperty = EventRequestModel.EventProperty(eventPropertyId: propertiesEvent[popupActionProperty]?.id ?? 0, value: actionValue)
                        eventProperties.append(newEventProperty)
                    }

                    if propertiesEvent.keys.contains("Platform") {
                        var newEventProperty1 = EventRequestModel.EventProperty(eventPropertyId: propertiesEvent["Platform"]?.id ?? 0, value: "iOS")
                        eventProperties.append(newEventProperty1)
                    }

                    if propertiesEvent.keys.contains("sdk-version") {
                        var newEventProperty2 = EventRequestModel.EventProperty(eventPropertyId: propertiesEvent["sdk-version"]?.id ?? 0, value: "3")
                        eventProperties.append(newEventProperty2)
                    }
                }

                var eventModel = EventRequestModel.Event(
                    eventId: eventId,
                    eventProperties: eventProperties,
                    sessionId: getUniqueIdentifier(),
                    campaignCustomerInstanceId: campaignInstanceId,
                    campaignId: "",
                    name: popupAction
                )

                var eventModelList: [EventRequestModel.Event] = [eventModel]
                var eventRequestModel = EventRequestModel.EventRequest(
                    customerId: getCustomerId(),
                    deviceId: getUniqueIdentifier(),
                    events: eventModelList
                )

                postEventToServer(eventRequestModel: eventRequestModel)
            }
        } catch {
            print("Error in sendPopupEvent: \(error)")
        }
    }

    func postEventToServer(eventRequestModel: EventRequestModel.EventRequest) {
        do {
            var requestBody = eventRequestModel

            NetworkManager.shared.recordEvent(requestBody: requestBody) { result in
                switch result {
                case .success(let response):
                    print("Post Record Event Successful: \(response.data)")
                    self.campaing = response.data
                    let currentVC = SDKManager.shared.getCurrentViewController()

                    DispatchQueue.main.async {
                        do{
                            
                            if !self.campaing.campaigns.isEmpty {
                                self.campaignId = String(self.campaing.campaigns.first?.campaignId ?? 0)
                                self.campaignInstanceId = self.campaing.campaigns.first?.campaignCustomerInstanceId ?? ""
//                                if let currentVC = currentVC {
//                                    // Now currentVC is safely unwrapped and can be used
//                                    self.openWebView(from: currentVC, htmlString: self.campaing.campaigns.first?.message?.design ?? "")
//                                } else {
//                                    print("currentVC is nil")
//                                }
                                
                                guard let currentVC = currentVC else {
                                            throw EventManagerError.unknownError
                                        }

                                        // Now call the openWebView method which may throw an error
                                        try self.openWebView(from: currentVC, htmlString: self.campaing.campaigns.first?.message?.design ?? "")
                            }
                        }
                        catch  let error {
                            // Handle and print the error thrown from the do block
                            print("Error in showing campaign: \(error)")
                        }
                    }
                case .failure(let error):
                    print("Error posting Record Event: \(error)")
                }
            }
        } catch {
            print("Error in postEventToServer: \(error)")
        }
    }

    public func sendAttribute(attributeName: String, attributeValue: String) {
            do {
                if attributeMap.isEmpty {
                    getAttributeList()
                    return
                }
                //In case of empty value, attribute will be recorded
                if(attributeValue.isEmpty){return}

                if attributeMap.keys.contains(attributeName) {
                    var attributeRequestModel = AttributeRequestModel.AttributeRequest(
                        customerId: getCustomerId(),
                        attributeId: EventManager.shared.getAttribute(byName: attributeName)?.id ?? 0,
                        value: attributeValue
                    )
                    //In case of same attribute value attribute will not trigger
                    if(self.getAttributeValue(attributeId: String(attributeRequestModel.attributeId)) != attributeValue){
                        //In case attribute property value set_identity = true, should call set identity
                        if(EventManager.shared.getAttribute(byName: attributeName)?.should_set_identity ?? false){
                            self.postIdentification(identity: attributeValue)
                        }
                        //Set identity Call complete

                        DispatchQueue.global().asyncAfter(deadline: .now() + 2.0) {
                            // Putting 2 seconds delay make sure, set identity call should be first.
                            do {
                                   try self.postAttributeToServer(attributeRequestModel: attributeRequestModel)
                               } catch {
                                   print("Error posting attributes to server: \(error)")
                               }
                        }

                    }
                    else {
                        print("Attribute value is same as previous")
                    }


                }
            } catch {
                print("Error in sendAttribute: \(error)")
            }
        }

    /*public func sendAttribute(attributeName: String, attributeValue: String) {
        do {
            if attributeMap.isEmpty {
                getAttributeList()
                return
            }

            if attributeMap.keys.contains(attributeName) {
                var attributeRequestModel = AttributeRequestModel.AttributeRequest(
                    customerId: getCustomerId(),
                    attributeId: EventManager.shared.getAttribute(byName: attributeName)?.id ?? 0,
                    value: attributeValue
                )

                postAttributeToServer(attributeRequestModel: attributeRequestModel)
            }
        } catch {
            print("Error in sendAttribute: \(error)")
        }
    }*/

    func postAttributeToServer(attributeRequestModel: AttributeRequestModel.AttributeRequest) {
        do {
            var requestBody = attributeRequestModel

            NetworkManager.shared.recordAttribute(requestBody: requestBody) { result in
                switch result {
                case .success(let response):
                    print("Attribute Successfully Captured: \(response.data)")
                case .failure(let error):
                    print("Error posting Attribute: \(error)")
                }
            }
        } catch {
            print("Error in postAttributeToServer: \(error)")
        }
    }

    var campaignResponse = Campaigns(campaigns: [])

    public func openWebView(from parentViewController: UIViewController, htmlString: String) {
        do {
            var webViewController = WebViewController()
            if !campaing.campaigns.isEmpty {
                webViewController.loadHTML(campaing.campaigns.first?.message?.design ?? "")
            }
            uiViewController = parentViewController
            uiViewController?.present(webViewController, animated: true, completion: nil)
        } catch {
            print("Error opening WebView: \(error)")
        }
    }

    func decodeAddEventResponse(from jsonData: Data) {
        do {
            let decoder = JSONDecoder()
            let decodedResponse = try decoder.decode(AddEventResponse.self, from: jsonData)
            print("Decoded Response: \(decodedResponse)")
        } catch {
            print("Decoding Error: \(error)")
        }
    }

    /*public func firebaseToken(token: String) {
        do {
            print(token)
            saveFirebaseToken(token: token)
            if token.isEmpty {
                return
            }
            postDeviceToken()
        } catch {
            print("Error in firebaseToken: \(error)")
        }
    }*/

       public func firebaseToken(token: String) {
            do {
                print(token)
                saveFirebaseToken(token: token)
                if token.isEmpty {
                    return
                }
                //first time TokenManager.shared.authToken always be empty b/c we want to push token to the server
                //when app launches
                //If token changed, it will call it again
                let lastToken = TokenManager.shared.authToken ?? ""
                if(TokenManager.shared.authToken == token){
                    return
                }
                TokenManager.shared.authToken = token
                //End of token maintaining implementation
                postDeviceToken()
            } catch {
                print("Error in firebaseToken: \(error)")
            }
        }

    func postDeviceToken() {
        do {
            var appToken = AppPushToken(token: getFirebaseToken())
            var requestBody = AppDeviceTokenRequest(device_id: getUniqueIdentifier(), is_app_push_subscribed: true, device_platform: "app_ios", app_push_token: appToken)
            NetworkManager.shared.postToken(requestBody: requestBody) { result in
                switch result {
                case .success(let response):
                    print("Token Successfully Captured: \(response.data)")
                case .failure(let error):
                    print("Error posting Token: \(error)")
                }
            }
        } catch {
            print("Error in postDeviceToken: \(error)")
        }
    }

    public func notificationViewed(notificationData: UNNotificationRequest) {
        do {
            if let campaignInstanceId = notificationData.content.userInfo["campaignCustomerInstanceId"] as? String {
                self.campaignInstanceId = campaignInstanceId
            }
            //campaignId = "86"
            sendPopupEvent(eventName: EventNames.notificationViewed.rawValue, popupActionProperty: "", popupAction: PopupActionName.view.rawValue, actionValue: "")
        } catch {
            print("Error in notificationViewed: \(error)")
        }
    }

    public func notificationTapped(notificationData: UNNotificationRequest) {
        do {
            if let campaignInstanceId = notificationData.content.userInfo["campaignCustomerInstanceId"] as? String {
                self.campaignInstanceId = campaignInstanceId
            }
            //campaignId = "86"
            sendPopupEvent(eventName: EventNames.notificationClicked.rawValue, popupActionProperty: "", popupAction: PopupActionName.click.rawValue, actionValue: "")
        } catch {
            print("Error in notificationTapped: \(error)")
        }
    }
    
    enum EventManagerError: Error {
        case networkError(description: String)
        case unknownError
    }


    // App Installed Logic

  public var isAppInstallDateValid: Bool {
      do {
          // Retrieve the stored installation date from UserDefaults
          guard let storedInstallDate = UserDefaults.standard.value(forKey: "appInstallDate") as? Date else {
              return false // No install date found
          }

          // Check if the stored installation date is less than 5 minutes old
          let currentDate = Date()
          return currentDate.timeIntervalSince(storedInstallDate) < 5 * 60

      } catch {
          // If an error occurs, handle it here
          print("Error retrieving or checking appInstallDate: \(error.localizedDescription)")
          return false // Return false in case of error
      }
  }


    private func fetchInstallDate() -> Date {
        do {
            if let documentsFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last {
                let attributes = try FileManager.default.attributesOfItem(atPath: documentsFolder.path)
                if let installDate = attributes[.creationDate] as? Date {
                    // Save the install date to UserDefaults
                    UserDefaults.standard.set(installDate, forKey: "appInstallDate")
                    print("Install Time : \(installDate)")
                    return installDate
                }
            }
        } catch {
            // Handle any error that occurred when accessing the file system
            print("Error retrieving creation date: \(error.localizedDescription)")
        }

        // Fallback to current date if an error occurs
        let fallbackDate = Date()
        // Optionally, save fallback date to UserDefaults
        //UserDefaults.standard.set(fallbackDate, forKey: "appInstallDateFallback")
        return fallbackDate
    }

    // Define a method to simulate adding app launch event with error handling

    func addAppInstalledEvent() {
        appEventQueue.async {
            do {
                // Simulate the app install event (this could be storing the install date or logging the event)
               //Calling App launch here

                if (self.isAppInstallDateValid && !UserDefaults.standard.bool(forKey: self.appInstalledMergn)){

                    print("Mobile App installed Successfully ")
                   
                    UserDefaults.standard.set(true, forKey: self.appInstalledMergn)
                     
                    self.sendEvent(eventName: EventNames.appInstalled.rawValue, properties: [:]);
                    // After the install event is done, signal the semaphore to unblock the launch event
                   // self.installEventSemaphore.signal()

                                }
            } catch {
                // Catch any error that occurred and handle it
                print("Error adding app install event: \(error.localizedDescription)")
            }
        }
    }

    func addAppLaunchEvent() {
        appEventQueue.async {
            do {
                    // Adding a 1-second delay before processing the launch event
                      DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                          do {
                              // Perform the operation after the delay
                              // Wait for the install event to complete before launching (if you have a semaphore, you can use it)
                              // self.installEventSemaphore.wait()

                              if !AppConstantsMergn.shared.isAppLaunch {
                                  AppConstantsMergn.shared.isAppLaunch = true
                                  print("App Launched Successfully")
                                  self.sendEvent(eventName: EventNames.appLaunched.rawValue, properties: [:])
                              }
                          } catch {
                              // Catch any error that occurred during the event handling and handle it
                              print("Error in app launch event handling: \(error.localizedDescription)")
                          }
                      }

            } catch {
                // Catch any error that occurred and handle it
                print("Error adding app launch event: \(error.localizedDescription)")
            }
        }
    }

    final class TokenManager {
        static let shared = TokenManager()

        private init() {} // Prevent external initialization

        var authToken: String?
    }




}
