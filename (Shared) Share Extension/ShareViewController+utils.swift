//
//  ShareViewController+utils.swift
//  NativeWebKit
//
//  Created by Zack Qattan on 12/27/23.
//
// Users/zakaton/Documents/GitHub/NativeWebKit/(Shared) Share Extension/ShareViewController+utils.swift:11:8 No such module 'Social'

import CoreServices
import Foundation
import OSLog
import Social
import UkatonMacros
import UniformTypeIdentifiers

extension ShareViewController {
    var urlPrefix: String { "nativewebkit://" }

    func completeRequest() {
        extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
    }

    func handleIncomingData() {
        guard let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem,
              let itemProvider = extensionItem.attachments?.first
        else {
            extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
            return
        }

        if itemProvider.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
            self.handleIncomingURL(itemProvider: itemProvider)
        } else if itemProvider.hasItemConformingToTypeIdentifier(UTType.text.identifier) {
            self.handleIncomingText(itemProvider: itemProvider)
        } else {
            logger.error("Error: No url or text found")
            self.completeRequest()
        }
    }

    func handleIncomingURL(itemProvider: NSItemProvider) {
        logger.debug("handleIncomingURL \(itemProvider.debugDescription, privacy: .public)")
        itemProvider.loadItem(forTypeIdentifier: UTType.url.identifier) { [self] item, error in
            if let error {
                logger.error("URL-Error: \(error.localizedDescription, privacy: .public)")
                self.completeRequest()
                return
            }

            #if os(macOS)
            guard let data = item as? Data,
                  let urlString = String(data: data as Data, encoding: .utf8)
            else {
                return
            }
            self.openMainApp(with: urlString)
            #else
            guard let url = item as? NSURL, let urlString = url.absoluteString else {
                self.completeRequest()
                return
            }
            #endif

            self.openMainApp(with: urlString)
        }
    }

    func handleIncomingText(itemProvider: NSItemProvider) {
        logger.debug("handleIncomingText \(itemProvider.debugDescription, privacy: .public)")
        itemProvider.loadItem(forTypeIdentifier: UTType.text.identifier) { [self] item, error in
            if let error {
                logger.error("Text-Error: \(error.localizedDescription, privacy: .public)")
                self.completeRequest()
                return
            }

            guard let urlString = item as? String else {
                self.completeRequest()
                return
            }

            self.openMainApp(with: urlString)
        }
    }

    func openMainApp(with urlString: String) {
        logger.debug("openMainApp")
        self.extensionContext?.completeRequest(returningItems: nil, completionHandler: { [self] _ in
            logger.debug("getting url from \(self.urlPrefix, privacy: .public)")
            guard let url = URL(string: self.urlPrefix + urlString) else {
                return
            }
            logger.debug("url \(url.debugDescription, privacy: .public)")
            #if os(macOS)
            NSWorkspace.shared.open(url)
            #else
            _ = self.openURL(url)
            #endif
        })
    }
}
