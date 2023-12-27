//
//  BrowserViewModel+history.swift
//  NativeWebKit
//
//  Created by Zack Qattan on 12/27/23.
//

import WebKit

extension BrowserViewModel {
    var hasHistory: Bool {
        !webView.backForwardList.backList.isEmpty
    }
}
