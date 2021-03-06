//
//  MessagingTests.swift
//  ECMASwiftTests
//
//  Created by Taylor McIntyre on 2019-07-03.
//  Copyright © 2019 hiimtmac. All rights reserved.
//

import XCTest
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

class MessagingTests: ECMASwiftTestCase {

    var messageExp: XCTestExpectation!
    var triggerExp: XCTestExpectation!
    
    override func setUp() {
        super.setUp()
        
        messageExp = expectation(description: "message")
        triggerExp = expectation(description: "trigger")
    }
    
    struct Person: Equatable, Codable, JavaScriptParameterEncodable {
        let name: String
        let age: Int
    }
    
    func testMessage() {
        let payload = ESWebView.Message(message: "hello!")
        
        cancellable = Publishers
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
        
        cancellable = Publishers
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
        
        let obj = Person(name: "tmac", age: 27)
        
        cancellable = Publishers
            .Zip(webView.triggerMessage(handler: .prompt, message: payload), webView.waitForPrompt())
            .flatMap { self.webView.getVariable(named: $1.name) }
            .sink(receiveCompletion: { result in
                switch result {
                case .finished:
                    self.messageExp.fulfill()
                    self.triggerExp.fulfill()
                case .failure(let error): XCTFail(error.localizedDescription)
                }
            }, receiveValue: {
                XCTAssertEqual($0, obj)
            })
        
        wait(for: [messageExp, triggerExp], timeout: 5)
    }
    
    func testPromptFunction() {
        let payload = ESWebView.Prompt(name: "jsonResponse", type: .function)

        let obj = Person(name: "tmac", age: 27)
        
        cancellable = Publishers
            .Zip(webView.triggerMessage(handler: .prompt, message: payload), webView.waitForPrompt())
            .flatMap { self.webView.runReturning(named: $1.name) }
            .sink(receiveCompletion: { result in
                switch result {
                case .finished:
                    self.messageExp.fulfill()
                    self.triggerExp.fulfill()
                case .failure(let error): XCTFail(error.localizedDescription)
                }
            }, receiveValue: {
                XCTAssertEqual($0, obj)
            })
        
        wait(for: [messageExp, triggerExp], timeout: 5)
    }
    
    func testRequest() {
        let payload = ESWebView.Request(object: "Jobs", predicate: nil, toHandler: "setJobs", type: .function)

        cancellable = Publishers
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
        
        cancellable = Publishers
            .Zip(webView.triggerMessage(handler: .request, message: payload), webView.waitForRequest())
            .flatMap { self.webView.runReturning(named: $1.toHandler, args: [people]) }
            .sink(receiveCompletion: { result in
                switch result {
                case .finished:
                    self.messageExp.fulfill()
                    self.triggerExp.fulfill()
                case .failure(let error): XCTFail(error.localizedDescription)
                }
            }, receiveValue: {
                   XCTAssertEqual($0, people)
            })
        
        wait(for: [messageExp, triggerExp], timeout: 5)
    }
}

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
