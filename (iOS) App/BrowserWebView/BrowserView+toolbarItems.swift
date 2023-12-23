//
//  BrowserView+toolbarItems.swift
//  (Mac) NativeWebKit
//
//  Created by Zack Qattan on 12/23/23.
//

import SwiftUI

extension BrowserView {
    var searchToolbarItems: some View {
        HStack {
            searchImage
            searchField
            refreshButton
        }
        .padding(5)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray, lineWidth: 1)
        )
    }

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
            navigationToolbarItems
        }
    }
}

#Preview("") {
    BrowserView()
}
