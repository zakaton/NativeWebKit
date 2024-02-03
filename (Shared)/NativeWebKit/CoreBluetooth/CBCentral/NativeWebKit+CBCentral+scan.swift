//
//  NativeWebKit+CBCentral+scan.swift
//  NativeWebKit
//
//  Created by Zack Qattan on 2/2/24.
//

import CoreBluetooth

extension NativeWebKit {
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
        guard let peripheral = cbGetPeripheral(identifierString: identifierString) else {
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
}
