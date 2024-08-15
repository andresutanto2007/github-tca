//
//  NetworkKitError.swift
//  NetworkKit
//
//  Created by Andre on 2024/08/14.
//

import Foundation

public enum NetworkKitError: Error, LocalizedError {
    case invalidJSON(Error)
    case invalidUrl
    case invalidQueryParameter
    case serverError
    case invalidCredentials
    case unknownError
    
    public var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return String.localized("error_description_invalid_credentials")
        default:
            return String.localized("error_description_common")
        }
    }
}
