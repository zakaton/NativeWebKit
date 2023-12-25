//
//  ShareViewController.swift
//  Share
//
//  Created by Zack Qattan on 12/24/23.
//

// https://medium.com/@damisipikuda/how-to-receive-a-shared-content-in-an-ios-application-4d5964229701

import CoreServices
import Foundation
import OSLog
import Social
import UIKit
import UkatonMacros
import UniformTypeIdentifiers

@StaticLogger
class ShareViewController: UIViewController {
    private let typeURL = UTType.url
    private let urlPrefix = "nativewebkit://"

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem,
              let itemProvider = extensionItem.attachments?.first
        else {
            extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
            return
        }

        if itemProvider.hasItemConformingToTypeIdentifier(self.typeURL.identifier) {
            self.handleIncomingURL(itemProvider: itemProvider)
        } else {
            logger.error("Error: No url or text found")
            extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
        }
    }

    private func handleIncomingURL(itemProvider: NSItemProvider) {
        logger.debug("handleIncomingURL \(itemProvider.debugDescription, privacy: .public)")
        itemProvider.loadItem(forTypeIdentifier: self.typeURL.identifier) { [self] item, error in
            if let error {
                logger.error("URL-Error: \(error.localizedDescription, privacy: .public)")
            }

            guard let url = item as? NSURL else {
                extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
                return
            }

            self.openMainApp(with: url.absoluteString!)
        }
    }

    private func openMainApp(with urlString: String) {
        logger.debug("openMainApp")
        self.extensionContext?.completeRequest(returningItems: nil, completionHandler: { [self] _ in
            logger.debug("getting url from \(self.urlPrefix, privacy: .public)")
            guard let url = URL(string: self.urlPrefix + urlString) else {
                return
            }
            logger.debug("url \(url.debugDescription, privacy: .public)")
            _ = self.openURL(url)
        })
    }

    // Courtesy: https://stackoverflow.com/a/44499222/13363449 👇🏾
    // Function must be named exactly like this so a selector can be found by the compiler!
    // Anyway - it's another selector in another instance that would be "performed" instead.
    @objc private func openURL(_ url: URL) -> Bool {
        var responder: UIResponder? = self
        while responder != nil {
            if let application = responder as? UIApplication {
                return application.perform(#selector(self.openURL(_:)), with: url) != nil
            }
            responder = responder?.next
        }
        return false
    }
}
