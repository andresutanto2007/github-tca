//
//  MockSearchRepositories.swift
//  GitHubTCATests
//
//  Created by Andre on 2024/08/15.
//

import Foundation

enum MockSearchRepositories: MockItem {
    
    case successIsLastPage
    case successHasNextPage
    case successMissingFields
    
    var fileName: String {
        switch self {
        case .successIsLastPage: return "searchRepositories_isLastPage"
        case .successHasNextPage: return "searchRepositories_hasNextPage"
        case .successMissingFields: return "searchRepositories_missingFields"
        }
    }
    
    var urlResponse: URLResponse { URLResponse() }
    var extensionName: String { "json" }
}
