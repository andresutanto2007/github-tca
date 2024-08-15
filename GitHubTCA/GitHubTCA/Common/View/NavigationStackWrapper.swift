//
//  NavigationStackWrapper.swift
//  GitHubTCA
//
//  Created by Andre on 2024/08/14.
//

import SwiftUI

struct NavigationStackWrapper<Content>: View where Content: View {
    private var content: Content
    
    init(
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
    }
    
    var body: some View {
        if #available(iOS 16, macOS 13, tvOS 16, watchOS 9, visionOS 1, *) {
            NavigationStack {
                content
            }
        } else {
            // Support previous platform versions.
            NavigationView {
                content
            }
            .navigationViewStyle(.stack)
        }
    }
}
