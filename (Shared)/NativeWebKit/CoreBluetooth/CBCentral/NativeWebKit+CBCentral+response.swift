//
//  NativeWebKit+CBCentral+message.swift
//  NativeWebKit
//
//  Created by Zack Qattan on 2/2/24.
//

import CoreBluetooth

extension NativeWebKit {
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

    func cbGetServicesMessage(services: [CBService]) -> NKMessage {
        [
            "type": NKCBCentralMessageType.getServices.name,
            "getServices": [
                "identifier": services[0].peripheralIdentifierString ?? "",
                "services": services.map { $0.json }
            ]
        ]
    }

    func cbGetIncludedServicesMessage(service: CBService, includedServices: [CBService]? = nil) -> NKMessage {
        let _includedServices = includedServices ?? service.includedServices ?? []
        return [
            "type": NKCBCentralMessageType.getIncludedServices.name,
            "getIncludedServices": [
                "identifier": service.peripheralIdentifierString ?? "",
                "serviceUUID": service.json,
                "includedServiceUUIDs": _includedServices.map { $0.uuidString }
            ]
        ]
    }

    func cbGetCharacteristicsMessage(characteristics: [CBCharacteristic]) -> NKMessage {
        [
            "type": NKCBCentralMessageType.getCharacteristics.name,
            "getCharacteristics": [
                "identifier": characteristics[0].service?.peripheralIdentifierString ?? "",
                "serviceUUID": characteristics[0].service?.uuidString ?? "",
                "characteristics": characteristics.map { $0.json }
            ]
        ]
    }

    func cbGetCharacteristicValueMessage(characteristic: CBCharacteristic) -> NKMessage {
        [
            "type": NKCBCentralMessageType.getCharacteristicValue.name,
            "getCharacteristicValue": [
                "identifier": characteristic.peripheralIdentifierString ?? "",
                "serviceUUID": characteristic.service?.uuidString ?? "",
                "characteristicUUID": characteristic.uuidString,
                "value": characteristic.value?.bytes ?? [],
                "timestamp": characteristic.lastTimeValueUpdated ?? 0.0
            ]
        ]
    }

    func cbUpdatedCharacteristicValuesMessage(updatedCharacteristics: [CBCharacteristic]) -> NKMessage {
        [
            "type": NKCBCentralMessageType.updatedCharacteristicValues.name,
            "updatedCharacteristicValues": updatedCharacteristics.map { $0.updatedValueJson }
        ]
    }

    func cbGetCharacteristicNotifyValueMessage(characteristic: CBCharacteristic) -> NKMessage {
        [
            "type": NKCBCentralMessageType.getCharacteristicNotifyValue.name,
            "getCharacteristicNotifyValue": [
                "identifier": characteristic.service?.peripheral?.identifierString ?? "",
                "serviceUUID": characteristic.service?.uuidString ?? "",
                "characteristicUUID": characteristic.uuidString,
                "isNotifying": characteristic.isNotifying
            ]
        ]
    }

    func cbGetDescriptorsMessage(descriptors: [CBDescriptor]) -> NKMessage {
        [
            "type": NKCBCentralMessageType.getDescriptors.name,
            "getDescriptors": [
                "identifier": descriptors[0].characteristic?.peripheralIdentifierString ?? "",
                "serviceUUID": descriptors[0].characteristic?.service?.uuidString ?? "",
                "characteristicUUID": descriptors[0].characteristic?.uuidString ?? "",
                "descriptors": descriptors.map { $0.json }
            ]
        ]
    }

    func cbGetDescriptorValueMessage(descriptor: CBDescriptor) -> NKMessage {
        [
            "type": NKCBCentralMessageType.getDescriptorValue.name,
            "getDescriptorValue": [
                "identifier": descriptor.peripheralIdentifierString ?? "",
                "serviceUUID": descriptor.characteristic?.service?.uuidString ?? "",
                "characteristicUUID": descriptor.characteristic?.uuidString ?? "",
                "descriptorUUID": descriptor.uuidString,
                "value": descriptor.valueJson ?? ""
            ]
        ]
    }
}
