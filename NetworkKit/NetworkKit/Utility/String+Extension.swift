//
//  String+Extension.swift
//  NetworkKit
//
//  Created by Andre on 2024/08/14.
//

import Foundation

extension String {
    static func localized(_ resource: String.LocalizationValue) -> String {
        return String(localized: resource, bundle: Bundle.current)
    }
}
