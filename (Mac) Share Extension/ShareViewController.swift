//
//  ShareViewController.swift
//  (Mac) Share Extension)
//
//  Created by Zack Qattan on 12/24/23.
//

// https://medium.com/@damisipikuda/how-to-receive-a-shared-content-in-an-ios-application-4d5964229701

import AppKit
import CoreServices
import Foundation
import OSLog
import UkatonMacros
import UniformTypeIdentifiers

@StaticLogger
class ShareViewController: NSViewController {
    override func viewDidAppear() {
        super.viewDidAppear()
        handleIncomingData()
    }
}
