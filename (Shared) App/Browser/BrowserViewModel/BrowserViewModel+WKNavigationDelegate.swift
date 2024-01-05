//
//  BrowserViewModel+WKNavigationDelegate.swift
//  NativeWebKit
//
//  Created by Zack Qattan on 12/23/23.
//

import WebKit

extension BrowserViewModel: WKNavigationDelegate {
    func setWebViewNavigationDelegate(_ webView: WKWebView) {
        webView.navigationDelegate = self
    }

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

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        updateNavigationControls()
        logger.debug("loaded \(webView.url?.absoluteString ?? "nil", privacy: .public)")
        if !didGetThemeColor {
            getThemeColorWithJavaScript()
        }
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        didGetThemeColor = false
        updateNavigationControls()
    }

    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        logger.debug("received authentication challenge \(challenge.debugDescription)")

        guard let serverTrust = challenge.protectionSpace.serverTrust else {
            logger.error("serverTrust not found")
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        SecTrustEvaluateAsyncWithError(serverTrust, .main) { serverTrust, trusted, error in
            self.logger.debug("trusted? \(trusted)")
            if let error {
                self.logger.debug("error? \(error.localizedDescription)")
            }

            DispatchQueue.global(qos: .background).async {
                let credential = URLCredential(trust: serverTrust)
                completionHandler(.useCredential, credential)
            }
        }
    }
}
