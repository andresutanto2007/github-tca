//
//  RepositoryListFeatureTests.swift
//  GitHubTCATests
//
//  Created by Andre on 2024/08/15.
//

import ComposableArchitecture
import XCTest
import NetworkKit

@testable import GitHubTCA

final class RepositoryListFeatureTests: XCTestCase {
    
    @MainActor
    func testDidLoadSuccess() async {
        let mockResponse: NetworkResponse<GitHubSearch<GitHubRepository>> = try! MockHelper.buildNetworkResponse(
            with: MockSearchRepositories.successIsLastPage
        )
        
        let store = TestStore(initialState: RepositoryListFeature.State(username: "defunkt")) {
            RepositoryListFeature()
        } withDependencies: {
            $0.repositoryListClient.searchRepositories = { (_, _, _) in mockResponse }
            $0.uuid = .incrementing
        }
        
        await store.send(.didLoad) {
            $0.repositories = []
            $0.page = 1
            $0.totalItems = nil
            $0.searchedText = ""
            $0.isLoading = true
        }
        
        await store.receive(\.onReceivedResponse) {
            $0.isLoading = false
            $0.page = 2
            $0.totalItems = 5
            $0.repositories = self.populateRepositoryViewModels(response: mockResponse, startIndex: 0)
        }
    }
    
    @MainActor
    func testDidLoadSuccessMissingFields() async {
        let mockResponse: NetworkResponse<GitHubSearch<GitHubRepository>> = try! MockHelper.buildNetworkResponse(
            with: MockSearchRepositories.successMissingFields
        )
        
        let store = TestStore(initialState: RepositoryListFeature.State(username: "defunkt")) {
            RepositoryListFeature()
        } withDependencies: {
            $0.repositoryListClient.searchRepositories = { (_, _, _) in mockResponse }
            $0.uuid = .incrementing
        }
        
        await store.send(.didLoad) {
            $0.repositories = []
            $0.page = 1
            $0.totalItems = nil
            $0.searchedText = ""
            $0.isLoading = true
        }
        
        await store.receive(\.onReceivedResponse) {
            $0.isLoading = false
            $0.page = 2
            $0.totalItems = 1
            $0.repositories = [RepositoryView.Model(id: UUID(0), name: "-", language: "-", star: 0, description: "-", htmlUrl: nil)]
        }
    }
    
    @MainActor
    func testDidLoadInRequest() async {
        let mockResponse: NetworkResponse<GitHubSearch<GitHubRepository>> = try! MockHelper.buildNetworkResponse(
            with: MockSearchRepositories.successIsLastPage
        )
        
        var delayedResponseTask: Task<Void, Error>? = nil
        
        let store = TestStore(initialState: RepositoryListFeature.State(username: "defunkt")) {
            RepositoryListFeature()
        } withDependencies: {
            $0.repositoryListClient.searchRepositories = { (_, _, _) in
                delayedResponseTask = Task {
                    try await Task.sleep(nanoseconds: 999_000_000_000)
                }
                try? await delayedResponseTask?.value
                return mockResponse
            }
            $0.uuid = .incrementing
        }
        
        
        await store.send(.didLoad) {
            $0.repositories = []
            $0.page = 1
            $0.totalItems = nil
            $0.searchedText = ""
            $0.isLoading = true
        }
        await store.send(.didLoad)
        
        // Simulate got response after waiting
        delayedResponseTask?.cancel()
        
        await store.receive(\.onReceivedResponse) {
            $0.isLoading = false
            $0.page = 2
            $0.totalItems = 5
            $0.repositories = self.populateRepositoryViewModels(response: mockResponse, startIndex: 0)
        }
    }
    
    @MainActor
    func testDidLoadFailure() async {
        let store = TestStore(initialState: RepositoryListFeature.State(username: "defunkt")) {
            RepositoryListFeature()
        } withDependencies: {
            $0.repositoryListClient.searchRepositories = { (_, _, _) in throw NetworkKitError.serverError }
        }
        
        await store.send(.didLoad) {
            $0.repositories = []
            $0.page = 1
            $0.totalItems = nil
            $0.searchedText = ""
            $0.isLoading = true
        }
        
        await store.receive(\.onReceivedResponse) {
            $0.isLoading = false
            $0.errorAlert = CommonAlert.ErrorFeature.buildAlert(error: NetworkKitError.serverError)
        }
    }
    
