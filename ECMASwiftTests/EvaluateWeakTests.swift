//
//  EvaluateWeakTests.swift
//  ECMASwiftTests
//
//  Created by Taylor McIntyre on 2019-07-03.
//  Copyright © 2019 hiimtmac. All rights reserved.
//

import XCTest
import Combine
import PromiseKit
@testable import ECMASwift

class EvaluateWeakTestsPromises: ECMASwiftTestCase {
    
    func testGetStringVar() {
        let exp = expectation(description: "string")
        
        firstly {
            webView.evaluateJavaScript("string;", as: String.self)
        }.get {
            XCTAssertEqual($0, "taylor")
            exp.fulfill()
        }.catch {
            XCTFail($0.localizedDescription)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5)
    }
    
    func testGetIntVar() {
        let exp = expectation(description: "int")
        
        firstly {
            webView.evaluateJavaScript("int;", as: Int.self)
        }.get {
            XCTAssertEqual($0, 27)
            exp.fulfill()
        }.catch {
            XCTFail($0.localizedDescription)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5)
    }
    
    func testGetDoubleVar() {
        let exp = expectation(description: "double")
        
        firstly {
            webView.evaluateJavaScript("double;", as: Double.self)
        }.get {
            XCTAssertEqual($0, 10.5)
            exp.fulfill()
        }.catch {
            XCTFail($0.localizedDescription)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5)
    }
    
    func testGetBoolVar() {
        let exp = expectation(description: "bool")
        
        firstly {
            webView.evaluateJavaScript("bool;", as: Bool.self)
        }.get {
            XCTAssertEqual($0, true)
            exp.fulfill()
        }.catch {
            XCTFail($0.localizedDescription)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5)
    }
    
    func testGetArrayVar() {
        let exp = expectation(description: "array")
        
        firstly {
            webView.evaluateJavaScript("array;", as: [Int].self)
        }.get {
            XCTAssertEqual($0, [1, 2, 3, 4])
            exp.fulfill()
        }.catch {
            XCTFail($0.localizedDescription)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5)
    }
    
    func testGetJSONVar() {
        let exp = expectation(description: "json")
        
        struct JSON: Codable {
            let name: String
            let age: Int
        }
        
        firstly {
            webView.evaluateJavaScript("json;", as: JSON.self)
        }.get {
            XCTAssertEqual($0.name, "tmac")
            XCTAssertEqual($0.age, 27)
            exp.fulfill()
        }.catch {
            XCTFail($0.localizedDescription)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5)
    }
    
    
    func testGetDataVar() {
        let exp = expectation(description: "json")
        
        struct JSON: Codable {
            let name: String
            let age: Int
        }
        
        firstly {
            webView.evaluateJavaScript("json;", as: Data.self)
        }.map {
            return try JSONDecoder().decode(JSON.self, from: $0)
        }.get {
            XCTAssertEqual($0.name, "tmac")
            XCTAssertEqual($0.age, 27)
            exp.fulfill()
        }.catch {
            XCTFail($0.localizedDescription)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5)
    }
    
    func testGetStringFunc() {
        let exp = expectation(description: "stringResponse")
        
        firstly {
            webView.evaluateJavaScript("stringResponse();", as: String.self)
        }.get {
            XCTAssertEqual($0, "taylor")
            exp.fulfill()
        }.catch {
            XCTFail($0.localizedDescription)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5)
    }
    
    func testGetIntFunc() {
        let exp = expectation(description: "intResponse")
        
        firstly {
            webView.evaluateJavaScript("intResponse();", as: Int.self)
        }.get {
            XCTAssertEqual($0, 27)
            exp.fulfill()
        }.catch {
            XCTFail($0.localizedDescription)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5)
    }
    
    func testGetDoubleFunc() {
        let exp = expectation(description: "doubleResponse")
        
        firstly {
            webView.evaluateJavaScript("doubleResponse();", as: Double.self)
        }.get {
            XCTAssertEqual($0, 10.5)
            exp.fulfill()
        }.catch {
            XCTFail($0.localizedDescription)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5)
    }
    
    func testGetBoolFunc() {
        let exp = expectation(description: "boolResponse")
        
        firstly {
            webView.evaluateJavaScript("boolResponse();", as: Bool.self)
        }.get {
            XCTAssertEqual($0, true)
            exp.fulfill()
        }.catch {
            XCTFail($0.localizedDescription)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5)
    }
    
    func testGetArrayFunc() {
        let exp = expectation(description: "arrayResponse")
        
        firstly {
            webView.evaluateJavaScript("arrayResponse();", as: [Int].self)
        }.get {
            XCTAssertEqual($0, [1, 2, 3, 4])
            exp.fulfill()
        }.catch {
            XCTFail($0.localizedDescription)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5)
    }
    
