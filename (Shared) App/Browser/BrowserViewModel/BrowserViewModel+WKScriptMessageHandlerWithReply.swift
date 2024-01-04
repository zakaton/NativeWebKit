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
        if let response = nativeWebKit.handleMessage(message.body) {
            logger.log("response \(String(describing: response), privacy: .public)")
            replyHandler(response, nil)
        }
        else {
            logger.log("no message response")
            replyHandler(nil, nil)
        }
    }

    // func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) async -> (Any?, String?) {}
}
