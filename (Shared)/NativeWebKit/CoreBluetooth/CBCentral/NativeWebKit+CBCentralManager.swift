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
            if let identifierString = message["identifier"] as? String, let peripheral = cbRetrievePeripheral(identifierString: identifierString) {
                response = cbPeripheralConnectionStateMessage(peripheral: peripheral)
            }
            else {
                logger.error("no identifier found in message")
            }
        case .disconnect:
            if let identifierString = message["identifier"] as? String {
                if let peripheral = cbRetrievePeripheral(identifierString: identifierString) {
                    cbCentralManager.cancelPeripheralConnection(peripheral)
                    #if !IN_APP
                    response = cbPeripheralConnectionStateMessage(peripheral: peripheral)
                    #endif
                }
                else {
                    logger.error("no discoveredPeripheral found with identifier \(identifierString, privacy: .public)")
                }
            }
            else {
                logger.error("no identifier found in message")
            }
        case .disconnectAll:
            cbDiscoveredPeripherals.filter { $0.value.peripheral.state != .disconnected }.forEach {
                cbCentralManager.cancelPeripheralConnection($0.value.peripheral)
            }
        case .connectedPeripherals:
            let serviceUUIDs = message["serviceUUIDs"] as? [String]
            response = cbConnectedPeripheralsMessage(serviceUUIDs: serviceUUIDs)
        case .disconnectedPeripherals:
            response = cbDisconnectedPeripheralsMessage
        case .readRSSI:
            guard let identifiers = message["identifiers"] as? [String] else {
                logger.error("no identifiers in message")
                return nil
            }
            let peripherals = cbCentralManager.retrievePeripherals(withIdentifiers: identifiers.compactMap { .init(uuidString: $0) })
            peripherals.forEach { $0.readRSSI() }
        case .getRSSI:
            guard let peripherals = message["peripherals"] as? [NKMessage] else {
                logger.error("no peripherals in message")
                return nil
            }
            response = cbPeripheralRSSIsMessage(peripherals: peripherals)
        // TODO: - FILL
        case .getService:
            // TODO: - FILL
            break
        case .getServices:
            // TODO: - FILL
            break
        }
        return response
    }

    func cbRetrievePeripheral(identifierString: String) -> CBPeripheral? {
        if let identifier: UUID = .init(uuidString: identifierString) {
            let peripherals = cbCentralManager.retrievePeripherals(withIdentifiers: [identifier])
            return peripherals[0]
        }
        else {
            logger.error("invalid identifierString \(identifierString, privacy: .public)")
            return nil
        }
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
        guard let peripheral = cbRetrievePeripheral(identifierString: identifierString) else {
            logger.error("no peripheral found for identifierString \(identifierString, privacy: .public)")
            return nil
        }

        if cbPeripherals[peripheral.identifierString] == nil {
            cbPeripherals[peripheral.identifierString] = .init(peripheral: peripheral)
            peripheral.delegate = self
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
        cbCentralManager.connect(peripheral, options: options)

        #if IN_APP
        return nil
        #else
        return cbPeripheralConnectionStateMessage(peripheral: peripheral)
        #endif
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

    func cbCentralDiscoveredPeripheralMessage(discoveredPeripheral: NKCBDiscoveredPeripheral) -> NKMessage {
        [
            "type": NKCBCentralMessageType.discoveredPeripheral.name,
            "discoveredPeripheral": discoveredPeripheral.json
        ]
    }

    var cbCentralDiscoveredPeripheralsMessage: NKMessage {
        let discoveredPeripheralsJsons = cbUpdatedDiscoveredPeripherals.compactMap { identifierString in
            if let discoveredPeripheral = cbDiscoveredPeripherals[identifierString] {
                return discoveredPeripheral.json
            }
            return nil
        }
        cbUpdatedDiscoveredPeripherals.removeAll(keepingCapacity: true)

        return [
            "type": NKCBCentralMessageType.discoveredPeripherals.name,
            "discoveredPeripherals": discoveredPeripheralsJsons
        ]
    }

    func cbPeripheralConnectionStateMessage(peripheral: CBPeripheral) -> NKMessage {
        cbDisconnectedPeripherals.remove(peripheral.identifierString)
        return [
            "type": NKCBCentralMessageType.peripheralConnectionState.name,
            "peripheralConnectionState": [
                "identifier": peripheral.identifierString,
                "connectionState": peripheral.state.name
            ]
        ]
    }

    func cbConnectedPeripheralsMessage(serviceUUIDs: [String]? = []) -> NKMessage? {
        var connectedPeripheralsMessage = cbPeripherals.map { $0.value.json }

        logger.debug("serviceUUIDs: \(serviceUUIDs?.debugDescription ?? "nil", privacy: .public)")

        if let serviceUUIDs {
            let _serviceUUIDs: [CBUUID] = serviceUUIDs.map { .init(string: $0) }
            let peripherals = cbCentralManager.retrieveConnectedPeripherals(withServices: _serviceUUIDs)
            connectedPeripheralsMessage += peripherals.compactMap {
                if cbPeripherals[$0.identifierString] == nil {
                    return NKCBPeripheral(peripheral: $0).json
                }
                else {
                    return nil
                }
            }
        }

        guard !connectedPeripheralsMessage.isEmpty else {
            return nil
        }

        return [
            "type": NKCBCentralMessageType.connectedPeripherals.name,
            "connectedPeripherals": connectedPeripheralsMessage
        ]
    }

    var cbDisconnectedPeripheralsMessage: NKMessage? {
        let disconnectedPeripheralsMessage = Array(cbDisconnectedPeripherals)

        guard !cbDiscoveredPeripherals.isEmpty else {
            return nil
        }
        cbDisconnectedPeripherals.removeAll()

        return [
            "type": NKCBCentralMessageType.disconnectedPeripherals.name,
            "disconnectedPeripherals": disconnectedPeripheralsMessage
        ]
    }

    func cbPeripheralRSSIsMessage(peripherals: [NKMessage]) -> NKMessage {
        let peripheralRSSIs: [NKMessage] = peripherals.compactMap {
            guard let identifierString = $0["identifier"] as? String else {
                logger.error("no identifier found in message")
                return nil
            }
            let timestamp = $0["timestamp"] as? TimeInterval
            guard let rssiJson = cbPeripherals[identifierString]?.rssiJson(since: timestamp) else {
                logger.error("no peripheral found for identifier \(identifierString)")
                return nil
            }

            return rssiJson
        }

        return [
            "type": NKCBCentralMessageType.getRSSI.name,
            "peripheralRSSIs": peripheralRSSIs
        ]
    }

    func cbPeripheralRSSIsMessage(peripherals: [CBPeripheral]) -> NKMessage {
        let peripheralRSSIs: [NKMessage] = peripherals.compactMap {
            guard let rssiJson = cbPeripherals[$0.identifierString]?.rssiJson() else {
                logger.error("no peripheral found for identifier \($0.identifierString)")
                return nil
            }

            return rssiJson
        }

        return [
            "type": NKCBCentralMessageType.getRSSI.name,
            "peripheralRSSIs": peripheralRSSIs
        ]
    }
}
