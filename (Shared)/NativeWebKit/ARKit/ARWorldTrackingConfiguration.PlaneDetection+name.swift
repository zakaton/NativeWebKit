//
//  ARWorldTrackingConfiguration.PlaneDetection+name.swift
//  (iOS) NativeWebKit
//
//  Created by Zack Qattan on 1/20/24.
//

import ARKit

extension ARWorldTrackingConfiguration.PlaneDetection {
    var name: String {
        switch self {
        case .horizontal:
            "horizontal"
        case .vertical:
            "vertical"
        default:
            "unknown"
        }
    }
}

extension ARWorldTrackingConfiguration.PlaneDetection: CaseIterable {
    public static var allCases: [ARWorldTrackingConfiguration.PlaneDetection] {
        [.horizontal, .vertical]
    }

    init?(name: String) {
        guard let planeDetection = Self.allCases.first(where: { $0.name == name }) else {
            return nil
        }
        self = planeDetection
    }
}
