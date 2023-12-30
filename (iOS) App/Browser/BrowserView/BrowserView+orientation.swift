//
//  BrowserView+Orientation.swift
//  (iOS) NativeWebKit
//
//  Created by Zack Qattan on 12/26/23.
//

import Foundation

extension BrowserView {
    var isPortrait: Bool {
        horizontalSizeClass == .compact && verticalSizeClass == .regular
    }

    var isLandscape: Bool {
        horizontalSizeClass == .regular && verticalSizeClass == .compact
    }
}
