//
//  ESWebView.swift
//  ECMASwift
//
//  Created by Taylor McIntyre on 2019-07-03.
//  Copyright © 2019 hiimtmac. All rights reserved.
//

import Foundation
import WebKit

private let kMessage = "ECMASwiftMessage"
private let kPrompt = "ECMASwiftPrompt"
private let kRequest = "ECMASwiftRequest"

public class ESWebView: WKWebView {
    
    public static let message = Notification.Name("ECMASwiftMessage")
    public static let prompt = Notification.Name("ECMASwiftPrompt")
    public static let request = Notification.Name("ECMASwiftRequest")
    public static let unknown = Notification.Name("ECMASwiftUnknown")
    public static let error = Notification.Name("ECMASwiftError")
    
    public var handleAlertPanel: (() -> Void)?
    public var handleConfirmPanel: (() -> Void)?
    public var handleTextInputPanel: (() -> Void)?
    
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

extension ESWebView: WKUIDelegate {
    public func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let ac = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: acceptText, style: .default) { _ in
            completionHandler()
        })
        
        present(ac, animated: true)
    }
    
    public func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let ac = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: cancelText, style: .default) { _ in
            completionHandler(false)
        })
        ac.addAction(UIAlertAction(title: acceptText, style: .default) { _ in
            completionHandler(true)
        })
        
        present(ac, animated: true)
    }
    
    public func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        let ac = UIAlertController(title: nil, message: prompt, preferredStyle: .alert)
        ac.addTextField { prompt in
            prompt.text = defaultText
        }
        ac.addAction(UIAlertAction(title: cancelText, style: .default) { _ in
            completionHandler(nil)
        })
        ac.addAction(UIAlertAction(title: acceptText, style: .default) { [ac] _ in
            completionHandler(ac.textFields?.first?.text)
        })
        
        present(ac, animated: true)
    }
}
