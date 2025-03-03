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
   // private let baseURL = "https://devapi.mergn.com/sdk-management/api/"  // Replace with your API base URL

    // Method to create headers for the API requests
    private func createHeaders() -> [String: String] {
        return [
            "Content-Type": "application/json"
        ]
    }

    // A helper function to perform a network request
    private func request<T: Codable>(endpoint: String, method: HTTPMethod, body: Data? = nil, responseType: T.Type, completion: @escaping (Result<T, NetworkError>) -> Void) {

        do {
            // Construct the full URL
            guard let url = URL(string: "\(baseURL)\(endpoint)") else {
                completion(.failure(.invalidURL))
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = method.rawValue
            request.allHTTPHeaderFields = createHeaders()
            print(request.allHTTPHeaderFields)

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
                    let decoder = JSONDecoder()
                    let decodedResponse = try decoder.decode(T.self, from: data)
                  //  print("Network Layer Decode Response \(decodedResponse)")
                    completion(.success(decodedResponse))
                } catch {
                    completion(.failure(.decodingError))
                    print("Decoding Error: \(error)")
                }
            }

            task.resume()
        } catch {
            completion(.failure(.unknownError))  // Catch any unexpected errors
            print("Unexpected error occurred: \(error)")
        }
    }

   }
