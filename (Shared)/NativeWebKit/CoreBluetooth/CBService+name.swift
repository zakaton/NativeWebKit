//
//  CBService+name.swift
//  NativeWebKit
//
//  Created by Zack Qattan on 2/2/24.
//

import CoreBluetooth

extension CBService {
    var uuidString: String {
        uuid.uuidString
    }

    var peripheralIdentifierString: String? {
        peripheral?.identifierString
    }

    var json: NKMessage {
        [
            "uuid": uuidString,
            "isPrimary": isPrimary,
            "includedServiceUUIDs": includedServices?.map { $0.uuidString } ?? [],
            "characteristics": characteristics?.map { $0.json } ?? []
        ]
    }
}
