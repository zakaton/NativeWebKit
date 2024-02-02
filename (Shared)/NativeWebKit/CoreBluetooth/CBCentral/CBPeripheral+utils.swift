//
//  CBPeripheral+utils.swift
//  NativeWebKit
//
//  Created by Zack Qattan on 1/31/24.
//

import CoreBluetooth

extension CBPeripheral {
    var identifierString: String {
        identifier.uuidString
    }
}
