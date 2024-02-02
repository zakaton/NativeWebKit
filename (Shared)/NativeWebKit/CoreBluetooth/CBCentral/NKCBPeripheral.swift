//
//  NKCBPeripheral.swift
//  NativeWebKit
//
//  Created by Zack Qattan on 1/31/24.
//

import CoreBluetooth

struct NKCBPeripheral {
    let peripheral: CBPeripheral
    var identifier: String { peripheral.identifier.uuidString }
    var name: String? { peripheral.name }
    var rssi: NSNumber? {
        didSet {
            lastTimeRSSIUpdated = Date.now.timeIntervalSince1970
        }
    }

    var lastTimeRSSIUpdated: TimeInterval?

    func rssiJson(since timestamp: TimeInterval? = nil) -> [String: Any]? {
        guard let rssi, let lastTimeRSSIUpdated else {
            return nil
        }

        guard timestamp == nil || timestamp! < lastTimeRSSIUpdated else {
            return nil
        }

        return [
            "identifier": peripheral.identifierString,
            "rssi": rssi,
            "timestamp": lastTimeRSSIUpdated
        ]
    }

    var json: [String: Any] {
        var json: [String: Any] = [
            "identifier": peripheral.identifierString,
            "connectionState": peripheral.state.name
        ]

        if let rssi {
            json["rssi"] = rssi
        }

        if let name {
            json["name"] = name
        }

        return json
    }
}
