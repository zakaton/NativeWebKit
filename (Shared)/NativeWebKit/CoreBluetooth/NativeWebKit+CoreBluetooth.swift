//
//  NativeWebKit+CoreBluetooth.swift
//  NativeWebKit
//
//  Created by Zack Qattan on 1/29/24.
//

import CoreBluetooth

extension NativeWebKit {
    func handleCoreBluetoothMessage(_ message: NKMessage, messageType: NKCoreBluetoothMessageType) -> NKResponse? {
        logger.debug("coreBluetoothMessageType \(messageType.id, privacy: .public)")

        var response: NKResponse?
        switch messageType {
        case .state:
            response = coreBluetoothStateMessage
        case .isScanning:
            response = coreBluetoothIsScanningMessage
        case .startScan:
            let scanOptions = message["scanOptions"] as? NKMessage
            cbStartScan(scanOptions: scanOptions)
            response = coreBluetoothIsScanningMessage
        case .discoveredDevices:
            response = coreBluetoothDiscoveredDevicesMessage
        case .discoveredDevice:
            // only used for messaging from the app directly into the webpage
            break
        case .stopScan:
            cbCentralManager.stopScan()
            response = coreBluetoothIsScanningMessage
        }
        return response
    }

    func cbStartScan(scanOptions: NKMessage?) {
        if cbCentralManager.isScanning {
            logger.debug("already scanning - resetting")
            cbStopScan()
        }

        if let scanOptions {
            logger.debug("scanOptions: \(scanOptions, privacy: .public)")
            let serviceUUIDStrings = scanOptions["serviceUUIDs"] as? [String]
            let serviceUUIDs = serviceUUIDStrings?.filter { !$0.isEmpty }.compactMap { CBUUID(string: $0) }
            if let serviceUUIDs {
                logger.debug("scanning serviceUUIDs \(serviceUUIDs, privacy: .public)")
            }
            var options: [String: Any] = [:]
            if let optionsDict = scanOptions["options"] as? [String: Any] {
                if let allowDuplicates = optionsDict["allowDuplicates"] as? Bool {
                    options[CBCentralManagerScanOptionAllowDuplicatesKey] = allowDuplicates
                }
                if let solicitedServiceUUIDStrings = optionsDict["solicitedServiceUUIDs"] as? [String] {
                    let solicitedServiceUUIDs = solicitedServiceUUIDStrings.filter { !$0.isEmpty }.compactMap { CBUUID(string: $0) }
                    if !solicitedServiceUUIDs.isEmpty {
                        options[CBCentralManagerScanOptionSolicitedServiceUUIDsKey] = solicitedServiceUUIDStrings
                    }
                }
                logger.debug("scanning with options \(options.debugDescription, privacy: .public)")
            }
            cbCentralManager.scanForPeripherals(withServices: serviceUUIDs, options: options)
        }
        else {
            logger.debug("scanning with no options")
            cbCentralManager.scanForPeripherals(withServices: nil)
        }

        cbStartScanTimer()
    }

    func cbStopScan() {
        if !cbCentralManager.isScanning {
            logger.debug("already not scanning")
            return
        }
        cbCentralManager.stopScan()
        cbStopScanTimer()
    }

    var coreBluetoothStateMessage: NKMessage {
        [
            "type": NKCoreBluetoothMessageType.state.name,
            "state": cbCentralManager.state.name
        ]
    }

    var coreBluetoothIsScanningMessage: NKMessage {
        [
            "type": NKCoreBluetoothMessageType.isScanning.name,
            "isScanning": cbCentralManager.isScanning
        ]
    }

    func coreBluetoothDiscoveredDeviceMessage(discoveredDevice: NKCoreBluetoothDiscoveredDevice) -> NKMessage {
        [
            "type": NKCoreBluetoothMessageType.discoveredDevice.name,
            "discoveredDevice": discoveredDevice.json
        ]
    }

    var coreBluetoothDiscoveredDevicesMessage: NKMessage {
        let discoveredDevicesJsons = cbUpdatedDiscoveredDevices.compactMap { identifier in
            if let discoveredDeviceIndex = cbDiscoveredDevices.firstIndex(where: { $0.peripheral.identifier == identifier }) {
                return cbDiscoveredDevices[discoveredDeviceIndex].json
            }
            return nil
        }
        cbUpdatedDiscoveredDevices.removeAll(keepingCapacity: true)

        return [
            "type": NKCoreBluetoothMessageType.discoveredDevices.name,
            "discoveredDevices": discoveredDevicesJsons
        ]
    }
}
