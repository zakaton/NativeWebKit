//
//  PanelType.swift
//  NativeWebKit
//
//  Created by Zack Qattan on 12/27/23.
//

import Foundation
import UkatonMacros

@EnumName
enum PanelType: Identifiable {
    case alert(completionHandler: () -> Void)
    case prompt(completionHandler: (String?) -> Void, defaultText: String?)
    case confirm(completionHandler: (Bool) -> Void)
    case notTrusted(completionHandler: (URLSession.AuthChallengeDisposition, URLCredential?) -> Void, serverTrust: SecTrust)

    var id: String { name }
}
