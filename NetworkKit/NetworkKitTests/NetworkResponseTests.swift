//
//  NetworkResponseTests.swift
//  NetworkKitTests
//
//  Created by Andre on 2024/08/14.
//

import Foundation
import XCTest
import NetworkKit

final class NetworkResponseTests: XCTestCase {
    
    func testInitWithInvalidJSONData() {
        do {
            let _ = try NetworkResponse<SampleDecodable>(data: Data(), response: URLResponse())
            XCTFail("Should throw error")
        } catch let error {
            guard case NetworkKitError.invalidJSON = error else {
                XCTFail("Should throw NetworkKitError.invalidJSON")
                return
            }
        }
    }
    
    func testInitWithValidJSONData() {
        let jsonData = "{\"id\":1}".data(using: .utf8)!
        let response = try! NetworkResponse<SampleDecodable>(data: jsonData, response: URLResponse())
        XCTAssertEqual(response.body.id, 1)
    }
    
    func testInitWithDecodable() {
        let response = NetworkResponse(body: SampleDecodable(id: 1), response: URLResponse())
        XCTAssertEqual(response.body.id, 1)
    }
}

extension NetworkResponseTests {
    private struct SampleDecodable: Decodable {
        let id: Int
    }
}
