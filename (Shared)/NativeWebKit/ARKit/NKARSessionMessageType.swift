//
//  NKARSessionMessageType.swift
//  NativeWebKit
//
//  Created by Zack Qattan on 1/6/24.
//

import Foundation

enum NKARSessionMessageType: String, NKMessageTypeProtocol {
    static let prefix: String = "ars"
    case worldTrackingSupport
    case faceTrackingSupport
    case run
    case isRunning
    case pause
    case frame
    case debugOptions
}
