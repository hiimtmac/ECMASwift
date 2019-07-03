//
//  MessagingTests.swift
//  ECMASwiftTests
//
//  Created by Taylor McIntyre on 2019-07-03.
//  Copyright © 2019 hiimtmac. All rights reserved.
//

import XCTest
import PromiseKit
import WebKit
@testable import ECMASwift

class MessagingTests: ECMASwiftTestCase {

    var messageExp: XCTestExpectation!
    var triggerExp: XCTestExpectation!
    
    override func setUp() {
        super.setUp()
        
        messageExp = expectation(description: "message")
        triggerExp = expectation(description: "trigger")
    }
    
    struct Person: Codable, JavaScriptParameterEncodable {
        let name: String
        let age: Int
    }
    
    func testMessage() {
        let message = webView.waitForMessage().done {
            XCTAssertEqual($0.message, "hello!")
            self.messageExp.fulfill()
        }
        
        let payload = ESWebView.Message(message: "hello!")
        let trigger = webView.triggerMessage(handler: .message, message: payload).done {
            self.triggerExp.fulfill()
        }
        
        when(fulfilled: [message, trigger]).catch {
            XCTFail($0.localizedDescription)
            self.messageExp.fulfill()
        }
        
        wait(for: [messageExp, triggerExp], timeout: 5)
    }
    
    func testPrompt() {
        let message = webView.waitForPrompt().done {
            XCTAssertEqual($0.name, "json")
            XCTAssertEqual($0.type, .variable)
            self.messageExp.fulfill()
        }
        
        let payload = ESWebView.Prompt(name: "json", type: .variable)
        let trigger = webView.triggerMessage(handler: .prompt, message: payload).done {
            self.triggerExp.fulfill()
        }
        
        when(fulfilled: [message, trigger]).catch {
            XCTFail($0.localizedDescription)
            self.messageExp.fulfill()
        }
        
        wait(for: [messageExp, triggerExp], timeout: 5)
    }
    
    func testPromptVariable() {
        let prompt = webView.waitForPrompt().get {
            XCTAssertEqual($0.name, "json")
            XCTAssertEqual($0.type, .variable)
        }.then {
            self.webView.getVariable(named: $0.name, as: Person.self)
        }.done {
            XCTAssertEqual($0.age, 27)
            XCTAssertEqual($0.name, "tmac")
                self.messageExp.fulfill()
        }
        
        let payload = ESWebView.Prompt(name: "json", type: .variable)
        let trigger = webView.triggerMessage(handler: .prompt, message: payload).done {
            self.triggerExp.fulfill()
        }
        
        when(fulfilled: [prompt, trigger]).catch {
            XCTFail($0.localizedDescription)
            self.messageExp.fulfill()
        }
        
        wait(for: [messageExp, triggerExp], timeout: 5)
    }
    
    func testPromptFunction() {
        let prompt = webView.waitForPrompt().get {
            XCTAssertEqual($0.name, "jsonResponse")
            XCTAssertEqual($0.type, .function)
        }.then {
            self.webView.runReturning(named: $0.name, as: Person.self)
        }.done {
            XCTAssertEqual($0.age, 27)
            XCTAssertEqual($0.name, "tmac")
            self.messageExp.fulfill()
        }
        
        let payload = ESWebView.Prompt(name: "jsonResponse", type: .function)
        let trigger = webView.triggerMessage(handler: .prompt, message: payload).done {
            self.triggerExp.fulfill()
        }
        
        when(fulfilled: [prompt, trigger]).catch {
            XCTFail($0.localizedDescription)
            self.messageExp.fulfill()
        }
        
        wait(for: [messageExp, triggerExp], timeout: 5)
    }
    
    func testRequest() {
        let message = webView.waitForRequest().done {
            XCTAssertEqual($0.object, "Jobs")
            XCTAssertEqual($0.predicate, nil)
            self.messageExp.fulfill()
        }
        
        let payload = ESWebView.Request(object: "Jobs", predicate: nil, toHandler: "setJobs", type: .function)
        let trigger = webView.triggerMessage(handler: .request, message: payload).done {
            self.triggerExp.fulfill()
        }
        
        when(fulfilled: [message, trigger]).catch {
            XCTFail($0.localizedDescription)
            self.messageExp.fulfill()
        }
        
        wait(for: [messageExp, triggerExp], timeout: 5)
    }
    
