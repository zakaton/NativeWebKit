//
//  BrowserViewModel+WKScriptMessageHandlerWithReply.swift
//  NativeWebKit
//
//  Created by Zack Qattan on 12/29/23.
//

import WebKit

extension BrowserViewModel: WKScriptMessageHandlerWithReply {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage, replyHandler: @escaping (Any?, String?) -> Void) {
        logger.debug("received message \(String(describing: message.body), privacy: .public)")
        if let _message = message.body as? [String: Any] {
            if let response = nativeWebKit.handleMessage(message: _message) {
                replyHandler(response, nil)
            }
            else {
                let errorString = "nil response"
                logger.error("\(errorString)")
                replyHandler(nil, errorString)
            }
        }
        else {
            let errorString = "invalid message format"
            logger.error("\(errorString)")
            replyHandler(nil, errorString)
        }
    }

    // func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) async -> (Any?, String?) {}
}
