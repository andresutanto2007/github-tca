//
//  RepositoryView.swift
//  GitHubTCA
//
//  Created by Andre on 2024/08/15.
//

import SwiftUI

struct RepositoryView: View {
    private let model: RepositoryView.Model
    
    init(_ model: RepositoryView.Model) {
        self.model = model
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                VStack(alignment: .leading) {
                    Text(model.name)
                        .font(.title3)
                        .accessibilityIdentifier(AccessibilityElement.name.id)
                    Text(model.language)
                        .font(.caption)
                        .accessibilityIdentifier(AccessibilityElement.language.id)
                }
                Spacer()
                Text(String(model.star) + "⭐️")
                    .font(.title3)
                    .accessibilityIdentifier(AccessibilityElement.star.id)
            }.frame(maxWidth: .infinity)
            Divider()
            Text(model.description)
                .font(.footnote)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityIdentifier(AccessibilityElement.description.id)
        }
    }
}

extension RepositoryView {
    enum AccessibilityElement: ElementIdentifiable {
        var parent: String { "repositoryView" }
        
        case name
        case language
        case star
        case description
    }
}

extension RepositoryView {
    struct Model: Identifiable, Equatable {
        let id: UUID
        let name: String
        let language: String
        let star: Int
        let description: String
        let htmlUrl: URL?
        
        init(id: UUID = UUID(), name: String, language: String, star: Int, description: String, htmlUrl: URL?) {
            self.id = id
            self.name = name
            self.language = language
            self.star = star
            self.description = description
            self.htmlUrl = htmlUrl
        }
    }
}
