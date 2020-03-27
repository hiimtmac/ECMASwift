//
//  UserScriptTests.swift
//  ECMASwiftTests
//
//  Created by Taylor McIntyre on 2019-07-03.
//  Copyright © 2019 hiimtmac. All rights reserved.
//

import XCTest
import Combine
import WebKit
@testable import ECMASwift

class UserScriptTests: XCTestCase {

    var webView: ESWebView!
    var loadExp: XCTestExpectation!
    
    override func tearDown() {
        super.tearDown()
        webView = nil
    }
    
    func setupWebview(with scripts: [WKUserScript]) {
        let web = Bundle(for: UserScriptTests.self).resourceURL!
        let url = web.appendingPathComponent("index.html")
        webView = ESWebView(frame: .zero, scripts: scripts)
        webView.navigationDelegate = self
        webView.loadFileURL(url, allowingReadAccessTo: web)
        
        loadExp = expectation(description: "loadWebView")
        wait(for: [loadExp], timeout: 5)
    }
}

extension UserScriptTests: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loadExp.fulfill()
    }
}
 
class UserScriptTestsCombine: UserScriptTests {
    
    var anyCancellable: AnyCancellable?
    
    func testSetNewVariableBeginning() {
        let exp = expectation(description: "setNewVarBeginning")
        
        let script = WKUserScript(source: "const cool = \(asJS: "hello");", injectionTime: .atDocumentStart, forMainFrameOnly: true)
        setupWebview(with: [script])
        
        anyCancellable = webView
            .getVariable(named: "cool", as: String.self)
            .sink(receiveCompletion: { result in
                switch result {
                case .finished: exp.fulfill()
                case .failure(let error): XCTFail(error.localizedDescription)
                }
            }, receiveValue: {
                XCTAssertEqual($0, "hello")
            })
        
        wait(for: [exp], timeout: 5)
    }
    
    func testSetNewVariableEnd() {
        let exp = expectation(description: "setNewVarEnd")
        
        let script = WKUserScript(source: "const cool = \(asJS: "hello");", injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        setupWebview(with: [script])
        
        anyCancellable = webView
            .getVariable(named: "cool", as: String.self)
            .sink(receiveCompletion: { result in
                switch result {
                case .finished: exp.fulfill()
                case .failure(let error): XCTFail(error.localizedDescription)
                }
            }, receiveValue: {
                XCTAssertEqual($0, "hello")
            })
        
        wait(for: [exp], timeout: 5)
    }
    
    func testSetExistingVariableBeginning() {
        let exp = expectation(description: "setExistingVarBeginning")
        
        // `const string = "hello";` at beginning will overwrite app.js `var string = "taylor";` --> "hello"
        // `var string = "hello";` at beginning will be overwritten by app.js `var string = "taylor";` --> "taylor"
        // `string = "hello";` at beginning will be overwritten by app.js `var string = "taylor";` --> "taylor"
        let script = WKUserScript(source: "string = \(asJS: "hello");", injectionTime: .atDocumentStart, forMainFrameOnly: true)
        setupWebview(with: [script])
        
        anyCancellable = webView
            .getVariable(named: "string", as: String.self)
            .sink(receiveCompletion: { result in
                switch result {
                case .finished: exp.fulfill()
                case .failure(let error): XCTFail(error.localizedDescription)
                }
            }, receiveValue: {
                XCTAssertEqual($0, "taylor")
            })
        
        wait(for: [exp], timeout: 5)
    }
    
    func testSetExistingVariableEnd() {
        let exp = expectation(description: "setExistingVarEnd")
        
        // `const string = "hello";` at end will not be set due to app.js `var string = "taylor";` --> "taylor"
        // `var string = "hello";` at end will overwrite app.js `var string = "taylor";` --> "hello"
        // `string = "hello";` at end will overwrite app.js `var string = "taylor";` --> "hello"
        let script = WKUserScript(source: "string = \(asJS: "hello");", injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        setupWebview(with: [script])
        
        anyCancellable = webView
            .getVariable(named: "string", as: String.self)
            .sink(receiveCompletion: { result in
                switch result {
                case .finished: exp.fulfill()
                case .failure(let error): XCTFail(error.localizedDescription)
                }
            }, receiveValue: {
                XCTAssertEqual($0, "hello")
            })
        
        wait(for: [exp], timeout: 5)
    }
    
    struct Object: Codable, JavaScriptParameterEncodable {
        let name: String
        let age: Int
    }
    
    func testSetNewObjectBeginning() {
        let exp = expectation(description: "setNewObjectBeginning")
        
        let obj = Object(name: "connor", age: 24)
        
        let script = WKUserScript(source: "const cool = \(asJS: obj);", injectionTime: .atDocumentStart, forMainFrameOnly: true)
        setupWebview(with: [script])
        
        anyCancellable = webView
            .getVariable(named: "cool", as: Object.self)
            .sink(receiveCompletion: { result in
                switch result {
                case .finished: exp.fulfill()
                case .failure(let error): XCTFail(error.localizedDescription)
                }
            }, receiveValue: {
                XCTAssertEqual($0.name, "connor")
            })
        
        wait(for: [exp], timeout: 5)
    }
    
    func testSetNewObjectEnd() {
        let exp = expectation(description: "setNewObjectEnd")
        
        let obj = Object(name: "connor", age: 24)
        
        let script = WKUserScript(source: "const cool = \(asJS: obj);", injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        setupWebview(with: [script])
        
        anyCancellable = webView
            .getVariable(named: "cool", as: Object.self)
            .sink(receiveCompletion: { result in
                switch result {
                case .finished: exp.fulfill()
                case .failure(let error): XCTFail(error.localizedDescription)
                }
            }, receiveValue: {
                XCTAssertEqual($0.name, "connor")
            })
        
        wait(for: [exp], timeout: 5)
    }
    
    func testSetExistingObjectBeginning() {
        let exp = expectation(description: "setExistingObjectBeginning")
        
        let obj = Object(name: "connor", age: 24)
        
        // see existing variable tests above
        let script = WKUserScript(source: "json = \(asJS: obj);", injectionTime: .atDocumentStart, forMainFrameOnly: true)
        setupWebview(with: [script])
        
        anyCancellable = webView
            .getVariable(named: "json", as: Object.self)
            .sink(receiveCompletion: { result in
                switch result {
                case .finished: exp.fulfill()
                case .failure(let error): XCTFail(error.localizedDescription)
                }
            }, receiveValue: {
                XCTAssertEqual($0.name, "tmac")
            })
        
        wait(for: [exp], timeout: 5)
    }
    
    func testSetExistingObjectEnd() {
        let exp = expectation(description: "setExistingObjectEnd")
        
        let obj = Object(name: "connor", age: 24)
        
        // see existing variable tests above
        let script = WKUserScript(source: "json = \(asJS: obj);", injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        setupWebview(with: [script])
        
        anyCancellable = webView
            .getVariable(named: "json", as: Object.self)
            .sink(receiveCompletion: { result in
                switch result {
                case .finished: exp.fulfill()
                case .failure(let error): XCTFail(error.localizedDescription)
                }
            }, receiveValue: {
                XCTAssertEqual($0.name, "connor")
            })
        
        wait(for: [exp], timeout: 5)
    }
}
