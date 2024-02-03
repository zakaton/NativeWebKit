//
//  CBCharacteristicWriteType+name.swift
//  NativeWebKit
//
//  Created by Zack Qattan on 2/2/24.
//

import CoreBluetooth

extension CBCharacteristicWriteType {
    var name: String {
        switch self {
        case .withResponse:
            "withResponse"
        case .withoutResponse:
            "withoutResponse"
        @unknown default:
            "unknown"
        }
    }
}

extension CBCharacteristicWriteType {
    public static var allCases: [Self] {
        [.withResponse, .withoutResponse]
    }

    init?(name: String) {
        guard let writeType = Self.allCases.first(where: { $0.name == name }) else {
            return nil
        }
        self = writeType
    }
}
