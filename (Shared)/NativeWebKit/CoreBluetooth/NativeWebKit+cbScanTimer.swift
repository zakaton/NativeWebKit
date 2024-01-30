//
//  NativeWebKit+cbScanTimer.swift
//  NativeWebKit
//
//  Created by Zack Qattan on 1/29/24.
//

import Foundation

extension NativeWebKit {
    func cbStartScanTimer() {
        guard cbScanTimer == nil else {
            logger.warning("cbScanTimer is already running")
            return
        }
        cbScanTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(cbCheckDevices), userInfo: nil, repeats: true)
        cbScanTimer?.tolerance = 0.2
    }

    func cbStopScanTimer() {
        guard cbScanTimer != nil else {
            logger.warning("no cbScanTimer to stop")
            return
        }

        cbScanTimer!.invalidate()
        cbScanTimer = nil
    }

    @objc func cbCheckDevices() {
        cbDiscoveredDevices.removeAll(where: {
            $0.peripheral.state == .disconnected && $0.dateCreated.timeIntervalSinceNow < -4
        })

        cbUpdatedDiscoveredDevices = cbUpdatedDiscoveredDevices.filter { identifier in
            cbDiscoveredDevices.contains { $0.peripheral.identifier == identifier }
        }
    }
}
