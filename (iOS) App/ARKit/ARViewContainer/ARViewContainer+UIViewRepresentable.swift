//
//  ARViewContainer+UIViewRepresentable.swift
//  (iOS) NativeWebKit
//
//  Created by Zack Qattan on 1/7/24.
//

import ARKit
import RealityKit
import SwiftUI

extension ARViewContainer: UIViewRepresentable {
    typealias UIViewType = ARView

    func makeUIView(context: Context) -> ARView {
        makeView()
    }

    func updateUIView(_ uiView: ARView, context: Context) {}
}
