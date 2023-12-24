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
    func beginRequest(with context: NSExtensionContext) {
        let request = context.inputItems.first as? NSExtensionItem

        let profile: UUID?
        if #available(iOS 17.0, macOS 14.0, *) {
            profile = request?.userInfo?[SFExtensionProfileKey] as? UUID
        } else {
            profile = request?.userInfo?["profile"] as? UUID
        }

        let message: Any?
        if #available(iOS 17.0, macOS 14.0, *) {
            message = request?.userInfo?[SFExtensionMessageKey]
        } else {
            message = request?.userInfo?["message"]
        }

        logger.debug("Received message from browser.runtime.sendNativeMessage: \(String(describing: message)) (profile: \(profile?.uuidString ?? "none")")

        let response = NSExtensionItem()
        response.userInfo = [SFExtensionMessageKey: ["echo": message]]

        context.completeRequest(returningItems: [response], completionHandler: nil)
    }
}
