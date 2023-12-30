//
//  BrowserViewModel+WKScriptMessageHandler.swift
//  NativeWebKit
//
//  Created by Zack Qattan on 12/29/23.
//

import WebKit

extension BrowserViewModel: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        logger.debug("received message \(String(describing: message.body), privacy: .public)")
        if let _message = message.body as? NKMessage {
            nativeWebKit.handleMessage(message: _message)
        }
        else {
            logger.error("invalid message format")
        }
    }
}
