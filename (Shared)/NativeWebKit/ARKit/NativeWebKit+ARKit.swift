//
//  NativeWebKit+ARKit.swift
//  (iOS) NativeWebKit
//
//  Created by Zack Qattan on 2/2/24.
//

import ARKit
import Foundation
import RealityKit

extension NativeWebKit {
    var arSession: ARSession { arView.session }

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
                    logger.warning("ARWorldTrackingConfiguration doesn't support faceTracking")
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
        case .bodyTracking:
            guard ARBodyTrackingConfiguration.isSupported else {
                logger.warning("body tracking is not supported")
                return nil
            }
            let bodyTrackingConfiguration = ARBodyTrackingConfiguration()
            bodyTrackingConfiguration.automaticSkeletonScaleEstimationEnabled = true
            configuration = bodyTrackingConfiguration
        }

        guard let configuration else {
            logger.debug("unable to create configuration")
            return nil
        }

        if let frameSemanticsStrings = message["frameSemantics"] as? [String] {
            logger.debug("frameSemanticsStrings \(frameSemanticsStrings, privacy: .public)")
            let frameSemanticsArray = frameSemanticsStrings.compactMap { ARConfiguration.FrameSemantics(name: $0) }
            logger.debug("frameSemanticsArray \(frameSemanticsArray, privacy: .public)")
            let frameSemantics: ARConfiguration.FrameSemantics = .init(frameSemanticsArray)
            configuration.frameSemantics = frameSemantics
        }

        // TODO: - any extra configuration stuff
        configuration.isLightEstimationEnabled = true
        configuration.providesAudioData = false

        return configuration
    }
}
