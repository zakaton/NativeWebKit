//
//  NativeWebKit+CBCentral.swift
//  NativeWebKit
//
//  Created by Zack Qattan on 1/29/24.
//

import CoreBluetooth

extension NativeWebKit {
    func handleCBCentralMessage(_ message: NKMessage, messageType: NKCBCentralMessageType) -> NKResponse? {
        logger.debug("coreBluetoothCentralMessageType \(messageType.id, privacy: .public)")

        var response: NKResponse?
        switch messageType {
        case .state:
            response = cbCentralStateMessage
        case .isScanning:
            response = cbCentralIsScanningMessage
        case .startScan:
            let scanOptions = message["scanOptions"] as? NKMessage
            cbStartScan(scanOptions: scanOptions)
            response = cbCentralIsScanningMessage
        case .discoveredPeripherals:
            response = cbCentralDiscoveredPeripheralsMessage
        case .discoveredPeripheral:
            // only used for messaging from the app directly into the webpage
            break
        case .stopScan:
            cbStopScan()
            response = cbCentralIsScanningMessage
        case .connect:
            if let connectOptions = message["connectOptions"] as? NKMessage {
                response = cbConnect(connectOptions: connectOptions)
            }
            else {
                logger.error("no connectOptions found in message")
            }
        case .peripheralConnectionState:
            if let identifierString = message["identifier"] as? String {
                response = cbPeripheralConnectionStateMessage(identifierString: identifierString)
            }
            else {
                logger.error("no identifier found in message")
            }
        case .disconnect:
            if let identifierString = message["identifier"] as? String {
                if let discoveredPeripheralIndex = cbGetDiscoveredPeripheralIndexByIdentifier(identifierString) {
                    cbCentralManager.cancelPeripheralConnection(cbDiscoveredPeripherals[discoveredPeripheralIndex].peripheral)
                    response = cbPeripheralConnectionStateMessage(identifierString: identifierString)
                }
                else {
                    logger.error("no discoveredPeripheral found with identifier \(identifierString, privacy: .public)")
                }
            }
            else {
                logger.error("no identifier found in message")
            }
        case .disconnectAll:
            cbDiscoveredPeripherals.filter { $0.peripheral.state != .disconnected }.forEach {
                cbCentralManager.cancelPeripheralConnection($0.peripheral)
            }
        case .connectedPeripherals:
            // TODO: - FILL
            break
        }
        return response
    }

    func cbGetDiscoveredPeripheralIndexByIdentifier(_ identifierString: String) -> Int? {
        cbDiscoveredPeripherals.firstIndex(where: { $0.peripheral.identifier.uuidString == identifierString })
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
        logger.debug("stopped scanning")
        cbStopScanTimer()
    }

    func cbConnect(connectOptions: NKMessage) -> NKMessage? {
        guard let identifierString = connectOptions["identifier"] as? String else {
            logger.error("no identifier string found")
            return nil
        }
        guard let discoveredPeripheralIndex = cbGetDiscoveredPeripheralIndexByIdentifier(identifierString) else {
            logger.error("no discovered device found with identifier \(identifierString, privacy: .public)")
            return nil
        }

        var options: [String: Any]?
        if let optionsMessage = connectOptions["options"] as? [String: Any] {
            options = [:]
            if let enableAutoReconnect = optionsMessage["enableAutoReconnect"] as? Bool {
                options![CBConnectPeripheralOptionEnableAutoReconnect] = enableAutoReconnect
            }
            #if !os(macOS)
            if let enableTransportBridging = optionsMessage["enableTransportBridging"] as? Bool {
                options![CBConnectPeripheralOptionEnableTransportBridgingKey] = enableTransportBridging
            }
            #endif
            if let notifyOnConnection = optionsMessage["notifyOnConnection"] as? Bool {
                options![CBConnectPeripheralOptionNotifyOnConnectionKey] = notifyOnConnection
            }
            if let notifyOnDisconnection = optionsMessage["notifyOnDisconnection"] as? Bool {
                options![CBConnectPeripheralOptionNotifyOnDisconnectionKey] = notifyOnDisconnection
            }
            if let notifyOnNotification = optionsMessage["notifyOnNotification"] as? Bool {
                options![CBConnectPeripheralOptionNotifyOnNotificationKey] = notifyOnNotification
            }
            #if !os(macOS)
            if let requiresANCS = optionsMessage["requiresANCS"] as? Bool {
                options![CBConnectPeripheralOptionRequiresANCS] = requiresANCS
            }
            #endif
            if let startDelay = optionsMessage["startDelay"] as? NSNumber {
                options![CBConnectPeripheralOptionStartDelayKey] = startDelay
            }
        }
        cbCentralManager.connect(cbDiscoveredPeripherals[discoveredPeripheralIndex].peripheral, options: options)

        return cbPeripheralConnectionStateMessage(identifierString: identifierString)
    }

    var cbCentralStateMessage: NKMessage {
        [
            "type": NKCBCentralMessageType.state.name,
            "state": cbCentralManager.state.name
        ]
    }

    var cbCentralIsScanningMessage: NKMessage {
        [
            "type": NKCBCentralMessageType.isScanning.name,
            "isScanning": cbCentralManager.isScanning
        ]
    }

    func cbCentralDiscoveredPeripheralMessage(discoveredPeripheral: NKCoreBluetoothDiscoveredPeripheral) -> NKMessage {
        [
            "type": NKCBCentralMessageType.discoveredPeripheral.name,
            "discoveredPeripheral": discoveredPeripheral.json
        ]
    }

    var cbCentralDiscoveredPeripheralsMessage: NKMessage {
        let discoveredPeripheralsJsons = cbUpdatedDiscoveredPeripherals.compactMap { identifierString in
            if let discoveredPeripheralIndex = cbGetDiscoveredPeripheralIndexByIdentifier(identifierString) {
                return cbDiscoveredPeripherals[discoveredPeripheralIndex].json
            }
            return nil
        }
        cbUpdatedDiscoveredPeripherals.removeAll(keepingCapacity: true)

        return [
            "type": NKCBCentralMessageType.discoveredPeripherals.name,
            "discoveredPeripherals": discoveredPeripheralsJsons
        ]
    }

    func cbPeripheralConnectionStateMessage(identifierString: String) -> NKMessage? {
        guard let discoveredPeripheralIndex = cbGetDiscoveredPeripheralIndexByIdentifier(identifierString) else {
            logger.error("couldn't find discoveredPeripheral with identifier \(identifierString, privacy: .public)")
            return nil
        }

        return [
            "type": NKCBCentralMessageType.peripheralConnectionState.name,
            "peripheralConnectionState": [
                "identifier": identifierString,
                "connectionState": cbDiscoveredPeripherals[discoveredPeripheralIndex].peripheral.state.name
            ]
        ]
    }
}