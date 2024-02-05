//
//  NativeWebKitApp.swift
//  (Mac) NativeWebKit
//
//  Created by Zack Qattan on 12/20/23.
//

import SwiftUI

@main
struct NativeWebKitApp: App {
    #if !os(iOS)
    @ObservedObject var findToolbar: FindToolbarModel = .shared
    #endif

    var body: some Scene {
        #if os(macOS)
        WindowGroup {
            ContentView()
        }
        .windowToolbarStyle(.unified(showsTitle: false))
        .commands {
            // TODO: - figure out how to ge the title from WKWebView's backForwardList.backList[].title on iOS (currently blank)
//            CommandMenu("History") {
//                // TODO: - reference some global webViewModel's history
//            }

            CommandGroup(after: .textEditing) {
                Button("Find") {
                    withAnimation {
                        findToolbar.isVisible.toggle()
                    }
                }
                .keyboardShortcut("F")
            }
        }
        #else
        WindowGroup {
            ContentView()
        }
        #endif
    }
}
