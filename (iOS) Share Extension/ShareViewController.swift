//
//  ShareViewController.swift
//  (iOS) Share Extension
//
//  Created by Zack Qattan on 12/24/23.
//

// https://medium.com/@damisipikuda/how-to-receive-a-shared-content-in-an-ios-application-4d5964229701

import CoreServices
import Foundation
import OSLog
import UIKit
import UkatonMacros
import UniformTypeIdentifiers

@StaticLogger
class ShareViewController: UIViewController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        handleIncomingData()
    }

    // Courtesy: https://stackoverflow.com/a/44499222/13363449 👇🏾
    // Function must be named exactly like this so a selector can be found by the compiler!
    // Anyway - it's another selector in another instance that would be "performed" instead.
    @objc func openURL(_ url: URL) -> Bool {
        var responder: UIResponder? = self
        while responder != nil {
            if let application = responder as? UIApplication {
                return application.perform(#selector(self.openURL(_:)), with: url) != nil
            }
            responder = responder?.next
        }
        return false
    }
}
