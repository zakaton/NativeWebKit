//
//  NativeWebKit+CMHeadphoneMotionManagerDelegate.swift
//  NativeWebKit
//
//  Created by Zack Qattan on 12/30/23.
//

import CoreMotion

extension NativeWebKit: CMHeadphoneMotionManagerDelegate {
    func headphoneMotionManagerDidConnect(_ manager: CMHeadphoneMotionManager) {
        logger.debug("headphoneMotionManagerDidConnect")
        onHeadphoneMotionManagerConnectionUpdate()
    }

    func headphoneMotionManagerDidDisconnect(_ manager: CMHeadphoneMotionManager) {
        logger.debug("headphoneMotionManagerDidDisconnect")
        onHeadphoneMotionManagerConnectionUpdate()
    }

    func onHeadphoneMotionManagerConnectionUpdate() {
        #if IN_APP
        dispatchMessageToWebpages(headphoneMotionIsActiveMessage)
        #endif
    }
}
