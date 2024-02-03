//
//  CBDescriptor+utils.swift
//  NativeWebKit
//
//  Created by Zack Qattan on 2/2/24.
//

import CoreBluetooth

extension CBDescriptor {
    var uuidString: String {
        uuid.uuidString
    }

    var peripheral: CBPeripheral? {
        characteristic?.peripheral
    }

    var peripheralIdentifierString: String? {
        peripheral?.identifierString
    }

    var json: NKMessage {
        [
            "uuid": uuidString
        ]
    }

    var valueJson: NKMessage? {
        // https://stackoverflow.com/questions/52816049/how-to-convert-cbdescriptor-value-to-string

        switch uuidString {
        case CBUUIDCharacteristicFormatString:
            guard let data = value as? Data else {
                return nil
            }
            return [
                "type": "characteristicFormat",
                "value": data.bytes
            ]
        case CBUUIDCharacteristicUserDescriptionString:
            guard let string = value as? String else {
                return nil
            }
            return [
                "type": "characteristicUserDescription",
                "value": string
            ]

        case CBUUIDCharacteristicExtendedPropertiesString:
            guard let number = value as? NSNumber else {
                return nil
            }
            return [
                "type": "characterisrticExtendedProperties",
                "value": number
            ]

        case CBUUIDClientCharacteristicConfigurationString:
            guard let number = value as? NSNumber else {
                return nil
            }
            return [
                "type": "clientCharacteristicConfiguration",
                "value": number
            ]
        case CBUUIDServerCharacteristicConfigurationString:
            guard let number = value as? NSNumber else {
                return nil
            }
            return [
                "type": "serverCharacteristicConfiguration",
                "value": number
            ]
        case CBUUIDCharacteristicAggregateFormatString:
            guard let string = value as? String else {
                return nil
            }
            return [
                "type": "characteristicAggregateFormat",
                "value": string
            ]
        default:
            return nil
        }
    }
}
