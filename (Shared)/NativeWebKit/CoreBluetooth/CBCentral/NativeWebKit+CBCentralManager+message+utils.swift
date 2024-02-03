//
//  NativeWebKit+CBCentralManager+message+utils.swift
//  NativeWebKit
//
//  Created by Zack Qattan on 2/2/24.
//

import CoreBluetooth

extension NativeWebKit {
    func cbGetPeripheral(message: NKMessage) -> CBPeripheral? {
        guard let identifierString = message["identifier"] as? String else {
            logger.error("no identifier found in message")
            return nil
        }
        guard let peripheral = cbGetPeripheral(identifierString: identifierString) else {
            logger.error("no peripheral found with identifier \(identifierString, privacy: .public)")
            return nil
        }
        return peripheral
    }

    func cbGetService(message: NKMessage) -> CBService? {
        guard let peripheral = cbGetPeripheral(message: message) else {
            return nil
        }
        guard let serviceUUIDString = message["serviceUUID"] as? String else {
            logger.error("no serviceUUID found in message")
            return nil
        }
        guard let service = peripheral.services?.first(where: { $0.uuidString == serviceUUIDString }) else {
            logger.error("no service found in peripheral services with serviceUUID \(serviceUUIDString, privacy: .public)")
            return nil
        }
        return service
    }

    func cbGetServices(message: NKMessage) -> [CBService]? {
        guard let peripheral = cbGetPeripheral(message: message) else {
            return nil
        }
        guard let serviceUUIDStrings = message["serviceUUIDs"] as? [String] else {
            logger.error("no serviceUUIDs found in message")
            return peripheral.services
        }
        return serviceUUIDStrings.compactMap { serviceUUIDString in
            peripheral.services?.first(where: { $0.uuidString == serviceUUIDString })
        }
    }

    func cbGetServiceUUIDs(message: NKMessage) -> [CBUUID]? {
        guard let serviceUUIDStrings = message["serviceUUIDs"] as? [String] else {
            logger.debug("no serviceUUIDs found in message")
            return nil
        }
        return serviceUUIDStrings.compactMap { .init(string: $0) }
    }

    func cbGetIncludedServiceUUIDs(message: NKMessage) -> [CBUUID]? {
        guard let includedServiceUUIDStrings = message["includedServiceUUIDs"] as? [String] else {
            logger.debug("no includedServiceUUIDs found in message")
            return nil
        }
        return includedServiceUUIDStrings.compactMap { .init(string: $0) }
    }

    func cbGetIncludedServices(message: NKMessage) -> [CBService]? {
        guard let service = cbGetService(message: message) else {
            return nil
        }
        guard let includedServiceUUIDs = cbGetIncludedServiceUUIDs(message: message) else {
            return service.includedServices
        }

        return includedServiceUUIDs.compactMap { serviceUUID in
            service.peripheral?.services?.first(where: { $0.uuid == serviceUUID })
        }
    }

    func cbGetCharacteristicUUIDs(message: NKMessage) -> [CBUUID]? {
        guard let characteristicUUIDStrings = message["characteristicUUIDs"] as? [String] else {
            logger.debug("no characteristicUUIDs found in message")
            return nil
        }
        return characteristicUUIDStrings.compactMap { .init(string: $0) }
    }

    func cbGetCharacteristic(message: NKMessage) -> CBCharacteristic? {
        guard let service = cbGetService(message: message) else {
            return nil
        }
        guard let characteristicUUIDString = message["characteristicUUID"] as? String else {
            logger.error("no characteristicUUID found in message")
            return nil
        }
        guard let characteristic = cbGetCharacteristic(characteristicUUIDString: characteristicUUIDString, in: service) else {
            logger.error("no characteristic found in service")
            return nil
        }
        return characteristic
    }

    func cbGetCharacteristics(message: NKMessage) -> [CBCharacteristic]? {
        guard let service = cbGetService(message: message) else {
            return nil
        }
        guard let characteristicUUIDStrings = message["characteristicUUIDs"] as? [String] else {
            logger.error("no characteristicUUIDs found in message")
            return service.characteristics
        }
        return characteristicUUIDStrings.compactMap { characteristicUUIDString in
            cbGetCharacteristic(characteristicUUIDString: characteristicUUIDString, in: service)
        }
    }

    func cbGetCharacteristicWriteType(message: NKMessage) -> CBCharacteristicWriteType? {
        guard let writeTypeString = message["writeType"] as? String else {
            logger.debug("no writeType in message")
            return nil
        }
        guard let writeType: CBCharacteristicWriteType = .init(name: writeTypeString) else {
            logger.error("invalid writeType name \(writeTypeString, privacy: .public)")
            return nil
        }
        return writeType
    }

    func cbGetData(message: NKMessage) -> Data? {
        guard let dataArray = message["data"] as? [UInt8] else {
            logger.error("no data found in message")
            return nil
        }
        let data: Data = .init(dataArray)
        return data
    }

    func cbGetDescriptor(message: NKMessage) -> CBDescriptor? {
        guard let characteristic = cbGetCharacteristic(message: message) else {
            return nil
        }
        guard let descriptorUUIDString = message["descriptorUUID"] as? String else {
            logger.error("no descriptorUUIDString found in message")
            return nil
        }
        guard let descriptor = cbGetDescriptor(descriptorUUIDString: descriptorUUIDString, in: characteristic) else {
            logger.error("no descriptor found in characteristic")
            return nil
        }

        return descriptor
    }

    func cbGetDescriptors(message: NKMessage) -> [CBDescriptor]? {
        guard let characteristic = cbGetCharacteristic(message: message) else {
            return nil
        }
        guard let descriptorUUIDStrings = message["descriptorUUIDs"] as? [String] else {
            logger.debug("no descriptorUUIDs found in message")
            return characteristic.descriptors
        }
        let descriptors: [CBDescriptor] = descriptorUUIDStrings.compactMap {
            guard let descriptor = cbGetDescriptor(descriptorUUIDString: $0, in: characteristic) else {
                logger.error("no characteristic found in peripheral")
                return nil
            }

            return descriptor
        }

        return descriptors
    }
}
