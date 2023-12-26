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
    @State var isKeyboardVisible: Bool = false

    @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?
    @State private var orientation = UIDeviceOrientation.unknown

    var body: some View {
        #if !os(macOS)
        if !isPortrait {
            HStack(alignment: .center) {
                toolbarItems
            }
            .padding(.horizontal)
            .padding(.top, 0.5)
        }
        #endif

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
        .onRotate { newOrientation in
            // logger.debug("newOrientation \(newOrientation.rawValue)")
            switch newOrientation {
            case .unknown, .faceUp, .faceDown:
                break
            default:
                orientation = newOrientation
            }
        }
        .modify {
            #if !os(macOS)
            if !isPortrait {
                $0.ignoresSafeArea(.all)
            }
            #endif
        }

        #if !os(macOS)
        if isPortrait {
            HStack(alignment: .center) {
                toolbarItems
            }
            .padding(.horizontal)
            .padding(.top, isKeyboardVisible ? 0 : 1.0)
        }
        #endif
    }

    var isPortrait: Bool {
        if orientation == .unknown {
            return horizontalSizeClass == .compact && verticalSizeClass == .regular
        }

        return switch orientation {
        case .landscapeLeft, .landscapeRight:
            false
        default:
            true
        }
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
