//
//  UserRepositoryView.swift
//  GitHubTCA
//
//  Created by Andre on 2024/08/15.
//

import SwiftUI
import ComposableArchitecture

struct UserRepositoryView: View {
    @Perception.Bindable var store: StoreOf<UserRepositoryFeature>
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.dismiss) private var dismiss
    
    private var repositoryGridColumns: [GridItem] {
        let numberOfColumns = horizontalSizeClass == .regular ? 2 : 1
        return Array(repeating: GridItem(.flexible()), count: numberOfColumns)
    }
    
    private var maxRepositoryCardHeight: CGFloat {
        return horizontalSizeClass == .regular ? 300 : .infinity
    }
    
    var body: some View {
        WithPerceptionTracking {
            VStack {
                Divider()
                ScrollView {
                    VStack(alignment: .leading) {
                        UserDetailView(store: store.scope(state: \.userDetail, action: \.userDetail))
                        RepositoryListView(store: store.scope(state: \.repositoryList, action: \.repositoryList))
                    }
                    .padding(16)
                    .frame(alignment: .top)
                }
            }
            .searchable(text: $store.searchedText.sending(\.searchedText), placement: .navigationBarDrawer)
            .onSubmit(of: .search) {
                store.send(.repositoryList(.onSubmitSearch(store.searchedText)))
            }
            .navigationTitle(store.username)
            .toolbar {
                ToolbarItem(placement: .destructiveAction) {
                    Button("toolbar_close") {
                        dismiss()
                    }
                    .accessibilityIdentifier(AccessibilityElement.toolbarClose.id)
                }
            }
        }
    }
}

extension UserRepositoryView {
    enum AccessibilityElement: ElementIdentifiable {
        var parent: String { "userRepositoryView" }
        case toolbarClose
    }
}
