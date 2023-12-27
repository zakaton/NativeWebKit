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
    lazy var webView: WKWebView = {
        let _webView = WKWebView()

        _webView.isInspectable = true
        _webView.allowsBackForwardNavigationGestures = true
        _webView.allowsLinkPreview = true

        #if !os(macOS)
        _webView.isFindInteractionEnabled = true
        #endif

        _webView.configuration.preferences.isElementFullscreenEnabled = true
        _webView.configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
        _webView.configuration.allowsAirPlayForMediaPlayback = true
        _webView.configuration.mediaTypesRequiringUserActionForPlayback = .all
        // _webView.configuration.preferences.inactiveSchedulingPolicy = .throttle
        #if !os(macOS)
        _webView.configuration.ignoresViewportScaleLimits = false
        _webView.configuration.allowsInlineMediaPlayback = true
        _webView.configuration.allowsPictureInPictureMediaPlayback = true
        #endif

        setWebViewNavigationDelegate(_webView)
        setWebViewUIDelegate(_webView)
        setObservations(_webView)
        #if !os(macOS)
        setUIScrollViewDelegate(_webView)
        #endif

        _webView.load(URLRequest(url: url!))
        return _webView
    }()

    @Published var themeColor: Color = .clear

    var observations: [NSKeyValueObservation] = []
    func setObservations(_ webView: WKWebView) {
        let titleObservation = webView.observe(\.title, options: [.new]) { [unowned self] _, value in
            if let newTitle = value.newValue as? String, !newTitle.isEmpty {
                logger.debug("new title \(newTitle)")
                title = newTitle
            }
        }
        observations.append(titleObservation)

        let themeColorObservation = webView.observe(\.themeColor, options: [.new]) { [unowned self] _, value in
            logger.debug("new theme color....\(webView.themeColor.debugDescription)")
            #if os(macOS)
            if let newThemeColor = value.newValue as? NSColor {
                self.logger.debug("new theme color \(newThemeColor.description)")
                themeColor = .init(nsColor: newThemeColor)
            }
            #else
            if let newThemeColor = value.newValue as? UIColor {
                self.logger.debug("new theme color \(newThemeColor.description)")
                themeColor = .init(uiColor: newThemeColor)
            }
            #endif
        }
        observations.append(themeColorObservation)

        let underPageBackgroundColorObservation = webView.observe(\.underPageBackgroundColor, options: [.new]) { [unowned self] _, value in
            logger.debug("observed new under page background color")
            #if os(macOS)
            if let newThemeColor = value.newValue as? NSColor {
                self.logger.debug("new theme color \(newThemeColor.description)")
                themeColor = .init(nsColor: newThemeColor)
            }
            #else
            if let newThemeColor = value.newValue as? UIColor {
                self.logger.debug("new theme color \(newThemeColor.description)")
                themeColor = .init(uiColor: newThemeColor)
            }
            #endif
        }
        observations.append(underPageBackgroundColorObservation)
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
    }

    func goForward() {
        webView.goForward()
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
