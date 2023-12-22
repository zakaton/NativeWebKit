//
//  BrowserView.swift
//  NativeWebKit
//
//  Created by Zack Qattan on 12/22/23.
//

// https://medium.com/@yeeedward/messaging-between-wkwebview-and-native-application-in-swiftui-e985f0bfacf

import SwiftUI
import WebKit

struct BrowserView: View {
    @StateObject var browserViewModel = BrowserViewModel()

    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    browserViewModel.goBack()
                }) {
                    Image(systemName: "chevron.backward")
                }
                .disabled(!browserViewModel.canGoBack)

                Button(action: {
                    browserViewModel.goForward()
                }) {
                    Image(systemName: "chevron.forward")
                }
                .disabled(!browserViewModel.canGoForward)

                .padding(.trailing, 5)

                TextField("URL", text: $browserViewModel.urlString, onCommit: {
                    browserViewModel.loadURLString()
                })
                .textFieldStyle(RoundedBorderTextFieldStyle())

                Button(action: {
                    browserViewModel.reload()
                }) {
                    Image(systemName: "arrow.clockwise")
                }
            }
            .padding(.horizontal)

            if let url = URL(string: browserViewModel.urlString) {
                BrowserWebView(url: url,
                               viewModel: browserViewModel)
                    .edgesIgnoringSafeArea(.all)
            } else {
                Text("Please, enter a url.")
            }
        }
    }
}

#Preview {
    BrowserView()
        .frame(maxWidth: 400)
}
