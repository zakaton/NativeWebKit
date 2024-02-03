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
    func handleARSessionMessage(_ message: NKMessage, messageType: NKARSessionMessageType) -> NKResponse? {
        logger.debug("ARSessionMessageType \(messageType.id, privacy: .public)")

        var response: NKResponse?
        switch messageType {
        case .worldTrackingSupport:
            response = arSessionWorldTrackingSupportMessage
        case .faceTrackingSupport:
            response = arSessionFaceTrackingSupportMessage
        case .bodyTrackingSupport:
            response = arSessionBodyTrackingSupportMessage
        case .run:
            guard let configurationMessage = message["configuration"] as? NKMessage
            else {
                logger.error("no configuration found in message")
                return nil
            }

            guard let configuration = getARTrackingConfiguration(from: configurationMessage) else {
                logger.error("unable to create configuration")
                return nil
            }

            arConfiguration = configuration

            if isARSessionRunning {
                logger.warning("ARSession is already running - will reset")
                pauseARSession()
            }
            arSession.run(arConfiguration!, options: [
                .removeExistingAnchors,
                .resetSceneReconstruction,
                .resetTracking,
                .stopTrackedRaycasts
            ])
            isARSessionRunning = true
            response = wrapMultipleMessages(arSessionIsRunningMessage, arSessionConfigurationMessage)
        case .isRunning:
            response = arSessionIsRunningMessage
        case .configuration:
            response = arSessionConfigurationMessage
        case .pause:
            guard isARSessionRunning else {
                logger.log("ARSession is not running - no need to pause")
                return nil
            }
            pauseARSession()
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
        case .showCamera:
            if let newShowARCamera = message["showCamera"] as? Bool {
                if newShowARCamera != showARCamera {
                    logger.debug("updating showARCamera to \(newShowARCamera)")
                    showARCamera = newShowARCamera
                    arView.environment.background = showARCamera ? .cameraFeed() : .color(.clear)
                }
            }
            response = arViewShowCameraMessage
        case .messageConfiguration:
            guard let newMessageConfiguration = message["messageConfiguration"] as? [String: Bool] else {
                logger.debug("no messageConfiguration found")
                return nil
            }
            newMessageConfiguration.forEach { rawFlag, enabled in
                guard let flag: NKARSessionMessageConfigurationFlag = .init(rawValue: rawFlag) else {
                    logger.error("invalid NKARSessionMessageConfigurationFlag flag \(rawFlag)")
                    return
                }
                arSessionMessageConfiguration[flag] = enabled
            }
            let _arSessionMessageConfiguration = arSessionMessageConfiguration
            logger.debug("new arSessionMessageConfiguration \(_arSessionMessageConfiguration, privacy: .public)")
            response = arSessionMessageConfigurationMessage
        }

        return response
    }
}
