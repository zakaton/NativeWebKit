//
//  NativeWebKit+ARSCNViewDelegate.swift
//  NativeWebKit
//
//  Created by Zack Qattan on 1/6/24.
//

import ARKit

extension NativeWebKit: ARSCNViewDelegate {
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        logger.debug("update \(frame.camera.transform.debugDescription)")
    }

    func sessionWasInterrupted(_ session: ARSession) {
        logger.debug("AR sessionWasInterrupted")
    }

    func sessionInterruptionEnded(_ session: ARSession) {
        logger.debug("AR sessionInterruptionEnded")
    }
}
