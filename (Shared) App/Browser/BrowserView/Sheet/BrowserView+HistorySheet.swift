//
//  BrowserView+HistorySheet.swift
//  NativeWebKit
//
//  Created by Zack Qattan on 12/27/23.
//

import SwiftUI

extension BrowserView {
    @ViewBuilder
    var historySheet: some View {
        ForEach(browserViewModel.webView.backForwardList.backList, id: \.self) { item in
            let text = item.title != nil && !item.title!.isEmpty ? item.title : item.url.absoluteString
            if let text {
                Button(action: {
                    browserViewModel.webView.go(to: item)
                    sheet = nil
                }, label: {
                    Text(text)
                }).buttonStyle(.plain)
            }
        }
        Spacer()
    }
}
