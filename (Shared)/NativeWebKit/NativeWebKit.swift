//
//  NativeWebKit.swift
//  NativeWebKit
//
//  Created by Zack Qattan on 12/29/23.
//

#if os(iOS)
    import ARKit
#endif
import AVFAudio
import CoreMotion
import Foundation
import OSLog
import SceneKit
import UkatonMacros

typealias NKMessage = [String: Any]
typealias NKResponse = [String: Any]

@StaticLogger
@Singleton
class NativeWebKit: NSObject, HasNKContext {
    var observations: [NSKeyValueObservation] = []

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
        logger.debug("message type \(messageType, privacy: .public)")

        var response: NKResponse?

        if let templateMessageType: NKTemplateMessageType = .init(rawValue: messageType) {
            response = handleTemplateMessage(message, messageType: templateMessageType)
        }
        else if let headphoneMotionMessageType: NKHeadphoneMotionMessageType = .init(rawValue: messageType) {
            response = handleHeadphoneMotionMessage(message, messageType: headphoneMotionMessageType)
        }
        else if let audioSessionMessageType: NKAudioSessionMessageType = .init(rawValue: messageType) {
            #if os(iOS)
                response = handleAudioSessionMessage(message, messageType: audioSessionMessageType)
            #else
                logger.error("audioSession messages are not available on MacOS")
            #endif
        }
        else if let arSessionMessageType: NKARSessionMessageType = .init(rawValue: messageType) {
            #if os(iOS)
                response = handleARSessionMessage(message, messageType: arSessionMessageType)
            #else
                logger.error("arSession messages are not available on MacOS")
            #endif
        }
        else {
            logger.warning("uncaught exception for message type \(messageType, privacy: .public)")
        }

        if response != nil, response!["type"] == nil {
            response!["type"] = messageType
        }

        return response
    }

    #if IN_APP
        func dispatchMessageToWebpages(_ message: NKMessage) {
            logger.debug("sending message to webpages \(message.debugDescription)")
            guard let messageData = try? JSONSerialization.data(withJSONObject: message) else {
                logger.error("unable to convert mesage to json")
                return
            }
            guard let messageString = String(data: messageData, encoding: .utf8) else {
                logger.error("unable to stringify mesage json")
                return
            }
            logger.debug("sending message json to webpages \"\(messageString)\"")
            DispatchQueue.main.async {
                BrowserViewModel.models.forEach {
                    $0.webView.evaluateJavaScript("""
                        window.dispatchEvent(new CustomEvent("nativewebkit-receive", {detail: \(messageString)}))
                    """)
                }
            }
        }
    #endif

    // MARK: - CMHeadphoneMotionManager

    #if !os(visionOS)
        lazy var headphoneMotionManager: CMHeadphoneMotionManager = {
            logger.debug("lazy loading headphoneMotionManager...")
            let headphoneMotionManager: CMHeadphoneMotionManager = .init()
            setupHeadphoneMotionManager(headphoneMotionManager)
            return headphoneMotionManager
        }()
    #endif

    // MARK: - AVAudioSession

    #if os(iOS)
        lazy var audioSession: AVAudioSession = .sharedInstance()
    #endif

    // MARK: - ARSession

    #if os(iOS)
        lazy var sceneView: ARSCNView = {
            logger.debug("lazy loading sceneView...")
            let sceneView: ARSCNView = .init()
            setupSceneView(sceneView)
            return sceneView
        }()
    #endif
}
