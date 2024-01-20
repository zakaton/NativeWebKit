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

        let configurationObservation = arView.session.observe(\.configuration, options: [.new]) { [unowned self] _, _ in
            logger.debug("arSession.configuration updated!")
        }
        observations.append(configurationObservation)
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

    func pauseARSession(dispatchToWebpages: Bool = false) {
        guard isARSessionRunning else {
            logger.warning("ARSession is already not running")
            return
        }
        logger.debug("pausing ARSession...")
        arSession.pause()
        isARSessionRunning = false
        if dispatchToWebpages {
            dispatchMessageToWebpages(arSessionIsRunningMessage)
        }
    }

    func getARTrackingConfiguration(from message: NKMessage) -> ARConfiguration? {
        guard let configurationTypeString = message["type"] as? String else {
            logger.error("no configuration type found in message")
            return nil
        }

        guard let configurationType = NKARSessionConfigurationType(rawValue: configurationTypeString) else {
            logger.error("invalid configuration type \(configurationTypeString)")
            return nil
        }

        var configuration: ARConfiguration?

        switch configurationType {
        case .faceTracking:
            guard ARFaceTrackingConfiguration.isSupported else {
                logger.warning("face tracking is not supported")
                return nil
            }
            let faceTrackingConfiguration = ARFaceTrackingConfiguration()
            faceTrackingConfiguration.maximumNumberOfTrackedFaces = 1
            if let isWorldTrackingEnabled = message["isWorldTrackingEnabled"] as? Bool {
                if ARFaceTrackingConfiguration.supportsWorldTracking {
                    faceTrackingConfiguration.isWorldTrackingEnabled = isWorldTrackingEnabled
                }
                else {
                    logger.warning("ARFaceTrackingConfiguration doesn't support worldTracking")
                }
            }
            configuration = faceTrackingConfiguration
        case .worldTracking:
            guard ARWorldTrackingConfiguration.isSupported else {
                logger.warning("world tracking is not supported")
                return nil
            }
            let worldTrackingConfiguration = ARWorldTrackingConfiguration()
            if let userFaceTrackingEnabled = message["userFaceTrackingEnabled"] as? Bool {
                if ARWorldTrackingConfiguration.supportsUserFaceTracking {
                    worldTrackingConfiguration.userFaceTrackingEnabled = userFaceTrackingEnabled
                }
                else {
                    logger.warning("ARFaceTrackingConfiguration doesn't support worldTracking")
                }
            }
            if let planeDetectionStrings = message["planeDetection"] as? [String] {
                logger.debug("planeDetectionStrings \(planeDetectionStrings, privacy: .public)")
                let planeDetectionArray = planeDetectionStrings.compactMap { ARWorldTrackingConfiguration.PlaneDetection(name: $0) }
                logger.debug("planeDetectionArray \(planeDetectionArray, privacy: .public)")
                let planeDetection: ARWorldTrackingConfiguration.PlaneDetection = .init(planeDetectionArray)
                worldTrackingConfiguration.planeDetection = planeDetection
            }
            configuration = worldTrackingConfiguration
        }

        guard let configuration else {
            logger.debug("unable to create configuration")
            return nil
        }

        // TODO: - any extra configuration stuff
        configuration.isLightEstimationEnabled = true
        configuration.providesAudioData = false

        return configuration
    }
}
