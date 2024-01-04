//
//  NativeWebKit+AudioSession.swift
//  NativeWebKit
//
//  Created by Zack Qattan on 1/2/24.
//

import AVFAudio

extension NativeWebKit {
    func handleAudioSessionMessage(_ message: NKMessage, messageType: NKAudioSessionMessageType) -> NKResponse? {
        logger.debug("audioSessionMessageType \(messageType.name, privacy: .public)")

        logger.debug("audioSession category \(self.audioSession.category.rawValue.debugDescription, privacy: .public)")
        logger.debug("audioSession mode \(self.audioSession.mode.rawValue.debugDescription, privacy: .public)")

        do {
            try audioSession.setCategory(.playAndRecord, mode: .default, options: .mixWithOthers)
        } catch {
            logger.debug("AVAudioSession init error: \(error, privacy: .public)")
        }

        var response: NKResponse?
        switch messageType {
        case .blank:
            break
        }
        return response
    }
}
