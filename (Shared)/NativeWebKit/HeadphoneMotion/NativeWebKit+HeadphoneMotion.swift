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
