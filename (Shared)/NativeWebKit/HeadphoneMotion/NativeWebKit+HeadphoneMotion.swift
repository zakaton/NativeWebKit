//
//  NativeWebKit+HeadphoneMotion.swift
//  NativeWebKit
//
//  Created by Zack Qattan on 12/30/23.
//

import CoreMotion

extension NativeWebKit {
    func handleHeadphoneMotionMessage(_ message: NKMessage, messageType: NKHeadphoneMotionMessageType) -> NKResponse? {
        logger.debug("headphoneMotionMessageType \(messageType.name, privacy: .public)")

        var response: NKResponse?
        switch messageType {
        case .isAvailable:
            response = headphoneMotionIsAvailableMessage
        case .isActive:
            response = headphoneMotionIsActiveMessage
        case .startUpdates:
            if !headphoneMotionManager.isDeviceMotionActive {
                if context == .app {
                    headphoneMotionManager.startDeviceMotionUpdates(to: .init(), withHandler: onMotionData)
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

    func onMotionData(deviceMotion: CMDeviceMotion?, error: Error?) {
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
}
