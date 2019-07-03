//
//  ECMASwiftTestCase.swift
//  ECMASwiftTests
//
//  Created by Taylor McIntyre on 2019-07-03.
//  Copyright © 2019 hiimtmac. All rights reserved.
//

import XCTest
import WebKit
import ECMASwift

class ECMASwiftTestCase: XCTestCase {
    
    var webView: ESWebView!
    var loadExp: XCTestExpectation!
    
    override func setUp() {
        super.setUp()
        
        let web = Bundle(for: ECMASwiftTestCase.self).resourceURL!
        let url = web.appendingPathComponent("index.html")
        webView = ESWebView(frame: .zero)
        webView.navigationDelegate = self
        webView.loadFileURL(url, allowingReadAccessTo: web)
        
        loadExp = expectation(description: "loadWebView")
        wait(for: [loadExp], timeout: 5)
    }
    
    override func tearDown() {
        super.tearDown()
        webView = nil
    }
}

extension ECMASwiftTestCase: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loadExp.fulfill()
    }
}
