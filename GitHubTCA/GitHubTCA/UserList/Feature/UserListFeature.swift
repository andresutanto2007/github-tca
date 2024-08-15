//
//  UserListFeature.swift
//  GitHubTCA
//
//  Created by Andre on 2024/08/14.
//

import Foundation
import ComposableArchitecture
import NetworkKit

@Reducer
struct UserListFeature {
    @ObservableState
    struct State: Equatable {
        var users: [UserView.Model] = []
        var isLoading: Bool = false
        var userListUrl: String? = nil
        @Presents var destination: Destination.State? = nil
    }
    
    @Reducer(state: .equatable)
    enum Destination {
        case userRepository(UserRepositoryFeature)
        case errorAlert(CommonAlert.ErrorFeature)
    }
    
    enum Action {
        case didLoad
        case onAppearUser(UserView.Model)
        case onTapUser(UserView.Model)
        
        case onReceivedResponse(OnReceivedResponse)
        case destination(PresentationAction<Destination.Action>)
        
        enum OnReceivedResponse {
            case userList(NetworkResponse<[GitHubUser]>)
            case error(Error)
        }
    }
    
    @Dependency(\.userListClient) var userListClient
    @Dependency(\.uuid) var uuid
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .didLoad:
                state.userListUrl = "https://api.github.com/users"
                return fetchUserIfNecessary(state: &state)
            case let .onAppearUser(user):
                let thresholdIndex = state.users.count - 5
                if let userIndex = state.users.firstIndex(of: user), userIndex >= thresholdIndex {
                    return fetchUserIfNecessary(state: &state)
                }
                return .none
            case let .onTapUser(user):
                let userRepositoryState = UserRepositoryFeature.State(username: user.name)
                state.destination = .userRepository(userRepositoryState)
                return .none
            case let .onReceivedResponse(responseType):
                return onReceivedResponse(responseType: responseType, state: &state)
            case .destination(.presented(.errorAlert(.onTapRefreshButton))):
                return fetchUserIfNecessary(state: &state)
            case .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
    
    private func fetchUserIfNecessary(state: inout State) -> Effect<Action> {
        guard let url = state.userListUrl, !state.isLoading else { return .none }
        state.isLoading = true
        return .run { send in
            do {
                let response = try await userListClient.getUsers(url: url)
                return await send(.onReceivedResponse(.userList(response)))
            } catch let error {
                return await send(.onReceivedResponse(.error(error)))
            }
        }
    }
    
    private func onReceivedResponse(responseType: Action.OnReceivedResponse, state: inout State) -> Effect<Action> {
        state.isLoading = false
        
        switch responseType {
        case let .userList(response):
            state.userListUrl = GitHubPagination.getNextPageUrl(httpHeaders: response.header)
            state.users.append(
                contentsOf: response.body.compactMap({ UserView.Model(id: uuid(), from: $0) })
            )
        case let .error(error):
            state.destination = .errorAlert(CommonAlert.ErrorFeature.buildAlert(error: error))
        }
        
        return .none
    }
}

private extension UserView.Model {
    init?(id: UUID, from model: GitHubUser) {
        guard let name = model.login else {
            return nil
        }
        self.init(id: id, name: name, avatarURL: URL(string: model.avatarUrl ?? ""))
    }
}
