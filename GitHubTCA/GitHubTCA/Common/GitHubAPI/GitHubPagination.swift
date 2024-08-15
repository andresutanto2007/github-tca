//
//  GitHubPagination.swift
//  GitHubTCA
//
//  Created by Andre on 2024/08/14.
//

import Foundation

struct GitHubPagination {
    static func getNextPageUrl(httpHeaders: [AnyHashable: Any]) -> String? {
        guard let linkHeader = httpHeaders["Link"] as? String else {
            return nil
        }
        return extractNextPageUrl(from: linkHeader)
    }
    
    private static func extractNextPageUrl(from linkHeader: String) -> String? {
        let nextPageRegex: String = "<([^>]+)>;\\s*rel=\"next\""
        guard let regex = try? NSRegularExpression(pattern: nextPageRegex, options: []),
              let match = regex.firstMatch(in: linkHeader, options: [], range: NSRange(linkHeader.startIndex..<linkHeader.endIndex, in: linkHeader)),
              let range = Range(match.range(at: 1), in: linkHeader) else {
            return nil
        }
        return String(linkHeader[range])
    }
}
