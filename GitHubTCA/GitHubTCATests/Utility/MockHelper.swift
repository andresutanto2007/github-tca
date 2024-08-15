//
//  MockHelper.swift
//  GitHubTCATests
//
//  Created by Andre on 2024/08/14.
//

import Foundation
import NetworkKit

enum MockHelperError: Error {
    case fileNotFound
}

protocol MockItem {
    var fileName: String { get }
    var urlResponse: URLResponse { get }
    var extensionName: String { get }
}

final class MockHelper {
    static func buildNetworkResponse<T: Decodable>(with item: MockItem) throws -> NetworkResponse<T> {
        guard let fileURL = Bundle.current.url(forResource: item.fileName, withExtension: item.extensionName) else {
            throw MockHelperError.fileNotFound
        }
        let responseBody = try Data(contentsOf: fileURL)
        return try NetworkResponse(data: responseBody, response: item.urlResponse)
    }
}
