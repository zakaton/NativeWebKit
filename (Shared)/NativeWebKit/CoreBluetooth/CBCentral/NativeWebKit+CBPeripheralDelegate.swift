//
//  NativeWebKit+CBPeripheralDelegate.swift
//  NativeWebKit
//
//  Created by Zack Qattan on 1/31/24.
//

import CoreBluetooth

extension NativeWebKit: CBPeripheralDelegate {
    func peripheralDidUpdateName(_ peripheral: CBPeripheral) {
        logger.debug("peripheralDidUpdateName \(peripheral.identifier.uuidString, privacy: .public): \(peripheral.name ?? "nil", privacy: .public)")

        if cbPeripherals[peripheral.identifierString] != nil {
            cbPeripherals[peripheral.identifierString]?.lastTimeNameUpdated = Date.now.timeIntervalSince1970
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        logger.debug("didReadRSSI \(peripheral.name ?? peripheral.identifier.uuidString, privacy: .public) \(RSSI, privacy: .public)")

        if cbPeripherals[peripheral.identifierString] != nil {
            cbPeripherals[peripheral.identifierString]!.rssi = RSSI

            #if IN_APP
            dispatchMessageToWebpages(cbPeripheralRSSIsMessage(peripherals: [peripheral]))
            #endif
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        logger.debug("peripheral didModifyServices")
        if cbPeripherals[peripheral.identifierString] != nil {
            cbPeripherals[peripheral.identifierString]!.lastTimeServicesUpdated = Date.now.timeIntervalSince1970
            #if IN_APP
            dispatchMessageToWebpages(cbGetServicesMessage(services: peripheral.services ?? []))
            #endif
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: (any Error)?) {
        logger.debug("peripheral didDiscoverServices, error: \(error?.localizedDescription ?? "no error")")
        if cbPeripherals[peripheral.identifierString] != nil {
            cbPeripherals[peripheral.identifierString]?.lastTimeServicesUpdated = Date.now.timeIntervalSince1970
            #if IN_APP
            dispatchMessageToWebpages(cbGetServicesMessage(services: peripheral.services ?? []))
            #endif
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverIncludedServicesFor service: CBService, error: (any Error)?) {
        logger.debug("didDiscoverIncludedServicesFor service \(service.uuidString, privacy: .public) error: \(error?.localizedDescription ?? "no error")")
        if cbPeripherals[peripheral.identifierString] != nil {
            cbPeripherals[peripheral.identifierString]?.lastTimeIncludedServicesUpdated[service] = Date.now.timeIntervalSince1970
            #if IN_APP
            dispatchMessageToWebpages(cbGetIncludedServicesMessage(service: service))
            #endif
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: (any Error)?) {
        logger.debug("didDiscoverCharacteristicsFor service \(service.uuidString, privacy: .public) error: \(error?.localizedDescription ?? "no error")")
        if cbPeripherals[peripheral.identifierString] != nil {
            cbPeripherals[peripheral.identifierString]?.lastTimeCharacteristicsUpdated[service] = Date.now.timeIntervalSince1970
            #if IN_APP
            if let characteristics = service.characteristics {
                dispatchMessageToWebpages(cbGetCharacteristicsMessage(characteristics: characteristics))
            }
            #endif
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: (any Error)?) {
        logger.debug("didWriteValueFor characteristic \(characteristic.uuidString, privacy: .public) error: \(error?.localizedDescription ?? "no error")")
        if cbPeripherals[peripheral.identifierString] != nil {
            cbPeripherals[peripheral.identifierString]?.lastTimeCharacteristicValuesUpdated[characteristic] = Date.now.timeIntervalSince1970
            #if IN_APP
            dispatchMessageToWebpages(cbGetCharacteristicValueMessage(characteristic: characteristic))
            #endif
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: (any Error)?) {
        logger.debug("didUpdateValueFor characteristic \(characteristic.uuidString, privacy: .public) error: \(error?.localizedDescription ?? "no error")")
        if cbPeripherals[peripheral.identifierString] != nil {
            cbPeripherals[peripheral.identifierString]?.lastTimeCharacteristicValuesUpdated[characteristic] = Date.now.timeIntervalSince1970
            #if IN_APP
            dispatchMessageToWebpages(cbGetCharacteristicValueMessage(characteristic: characteristic))
            #endif
        }
    }

    func peripheralIsReady(toSendWriteWithoutResponse peripheral: CBPeripheral) {
        logger.debug("peripheralIsReady toSendWriteWithoutResponse")
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: (any Error)?) {
        logger.debug("peripheral didUpdateNotificationStateFor \(characteristic.uuidString, privacy: .public)")
        #if IN_APP
        dispatchMessageToWebpages(cbGetCharacteristicNotifyValueMessage(characteristic: characteristic))
        #endif
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: (any Error)?) {
        logger.debug("didDiscoverDescriptorsFor characteristic \(characteristic.uuidString, privacy: .public) error: \(error?.localizedDescription ?? "no error")")
        if cbPeripherals[peripheral.identifierString] != nil {
            cbPeripherals[peripheral.identifierString]?.lastTimeDescriptorsUpdated[characteristic] = Date.now.timeIntervalSince1970
            #if IN_APP
            if let descriptors = characteristic.descriptors {
                dispatchMessageToWebpages(cbGetDescriptorsMessage(descriptors: descriptors))
            }
            #endif
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: (any Error)?) {
        logger.debug("didUpdateValueFor descriptor \(descriptor.uuidString, privacy: .public) error: \(error?.localizedDescription ?? "no error")")
        if cbPeripherals[peripheral.identifierString] != nil {
            cbPeripherals[peripheral.identifierString]?.lastTimeDescriptorValueUpdated[descriptor] = Date.now.timeIntervalSince1970
            #if IN_APP
            dispatchMessageToWebpages(cbGetDescriptorValueMessage(descriptor: descriptor))
            #endif
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: (any Error)?) {
        logger.debug("didWriteValueFor descriptor \(descriptor.uuidString, privacy: .public) error: \(error?.localizedDescription ?? "no error")")
        if cbPeripherals[peripheral.identifierString] != nil {
            cbPeripherals[peripheral.identifierString]?.lastTimeDescriptorValueUpdated[descriptor] = Date.now.timeIntervalSince1970
            #if IN_APP
            dispatchMessageToWebpages(cbGetDescriptorValueMessage(descriptor: descriptor))
            #endif
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didOpen channel: CBL2CAPChannel?, error: (any Error)?) {
        logger.debug("didOpen channel error: \(error?.localizedDescription ?? "no error")")
    }
}
