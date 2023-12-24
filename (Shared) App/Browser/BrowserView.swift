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
        GeometryReader { geometry in
            VStack {
                BrowserWebView(viewModel: browserViewModel)
                    // .ignoresSafeArea(.all)
                    .modify {
                        if let title = browserViewModel.title {
                            $0.navigationTitle(title)
                        }
                    }
            }
            .modify {
                #if os(macOS)
                $0.toolbar {
                    ToolbarItemGroup(placement: .navigation) {
                        toolbarItems(geometry: geometry)
                    }
                }
                #endif
            }
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
