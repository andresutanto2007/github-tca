//
//  UserListView.swift
//  GitHubTCA
//
//  Created by Andre on 2024/08/14.
//

import ComposableArchitecture
import SwiftUI

struct UserListView: View {
    @Perception.Bindable var store: StoreOf<UserListFeature>
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    private var userGridColumns: [GridItem] {
        let numberOfColumns = horizontalSizeClass == .regular ? 3 : 1
        return Array(repeating: GridItem(.flexible()), count: numberOfColumns)
    }
    
    var body: some View {
        WithPerceptionTracking {
            ScrollView {
                VStack(alignment: .center) {
                    LazyVGrid(columns: userGridColumns) {
                        ForEach(store.users) { user in
                            UserView(user)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(8)
                                .cardBackground()
                                .onAppear {
                                    store.send(.onAppearUser(user))
                                }
                                .onTapGesture {
                                    store.send(.onTapUser(user))
                                }
                                .accessibilityElement(children: .contain)
                                .accessibilityIdentifier(AccessibilityElement.user.id)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    if store.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                .padding(16)
            }
            .task {
                store.send(.didLoad)
            }
            .navigationTitle("user_list_title")
            .sheet(item: $store.scope(state: \.destination?.userRepository, action: \.destination.userRepository)) { store in
                NavigationStackWrapper {
                    UserRepositoryView(store: store)
                }
            }
            .alert($store.scope(state: \.destination?.errorAlert, action: \.destination.errorAlert))
        }
    }
}

extension UserListView {
    enum AccessibilityElement: ElementIdentifiable {
        var parent: String { "userListView" }
        case user
    }
}
