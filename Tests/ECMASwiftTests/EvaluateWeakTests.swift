//
//  EvaluateWeakTests.swift
//  ECMASwiftTests
//
//  Created by Taylor McIntyre on 2019-07-03.
//  Copyright © 2019 hiimtmac. All rights reserved.
//

import XCTest
@testable import ECMASwift

class EvaluateWeakTests: ECMASwiftTestCase {
    
    func testGetStringVar() {
        let exp = expectation(description: "string")
        
        cancellable = webView
            .evaluateJavaScript("string;")
            .map { (val: String) in
                XCTAssert(type(of: val) == String.self)
                return val
            }
            .eraseToAnyPublisher()
            .sinkTest(equalTo: "taylor", on: exp)
        
        wait(for: [exp], timeout: 5)
    }
    
    func testGetOptionalStringVar() {
        let exp = expectation(description: "string")
        
        cancellable = webView
            .evaluateJavaScript("string;")
            .map { (val: String?) in
                XCTAssert(type(of: val) == Optional<String>.self)
                return val
            }
            .eraseToAnyPublisher()
            .sinkTest(equalTo: "taylor" as String?, on: exp)
        
        wait(for: [exp], timeout: 5)
    }
    
    func testGetIntVar() {
        let exp = expectation(description: "int")
        
        cancellable = webView
            .evaluateJavaScript("int;")
            .map { (val: Int) in
                XCTAssert(type(of: val) == Int.self)
                return val
            }
            .eraseToAnyPublisher()
            .sinkTest(equalTo: 27, on: exp)
        
        wait(for: [exp], timeout: 5)
    }
    
    func testGetOptionalIntVar() {
        let exp = expectation(description: "int")
        
        cancellable = webView
            .evaluateJavaScript("int;")
            .map { (val: Int?) in
                XCTAssert(type(of: val) == Optional<Int>.self)
                return val
            }
            .eraseToAnyPublisher()
            .sinkTest(equalTo: 27 as Int?, on: exp)
        
        wait(for: [exp], timeout: 5)
    }
    
    func testGetDoubleVar() {
        let exp = expectation(description: "double")
        
        cancellable = webView
            .evaluateJavaScript("double;")
            .map { (val: Double) in
                XCTAssert(type(of: val) == Double.self)
                return val
            }
            .eraseToAnyPublisher()
            .sinkTest(equalTo: 10.5, on: exp)
        
        wait(for: [exp], timeout: 5)
    }
    
    func testGetOptionalDoubleVar() {
        let exp = expectation(description: "double")
        
        cancellable = webView
            .evaluateJavaScript("double;")
            .map { (val: Double?) in
                XCTAssert(type(of: val) == Optional<Double>.self)
                return val
            }
            .eraseToAnyPublisher()
            .sinkTest(equalTo: 10.5 as Double?, on: exp)
        
        wait(for: [exp], timeout: 5)
    }
    
    func testGetBoolVar() {
        let exp = expectation(description: "bool")
        
        cancellable = webView
            .evaluateJavaScript("bool;")
            .map { (val: Bool) in
                XCTAssert(type(of: val) == Bool.self)
                return val
            }
            .eraseToAnyPublisher()
            .sinkTest(equalTo: true, on: exp)
        
        wait(for: [exp], timeout: 5)
    }
    
    func testGetOptionalBoolVar() {
        let exp = expectation(description: "bool")
        
        cancellable = webView
            .evaluateJavaScript("bool;")
            .map { (val: Bool?) in
                XCTAssert(type(of: val) == Optional<Bool>.self)
                return val
            }
            .eraseToAnyPublisher()
            .sinkTest(equalTo: true as Bool?, on: exp)
        
        wait(for: [exp], timeout: 5)
    }
    
    func testGetArrayVar() {
        let exp = expectation(description: "array")
        
        cancellable = webView
            .evaluateJavaScript("array;")
            .map { (val: [Int]) in
                XCTAssert(type(of: val) == [Int].self)
                return val
            }
            .eraseToAnyPublisher()
            .sinkTest(equalTo: [1,2,3,4], on: exp)
        
        wait(for: [exp], timeout: 5)
    }
    
    func testGetOptionalArrayVar() {
        let exp = expectation(description: "array")
        
        cancellable = webView
            .evaluateJavaScript("array;")
            .map { (val: [Int]?) in
                XCTAssert(type(of: val) == Optional<[Int]>.self)
                return val
            }
            .eraseToAnyPublisher()
            .sinkTest(equalTo: [1,2,3,4] as [Int]?, on: exp)
        
        wait(for: [exp], timeout: 5)
    }
    
    struct JSON: Codable, Equatable {
        let name: String
        let age: Int
    }
    
    func testGetJSONVar() {
        let exp = expectation(description: "json")

        let compare = JSON(name: "tmac", age: 27)
        
        cancellable = webView
            .evaluateJavaScript("json;")
            .map { (val: JSON) in
                XCTAssert(type(of: val) == JSON.self)
                return val
            }
            .eraseToAnyPublisher()
            .sinkTest(equalTo: compare, on: exp)
        
        wait(for: [exp], timeout: 5)
    }
    
