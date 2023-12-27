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
    @State var expandSearchBar: Bool = false
    @State var backgroundColor: Color = .clear
    @State var showNavigationBar: Bool = true
    @State var isFindInteractionVisible: Bool = false
    @State var isKeyboardVisible: Bool = false
    @State var sheet: Sheet?

    #if os(macOS)
    @FocusState var isFindFocused: Bool
    @State var findString: String = ""
    @ObservedObject var findToolbarModel: FindToolbarModel = .shared
    #endif

    @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?

    #if os(iOS)
    @State var orientation = UIDeviceOrientation.unknown
    #endif

    var body: some View {
        #if !os(macOS)
        if !isPortrait {
            toolbarItems
        }
        #endif

        GeometryReader { geometry in
            VStack(spacing: 0) {
                #if os(macOS)
                if findToolbarModel.isVisible {
                    findToolbar
                }
                #endif
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
        .sheet(item: $sheet, onDismiss: {
            logger.debug("sheet dismissed")
        }) { sheet in
            switch sheet {
            case .history:
                historySheet
                    .presentationDetents([.medium])
            }
        }
        .onOpenURL { incomingURL in
            logger.debug("(ContentView) App was opened via URL: \(incomingURL)")
            handleIncomingURL(incomingURL)
        }
        .background(backgroundColor)
        .modify {
            #if os(iOS)
            $0.onRotate { newOrientation in
                // logger.debug("newOrientation \(newOrientation.rawValue)")
                switch newOrientation {
                case .unknown, .faceUp, .faceDown:
                    break
                default:
                    orientation = newOrientation
                }
            }
            #endif
        }
        .modify {
            #if os(iOS)
            if !isPortrait {
                $0.ignoresSafeArea(.all)
            }
            #endif
        }

        #if os(iOS)
        if isPortrait {
            toolbarItems
        }
        #endif
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