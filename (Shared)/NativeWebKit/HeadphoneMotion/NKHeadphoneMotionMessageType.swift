//
//  NKHeadphoneMotionMessageType.swift
//  NativeWebKit
//
//  Created by Zack Qattan on 12/30/23.
//

import Foundation

enum NKHeadphoneMotionMessageType: String, NKMessageTypeProtocol {
    static let prefix: String = "hm"
    case isAvailable
    case isActive
    case startUpdates, stopUpdates
    case getData
}
