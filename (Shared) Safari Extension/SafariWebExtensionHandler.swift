//
//  SafariWebExtensionHandler.swift
//  Extension
//
//  Created by Zack Qattan on 12/21/23.
//

import OSLog
import SafariServices
import UkatonMacros

@StaticLogger
class SafariWebExtensionHandler: NSObject, NSExtensionRequestHandling {
    var nativeWebKit: NativeWebKit { .shared }
    func beginRequest(with context: NSExtensionContext) {
        guard let item = context.inputItems.first as? NSExtensionItem,
              let userInfo = item.userInfo as? [String: Any],
              let messageData = userInfo[SFExtensionMessageKey]
        else {
            context.completeRequest(returningItems: nil, completionHandler: nil)
            return
        }

        logger.debug("received message \(String(describing: messageData), privacy: .public)")

        guard let _response = nativeWebKit.handleMessage(messageData) else {
            logger.error("nil response")
            return
        }

        let response = NSExtensionItem()
        response.userInfo = [SFExtensionMessageKey: _response]

        logger.debug("response: \(response, privacy: .public)")
        context.completeRequest(returningItems: [response], completionHandler: nil)
    }
}
