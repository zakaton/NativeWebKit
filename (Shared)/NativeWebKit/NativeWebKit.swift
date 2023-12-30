//
//  NativeWebKit.swift
//  NativeWebKit
//
//  Created by Zack Qattan on 12/29/23.
//

import Foundation
import OSLog
import UkatonMacros

typealias NKMessage = [String: Any]
typealias NKResponse = [String: Any]

@StaticLogger
@Singleton
class NativeWebKit {
    @discardableResult
    func handleMessage(message: NKMessage) -> NKResponse? {
        guard let messageType = message["type"] as? String else {
            logger.error("no message type defined")
            return nil
        }

        var response = NKResponse()

        switch messageType {
        default:
            logger.warning("uncaught exception for message type \(messageType)")
        }

        // TODO: - FILL
        return response
    }
}
