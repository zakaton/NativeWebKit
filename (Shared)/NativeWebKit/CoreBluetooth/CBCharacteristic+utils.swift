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
        [
            "uuid": uuidString,
            "properties": properties.json,
            "descriptors": descriptors?.map { $0.json } ?? []
        ]
    }
}
