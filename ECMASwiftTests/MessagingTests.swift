//
//  MessagingTests.swift
//  ECMASwiftTests
//
//  Created by Taylor McIntyre on 2019-07-03.
//  Copyright © 2019 hiimtmac. All rights reserved.
//

import XCTest
import PromiseKit
import Combine
import WebKit
@testable import ECMASwift

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

extension ESWebView.Message: JavaScriptParameterEncodable {}
extension ESWebView.Prompt: JavaScriptParameterEncodable {}
extension ESWebView.Request: JavaScriptParameterEncodable {}

extension ESWebView {
    enum Handler: String {
        case message = "ECMASwiftMessage"
        case prompt = "ECMASwiftPrompt"
        case request = "ECMASwiftRequest"
    }
}

// MARK: - PromiseKit
class MessagingTestsPromises: ECMASwiftTestCase {

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

extension ESWebView {
    func waitForMessage() -> Promise<ESWebView.Message> {
        return NotificationProxyPromise<ESWebView.Message>(key: "message", notification: ESWebView.message).promise
    }
    
    func waitForRequest() -> Promise<ESWebView.Request> {
        return NotificationProxyPromise<ESWebView.Request>(key: "request", notification: ESWebView.request).promise
    }
    
    func waitForPrompt() -> Promise<ESWebView.Prompt> {
        return NotificationProxyPromise<ESWebView.Prompt>(key: "prompt", notification: ESWebView.prompt).promise
    }
    
    func triggerMessage(handler: Handler, message: JavaScriptParameterEncodable) -> Promise<Void> {
        return runVoid(named: "window.webkit.messageHandlers.\(handler.rawValue).postMessage", args: [message])
    }
}

class NotificationProxyPromise<T>: NSObject {
    let (promise, seal) = Promise<T>.pending()
    let key: String
    private var retainCycle: NotificationProxyPromise?
    
    init(key: String, notification: Notification.Name) {
        self.key = key
        super.init()
        retainCycle = self

        NotificationCenter.default.addObserver(self, selector: #selector(handleError(_:)), name: ESWebView.error, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleMessage(_:)), name: notification, object: nil)

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
        if let message = notification.userInfo?[key] as? T {
            seal.fulfill(message)
        } else {
            seal.reject(ProxyError.userInfo)
        }
    }
}

// MARK: - Combine
@available(iOS 13.0, *)
class MessagingTestsCombine: ECMASwiftTestCase {

    var messageExp: XCTestExpectation!
    var triggerExp: XCTestExpectation!
    
    var anyCancellable: AnyCancellable?
    
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
        let payload = ESWebView.Message(message: "hello!")
        
        anyCancellable = Publishers
            .Zip(webView.triggerMessage(handler: .message, message: payload), webView.waitForMessage())
            .sink(receiveCompletion: { result in
                switch result {
                case .finished:
                    self.messageExp.fulfill()
                    self.triggerExp.fulfill()
                case .failure(let error): XCTFail(error.localizedDescription)
                }
            }, receiveValue: {
                XCTAssertEqual($1.message, "hello!")
            })
        
        wait(for: [messageExp, triggerExp], timeout: 5)
    }
    
    func testPrompt() {
        let payload = ESWebView.Prompt(name: "json", type: .variable)
        
        anyCancellable = Publishers
            .Zip(webView.triggerMessage(handler: .prompt, message: payload), webView.waitForPrompt())
            .sink(receiveCompletion: { result in
                switch result {
                case .finished:
                    self.messageExp.fulfill()
                    self.triggerExp.fulfill()
                case .failure(let error): XCTFail(error.localizedDescription)
                }
            }, receiveValue: {
                XCTAssertEqual($1.name, "json")
                XCTAssertEqual($1.type, .variable)
            })
        
        wait(for: [messageExp, triggerExp], timeout: 5)
    }
    
    func testPromptVariable() {
        let payload = ESWebView.Prompt(name: "json", type: .variable)
        
        anyCancellable = Publishers
            .Zip(webView.triggerMessage(handler: .prompt, message: payload), webView.waitForPrompt())
            .flatMap { self.webView.getVariable(named: $1.name, as: Person.self) }
            .sink(receiveCompletion: { result in
                switch result {
                case .finished:
                    self.messageExp.fulfill()
                    self.triggerExp.fulfill()
                case .failure(let error): XCTFail(error.localizedDescription)
                }
            }, receiveValue: {
                XCTAssertEqual($0.age, 27)
                XCTAssertEqual($0.name, "tmac")
            })
        
        wait(for: [messageExp, triggerExp], timeout: 5)
    }
    
