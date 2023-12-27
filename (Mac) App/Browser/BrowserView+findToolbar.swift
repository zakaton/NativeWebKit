//
//  FindToolbarView.swift
//  (Mac) NativeWebKit
//
//  Created by Zack Qattan on 12/26/23.
//

import SwiftUI

extension BrowserView {
    @ViewBuilder
    var findToolbar: some View {
        HStack(alignment: .center) {
            Spacer()
            HStack(alignment: .center, spacing: 0) {
                Button {
                    // TODO: - FILL
                } label: {
                    Image(systemName: "magnifyingglass")
                        .imageScale(.small)
                }
                .buttonStyle(.accessoryBar)
                TextField("Search", text: $findString)
                    .textFieldStyle(.plain)
                if !findString.isEmpty {
                    Button {
                        // TODO: - FILL
                    } label: {
                        Image(systemName: "xmark.circle")
                    }
                    .buttonStyle(.accessoryBar)
                }
            }
            .frame(maxWidth: 200)
            // .padding(.horizontal, 0)
            .padding(.vertical, 2)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.gray, lineWidth: 1)
            )

            HStack(alignment: .center, spacing: 0) {
                Button {
                    // TODO: - Previous
                } label: {
                    Image(systemName: "chevron.left")
                }
                .buttonStyle(.accessoryBar)
                .padding(.top, 1)
                .padding(.horizontal, 2)
                .overlay {
                    UnevenRoundedRectangle(cornerRadii: .init(
                        topLeading: 5,
                        bottomLeading: 5,
                        bottomTrailing: 0,
                        topTrailing: 0
                    ),
                    style: .continuous)
                        .stroke(Color.gray, lineWidth: 1)
                }

                Button {
                    // TODO: - Next
                } label: {
                    Image(systemName: "chevron.right")
                }
                .buttonStyle(.accessoryBar)
                .padding(.top, 1)
                .padding(.horizontal, 2)
                .overlay {
                    UnevenRoundedRectangle(cornerRadii: .init(
                        topLeading: 0,
                        bottomLeading: 0,
                        bottomTrailing: 5,
                        topTrailing: 5
                    ),
                    style: .continuous)
                        .stroke(Color.gray, lineWidth: 1)
                }
            }

            Button(role: .cancel) {
                withAnimation {
                    findToolbarModel.isVisible = false
                }
            } label: {
                Text("Done")
            }
            .buttonStyle(.accessoryBarAction)
        }
        .padding(.top, 5)
        .padding(.trailing, 5)
        .padding(.bottom, 0)
    }
}

#Preview("") {
    BrowserView()
        .frame(maxWidth: 300)
}
