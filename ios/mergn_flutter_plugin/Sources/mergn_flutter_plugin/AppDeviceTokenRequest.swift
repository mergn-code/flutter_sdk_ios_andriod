//
//  AppDeviceTokenRequest.swift
//  mergn_ios
//
//  Created by Syed Hamza Hassan on 22/01/2025.
//

import Foundation

// This struct will represent the AppDeviceTokenRequest, which contains the device information and push token.
struct AppDeviceTokenRequest: Codable {
    var device_id: String
    var is_app_push_subscribed: Bool
    var device_platform: String
    var app_push_token: AppPushToken
}

// This struct will represent the AppPushToken containing the token string.
struct AppPushToken: Codable {
    var token: String
}
