//
//  UserRepositorySnapshotTests.swift
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

final class UserRepositorySnapshotTests: XCTestCase {
    
    @MainActor
    func testSuccessUserDetailAndRepositories() async {
        let mockUserDetail: NetworkResponse<GitHubUserDetail> = try! MockHelper.buildNetworkResponse(
            with: MockGetUserDetail.success
        )
        
        let mockRepositories: NetworkResponse<GitHubSearch<GitHubRepository>> = try! MockHelper.buildNetworkResponse(
            with: MockSearchRepositories.successIsLastPage
        )
        
        let store = Store(initialState: UserRepositoryFeature.State(username: "defunkt")) {
            UserRepositoryFeature()
        } withDependencies: {
            $0.userDetailClient.getUserDetail = { _ in mockUserDetail }
            $0.repositoryListClient.searchRepositories = { (_, _, _) in mockRepositories }
            $0.uuid = .incrementing
        }

        let view = UserRepositoryView(store: store)
        let vc = UIHostingController(rootView: view)
        store.send(.userDetail(.didLoad))
        store.send(.repositoryList(.didLoad))
        
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
    func testOnFetchUserList() async {
        let store = Store(initialState: UserRepositoryFeature.State(username: "defunkt")) {
            UserRepositoryFeature()
        } withDependencies: {
            $0.userDetailClient.getUserDetail = { _ in
                try! await Task.sleep(nanoseconds: 500_000)
                throw NSError(domain: "", code: 0)
            }
            $0.repositoryListClient.searchRepositories = { (_, _, _) in
                try! await Task.sleep(nanoseconds: 500_000)
                throw NSError(domain: "", code: 0)
            }
            $0.uuid = .incrementing
        }

        let view = UserRepositoryView(store: store)
        let vc = UIHostingController(rootView: view)
        
        store.send(.userDetail(.didLoad))
        store.send(.repositoryList(.didLoad))
        
        withSnapshotTesting {
            assertSnapshot(of: vc, as: .image(on: .iPhoneSe))
            assertSnapshot(of: vc, as: .image(on: .iPhone13Pro))
            assertSnapshot(of: vc, as: .image(on: .iPadPro11))
            assertSnapshot(of: vc, as: .image(on: .iPadPro11(.landscape(splitView: .oneThird))))
        }
    }
}
