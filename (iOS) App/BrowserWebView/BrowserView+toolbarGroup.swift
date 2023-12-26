//
//  BrowserView+toolbarItems.swift
//  (Mac) NativeWebKit
//
//  Created by Zack Qattan on 12/23/23.
//

import SwiftUI

extension BrowserView {
    @ViewBuilder
    var findButton: some View {
        Button(action: {
            if let findInteraction = browserViewModel.webView.findInteraction {
                findInteraction.presentFindNavigator(showingReplace: false)
                withAnimation {
                    isFindInteractionVisible = true
                }
            }
        }) {
            Image(systemName: "doc.text.magnifyingglass")
                .imageScale(.large)
        }
    }

    @ViewBuilder
    var searchToolbarItems: some View {
        HStack {
            if !isUrlFocused {
                searchImage
            }
            searchField
            if isUrlFocused {
                clearSearchFieldButton
            }
            else {
                refreshButton
            }
        }
        .padding(isUrlFocused ? 10 : 5)
        .overlay(
            RoundedRectangle(cornerRadius: isUrlFocused ? 10 : 8)
                .stroke(Color.gray, lineWidth: 1)
        )
        .padding(.bottom, isUrlFocused ? 10 : 5)
    }

    @ViewBuilder
    var navigationToolbarItems: some View {
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
    }

    @ViewBuilder
    var bottomToolbarItems: some View {
        VStack(spacing: 8) {
            if !isFindInteractionVisible {
                searchToolbarItems
                if showNavigationBar {
                    navigationToolbarItems
                        .transition(.push(from: .top))
                }
            }
        }
    }

    @ViewBuilder
    var topToolbarItems: some View {
        HStack {
            searchToolbarItems
            navigationToolbarItems
        }
    }

    @ViewBuilder
    var toolbarItems: some View {
        Group {
            if !isKeyboardVisible || isUrlFocused {
                if isPortrait {
                    VStack(spacing: 8) {
                        if !isFindInteractionVisible {
                            searchToolbarItems
                            if showNavigationBar {
                                navigationToolbarItems
                                    .transition(.push(from: .top))
                            }
                        }
                    }
                }
                else {
                    HStack(spacing: 6) {
                        Spacer()
                        goBackButton
                        Spacer()
                        goForwardButton
                        Spacer()
                        historyButton
                        Spacer()
                        searchToolbarItems
                        Spacer()
                        shareButton
                        Spacer()
                    }
                }
            }
        }
        .onChange(of: isUrlFocused) { _, _ in
            if isUrlFocused {
                withAnimation {
                    showNavigationBar = false
                }
            }
            else {
                withAnimation {
                    showNavigationBar = !browserViewModel.isDraggingUp
                }
            }
        }
        .onChange(of: browserViewModel.dragVelocity) { _, _ in
            if !isUrlFocused {
                withAnimation {
                    showNavigationBar = !browserViewModel.isDraggingUp
                }
            }
        }
        .modify {
            if browserViewModel.webView != nil, let findInteraction = browserViewModel.webView.findInteraction {
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

            if browserViewModel.webView != nil, let findInteraction = browserViewModel.webView.findInteraction {
                withAnimation {
                    isFindInteractionVisible = findInteraction.isFindNavigatorVisible
                }
            }
        }
    }
}

#Preview("") {
    BrowserView()
}
