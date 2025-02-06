//
//  NetworkManager.swift
//  mergn_ios
//
//  Created by Syed Hamza Hassan - Mergn on 06/11/2024.
//

import Foundation

// Define HTTP methods for the network requests
enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
}

// Define an enum for network errors
enum NetworkError: Error {
    case invalidURL
    case noData
    case badResponse(statusCode: Int)
    case decodingError
    case requestFailed(Error)
    case unknownError
}

class NetworkManager {
    

}
