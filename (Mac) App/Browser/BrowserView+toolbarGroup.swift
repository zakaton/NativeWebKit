//
//  BrowserView+toolbarItems.swift
//  (Mac) NativeWebKit
//
//  Created by Zack Qattan on 12/23/23.
//

import SwiftUI

extension BrowserView {
    @ViewBuilder
    func toolbarItems(geometry: GeometryProxy) -> some View {
        goBackButton
        goForwardButton

        let width = max(geometry.size.width - 250, 100)

        HStack(alignment: .center, spacing: 0) {
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
        .frame(width: width)

        shareButton
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
