//
//  BrowserView+alert.swift
//  NativeWebKit
//
//  Created by Zack Qattan on 12/28/23.
//

import SwiftUI

extension BrowserView {
    @ViewBuilder
    var alertActionsView: some View {
        switch panel?.type {
        case .alert(let completionHandler):
            Button("Close") {
                completionHandler()
            }
        case .prompt(completionHandler: let completionHandler, let defaultText):
            var promptInputBinding: Binding<String> {
                Binding {
                    browserViewModel.panel?.promptInput ?? defaultText ?? "nil input"
                } set: {
                    browserViewModel.panel?.promptInput = $0
                }
            }
            TextField(defaultText ?? "", text: promptInputBinding)
            Button("Ok") {
                completionHandler(browserViewModel.panel!.promptInput)
            }
            Button("Cancel") {
                completionHandler(nil)
            }
        case .confirm(completionHandler: let completionHandler):
            Button("Ok") {
                completionHandler(true)
            }
            Button("Cancel") {
                completionHandler(false)
            }
        case .none:
            Button("Close") {}
        }
    }

    @ViewBuilder
    var alertMessageView: some View {
        Text(panel?.message ?? "nil")
    }
}
