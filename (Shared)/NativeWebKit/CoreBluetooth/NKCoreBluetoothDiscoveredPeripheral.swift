//
//  NKCoreBluetoothDiscoveredPeripheral.swift
//  NativeWebKit
//
//  Created by Zack Qattan on 1/29/24.
//

import CoreBluetooth

struct NKCoreBluetoothDiscoveredPeripheral {
    let peripheral: CBPeripheral

    let rssi: NSNumber
    let advertisementData: [String: Any]
    var advertisementDataJson: [String: Any] {
        var json: [String: Any] = [:]

        let timestamp = self.advertisementData["kCBAdvDataTimestamp"] as! Double
        json["timestamp"] = timestamp

        if let serviceData = self.advertisementData["kCBAdvDataServiceData"] as? [CBUUID: Any] {
            var serviceDataJson: [String: Any] = [:]
            serviceData.forEach { uuid, anyValue in
                if let data = anyValue as? Data {
                    let bytes = [UInt8](data)
                    serviceDataJson[uuid.uuidString] = bytes
                }
            }
            json["serviceData"] = serviceDataJson
        }

        return json
    }

    let dateCreated: Date = .now

    var json: [String: Any] {
        var json: [String: Any] = [
            "identifier": peripheral.identifier.uuidString,
            "rssi": self.rssi,
            "advertisementData": self.advertisementDataJson
        ]

        if let name = peripheral.name {
            json["name"] = name
        }

        return json
    }
}
