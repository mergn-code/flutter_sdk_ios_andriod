//
//  EventListResponse.swift
//  mergn_ios
//
//  Created by Syed Hamza Hassan - Mergn on 06/11/2024.
//

import Foundation

// MARK: - EventListResponse
struct EventListResponse: Codable {
    let success: Bool
    let message: String
    let data: [String: Event]
}

// MARK: - Event
struct Event: Codable {
    let id: Int
    let name: String
    let eventProperty: [String: EventProperty]
}

// MARK: - EventProperty
struct EventProperty: Codable {
    let id: Int
    let name: String
    let data_type: String
}




