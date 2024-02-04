//
//  CBCharacteristic+utils.swift
//  NativeWebKit
//
//  Created by Zack Qattan on 2/2/24.
//

import CoreBluetooth

extension CBCharacteristic {
    var uuidString: String {
        uuid.uuidString
    }

    var peripheral: CBPeripheral? {
        service?.peripheral
    }

    var peripheralIdentifierString: String? {
        peripheral?.identifierString
    }

    var json: NKMessage {
        var descriptorsMessage: NKMessage = [:]
        descriptors?.forEach {
            descriptorsMessage[$0.uuidString] = $0.json
        }
        return [
            "uuid": uuidString,
            "properties": properties.json,
            "descriptors": descriptorsMessage,
            "isNotifying": isNotifying
        ]
    }

    var updatedValueJson: NKMessage {
        [
            "identifier": peripheralIdentifierString ?? "",
            "serviceUUID": service?.uuidString ?? "",
            "characteristicUUID": uuidString,
            "value": value?.bytes ?? [],
            "timestamp": lastTimeValueUpdated ?? 0.0
        ]
    }

    var lastTimeValueUpdated: Double? {
        guard let peripheralIdentifierString else {
            return nil
        }
        return NativeWebKit.shared.cbPeripherals[peripheralIdentifierString]?.lastTimeCharacteristicValuesUpdated[self]
    }
}
