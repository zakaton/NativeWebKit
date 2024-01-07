//
//  NativeWebKit+Template.swift
//  NativeWebKit
//
//  Created by Zack Qattan on 1/3/24.
//

extension NativeWebKit {
    func handleTemplateMessage(_ message: NKMessage, messageType: NKTemplateMessageType) -> NKResponse? {
        logger.debug("templateMessageType \(messageType.id, privacy: .public)")

        let response: NKResponse? = nil
        switch messageType {
        case .test:
            break
        }
        return response
    }
}
