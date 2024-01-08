//
//  NativeWebKit+ARSession.swift
//  NativeWebKit
//
//  Created by Zack Qattan on 1/6/24.
//

import ARKit
import Foundation
import RealityKit

extension NativeWebKit {
    func setupARView(_ arView: ARView) {
        arView.session.delegate = self
    }

    var arSession: ARSession { arView.session }

    func handleARSessionMessage(_ message: NKMessage, messageType: NKARSessionMessageType) -> NKResponse? {
        logger.debug("ARSessionMessageType \(messageType.id, privacy: .public)")

        var response: NKResponse?
        switch messageType {
        case .worldTrackingSupport:
            response = arSessionWorldTrackingSupportMessage
        case .faceTrackingSupport:
            response = arSessionFaceTrackingSupportMessage
        case .run:
            guard ARFaceTrackingConfiguration.isSupported else {
                logger.warning("face tracking is not supported")
                return nil
            }
            if isARSessionRunning {
                logger.warning("ARSession is already running - will reset")
                arSession.pause()
                isARSessionRunning = false
            }
            let configuration = ARFaceTrackingConfiguration()
            configuration.maximumNumberOfTrackedFaces = 1
            configuration.isWorldTrackingEnabled = true
            arSession.run(configuration, options: [.resetTracking, .removeExistingAnchors])
            isARSessionRunning = true
            response = arSessionIsRunningMessage
        case .isRunning:
            response = arSessionIsRunningMessage
        case .pause:
            guard isARSessionRunning else {
                logger.log("ARSession is not running - no need to pause")
                return nil
            }
            arSession.pause()
            isARSessionRunning = false
            response = arSessionIsRunningMessage
        case .frame:
            guard isARSessionRunning else {
                logger.log("ARSession is not running")
                return nil
            }
            guard let frame = arSession.currentFrame else {
                logger.log("no ARFrame available")
                return nil
            }
            response = arSessionFrameMessage(frame: frame)
        }
        return response
    }

    var arSessionWorldTrackingSupportMessage: NKMessage {
        [
            "type": NKARSessionMessageType.worldTrackingSupport.name,
            "worldTrackingSupport": [
                "isSupported": ARWorldTrackingConfiguration.isSupported,
                "supportsUserFaceTracking": ARWorldTrackingConfiguration.supportsUserFaceTracking
            ]
        ]
    }

    var arSessionFaceTrackingSupportMessage: NKMessage {
        [
            "type": NKARSessionMessageType.faceTrackingSupport.name,
            "faceTrackingSupport": [
                "isSupported": ARFaceTrackingConfiguration.isSupported,
                "supportsWorldTracking": ARFaceTrackingConfiguration.supportsWorldTracking
            ]
        ]
    }

    var arSessionIsRunningMessage: NKMessage {
        [
            "type": NKARSessionMessageType.isRunning.name,
            "isRunning": isARSessionRunning
        ]
    }

    func arSessionFrameMessage(frame: ARFrame) -> NKMessage {
        // can use frame.camera.transform or arView.cameraTransform
        let cameraTransform = arView.cameraTransform
        var message: NKMessage = [
            "type": NKARSessionMessageType.frame.name,
            "frame": [
                "camera": [
                    "quaternion": cameraTransform.matrix.quaternion.array,
                    "position": cameraTransform.matrix.position.array,
                    "eulerAngles": frame.camera.eulerAngles.array
                ]
            ]
        ]
        let faceAnchors = frame.anchors.compactMap { $0 as? ARFaceAnchor }.filter { $0.isTracked }
        logger.debug("face anchors? \(faceAnchors.count)")
        return message
    }
}
