//
//  ContentView.swift
//  NativeWebKit
//
//  Created by Zack Qattan on 12/20/23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        BrowserView(browserViewModel: .activeModel!)
    }
}

#Preview {
    ContentView()
    #if os(macOS)
        .frame(maxWidth: 400)
    #endif
}
