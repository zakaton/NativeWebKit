//
//  NKMessageTypeProtocol.swift
//  NativeWebKit
//
//  Created by Zack Qattan on 12/30/23.
//

import Foundation

protocol NKMessageTypeProtocol: Identifiable, CaseIterable, RawRepresentable where RawValue == String {
    static var prefix: String { get }
    var id: String { get }
    var name: String { get }
}

extension NKMessageTypeProtocol {
    var id: String { rawValue }
    var name: String { "\(Self.prefix)-\(id)" }

    init?(rawValue: RawValue) {
        guard let messageType = Self.allCases.first(where: { $0.name == rawValue }) else {
            return nil
        }
        self = messageType
    }
}
