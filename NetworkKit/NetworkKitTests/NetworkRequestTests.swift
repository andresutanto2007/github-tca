//
//  NetworkRequestTests.swift
//  NetworkKitTests
//
//  Created by Andre on 2024/08/14.
//

import Foundation
import XCTest
@testable import NetworkKit

final class NetworkRequestTests: XCTestCase {
    
    func testBuild() {
        let httpBody = Data()
        
        let urlRequest = try! NetworkRequest(
            url: "https://test.com", httpMethod: .get,
            header: ["k1": "v1", "k2": "v2"],
            queryParameter: ["q1": "v1", "q2": "v2"],
            dataBody: httpBody
        ).build()
        
        XCTAssertEqual(urlRequest.url, URL(string: "https://test.com?q1=v1&q2=v2"))
        XCTAssertEqual(urlRequest.httpMethod, "GET")
        XCTAssertEqual(urlRequest.httpBody, httpBody)
        XCTAssertEqual(urlRequest.allHTTPHeaderFields, ["k1": "v1", "k2": "v2"])
    }
    
    func testBuildMergeQueryParameter() {
        let urlRequest = try! NetworkRequest(
            url: "https://test.com?q3=v3", httpMethod: .get,
            queryParameter: ["q1": "v1", "q2": "v2"]
        ).build()
        
        XCTAssertEqual(urlRequest.url, URL(string: "https://test.com?q3=v3&q1=v1&q2=v2"))
    }
    
    func testBuildDuplicateQueryParameter() {
        let urlRequest = try! NetworkRequest(
            url: "https://test.com?q1=v5", httpMethod: .get,
            queryParameter: ["q1": "v1", "q2": "v2"]
        ).build()
        
        XCTAssertEqual(urlRequest.url, URL(string: "https://test.com?q1=v1&q2=v2"))
    }
    
    func testBuildEncodable() {
        let jsonBody = SampleEncodable(id: 1)
        let urlRequest = try! NetworkRequest(url: "", httpMethod: .get, jsonBody: jsonBody).build()
        XCTAssertNotNil(urlRequest.httpBody)
    }
    
    func testBuildInvalidUrl() {
        do {
            let _ = try NetworkRequest(url: "http://example.com:-80/", httpMethod: .get).build()
            XCTFail("Should throw error")
        } catch let error {
            guard case NetworkKitError.invalidUrl = error else {
                XCTFail("Should throw invalid url")
                return
            }
        }
    }
    
    func testHttpMethodRawValue() {
        XCTAssertEqual(NetworkRequest.HTTPMethod.get.rawValue, "GET")
        XCTAssertEqual(NetworkRequest.HTTPMethod.post.rawValue, "POST")
    }
}

extension NetworkRequestTests {
    private struct SampleEncodable: Encodable {
        let id: Int
    }
}
