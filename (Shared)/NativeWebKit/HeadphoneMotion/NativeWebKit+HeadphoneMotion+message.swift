//
//  NativeWebKit+HeadphoneMotion+message.swift
//  NativeWebKit
//
//  Created by Zack Qattan on 2/2/24.
//

import CoreMotion

extension NativeWebKit {
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
}