    func testRequestWithReturn() {
        let people = [
            Person(name: "Taylor", age: 27),
            Person(name: "Connor", age: 24),
            Person(name: "Jordyn", age: 21)
        ]
        
        let message = webView.waitForRequest().get {
            XCTAssertEqual($0.object, "Person")
            XCTAssertEqual($0.predicate, nil)
            XCTAssertEqual($0.toHandler, "returnContents")
            XCTAssertEqual($0.type.rawValue, "function")
        }.then {
            self.webView.runReturning(named: $0.toHandler, args: [people], as: [Person].self)
        }.done {
            XCTAssertEqual($0.count, 3)
            self.messageExp.fulfill()
        }
        
        let payload = ESWebView.Request(object: "Person", predicate: nil, toHandler: "returnContents", type: .function)
        let trigger = webView.triggerMessage(handler: .request, message: payload).done {
            self.triggerExp.fulfill()
        }
        
        when(fulfilled: [message, trigger]).catch {
            XCTFail($0.localizedDescription)
            self.messageExp.fulfill()
        }
        
        wait(for: [messageExp, triggerExp], timeout: 5)
    }

}

extension ESWebView.Message: JavaScriptParameterEncodable {}
extension ESWebView.Prompt: JavaScriptParameterEncodable {}
extension ESWebView.Request: JavaScriptParameterEncodable {}

extension ESWebView {
    func waitForMessage() -> Promise<ESWebView.Message> {
        return NotificationMessageProxy().promise
    }
    
    func waitForRequest() -> Promise<ESWebView.Request> {
        return NotificationRequestProxy().promise
    }
    
    func waitForPrompt() -> Promise<ESWebView.Prompt> {
        return NotificationPromptProxy().promise
    }
    
    enum Handler: String {
        case message = "JSFormKitMessage"
        case prompt = "JSFormKitPrompt"
        case request = "JSFormKitRequest"
    }
    
    func triggerMessage(handler: Handler, message: JavaScriptParameterEncodable) -> Promise<Void> {
        return runVoid(named: "window.webkit.messageHandlers.\(handler.rawValue).postMessage", args: [message])
    }
}

enum ProxyError: Error, LocalizedError {
    case userInfo
    case error(String)
    case timeout
    
    var errorDescription: String? {
        switch self {
        case .userInfo: return "user info"
        case .error(let str): return "err -> \(str)"
        case .timeout: return "timeout"
        }
    }
}

class NotificationMessageProxy: NSObject {
    let (promise, seal) = Promise<ESWebView.Message>.pending()
    private var retainCycle: NotificationMessageProxy?
    
    override init() {
        super.init()
        retainCycle = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleError(_:)), name: ESWebView.error, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleMessage(_:)), name: ESWebView.message, object: nil)
        
        _ = promise.ensure {
            self.retainCycle = nil
        }
    }
    
    @objc func handleError(_ notification: Notification) {
        let error = notification.userInfo!["error"] as! String
        let attempting = notification.userInfo!["attempting"] as! String
        seal.reject(ProxyError.error("Attempting: \(attempting) -> Error: \(error)"))
    }
    
    @objc func handleMessage(_ notification: Notification) {
        if let message = notification.userInfo?["message"] as? ESWebView.Message {
            seal.fulfill(message)
        } else {
            seal.reject(ProxyError.userInfo)
        }
    }
}

class NotificationPromptProxy: NSObject {
    let (promise, seal) = Promise<ESWebView.Prompt>.pending()
    private var retainCycle: NotificationPromptProxy?
    
    override init() {
        super.init()
        retainCycle = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleError(_:)), name: ESWebView.error, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handlePrompt(_:)), name: ESWebView.prompt, object: nil)
        
        _ = promise.ensure {
            self.retainCycle = nil
        }
    }
    
    @objc func handleError(_ notification: Notification) {
        let error = notification.userInfo!["error"] as! String
        let attempting = notification.userInfo!["attempting"] as! String
        seal.reject(ProxyError.error("Attempting: \(attempting) -> Error: \(error)"))
    }
    
    @objc func handlePrompt(_ notification: Notification) {
        if let prompt = notification.userInfo?["prompt"] as? ESWebView.Prompt {
            seal.fulfill(prompt)
        } else {
            seal.reject(ProxyError.userInfo)
        }
    }
}

class NotificationRequestProxy: NSObject {
    let (promise, seal) = Promise<ESWebView.Request>.pending()
    private var retainCycle: NotificationRequestProxy?
    
    override init() {
        super.init()
        retainCycle = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleError(_:)), name: ESWebView.error, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleRequest(_:)), name: ESWebView.request, object: nil)
        
        _ = promise.ensure {
            self.retainCycle = nil
        }
    }
    
    @objc func handleError(_ notification: Notification) {
        let error = notification.userInfo!["error"] as! String
        let attempting = notification.userInfo!["attempting"] as! String
        seal.reject(ProxyError.error("Attempting: \(attempting) -> Error: \(error)"))
    }
    
    @objc func handleRequest(_ notification: Notification) {
        if let request = notification.userInfo?["request"] as? ESWebView.Request {
            seal.fulfill(request)
        } else {
            seal.reject(ProxyError.userInfo)
        }
    }
}
