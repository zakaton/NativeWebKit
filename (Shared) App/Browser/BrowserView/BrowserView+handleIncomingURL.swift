//
//  BrowserView+handleIncomingURL.swift
//  NativeWebKit
//
//  Created by Zack Qattan on 12/26/23.
//

import WebKit

extension BrowserView {
    func handleIncomingURL(_ url: URL) {
        guard url.isDeeplink else {
            logger.warning("url is not deep link")
            return
        }

        guard let newUrlString = url.deepLinkUrl else {
            logger.warning("unable to get deepLinkUrl")
            return
        }

        logger.debug("new urlString from deepLink: \(newUrlString)")
        browserViewModel.urlString = newUrlString
        browserViewModel.loadURLString()
    }
}
