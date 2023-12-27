//
//  BrowserView+toolbars.swift
//  (iOS) NativeWebKit
//
//  Created by Zack Qattan on 12/26/23.
//

import SwiftUI

extension BrowserView {
    @ViewBuilder
    var topToolbar: some View {
        HStack(alignment: .center, spacing: 6) {
            Spacer()
            goBackButton
            Spacer()
            goForwardButton
            Spacer()
            historyButton
            Spacer()
            searchBar
            Spacer()
            shareButton
            Spacer()
        }
        .padding(.top, 6)
        .padding(.bottom, 2)
    }

    @ViewBuilder
    var bottomToolbar: some View {
        VStack(spacing: 8) {
            if !isFindInteractionVisible {
                searchBar
                if showNavigationBar {
                    HStack(alignment: .center) {
                        Spacer()
                        goBackButton
                        Spacer()
                        goForwardButton
                        Spacer()
                        shareButton
                        Spacer()
                        findButton
                        Spacer()
                        historyButton
                        Spacer()
                    }
                    .imageScale(.large)
                    .transition(.asymmetric(insertion: .push(from: .bottom), removal: .push(from: .top)))
                }
            }
        }
        .padding(.bottom, expandSearchBar ? 4 : 0)
    }

    @ViewBuilder
    var toolbarItems: some View {
        Group {
            if !isKeyboardVisible || isUrlFocused {
                if isPortrait {
                    bottomToolbar
                }
                else {
                    topToolbar
                }
            }
        }
        .onChange(of: isUrlFocused) { _, _ in
            withAnimation {
                expandSearchBar = isUrlFocused
            }

            if isUrlFocused {
                withAnimation {
                    showNavigationBar = false
                }
            }
            else {
                withAnimation {
                    showNavigationBar = browserViewModel.isDraggingDown
                }
            }
        }
        .onChange(of: browserViewModel.dragVelocity) { _, _ in
            if !isUrlFocused {
                withAnimation {
                    showNavigationBar = browserViewModel.isDraggingDown
                }
            }
        }
        .modify {
            if let findInteraction = browserViewModel.webView.findInteraction {
                $0.onReceive(findInteraction.activeFindSession.publisher, perform: { _ in
                    //  logger.debug("findInteraction change")
                    withAnimation {
                        isFindInteractionVisible = findInteraction.isFindNavigatorVisible
                    }
                })
            }
        }
        .onReceive(keyboardPublisher) { newIsKeyboardVisible in
            // logger.debug("keyboardPublisher \(newIsKeyboardVisible, privacy: .public)")
            isKeyboardVisible = newIsKeyboardVisible

            if let findInteraction = browserViewModel.webView.findInteraction {
                withAnimation {
                    isFindInteractionVisible = findInteraction.isFindNavigatorVisible
                }
            }
        }
        .modify {
            if isPortrait {
                $0.onTapGesture {
                    if !showNavigationBar, !isKeyboardVisible {
                        withAnimation {
                            showNavigationBar = true
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, isKeyboardVisible ? 0 : 1.0)
                .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .onChanged { value in
                        // logger.debug("value \(value.translation.debugDescription)")
                        if value.translation.height > 0 {
                            if isUrlFocused {
                                withAnimation {
                                    isUrlFocused = false
                                }
                            }
                        }
                    })
            }
        }
    }
}

#Preview("") {
    BrowserView()
}
