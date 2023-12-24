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
    @ObservedObject var viewModel: BrowserViewModel

    func makeView() -> WKWebView {
        let webView = WKWebView()

        webView.isInspectable = true

        #if !os(macOS)
        webView.isFindInteractionEnabled = true
        #endif

        webView.configuration.preferences.isElementFullscreenEnabled = true
        webView.configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
        webView.configuration.allowsAirPlayForMediaPlayback = true
        webView.configuration.mediaTypesRequiringUserActionForPlayback = .all
        #if !os(macOS)
        webView.configuration.ignoresViewportScaleLimits = false
        webView.configuration.allowsInlineMediaPlayback = true
        webView.configuration.allowsPictureInPictureMediaPlayback = true
        #endif

        viewModel.webView = webView
        webView.load(URLRequest(url: viewModel.url!))
        return webView
    }
}
