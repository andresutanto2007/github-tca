//
//  ElementIdentifiable.swift
//  GitHubTCA
//
//  Created by Andre on 2024/08/14.
//

protocol ElementIdentifiable {
    var parent: String { get }
    var id: String { get }
}

extension ElementIdentifiable {
    var id: String {
        return "\(parent).\(self)"
    }
}
