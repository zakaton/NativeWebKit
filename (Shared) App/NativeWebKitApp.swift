//
//  NativeWebKitApp.swift
//  (Mac) NativeWebKit
//
//  Created by Zack Qattan on 12/20/23.
//

import SwiftUI

@main
struct NativeWebKitApp: App {
    #if os(macOS)
    @StateObject var findToolbar: FindToolbar = .shared
    #endif

    var body: some Scene {
        #if os(macOS)
        WindowGroup {
            ContentView()
        }
        .windowToolbarStyle(.unified(showsTitle: false))
        .environmentObject(findToolbar)
        .commands {
            CommandMenu("History") {
                // TODO: - reference some global webViewModel's history
            }

            CommandGroup(after: .textEditing) {
                Button("Find") {
                    findToolbar.isVisible.toggle()
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
