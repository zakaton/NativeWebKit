//
//  BrowserView+navigation_iOS.swift
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
    var searchBar: some View {
        HStack(alignment: .center) {
            if !expandSearchBar {
                searchImage
            }
            searchField
            if expandSearchBar {
                if !browserViewModel.urlString.isEmpty {
                    clearSearchFieldButton
                }
            }
            else {
                refreshButton
            }
        }
        .padding(.horizontal, 7)
        .padding(.vertical, expandSearchBar ? 10 : 5)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray, lineWidth: expandSearchBar ? 1.5 : 1)
        )
    }
}

#Preview("") {
    BrowserView()
}
