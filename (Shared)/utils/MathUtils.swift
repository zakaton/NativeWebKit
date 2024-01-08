//
//  MathUtils.swift
//  (iOS) NativeWebKit
//
//  Created by Zack Qattan on 1/7/24.
//

import simd

extension simd_float3 {
    var array: [Float] {
        [x, y, z]
    }
}

extension simd_float4 {
    var array: [Float] {
        [x, y, z, w]
    }
}

extension simd_quatf {
    var array: [Float] {
        vector.array
    }
}

extension simd_float4x4 {
    var position: simd_float3 {
        let col = columns.3
        return .init(x: col.x, y: col.y, z: col.z)
    }

    var quaternion: simd_quatf {
        .init(self)
    }
}
