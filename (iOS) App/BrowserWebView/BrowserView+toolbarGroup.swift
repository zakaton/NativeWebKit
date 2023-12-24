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
            }
        }) {
            Image(systemName: "doc.text.magnifyingglass")
                .imageScale(imageScale)
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
        HStack {
            Spacer()
            goBackButton
            Spacer()
            goForwardButton
            Spacer()
//            findButton
//            Spacer()
        }
        .imageScale(.large)
    }

    @ViewBuilder
    var toolbarItems: some View {
        VStack(spacing: 12) {
            searchToolbarItems
            if showNavigationBar {
                navigationToolbarItems
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
            withAnimation {
                showNavigationBar = !browserViewModel.isDraggingUp
            }
        }
    }
}

#Preview("") {
    BrowserView()
}
