//
//  UserListSnapshotTests.swift
//  GitHubTCATests
//
//  Created by Andre on 2024/08/14.
//

import XCTest
import ComposableArchitecture
import SnapshotTesting
import NetworkKit
import SwiftUI

@testable import GitHubTCA

final class UserListSnapshotTests: XCTestCase {
    
    @MainActor
    func testSuccessUserList() async {
        let mockResponse: NetworkResponse<[GitHubUser]> = try! MockHelper.buildNetworkResponse(
            with: MockGetUsers.successIsLastPage
        )
        
        let store = Store(initialState: UserListFeature.State()) {
            UserListFeature()
        } withDependencies: {
            $0.userListClient.getUsers = { _ in mockResponse }
            $0.uuid = .incrementing
        }

        let view = UserListView(store: store)
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
    func testOnFetchUserList() async {
        let store = Store(initialState: UserListFeature.State()) {
            UserListFeature()
        } withDependencies: {
            $0.userListClient.getUsers = { _ in
                try! await Task.sleep(nanoseconds: 500_000)
                throw NSError(domain: "", code: 0)
            }
            $0.uuid = .incrementing
        }

        let view = UserListView(store: store)
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
