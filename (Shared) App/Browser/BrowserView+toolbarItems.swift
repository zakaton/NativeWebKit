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
                .imageScale(imageScale)
        }
    }

    var imageScale: Image.Scale {
        #if os(macOS)
        .small
        #else
        .medium
        #endif
    }

    @ViewBuilder
    var refreshButton: some View {
        Button(action: {
            browserViewModel.reload()
        }) {
            Image(systemName: "arrow.clockwise")
                .imageScale(imageScale)
        }
    }

    @ViewBuilder
    var shareButton: some View {
        ShareLink(item: .init(browserViewModel.urlString)) {
            Image(systemName: "square.and.arrow.up")
                .imageScale(.medium)
        }
    }

    @ViewBuilder
    var clearSearchFieldButton: some View {
        Button(action: {
            browserViewModel.urlString = ""
        }) {
            Image(systemName: "xmark.circle")
                .imageScale(imageScale)
        }
    }

    @ViewBuilder
    var searchField: some View {
        TextField("Search or enter website name", text: $browserViewModel.urlString)
            .onSubmit {
                browserViewModel.loadURLString()
            }
            .textFieldStyle(.plain)
            .focused($isUrlFocused)
            .autocorrectionDisabled(true)
            .modify {
                #if !os(macOS)
                $0
                    .keyboardType(.webSearch)
                    .onChange(of: isUrlFocused) { _, _ in
                        if isUrlFocused {
                            DispatchQueue.main.async {
                                UIApplication.shared.sendAction(#selector(UIResponder.selectAll(_:)), to: nil, from: nil, for: nil)
                            }
                        }
                        else {
                            if let urlString = browserViewModel.webView.url?.absoluteString {
                                browserViewModel.urlString = urlString
                            }
                        }
                    }
                    .textInputAutocapitalization(.never)
                    .submitLabel(.go)
                    .textContentType(.URL)
                    .scrollDismissesKeyboard(.interactively)
                #endif
            }
    }
}
