//
//  NKARSessionConfigurationType.swift
//  (iOS) NativeWebKit
//
//  Created by Zack Qattan on 1/8/24.
//

import Foundation

enum NKARSessionConfigurationType: String {
    var name: String { rawValue }
    case worldTracking
    case faceTracking
}
