//
//  CBCharacteristicProperties+utils.swift
//  NativeWebKit
//
//  Created by Zack Qattan on 2/2/24.
//

import CoreBluetooth

extension CBCharacteristicProperties {
    var json: NKMessage {
        var _json: NKMessage = [:]
        Self.allCases.forEach {
            if let name = $0.name {
                _json[name] = self.contains($0)
            }
        }
        return _json
    }

    var name: String? {
        switch self {
        case .read:
            "read"
        case .write:
            "write"
        case .writeWithoutResponse:
            "writeWithoutResponse"
        case .indicate:
            "indicate"
        case .notify:
            "notify"
        default:
            nil
        }
    }
}

extension CBCharacteristicProperties: CaseIterable {
    public static var allCases: [CBCharacteristicProperties] {
        [.read, .write, .writeWithoutResponse, .notify, .indicate]
    }
}
