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
            setWebViewUIDelegate()
            #if !os(macOS)
            setUIScrollViewDelegate()
            #endif
        }
    }

    static let defaultUrlString = "https://www.google.com"

    @Published var urlString = defaultUrlString

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
            let currentUrlString = urlString
            logger.warning("invalid urlString \"\(currentUrlString)\"")
            urlString = searchPrefix + currentUrlString.replacingOccurrences(of: " ", with: "+")
            loadURLString()
        }
    }

    let searchPrefix: String = "https://www.google.com/search?q="
    var isSearch: Bool {
        urlString.hasPrefix(searchPrefix)
    }

    @Published var canGoBack = false
    @Published var canGoForward = false
    @Published var title: String?

    func goBack() {
        webView.goBack()
        updateNavigationControls()
    }

    func goForward() {
        webView.goForward()
        updateNavigationControls()
    }

    func updateNavigationControls() {
        canGoBack = webView.canGoBack
        canGoForward = webView.canGoForward
    }

    func reload() {
        webView.reload()
    }

    @Published var dragVelocity: CGPoint = .zero
}
