//
//  BrowserView.swift
//  NativeWebKit
//
//  Created by Zack Qattan on 12/22/23.
//

// https://medium.com/@yeeedward/messaging-between-wkwebview-and-native-application-in-swiftui-e985f0bfacf

import OSLog
import SwiftUI
import UkatonMacros
import WebKit

extension URL {
    var deepLinkScheme: String { "nativewebkit" }
    var deepLinkPrefix: String { "\(deepLinkScheme)://" }
    var isDeeplink: Bool {
        scheme == deepLinkScheme
    }

    var deepLinkUrl: String? {
        if isDeeplink {
            var urlString = absoluteString.removePrefix(deepLinkPrefix)
            if urlString.hasPrefix("https//") {
                urlString = urlString.replacePrefix("https//", with: "https://")
            }
            if urlString.hasPrefix("http//") {
                urlString = urlString.replacePrefix("http//", with: "http://")
            }
            return urlString
        }
        return nil
    }
}

@StaticLogger
struct BrowserView: View {
    @StateObject var browserViewModel = BrowserViewModel()
    @FocusState var isUrlFocused: Bool

    var body: some View {
        GeometryReader { geometry in
            VStack {
                BrowserWebView(viewModel: browserViewModel)
                    .modify {
                        if let title = browserViewModel.title {
                            $0.navigationTitle(title)
                        }
                    }
            }
            .modify {
                #if os(macOS)
                $0.toolbar {
                    ToolbarItemGroup(placement: .navigation) {
                        toolbarItems(geometry: geometry)
                    }
                }
                #endif
            }
        }
        .onOpenURL { incomingURL in
            logger.debug("(ContentView) App was opened via URL: \(incomingURL)")
            handleIncomingURL(incomingURL)
        }

        #if !os(macOS)
        HStack {
            toolbarItems
        }
        .padding(.horizontal)
        .padding(.top, 1.0)
        #endif
    }

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

#Preview("") {
    BrowserView()
        .modify {
            #if os(macOS)
            $0.frame(maxWidth: 300)
            #endif
        }
}
