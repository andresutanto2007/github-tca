//
//  UserDetailClient.swift
//  GitHubTCA
//
//  Created by Andre on 2024/08/15.
//

import Foundation
import ComposableArchitecture
import NetworkKit

@DependencyClient
struct UserDetailClient {
    var getUserDetail: (_ username: String) async throws -> NetworkResponse<GitHubUserDetail>
}

extension UserDetailClient: DependencyKey {
    static let liveValue = UserDetailClient(
        getUserDetail: { username in
            let request = NetworkRequest(
                url: "https://api.github.com/users/\(username)", httpMethod: .get,
                header: GitHubRequestHeader.common
            )
            return try await NetworkManager.request(request)
        }
    )
}

extension DependencyValues {
    var userDetailClient: UserDetailClient {
        get { self[UserDetailClient.self] }
        set { self[UserDetailClient.self] = newValue }
    }
}
