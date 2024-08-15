//
//  GitHubSearch.swift
//  GitHubTCA
//
//  Created by Andre on 2024/08/15.
//

import Foundation

struct GitHubSearch<Item: Decodable>: Decodable {
    let totalCount: Int?
    let items: [Item]
    
    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case items
    }
}
