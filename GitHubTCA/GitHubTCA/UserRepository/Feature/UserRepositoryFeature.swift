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
        @Presents var webView: CommonWebViewFeature.State?
        
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
        case webView(PresentationAction<CommonWebViewFeature.Action>)
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
                guard let htmlUrl = repository.htmlUrl else {
                    return .none
                }
                state.webView = CommonWebViewFeature.State(url: htmlUrl, title: repository.name)
                return .none
            case let .searchedText(text):
                state.searchedText = text
                return .none
            default:
                return .none
            }
        }
        .ifLet(\.$webView, action: \.webView) {
            CommonWebViewFeature()
        }
    }
}
