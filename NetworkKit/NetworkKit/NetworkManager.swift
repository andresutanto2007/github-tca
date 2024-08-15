//
//  NetworkManager.swift
//  NetworkKit
//
//  Created by Andre on 2024/08/14.
//

import Foundation

final public class NetworkManager {
    
    private static let defaultClient = DefaultNetworkClient()
    
    public static func request<T: Decodable>(
        _ networkRequest: NetworkRequest
    ) async throws -> NetworkResponse<T> {
        return try await Self.request(client: defaultClient, request: networkRequest)
    }
    
    static func request<T: Decodable>(
        client: NetworkClient,
        request: NetworkRequest
    ) async throws -> NetworkResponse<T> {
        do {
            let (data, response) = try await client.data(for: try request.build())
            if let httpResponse = response as? HTTPURLResponse {
                switch httpResponse.statusCode {
                case 200...299:
                    return try NetworkResponse(data: data, response: response)
                case 401:
                    throw NetworkKitError.invalidCredentials
                case 403, 429, 503:
                    throw NetworkKitError.serverError
                default:
                    throw NetworkKitError.unknownError
                }
            }
            return try NetworkResponse(data: data, response: response)
        } catch let error {
            throw error
        }
    }
}

extension NetworkManager {
    private final class DefaultNetworkClient: NetworkClient {
        func data(for request: URLRequest) async throws -> (Data, URLResponse) {
            return try await URLSession.shared.data(for: request)
        }
    }
}
