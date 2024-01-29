//
//  CBManagerState+name.swift
//  NativeWebKit
//
//  Created by Zack Qattan on 1/29/24.
//

import CoreBluetooth

extension CBManagerState {
    var name: String {
        switch self {
        case .unknown:
            "unknown"
        case .resetting:
            "resetting"
        case .unsupported:
            "unsupported"
        case .unauthorized:
            "unauthorized"
        case .poweredOff:
            "poweredOff"
        case .poweredOn:
            "poweredOn"
        @unknown default:
            "unknown"
        }
    }
}
