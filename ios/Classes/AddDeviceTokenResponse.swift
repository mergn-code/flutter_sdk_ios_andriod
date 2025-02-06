//
//  AddDeviceTokenResponse.swift
//  mergn_ios
//
//  Created by Syed Hamza Hassan on 22/01/2025.
//

import Foundation

// This struct represents the response containing the success status, message, and the data object.
struct AddDeviceTokenResponse: Codable {
    var success: Bool
    var message: String
    var data: DataToken
}

// This struct represents the Data object inside the response, which contains a message.
struct DataToken: Codable {
    var message: String
}
