//
//  NativeWebKit+CBPeripheralDelegate.swift
//  NativeWebKit
//
//  Created by Zack Qattan on 1/31/24.
//

import CoreBluetooth

extension NativeWebKit: CBPeripheralDelegate {
    func peripheralDidUpdateName(_ peripheral: CBPeripheral) {
        logger.debug("peripheralDidUpdateName \(peripheral.identifier.uuidString, privacy: .public): \(peripheral.name ?? "NO_NAME", privacy: .public)")
    }

    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        logger.debug("didReadRSSI \(peripheral.name ?? peripheral.identifier.uuidString, privacy: .public) \(RSSI, privacy: .public)")

        if cbPeripherals[peripheral.identifierString] != nil {
            cbPeripherals[peripheral.identifierString]!.rssi = RSSI

            #if IN_APP
            dispatchMessageToWebpages(cbPeripheralRSSIsMessage(peripherals: [peripheral]))
            #endif
        }
    }
}
