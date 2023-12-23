//
//  BrowserViewModel+WKNavigationDelegate.swift
//  NativeWebKit
//
//  Created by Zack Qattan on 12/23/23.
//

import WebKit

extension BrowserViewModel {
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        if let newUrlString = webView.url?.absoluteString {
            urlString = newUrlString
        }
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("didFail \(error.localizedDescription)")
        logger.error("didFail \(error.localizedDescription)")
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("didFailProvisionalNavigation \(error.localizedDescription)")
        if !isSearch {
            logger.error("didFailProvisionalNavigation \(error.localizedDescription)")
            urlString = "\(searchPrefix)\(urlString)"
            loadURLString()
        }
    }
}
