//
//  ARView.CameraMode+utils.swift
//  (iOS) NativeWebKit
//
//  Created by Zack Qattan on 1/8/24.
//

import RealityKit

extension ARView.CameraMode {
    var name: String {
        return switch self {
        case .ar:
            "ar"
        case .nonAR:
            "nonAR"
        @unknown default:
            "unknown"
        }
    }
}

extension ARView.CameraMode: CaseIterable {
    public static var allCases: [ARView.CameraMode] {
        [.ar, .nonAR]
    }

    init?(name: String) {
        guard let cameraMode = Self.allCases.first(where: { $0.name == name }) else {
            return nil
        }
        self = cameraMode
    }
}
