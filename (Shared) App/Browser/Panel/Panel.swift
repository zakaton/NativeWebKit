//
//  Panel.swift
//  NativeWebKit
//
//  Created by Zack Qattan on 12/28/23.
//

import SwiftUI

// https://medium.com/@yeeedward/messaging-between-wkwebview-and-native-application-in-swiftui-e985f0bfacf

struct Panel {
    // MARK: - Properties for Javascript alert, confirm, and prompt dialog boxes

    var title: String { type.name.capitalized }
    let type: PanelType

    let message: String
    var promptInput: String = ""

    init(type: PanelType, message: String) {
        self.type = type
        self.message = message
        if case .prompt(_, let defaultText) = type, let defaultText {
            promptInput = defaultText
        }
    }
}
