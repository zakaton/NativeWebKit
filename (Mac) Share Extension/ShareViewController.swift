//
//  ShareViewController.swift
//  Share
//
//  Created by Zack Qattan on 12/24/23.
//

// https://medium.com/@damisipikuda/how-to-receive-a-shared-content-in-an-ios-application-4d5964229701

import AppKit
import CoreServices
import Foundation
import OSLog
import Social
import UkatonMacros
import UniformTypeIdentifiers

@StaticLogger
class ShareViewController: NSViewController {
    private let typeURL = UTType.url
    private let urlPrefix = "nativewebkit://"

    override func viewDidAppear() {
        super.viewDidAppear()

        guard let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem,
              let itemProvider = extensionItem.attachments?.first
        else {
            logger.debug("nothing found")
            self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
            return
        }

        logger.debug("extensionItem \(extensionItem.debugDescription, privacy: .public)")
        logger.debug("itemProvider \(itemProvider.debugDescription, privacy: .public)")

        if itemProvider.hasItemConformingToTypeIdentifier(self.typeURL.identifier) {
            logger.debug("will handle incoming url")
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

            guard let data = item as? Data,
                  let urlString = String(data: data as Data, encoding: .utf8)
            else {
                return
            }

            self.openMainApp(with: urlString)
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
            NSWorkspace.shared.open(url)
        })
    }
}
