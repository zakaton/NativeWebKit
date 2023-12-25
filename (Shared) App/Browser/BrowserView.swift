//
//  BrowserView.swift
//  NativeWebKit
//
//  Created by Zack Qattan on 12/22/23.
//

// https://medium.com/@yeeedward/messaging-between-wkwebview-and-native-application-in-swiftui-e985f0bfacf

import Combine
import OSLog
import SwiftUI
import UkatonMacros
import WebKit

@StaticLogger
struct BrowserView: View {
    @StateObject var browserViewModel = BrowserViewModel()
    @FocusState var isUrlFocused: Bool
    @State var backgroundColor: Color = .clear
    @State var showNavigationBar: Bool = true
    @State var isFindInteractionVisible: Bool = false

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
        .background(backgroundColor)

        #if !os(macOS)
        HStack(alignment: .center) {
            toolbarItems
        }
        .padding(.horizontal)
        .padding(.top, isFindInteractionVisible ? 0 : 1.0)
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
