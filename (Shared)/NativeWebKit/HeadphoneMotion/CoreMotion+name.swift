//
//  CoreMotion+name.swift
//  NativeWebKit
//
//  Created by Zack Qattan on 1/1/24.
//

import CoreMotion

extension CMDeviceMotion.SensorLocation {
    var name: String {
        switch self {
        case .default:
            "default"
        case .headphoneLeft:
            "left headphone"
        case .headphoneRight:
            "right headphone"
        @unknown default:
            "unknown"
        }
    }
}
