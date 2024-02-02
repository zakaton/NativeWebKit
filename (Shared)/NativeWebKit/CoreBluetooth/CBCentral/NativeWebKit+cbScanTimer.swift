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
        logger.debug("started cbScanTimer")

        cbDiscoveredPeripherals.removeAll(keepingCapacity: true)

        cbScanTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(cbCheckDevices), userInfo: nil, repeats: true)
        cbScanTimer?.tolerance = 0.2
    }

    func cbStopScanTimer() {
        guard cbScanTimer != nil else {
            logger.warning("no cbScanTimer to stop")
            return
        }
        logger.debug("stopped cbScanTimer")

        cbScanTimer!.invalidate()
        cbScanTimer = nil
    }

    @objc func cbCheckDevices() {
        cbDiscoveredPeripherals = cbDiscoveredPeripherals.filter {
            $0.value.peripheral.state == .disconnected && $0.value.lastTimeUpdated.timeIntervalSinceNow < -4
        }

        cbUpdatedDiscoveredPeripherals = cbUpdatedDiscoveredPeripherals.filter { identifier in
            cbDiscoveredPeripherals.contains { $0.key == identifier }
        }
    }
}
