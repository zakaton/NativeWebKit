//
//  NKARSessionMessageConfiguration.swift
//  (iOS) NativeWebKit
//
//  Created by Zack Qattan on 1/15/24.
//

import Foundation

enum NKARSessionMessageConfigurationFlag: String, CaseIterable {
    var name: String { rawValue }
    case faceAnchorBlendshapes
    case faceAnchorGeometry
}

typealias NKARSessionMessageConfiguration = [NKARSessionMessageConfigurationFlag: Bool]

extension NKARSessionMessageConfiguration {
    var json: [String: Bool] {
        var message: [String: Bool] = [:]
        self.forEach { flag, enabled in
            message[flag.rawValue] = enabled
        }
        return message
    }
}
