//
//  CoreMotion+array.swift
//  NativeWebKit
//
//  Created by Zack Qattan on 1/1/24.
//

import CoreMotion

extension CMQuaternion {
    var array: [Double] {
        [x, z, -y, w]
    }
}

extension CMAttitude {
    var array: [Double] {
        [pitch, yaw, -roll]
    }
}

extension CMAcceleration {
    var array: [Double] {
        [x, z, -y]
    }
}

extension CMRotationRate {
    var array: [Double] {
        [x, z, -y]
    }
}