    func testPromptFunction() {
        let payload = ESWebView.Prompt(name: "jsonResponse", type: .function)

        anyCancellable = Publishers
            .Zip(webView.triggerMessage(handler: .prompt, message: payload), webView.waitForPrompt())
            .flatMap { self.webView.runReturning(named: $1.name, as: Person.self) }
            .sink(receiveCompletion: { result in
                switch result {
                case .finished:
                    self.messageExp.fulfill()
                    self.triggerExp.fulfill()
                case .failure(let error): XCTFail(error.localizedDescription)
                }
            }, receiveValue: {
                XCTAssertEqual($0.age, 27)
                XCTAssertEqual($0.name, "tmac")
            })
        
        wait(for: [messageExp, triggerExp], timeout: 5)
    }
    
    func testRequest() {
        let payload = ESWebView.Request(object: "Jobs", predicate: nil, toHandler: "setJobs", type: .function)

        anyCancellable = Publishers
            .Zip(webView.triggerMessage(handler: .request, message: payload), webView.waitForRequest())
            .sink(receiveCompletion: { result in
                switch result {
                case .finished:
                    self.messageExp.fulfill()
                    self.triggerExp.fulfill()
                case .failure(let error): XCTFail(error.localizedDescription)
                }
            }, receiveValue: {
                XCTAssertEqual($1.object, "Jobs")
                XCTAssertEqual($1.predicate, nil)
            })
        
        wait(for: [messageExp, triggerExp], timeout: 5)
    }
    
    func testRequestWithReturn() {
        let people = [
            Person(name: "Taylor", age: 27),
            Person(name: "Connor", age: 24),
            Person(name: "Jordyn", age: 21)
        ]
        
        let payload = ESWebView.Request(object: "Person", predicate: nil, toHandler: "returnContents", type: .function)
        
        anyCancellable = Publishers
            .Zip(webView.triggerMessage(handler: .request, message: payload), webView.waitForRequest())
            .flatMap { self.webView.runReturning(named: $1.toHandler, args: [people], as: [Person].self) }
            .sink(receiveCompletion: { result in
                switch result {
                case .finished:
                    self.messageExp.fulfill()
                    self.triggerExp.fulfill()
                case .failure(let error): XCTFail(error.localizedDescription)
                }
            }, receiveValue: {
                   XCTAssertEqual($0.count, 3)
            })
        
        wait(for: [messageExp, triggerExp], timeout: 5)
    }
}

@available(iOS 13.0, *)
extension ESWebView {
    func waitForMessage() -> AnyPublisher<ESWebView.Message, Error> {
        return NotificationProxyCombine<ESWebView.Message>(key: "message", notification: ESWebView.message).publisher
    }

    func waitForRequest() -> AnyPublisher<ESWebView.Request, Error> {
        return NotificationProxyCombine<ESWebView.Request>(key: "request", notification: ESWebView.request).publisher
    }

    func waitForPrompt() -> AnyPublisher<ESWebView.Prompt, Error> {
        return NotificationProxyCombine<ESWebView.Prompt>(key: "prompt", notification: ESWebView.prompt).publisher
    }

    func triggerMessage(handler: Handler, message: JavaScriptParameterEncodable) -> AnyPublisher<Void, Error> {
        return runVoid(named: "window.webkit.messageHandlers.\(handler.rawValue).postMessage", args: [message])
    }
}

@available(iOS 13.0, *)
class NotificationProxyCombine<T>: NSObject {
    var publisher: AnyPublisher<T, Error>
    
    init(key: String, notification: Notification.Name) {
        let errorNotification = NotificationCenter.default
            .publisher(for: ESWebView.error, object: nil)
            .setFailureType(to: ProxyError.self)
            .tryMap { notification -> T in
                let error = notification.userInfo!["error"] as! String
                let attempting = notification.userInfo!["attempting"] as! String
                throw ProxyError.error("Attempting: \(attempting) -> Error: \(error)")
            }
            .eraseToAnyPublisher()
        
        let messageNotification = NotificationCenter.default
            .publisher(for: notification, object: nil)
            .tryMap { notification -> T in
                if let message = notification.userInfo?[key] as? T {
                    return message
                } else {
                    throw ProxyError.userInfo
                }
            }.eraseToAnyPublisher()
        
        publisher = Publishers
            .Merge(errorNotification, messageNotification)
            .eraseToAnyPublisher()
        
        super.init()
    }
}
