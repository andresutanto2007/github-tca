//
//  GitHubSearchQuery.swift
//  GitHubTCA
//
//  Created by Andre on 2024/08/15.
//

import Foundation

struct GitHubSearchQuery {
    /// Query
    let query: String
    
    /// Filter by username
    let username: String?
    
    func build() -> String {
        var filters: [String: String] = [:]
        if let username {
            filters["user"] = username
        }
        
        guard !filters.isEmpty else {
            return query
        }
        
        var parameters: [String] = [query]
        parameters.append(contentsOf: filters.compactMap({ $0.key + ":" + $0.value }))
        return parameters.joined(separator: "+")
    }
}
