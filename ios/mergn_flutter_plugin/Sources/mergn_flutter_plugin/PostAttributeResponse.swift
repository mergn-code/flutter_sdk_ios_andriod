//
//  PostAttributeResponse.swift
//  mergn_ios
//
//  Created by Syed Hamza Hassan - Mergn on 15/11/2024.
//

import Foundation

// Swift struct equivalent of the Kotlin PostAttributeResponse
struct PostAttributeResponse: Codable {
    let success: Bool
    let message: String?
    let data: String?
}
