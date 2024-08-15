//
//  MockGetUsers.swift
//  GitHubTCATests
//
//  Created by Andre on 2024/08/14.
//

import Foundation

enum MockGetUsers: MockItem {
    
    case successIsLastPage
    case successHasNextPage
    case successPartialMissingFields
    
    var fileName: String {
        switch self {
        case .successIsLastPage, .successHasNextPage: return "getUsers"
        case .successPartialMissingFields: return "getUsers_partialMissingFields"
        }
    }
    
    var urlResponse: URLResponse {
        switch self {
        case .successIsLastPage, .successPartialMissingFields: return URLResponse()
        case .successHasNextPage:
            return HTTPURLResponse(
                url: URL(string: "https://api.github.com/users")!,
                statusCode: 200, httpVersion: nil,
                headerFields: [
                    "Link": "<https://api.github.com/repositories/1300192/issues?page=2>; rel=\"prev\", <https://api.github.com/repositories/1300192/issues?page=4>; rel=\"next\", <https://api.github.com/repositories/1300192/issues?page=515>; rel=\"last\", <https://api.github.com/repositories/1300192/issues?page=1>; rel=\"first\""
                ]
            )!
        }
    }
    
    var extensionName: String { "json" }
}
