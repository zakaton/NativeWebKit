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
        logger.debug("received authentication challenge \(challenge.debugDescription) \(challenge.previousFailureCount)")

        guard let serverTrust = challenge.protectionSpace.serverTrust else {
            logger.error("serverTrust not found")
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        // TODO: - fix "This method should not be called on the main thread as it may lead to UI unresponsiveness." issue
        SecTrustEvaluateAsyncWithError(serverTrust, .main) { [self] serverTrust, trusted, error in
            logger.debug("trusted? \(trusted)")
            if let error {
                logger.debug("error? \(error.localizedDescription)")
                // TODO: - panel shows up twice, and crashes when selecting "Trust Anyway"
                // panel = .init(type: .notTrusted(completionHandler: completionHandler, serverTrust: serverTrust), message: error.localizedDescription)
                // return
            }

            DispatchQueue.global(qos: .background).async {
                let credential = URLCredential(trust: serverTrust)
                completionHandler(.useCredential, credential)
            }
        }
    }

    func webView(_ webView: WKWebView, authenticationChallenge challenge: URLAuthenticationChallenge, shouldAllowDeprecatedTLS decisionHandler: @escaping (Bool) -> Void) {
        logger.debug("shouldAllowDeprecatedTLS?")
        // TODO: - show panel
        decisionHandler(true)
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse) async -> WKNavigationResponsePolicy {
        // logger.debug("decidePolicyFor navigationResponse \(navigationResponse.description)")
        return .allow
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) async -> WKNavigationActionPolicy {
        // logger.debug("decidePolicyFor navigationAction \(navigationAction.description)")
        return .allow
    }
}
