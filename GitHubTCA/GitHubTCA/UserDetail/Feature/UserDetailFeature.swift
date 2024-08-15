//
//  UserDetailFeature.swift
//  GitHubTCA
//
//  Created by Andre on 2024/08/15.
//

import Foundation
import NetworkKit
import ComposableArchitecture

@Reducer
struct UserDetailFeature {
    @ObservableState
    struct State: Equatable {
        let username: String
        var isLoading: Bool = false
        var model: UserDetailView.Model = .init(fullname: "-", followers: 0, following: 0, avatarURL: nil)
        @Presents var errorAlert: CommonAlert.ErrorFeature.State?
    }
    
    enum Action {
        case didLoad
        case onReceivedResponse(OnReceivedResponse)
        case errorAlert(PresentationAction<CommonAlert.ErrorFeature.Action>)
        
        enum OnReceivedResponse {
            case userDetail(NetworkResponse<GitHubUserDetail>)
            case error(Error)
        }
    }
    
    @Dependency(\.userDetailClient) var userDetailClient
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .didLoad:
                return fetchUserDetail(state: &state)
            case let .onReceivedResponse(responseType):
                return onReceivedResponse(responseType: responseType, state: &state)
            case .errorAlert(.presented(.onTapRefreshButton)):
                return fetchUserDetail(state: &state)
            case .errorAlert:
                return .none
            }
        }
        .ifLet(\.$errorAlert, action: \.errorAlert)
    }
    
    private func fetchUserDetail(state: inout State) -> Effect<Action> {
        guard !state.isLoading else { return .none }
        state.isLoading = true
        let username = state.username
        return .run { send in
            do {
                let response = try await userDetailClient.getUserDetail(username: username)
                await send(.onReceivedResponse(.userDetail(response)))
            } catch let error {
                await send(.onReceivedResponse(.error(error)))
            }
        }
    }
    
    private func onReceivedResponse(responseType: Action.OnReceivedResponse, state: inout State) -> Effect<Action> {
        state.isLoading = false
        
        switch responseType {
        case let .userDetail(response):
            state.model = UserDetailView.Model(from: response.body)
        case let .error(error):
            state.errorAlert = CommonAlert.ErrorFeature.buildAlert(error: error)
        }
        
        return .none
    }
}

private extension UserDetailView.Model {
    init(from model: GitHubUserDetail) {
        self.init(
            fullname: model.name ?? "-",
            followers: model.followers ?? 0,
            following: model.following ?? 0,
            avatarURL: URL(string: model.avatarUrl ?? "")
        )
    }
}
