//
//  UserDetailView.swift
//  GitHubTCA
//
//  Created by Andre on 2024/08/15.
//

import SwiftUI
import ComposableArchitecture

struct UserDetailView: View {
    @Perception.Bindable var store: StoreOf<UserDetailFeature>
    
    var body: some View {
        WithPerceptionTracking {
            VStack {
                HStack(spacing: 32.0) {
                    AvatarView(imageURL: store.model.avatarURL)
                    followerView
                    followingView
                }
                fullnameView
            }
            .frame(maxWidth: .infinity)
            .task {
                store.send(.didLoad)
            }
            .alert($store.scope(state: \.errorAlert, action: \.errorAlert))
        }
    }
    
    @ViewBuilder
    private var fullnameView: some View {
        if store.isLoading {
            ProgressView()
                .frame(maxWidth: .infinity, alignment: .leading)
        } else {
            Text(store.model.fullname)
                .font(.subheadline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityIdentifier(AccessibilityElement.fullname.id)
        }
    }
    
    @ViewBuilder
    private var followerView: some View {
        VStack {
            if store.isLoading {
                ProgressView()
            } else {
                Text(String(store.model.followers))
                    .lineLimit(1)
                    .font(.callout)
                    .accessibilityIdentifier(AccessibilityElement.followersCount.id)
            }
            Text("user_detail_followers")
                .lineLimit(1)
                .font(.caption)
                .accessibilityIdentifier(AccessibilityElement.followers.id)
        }
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    private var followingView: some View {
        VStack {
            if store.isLoading {
                ProgressView()
            } else {
                Text(String(store.model.following))
                    .lineLimit(1)
                    .font(.callout)
                    .accessibilityIdentifier(AccessibilityElement.followingCount.id)
            }
            Text("user_detail_following")
                .lineLimit(1)
                .font(.caption)
                .accessibilityIdentifier(AccessibilityElement.following.id)
        }
        .frame(maxWidth: .infinity)
    }
}

extension UserDetailView {
    enum AccessibilityElement: ElementIdentifiable {
        var parent: String { "userDetailView" }
        
        case fullname
        case followersCount
        case followers
        case followingCount
        case following
    }
}

extension UserDetailView {
    struct Model: Equatable {
        let fullname: String
        let followers: Int
        let following: Int
        let avatarURL: URL?
        
        init(fullname: String, followers: Int, following: Int, avatarURL: URL?) {
            self.fullname = fullname
            self.followers = followers
            self.following = following
            self.avatarURL = avatarURL
        }
    }
}
