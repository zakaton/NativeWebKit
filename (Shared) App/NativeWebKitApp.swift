//
//  NativeWebKitApp.swift
//  (Mac) NativeWebKit
//
//  Created by Zack Qattan on 12/20/23.
//

import SwiftUI

@main
struct NativeWebKitApp: App {
    var body: some Scene {
        #if os(macOS)
        WindowGroup {
            ContentView()
        }
        .windowToolbarStyle(.unified(showsTitle: false))
        #else
        WindowGroup {
            ContentView()
        }
        #endif
    }
}
