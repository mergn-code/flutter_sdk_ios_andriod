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
        var value: String? = nil
        var isParse: Bool? = false
    }

    // MARK: - Event
    struct Event: Codable {
        let eventId: Int
        let eventProperties: [EventProperty]
        let sessionId: String
        var campaignCustomerInstanceId: String? = nil
        var campaignId: String? = nil
        var name: String? = nil
        var isParse: Bool? = false
    }

    // MARK: - EventRequest
    struct EventRequest: Codable {
        let customerId: String
        let deviceId: String
        let events: [Event]
    }

}

