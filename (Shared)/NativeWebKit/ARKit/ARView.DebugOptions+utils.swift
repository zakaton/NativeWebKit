//
//  ARView.DebugOptions+utils.swift
//  (iOS) NativeWebKit
//
//  Created by Zack Qattan on 1/8/24.
//

import ARKit
import RealityKit

extension ARView.DebugOptions {
    var name: String? {
        return switch self {
        case .none:
            "none"
        case .showAnchorGeometry:
            "showAnchorGeometry"
        case .showAnchorOrigins:
            "showAnchorOrigins"
        case .showFeaturePoints:
            "showFeaturePoints"
        case .showPhysics:
            "showPhysics"
        case .showSceneUnderstanding:
            "showSceneUnderstanding"
        case .showStatistics:
            "showStatistics"
        case .showWorldOrigin:
            "showWorldOrigin"
        default:
            nil
        }
    }
}

extension ARView.DebugOptions: CaseIterable {
    public static var allCases: [ARView.DebugOptions] {
        [
            .none,
            .showAnchorGeometry,
            .showAnchorOrigins,
            .showFeaturePoints,
            .showPhysics,
            .showSceneUnderstanding,
            .showStatistics,
            .showWorldOrigin,
        ]
    }
}
