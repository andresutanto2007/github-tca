//
//  GitHubRepository.swift
//  GitHubTCA
//
//  Created by Andre on 2024/08/15.
//

import Foundation

struct GitHubRepository: Decodable {
    let name: String?
    let htmlUrl: String?
    let description: String?
    let stargazersCount: Int?
    let language: String?
    
    enum CodingKeys: String, CodingKey {
        case name
        case htmlUrl = "html_url"
        case description
        case stargazersCount = "stargazers_count"
        case language
    }
}
