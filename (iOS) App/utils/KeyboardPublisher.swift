//
//  KeyboardPublisher.swift
//  NativeWebKit
//
//  Created by Zack Qattan on 12/25/23.
//

// https://stackoverflow.com/questions/65784294/how-to-detect-if-keyboard-is-present-in-swiftui

import Combine
import SwiftUI

extension View {
    var keyboardPublisher: AnyPublisher<Bool, Never> {
        Publishers
            .Merge(
                NotificationCenter
                    .default
                    .publisher(for: UIResponder.keyboardWillHideNotification)
                    .map { _ in false },
                NotificationCenter
                    .default
                    .publisher(for: UIResponder.keyboardWillShowNotification)
                    .map { _ in true })
            .debounce(for: .seconds(0.1), scheduler: RunLoop.main)
            .eraseToAnyPublisher()
    }
}
