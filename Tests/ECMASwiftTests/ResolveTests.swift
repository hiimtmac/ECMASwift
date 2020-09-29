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
    
    var anyCancellable: AnyCancellable?
    
    func testResolveSuccess() {
        let exp = expectation(description: "string")
                
        anyCancellable = webView.evaluateJavaScript("string;").resolve { result in
            switch result {
            case .success(let str):
                XCTAssertEqual(str as? String, "taylor")
            case .failure(let err):
                XCTFail(err.localizedDescription)
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5)
    }
    
    func testResolveFails() {
        let exp = expectation(description: "fails")
        
        anyCancellable = webView.evaluateJavaScript("noExist;").resolve { result in
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
