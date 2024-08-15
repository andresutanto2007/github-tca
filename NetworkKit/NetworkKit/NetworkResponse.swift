//
//  NetworkResponse.swift
//  NetworkKit
//
//  Created by Andre on 2024/08/14.
//

import Foundation

public struct NetworkResponse<T: Decodable> {
    public var body: T
    public var header: [AnyHashable: Any]
    
    public init(data: Data, response: URLResponse) throws {
        do {
            let body = try JSONDecoder().decode(T.self, from: data)
            self.init(body: body, response: response)
        } catch let error {
            throw NetworkKitError.invalidJSON(error)
        }
    }
    
    public init(body: T, response: URLResponse) {
        self.body = body
        if let httpUrlResponse = response as? HTTPURLResponse {
            header = httpUrlResponse.allHeaderFields
        } else {
            header = [:]
        }
    }
}
