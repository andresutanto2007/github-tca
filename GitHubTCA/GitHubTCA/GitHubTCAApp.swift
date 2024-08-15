//
//  GitHubTCAApp.swift
//  GitHubTCA
//
//  Created by Andre on 2024/08/15.
//

import ComposableArchitecture
import SwiftUI

@main
struct GitHubTCAApp: App {
    private let store = Store(initialState: UserListFeature.State()) {
        UserListFeature()
    }
    
    var body: some Scene {
        WindowGroup {
            if !isTesting {
                NavigationStackWrapper {
                    UserListView(store: store)
                }
            }
        }
    }
}
