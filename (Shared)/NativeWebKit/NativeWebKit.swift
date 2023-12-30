//
//  NativeWebKit.swift
//  NativeWebKit
//
//  Created by Zack Qattan on 12/29/23.
//

import CoreMotion
import Foundation
import OSLog
import UkatonMacros

typealias NKMessage = [String: Any]
typealias NKResponse = [String: Any]

@StaticLogger
@Singleton
class NativeWebKit: NSObject, HasNKContext {
    // MARK: - CMHeadphoneMotionManager

    #if !os(visionOS)
    lazy var headphoneMotionManager: CMHeadphoneMotionManager = {
        logger.debug("lazy loading headphoneMotionManager")
        let headphoneMotionManager: CMHeadphoneMotionManager = .init()
        headphoneMotionManager.delegate = self
        return headphoneMotionManager
    }()
    #endif

    // MARK: - Message Handling

    @discardableResult
    func handleMessage(_ message: Any) -> Any? {
        if let messages = message as? [NKMessage] {
            return messages.compactMap { handleSingleMessage($0) }
        }
        else if let singleMessage = message as? NKMessage {
            return handleSingleMessage(singleMessage)
        }
        else {
            logger.error("invalid message format")
            return nil
        }
    }

    private func handleSingleMessage(_ message: NKMessage) -> Any? {
        guard let messageType = message["type"] as? String else {
            logger.error("no message type defined")
            return nil
        }
        logger.debug("message type \(messageType)")

        var response: NKResponse?

        if let headphoneMotionMessageType: NKHeadphoneMotionMessageType = .init(rawValue: messageType) {
            response = handleHeadphoneMotionMessage(message, messageType: headphoneMotionMessageType)
        }
        else {
            logger.warning("uncaught exception for message type \(messageType)")
        }

        return response
    }
}