    @MainActor
    func testOnAppearRepositoryOnLastPage() async {
        let mockResponse: NetworkResponse<GitHubSearch<GitHubRepository>> = try! MockHelper.buildNetworkResponse(
            with: MockSearchRepositories.successIsLastPage
        )
        
        let store = TestStore(initialState: RepositoryListFeature.State(username: "defunkt")) {
            RepositoryListFeature()
        } withDependencies: {
            $0.repositoryListClient.searchRepositories = { (_, _, _) in mockResponse }
            $0.uuid = .incrementing
        }
        
        await store.send(.didLoad) {
            $0.repositories = []
            $0.page = 1
            $0.totalItems = nil
            $0.searchedText = ""
            $0.isLoading = true
        }
        
        await store.receive(\.onReceivedResponse) {
            $0.isLoading = false
            $0.page = 2
            $0.totalItems = 5
            $0.repositories = self.populateRepositoryViewModels(response: mockResponse, startIndex: 0)
        }
        
        // When user reach end of user list
        await store.send(.onAppearRepository(store.state.repositories[4]))
    }
    
    @MainActor
    func testOnAppearRepositoryHasNextPage() async {
        let mockResponse: NetworkResponse<GitHubSearch<GitHubRepository>> = try! MockHelper.buildNetworkResponse(
            with: MockSearchRepositories.successHasNextPage
        )
        
        let store = TestStore(initialState: RepositoryListFeature.State(username: "defunkt")) {
            RepositoryListFeature()
        } withDependencies: {
            $0.repositoryListClient.searchRepositories = { (_, _, _) in mockResponse }
            $0.uuid = .incrementing
        }
        
        await store.send(.didLoad) {
            $0.repositories = []
            $0.page = 1
            $0.totalItems = nil
            $0.searchedText = ""
            $0.isLoading = true
        }
        
        await store.receive(\.onReceivedResponse) {
            $0.isLoading = false
            $0.page = 2
            $0.totalItems = 77
            $0.repositories = self.populateRepositoryViewModels(response: mockResponse, startIndex: 0)
        }
        
        // When user still on top of user list
        await store.send(.onAppearRepository(store.state.repositories[5]))
        
        // When user reach end of user list
        await store.send(.onAppearRepository(store.state.repositories[6])) {
            $0.isLoading = true
        }
        
        await store.receive(\.onReceivedResponse) {
            $0.isLoading = false
            $0.page = 3
            $0.totalItems = 77
            $0.repositories.append(contentsOf: self.populateRepositoryViewModels(response: mockResponse, startIndex: 10))
        }
    }
    
    @MainActor
    func testOnAppearRepositoryHasNextPageInRequest() async {
        let mockResponse: NetworkResponse<GitHubSearch<GitHubRepository>> = try! MockHelper.buildNetworkResponse(
            with: MockSearchRepositories.successHasNextPage
        )
        
        var delayedResponseTask: Task<Void, Error>? = nil
        
        let store = TestStore(initialState: RepositoryListFeature.State(username: "defunkt")) {
            RepositoryListFeature()
        } withDependencies: {
            $0.repositoryListClient.searchRepositories = { (_, _, _) in
                delayedResponseTask = Task {
                    try await Task.sleep(nanoseconds: 999_000_000_000)
                }
                try? await delayedResponseTask?.value
                return mockResponse
            }
            $0.uuid = .incrementing
        }
        
        await store.send(.didLoad) {
            $0.repositories = []
            $0.page = 1
            $0.totalItems = nil
            $0.searchedText = ""
            $0.isLoading = true
        }
        
        
        // Simulate got response after waiting
        delayedResponseTask?.cancel()
        
        await store.receive(\.onReceivedResponse) {
            $0.isLoading = false
            $0.page = 2
            $0.totalItems = 77
            $0.repositories = self.populateRepositoryViewModels(response: mockResponse, startIndex: 0)
        }
        
        // When user still on top of user list
        await store.send(.onAppearRepository(store.state.repositories[5]))
        
        // When user reach end of user list
        await store.send(.onAppearRepository(store.state.repositories[6])) {
            $0.isLoading = true
        }
        await store.send(.onAppearRepository(store.state.repositories[7]))
        await store.send(.onAppearRepository(store.state.repositories[8]))
        
        // Simulate got response after waiting
        delayedResponseTask?.cancel()
        
        await store.receive(\.onReceivedResponse) {
            $0.isLoading = false
            $0.page = 3
            $0.totalItems = 77
            $0.repositories.append(contentsOf: self.populateRepositoryViewModels(response: mockResponse, startIndex: 10))
        }
    }
    
