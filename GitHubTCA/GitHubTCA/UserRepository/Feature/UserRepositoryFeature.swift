//
//  UserRepositoryFeature.swift
//  GitHubTCA
//
//  Created by Andre on 2024/08/15.
//

import Foundation
import NetworkKit
import ComposableArchitecture

@Reducer
struct UserRepositoryFeature {
    @ObservableState
    struct State: Equatable {
        let username: String
        var userDetail: UserDetailFeature.State
        var repositoryList: RepositoryListFeature.State
        var searchedText: String = ""
        
        init(username: String) {
            self.username = username
            self.userDetail = UserDetailFeature.State(username: username)
            self.repositoryList = RepositoryListFeature.State(username: username)
        }
    }
    
    enum Action {
        case userDetail(UserDetailFeature.Action)
        case repositoryList(RepositoryListFeature.Action)
        case searchedText(String)
    }
    
    var body: some ReducerOf<Self> {
        Scope(state: \.userDetail, action: \.userDetail) {
            UserDetailFeature()
        }
        Scope(state: \.repositoryList, action: \.repositoryList) {
            RepositoryListFeature()
        }
        Reduce { state, action in
            switch action {
            case let .repositoryList(.onTapRepository(repository)):
                // TODO: Open webview
                return .none
            case let .searchedText(text):
                state.searchedText = text
                return .none
            default:
                return .none
            }
        }
    }
}
