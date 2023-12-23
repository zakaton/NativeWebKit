//
//  BrowserViewModel.swift
//  NativeWebKit
//
//  Created by Zack Qattan on 12/22/23.
//

import Combine
import OSLog
import SwiftUI
import UkatonMacros
import WebKit

@StaticLogger
class BrowserViewModel: NSObject, ObservableObject {
    weak var webView: WKWebView! {
        didSet {
            setWebViewNavigationDelegate()
            #if !os(macOS)
            setUIScrollViewDelegate()
            #endif
        }
    }

    @Published var urlString = "https://www.apple.com"

    var formattedUrlString: String {
        guard urlString.hasPrefix("http://") || urlString.hasPrefix("https://") else {
            return "https://\(urlString)"
        }
        return urlString
    }

    var url: URL? {
        URL(string: formattedUrlString)
    }

    func loadURLString() {
        if let url {
            logger.debug("loading \(url.absoluteString)")
            webView.load(URLRequest(url: url))
        }
        else {
            let urlString = self.urlString
            logger.warning("invalid urlString \(urlString)")
        }
    }

    let searchPrefix: String = "https://www.google.com/search?q="
    var isSearch: Bool {
        urlString.hasPrefix(searchPrefix)
    }

    @Published var canGoBack = false
    @Published var canGoForward = false

    func goBack() {
        webView.goBack()
    }

    func goForward() {
        webView.goForward()
    }

    func reload() {
        webView.reload()
    }
}
