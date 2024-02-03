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
    case stopScan
    case discoveredPeripheral
    case discoveredPeripherals
    
    case connect
    case peripheralConnectionState
    case disconnect
    case disconnectAll
    
    case connectedPeripherals
    case disconnectedPeripherals
    
    case readRSSI
    case getRSSI
    
    case discoverServices
    case discoverIncludedServices
    case discoverCharacteristics
    case discoverDescriptors
    
    case getServices
    case getIncludedServices
    case getCharacteristics
    case getDescriptors

    case readCharacteristicValue
    case writeCharacteristicValue
    case setCharacteristicNotifyValue
    
    case getCharacteristicValue
    case updatedCharacteristicValues
    case getCharacteristicNotifyValue

    case readDescriptorValue
    case writeDescriptorValue

    case getDescriptorValue
}
