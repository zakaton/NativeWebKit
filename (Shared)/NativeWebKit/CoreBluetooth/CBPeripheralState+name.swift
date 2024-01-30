//
//  CBPeripheralState+name.swift
//  NativeWebKit
//
//  Created by Zack Qattan on 1/30/24.
//

import CoreBluetooth

extension CBPeripheralState {
    var name: String {
        switch self {
        case .disconnected:
            "disconnected"
        case .connecting:
            "connecting"
        case .connected:
            "connected"
        case .disconnecting:
            "disconnecting"
        @unknown default:
            "unknown"
        }
    }
}
