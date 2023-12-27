//
//  FindToolbarView.swift
//  (Mac) NativeWebKit
//
//  Created by Zack Qattan on 12/26/23.
//

import SwiftUI
import WebKit

extension BrowserView {
    func find(isBackwards: Bool = false) {
        if isBackwards {
            findToolbarModel.configuration.backwards = true
        }
        findToolbarModel.find(findString, in: browserViewModel.webView)
        findToolbarModel.configuration.backwards = false
    }

    @ViewBuilder
    var findToolbar: some View {
        HStack(alignment: .center) {
            Spacer()
            if !findString.isEmpty, let matchFound = findToolbarModel.matchFound, !matchFound {
                Text("Not found")
            }
            HStack(alignment: .center, spacing: 0) {
                Button {
                    // TODO: - set focus
                } label: {
                    Image(systemName: "magnifyingglass")
                        .imageScale(.small)
                }
                .buttonStyle(.accessoryBar)
                TextField("Search", text: $findString)
                    .focused($isFindFocused)
                    .textFieldStyle(.plain)
                    .onSubmit {
                        find()
                    }
                    .onChange(of: findString) {
                        find()
                    }
                if !findString.isEmpty {
                    Button {
                        findString = ""
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
                    find(isBackwards: true)
                } label: {
                    Image(systemName: "chevron.left")
                }
                .accessibilityLabel("find previous")
                .disabled(!(findToolbarModel.matchFound ?? false))
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
                    find()
                } label: {
                    Image(systemName: "chevron.right")
                }
                .accessibilityLabel("find next")
                .disabled(!(findToolbarModel.matchFound ?? false))
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
        .onAppear {
            withAnimation {
                isFindFocused = true
            }
        }
    }
}

#Preview("") {
    BrowserView()
        .frame(maxWidth: 300)
}
