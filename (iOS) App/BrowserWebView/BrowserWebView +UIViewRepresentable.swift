//
//  BrowserWebView+UIViewRepresentable.swift
//  (iOS) NativeWebKit
//
//  Created by Zack Qattan on 12/22/23.
//

import SwiftUI
import WebKit

extension BrowserWebView: UIViewRepresentable {
    typealias UIViewType = WKWebView

    func makeUIView(context: Context) -> WKWebView {
        makeView()
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
