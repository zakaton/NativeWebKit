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
        dispatchMessageToWebpages(cbCentralStateMessage, activeOnly: true)
        #endif
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        logger.debug("centralManager didDiscover \(peripheral.name ?? peripheral.identifier.uuidString, privacy: .public)")

        let discoveredPeripheral: NKCBDiscoveredPeripheral = .init(peripheral: peripheral, rssi: RSSI, advertisementData: advertisementData)

        cbDiscoveredPeripherals.updateValue(discoveredPeripheral, forKey: discoveredPeripheral.identifier)

        #if IN_APP
        dispatchMessageToWebpages(cbCentralDiscoveredPeripheralMessage(discoveredPeripheral: discoveredPeripheral), activeOnly: true)
        #else
        cbUpdatedDiscoveredPeripherals.insert(peripheral.identifier.uuidString)
        #endif
    }

    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String: Any]) {
        logger.debug("will restore state \(dict.debugDescription)")
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        logger.debug("did connect to peripheral \(peripheral.name ?? peripheral.identifier.uuidString, privacy: .public)")

        #if IN_APP
        dispatchMessageToWebpages(cbPeripheralConnectionStateMessage(peripheral: peripheral))
        #endif
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        logger.debug("failed to connect to peripheral \(peripheral.name ?? peripheral.identifierString, privacy: .public): \(error?.localizedDescription ?? "no error")")
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        logger.debug("did disconnect from peripheral \(peripheral.name ?? peripheral.identifierString, privacy: .public): \(error?.localizedDescription ?? "no error")")

        cbPeripherals.removeValue(forKey: peripheral.identifier.uuidString)

        #if IN_APP
        let message = cbPeripheralConnectionStateMessage(peripheral: peripheral)
        dispatchMessageToWebpages(message)
        #else
        cbDisconnectedPeripherals.insert(peripheral.identifier.uuidString)
        #endif
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, timestamp: CFAbsoluteTime, isReconnecting: Bool, error: Error?) {
        logger.debug("did disconnect from peripheral \(peripheral.name ?? peripheral.identifierString, privacy: .public) at \(timestamp, privacy: .public) (reconnecting? \(isReconnecting, privacy: .public): \(error?.localizedDescription ?? "no error")")
    }
}
