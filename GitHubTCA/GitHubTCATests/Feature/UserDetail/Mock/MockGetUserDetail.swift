//
//  MockGetUserDetail.swift
//  GitHubTCATests
//
//  Created by Andre on 2024/08/15.
//

import Foundation

enum MockGetUserDetail: MockItem {
    
    case success
    case successMissingFields
    
    var fileName: String {
        switch self {
        case .success: return "getUserDetail"
        case .successMissingFields: return "getUserDetail_missingFields"
        }
    }
    
    var urlResponse: URLResponse { URLResponse() }
    var extensionName: String { "json" }
}
