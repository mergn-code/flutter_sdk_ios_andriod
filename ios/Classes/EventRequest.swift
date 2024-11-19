//
//  EventRequest.swift
//  mergn_ios
//
//  Created by Syed Hamza Hassan - Mergn on 15/11/2024.
//

import Foundation

struct EventRequestModel{
    // MARK: - EventProperty
    struct EventProperty: Codable {
        let eventPropertyId: Int
        let value: String
    }
    
    // MARK: - Event
    struct Event: Codable {
        let eventId: Int
        let eventProperties: [EventProperty]
        let sessionId: String
        let campaignCustomerInstanceId: String? = nil
        let campaignId: String? = nil
        let name: String? = nil
    }
    
    // MARK: - EventRequest
    struct EventRequest: Codable {
        let customerId: String
        let deviceId: String
        let events: [Event]
    }
    
}
