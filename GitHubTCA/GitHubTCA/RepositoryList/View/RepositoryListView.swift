//
//  RepositoryListView.swift
//  GitHubTCA
//
//  Created by Andre on 2024/08/15.
//

import ComposableArchitecture
import SwiftUI

struct RepositoryListView: View {
    @Perception.Bindable var store: StoreOf<RepositoryListFeature>
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.isSearching) private var isSearching
    
    private var repositoryGridColumns: [GridItem] {
        let numberOfColumns = horizontalSizeClass == .regular ? 2 : 1
        return Array(repeating: GridItem(.flexible()), count: numberOfColumns)
    }
    
    var body: some View {
        WithPerceptionTracking {
            VStack {
                if store.repositories.isEmpty && !store.isLoading {
                    Text("repository_list_empty")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .accessibilityIdentifier(AccessibilityElement.emptyRepository.id)
                } else {
                    LazyVGrid(columns: repositoryGridColumns) {
                        ForEach(store.repositories) { repository in
                            RepositoryView(repository)
                                .frame(height: 120, alignment: .top)
                                .padding(8)
                                .cardBackground()
                                .onAppear {
                                    store.send(.onAppearRepository(repository))
                                }
                                .onTapGesture {
                                    store.send(.onTapRepository(repository))
                                }
                                .accessibilityElement(children: .contain)
                                .accessibilityIdentifier(AccessibilityElement.repository.id)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .top)
                    if store.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .task {
                store.send(.didLoad)
            }
            .onChange(of: isSearching) { isSearching in
                if !isSearching {
                    store.send(.onSubmitSearch(""))
                }
            }
            .alert($store.scope(state: \.errorAlert, action: \.errorAlert))
        }
    }
}

extension RepositoryListView {
    enum AccessibilityElement: ElementIdentifiable {
        var parent: String { "repositoryListView" }
        
        case emptyRepository
        case repository
    }
}
