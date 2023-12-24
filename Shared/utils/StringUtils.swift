//
//  StringUtils.swift
//  NativeWebKit
//
//  Created by Zack Qattan on 12/24/23.
//

import Foundation

extension String {
    func removePrefix(_ prefix: String) -> String {
        if hasPrefix(prefix) {
            return .init(dropFirst(prefix.count))
        }
        return self
    }

    func replacePrefix(_ prefix: String, with newPrefix: String) -> String {
        if hasPrefix(prefix) {
            return newPrefix + removePrefix(prefix)
        }
        return self
    }
}
