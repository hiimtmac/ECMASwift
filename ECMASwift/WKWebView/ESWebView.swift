//
//  ESWebView.swift
//  ECMASwift
//
//  Created by Taylor McIntyre on 2019-07-03.
//  Copyright © 2019 hiimtmac. All rights reserved.
//

import Foundation
import WebKit

private let kMessage = "JSFormKitMessage"
private let kPrompt = "JSFormKitPrompt"
private let kRequest = "JSFormKitRequest"

public class ESWebView: WKWebView {
    
    public static let message = Notification.Name("JSFormKitMessage")
    public static let prompt = Notification.Name("JSFormKitPrompt")
    public static let request = Notification.Name("JSFormKitRequest")
    public static let unknown = Notification.Name("JSFormKitUnknown")
    public static let error = Notification.Name("JSFormKitError")
    
    public init(frame: CGRect, scripts: [WKUserScript] = []) {
        let preferences = WKPreferences()
        preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
        
        let userController = WKUserContentController()
        for script in scripts {
            userController.addUserScript(script)
        }
        
        let config = WKWebViewConfiguration()
        config.preferences = preferences
        config.userContentController = userController
        
        super.init(frame: frame, configuration: config)
        
        userController.add(self, name: kMessage)
        userController.add(self, name: kPrompt)
        userController.add(self, name: kRequest)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        configuration.userContentController.removeScriptMessageHandler(forName: kMessage)
        configuration.userContentController.removeScriptMessageHandler(forName: kPrompt)
        configuration.userContentController.removeScriptMessageHandler(forName: kRequest)
    }
}

extension ESWebView: WKScriptMessageHandler {
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        switch message.name {
        case kMessage:
            do {
                let encoded = try JSONSerialization.data(withJSONObject: message.body, options: [])
                let decoded = try JSONDecoder().decode(Message.self, from: encoded)
                NotificationCenter.default.post(name: ESWebView.message, object: nil, userInfo: ["message": decoded])
            } catch {
                NotificationCenter.default.post(name: ESWebView.error, object: nil, userInfo: ["attempting": "message", "error": error.localizedDescription])
            }
        case kPrompt:
            do {
                let encoded = try JSONSerialization.data(withJSONObject: message.body, options: [])
                let decoded = try JSONDecoder().decode(Prompt.self, from: encoded)
                NotificationCenter.default.post(name: ESWebView.prompt, object: nil, userInfo: ["prompt": decoded])
            } catch {
                NotificationCenter.default.post(name: ESWebView.error, object: nil, userInfo: ["attempting": "prompt", "error": error.localizedDescription])
            }
        case kRequest:
            do {
                let encoded = try JSONSerialization.data(withJSONObject: message.body, options: [])
                let decoded = try JSONDecoder().decode(Request.self, from: encoded)
                NotificationCenter.default.post(name: ESWebView.request, object: nil, userInfo: ["request": decoded])
            } catch {
                NotificationCenter.default.post(name: ESWebView.error, object: nil, userInfo: ["attempting": "request", "error": error.localizedDescription])
            }
        default:
            NotificationCenter.default.post(name: ESWebView.unknown, object: nil, userInfo: ["name": message.name, "body": message.body])
        }
    }
    
    public struct Message: Codable {
        public let message: String
    }
    
    public struct Prompt: Codable {
        public let name: String
        public let type: HandlerType
    }
    
    public struct Request: Codable {
        public let object: String
        public let predicate: String?
        public let toHandler: String
        public let type: HandlerType
    }
    
    public enum HandlerType: String, Codable {
        case variable
        case function
    }
}
