//
//  ResolveTests.swift
//  ECMASwiftTests
//
//  Created by Taylor McIntyre on 2019-10-15.
//  Copyright © 2019 hiimtmac. All rights reserved.
//

import XCTest
@testable import ECMASwift

class ResolveTests: ECMASwiftTestCase {
    
    func testResolveSuccess() {
        let exp = expectation(description: "string")
        
        webView.evaluateJavaScript("string;", as: String.self).resolve { result in
            switch result {
            case .success(let str):
                XCTAssertEqual(str, "taylor")
            case .failure(let err):
                XCTFail(err.localizedDescription)
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5)
    }
    
    func testResolveFails() {
        let exp = expectation(description: "fails")
        
        webView.evaluateJavaScript("noExist;", as: Int.self).resolve { result in
            switch result {
            case .success:
                XCTFail("should not work")
            case .failure(let err):
                XCTAssert(err is JavaScriptError)
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5)
    }
}
