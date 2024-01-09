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
        arView.renderOptions.formUnion(.init([
            .disableHDR,
            .disableFaceMesh,
            .disableMotionBlur,
            .disableCameraGrain,
            .disablePersonOcclusion,
            .disableGroundingShadows,
            .disableDepthOfField,
            .disableAREnvironmentLighting
        ]))
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
//            let configuration = ARWorldTrackingConfiguration()
//            configuration.sceneReconstruction = .meshWithClassification
//            configuration.userFaceTrackingEnabled = true
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
        case .debugOptions:
            if let newDebugOptions = message["debugOptions"] as? [String: Bool] {
                logger.debug("new debug options: \(newDebugOptions, privacy: .public)")
                ARView.DebugOptions.allCases.forEach { debugOption in
                    if let enableDebugOption = newDebugOptions[debugOption.name!] {
                        if enableDebugOption {
                            arView.debugOptions.insert(debugOption)
                        }
                        else {
                            arView.debugOptions.remove(debugOption)
                        }
                    }
                }
            }
            response = arSessionDebugOptionsMessage
        case .cameraMode:
            if let cameraModeName = message["cameraMode"] as? String,
               let cameraMode: ARView.CameraMode = .init(name: cameraModeName),
               cameraMode != arView.cameraMode
            {
                logger.debug("updating camera mode to \(cameraMode.name)")
                arView.cameraMode = cameraMode
                arCameraModeSubject.send(cameraMode)
            }
            response = arViewCameraModeMessage
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

    var arSessionDebugOptionsMessage: NKMessage {
        let debugOptions = arView.debugOptions
        var debugOptionsMessage: NKMessage = [:]
        ARView.DebugOptions.allCases.forEach {
            debugOptionsMessage[$0.name!] = debugOptions.contains($0)
        }

        let message: NKMessage = [
            "type": NKARSessionMessageType.debugOptions.name,
            "debugOptions": debugOptionsMessage
        ]
        return message
    }

    func arSessionFrameMessage(frame: ARFrame) -> NKMessage {
        let focalLengthKey = kCGImagePropertyExifFocalLength as String
        let focalLength = frame.exifData[focalLengthKey] as! NSNumber

        // can use frame.camera.transform or arView.cameraTransform
        let cameraTransform = arView.cameraTransform
        let cameraMessage: NKMessage = [
            "quaternion": cameraTransform.matrix.quaternion.array,
            "position": cameraTransform.matrix.position.array,
            "eulerAngles": frame.camera.eulerAngles.array,
            "focalLength": focalLength
        ]

        var frameMessage: NKMessage = [
            "camera": cameraMessage
        ]

        let faceAnchors = frame.anchors.compactMap { $0 as? ARFaceAnchor }.filter { $0.isTracked }
        var faceAnchorsMessage: [NKMessage]?
        if !faceAnchors.isEmpty {
            faceAnchorsMessage = faceAnchors.map {
                var blendShapesMessage: NKMessage = [:]
                for (blendShapeLocation, number) in $0.blendShapes {
                    if let blendShapeLocationName = blendShapeLocation.name {
                        blendShapesMessage[blendShapeLocationName] = number
                    }
                    else {
                        logger.error("no name for blendshape \(blendShapeLocation.rawValue)")
                    }
                }
                let message = [
                    "identifier": $0.identifier.uuidString,
                    "lookAtPoint": $0.lookAtPoint.array,
                    "position": $0.transform.position.array,
                    "quaternion": $0.transform.quaternion.array,
                    "leftEye": [
                        "position": $0.leftEyeTransform.position.array,
                        "quaternion": $0.leftEyeTransform.quaternion.array
                    ],
                    "rightEye": [
                        "position": $0.rightEyeTransform.position.array,
                        "quaternion": $0.rightEyeTransform.quaternion.array
                    ],
                    "blendShapes": blendShapesMessage
                ]
                return message
            }
        }

        if let faceAnchorsMessage {
            frameMessage["faceAnchors"] = faceAnchorsMessage
        }

        let message: NKMessage = [
            "type": NKARSessionMessageType.frame.name,
            "frame": frameMessage
        ]

        return message
    }

    var arViewCameraModeMessage: NKMessage {
        [
            "type": NKARSessionMessageType.cameraMode.name,
            "cameraMode": arView.cameraMode.name
        ]
    }
}
