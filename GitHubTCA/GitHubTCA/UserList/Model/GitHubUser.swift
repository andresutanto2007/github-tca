//
//  GitHubUser.swift
//  GitHubTCA
//
//  Created by Andre on 2024/08/14.
//

import Foundation

struct GitHubUser: Decodable {
    let login: String?
    let avatarUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case login
        case avatarUrl = "avatar_url"
    }
}
