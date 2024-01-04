//
//  BrowserViewModel.swift
//  NativeWebKit
//
//  Created by Zack Qattan + ChatGPT on 12/22/23.
//

import Combine
import OSLog
import SwiftUI
import UkatonMacros
import WebKit

@StaticLogger
class BrowserViewModel: NSObject, ObservableObject {
    static var models: [BrowserViewModel] = []
    static var activeModel: BrowserViewModel? = .init()

    override init() {
        super.init()

        Self.models.append(self)
    }

    deinit {
        if isActiveModel {
            logger.debug("removing active browserViewModel")
            Self.activeModel = nil
        }
        Self.models.removeAll(where: { $0 == self })
    }

    var isActiveModel: Bool {
        self == Self.activeModel
    }

    var index: Int! {
        Self.models.firstIndex(of: self)
    }

    // MARK: - WKWebView

    lazy var webView: WKWebView = {
        let configuration: WKWebViewConfiguration = .init()
        configuration.applicationNameForUserAgent = "NativeWebKit"
        configuration.allowsAirPlayForMediaPlayback = true
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        #if !os(macOS)
        configuration.ignoresViewportScaleLimits = false
        configuration.allowsInlineMediaPlayback = true
        configuration.allowsPictureInPictureMediaPlayback = true
        #endif

        let defaultWebpagePreferences: WKWebpagePreferences = .init()
        defaultWebpagePreferences.allowsContentJavaScript = true
        configuration.defaultWebpagePreferences = defaultWebpagePreferences

        let userContentController: WKUserContentController = .init()
        userContentController.removeAllScriptMessageHandlers()
        userContentController.add(self, contentWorld: .page, name: "nativewebkit_noreply")
        userContentController.addScriptMessageHandler(self, contentWorld: .page, name: "nativewebkit_reply")
        configuration.userContentController = userContentController

        let preferences: WKPreferences = .init()
        preferences.isElementFullscreenEnabled = true
        preferences.isFraudulentWebsiteWarningEnabled = true
        preferences.javaScriptCanOpenWindowsAutomatically = true
        preferences.inactiveSchedulingPolicy = .throttle
        configuration.preferences = preferences

        let _webView = WKWebView(frame: .zero, configuration: configuration)

        #if !os(macOS)
        _webView.isFindInteractionEnabled = true
        #endif

        _webView.isInspectable = true
        _webView.allowsBackForwardNavigationGestures = true
        _webView.allowsLinkPreview = true
        _webView.underPageBackgroundColor = .white

        setWebViewNavigationDelegate(_webView)
        setWebViewUIDelegate(_webView)
        setObservations(_webView)
        #if !os(macOS)
        setUIScrollViewDelegate(_webView)
        #endif

        _webView.load(URLRequest(url: url!))
        return _webView
    }()

    // MARK: - Url

    static let defaultUrlString = "https://192.168.1.44:5500"

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
        } else {
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

    // MARK: - Navigation

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

    // MARK: - Theme Color

    @Published var themeColor: Color = .clear {
        didSet {
            didGetThemeColor = true
        }
    }

    var didGetThemeColor: Bool = false
    let getBackgroundColorJavaScriptString: String = """
    (function getBackgroundColor(element) {
      // If no element is provided, default to document.body
      element = element || document.body;

      // Get the computed style of the current element
      var computedStyle = window.getComputedStyle(element);

      // Get the computed background color
      var backgroundColor = computedStyle.backgroundColor;

      // Parse the background color string into an array of numbers
      var colorArray = backgroundColor.match(/\\d+/g).map(Number);

      // If the array has fewer than 3 values, add 255 (fully opaque) for the alpha component
      if (colorArray.length < 4) {
        colorArray.push(255);
      }

      // If the alpha component is 0 (fully transparent), recursively check the parent element
      if (colorArray[3] === 0 && element.parentElement) {
        return getBackgroundColor(element.parentElement);
      }

      // Return the array representing RGBA components
      return colorArray.map(value => value/255)
    })()
    """

    func getThemeColorWithJavaScript() {
        // ChatGPT made getBackgroundColor
        webView.evaluateJavaScript(getBackgroundColorJavaScriptString, completionHandler: { [self] value, error in
            if let error {
                logger.error("error \(error.localizedDescription)")
                return
            }

            if let rgba = value as? [Double], rgba.count == 4 {
                logger.debug("themeColor rgba \(rgba)")
                themeColor = .init(red: rgba[0], green: rgba[1], blue: rgba[2], opacity: rgba[3])
            }
        })
    }

    // MARK: - Observations

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
            logger.debug("webView theme color \(webView.themeColor.debugDescription)")
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
            logger.debug("new theme color \(webView.themeColor.debugDescription)")
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

    // MARK: Panel

    @Published var showPanel: Bool = false
    var panel: Panel? {
        didSet {
            showPanel = panel != nil
        }
    }

    // MARK: - NativeWebKit

    var nativeWebKit: NativeWebKit { .shared }
}
