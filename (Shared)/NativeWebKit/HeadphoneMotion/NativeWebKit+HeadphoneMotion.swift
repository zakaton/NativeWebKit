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
            response = ["isAvailable": headphoneMotionManager.isDeviceMotionAvailable]
        case .isActive:
            response = ["isActive": headphoneMotionManager.isDeviceMotionActive]
        case .startUpdates:
            if context == .app {
                headphoneMotionManager.startDeviceMotionUpdates(to: .init(), withHandler: onMotionData)
            }
            else {
                headphoneMotionManager.startDeviceMotionUpdates()
            }
            response = [
                "type": NKHeadphoneMotionMessageType.isActive.name,
                "isActive": headphoneMotionManager.isDeviceMotionActive
            ]
        case .stopUpdates:
            headphoneMotionManager.stopDeviceMotionUpdates()
            response = [
                "type": NKHeadphoneMotionMessageType.isActive.name,
                "isActive": headphoneMotionManager.isDeviceMotionActive
            ]
        case .getData:
            if headphoneMotionManager.isDeviceMotionActive,
               let timestamp = message["timestamp"] as? Double,
               let deviceMotion = headphoneMotionManager.deviceMotion,
               timestamp != deviceMotion.timestamp
            {
                response = [
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
            else {
                logger.debug("no headphone deviceMotion to return")
            }
        }
        return response
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

        // TODO: - FILL
        logger.debug("motion data :)")
    }
}
