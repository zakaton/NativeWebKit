//
//  NativeWebKit+CBCentral+utils.swift
//  NativeWebKit
//
//  Created by Zack Qattan on 2/2/24.
//

import CoreBluetooth

extension NativeWebKit {
    func cbGetPeripheral(identifierString: String) -> CBPeripheral? {
        if let identifier: UUID = .init(uuidString: identifierString) {
            let peripherals = cbCentralManager.retrievePeripherals(withIdentifiers: [identifier])
            return peripherals[0]
        }
        else {
            logger.error("invalid identifierString \(identifierString, privacy: .public)")
            return nil
        }
    }

//    func cbGetCharacteristic(characteristicUUIDString: String, in peripheral: CBPeripheral) -> CBCharacteristic? {
//        var characteristic: CBCharacteristic?
//        guard let services = peripheral.services else {
//            logger.error("no services found in peripheral")
//            return nil
//        }
//        characteristicTraversal: for service in services {
//            if let characteristics = service.characteristics {
//                for _characteristic in characteristics {
//                    if _characteristic.uuidString == characteristicUUIDString {
//                        characteristic = _characteristic
//                        break characteristicTraversal
//                    }
//                }
//            }
//        }
//        return characteristic
//    }

    func cbGetCharacteristic(characteristicUUIDString: String, in service: CBService) -> CBCharacteristic? {
        var characteristic: CBCharacteristic?

        if let characteristics = service.characteristics {
            characteristicTraversal: for _characteristic in characteristics {
                if _characteristic.uuidString == characteristicUUIDString {
                    characteristic = _characteristic
                    break characteristicTraversal
                }
            }
        }

        return characteristic
    }

    func cbGetDescriptor(descriptorUUIDString: String, in characteristic: CBCharacteristic) -> CBDescriptor? {
        return characteristic.descriptors?.first(where: { $0.uuidString == descriptorUUIDString })
    }
}
