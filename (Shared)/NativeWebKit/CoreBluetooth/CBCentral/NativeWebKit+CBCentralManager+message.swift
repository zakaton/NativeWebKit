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
            guard let connectOptions = message["connectOptions"] as? NKMessage else {
                logger.error("no connectOptions found in message")
                return nil
            }
            response = cbConnect(connectOptions: connectOptions)
        case .peripheralConnectionState:
            guard let peripheral = cbGetPeripheral(message: message)
            else {
                return nil
            }

            response = cbPeripheralConnectionStateMessage(peripheral: peripheral)
        case .disconnect:
            guard let peripheral = cbGetPeripheral(message: message)
            else {
                return nil
            }

            cbCentralManager.cancelPeripheralConnection(peripheral)
            #if !IN_APP
            response = cbPeripheralConnectionStateMessage(peripheral: peripheral)
            #endif
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

        case .discoverServices:
            guard let peripheral = cbGetPeripheral(message: message)
            else {
                return nil
            }

            let serviceUUIDs = cbGetServiceUUIDs(message: message)

            peripheral.discoverServices(serviceUUIDs)
        case .discoverIncludedServices:
            guard let service = cbGetService(message: message)
            else {
                return nil
            }

            let includedServiceUUIDs = cbGetIncludedServiceUUIDs(message: message)

            service.peripheral?.discoverIncludedServices(includedServiceUUIDs, for: service)
        case .getServices:
            guard let services = cbGetServices(message: message)
            else {
                return nil
            }
            response = cbGetServicesMessage(services: services)
        case .getIncludedServices:
            guard let service = cbGetService(message: message)
            else {
                return nil
            }
            let includedServices = cbGetIncludedServices(message: message) ?? service.includedServices ?? []
            response = cbGetIncludedServicesMessage(service: service, includedServices: includedServices)
        case .discoverCharacteristics:
            guard let service = cbGetService(message: message)
            else {
                return nil
            }

            let characteristicUUIDs = cbGetCharacteristicUUIDs(message: message)

            service.peripheral?.discoverCharacteristics(characteristicUUIDs, for: service)
        case .getCharacteristics:
            guard let characteristics = cbGetCharacteristics(message: message) else {
                return nil
            }
            response = cbGetCharacteristicsMessage(characteristics: characteristics)
        case .discoverDescriptors:
            guard let characteristic = cbGetCharacteristic(message: message)
            else {
                return nil
            }
            characteristic.peripheral?.discoverDescriptors(for: characteristic)
        case .getDescriptors:
            guard let descriptors = cbGetDescriptors(message: message) else {
                return nil
            }
            response = cbGetDescriptorsMessage(descriptors: descriptors)
        case .readCharacteristicValue:
            guard let characteristic = cbGetCharacteristic(message: message)
            else {
                return nil
            }
            characteristic.peripheral?.readValue(for: characteristic)

        case .writeCharacteristicValue:
            guard let characteristic = cbGetCharacteristic(message: message),
                  let data = cbGetData(message: message)
            else {
                return nil
            }

            let writeType = cbGetCharacteristicWriteType(message: message) ?? .withoutResponse
            characteristic.peripheral?.writeValue(data, for: characteristic, type: writeType)

        case .getCharacteristicValue:
            guard let characteristic = cbGetCharacteristic(message: message) else {
                return nil
            }
            if let timestamp = message["timestamp"] as? Double, let peripheral = characteristic.peripheral {
                guard timestamp != cbPeripherals[peripheral.identifierString]?.lastTimeCharacteristicValuesUpdated[characteristic] else {
                    logger.debug("characteristic value hasn't updated since last time")
                    return nil
                }
            }

            response = cbGetCharacteristicValueMessage(characteristic: characteristic)

        case .updatedCharacteristicValues:
            guard let timestamp = message["timestamp"] as? Double else {
                logger.error("no timestamp found in message")
                return nil
            }

            var updatedCharacteristics: [CBCharacteristic] = []
            cbPeripherals.values.forEach { cbPeripheral in
                cbPeripheral.lastTimeCharacteristicValuesUpdated.forEach { characteristic, lastTimeUpdated in
                    if timestamp != lastTimeUpdated {
                        updatedCharacteristics.append(characteristic)
                    }
                }
            }

            if !updatedCharacteristics.isEmpty {
                response = cbUpdatedCharacteristicValuesMessage(updatedCharacteristics: updatedCharacteristics)
            }

        case .setCharacteristicNotifyValue:
            guard let characteristic = cbGetCharacteristic(message: message)
            else {
                return nil
            }

            guard let notifyValue = message["notifyValue"] as? Bool else {
                logger.error("no notifyValue found in message")
                return nil
            }

            characteristic.peripheral?.setNotifyValue(notifyValue, for: characteristic)
        case .getCharacteristicNotifyValue:
            guard let characteristic = cbGetCharacteristic(message: message)
            else {
                return nil
            }
            response = cbGetCharacteristicNotifyValueMessage(characteristic: characteristic)

        case .readDescriptorValue:
            guard let descriptor = cbGetDescriptor(message: message)
            else {
                return nil
            }

            descriptor.peripheral?.readValue(for: descriptor)

        case .writeDescriptorValue:
            guard let descriptor = cbGetDescriptor(message: message),
                  let data = cbGetData(message: message)
            else {
                return nil
            }

            descriptor.peripheral?.writeValue(data, for: descriptor)

        case .getDescriptorValue:
            guard let descriptor = cbGetDescriptor(message: message)
            else {
                return nil
            }

            if let timestamp = message["timestamp"] as? Double, let peripheral = descriptor.peripheral {
                guard timestamp != cbPeripherals[peripheral.identifierString]?.lastTimeDescriptorValueUpdated[descriptor] else {
                    logger.debug("descriptor value hasn't updated since last time")
                    return nil
                }
            }

            response = cbGetDescriptorValueMessage(descriptor: descriptor)
        }
        return response
    }
}
