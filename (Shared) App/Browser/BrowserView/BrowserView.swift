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
#if os(iOS)
import ARKit
import RealityKit
#endif

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
    var webView: WKWebView { browserViewModel.webView }

    #if os(iOS)
    @State var orientation = UIDeviceOrientation.unknown
    #endif

    var nativeWebKit: NativeWebKit { .shared }

    #if os(iOS)
    @State var isARSessionRunning: Bool? {
        didSet {
            updateShowARView()
        }
    }

    @State var arCameraMode: ARView.CameraMode? = nil {
        didSet {
            updateShowARView()
        }
    }

    @State var showARCamera: Bool? {
        didSet {
            updateShowARView()
        }
    }

    func updateShowARView() {
        // originally added "&& showARView", but it seems that not showing the ARViewContainer removes the position/quaternion from the camera data, as if you set arCameraMode to .nonAR
        let newShowARView = isARSessionRunning == true && arCameraMode == .ar
        if newShowARView != showARView {
            logger.debug("updating showARView to \(showARView)")
            showARView = newShowARView
        }
    }

    @State var showARView: Bool = false {
        didSet {
            logger.debug("updating webView background due to new arView setup...")
            webView.isOpaque = !showARView
            webView.underPageBackgroundColor = showARView ? .clear : .white
        }
    }
    #endif

    var body: some View {
        #if os(iOS)
        if !isPortrait, !showARView {
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
                    if showARView {
                        ARViewContainer()
                            .edgesIgnoringSafeArea(.all)
                            .ignoresSafeArea(.all)
                    }
                    #endif
                    BrowserWebView(viewModel: browserViewModel)
                        .modify {
                            if let title = browserViewModel.title {
                                $0.navigationTitle(title)
                            }
                        }
                        .modify {
                            #if os(iOS)
                            if showARView {
                                $0
                                    .ignoresSafeArea(.all)
                                    .overlay(alignment: .topTrailing) {
                                        Button(action: {
                                            nativeWebKit.pauseARSession(dispatchToWebpages: true)
                                        }, label: {
                                            Image(systemName: "xmark.circle.fill")
                                                .imageScale(.large)
                                        })
                                        .padding(.trailing)
                                    }
                            }
                            #endif
                        }
                        .alert(panel?.title ?? "", isPresented: $browserViewModel.showPanel) {
                            alertActionsView
                        } message: {
                            alertMessageView
                        }
                }
                .modify {
                    #if os(iOS)
                    $0.onReceive(nativeWebKit.$isARSessionRunning) {
                        isARSessionRunning = $0
                    }
                    .onReceive(nativeWebKit.arCameraModeSubject) {
                        arCameraMode = $0
                    }
                    .onReceive(nativeWebKit.$showARCamera) {
                        showARCamera = $0
                    }
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
        .background(browserViewModel.themeColor)
        .background(.white)
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
        if isPortrait, !showARView {
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
