//
//  ARPlaneAnchor.Alignment+name.swift
//  (iOS) NativeWebKit
//
//  Created by Zack Qattan on 1/21/24.
//

import ARKit

extension ARPlaneAnchor.Alignment {
    var name: String? {
        switch self {
        case .horizontal:
            "horizontal"
        case .vertical:
            "vertical"
        @unknown default:
            nil
        }
    }
}