    @MainActor
    func testOnTapRefreshInErrorAlert() async {
        let store = TestStore(initialState: RepositoryListFeature.State(username: "defunkt")) {
            RepositoryListFeature()
        } withDependencies: {
            $0.repositoryListClient.searchRepositories = { (_, _, _) in throw NetworkKitError.serverError }
        }
        
        await store.send(.didLoad) {
            $0.repositories = []
            $0.page = 1
            $0.totalItems = nil
            $0.searchedText = ""
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
    
    @MainActor
    func testOnSubmitSearch() async {
        let mockResponse: NetworkResponse<GitHubSearch<GitHubRepository>> = try! MockHelper.buildNetworkResponse(
            with: MockSearchRepositories.successIsLastPage
        )
        
        let store = TestStore(initialState: RepositoryListFeature.State(username: "defunkt")) {
            RepositoryListFeature()
        } withDependencies: {
            $0.repositoryListClient.searchRepositories = { (_, _, _) in mockResponse }
            $0.uuid = .incrementing
        }
        
        await store.send(.onSubmitSearch("Testing")) {
            $0.repositories = []
            $0.page = 1
            $0.totalItems = nil
            $0.searchedText = "Testing"
            $0.isLoading = true
        }
        
        await store.receive(\.onReceivedResponse) {
            $0.isLoading = false
            $0.page = 2
            $0.totalItems = 5
            $0.repositories = self.populateRepositoryViewModels(response: mockResponse, startIndex: 0)
        }
    }
    
    @MainActor
    func testOnSubmitSearchSameText() async {
        let mockResponse: NetworkResponse<GitHubSearch<GitHubRepository>> = try! MockHelper.buildNetworkResponse(
            with: MockSearchRepositories.successIsLastPage
        )
        
        let store = TestStore(initialState: RepositoryListFeature.State(username: "defunkt")) {
            RepositoryListFeature()
        } withDependencies: {
            $0.repositoryListClient.searchRepositories = { (_, _, _) in mockResponse }
            $0.uuid = .incrementing
        }
        
        await store.send(.onSubmitSearch("Testing")) {
            $0.repositories = []
            $0.page = 1
            $0.totalItems = nil
            $0.searchedText = "Testing"
            $0.isLoading = true
        }
        
        await store.receive(\.onReceivedResponse) {
            $0.isLoading = false
            $0.page = 2
            $0.totalItems = 5
            $0.repositories = self.populateRepositoryViewModels(response: mockResponse, startIndex: 0)
        }
        
        await store.send(.onSubmitSearch("Testing"))
    }
    
    private func populateRepositoryViewModels(response: NetworkResponse<GitHubSearch<GitHubRepository>>, startIndex: Int) -> [RepositoryView.Model] {
        return response.body.items.enumerated().compactMap({ (index, value) in
            RepositoryView.Model(
                id: UUID(startIndex + index), name: value.name ?? "-",
                language: value.language ?? "-", star: value.stargazersCount ?? 0,
                description: value.description ?? "-", htmlUrl: URL(string: value.htmlUrl ?? "")
            )
        })
    }
}
