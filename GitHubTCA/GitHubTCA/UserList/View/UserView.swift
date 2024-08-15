//
//  UserView.swift
//  GitHubTCA
//
//  Created by Andre on 2024/08/14.
//

import SwiftUI

struct UserView: View {
    
    private let model: UserView.Model
    
    init(_ model: UserView.Model) {
        self.model = model
    }
    
    var body: some View {
        HStack(alignment: .center) {
            AvatarView(imageURL: model.avatarURL)
                .accessibilityIdentifier(AccessibilityElement.avatar.id)
            Text(model.name)
                .accessibilityIdentifier(AccessibilityElement.name.id)
        }
    }
}

extension UserView {
    enum AccessibilityElement: ElementIdentifiable {
        var parent: String { "userView" }
        case avatar
        case name
    }
}

extension UserView {
    struct Model: Identifiable, Equatable {
        let id: UUID
        let name: String
        let avatarURL: URL?
        
        init(id: UUID = UUID(), name: String, avatarURL: URL?) {
            self.id = id
            self.name = name
            self.avatarURL = avatarURL
        }
    }
}
