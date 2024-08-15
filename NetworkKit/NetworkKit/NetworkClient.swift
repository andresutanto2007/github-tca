//
//  NetworkClient.swift
//  NetworkKit
//
//  Created by Andre on 2024/08/14.
//

import Foundation

protocol NetworkClient {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}
