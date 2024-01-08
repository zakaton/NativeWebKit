//
//  NativeWebKit+ARSessionDelegate.swift
//  NativeWebKit
//
//  Created by Zack Qattan on 1/6/24.
//

import ARKit

extension NativeWebKit: ARSessionDelegate {
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        #if IN_APP
        dispatchMessageToWebpages(arSessionFrameMessage(frame: frame), activeOnly: true)
        #endif
    }

    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        // logger.debug("didAdd anchors")
    }

    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        // logger.debug("didUpdate anchors")
    }

    func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
        // logger.debug("didRemove anchors")
    }

    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        logger.debug("cameraDidChangeTrackingState")
    }

    func sessionWasInterrupted(_ session: ARSession) {
        logger.debug("AR sessionWasInterrupted")
    }

    func sessionInterruptionEnded(_ session: ARSession) {
        logger.debug("AR sessionInterruptionEnded")
    }

    func session(_ session: ARSession, didFailWithError error: Error) {
        logger.error("arSession didFailWithError \(error.localizedDescription)")
    }
}
