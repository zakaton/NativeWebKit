//
//  BrowserView+alert.swift
//  NativeWebKit
//
//  Created by Zack Qattan on 12/28/23.
//

// https://medium.com/@yeeedward/messaging-between-wkwebview-and-native-application-in-swiftui-e985f0bfacf

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
            Button("Cancel", role: .cancel) {
                completionHandler(nil)
            }
            Button("Ok") {
                completionHandler(browserViewModel.panel!.promptInput)
            }
        case .confirm(completionHandler: let completionHandler):
            Button("Cancel", role: .cancel) {
                completionHandler(false)
            }
            Button("Ok") {
                completionHandler(true)
            }
        case .notTrusted(completionHandler: let completionHandler, serverTrust: let serverTrust): Button("Go back", role: .cancel) {
                DispatchQueue.global(qos: .background).async {
                    logger.debug("cancelAuthenticationChallenge")
                    completionHandler(.cancelAuthenticationChallenge, nil)
                }
            }
            Button("Trust anyway") {
                DispatchQueue.global(qos: .background).async {
                    let credential = URLCredential(trust: serverTrust)
                    completionHandler(.useCredential, credential)
                }
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