    func testGetJSONFunc() {
        let exp = expectation(description: "jsonResponse")
        
        struct JSON: Codable {
            let name: String
            let age: Int
        }
        
        firstly {
            webView.evaluateJavaScript("jsonResponse();", as: JSON.self)
        }.get {
            XCTAssertEqual($0.name, "tmac")
            XCTAssertEqual($0.age, 27)
            exp.fulfill()
        }.catch {
            XCTFail($0.localizedDescription)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5)
    }
    
    func testGetDataFunc() {
        let exp = expectation(description: "jsonResponse")
        
        struct JSON: Codable {
            let name: String
            let age: Int
        }
        
        firstly {
            webView.evaluateJavaScript("jsonResponse();", as: Data.self)
        }.map {
            return try JSONDecoder().decode(JSON.self, from: $0)
        }.get {
            XCTAssertEqual($0.name, "tmac")
            XCTAssertEqual($0.age, 27)
            exp.fulfill()
        }.catch {
            XCTFail($0.localizedDescription)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5)
    }
    
    func testGetFails() {
        let exp = expectation(description: "fails")
        
        firstly {
            webView.evaluateJavaScript("noExist;", as: Int.self)
        }.get { _ in
            XCTFail("should not work")
            exp.fulfill()
        }.catch {
            XCTAssert($0 is JavaScriptError)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5)
    }
    
    func testGetVoidFunc() {
        let exp = expectation(description: "noResponse")
        
        firstly {
            webView.evaluateJavaScript("noResponse();")
        }.done {
            exp.fulfill()
        }.catch {
            XCTFail($0.localizedDescription)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5)
    }
}

@available(iOS 13.0, *)
class EvaluateWeakTestsCombine: ECMASwiftTestCase {
    
    var anyCancellable: AnyCancellable?
    
