//
//  UserListClient.swift
//  GitHubTCA
//
//  Created by Andre on 2024/08/14.
//

import Foundation
import ComposableArchitecture
import NetworkKit

@DependencyClient
struct UserListClient {
    var getUsers: (_ url: String) async throws -> NetworkResponse<[GitHubUser]>
}

extension UserListClient: DependencyKey {
    static let liveValue = UserListClient(
        getUsers: { url in
            let request = NetworkRequest(
                url: url, httpMethod: .get,
                header: GitHubRequestHeader.common
            )
            return try await NetworkManager.request(request)
        }
    )
}

extension DependencyValues {
    var userListClient: UserListClient {
        get { self[UserListClient.self] }
        set { self[UserListClient.self] = newValue }
    }
}
