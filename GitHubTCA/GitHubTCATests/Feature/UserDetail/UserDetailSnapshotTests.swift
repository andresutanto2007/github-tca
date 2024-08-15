//
//  UserDetailSnapshotTests.swift
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

final class UserDetailSnapshotTests: XCTestCase {
    
    @MainActor
    func testSuccessUserDetail() async {
        let mockResponse: NetworkResponse<GitHubUserDetail> = try! MockHelper.buildNetworkResponse(
            with: MockGetUserDetail.success
        )
        
        let store = Store(initialState: UserDetailFeature.State(username: "defunkt")) {
            UserDetailFeature()
        } withDependencies: {
            $0.userDetailClient.getUserDetail = { _ in mockResponse }
        }

        let view = UserDetailView(store: store)
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
    func testOnFetchUserDetail() async {
        let store = Store(initialState: UserDetailFeature.State(username: "defunkt")) {
            UserDetailFeature()
        } withDependencies: {
            $0.userDetailClient.getUserDetail = { _ in
                try! await Task.sleep(nanoseconds: 500_000)
                throw NSError(domain: "", code: 0)
            }
        }

        let view = UserDetailView(store: store)
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
