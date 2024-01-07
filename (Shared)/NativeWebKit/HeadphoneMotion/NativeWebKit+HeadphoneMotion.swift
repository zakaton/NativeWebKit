//
//  NativeWebKit+HeadphoneMotion.swift
//  NativeWebKit
//
//  Created by Zack Qattan on 12/30/23.
//

import CoreMotion

extension NativeWebKit {
    func setupHeadphoneMotionManager(_ headphoneMotionManager: CMHeadphoneMotionManager) {
        headphoneMotionManager.delegate = self

        /*
         TODO: - figure out how to observe \.isDeviceMotionAvailable
         If you startDeviceMotionUpdates(), it doesn't trigger the headphoneMotionManagerDidConnect() event if there's no headphones connected.
         This is fine if you're in Safari, but if you're in the app and don't poll for updates it doesn't trigger the "isActive" javascript event
         */
        let isAvailableObservation = headphoneMotionManager.observe(\.isDeviceMotionAvailable, options: [.new]) { [unowned self] _, _ in
            logger.debug("headphoneMotionManager.isDeviceMotionAvailable updated")
            onHeadphoneMotionManagerIsAvailableUpdate()
        }
        observations.append(isAvailableObservation)

        let isActiveObservation = headphoneMotionManager.observe(\.isDeviceMotionActive, options: [.new]) { [unowned self] _, _ in
            logger.debug("headphoneMotionManager.isDeviceMotionActive updated")
            onHeadphoneMotionManagerIsActiveUpdate()
        }
        observations.append(isActiveObservation)
    }

    func handleHeadphoneMotionMessage(_ message: NKMessage, messageType: NKHeadphoneMotionMessageType) -> NKResponse? {
        logger.debug("headphoneMotionMessageType \(messageType.id, privacy: .public)")

        var response: NKResponse?
        switch messageType {
        case .isAvailable:
            response = headphoneMotionIsAvailableMessage
        case .isActive:
            response = headphoneMotionIsActiveMessage
        case .startUpdates:
            if !headphoneMotionManager.isDeviceMotionActive {
                if context == .app {
                    headphoneMotionManager.startDeviceMotionUpdates(to: .init(), withHandler: onHeadphoneMotionData)
                }
                else {
                    headphoneMotionManager.startDeviceMotionUpdates()
                }
            }
            else {
                logger.warning("headphoneMotionManager is already active")
            }
        case .stopUpdates:
            if headphoneMotionManager.isDeviceMotionActive {
                headphoneMotionManager.stopDeviceMotionUpdates()
            }
            else {
                logger.warning("headphoneMotionManager is not active")
            }
        case .getData:
            guard headphoneMotionManager.isDeviceMotionActive else {
                logger.warning("headphoneMotionManager is not active")
                return nil
            }
            guard let timestamp = message["timestamp"] as? Double else {
                logger.error("no timestamp was included in message")
                return nil
            }
            guard let deviceMotion = headphoneMotionManager.deviceMotion else {
                logger.log("no device motion found")
                return nil
            }
            guard timestamp != deviceMotion.timestamp else {
                logger.log("no new device motion data since last time")
                return nil
            }
            response = headphoneMotionDataMessage(deviceMotion: deviceMotion)
        }
        return response
    }

    var headphoneMotionIsAvailableMessage: NKMessage {
        [
            "type": NKHeadphoneMotionMessageType.isAvailable.name,
            "isAvailable": headphoneMotionManager.isDeviceMotionAvailable
        ]
    }

    var headphoneMotionIsActiveMessage: NKMessage {
        [
            "type": NKHeadphoneMotionMessageType.isActive.name,
            "isActive": headphoneMotionManager.isDeviceMotionActive
        ]
    }

    func headphoneMotionDataMessage(deviceMotion: CMDeviceMotion) -> NKMessage {
        [
            "type": NKHeadphoneMotionMessageType.getData.name,
            "motionData": [
                "timestamp": deviceMotion.timestamp,
                "sensorLocation": deviceMotion.sensorLocation.name,
                "quaternion": deviceMotion.attitude.quaternion.array,
                "userAcceleration": deviceMotion.userAcceleration.array,
                "gravity": deviceMotion.gravity.array,
                "rotationRate": deviceMotion.rotationRate.array,
                "euler": deviceMotion.attitude.array
            ]
        ]
    }

    func onHeadphoneMotionData(deviceMotion: CMDeviceMotion?, error: Error?) {
        if let error {
            logger.error("\(error.localizedDescription)")
            return
        }

        guard let deviceMotion else {
            logger.error("no deviceMotion data found")
            return
        }

        #if IN_APP
        dispatchMessageToWebpages(headphoneMotionDataMessage(deviceMotion: deviceMotion))
        #endif
    }

    func onHeadphoneMotionManagerIsAvailableUpdate() {
        #if IN_APP
        dispatchMessageToWebpages(headphoneMotionIsAvailableMessage)
        #endif
    }

    func onHeadphoneMotionManagerIsActiveUpdate() {
        #if IN_APP
        dispatchMessageToWebpages(headphoneMotionIsActiveMessage)
        #endif
    }
}
