//
//  GitHubRequestHeader.swift
//  GitHubTCA
//
//  Created by Andre on 2024/08/14.
//

import Foundation
import NetworkKit

/// Helper to create GitHub Network Request Header
struct GitHubRequestHeader {
    
    enum Information {
        case authorization(accessToken: String)
        
        var header: (key: String, value: String) {
            switch self {
            case let .authorization(accessToken):
                return (key: "Authorization", value: "Bearer \(accessToken)")
            }
        }
    }
    
    static var common: [String: String] {
        var informations: [Information] = []
        
        if let accessToken = Bundle.main.infoDictionary?["GITHUB_ACCESS_TOKEN"] as? String, !accessToken.isEmpty {
            informations.append(.authorization(accessToken: accessToken))
        }
        
        var headerInformation: [String: String] = [:]
        for headerInfo in informations.map({ $0.header }) {
            headerInformation[headerInfo.key] = headerInfo.value
        }
        return headerInformation
    }
}
