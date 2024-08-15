//
//  RepositoryListFeature.swift
//  GitHubTCA
//
//  Created by Andre on 2024/08/15.
//

import Foundation
import ComposableArchitecture
import NetworkKit

@Reducer
struct RepositoryListFeature {
    @ObservableState
    struct State: Equatable {
        var isLoading: Bool = false
        var page: Int = 1
        var totalItems: Int? = nil
        var repositories: [RepositoryView.Model] = []
        var searchedText: String = ""
        let username: String
        @Presents var errorAlert: CommonAlert.ErrorFeature.State? = nil
    }
    
    enum Action {
        case didLoad
        case onAppearRepository(RepositoryView.Model)
        case onTapRepository(RepositoryView.Model)
        case onReceivedResponse(OnReceivedResponse)
        case onSubmitSearch(String)
        case errorAlert(PresentationAction<CommonAlert.ErrorFeature.Action>)
        
        enum OnReceivedResponse {
            case repositoryList(NetworkResponse<GitHubSearch<GitHubRepository>>)
            case error(Error)
        }
    }
    
    @Dependency(\.repositoryListClient) var repositoryListClient
    @Dependency(\.uuid) var uuid
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .didLoad:
                resetResult(state: &state)
                return fetchRepositories(state: &state)
            case let .onAppearRepository(repository):
                guard let totalItems = state.totalItems, state.repositories.count < totalItems else { return .none }
                let thresholdIndex = state.repositories.count - 5
                if let repositoryIndex = state.repositories.firstIndex(of: repository),
                   repositoryIndex > thresholdIndex {
                    return fetchRepositories(state: &state)
                }
                return .none
            case let .onReceivedResponse(responseType):
                return onReceivedResponse(responseType: responseType, state: &state)
            case let .onSubmitSearch(newText):
                guard state.searchedText != newText else { return .none }
                resetResult(state: &state)
                state.searchedText = newText
                return fetchRepositories(state: &state)
            case .errorAlert(.presented(.onTapRefreshButton)):
                return fetchRepositories(state: &state)
            case .onTapRepository, .errorAlert:
                return .none
            }
        }
        .ifLet(\.$errorAlert, action: \.errorAlert)
    }
    
    private func resetResult(state: inout State) {
        state.repositories = []
        state.page = 1
        state.totalItems = nil
        state.searchedText = ""
    }
    
    private func fetchRepositories(state: inout State) -> Effect<Action> {
        guard !state.isLoading else { return .none }
        state.isLoading = true
        let query = GitHubSearchQuery(query: state.searchedText, username: state.username)
        let page = state.page
        return .run { send in
            do {
                let response = try await repositoryListClient.searchRepositories(query: query, itemPerPage: 30, page: page)
                await send(.onReceivedResponse(.repositoryList(response)))
            } catch let error {
                await send(.onReceivedResponse(.error(error)))
            }
        }
    }
    
    private func onReceivedResponse(responseType: Action.OnReceivedResponse, state: inout State) -> Effect<Action> {
        state.isLoading = false
        
        switch responseType {
        case let .repositoryList(response):
            state.repositories.append(
                contentsOf: response.body.items.compactMap({ RepositoryView.Model(id: uuid(), from: $0)} )
            )
            state.totalItems = response.body.totalCount
            state.page += 1
        case let .error(error):
            state.errorAlert = CommonAlert.ErrorFeature.buildAlert(error: error)
        }
        
        return .none
    }
}

private extension RepositoryView.Model {
    init(id: UUID, from model: GitHubRepository) {
        self.init(
            id: id, name: model.name ?? "-",
            language: model.language ?? "-",
            star: model.stargazersCount ?? 0,
            description: model.description ?? "-",
            htmlUrl: URL(string: model.htmlUrl ?? "")
        )
    }
}
