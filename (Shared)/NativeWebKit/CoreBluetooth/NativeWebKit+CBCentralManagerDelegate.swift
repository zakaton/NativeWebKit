//
//  NativeWebKit+CBCentralManagerDelegate.swift
//  NativeWebKit
//
//  Created by Zack Qattan on 1/29/24.
//

import CoreBluetooth

extension NativeWebKit: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        logger.debug("centralManagerDidUpdateState \(central.state.name, privacy: .public)")
        #if IN_APP
        dispatchMessageToWebpages(coreBluetoothStateMessage, activeOnly: true)
        #endif
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        logger.debug("centralManager didDiscover \(peripheral.name ?? peripheral.identifier.uuidString, privacy: .public)")

        let discoveredDevice: NKCoreBluetoothDiscoveredDevice = .init(peripheral: peripheral, rssi: RSSI, advertisementData: advertisementData)

        cbDiscoveredDevices.replaceOrAppend(discoveredDevice, firstMatchingKeyPath: \.peripheral)

        #if IN_APP
        dispatchMessageToWebpages(coreBluetoothDiscoveredDeviceMessage(discoveredDevice: discoveredDevice), activeOnly: true)
        #else
        cbUpdatedDiscoveredDevices.insert(peripheral.identifier)
        #endif
    }
}