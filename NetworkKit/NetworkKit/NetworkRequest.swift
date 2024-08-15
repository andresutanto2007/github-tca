//
//  NetworkRequest.swift
//  NetworkKit
//
//  Created by Andre on 2024/08/14.
//

import Foundation

public struct NetworkRequest {
    public enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
    }
    
    private let url: String
    private let httpMethod: HTTPMethod
    private let queryParameter: [String: String]
    private let httpBody: Data?
    private let httpHeader: [String: String]
    
    public init(
        url: String, httpMethod: HTTPMethod,
        header: [String: String] = [:],
        queryParameter: [String: String] = [:],
        dataBody: Data? = nil
    ) {
        self.url = url
        self.httpMethod = httpMethod
        self.queryParameter = queryParameter
        self.httpHeader = header
        self.httpBody = dataBody
    }
    
    public init<T: Encodable>(
        url: String, httpMethod: HTTPMethod,
        header: [String: String] = [:],
        queryParameter: [String: String] = [:],
        jsonBody: T
    ) throws {
        do {
            let requestBody = try JSONEncoder().encode(jsonBody)
            self.init(url: url, httpMethod: httpMethod, header: header, queryParameter: queryParameter, dataBody: requestBody)
        }
        catch let error {
            throw NetworkKitError.invalidJSON(error)
        }
    }
    
    func build() throws -> URLRequest {
        var urlRequest = URLRequest(url: try constructURL(url: url, queryParameter: queryParameter))
        urlRequest.httpBody = httpBody
        urlRequest.allHTTPHeaderFields = httpHeader
        return urlRequest
    }
    
    private func constructURL(url: String, queryParameter: [String: String]) throws -> URL {
        guard var urlComponents = URLComponents(string: url) else {
            throw NetworkKitError.invalidUrl
        }
        
        var newQueryItems = urlComponents.queryItems ?? []
        for query in queryParameter.sorted(by: { $0.key < $1.key }) {
            newQueryItems.removeAll(where: {$0.name == query.key})
            newQueryItems.append(URLQueryItem(name: query.key, value: query.value))
        }
        urlComponents.queryItems = newQueryItems
        
        guard let url = urlComponents.url else {
            throw NetworkKitError.invalidUrl
        }
        return url
    }
}
