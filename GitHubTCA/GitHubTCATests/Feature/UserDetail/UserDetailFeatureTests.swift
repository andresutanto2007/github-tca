//
//  UserDetailFeatureTests.swift
//  GitHubTCATests
//
//  Created by Andre on 2024/08/15.
//

import ComposableArchitecture
import XCTest
import NetworkKit

@testable import GitHubTCA

final class UserDetailFeatureTests: XCTestCase {
    
    @MainActor
    func testDidLoadSuccess() async {
        let mockResponse: NetworkResponse<GitHubUserDetail> = try! MockHelper.buildNetworkResponse(
            with: MockGetUserDetail.success
        )
        
        let store = TestStore(initialState: UserDetailFeature.State(username: "defunkt")) {
            UserDetailFeature()
        } withDependencies: {
            $0.userDetailClient.getUserDetail = { _ in mockResponse }
        }
        
        await store.send(.didLoad) {
            $0.isLoading = true
        }
        
        await store.receive(\.onReceivedResponse) {
            $0.isLoading = false
            $0.model = UserDetailView.Model(
                fullname: "Chris Wanstrath",
                followers: 22357, following: 215,
                avatarURL: URL(string: "https://avatars.githubusercontent.com/u/2?v=4")!
            )
        }
    }
    
    @MainActor
    func testDidLoadSuccessMissingFields() async {
        let mockResponse: NetworkResponse<GitHubUserDetail> = try! MockHelper.buildNetworkResponse(
            with: MockGetUserDetail.successMissingFields
        )
        
        let store = TestStore(initialState: UserDetailFeature.State(username: "defunkt")) {
            UserDetailFeature()
        } withDependencies: {
            $0.userDetailClient.getUserDetail = { _ in mockResponse }
        }
        
        await store.send(.didLoad) {
            $0.isLoading = true
        }
        
        await store.receive(\.onReceivedResponse) {
            $0.isLoading = false
            $0.model = UserDetailView.Model(
                fullname: "-",
                followers: 0, following: 0,
                avatarURL: nil
            )
        }
    }
    
    @MainActor
    func testDidLoadInRequest() async {let mockResponse: NetworkResponse<GitHubUserDetail> = try! MockHelper.buildNetworkResponse(
            with: MockGetUserDetail.success
        )
        
        var delayedResponseTask: Task<Void, Error>? = nil
        
        let store = TestStore(initialState: UserDetailFeature.State(username: "defunkt")) {
            UserDetailFeature()
        } withDependencies: {
            $0.userDetailClient.getUserDetail = { _ in
                delayedResponseTask = Task {
                    try await Task.sleep(nanoseconds: 999_000_000_000)
                }
                try? await delayedResponseTask?.value
                return mockResponse
            }
        }
        
        await store.send(.didLoad) {
            $0.isLoading = true
        }
        
        await store.send(.didLoad)
        
        // Simulate got response after waiting
        delayedResponseTask?.cancel()
        
        await store.receive(\.onReceivedResponse) {
            $0.isLoading = false
            $0.model = UserDetailView.Model(
                fullname: "Chris Wanstrath",
                followers: 22357, following: 215,
                avatarURL: URL(string: "https://avatars.githubusercontent.com/u/2?v=4")!
            )
        }
    }
    

    @MainActor
    func testDidLoadFailure() async {
        let store = TestStore(initialState: UserDetailFeature.State(username: "defunkt")) {
            UserDetailFeature()
        } withDependencies: {
            $0.userDetailClient.getUserDetail = { _ in throw NetworkKitError.serverError }
        }
        
        await store.send(.didLoad) {
            $0.isLoading = true
        }
        
        await store.receive(\.onReceivedResponse) {
            $0.isLoading = false
            $0.errorAlert = CommonAlert.ErrorFeature.buildAlert(error: NetworkKitError.serverError)
        }
    }
    
    @MainActor
    func testOnTapRefreshInErrorAlert() async {
        let store = TestStore(initialState: UserDetailFeature.State(username: "defunkt")) {
            UserDetailFeature()
        } withDependencies: {
            $0.userDetailClient.getUserDetail = { _ in throw NetworkKitError.serverError }
        }
        
        await store.send(.didLoad) {
            $0.isLoading = true
        }
        
        await store.receive(\.onReceivedResponse) {
            $0.isLoading = false
            $0.errorAlert = CommonAlert.ErrorFeature.buildAlert(error: NetworkKitError.serverError)
        }
        
        await store.send(.errorAlert(.presented(.onTapRefreshButton))) {
            $0.isLoading = true
            $0.errorAlert = nil
        }
        
        await store.receive(\.onReceivedResponse) {
            $0.isLoading = false
            $0.errorAlert = CommonAlert.ErrorFeature.buildAlert(error: NetworkKitError.serverError)
        }
    }
}
