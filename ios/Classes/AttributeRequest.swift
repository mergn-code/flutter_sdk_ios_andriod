//
//  AttributeRequest.swift
//  mergn_ios
//
//  Created by Syed Hamza Hassan - Mergn on 15/11/2024.
//

import Foundation



// Define the AttributeRequest class with nested AttributeProperty struct
struct AttributeRequestModel: Codable {
    
    // MARK: - Nested AttributeProperty Struct
    struct AttributeProperty: Codable {
        let eventPropertyId: Int
        let value: String
    }
    
    // MARK: - Properties for AttributeRequest
    struct AttributeRequest: Codable{
        let customerId: String
        let attributeId: Int
        let value: String
    }
    
}
