//
//  BrowserView+toolbarItems.swift
//  (Mac) NativeWebKit
//
//  Created by Zack Qattan on 12/23/23.
//

import SwiftUI

extension BrowserView {
    @ViewBuilder
    var toolbarItems: some View {
        goBackButton
        goForwardButton

        HStack(spacing: 0) {
            searchImage
            searchField
            refreshButton
        }
        .padding(.horizontal, 2)
        .padding(.top, 2)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray, lineWidth: 1)
        )
    }
}

#Preview("") {
    BrowserView()
        .modify {
            #if os(macOS)
            $0.frame(maxWidth: 600)
            #endif
        }
}
