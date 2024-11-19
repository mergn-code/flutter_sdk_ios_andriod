//
//  AttributeListResponse.swift
//  mergn_ios
//
//  Created by Syed Hamza Hassan - Mergn on 06/11/2024.
//

// Define a single class to handle both Attribute and AttributeListResponse in one
struct AttributeListResponse: Codable {
    let success: Bool
    let message: String
    let data: [String: Attribute]  // A map of attribute names to Attribute objects

    // Nested struct for individual attributes
    struct Attribute: Codable {
        let id: Int
        let name: String
        let attributeProperty: [String: String]  // Using [String: Any] for simplicity

        // Custom decoding to handle `Any` type for attributeProperty
        enum CodingKeys: String, CodingKey {
            case id
            case name
            case attributeProperty = "attribute_property"  // Adjust if needed
        }

        // Custom initializer for decoding attributeProperty as [String: Any]
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            id = try container.decode(Int.self, forKey: .id)
            name = try container.decode(String.self, forKey: .name)

            // Try decoding attributeProperty as a dictionary of [String: String] or [String: Int]
            if let attributePropertyData = try? container.decode([String: String].self, forKey: .attributeProperty) {
                attributeProperty = attributePropertyData as [String: String]
            } else if let attributePropertyData = try? container.decode([String: String].self, forKey: .attributeProperty) {
                attributeProperty = attributePropertyData as [String: String]
            } else {
                attributeProperty = [:]  // Default to empty dictionary if decoding fails
            }
        }
    }
}

