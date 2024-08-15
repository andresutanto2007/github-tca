//
//  GitHubUserDetail.swift
//  GitHubTCA
//
//  Created by Andre on 2024/08/15.
//

import Foundation

struct GitHubUserDetail: Decodable {
    let login: String?
    let avatarUrl: String?
    let followers: Int?
    let following: Int?
    let name: String?
    
    enum CodingKeys: String, CodingKey {
        case login
        case avatarUrl = "avatar_url"
        case followers
        case following
        case name
    }
}
