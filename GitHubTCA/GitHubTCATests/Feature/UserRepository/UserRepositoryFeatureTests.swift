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
    
    @MainActor
    func testRepositoryListOnTapRepositoryInvalidUrl() async {
        let store = TestStore(initialState: UserRepositoryFeature.State(username: "defunkt")) {
            UserRepositoryFeature()
        }
        
        let dummyRepository = RepositoryView.Model(name: "Test", language: "Test", star: 0, description: "test", htmlUrl: nil)
        await store.send(.repositoryList(.onTapRepository(dummyRepository)))
    }
    
    @MainActor
    func testRepositoryListOnTapRepositoryValidUrl() async {
        let store = TestStore(initialState: UserRepositoryFeature.State(username: "defunkt")) {
            UserRepositoryFeature()
        }
        
        let dummyRepository = RepositoryView.Model(name: "Test", language: "Test", star: 0, description: "test", htmlUrl: URL(string: "anyUrl")!)
        await store.send(.repositoryList(.onTapRepository(dummyRepository))) {
            $0.webView = CommonWebViewFeature.State(url: URL(string: "anyUrl")!, title: "Test")
        }
    }
}
