//
//  BrowserView+Orientation.swift
//  (iOS) NativeWebKit
//
//  Created by Zack Qattan on 12/26/23.
//

import Foundation

extension BrowserView {
    var isPortrait: Bool {
        if orientation == .unknown {
            return horizontalSizeClass == .compact && verticalSizeClass == .regular
        }

        return switch orientation {
        case .landscapeLeft, .landscapeRight:
            false
        default:
            true
        }
    }
}
