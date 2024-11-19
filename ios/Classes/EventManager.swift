//
//  EventManager.swift
//  mergn_ios
//
//  Created by Syed Hamza Hassan - Mergn on 05/11/2024.
//

import Foundation
import UIKit

public class EventManager {
    
    private let identifierKey = "com.example.uniqueIdentifier"
    private let customerMergnKey = "customer_mergn_key"
    public  let apiMergnKey = "api_mergn_key"
    
    // Static shared instance
       public static let shared = EventManager()
       
    
       
       // Private initializer to prevent external instantiation
       private init() {
           // You can set up default values or load configurations here
           print("EventManager initialized")
       }
   
    var eventsList: [String : Event] = [:]
    //var attributesList: [Attribute] = []

    
    //static let shared = EventManager()
    
    //private init() {} // Private init to prevent creating instances
    
    // Generate or retrieve a unique identifier
    public func registerAPI(clientApiKey: String) {
       
        let apiKey = clientApiKey
        UserDefaults.standard.set(apiKey, forKey: apiMergnKey)
        
        postIdentification()
      
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
    
    // Method to add an event
    func addAttribute(_ name: String, _ attribute: AttributeListResponse.Attribute) {
        attributeMap[name] = attribute
    }
    
    // Method to get an event by name
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
    
    public func getCustomerId() -> String {
        if let saveCustomerId = UserDefaults.standard.string(forKey: customerMergnKey) {
            return saveCustomerId
        }
        return ""
    }
    
    public func getEventList(){
        NetworkManager.shared.getEventList { result in
            switch result {
            case .success(let eventList):
                //print("Event List: \(eventList)")
                
                for eventData in eventList.data {
                    EventManager.shared.addEvent(eventData.key,eventData.value)
                    
                }
                //print("Event Name : \(EventManager.shared.getEvent(byName : "User_Profile_Clicked")?.eventProperty)")
                
                // Safe unwrapping and looping over the dictionary
                if let properties = EventManager.shared.getEvent(byName : "User_Profile_Clicked")?.eventProperty {
                    // Loop through the dictionary and print each key and its corresponding EventProperty
                    /*for (key, property) in properties {
                        if(property.name == "operating-system"){
                            print("Key: \(key), Name: \(property.name), ID: \(property.id), Data Type: \(property.data_type)")}
                    }*/
                } else {
                    print("Event properties are nil.")
                }
                    print("getEventList Success")
                if(self.attributeMap.isEmpty){
                    self.getAttributeList()}
                
            case .failure(let error):
                print("Error fetching event list: \(error)")
                
            }
        }
    }
    
    public func getAttributeList(){
        NetworkManager.shared.getAttributeList { result in
            switch result {
            case .success(let attributeList):
               // print("Attribute List: \(attributeList)")
                print("getAttributeList Success")
                for attributeData in attributeList.data {
                    EventManager.shared.addAttribute(attributeData.key,attributeData.value)
                    
                }
               // attributesList = attributeList
            case .failure(let error):
                print("Error fetching attribute list: \(error)")
            }
        }
    }
    
    // Static method for posting identification
        public func postIdentification(identity: String? = nil) {
            // Call NetworkManager's postIdentification method
            var requestBody = SetIdentificationRequest(deviceId: getUniqueIdentifier(), os: "IOS")
            
            // Check if identity is not nil or empty
                    if let identity = identity, !identity.isEmpty {
                        // Print the valid identity value
                        requestBody = SetIdentificationRequest(deviceId: getUniqueIdentifier(), os: "IOS", identity: identity)
                    }
            
            NetworkManager.shared.postIdentification(requestBody: requestBody) { result in
                switch result {
                case .success(let response):
                    // Handle success response
                    print("Post Identification Successful: \(response.data)")
                    self.saveCustomerId(customerId :String(response.data))
                    if(self.eventMap.isEmpty){
                        self.getEventList()}
                    // Optionally, you can process the response or update the UI on the main thread here
                    DispatchQueue.main.async {
                        // Update UI or handle success logic
                        // Example: self.someLabel.text = response.message
                    }
                    
                case .failure(let error):
                    // Handle failure
                    print("Error posting identification: \(error)")
                    print("POST Request : \(requestBody)")
                    // Optionally, you can handle failure logic or show an error to the user
                    DispatchQueue.main.async {
                        // Show an error message or handle failure scenario
                    }
                }
            }
        }
    
    public  func sendEvent(eventName: String, properties: [String: Any]) {
        if(eventMap.isEmpty){
            getEventList()
            return
        }
        if(eventMap.keys.contains(eventName)){
            var eventDetails = EventManager.shared.getEvent(byName : eventName)
            var eventId: Int = eventDetails?.id ?? 0
            var name: String? = eventDetails?.name
            var eventProperties: [EventRequestModel.EventProperty] = []
            
            if let propertiesEvent = eventDetails?.eventProperty {
                // Loop through the dictionary and print each key and its corresponding EventProperty
                for (key, property) in propertiesEvent {
                    if(properties.keys.contains(property.name)){
                        var newEventProperty = EventRequestModel.EventProperty(eventPropertyId: property.id, value: properties[property.name] as? String ?? "")
                        eventProperties.append(newEventProperty)
                        print("Event Properties: \(eventProperties)")
                              
                              }
                }
                  if(propertiesEvent.keys.contains("Platform")){

                                    var newEventProperty = EventRequestModel.EventProperty(eventPropertyId: propertiesEvent["Platform"]?.id ?? 0, value: "iOS" as? String ?? "")
                                    eventProperties.append(newEventProperty)
                                    print("Event Properties: \(eventProperties)")

                                          }
            }
            var eventModel = EventRequestModel.Event(
                eventId:eventId,
                eventProperties:eventProperties,
                sessionId:"aaa-bbbb-vvvv-111-3213"
)
            var eventModelList : [EventRequestModel.Event] = []
            eventModelList.append(eventModel)
            
            var eventRquestModel = EventRequestModel.EventRequest(
                customerId: getCustomerId(),
                deviceId: getUniqueIdentifier(),
                events : eventModelList)
            
            postEventToServer(eventRequestModel:eventRquestModel)
            
            
        }
        

    
    }
    
    // Static method for posting identification
        func postEventToServer(eventRequestModel: EventRequestModel.EventRequest) {
            // Call NetworkManager's postIdentification method
            var requestBody = eventRequestModel
        
            
            NetworkManager.shared.recordEvent(requestBody: requestBody) { result in
                switch result {
                case .success(let response):
                    // Handle success response
                    print("Post Identification Successful: \(response.data)")
                   
                    // Optionally, you can process the response or update the UI on the main thread here
                    DispatchQueue.main.async {
                        // Update UI or handle success logic
                        // Example: self.someLabel.text = response.message
                    }
                    
                case .failure(let error):
                    // Handle failure
                    print("Error posting identification: \(error)")
                    print("POST Request : \(requestBody)")
                    // Optionally, you can handle failure logic or show an error to the user
                    DispatchQueue.main.async {
                        // Show an error message or handle failure scenario
                    }
                }
            }
        }
    
    public  func sendAttribute(attributeName: String, attributeValue: String) {
        if(attributeMap.isEmpty){
            getAttributeList()
            return
        }
        if(attributeMap.keys.contains(attributeName)){
            var attributeRequestModel = AttributeRequestModel.AttributeRequest(
                customerId: getCustomerId(),
                attributeId: EventManager.shared.getAttribute(byName: attributeName)?.id ?? 0,
                value: attributeValue)
            
            postAttributeToServer(attributeRequestModel:attributeRequestModel)
        }
        
    }
    
    // Static method for posting identification
    func postAttributeToServer(attributeRequestModel: AttributeRequestModel.AttributeRequest) {
            // Call NetworkManager's postIdentification method
            var requestBody = attributeRequestModel
        
            
            NetworkManager.shared.recordAttribute(requestBody: requestBody) { result in
                switch result {
                case .success(let response):
                    // Handle success response
                    print("Attribute Successfully Captured: \(response.data)")
                   
                    // Optionally, you can process the response or update the UI on the main thread here
                    DispatchQueue.main.async {
                        // Update UI or handle success logic
                        // Example: self.someLabel.text = response.message
                    }
                    
                case .failure(let error):
                    // Handle failure
                    print("Error posting Attribute: \(error)")
                    print("POST Request : \(requestBody)")
                    // Optionally, you can handle failure logic or show an error to the user
                    DispatchQueue.main.async {
                        // Show an error message or handle failure scenario
                    }
                }
            }
        }
    
    
}
