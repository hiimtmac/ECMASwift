// ESWebView.swift
// Copyright © 2022 hiimtmac

import Foundation

private let kMessage = "ECMASwiftMessage"
private let kPrompt = "ECMASwiftPrompt"
private let kRequest = "ECMASwiftRequest"

public class ESWebView: WKWebView {
    public static let message = Notification.Name("ECMASwiftMessage")
    public static let prompt = Notification.Name("ECMASwiftPrompt")
    public static let request = Notification.Name("ECMASwiftRequest")
    public static let unknown = Notification.Name("ECMASwiftUnknown")
    public static let error = Notification.Name("ECMASwiftError")

    public var handleAlertPanel: ((_ message: String, _ completionHandler: @escaping () -> Void) -> Void)?
    public var handleConfirmPanel: ((_ message: String, _ completionHandler: @escaping (Bool) -> Void) -> Void)?
    public var handleTextInputPanel: ((_ prompt: String, _ defaultText: String?, _ completionHandler: @escaping (String?) -> Void) -> Void)?

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
        uiDelegate = self
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        configuration.userContentController.removeScriptMessageHandler(forName: kMessage)
        configuration.userContentController.removeScriptMessageHandler(forName: kPrompt)
        configuration.userContentController.removeScriptMessageHandler(forName: kRequest)
    }
}

extension ESWebView: WKScriptMessageHandler {
    public func userContentController(_: WKUserContentController, didReceive message: WKScriptMessage) {
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
    public func webView(_: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame _: WKFrameInfo, completionHandler: @escaping () -> Void) {
        if let handleAlertPanel = handleAlertPanel {
            handleAlertPanel(message, completionHandler)
        } else {
            completionHandler()
        }
    }

    public func webView(_: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame _: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        if let handleConfirmPanel = handleConfirmPanel {
            handleConfirmPanel(message, completionHandler)
        } else {
            completionHandler(false)
        }
    }

    public func webView(_: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame _: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        if let handleTextInputPanel = handleTextInputPanel {
            handleTextInputPanel(prompt, defaultText, completionHandler)
        } else {
            completionHandler(nil)
        }
    }
}
