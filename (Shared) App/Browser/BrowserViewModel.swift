//
//  BrowserViewModel.swift
//  NativeWebKit
//
//  Created by Zack Qattan on 12/22/23.
//

import OSLog
import SwiftUI
import UkatonMacros
import WebKit

@StaticLogger
class BrowserViewModel: NSObject, ObservableObject, WKNavigationDelegate {
    weak var webView: WKWebView? {
        didSet {
            webView?.navigationDelegate = self
        }
    }

    @Published var urlString = "https://www.apple.com"
    @Published var canGoBack = false
    @Published var canGoForward = false

    func loadURLString() {
        if let url = URL(string: urlString) {
            webView?.load(URLRequest(url: url))
        }
    }

    func goBack() {
        webView?.goBack()
    }

    func goForward() {
        webView?.goForward()
    }

    func reload() {
        webView?.reload()
    }
}
