//
//  MathUtils.swift
//  NativeWebKit
//
//  Created by Zack Qattan on 1/7/24.
//

import simd

extension simd_float3 {
    var array: [Float] {
        [x, y, z]
    }
}

extension simd_float2 {
    var array: [Float] {
        [x, y]
    }
}

extension simd_float4 {
    var array: [Float] {
        [x, y, z, w]
    }

    var array3: simd_float3 {
        [x, y, z]
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

    var quaternion2: simd_quatf {
        /*
         Getting the usual quaternion from a faceAnchor's matrix is completely off.
         I was able to get the right quaternion values from the matrix using THREE.js's Matrix4.decompose.
         So I'm just gonna recreate it here...
         */

        // https://github.com/mrdoob/three.js/blob/master/src/math/Matrix4.js#L732
        var sx = simd_length(simd_float3(columns.0.array3))
        let sy = simd_length(simd_float3(columns.1.array3))
        let sz = simd_length(simd_float3(columns.2.array3))

        if determinant < 0 {
            sx *= -1
        }

        var _m1: simd_float4x4 = .init(columns: (columns.0, columns.1, columns.2, columns.3))

        let invSX = 1 / sx
        let invSY = 1 / sy
        let invSZ = 1 / sz

        _m1.columns.0.x *= invSX
        _m1.columns.0.y *= invSX
        _m1.columns.0.z *= invSX

        _m1.columns.1.x *= invSY
        _m1.columns.1.y *= invSY
        _m1.columns.1.z *= invSY

        _m1.columns.2.x *= invSZ
        _m1.columns.2.y *= invSZ
        _m1.columns.2.z *= invSZ

        return .init(_m1)
    }

    var array: [[Float]] {
        [columns.0.array, columns.1.array, columns.2.array, columns.3.array]
    }
}
