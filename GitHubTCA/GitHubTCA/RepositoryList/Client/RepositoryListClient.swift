//
//  RepositoryListClient.swift
//  GitHubTCA
//
//  Created by Andre on 2024/08/15.
//

import Foundation
import ComposableArchitecture
import NetworkKit

@DependencyClient
struct RepositoryListClient {
    var searchRepositories: (_ query: GitHubSearchQuery, _ itemPerPage: Int, _ page: Int) async throws -> NetworkResponse<GitHubSearch<GitHubRepository>>
}

extension RepositoryListClient: DependencyKey {
    static let liveValue = RepositoryListClient(
        searchRepositories: { query, itemPerPage, page in
            let request = NetworkRequest(
                url: "https://api.github.com/search/repositories", httpMethod: .get,
                header: GitHubRequestHeader.common,
                queryParameter: [
                    "q": query.build(),
                    "per_page": "\(itemPerPage)",
                    "page": "\(page)"
                ]
            )
            return try await NetworkManager.request(request)
        }
    )
}

extension DependencyValues {
    var repositoryListClient: RepositoryListClient {
        get { self[RepositoryListClient.self] }
        set { self[RepositoryListClient.self] = newValue }
    }
}
