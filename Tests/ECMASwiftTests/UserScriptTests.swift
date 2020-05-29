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
    
    var cancellable: AnyCancellable?
    
    override func tearDown() {
        super.tearDown()
        webView = nil
    }
    
    func setupWebview(with scripts: [WKUserScript]) {
        let web = webURL()
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
 
extension UserScriptTests {
    
    func testSetNewVariableBeginning() {
        let exp = expectation(description: "setNewVarBeginning")
        
        let script = WKUserScript(source: "const cool = \(asJS: "hello");", injectionTime: .atDocumentStart, forMainFrameOnly: true)
        setupWebview(with: [script])
        
        cancellable = webView
            .getVariable(named: "cool")
            .sinkTest(equalTo: "hello", on: exp)
        
        wait(for: [exp], timeout: 5)
    }
    
    func testSetNewVariableEnd() {
        let exp = expectation(description: "setNewVarEnd")
        
        let script = WKUserScript(source: "const cool = \(asJS: "hello");", injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        setupWebview(with: [script])
        
        cancellable = webView
            .getVariable(named: "cool")
            .sinkTest(equalTo: "hello", on: exp)
        
        wait(for: [exp], timeout: 5)
    }
    
    func testSetExistingVariableBeginning() {
        let exp = expectation(description: "setExistingVarBeginning")
        
        // `const string = "hello";` at beginning will overwrite app.js `var string = "taylor";` --> "hello"
        // `var string = "hello";` at beginning will be overwritten by app.js `var string = "taylor";` --> "taylor"
        // `string = "hello";` at beginning will be overwritten by app.js `var string = "taylor";` --> "taylor"
        let script = WKUserScript(source: "string = \(asJS: "hello");", injectionTime: .atDocumentStart, forMainFrameOnly: true)
        setupWebview(with: [script])
        
        cancellable = webView
            .getVariable(named: "string")
            .sinkTest(equalTo: "taylor", on: exp)
        
        wait(for: [exp], timeout: 5)
    }
    
    func testSetExistingVariableEnd() {
        let exp = expectation(description: "setExistingVarEnd")
        
        // `const string = "hello";` at end will not be set due to app.js `var string = "taylor";` --> "taylor"
        // `var string = "hello";` at end will overwrite app.js `var string = "taylor";` --> "hello"
        // `string = "hello";` at end will overwrite app.js `var string = "taylor";` --> "hello"
        let script = WKUserScript(source: "string = \(asJS: "hello");", injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        setupWebview(with: [script])
        
        cancellable = webView
            .getVariable(named: "string")
            .sinkTest(equalTo: "hello", on: exp)
        
        wait(for: [exp], timeout: 5)
    }
    
    struct Object: Equatable, Codable, JavaScriptParameterEncodable {
        let name: String
        let age: Int
    }
    
    func testSetNewObjectBeginning() {
        let exp = expectation(description: "setNewObjectBeginning")
        
        let obj = Object(name: "connor", age: 24)
        
        let script = WKUserScript(source: "const cool = \(asJS: obj);", injectionTime: .atDocumentStart, forMainFrameOnly: true)
        setupWebview(with: [script])
        
        cancellable = webView
            .getVariable(named: "cool")
            .sinkTest(equalTo: obj, on: exp)
        
        wait(for: [exp], timeout: 5)
    }
    
    func testSetNewObjectEnd() {
        let exp = expectation(description: "setNewObjectEnd")
        
        let obj = Object(name: "connor", age: 24)
        
        let script = WKUserScript(source: "const cool = \(asJS: obj);", injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        setupWebview(with: [script])
        
        cancellable = webView
            .getVariable(named: "cool")
            .sinkTest(equalTo: obj, on: exp)
        
        wait(for: [exp], timeout: 5)
    }
    
    func testSetExistingObjectBeginning() {
        let exp = expectation(description: "setExistingObjectBeginning")
        
        let compare = Object(name: "connor", age: 24)
        
        // see existing variable tests above
        let script = WKUserScript(source: "newJson = \(asJS: compare);", injectionTime: .atDocumentStart, forMainFrameOnly: true)
        setupWebview(with: [script])
        
        cancellable = webView
            .getVariable(named: "newJson")
            .sinkTest(equalTo: compare, on: exp)
        
        wait(for: [exp], timeout: 5)
    }
    
    func testSetExistingObjectEnd() {
        let exp = expectation(description: "setExistingObjectEnd")
        
        let obj = Object(name: "connor", age: 24)
        
        // see existing variable tests above
        let script = WKUserScript(source: "json = \(asJS: obj);", injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        setupWebview(with: [script])
        
        let comp = Object(name: "connor", age: 24)
        
        cancellable = webView
            .getVariable(named: "json")
            .sinkTest(equalTo: comp, on: exp)
        
        wait(for: [exp], timeout: 5)
    }
}
