//
//  AddEventResponse.swift
//  mergn_ios
//
//  Created by Syed Hamza Hassan - Mergn on 15/11/2024.
//

import Foundation

// MARK: - AddEventResponse
struct AddEventResponse: Codable {
    let success: Bool
    let message: String
    let data: Campaigns
}

// MARK: - Campaigns
struct Campaigns: Codable {
    let campaigns: [Campaign]
}

// MARK: - Campaign
struct Campaign: Codable {
    let message: Message
    let campaignId: Int
    let campaignEntryTime: String
    //let campaignEntryTimeValue: String?
    let campaignCustomerInstanceId: Int
}

// MARK: - Message
struct Message: Codable {
    let name: String
    let design: String
}
