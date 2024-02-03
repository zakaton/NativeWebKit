//
//  NativeWebKit+HeadphoneMotion+response.swift
//  NativeWebKit
//
//  Created by Zack Qattan on 2/2/24.
//

import CoreMotion

extension NativeWebKit {
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
}
