//
//  UserListFeatureTests.swift
//  GitHubTCATests
//
//  Created by Andre on 2024/08/14.
//

import ComposableArchitecture
import XCTest
import NetworkKit

@testable import GitHubTCA

final class UserListFeatureTests: XCTestCase {
    
    @MainActor
    func testDidLoadSuccess() async {
        let mockResponse: NetworkResponse<[GitHubUser]> = try! MockHelper.buildNetworkResponse(
            with: MockGetUsers.successIsLastPage
        )
        
        let store = TestStore(initialState: UserListFeature.State()) {
            UserListFeature()
        } withDependencies: {
            $0.userListClient.getUsers = { _ in mockResponse }
            $0.uuid = .incrementing
        }
        
        await store.send(.didLoad) {
            $0.userListUrl = "https://api.github.com/users"
            $0.isLoading = true
        }
        
        await store.receive(\.onReceivedResponse) {
            $0.isLoading = false
            $0.userListUrl = nil
            $0.users = mockResponse.body.enumerated().compactMap({ (index, value) in
                return UserView.Model(id: UUID(index), name: value.login!, avatarURL: URL(string: value.avatarUrl!)!)
            })
        }
    }
    
    @MainActor
    func testDidLoadInRequest() async {
        let mockResponse: NetworkResponse<[GitHubUser]> = try! MockHelper.buildNetworkResponse(
            with: MockGetUsers.successIsLastPage
        )
        
        var delayedResponseTask: Task<Void, Error>? = nil
        
        let store = TestStore(initialState: UserListFeature.State()) {
            UserListFeature()
        } withDependencies: {
            $0.userListClient.getUsers = { _ in
                delayedResponseTask = Task {
                    try await Task.sleep(nanoseconds: 999_000_000_000)
                }
                try? await delayedResponseTask?.value
                return mockResponse
            }
            $0.uuid = .incrementing
        }
        
        await store.send(.didLoad) {
            $0.userListUrl = "https://api.github.com/users"
            $0.isLoading = true
        }
        await store.send(.didLoad)
        
        // Simulate got response after waiting
        delayedResponseTask?.cancel()
        
        await store.receive(\.onReceivedResponse) {
            $0.isLoading = false
            $0.userListUrl = nil
            $0.users = mockResponse.body.enumerated().compactMap({ (index, value) in
                return UserView.Model(id: UUID(index), name: value.login!, avatarURL: URL(string: value.avatarUrl!)!)
            })
        }
    }
    
    @MainActor
    func testDidLoadPartialMissingFields() async {
        let mockResponse: NetworkResponse<[GitHubUser]> = try! MockHelper.buildNetworkResponse(
            with: MockGetUsers.successPartialMissingFields
        )
        
        let store = TestStore(initialState: UserListFeature.State()) {
            UserListFeature()
        } withDependencies: {
            $0.userListClient.getUsers = { _ in mockResponse }
            $0.uuid = .incrementing
        }
        
        await store.send(.didLoad) {
            $0.userListUrl = "https://api.github.com/users"
            $0.isLoading = true
        }
        
        await store.receive(\.onReceivedResponse) {
            $0.isLoading = false
            $0.userListUrl = nil
            $0.users = [
                UserView.Model(
                    id: UUID(3), name: "wycats",
                    avatarURL: URL(string: "https://avatars.githubusercontent.com/u/4?v=4")!
                ),
                UserView.Model(
                    id: UUID(4), name: "ezmobius",
                    avatarURL: URL(string: "https://avatars.githubusercontent.com/u/5?v=4")!
                ),
                UserView.Model(
                    id: UUID(5), name: "ivey", avatarURL: nil
                ),
                UserView.Model(
                    id: UUID(6), name: "evanphx",
                    avatarURL: URL(string: "https://avatars.githubusercontent.com/u/7?v=4")!
                )
            ]
        }
    }
    
    @MainActor
    func testDidLoadFailure() async {
        let store = TestStore(initialState: UserListFeature.State()) {
            UserListFeature()
        } withDependencies: {
            $0.userListClient.getUsers = { _ in throw NetworkKitError.serverError }
        }
        
        await store.send(.didLoad) {
            $0.userListUrl = "https://api.github.com/users"
            $0.isLoading = true
        }
        
        await store.receive(\.onReceivedResponse) {
            $0.isLoading = false
            $0.destination = .errorAlert(CommonAlert.ErrorFeature.buildAlert(error: NetworkKitError.serverError))
        }
    }
    
