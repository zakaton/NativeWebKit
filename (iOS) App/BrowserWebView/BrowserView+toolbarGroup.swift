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
        }
        .imageScale(.large)
    }

    @ViewBuilder
    var toolbarItems: some View {
        VStack(spacing: 8) {
            if !isFindInteractionVisible {
                searchToolbarItems
                if showNavigationBar {
                    navigationToolbarItems
                        .transition(.push(from: .top))
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
        .onReceive(keyboardPublisher) { _ in
            // logger.debug("keyboardPublisher \(value, privacy: .public)")
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
