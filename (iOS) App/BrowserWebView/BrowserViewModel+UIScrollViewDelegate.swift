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
        webView.scrollView.bounces = true

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
}