    @MainActor
    func testOnAppearUserHasNextPage() async {
        let mockResponse: NetworkResponse<[GitHubUser]> = try! MockHelper.buildNetworkResponse(
            with: MockGetUsers.successHasNextPage
        )
        
        let store = TestStore(initialState: UserListFeature.State()) {
            UserListFeature()
        } withDependencies: {
            $0.userListClient.getUsers = { _ in mockResponse }
            $0.uuid = .incrementing
        }
        
        await store.send(.didLoad) {
            $0.userListUrl = "https://api.github.com/users"
            $0.isLoading = true
        }
        
        await store.receive(\.onReceivedResponse) {
            $0.isLoading = false
            $0.userListUrl = "https://api.github.com/repositories/1300192/issues?page=4"
            $0.users = mockResponse.body.enumerated().compactMap({ (index, value) in
                return UserView.Model(id: UUID(index), name: value.login!, avatarURL: URL(string: value.avatarUrl!)!)
            })
        }
        
        // When user still on top of user list
        await store.send(.onAppearUser(store.state.users[24]))
        
        // When user reach end of user list
        await store.send(.onAppearUser(store.state.users[25])) {
            $0.isLoading = true
        }
        
        await store.receive(\.onReceivedResponse) {
            $0.isLoading = false
            $0.userListUrl = "https://api.github.com/repositories/1300192/issues?page=4"
            $0.users.append(contentsOf: mockResponse.body.enumerated().compactMap({ (index, value) in
                return UserView.Model(id: UUID(index + 30), name: value.login!, avatarURL: URL(string: value.avatarUrl!)!)
            }))
        }
    }
    
    @MainActor
    func testOnAppearUserHasNextPageInRequest() async {
        let mockResponse: NetworkResponse<[GitHubUser]> = try! MockHelper.buildNetworkResponse(
            with: MockGetUsers.successHasNextPage
        )
        
        var delayedResponseTask: Task<Void, Error>? = nil
        
        let store = TestStore(initialState: UserListFeature.State()) {
            UserListFeature()
        } withDependencies: {
            $0.userListClient.getUsers = { _ in
                delayedResponseTask = Task { try await Task.sleep(nanoseconds: 999_000_000_000) }
                try? await delayedResponseTask?.value
                return mockResponse
            }
            $0.uuid = .incrementing
        }
        
        
        await store.send(.didLoad) {
            $0.userListUrl = "https://api.github.com/users"
            $0.isLoading = true
        }
        
        // Simulate got response after waiting
        delayedResponseTask?.cancel()
        
        await store.receive(\.onReceivedResponse) {
            $0.isLoading = false
            $0.userListUrl = "https://api.github.com/repositories/1300192/issues?page=4"
            $0.users = mockResponse.body.enumerated().compactMap({ (index, value) in
                return UserView.Model(id: UUID(index), name: value.login!, avatarURL: URL(string: value.avatarUrl!)!)
            })
        }
        
        // When user still on top of user list
        await store.send(.onAppearUser(store.state.users[24]))
        
        // When user reach end of user list
        await store.send(.onAppearUser(store.state.users[25])) {
            $0.isLoading = true
        }
        await store.send(.onAppearUser(store.state.users[26]))
        await store.send(.onAppearUser(store.state.users[27]))
        
        // Simulate got response after waiting
        delayedResponseTask?.cancel()
        
        await store.receive(\.onReceivedResponse) {
            $0.isLoading = false
            $0.userListUrl = "https://api.github.com/repositories/1300192/issues?page=4"
            $0.users.append(contentsOf: mockResponse.body.enumerated().compactMap({ (index, value) in
                return UserView.Model(id: UUID(index + 30), name: value.login!, avatarURL: URL(string: value.avatarUrl!)!)
            }))
        }
    }
    
    @MainActor
    func testOnAppearUserLastPage() async {
        let mockResponse: NetworkResponse<[GitHubUser]> = try! MockHelper.buildNetworkResponse(
            with: MockGetUsers.successIsLastPage
        )
        
        let store = TestStore(initialState: UserListFeature.State()) {
            UserListFeature()
        } withDependencies: {
            $0.userListClient.getUsers = { _ in mockResponse }
            $0.uuid = .incrementing
        }
        
        await store.send(.didLoad) {
            $0.userListUrl = "https://api.github.com/users"
            $0.isLoading = true
        }
        
        await store.receive(\.onReceivedResponse) {
            $0.isLoading = false
            $0.userListUrl = nil
            $0.users = mockResponse.body.enumerated().compactMap({ (index, value) in
                return UserView.Model(id: UUID(index), name: value.login!, avatarURL: URL(string: value.avatarUrl!)!)
            })
        }
        
        // When user still on top of user list
        await store.send(.onAppearUser(store.state.users[24]))
        
        // When user reach end of user list
        await store.send(.onAppearUser(store.state.users[25]))
    }
    
    @MainActor
    func testOnTapRefreshInErrorAlert() async {
        let store = TestStore(initialState: UserListFeature.State()) {
            UserListFeature()
        } withDependencies: {
            $0.userListClient.getUsers = { _ in throw NetworkKitError.serverError }
            $0.uuid = .incrementing
        }
        
        await store.send(.didLoad) {
            $0.userListUrl = "https://api.github.com/users"
            $0.isLoading = true
        }
        
        await store.receive(\.onReceivedResponse) {
            $0.isLoading = false
            $0.destination = .errorAlert(CommonAlert.ErrorFeature.buildAlert(error: NetworkKitError.serverError))
        }
        
        await store.send(.destination(.presented(.errorAlert(.onTapRefreshButton)))) {
            $0.isLoading = true
            $0.destination = nil
        }
        
        await store.receive(\.onReceivedResponse) {
            $0.isLoading = false
            $0.destination = .errorAlert(CommonAlert.ErrorFeature.buildAlert(error: NetworkKitError.serverError))
        }
    }
}
