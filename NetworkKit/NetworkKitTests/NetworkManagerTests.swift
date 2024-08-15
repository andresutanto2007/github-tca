//
//  NetworkManagerTests.swift
//  NetworkKitTests
//
//  Created by Andre on 2024/08/14.
//

import Foundation
import XCTest
@testable import NetworkKit

final class NetworkManagerTests: XCTestCase {
    
    func testSuccessRequest() async {
        let mockNetworkClient = MockNetworkClient()
        let httpUrlResponse = HTTPURLResponse(
            url: URL(string: "example")!, statusCode: 200,
            httpVersion: nil, headerFields: nil
        )!
        let jsonData = "{\"id\":1}".data(using: .utf8)
        mockNetworkClient.networkResult = .success((jsonData!, httpUrlResponse))
        let request = NetworkRequest(url: "example", httpMethod: .get)
        let response: NetworkResponse<SampleResponse> = try! await NetworkManager.request(client: mockNetworkClient, request: request)
        XCTAssertNotNil(response.body)
    }
    
    func testThrowInvalidCredentials() async {
        let mockNetworkClient = MockNetworkClient()
        let httpUrlResponse = HTTPURLResponse(
            url: URL(string: "example")!, statusCode: 401,
            httpVersion: nil, headerFields: nil
        )!
        mockNetworkClient.networkResult = .success((Data(), httpUrlResponse))
        let request = NetworkRequest(url: "example", httpMethod: .get)
        do {
            let _: NetworkResponse<SampleResponse> = try await NetworkManager.request(client: mockNetworkClient, request: request)
            XCTFail("Should throw error")
        } catch let error {
            guard case NetworkKitError.invalidCredentials = error else {
                XCTFail("Should throw invalid credentials")
                return
            }
        }
    }
    
    func testThrowServerError() async {
        let mockNetworkClient = MockNetworkClient()
        let statusCodes: [Int] = [403, 429, 503]
        
        for statusCode in statusCodes {
            let httpUrlResponse = HTTPURLResponse(
                url: URL(string: "example")!, statusCode: statusCode,
                httpVersion: nil, headerFields: nil
            )!
            mockNetworkClient.networkResult = .success((Data(), httpUrlResponse))
            let request = NetworkRequest(url: "example", httpMethod: .get)
            do {
                let _: NetworkResponse<SampleResponse> = try await NetworkManager.request(client: mockNetworkClient, request: request)
                XCTFail("Should throw error")
            } catch let error {
                guard case NetworkKitError.serverError = error else {
                    XCTFail("Should throw server error")
                    return
                }
            }
        }
    }
    
    func testThrowUnknownError() async {
        let mockNetworkClient = MockNetworkClient()
        let statusCodes: [Int] = [499, 512, 103]
        
        for statusCode in statusCodes {
            let httpUrlResponse = HTTPURLResponse(
                url: URL(string: "example")!, statusCode: statusCode,
                httpVersion: nil, headerFields: nil
            )!
            mockNetworkClient.networkResult = .success((Data(), httpUrlResponse))
            let request = NetworkRequest(url: "example", httpMethod: .get)
            do {
                let _: NetworkResponse<SampleResponse> = try await NetworkManager.request(client: mockNetworkClient, request: request)
                XCTFail("Should throw error")
            } catch let error {
                guard case NetworkKitError.unknownError = error else {
                    XCTFail("Should throw unknown error")
                    return
                }
            }
        }
    }
    
    func testClientThrowError() async {
        let mockNetworkClient = MockNetworkClient()
        let request = NetworkRequest(url: "", httpMethod: .get)
        do {
            let _: NetworkResponse<SampleResponse> = try await NetworkManager.request(client: mockNetworkClient, request: request)
            XCTFail("Should throw error")
        } catch let error {
            guard case NetworkKitError.unknownError = error else {
                XCTFail("Should throw unknown error")
                return
            }
        }
    }
}

extension NetworkManagerTests {
    private final class MockNetworkClient: NetworkClient {
        var networkResult: Result<(Data, URLResponse), Error> = .failure(NetworkKitError.unknownError)
        func data(for request: URLRequest) async throws -> (Data, URLResponse) {
            switch networkResult {
            case .success(let response):
                return response
            case .failure(let error):
                throw error
            }
        }
    }
    
    private final class SampleResponse: Decodable {
        let id: Int
    }
}
