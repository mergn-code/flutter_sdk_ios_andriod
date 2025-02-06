import Foundation
import UIKit
import UserNotifications

public class EventManager {
    
    private let identifierKey = "com.example.uniqueIdentifier"
    private let customerMergnKey = "customer_mergn_key"
    public let apiMergnKey = "api_mergn_key"
    private var uiViewController: UIViewController?
    private var campaing: Campaigns = Campaigns(campaigns: [])
    private var campaignId = ""
    private var campaignInstanceId = ""
    private let firebaseTokenMergn = "mergn_firebase_token"

    // Static shared instance
    public static let shared = EventManager()

    private init() {
        print("EventManager initialized")
    }

    var eventMap: [String: Event] = [:]
    var attributeMap: [String: AttributeListResponse.Attribute] = [:]

    public func registerAPI(clientApiKey: String) {
        UserDefaults.standard.set(clientApiKey, forKey: apiMergnKey)
        Task {
            await postIdentification()
        }
    }

    func addEvent(_ name: String, _ event: Event) {
        eventMap[name] = event
    }

    func getEvent(byName name: String) -> Event? {
        return eventMap[name]
    }

    func addAttribute(_ name: String, _ attribute: AttributeListResponse.Attribute) {
        attributeMap[name] = attribute
    }

    func getAttribute(byName name: String) -> AttributeListResponse.Attribute? {
        return attributeMap[name]
    }

    public func getUniqueIdentifier() -> String {
        if let savedIdentifier = UserDefaults.standard.string(forKey: identifierKey) {
            return savedIdentifier
        } else {
            let newIdentifier = UUID().uuidString
            UserDefaults.standard.set(newIdentifier, forKey: identifierKey)
            return newIdentifier
        }
    }

    public func saveCustomerId(customerId: String) {
        UserDefaults.standard.set(customerId, forKey: customerMergnKey)
    }

    public func saveFirebaseToken(token: String) {
        guard !token.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            print("Invalid token: Token is empty")
            return
        }
        UserDefaults.standard.set(token, forKey: firebaseTokenMergn)
    }

    public func getCustomerId() -> String {
        return UserDefaults.standard.string(forKey: customerMergnKey) ?? ""
    }

    public func getFirebaseToken() -> String {
        return UserDefaults.standard.string(forKey: firebaseTokenMergn) ?? ""
    }

    public func getEventList() async {
        do {
            let eventList = try await NetworkManager.shared.getEventList()
            for eventData in eventList.data {
                addEvent(eventData.key, eventData.value)
            }
            if attributeMap.isEmpty {
                await getAttributeList()
            }
        } catch {
            print("Error fetching event list: \(error)")
        }
    }

    public func getAttributeList() async {
        do {
            let attributeList = try await NetworkManager.shared.getAttributeList()
            if attributeList.data.isEmpty {
                print("Error: No attribute data available.")
                return
            }
            for attributeData in attributeList.data {
                addAttribute(attributeData.key, attributeData.value)
            }
        } catch {
            print("Error fetching attribute list: \(error)")
        }
    }

    public func postIdentification(identity: String? = nil) async {
        guard let identity = identity, !identity.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            print("Identity should not be empty")
            return
        }

        let requestBody = SetIdentificationRequest(
            deviceId: getUniqueIdentifier(),
            os: "iOS",
            identity: identity
        )

        do {
            let response = try await NetworkManager.shared.postIdentification(requestBody: requestBody)
            print("Post Identification Successful: \(response.data)")
            saveCustomerId(customerId: String(response.data))

            if eventMap.isEmpty {
                await getEventList()
            }
        } catch {
            print("Error posting identification: \(error)")
        }
    }


    public func sendEvent(eventName: String, properties: [String: Any]) async {
        guard !eventMap.isEmpty else {
            await getEventList()
            return
        }

        guard let eventDetails = getEvent(byName: eventName) else { return }
        var eventProperties: [EventRequestModel.EventProperty] = []

        for (key, property) in eventDetails.eventProperty {
            if let value = properties[property.name] as? String {
                eventProperties.append(EventRequestModel.EventProperty(eventPropertyId: property.id, value: value))
            }
        }

        eventProperties.append(contentsOf: [
            EventRequestModel.EventProperty(eventPropertyId: eventDetails.eventProperty["Platform"]?.id ?? 0, value: "iOS"),
            EventRequestModel.EventProperty(eventPropertyId: eventDetails.eventProperty["sdk-version"]?.id ?? 0, value: "2")
        ])

        let eventModel = EventRequestModel.Event(
            eventId: eventDetails.id,
            eventProperties: eventProperties,
            sessionId: getUniqueIdentifier()
        )

        let eventRequestModel = EventRequestModel.EventRequest(
            customerId: getCustomerId(),
            deviceId: getUniqueIdentifier(),
            events: [eventModel]
        )

        await postEventToServer(eventRequestModel: eventRequestModel)
    }

    func postEventToServer(eventRequestModel: EventRequestModel.EventRequest) async {
        do {
            let response = try await NetworkManager.shared.recordEvent(requestBody: eventRequestModel)
            print("Post Record Event Successful: \(response.data)")
            campaing = response.data
            if let currentVC = SDKManager.shared.getCurrentViewController(), !campaing.campaigns.isEmpty {
                campaignId = String(campaing.campaigns.first?.campaignId ?? 0)
                campaignInstanceId = campaing.campaigns.first?.campaignCustomerInstanceId ?? ""
                await openWebView(from: currentVC, htmlString: campaing.campaigns.first?.message?.design ?? "")
            }
        } catch {
            print("Error posting event: \(error)")
        }
    }

    public func openWebView(from parentViewController: UIViewController, htmlString: String) async {
        let webViewController = WebViewController()
        if !campaing.campaigns.isEmpty {
            webViewController.loadHTML(campaing.campaigns.first?.message?.design ?? "")
        }
        uiViewController = parentViewController
        parentViewController.present(webViewController, animated: true, completion: nil)
    }

    public func firebaseToken(token: String) {
        saveFirebaseToken(token: token)
        guard !token.isEmpty else { return }
        Task {
            await postDeviceToken()
        }
    }

    func postDeviceToken() async {
        let appToken = AppPushToken(token: getFirebaseToken())
        let requestBody = AppDeviceTokenRequest(
            device_id: getUniqueIdentifier(),
            is_app_push_subscribed: true,
            device_platform: "app_ios",
            app_push_token: appToken
        )
        do {
            let response = try await NetworkManager.shared.postToken(requestBody: requestBody)
            print("Token Successfully Captured: \(response.data)")
        } catch {
            print("Error posting token: \(error)")
        }
    }
}
