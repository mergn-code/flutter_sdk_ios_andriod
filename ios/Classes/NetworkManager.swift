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
    
    static let shared = NetworkManager()  // Singleton instance
    
    private let session = URLSession.shared
    private let baseURL = "https://api.mergn.com/sdk-management/api/"  // Replace with your API base URL
    
    // Method to create headers for the API requests
    private func createHeaders() -> [String: String] {
        return [
            "authorization": UserDefaults.standard.string(forKey: EventManager.shared.apiMergnKey) ?? "default_api_key",  // Replace with actual token // Hard corded
            "Content-Type": "application/json"
        ]
    }
    
    // A helper function to perform a network request
    private func request<T: Codable>(endpoint: String, method: HTTPMethod, body: Data? = nil, responseType: T.Type, completion: @escaping (Result<T, NetworkError>) -> Void) {
        
        // Construct the full URL
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = createHeaders()
        
        // Add the body data if provided (for POST/PUT requests)
        if let body = body {
            request.httpBody = body
        }
        
        // Create a data task to perform the request
        let task = session.dataTask(with: request) { data, response, error in
            // Handle network errors
            if let error = error {
                completion(.failure(.requestFailed(error)))
                return
            }
            
            // Check if there is data in the response
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            
            // Check for a valid response status code (200 or 201 for success)
                    if let httpResponse = response as? HTTPURLResponse {
                        let statusCode = httpResponse.statusCode
                        if statusCode != 200 && statusCode != 201 {
                            completion(.failure(.badResponse(statusCode: statusCode)))
                            return
                        }
                    }
            
            // Decode the response data
            do {
                //print("Post Identification Successful: \(data)")
                let decoder = JSONDecoder()
                let decodedResponse = try decoder.decode(T.self, from: data)
                completion(.success(decodedResponse))
            } catch {
                completion(.failure(.decodingError))
            }
        }
        
        task.resume()
    }
   
    func getEventList(completion: @escaping (Result<EventListResponse, NetworkError>) -> Void) {
            request(endpoint: "event", method: .get, responseType: EventListResponse.self, completion: completion)
        }
    
    func getAttributeList(completion: @escaping (Result<AttributeListResponse, NetworkError>) -> Void) {
            request(endpoint: "attribute", method: .get, responseType: AttributeListResponse.self, completion: completion)
        }
    
    func postIdentification(requestBody: SetIdentificationRequest, completion: @escaping (Result<CustomerIdentificationResponse, NetworkError>) -> Void) {
        // Encode the request body
        do {
            let encoder = JSONEncoder()
            let jsonData = try encoder.encode(requestBody)
            
            // Perform the network request using the generic helper function
            request(endpoint: "customer/set-identity", method: .post, body: jsonData, responseType: CustomerIdentificationResponse.self) { result in
                switch result {
                case .success(let response):
                    completion(.success(response))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } catch {
            completion(.failure(.decodingError))  // Handle encoding error
        }
    }
    
    func recordEvent(requestBody: EventRequestModel.EventRequest, completion: @escaping (Result<AddEventResponse, NetworkError>) -> Void) {
        // Encode the request body
        do {
            let encoder = JSONEncoder()
            let jsonData = try encoder.encode(requestBody)
            
            // Perform the network request using the generic helper function
            request(endpoint: "v2/event/record-event", method: .post, body: jsonData, responseType: AddEventResponse.self) { result in
                switch result {
                case .success(let response):
                    completion(.success(response))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } catch {
            completion(.failure(.decodingError))  // Handle encoding error
        }
    }
    
    func recordAttribute(requestBody: AttributeRequestModel.AttributeRequest, completion: @escaping (Result<PostAttributeResponse, NetworkError>) -> Void) {
        // Encode the request body
        do {
            let encoder = JSONEncoder()
            let jsonData = try encoder.encode(requestBody)
            
            // Perform the network request using the generic helper function
            request(endpoint: "attribute/set-attribute", method: .post, body: jsonData, responseType: PostAttributeResponse.self) { result in
                switch result {
                case .success(let response):
                    completion(.success(response))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } catch {
            completion(.failure(.decodingError))  // Handle encoding error
        }
    }
    
}
    
   
    


