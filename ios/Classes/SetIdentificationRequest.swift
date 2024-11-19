//
//  SetIdentificationRequest.swift
//  mergn_ios
//
//  Created by Syed Hamza Hassan - Mergn on 13/11/2024.
//

import Foundation

// Unified class to handle both SetIdentificationRequest and SetIdentificationRequestForLogin
class SetIdentificationRequest: Codable {
    var deviceId: String
    var os: String
    var identity: String?  // Optional identity field

    // Initializer for SetIdentificationRequest (without identity)
    init(deviceId: String, os: String) {
        self.deviceId = deviceId
        self.os = os
        self.identity = nil
    }
    
    // Initializer for SetIdentificationRequestForLogin (with identity)
    init(deviceId: String, os: String, identity: String) {
        self.deviceId = deviceId
        self.os = os
        self.identity = identity
    }
}
