//
//  BrowserWebView+NSViewRepresentable.swift
//  (Mac) NativeWebKit
//
//  Created by Zack Qattan on 12/22/23.
//

import SwiftUI
import WebKit

extension BrowserWebView: NSViewRepresentable {
    typealias UIViewType = WKWebView

    func makeNSView(context: Context) -> WKWebView {
        makeView()
    }

    func updateNSView(_ uiView: WKWebView, context: Context) {}
}
