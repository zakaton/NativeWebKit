//
//  BrowserViewModel+UIScrollViewDelegate.swift
//  (iOS) NativeWebKit
//
//  Created by Zack Qattan on 12/23/23.
//

import UIKit
import WebKit

extension BrowserViewModel: UIScrollViewDelegate {
    func setUIScrollViewDelegate(_ webView: WKWebView) {
        webView.scrollView.delegate = self
        webView.scrollView.keyboardDismissMode = .interactiveWithAccessory
        webView.scrollView.bounces = true

        webView.scrollView.allowsKeyboardScrolling = true

        webView.scrollView.refreshControl = UIRefreshControl()
        webView.scrollView.refreshControl?.addTarget(self, action:
            #selector(handleRefreshControl),
            for: .valueChanged)
    }

    @objc func handleRefreshControl() {
        reload()

        DispatchQueue.main.async {
            self.webView.scrollView.refreshControl?.endRefreshing()
        }
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        dragVelocity = scrollView.panGestureRecognizer.velocity(in: scrollView.superview)
    }

    var isDragging: Bool { webView.scrollView.isDragging }
    var isDraggingUp: Bool { dragVelocity.y < 0 }
}
