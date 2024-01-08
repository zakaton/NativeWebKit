//
//  NativeWebKit+AudioSession.swift
//  NativeWebKit
//
//  Created by Zack Qattan on 1/2/24.
//

import AVFAudio

extension NativeWebKit {
    func handleAudioSessionMessage(_ message: NKMessage, messageType: NKAudioSessionMessageType) -> NKResponse? {
        logger.debug("audioSessionMessageType \(messageType.id, privacy: .public)")

        logger.debug("audioSession category \(self.audioSession.category.rawValue.debugDescription, privacy: .public)")
        logger.debug("audioSession mode \(self.audioSession.mode.rawValue.debugDescription, privacy: .public)")
        
        /*
         The purpose of this module was to attempt to change the audioSession category/mode of the WKWebview.
         This is to attempt to fix the speakers turning from Stereo to Mono when the microphone is on, preventing spacial voice chat applications on the web.
         Unfortunately, the WKWebView's audio session is not accessible 🤷.
         I'll keep this here in case they give access in future iOS verions...
         */

        do {
            try audioSession.setCategory(.playAndRecord, mode: .default, options: .mixWithOthers)
        } catch {
            logger.debug("AVAudioSession init error: \(error, privacy: .public)")
        }

        let response: NKResponse? = nil
        switch messageType {
        case .blank:
            break
        }
        return response
    }
}
