// ECMASwiftTestCase.swift
// Copyright © 2022 hiimtmac

import ECMASwift
import XCTest

class ECMASwiftTestCase: XCTestCase {
    var webView: ESWebView!
    var loadExp: XCTestExpectation!

    var cancellable: AnyCancellable?

    override func setUp() {
        super.setUp()

        let web = webURL()
        let url = web.appendingPathComponent("index.html")
        self.webView = ESWebView(frame: .zero)
        self.webView.navigationDelegate = self
        self.webView.loadFileURL(url, allowingReadAccessTo: web)

        self.loadExp = expectation(description: "loadWebView")
        wait(for: [self.loadExp], timeout: 5)
    }

    override func tearDown() {
        super.tearDown()
        self.webView = nil
    }
}

extension ECMASwiftTestCase: WKNavigationDelegate {
    func webView(_: WKWebView, didFinish _: WKNavigation!) {
        self.loadExp.fulfill()
    }
}

extension AnyPublisher where Output: Equatable {
    func sinkTest(equalTo: Output, on expectation: XCTestExpectation, file _: StaticString = #file, line _: UInt = #line) -> AnyCancellable {
        self.sink(receiveCompletion: { result in
            switch result {
            case .finished: expectation.fulfill()
            case let .failure(error): XCTFail(error.localizedDescription)
            }
        }, receiveValue: { output in
            XCTAssertEqual(equalTo, output)
        })
    }
}
