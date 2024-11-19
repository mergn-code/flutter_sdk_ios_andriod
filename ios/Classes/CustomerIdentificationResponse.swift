//
//  CustomerIdentificationResponse.swift
//  mergn_ios
//
//  Created by Syed Hamza Hassan - Mergn on 13/11/2024.
//

import Foundation


struct CustomerIdentificationResponse: Codable {
    var success: Bool
    var message: String
    var data: Int
    
    // Initializer is automatically synthesized by Swift for structs,
    // so you can omit it unless you need to customize the initialization.
}
