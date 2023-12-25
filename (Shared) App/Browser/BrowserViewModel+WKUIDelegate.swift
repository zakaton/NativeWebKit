//
//  BrowserViewModel+WKUIDelegate.swift
//  NativeWebKit
//
//  Created by Zack Qattan on 12/25/23.
//
import WebKit

extension BrowserViewModel: WKUIDelegate {
    func setWebViewUIDelegate() {
        webView.uiDelegate = self
    }
}