    func testGetOptionalJSONVar() {
        let exp = expectation(description: "json")

        let compare = JSON(name: "tmac", age: 27)
        
        cancellable = webView
            .evaluateJavaScript("json;")
            .map { (val: JSON?) in
                XCTAssert(type(of: val) == Optional<JSON>.self)
                return val
            }
            .eraseToAnyPublisher()
            .sinkTest(equalTo: compare as JSON?, on: exp)
        
        wait(for: [exp], timeout: 5)
    }
    
    func testGetDataVar() {
        let exp = expectation(description: "json")
        
        let compare = JSON(name: "tmac", age: 27)
        
        cancellable = webView
            .evaluateJavaScript("json;")
            .map { (val: Data) in
                XCTAssert(type(of: val) == Data.self)
                return val
            }
            .decode(type: JSON.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
            .sinkTest(equalTo: compare, on: exp)
        
        wait(for: [exp], timeout: 5)
    }
    
    func testGetOptionalDataVar() {
        let exp = expectation(description: "json")
        
        let compare = JSON(name: "tmac", age: 27)
        
        cancellable = webView
            .evaluateJavaScript("json;")
            .compactMap { (val: Data?) in
                XCTAssert(type(of: val) == Optional<Data>.self)
                return val
            }
            .decode(type: JSON.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
            .sinkTest(equalTo: compare, on: exp)
        
        wait(for: [exp], timeout: 5)
    }
    
    func testGetStringFunc() {
        let exp = expectation(description: "stringResponse")
        
        cancellable = webView
            .evaluateJavaScript("stringResponse();")
            .map { (val: String) in
                XCTAssert(type(of: val) == String.self)
                return val
            }
            .eraseToAnyPublisher()
            .sinkTest(equalTo: "taylor", on: exp)
        
        wait(for: [exp], timeout: 5)
    }
    
    func testGetOptionalStringFunc() {
        let exp = expectation(description: "stringResponse")
        
        cancellable = webView
            .evaluateJavaScript("stringResponse();")
            .map { (val: String?) in
                XCTAssert(type(of: val) == Optional<String>.self)
                return val
            }
            .eraseToAnyPublisher()
            .sinkTest(equalTo: "taylor" as String?, on: exp)
        
        wait(for: [exp], timeout: 5)
    }
    
    func testGetIntFunc() {
        let exp = expectation(description: "intResponse")
        
        cancellable = webView
            .evaluateJavaScript("intResponse();")
            .map { (val: Int) in
                XCTAssert(type(of: val) == Int.self)
                return val
            }
            .eraseToAnyPublisher()
            .sinkTest(equalTo: 27, on: exp)
        
        wait(for: [exp], timeout: 5)
    }
    
    func testGetOptionalIntFunc() {
        let exp = expectation(description: "intResponse")
        
        cancellable = webView
            .evaluateJavaScript("intResponse();")
            .map { (val: Int?) in
                XCTAssert(type(of: val) == Optional<Int>.self)
                return val
            }
            .eraseToAnyPublisher()
            .sinkTest(equalTo: 27 as Int?, on: exp)
        
        wait(for: [exp], timeout: 5)
    }
    
    func testGetDoubleFunc() {
        let exp = expectation(description: "doubleResponse")
        
        cancellable = webView
            .evaluateJavaScript("doubleResponse();")
            .map { (val: Double) in
                XCTAssert(type(of: val) == Double.self)
                return val
            }
            .eraseToAnyPublisher()
            .sinkTest(equalTo: 10.5, on: exp)
        
        wait(for: [exp], timeout: 5)
    }
    
    func testGetOptionalDoubleFunc() {
        let exp = expectation(description: "doubleResponse")
        
        cancellable = webView
            .evaluateJavaScript("doubleResponse();")
            .map { (val: Double?) in
                XCTAssert(type(of: val) == Optional<Double>.self)
                return val
            }
            .eraseToAnyPublisher()
            .sinkTest(equalTo: 10.5 as Double?, on: exp)
        
        wait(for: [exp], timeout: 5)
    }
    
    func testGetBoolFunc() {
        let exp = expectation(description: "boolResponse")
        
        cancellable = webView
            .evaluateJavaScript("boolResponse();")
            .map { (val: Bool) in
                XCTAssert(type(of: val) == Bool.self)
                return val
            }
            .eraseToAnyPublisher()
            .sinkTest(equalTo: true, on: exp)
        
        wait(for: [exp], timeout: 5)
    }
    
    func testGetOptionalBoolFunc() {
        let exp = expectation(description: "boolResponse")
        
        cancellable = webView
            .evaluateJavaScript("boolResponse();")
            .map { (val: Bool?) in
                XCTAssert(type(of: val) == Optional<Bool>.self)
                return val
            }
            .eraseToAnyPublisher()
            .sinkTest(equalTo: true as Bool?, on: exp)
        
        wait(for: [exp], timeout: 5)
    }
    
    func testGetArrayFunc() {
        let exp = expectation(description: "arrayResponse")
        
        cancellable = webView
            .evaluateJavaScript("arrayResponse();")
            .map { (val: [Int]) in
                XCTAssert(type(of: val) == [Int].self)
                return val
            }
            .eraseToAnyPublisher()
            .sinkTest(equalTo: [1,2,3,4], on: exp)
        
        wait(for: [exp], timeout: 5)
    }
    
    func testGetOptionalArrayFunc() {
        let exp = expectation(description: "arrayResponse")
        
        cancellable = webView
            .evaluateJavaScript("arrayResponse();")
            .map { (val: [Int]?) in
                XCTAssert(type(of: val) == Optional<[Int]>.self)
                return val
            }
            .eraseToAnyPublisher()
            .sinkTest(equalTo: [1,2,3,4] as [Int]?, on: exp)
        
        wait(for: [exp], timeout: 5)
    }
    
    func testGetJSONFunc() {
        let exp = expectation(description: "jsonResponse")

        let compare = JSON(name: "tmac", age: 27)
        
        cancellable = webView
            .evaluateJavaScript("jsonResponse();")
            .map { (val: JSON) in
                XCTAssert(type(of: val) == JSON.self)
                return val
            }
            .eraseToAnyPublisher()
            .sinkTest(equalTo: compare, on: exp)
        
        wait(for: [exp], timeout: 5)
    }
    
    func testGetOptionalJSONFunc() {
        let exp = expectation(description: "jsonResponse")

        let compare = JSON(name: "tmac", age: 27)
        
        cancellable = webView
            .evaluateJavaScript("jsonResponse();")
            .map { (val: JSON?) in
                XCTAssert(type(of: val) == Optional<JSON>.self)
                return val
            }
            .eraseToAnyPublisher()
            .sinkTest(equalTo: compare as JSON?, on: exp)
        
        wait(for: [exp], timeout: 5)
    }
    
    func testGetDataFunc() {
        let exp = expectation(description: "jsonResponse")

        let compare = JSON(name: "tmac", age: 27)
        
        cancellable = webView
            .evaluateJavaScript("jsonResponse();")
            .map { (val: Data) in
                XCTAssert(type(of: val) == Data.self)
                return val
            }
            .eraseToAnyPublisher()
            .decode(type: JSON.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
            .sinkTest(equalTo: compare, on: exp)
        
        wait(for: [exp], timeout: 5)
    }
    
    func testGetOptionalDataFunc() {
        let exp = expectation(description: "jsonResponse")

        let compare = JSON(name: "tmac", age: 27)
        
        cancellable = webView
            .evaluateJavaScript("jsonResponse();")
            .compactMap { (val: Data?) in
                XCTAssert(type(of: val) == Optional<Data>.self)
                return val
            }
            .eraseToAnyPublisher()
            .decode(type: JSON.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
            .sinkTest(equalTo: compare, on: exp)
        
        wait(for: [exp], timeout: 5)
    }
    
    func testGetFails() {
        let exp = expectation(description: "fails")
        
        cancellable = webView
            .evaluateJavaScript("fails();")
            .eraseToAnyPublisher()
            .map { (val: Void) in val }
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
        
        cancellable = webView
            .evaluateJavaScript("noResponse();")
            .sink(receiveCompletion: { result in
                switch result {
                case .finished: exp.fulfill()
                case .failure: XCTFail("should not happen")
                }
            }, receiveValue: {})
        
        wait(for: [exp], timeout: 5)
    }
    
    func testNullVariableReturnsNull() {
        let exp = expectation(description: "nullVarNull")
        
        cancellable = webView
            .evaluateJavaScript("nullable;")
            .sinkTest(equalTo: nil as String?, on: exp)
        
        wait(for: [exp], timeout: 5)
    }
    
    func testUndefinedVariableReturnsNull() {
        let exp = expectation(description: "undefinedVarNull")
        
        cancellable = webView
            .evaluateJavaScript("undefined;")
            .sinkTest(equalTo: nil as String?, on: exp)
        
        wait(for: [exp], timeout: 5)
    }
    
    func testNullableVariableReturnsAfterSetting() {
        let exp = expectation(description: "nullVarNonNull")
        
        cancellable = webView
            .evaluateJavaScript("nullable;")
            .map { (str: String?) in XCTAssertNil(str) }
            .flatMap { (any: Any?) in self.webView.evaluateJavaScript("nullable = 'taylor';") }
            .flatMap { (any: Any?) in self.webView.evaluateJavaScript("nullable;") }
            .eraseToAnyPublisher()
            .sinkTest(equalTo: "taylor" as String?, on: exp)
        
        wait(for: [exp], timeout: 5)
    }
    
    func testNullableVariableErrorsOnNullWhenExpecting() {
        let exp = expectation(description: "nullVarNonNullError")
        
        cancellable = webView
            .evaluateJavaScript("nullable;")
            .eraseToAnyPublisher()
            .map { (val: String) in val }
            .sink(receiveCompletion: { result in
                exp.fulfill()
            }, receiveValue: { (val: String) in
                XCTFail("Should not hit this")
            })
        
        wait(for: [exp], timeout: 5)
    }
}
