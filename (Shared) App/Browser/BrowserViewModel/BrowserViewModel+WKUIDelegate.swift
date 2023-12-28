//
//  BrowserViewModel+WKUIDelegate.swift
//  NativeWebKit
//
//  Created by Zack Qattan on 12/25/23.
//

import WebKit

extension BrowserViewModel: WKUIDelegate {
    func setWebViewUIDelegate(_ webView: WKWebView) {
        webView.uiDelegate = self
    }

    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        logger.debug("alert \"\(message)\"")
        panel = .init(type: .alert(completionHandler: completionHandler), message: message)
    }

    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        logger.debug("prompt \"\(prompt)\" with defaultText \"\(defaultText ?? "nil")\"")
        panel = .init(type: .prompt(completionHandler: completionHandler, defaultText: defaultText), message: prompt)
    }

    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        logger.debug("confirm \"\(message)\"")
        panel = .init(type: .confirm(completionHandler: completionHandler), message: message)
    }
}
