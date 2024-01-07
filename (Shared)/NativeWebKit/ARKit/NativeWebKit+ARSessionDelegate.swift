//
//  NativeWebKit+ARSessionDelegate.swift
//  NativeWebKit
//
//  Created by Zack Qattan on 1/6/24.
//

import ARKit

extension NativeWebKit: ARSessionDelegate {
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        logger.debug("update \(frame.camera.transform.debugDescription)")
    }

    func session(_ session: ARSession, didFailWithError error: Error) {
        logger.error("arSession didFailWithError \(error.localizedDescription)")
    }

    func sessionWasInterrupted(_ session: ARSession) {
        logger.debug("AR sessionWasInterrupted")
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        logger.debug("AR sessionInterruptionEnded")
    }
}
