//
//  BrowserWebView.swift
//  NativeWebKit
//
//  Created by Zack Qattan on 12/22/23.
//

// https://www.swiftyplace.com/blog/loading-a-web-view-in-swiftui-with-wkwebview

import OSLog
import SwiftUI
import UkatonMacros
import WebKit

@StaticLogger
struct BrowserWebView {
    @ObservedObject var viewModel: BrowserViewModel

    init(viewModel: BrowserViewModel) {
        self.viewModel = viewModel
    }

    func makeView() -> WKWebView {
        viewModel.webView
    }
}
