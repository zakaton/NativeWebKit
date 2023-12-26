//
//  IsFindToolbarVisible.swift
//  (Mac) NativeWebKit
//
//  Created by Zack Qattan on 12/26/23.
//

import Foundation
import SwiftUI
import UkatonMacros

@Singleton()
class FindToolbar: ObservableObject {
    @Published var isVisible: Bool = false
}
