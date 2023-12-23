//
//  BrowserView.swift
//  NativeWebKit
//
//  Created by Zack Qattan on 12/22/23.
//

// https://medium.com/@yeeedward/messaging-between-wkwebview-and-native-application-in-swiftui-e985f0bfacf

import SwiftUI
import WebKit

struct BrowserView: View {
    @StateObject var browserViewModel = BrowserViewModel()
    @FocusState var isUrlFocused: Bool

    var body: some View {
        VStack {
            if let url = URL(string: browserViewModel.urlString) {
                BrowserWebView(url: url,
                               viewModel: browserViewModel)
            } else {
                Text("Please, enter a url.")
            }
        }
        .modify {
            #if os(macOS)
            $0.toolbar {
                ToolbarItemGroup(placement: .navigation) {
                    toolbarItems
                }
            }
            #endif
        }

        #if !os(macOS)
        HStack {
            toolbarItems
        }
        .padding(.horizontal)
        .padding(.top, 1.0)
        #endif
    }
}

#Preview("") {
    BrowserView()
        .modify {
            #if os(macOS)
            $0.frame(maxWidth: 300)
            #endif
        }
}
