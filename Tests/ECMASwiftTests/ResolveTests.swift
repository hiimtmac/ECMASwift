// ResolveTests.swift
// Copyright © 2022 hiimtmac

import XCTest
@testable import ECMASwift

class ResolveTests: ECMASwiftTestCase {
    var anyCancellable: AnyCancellable?

    func testResolveSuccess() {
        let exp = expectation(description: "string")

        self.anyCancellable = webView.evaluateJavaScript("string;").resolve { (result: Result<Any?, Error>) in
            switch result {
            case let .success(str):
                XCTAssertEqual(str as? String, "taylor")
            case let .failure(err):
                XCTFail(err.localizedDescription)
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 5)
    }

    func testResolveFails() {
        let exp = expectation(description: "fails")

        self.anyCancellable = webView.evaluateJavaScript("noExist;").resolve { (result: Result<Any?, Error>) in
            switch result {
            case .success:
                XCTFail("should not work")
            case let .failure(err):
                XCTAssert(err is JavaScriptError)
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 5)
    }
}
