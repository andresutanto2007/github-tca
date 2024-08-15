//
//  Bundle+Extension.swift
//  NetworkKit
//
//  Created by Andre on 2024/08/14.
//

import Foundation

extension Bundle {
    static var current: Bundle {
        class __ { }
        return Bundle(for: __.self)
    }
}
