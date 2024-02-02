//
//  NKCBDiscoveredPeripheral.swift
//  NativeWebKit
//
//  Created by Zack Qattan on 1/29/24.
//

import CoreBluetooth

struct NKCBDiscoveredPeripheral {
    let peripheral: CBPeripheral
    var name: String? { peripheral.name }
    var identifier: String { peripheral.identifier.uuidString }

    let rssi: NSNumber
    let advertisementData: [String: Any]
    var advertisementDataJson: [String: Any] {
        var json: [String: Any] = [:]

        let timestamp = advertisementData["kCBAdvDataTimestamp"] as! Double
        json["timestamp"] = timestamp

        if let serviceData = advertisementData["kCBAdvDataServiceData"] as? [CBUUID: Any] {
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

    let lastTimeUpdated: Date = .now

    var json: [String: Any] {
        var json: [String: Any] = [
            "identifier": identifier,
            "rssi": rssi,
            "advertisementData": advertisementDataJson
        ]

        if let name {
            json["name"] = name
        }

        return json
    }
}
