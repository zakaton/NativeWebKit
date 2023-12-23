//
//  BrowserView+toolbarItems.swift
//  NativeWebKit
//
//  Created by Zack Qattan on 12/23/23.
//

import SwiftUI

extension BrowserView {
    @ViewBuilder
    var goBackButton: some View {
        Button(action: {
            browserViewModel.goBack()
        }) {
            Image(systemName: "chevron.backward")
        }
        .disabled(!browserViewModel.canGoBack)
    }

    @ViewBuilder
    var goForwardButton: some View {
        Button(action: {
            browserViewModel.goForward()
        }) {
            Image(systemName: "chevron.forward")
        }
        .disabled(!browserViewModel.canGoForward)
        .padding(.trailing, 5)
    }

    @ViewBuilder
    var searchImage: some View {
        Button {
            isUrlFocused = true
        } label: {
            Image(systemName: "magnifyingglass")
        }
    }

    @ViewBuilder
    var refreshButton: some View {
        Button(action: {
            browserViewModel.reload()
        }) {
            Image(systemName: "arrow.clockwise")
        }
    }

    @ViewBuilder
    var searchField: some View {
        TextField("URL", text: $browserViewModel.urlString, onCommit: {
            browserViewModel.loadURLString()
        })
        .autocorrectionDisabled(true)
        .submitLabel(.go)
        .focused($isUrlFocused)
        .textFieldStyle(.plain)
        .modify {
            #if !os(macOS)
            $0.keyboardType(.URL)
            #endif
        }
    }
}
