//
//  ARPlaneAnchor.Classification+name.swift
//  (iOS) NativeWebKit
//
//  Created by Zack Qattan on 1/20/24.
//

import ARKit

extension ARPlaneAnchor.Classification {
    var name: String {
        switch self {
        case .none(let status):
            switch status {
            case .notAvailable:
                "notAvailable"
            case .undetermined:
                "undetermined"
            case .unknown:
                "unknown"
            @unknown default:
                "unknown"
            }
        case .wall:
            "wall"
        case .floor:
            "floor"
        case .ceiling:
            "ceiling"
        case .table:
            "table"
        case .seat:
            "seat"
        case .window:
            "window"
        case .door:
            "door"
        @unknown default:
            "unknown"
        }
    }
}
