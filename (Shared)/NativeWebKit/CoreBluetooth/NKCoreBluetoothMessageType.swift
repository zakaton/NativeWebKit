//
//  NKCoreBluetoothMessageType.swift
//  NativeWebKit
//
//  Created by Zack Qattan on 1/29/24.
//

import Foundation

enum NKCoreBluetoothMessageType: String, NKMessageTypeProtocol {
    static let prefix: String = "cb"
    case state
    case isScanning
    case startScan
    case discoveredPeripheral
    case discoveredPeripherals
    case stopScan
    case connect
    case connectionState
    case disconnect
    case disconnectAll
    case connectedPeripherals
}
