//
//  NetworkKitErrorTests.swift
//  NetworkKitTests
//
//  Created by Andre on 2024/08/14.
//

import Foundation
import XCTest
import NetworkKit

final class NetworkKitErrorTests: XCTestCase {
    
    func testErrorDescription() {
        XCTAssertEqual(NetworkKitError.invalidJSON(NSError()).errorDescription, "Something went wrong...")
        XCTAssertEqual(NetworkKitError.invalidUrl.errorDescription, "Something went wrong...")
        XCTAssertEqual(NetworkKitError.serverError.errorDescription, "Something went wrong...")
        XCTAssertEqual(NetworkKitError.invalidCredentials.errorDescription, "Invalid credentials")
        XCTAssertEqual(NetworkKitError.unknownError.errorDescription, "Something went wrong...")
        XCTAssertEqual(NetworkKitError.invalidQueryParameter.errorDescription, "Something went wrong...")
    }
}
