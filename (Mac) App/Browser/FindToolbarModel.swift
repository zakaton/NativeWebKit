//
//  IsFindToolbarVisible.swift
//  (Mac) NativeWebKit
//
//  Created by Zack Qattan on 12/26/23.
//

import Foundation
import OSLog
import SwiftUI
import UkatonMacros
import WebKit

@StaticLogger()
class FindToolbarModel: ObservableObject {
    static let shared = FindToolbarModel()

    @Published var isVisible: Bool = true
    @Published var matchFound: Bool? = nil
    let configuration: WKFindConfiguration = .init()

    init() {
        configuration.wraps = true
    }

    func find(_ string: String, in webView: WKWebView) {
        webView.find(string, configuration: configuration, completionHandler: { findResult in
            self.matchFound = findResult.matchFound
        })
    }
}
