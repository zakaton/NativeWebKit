//
//  BrowserWebView.swift
//  NativeWebKit
//
//  Created by Zack Qattan on 12/22/23.
//

// https://www.swiftyplace.com/blog/loading-a-web-view-in-swiftui-with-wkwebview

import SwiftUI
import WebKit

struct BrowserWebView {
    let url: URL
    @ObservedObject var viewModel: BrowserViewModel

    func makeView() -> WKWebView {
        let webView = WKWebView()
        viewModel.webView = webView
        webView.load(URLRequest(url: url))
        return webView
    }
}
