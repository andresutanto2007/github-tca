//
//  CommonWebViewFeatureTests.swift
//  GitHubTCATests
//
//  Created by Andre on 2024/08/15.
//

import ComposableArchitecture
import XCTest
import NetworkKit

@testable import GitHubTCA

final class CommonWebViewFeatureTests: XCTestCase {
    
    @MainActor
    func testIsLoading() async {
        let store = TestStore(initialState: CommonWebViewFeature.State(url: URL(string: "test")!)) {
            CommonWebViewFeature()
        }
        
        await store.send(.isLoading(true)) {
            $0.isLoading = true
        }
        
        await store.send(.isLoading(false)) {
            $0.isLoading = false
        }
    }
}
