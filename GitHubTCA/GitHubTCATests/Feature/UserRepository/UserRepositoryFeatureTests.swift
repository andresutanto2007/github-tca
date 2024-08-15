//
//  UserRepositoryFeatureTests.swift
//  GitHubTCATests
//
//  Created by Andre on 2024/08/15.
//

import ComposableArchitecture
import XCTest

@testable import GitHubTCA

final class UserRepositoryFeatureTests: XCTestCase {
    
    @MainActor
    func testSearchedText() async {
        let store = TestStore(initialState: UserRepositoryFeature.State(username: "defunkt")) {
            UserRepositoryFeature()
        }
        
        await store.send(.searchedText("Testing")) {
            $0.searchedText = "Testing"
        }
    }
}
