//
//  ARFaceAnchor.BlendShapeLocation+utils.swift
//  (iOS) NativeWebKit
//
//  Created by Zack Qattan on 1/8/24.
//

import ARKit

extension ARFaceAnchor.BlendShapeLocation {
    var name: String? {
        return switch self {
        case .browDownLeft:
            "browDownLeft"
        case .browDownRight:
            "browDownRight"
        case .browInnerUp:
            "browInnerUp"
        case .browOuterUpLeft:
            "browOuterUpLeft"
        case .browOuterUpRight:
            "browOuterUpRight"
        case .cheekPuff:
            "cheekPuff"
        case .cheekSquintLeft:
            "cheekSquintLeft"
        case .cheekSquintRight:
            "cheekSquintRight"
        case .eyeBlinkLeft:
            "eyeBlinkLeft"
        case .eyeBlinkRight:
            "eyeBlinkRight"
        case .eyeLookDownLeft:
            "eyeLookDownLeft"
        case .eyeLookDownRight:
            "eyeLookDownRight"
        case .eyeLookInLeft:
            "eyeLookInLeft"
        case .eyeLookInRight:
            "eyeLookInRight"
        case .eyeLookOutLeft:
            "eyeLookOutLeft"
        case .eyeLookOutRight:
            "eyeLookOutRight"
        case .eyeLookUpLeft:
            "eyeLookUpLeft"
        case .eyeLookUpRight:
            "eyeLookUpRight"
        case .eyeSquintLeft:
            "eyeSquintLeft"
        case .eyeSquintRight:
            "eyeSquintRight"
        case .eyeWideLeft:
            "eyeWideLeft"
        case .eyeWideRight:
            "eyeWideRight"
        case .jawForward:
            "jawForward"
        case .jawLeft:
            "jawLeft"
        case .jawOpen:
            "jawOpen"
        case .jawRight:
            "jawRight"
        case .mouthClose:
            "mouthClose"
        case .mouthDimpleLeft:
            "mouthDimpleLeft"
        case .mouthDimpleRight:
            "mouthDimpleRight"
        case .mouthFrownLeft:
            "mouthFrownLeft"
        case .mouthFrownRight:
            "mouthFrownRight"
        case .mouthFunnel:
            "mouthFunnel"
        case .mouthLeft:
            "mouthLeft"
        case .mouthLowerDownLeft:
            "mouthLowerDownLeft"
        case .mouthLowerDownRight:
            "mouthLowerDownRight"
        case .mouthPressLeft:
            "mouthPressLeft"
        case .mouthPressRight:
            "mouthPressRight"
        case .mouthPucker:
            "mouthPucker"
        case .mouthRight:
            "mouthRight"
        case .mouthRollLower:
            "mouthRollLower"
        case .mouthRollUpper:
            "mouthRollUpper"
        case .mouthShrugLower:
            "mouthShrugLower"
        case .mouthShrugUpper:
            "mouthShrugUpper"
        case .mouthSmileLeft:
            "mouthSmileLeft"
        case .mouthSmileRight:
            "mouthSmileRight"
        case .mouthStretchLeft:
            "mouthStretchLeft"
        case .mouthStretchRight:
            "mouthStretchRight"
        case .mouthUpperUpLeft:
            "mouthUpperUpLeft"
        case .mouthUpperUpRight:
            "mouthUpperUpRight"
        case .noseSneerLeft:
            "noseSneerLeft"
        case .noseSneerRight:
            "noseSneerRight"
        case .tongueOut:
            "tongueOut"
        default:
            nil
        }
    }
}
