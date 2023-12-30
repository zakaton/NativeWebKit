//
//  NativeWebKit+HeadphoneMotion.swift
//  NativeWebKit
//
//  Created by Zack Qattan on 12/30/23.
//

import CoreMotion

extension NativeWebKit {
    func handleHeadphoneMotionMessage(_ messgae: NKMessage, messageType: NKHeadphoneMotionMessageType) -> NKResponse? {
        logger.debug("headphoneMotionMessageType \(messageType.name)")

        var response: NKResponse?
        switch messageType {
        case .isEnabled:
            break
        }
        return response
    }
}
