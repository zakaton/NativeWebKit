//
//  BrowserViewModel+UIScrollViewDelegate.swift
//  (iOS) NativeWebKit
//
//  Created by Zack Qattan on 12/23/23.
//

import UIKit

extension BrowserViewModel: UIScrollViewDelegate {
    func setUIScrollViewDelegate() {
        webView.scrollView.delegate = self
        webView.scrollView.keyboardDismissMode = .interactiveWithAccessory
    }
}
