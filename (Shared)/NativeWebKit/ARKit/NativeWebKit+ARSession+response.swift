//
//  NativeWebKit+ARSession+message.swift
//  (iOS) NativeWebKit
//
//  Created by Zack Qattan on 1/9/24.
//

import ARKit
import RealityKit

extension NativeWebKit {
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

    var arSessionBodyTrackingSupportMessage: NKMessage {
        [
            "type": NKARSessionMessageType.bodyTrackingSupport.name,
            "bodyTrackingSupport": [
                "isSupported": ARBodyTrackingConfiguration.isSupported
            ]
        ]
    }

    var arSessionIsRunningMessage: NKMessage {
        [
            "type": NKARSessionMessageType.isRunning.name,
            "isRunning": isARSessionRunning
        ]
    }

    var arSessionConfigurationMessage: NKMessage? {
        guard let arConfigurationType else {
            logger.warning("no configuration type defined")
            return nil
        }

        let configurationInformation: NKMessage?
        switch arConfigurationType {
        case .worldTracking:
            guard let worldTrackingConfiguration = arConfiguration as? ARWorldTrackingConfiguration else {
                logger.error("unable to cast arSession.configuration as ARWorldTrackingConfiguration")
                return nil
            }
            let planeDetectionStrings = ARWorldTrackingConfiguration.PlaneDetection.allCases.filter { worldTrackingConfiguration.planeDetection.contains($0) }.compactMap { $0.name }
            configurationInformation = [
                "userFaceTrackingEnabled": worldTrackingConfiguration.userFaceTrackingEnabled,
                "planeDetection": planeDetectionStrings
            ]
        case .faceTracking:
            guard let faceTrackingConfiguration = arConfiguration as? ARFaceTrackingConfiguration else {
                logger.error("unable to cast arSession.configuration as ARFaceTrackingConfiguration")
                return nil
            }
            configurationInformation = [
                "isWorldTrackingEnabled": faceTrackingConfiguration.isWorldTrackingEnabled,
                "maximumNumberOfTrackedFaces": faceTrackingConfiguration.maximumNumberOfTrackedFaces
            ]
        case .bodyTracking:
            guard let bodyTrackingConfiguration = arConfiguration as? ARBodyTrackingConfiguration else {
                logger.error("unable to cast arSession.configuration as ARBodyTrackingConfiguration")
                return nil
            }
            configurationInformation = [:]
        }

        guard var configurationInformation else {
            logger.error("unable to get configuration information")
            return nil
        }

        configurationInformation["type"] = arConfigurationType.name
        if let arConfiguration, !arConfiguration.frameSemantics.isEmpty {
            let frameSemanticsArray = ARConfiguration.FrameSemantics.allCases.filter { arConfiguration.frameSemantics.contains($0) }
            configurationInformation["frameSemantics"] = frameSemanticsArray.compactMap { $0.name }
        }

        let message: NKMessage = [
            "type": NKARSessionMessageType.configuration.name,
            "configuration": configurationInformation
        ]

        return message
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
        let focalLengthKey = kCGImagePropertyExifFocalLenIn35mmFilm as String
        let focalLength = frame.exifData[focalLengthKey] as! NSNumber

        // can use frame.camera.transform or arView.cameraTransform
        let cameraTransform = arView.cameraTransform
        let cameraMessage: NKMessage = [
            "quaternion": cameraTransform.matrix.quaternion.array,
            "position": cameraTransform.matrix.position.array,
            "eulerAngles": frame.camera.eulerAngles.array,
            "focalLength": focalLength,
            "exposureOffset": frame.camera.exposureOffset
        ]

        var frameMessage: NKMessage = [
            "camera": cameraMessage,
            "timestamp": frame.timestamp
        ]
        if let lightEstimate = frame.lightEstimate {
            var lightEstimateMessage: NKMessage = [
                "ambientIntensity": lightEstimate.ambientIntensity,
                "ambientColorTemperature": lightEstimate.ambientColorTemperature
            ]
            if let directionalLightEstimate = lightEstimate as? ARDirectionalLightEstimate {
                lightEstimateMessage["primaryLightIntensity"] = directionalLightEstimate.primaryLightIntensity
                lightEstimateMessage["primaryLightDirection"] = directionalLightEstimate.primaryLightDirection.array
            }
            frameMessage["lightEstimate"] = lightEstimateMessage
        }

        let faceAnchors = frame.anchors.compactMap { $0 as? ARFaceAnchor }.filter { $0.isTracked }
        var faceAnchorsMessage: [NKMessage]?
        if !faceAnchors.isEmpty {
            faceAnchorsMessage = faceAnchors.map {
                var blendShapesMessage: NKMessage?
                if arSessionMessageConfiguration[.faceAnchorBlendshapes] == true || arSessionMessageConfiguration[.faceAnchorEyes] == true {
                    blendShapesMessage = .init()
                    if arSessionMessageConfiguration[.faceAnchorBlendshapes] == true {
                        for (blendShapeLocation, number) in $0.blendShapes {
                            if let blendShapeLocationName = blendShapeLocation.name {
                                blendShapesMessage![blendShapeLocationName] = number
                            }
                            else {
                                logger.error("no name for blendshape \(blendShapeLocation.rawValue)")
                            }
                        }
                    }
                    else {
                        blendShapesMessage![ARFaceAnchor.BlendShapeLocation.eyeBlinkLeft.name!] = $0.blendShapes[.eyeBlinkLeft]
                        blendShapesMessage![ARFaceAnchor.BlendShapeLocation.eyeBlinkRight.name!] = $0.blendShapes[.eyeBlinkRight]
                    }
                }

                var geometryMessage: NKMessage?
                if arSessionMessageConfiguration[.faceAnchorGeometry] == true {
                    // sending face geometry data can slow things down...
                    if lastTimeSentARFaceAnchorGeometry[$0.identifier] == nil || frame.timestamp - lastTimeSentARFaceAnchorGeometry[$0.identifier]! > 0.02 {
                        lastTimeSentARFaceAnchorGeometry[$0.identifier] = frame.timestamp

                        geometryMessage = .init()
                        geometryMessage!["vertices"] = $0.geometry.vertices.map { $0.array }
                        if didSendARInitialFaceAnchorGeometry[$0.identifier] != true {
                            logger.debug("first time sending face geometry for \($0.identifier.uuidString)")
                            geometryMessage!["triangleCount"] = $0.geometry.triangleCount
                            geometryMessage!["triangleIndices"] = $0.geometry.triangleIndices
                            geometryMessage!["textureCoordinates"] = $0.geometry.textureCoordinates.map { $0.array }
                            didSendARInitialFaceAnchorGeometry[$0.identifier] = true
                        }
                    }
                }

                var quaternion: simd_quatf?
                if arConfigurationType == .worldTracking {
                    // quaternion for faceAnchor when using worldTracking is incorrect
                    quaternion = $0.transform.quaternion2
                }
                else {
                    quaternion = $0.transform.quaternion
                }
                var message = [
                    "identifier": $0.identifier.uuidString,
                    "position": $0.transform.position.array,
                    "quaternion": quaternion!.array
                ]
                if arSessionMessageConfiguration[.faceAnchorEyes] == true {
                    message["leftEye"] = [
                        "position": $0.leftEyeTransform.position.array,
                        "quaternion": $0.leftEyeTransform.quaternion.array
                    ]
                    message["rightEye"] = [
                        "position": $0.rightEyeTransform.position.array,
                        "quaternion": $0.rightEyeTransform.quaternion.array
                    ]
                    message["lookAtPoint"] = $0.lookAtPoint.array
                }
                if let blendShapesMessage {
                    message["blendShapes"] = blendShapesMessage
                }
                if let geometryMessage {
                    message["geometry"] = geometryMessage
                }

                return message
            }
        }

        if let faceAnchorsMessage {
            frameMessage["faceAnchors"] = faceAnchorsMessage
        }

        let planeAnchors = frame.anchors.compactMap { $0 as? ARPlaneAnchor }
        var planeAnchorsMessage: [NKMessage]?
        if !planeAnchors.isEmpty {
            planeAnchorsMessage = planeAnchors.map {
                let planeExtent = $0.planeExtent
                let planeExtentMessage: NKMessage = [
                    "height": planeExtent.height,
                    "width": planeExtent.width,
                    "rotationOnYAxis": planeExtent.rotationOnYAxis
                ]
                let message = [
                    "identifier": $0.identifier.uuidString,
                    "position": $0.transform.position.array,
                    "center": $0.center.array,
                    "quaternion": $0.transform.quaternion.array,
                    "classification": $0.classification.name,
                    "planeExtent": planeExtentMessage
                    // "alignment": $0.alignment.name
                ]
                return message
            }
        }
        if let planeAnchorsMessage {
            frameMessage["planeAnchors"] = planeAnchorsMessage
        }

        let bodyAnchors = frame.anchors.compactMap { $0 as? ARBodyAnchor }
        var bodyAnchorsMessage: [NKMessage]?
        if !bodyAnchors.isEmpty {
            bodyAnchorsMessage = bodyAnchors.map { bodyAnchor in
                var skeletonMessage: NKMessage = [:]
                bodyAnchor.skeleton.definition.jointNames.enumerated().forEach { index, jointName in
                    if bodyAnchor.skeleton.isJointTracked(index) {
                        let transform = bodyAnchor.skeleton.jointLocalTransforms[index]
                        skeletonMessage[jointName] = [
                            "position": transform.position.array,
                            "quaternion": transform.quaternion.array
                        ]
                    }
                }

                let message = [
                    "identifier": bodyAnchor.identifier.uuidString,
                    "isTracked": bodyAnchor.isTracked,
                    "position": bodyAnchor.transform.position.array,
                    "quaternion": bodyAnchor.transform.quaternion.array,
                    "estimatedScaleFactor": bodyAnchor.estimatedScaleFactor,
                    "skeleton": skeletonMessage
                ]
                return message
            }
        }
        if let bodyAnchorsMessage {
            frameMessage["bodyAnchors"] = bodyAnchorsMessage
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

    var arViewShowCameraMessage: NKMessage {
        [
            "type": NKARSessionMessageType.showCamera.name,
            "showCamera": showARCamera
        ]
    }

    var arSessionMessageConfigurationMessage: NKMessage {
        [
            "type": NKARSessionMessageType.messageConfiguration.name,
            "messageConfiguration": arSessionMessageConfiguration.json
        ]
    }
}
