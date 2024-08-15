//
//  RepositoryListSnapshotTests.swift
//  GitHubTCATests
//
//  Created by Andre on 2024/08/15.
//

import XCTest
import ComposableArchitecture
import SnapshotTesting
import NetworkKit
import SwiftUI

@testable import GitHubTCA

final class RepositoryListSnapshotTests: XCTestCase {
    
    @MainActor
    func testSuccessSearchRepository() async {
        let mockResponse: NetworkResponse<GitHubSearch<GitHubRepository>> = try! MockHelper.buildNetworkResponse(
            with: MockSearchRepositories.successIsLastPage
        )
        
        let store = Store(initialState: RepositoryListFeature.State(username: "defunkt")) {
            RepositoryListFeature()
        } withDependencies: {
            $0.repositoryListClient.searchRepositories = { (_, _, _) in mockResponse }
            $0.uuid = .incrementing
        }

        let view = RepositoryListView(store: store)
        let vc = UIHostingController(rootView: view)
        store.send(.didLoad)
        
        let expectation = self.expectation(description: "wait")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
          expectation.fulfill()
        }
        await fulfillment(of: [expectation])
        
        withSnapshotTesting {
            assertSnapshot(of: vc, as: .image(on: .iPhoneSe))
            assertSnapshot(of: vc, as: .image(on: .iPhone13Pro))
            assertSnapshot(of: vc, as: .image(on: .iPadPro11))
            assertSnapshot(of: vc, as: .image(on: .iPadPro11(.landscape(splitView: .oneThird))))
        }
    }
    
    @MainActor
    func testEmptyRepository() async {
        let mockResponse: NetworkResponse<GitHubSearch<GitHubRepository>> = NetworkResponse(
            body: GitHubSearch(totalCount: 0, items: []),
            response: URLResponse()
        )
        
        let store = Store(initialState: RepositoryListFeature.State(username: "defunkt")) {
            RepositoryListFeature()
        } withDependencies: {
            $0.repositoryListClient.searchRepositories = { (_, _, _) in mockResponse }
            $0.uuid = .incrementing
        }

        let view = RepositoryListView(store: store)
        let vc = UIHostingController(rootView: view)
        store.send(.didLoad)
        
        let expectation = self.expectation(description: "wait")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
          expectation.fulfill()
        }
        await fulfillment(of: [expectation])
        
        withSnapshotTesting {
            assertSnapshot(of: vc, as: .image(on: .iPhoneSe))
            assertSnapshot(of: vc, as: .image(on: .iPhone13Pro))
            assertSnapshot(of: vc, as: .image(on: .iPadPro11))
            assertSnapshot(of: vc, as: .image(on: .iPadPro11(.landscape(splitView: .oneThird))))
        }
    }
    
    @MainActor
    func testOnFetchRespositoryList() async {
        let store = Store(initialState: RepositoryListFeature.State(username: "defunkt")) {
            RepositoryListFeature()
        } withDependencies: {
            $0.repositoryListClient.searchRepositories = { (_, _, _) in
                try! await Task.sleep(nanoseconds: 500_000)
                throw NSError(domain: "", code: 0)
            }
            $0.uuid = .incrementing
        }

        let view = RepositoryListView(store: store)
        let vc = UIHostingController(rootView: view)
        store.send(.didLoad)
        
        withSnapshotTesting {
            assertSnapshot(of: vc, as: .image(on: .iPhoneSe))
            assertSnapshot(of: vc, as: .image(on: .iPhone13Pro))
            assertSnapshot(of: vc, as: .image(on: .iPadPro11))
            assertSnapshot(of: vc, as: .image(on: .iPadPro11(.landscape(splitView: .oneThird))))
        }
    }
}
