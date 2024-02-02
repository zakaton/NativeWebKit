//
//  NKCBCentralMessageType.swift
//  NativeWebKit
//
//  Created by Zack Qattan on 1/29/24.
//

import Foundation

enum NKCBCentralMessageType: String, NKMessageTypeProtocol {
    static let prefix: String = "cbc"
    case state
    case isScanning
    case startScan
    case discoveredPeripheral
    case discoveredPeripherals
    case stopScan
    case connect
    case peripheralConnectionState
    case disconnect
    case disconnectAll
    case connectedPeripherals
    case disconnectedPeripherals
    case readRSSI
    case getRSSI
    case getService
    case getServices
}
