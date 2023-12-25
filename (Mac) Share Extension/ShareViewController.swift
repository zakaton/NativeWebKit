//
//  ShareViewController.swift
//  Share
//
//  Created by Zack Qattan on 12/24/23.
//

// https://medium.com/@damisipikuda/how-to-receive-a-shared-content-in-an-ios-application-4d5964229701

import AppKit
import CoreServices
import OSLog
import Social
import UkatonMacros

@StaticLogger
class ShareViewController: NSViewController {
    private let typeText = String(kUTTypeText)
    private let typeURL = String(kUTTypeURL)
    private let urlPrefix = "nativewebkit://"
    private let groupName = "X3KF23SMC7.group.nativewebkit.share"
    private let urlDefaultName = "incomingURL"

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

        if itemProvider.hasItemConformingToTypeIdentifier(self.typeURL) {
            logger.debug("will handle incoming url")
            self.handleIncomingURL(itemProvider: itemProvider)
        } else {
            logger.error("Error: No url or text found")
            self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
        }
    }

    private func handleIncomingURL(itemProvider: NSItemProvider) {
        logger.debug("handleIncomingURL \(itemProvider.debugDescription, privacy: .public)")
        itemProvider.loadItem(forTypeIdentifier: self.typeURL) { item, error in
            if let error {
                self.logger.error("URL-Error: \(error.localizedDescription, privacy: .public)")
            }

            if let url = item as? NSURL, let urlString = url.absoluteString {
                self.saveURLString(urlString)
            }

            if let data = item as? Data,
               let urlString = String(data: data as Data, encoding: .utf8)
            {
                self.saveURLString(urlString)
            }

            guard let data = item as? Data,
                  let urlString = String(data: data as Data, encoding: .utf8)
            else {
                return
            }

            self.openMainApp(with: urlString)
        }
    }

    private func saveURLString(_ urlString: String) {
        self.logger.debug("saving urlString \(urlString, privacy: .public)")
        UserDefaults(suiteName: self.groupName)?.set(urlString, forKey: self.urlDefaultName)
    }

    private func openMainApp(with urlString: String) {
        logger.debug("openMainApp")
        self.extensionContext?.completeRequest(returningItems: nil, completionHandler: { _ in
            self.logger.debug("getting url from \(self.urlPrefix, privacy: .public)")
            guard let url = URL(string: self.urlPrefix + urlString) else {
                return
            }
            self.logger.debug("url \(url.debugDescription, privacy: .public)")
            // _ = self.openURL(url)
            NSWorkspace.shared.open(url)
        })
    }

    // Courtesy: https://stackoverflow.com/a/44499222/13363449 👇🏾
    // Function must be named exactly like this so a selector can be found by the compiler!
    // Anyway - it's another selector in another instance that would be "performed" instead.
    @objc private func openURL(_ url: URL) -> Bool {
        logger.debug("openURL")
        var responder: NSResponder? = self

        while responder != nil {
            logger.debug("responder \(responder.debugDescription, privacy: .public)")
            if let application = responder as? NSApplication {
                logger.debug("application \(application.debugDescription, privacy: .public)")
                return application.perform(#selector(self.openURL(_:)), with: url) != nil
            }
            responder = responder?.nextResponder
        }
        return false
    }
}
