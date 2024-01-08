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
    @ObservedObject var browserViewModel: BrowserViewModel
    @FocusState var isUrlFocused: Bool
    @State var expandSearchBar: Bool = false
    @State var showNavigationBar: Bool = true
    @State var isFindInteractionVisible: Bool = false
    @State var isKeyboardVisible: Bool = false
    @State var sheetType: SheetType?

    #if os(macOS)
    @FocusState var isFindFocused: Bool
    @State var findString: String = ""
    @ObservedObject var findToolbarModel: FindToolbarModel = .shared
    #endif

    @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?

    var panel: Panel? { browserViewModel.panel }

    #if os(iOS)
    @State var orientation = UIDeviceOrientation.unknown
    #endif

    var nativeWebKit: NativeWebKit { .shared }

    #if os(iOS)
    @State var isARSessionRunning: Bool = false
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
                ZStack {
                    #if os(iOS)
                    if isARSessionRunning {
                        ARViewContainer()
                            .edgesIgnoringSafeArea(.top)
                    }
                    #endif
                    BrowserWebView(viewModel: browserViewModel)
                        .modify {
                            if let title = browserViewModel.title {
                                $0.navigationTitle(title)
                            }
                        }
                        .alert(panel?.title ?? "", isPresented: $browserViewModel.showPanel) {
                            alertActionsView
                        } message: {
                            alertMessageView
                        }
                }
                .modify {
                    #if os(iOS)
                    $0.onReceive(nativeWebKit.$isARSessionRunning, perform: {
                        isARSessionRunning = $0
                    })
                    #endif
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
        .sheet(item: $sheetType, onDismiss: {
            logger.debug("sheet dismissed")
        }) { sheetType in
            switch sheetType {
            case .history:
                historySheet
                    .presentationDetents([.medium])
            }
        }
        .onOpenURL { incomingURL in
            logger.debug("(ContentView) App was opened via URL: \(incomingURL)")
            handleIncomingURL(incomingURL)
        }
        .modify {
            #if os(iOS)
            if isARSessionRunning {
                $0.background(.clear)
            }
            else {
                $0.background(browserViewModel.themeColor)
                    .background(.white)
            }
            #else
            $0.background(browserViewModel.themeColor)
                .background(.white)
            #endif
        }
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
    BrowserView(browserViewModel: .activeModel!)
        .modify {
            #if os(macOS)
            $0.frame(maxWidth: 300)
            #endif
        }
}
