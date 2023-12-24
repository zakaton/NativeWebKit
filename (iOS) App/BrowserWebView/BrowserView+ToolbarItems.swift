//
//  BrowserView+toolbarItems.swift
//  (Mac) NativeWebKit
//
//  Created by Zack Qattan on 12/23/23.
//

import SwiftUI

extension BrowserView {
    @ViewBuilder
    var searchToolbarItems: some View {
        HStack {
            searchImage
            searchField
            if isUrlFocused {
                clearSearchFieldButton
            }
            else {
                refreshButton
            }
        }
        .padding(5)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray, lineWidth: 1)
        )
    }

    @ViewBuilder
    var navigationToolbarItems: some View {
        HStack {
            Spacer()
            goBackButton
            Spacer()
            goForwardButton
            Spacer()
        }
        .imageScale(.large)
    }

    @ViewBuilder
    var toolbarItems: some View {
        VStack(spacing: 12) {
            searchToolbarItems
            if !isUrlFocused {
                navigationToolbarItems
            }
        }
    }
}

#Preview("") {
    BrowserView()
}
