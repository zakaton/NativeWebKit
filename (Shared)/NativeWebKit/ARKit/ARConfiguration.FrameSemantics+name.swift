//
//  ARConfiguration.FrameSemantics+name.swift
//  (iOS) NativeWebKit
//
//  Created by Zack Qattan on 1/21/24.
//

import ARKit

extension ARConfiguration.FrameSemantics {
    var name: String? {
        switch self {
        case .bodyDetection:
            "bodyDetection"
        default:
            nil
        }
    }
}

extension ARConfiguration.FrameSemantics: CaseIterable {
    public static var allCases: [ARConfiguration.FrameSemantics] {
        [.bodyDetection]
    }

    init?(name: String) {
        guard let frameSemantic = Self.allCases.first(where: { $0.name == name }) else {
            return nil
        }
        self = frameSemantic
    }
}
