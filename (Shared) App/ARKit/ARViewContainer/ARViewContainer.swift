//
//  ARViewContainer.swift
//  NativeWebKit
//
//  Created by Zack Qattan on 1/7/24.
//

import ARKit
import OSLog
import RealityKit
import SwiftUI
import UkatonMacros

@StaticLogger
struct ARViewContainer {
    var arView: ARView { NativeWebKit.shared.arView }

    func makeView() -> ARView {
        arView
    }
}