    func testGetStringVar() {
        let exp = expectation(description: "string")
        
        anyCancellable = webView
            .evaluateJavaScript("string;", as: String.self)
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
    
    func testGetIntVar() {
        let exp = expectation(description: "int")
        
        anyCancellable = webView
            .evaluateJavaScript("int;", as: Int.self)
            .sink(receiveCompletion: { result in
                switch result {
                case .finished: exp.fulfill()
                case .failure(let error): XCTFail(error.localizedDescription)
                }
            }, receiveValue: {
                XCTAssertEqual($0, 27)
            })
        
        wait(for: [exp], timeout: 5)
    }
    
    func testGetDoubleVar() {
        let exp = expectation(description: "double")
        
        anyCancellable = webView
            .evaluateJavaScript("double;", as: Double.self)
            .sink(receiveCompletion: { result in
                switch result {
                case .finished: exp.fulfill()
                case .failure(let error): XCTFail(error.localizedDescription)
                }
            }, receiveValue: {
                XCTAssertEqual($0, 10.5)
            })
        
        wait(for: [exp], timeout: 5)
    }
    
    func testGetBoolVar() {
        let exp = expectation(description: "bool")
        
        anyCancellable = webView
            .evaluateJavaScript("bool;", as: Bool.self)
            .sink(receiveCompletion: { result in
                switch result {
                case .finished: exp.fulfill()
                case .failure(let error): XCTFail(error.localizedDescription)
                }
            }, receiveValue: {
                XCTAssertEqual($0, true)
            })
        
        wait(for: [exp], timeout: 5)
    }
    
    func testGetArrayVar() {
        let exp = expectation(description: "array")
        
        anyCancellable = webView
            .evaluateJavaScript("array;", as: [Int].self)
            .sink(receiveCompletion: { result in
                switch result {
                case .finished: exp.fulfill()
                case .failure(let error): XCTFail(error.localizedDescription)
                }
            }, receiveValue: {
                XCTAssertEqual($0, [1, 2, 3, 4])
            })
        XCTAssertNotNil(anyCancellable)
        
        wait(for: [exp], timeout: 5)
    }
    
    func testGetJSONVar() {
        let exp = expectation(description: "json")
        
        struct JSON: Codable {
            let name: String
            let age: Int
        }
        
        anyCancellable = webView
            .evaluateJavaScript("json;", as: JSON.self)
            .sink(receiveCompletion: { result in
                switch result {
                case .finished: exp.fulfill()
                case .failure(let error): XCTFail(error.localizedDescription)
                }
            }, receiveValue: {
                XCTAssertEqual($0.name, "tmac")
                XCTAssertEqual($0.age, 27)
            })
        
        wait(for: [exp], timeout: 5)
    }
    
    
    func testGetDataVar() {
        let exp = expectation(description: "json")
        
        struct JSON: Codable {
            let name: String
            let age: Int
        }
        
        anyCancellable = webView
            .evaluateJavaScript("json;", as: Data.self)
            .decode(type: JSON.self, decoder: JSONDecoder())
            .sink(receiveCompletion: { result in
                switch result {
                case .finished: exp.fulfill()
                case .failure(let error): XCTFail(error.localizedDescription)
                }
            }, receiveValue: {
                XCTAssertEqual($0.name, "tmac")
                XCTAssertEqual($0.age, 27)
            })
        
        wait(for: [exp], timeout: 5)
    }
    
    func testGetStringFunc() {
        let exp = expectation(description: "stringResponse")
        
        anyCancellable = webView
            .evaluateJavaScript("stringResponse();", as: String.self)
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
    
    func testGetIntFunc() {
        let exp = expectation(description: "intResponse")
        
        anyCancellable = webView
            .evaluateJavaScript("intResponse();", as: Int.self)
            .sink(receiveCompletion: { result in
                switch result {
                case .finished: exp.fulfill()
                case .failure(let error): XCTFail(error.localizedDescription)
                }
            }, receiveValue: {
                XCTAssertEqual($0, 27)
            })
        
        wait(for: [exp], timeout: 5)
    }
    
    func testGetDoubleFunc() {
        let exp = expectation(description: "doubleResponse")
        
        anyCancellable = webView
            .evaluateJavaScript("doubleResponse();", as: Double.self)
            .sink(receiveCompletion: { result in
                switch result {
                case .finished: exp.fulfill()
                case .failure(let error): XCTFail(error.localizedDescription)
                }
            }, receiveValue: {
                XCTAssertEqual($0, 10.5)
            })
        
        wait(for: [exp], timeout: 5)
    }
    
    func testGetBoolFunc() {
        let exp = expectation(description: "boolResponse")
        
        anyCancellable = webView
            .evaluateJavaScript("boolResponse();", as: Bool.self)
            .sink(receiveCompletion: { result in
                switch result {
                case .finished: exp.fulfill()
                case .failure(let error): XCTFail(error.localizedDescription)
                }
            }, receiveValue: {
                XCTAssertEqual($0, true)
            })
        
        wait(for: [exp], timeout: 5)
    }
    
    func testGetArrayFunc() {
        let exp = expectation(description: "arrayResponse")
        
        anyCancellable = webView
            .evaluateJavaScript("arrayResponse();", as: [Int].self)
            .sink(receiveCompletion: { result in
                switch result {
                case .finished: exp.fulfill()
                case .failure(let error): XCTFail(error.localizedDescription)
                }
            }, receiveValue: {
                XCTAssertEqual($0, [1, 2, 3, 4])
            })
        
        wait(for: [exp], timeout: 5)
    }
    
    func testGetJSONFunc() {
        let exp = expectation(description: "jsonResponse")
        
        struct JSON: Codable {
            let name: String
            let age: Int
        }
        
        anyCancellable = webView
            .evaluateJavaScript("jsonResponse();", as: JSON.self)
            .sink(receiveCompletion: { result in
                switch result {
                case .finished: exp.fulfill()
                case .failure(let error): XCTFail(error.localizedDescription)
                }
            }, receiveValue: {
                XCTAssertEqual($0.name, "tmac")
                XCTAssertEqual($0.age, 27)
            })
        
        wait(for: [exp], timeout: 5)
    }
    
    func testGetDataFunc() {
        let exp = expectation(description: "jsonResponse")
        
        struct JSON: Codable {
            let name: String
            let age: Int
        }
        
        anyCancellable = webView
            .evaluateJavaScript("jsonResponse();", as: Data.self)
            .decode(type: JSON.self, decoder: JSONDecoder())
            .sink(receiveCompletion: { result in
                switch result {
                case .finished: exp.fulfill()
                case .failure(let error): XCTFail(error.localizedDescription)
                }
            }, receiveValue: {
                XCTAssertEqual($0.name, "tmac")
                XCTAssertEqual($0.age, 27)
            })
        
        wait(for: [exp], timeout: 5)
    }
    
    func testGetFails() {
        let exp = expectation(description: "fails")
        
        anyCancellable = webView
            .evaluateJavaScript("fails();", as: Int.self)
            .sink(receiveCompletion: { result in
                switch result {
                case .finished: exp.fulfill()
                case .failure(let error):
                    XCTAssert(error is JavaScriptError)
                    exp.fulfill()
                }
            }, receiveValue: { _ in
                XCTFail("should not work")
            })
        
        wait(for: [exp], timeout: 5)
    }
    
    func testGetVoidFunc() {
        let exp = expectation(description: "noResponse")
        
        anyCancellable = webView
            .evaluateJavaScript("noResponse();")
            .sink(receiveCompletion: { result in
                switch result {
                case .finished: exp.fulfill()
                case .failure: XCTFail("should not happen")
                }
            }, receiveValue: {})
        
        wait(for: [exp], timeout: 5)
    }
}
