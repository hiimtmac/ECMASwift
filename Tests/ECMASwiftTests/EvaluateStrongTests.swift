//
//  EvaluateStongTests.swift
//  ECMASwiftTests
//
//  Created by Taylor McIntyre on 2019-07-03.
//  Copyright © 2019 hiimtmac. All rights reserved.
//

import XCTest
import Combine
@testable import ECMASwift

class EvaluateStrongTests: ECMASwiftTestCase {

    func testStringVar() {
        let exp = expectation(description: "string")
        
        cancellable = webView
            .getVariable(named: "string")
            .map { (val: String) in
                XCTAssertEqual(val, "taylor")
                XCTAssert(type(of: val) == String.self)
            }
            .flatMap { self.webView.setVariable(named: "string", value: "hello!") }
            .flatMap { self.webView.getVariable(named: "string") }
            .eraseToAnyPublisher()
            .sinkTest(equalTo: "hello!", on: exp)
        
        wait(for: [exp], timeout: 5)
    }
    
    func testOptionalStringVar() {
        let exp = expectation(description: "string")
        
        cancellable = webView
            .getVariable(named: "string")
            .map { (val: String?) in
                XCTAssertEqual(val, "taylor")
                XCTAssert(type(of: val) == Optional<String>.self)
            }
            .flatMap { self.webView.setVariable(named: "string", value: "hello!") }
            .flatMap { self.webView.getVariable(named: "string") }
            .eraseToAnyPublisher()
            .sinkTest(equalTo: "hello!" as String?, on: exp)
        
        wait(for: [exp], timeout: 5)
    }
    
    func testIntVar() {
        let exp = expectation(description: "int")
        
        cancellable = webView
            .getVariable(named: "int")
            .map { (val: Int) in
                XCTAssertEqual(val, 27)
                XCTAssert(type(of: val) == Int.self)
            }
            .flatMap { self.webView.setVariable(named: "int", value: 37) }
            .flatMap { self.webView.getVariable(named: "int") }
            .eraseToAnyPublisher()
            .sinkTest(equalTo: 37, on: exp)
        
        wait(for: [exp], timeout: 5)
    }
    
    func testOptionalIntVar() {
        let exp = expectation(description: "int")
        
        cancellable = webView
            .getVariable(named: "int")
            .map { (val: Int?) in
                XCTAssertEqual(val, 27)
                XCTAssert(type(of: val) == Optional<Int>.self)
            }
            .flatMap { self.webView.setVariable(named: "int", value: 37) }
            .flatMap { self.webView.getVariable(named: "int") }
            .eraseToAnyPublisher()
            .sinkTest(equalTo: 37 as Int?, on: exp)
        
        wait(for: [exp], timeout: 5)
    }
    
    func testDoubleVar() {
        let exp = expectation(description: "double")
        
        cancellable = webView
            .getVariable(named: "double")
            .map { (val: Double) in
                XCTAssertEqual(val, 10.5)
                XCTAssert(type(of: val) == Double.self)
            }
            .flatMap { self.webView.setVariable(named: "double", value: 26.6) }
            .flatMap { self.webView.getVariable(named: "double") }
            .eraseToAnyPublisher()
            .sinkTest(equalTo: 26.6, on: exp)
        
        wait(for: [exp], timeout: 5)
    }
    
    func testOptionalDoubleVar() {
        let exp = expectation(description: "double")
        
        cancellable = webView
            .getVariable(named: "double")
            .map { (val: Double?) in
                XCTAssertEqual(val, 10.5)
                XCTAssert(type(of: val) == Optional<Double>.self)
            }
            .flatMap { self.webView.setVariable(named: "double", value: 26.6) }
            .flatMap { self.webView.getVariable(named: "double") }
            .eraseToAnyPublisher()
            .sinkTest(equalTo: 26.6 as Double?, on: exp)
        
        wait(for: [exp], timeout: 5)
    }
    
    func testBoolVar() {
        let exp = expectation(description: "bool")
        
        cancellable = webView
            .getVariable(named: "bool")
            .map { (val: Bool) in
                XCTAssertEqual(val, true)
                XCTAssert(type(of: val) == Bool.self)
            }
            .flatMap { self.webView.setVariable(named: "bool", value: false) }
            .flatMap { self.webView.getVariable(named: "bool") }
            .eraseToAnyPublisher()
            .sinkTest(equalTo: false, on: exp)
        
        wait(for: [exp], timeout: 5)
    }
    
    func testOptionalBoolVar() {
        let exp = expectation(description: "bool")
        
        cancellable = webView
            .getVariable(named: "bool")
            .map { (val: Bool?) in
                XCTAssertEqual(val, true)
                XCTAssert(type(of: val) == Optional<Bool>.self)
            }
            .flatMap { self.webView.setVariable(named: "bool", value: false) }
            .flatMap { self.webView.getVariable(named: "bool") }
            .eraseToAnyPublisher()
            .sinkTest(equalTo: false as Bool?, on: exp)
        
        wait(for: [exp], timeout: 5)
    }
    
    func testArrayVar() {
        let exp = expectation(description: "array")
        
        cancellable = webView
            .getVariable(named: "array")
            .map { (val: [Int]) in
                XCTAssertEqual(val, [1,2,3,4])
                XCTAssert(type(of: val) == [Int].self)
            }
            .flatMap { self.webView.setVariable(named: "array", value: [5, 6, 7, 8]) }
            .flatMap { self.webView.getVariable(named: "array") }
            .eraseToAnyPublisher()
            .sinkTest(equalTo: [5,6,7,8], on: exp)
        
        wait(for: [exp], timeout: 5)
    }
    
    func testOptionalArrayVar() {
        let exp = expectation(description: "array")
        
        cancellable = webView
            .getVariable(named: "array")
            .map { (val: [Int]?) in
                XCTAssertEqual(val, [1,2,3,4])
                XCTAssert(type(of: val) == Optional<[Int]>.self)
            }
            .flatMap { self.webView.setVariable(named: "array", value: [5, 6, 7, 8]) }
            .flatMap { self.webView.getVariable(named: "array") }
            .eraseToAnyPublisher()
            .sinkTest(equalTo: [5,6,7,8] as [Int]?, on: exp)
        
        wait(for: [exp], timeout: 5)
    }
    
    struct JSON: Codable, JavaScriptParameterEncodable, Equatable {
        let name: String
        let age: Int
    }
    
    func testJSONVar() {
        let exp = expectation(description: "json")

        let compare1 = JSON(name: "tmac", age: 27)
        let compare2 = JSON(name: "taylor", age: 37)
        
        cancellable = webView
            .getVariable(named: "json")
            .map { (val: JSON) in
                XCTAssertEqual(val, compare1)
                XCTAssert(type(of: val) == JSON.self)
            }
            .flatMap { self.webView.setVariable(named: "json", value: compare2) }
            .flatMap { self.webView.getVariable(named: "json") }
            .eraseToAnyPublisher()
            .sinkTest(equalTo: compare2, on: exp)
        
        wait(for: [exp], timeout: 5)
    }
    
    func testOptionalJSONVar() {
        let exp = expectation(description: "json")

        let compare1 = JSON(name: "tmac", age: 27)
        let compare2 = JSON(name: "taylor", age: 37)
        
        cancellable = webView
            .getVariable(named: "json")
            .map { (val: JSON?) in
                XCTAssertEqual(val, compare1)
                XCTAssert(type(of: val) == Optional<JSON>.self)
            }
            .flatMap { self.webView.setVariable(named: "json", value: compare2) }
            .flatMap { self.webView.getVariable(named: "json") }
            .eraseToAnyPublisher()
            .sinkTest(equalTo: compare2 as JSON?, on: exp)
        
        wait(for: [exp], timeout: 5)
    }
    
    func testDataVar() {
        let exp = expectation(description: "json")
        
        let compare1 = JSON(name: "tmac", age: 27)
        let compare2 = JSON(name: "taylor", age: 37)
        
        cancellable = webView
            .getVariable(named: "json")
            .map { (val: Data) in
                XCTAssert(type(of: val) == Data.self)
                return val
            }
            .decode(type: JSON.self, decoder: JSONDecoder())
            .map {
                XCTAssertEqual($0, compare1)
            }
            .flatMap { self.webView.setVariable(named: "json", value: compare2) }
            .flatMap { self.webView.getVariable(named: "json") }
            .eraseToAnyPublisher()
            .sinkTest(equalTo: compare2, on: exp)
        
        wait(for: [exp], timeout: 5)
    }
    
    func testOptionalDataVar() {
        let exp = expectation(description: "json")
        
        let compare1 = JSON(name: "tmac", age: 27)
        let compare2 = JSON(name: "taylor", age: 37)
        
        cancellable = webView
            .getVariable(named: "json")
            .compactMap { (val: Data?) in
                XCTAssert(type(of: val) == Optional<Data>.self)
                return val
            }
            .decode(type: JSON.self, decoder: JSONDecoder())
            .map {
                XCTAssertEqual($0, compare1)
            }
            .flatMap { self.webView.setVariable(named: "json", value: compare2) }
            .flatMap { self.webView.getVariable(named: "json") }
            .eraseToAnyPublisher()
            .sinkTest(equalTo: compare2, on: exp)
        
        wait(for: [exp], timeout: 5)
    }
    
    func testRunReturningString() {
        let exp = expectation(description: "stringResponse")
        
        cancellable = webView
            .runReturning(named: "stringResponse")
            .map { (val: String) in
                XCTAssert(type(of: val) == String.self)
                return val
            }
            .eraseToAnyPublisher()
            .sinkTest(equalTo: "taylor", on: exp)
        
        wait(for: [exp], timeout: 5)
    }
    
    func testRunOptionalReturningString() {
        let exp = expectation(description: "stringResponse")
        
        cancellable = webView
            .runReturning(named: "stringResponse")
            .map { (val: String?) in
                XCTAssert(type(of: val) == Optional<String>.self)
                return val
            }
            .eraseToAnyPublisher()
            .sinkTest(equalTo: "taylor" as String?, on: exp)
        
        wait(for: [exp], timeout: 5)
    }
    
    func testRunReturningInt() {
        let exp = expectation(description: "intResponse")
        
        cancellable = webView
            .runReturning(named: "intResponse")
            .map { (val: Int) in
                XCTAssert(type(of: val) == Int.self)
                return val
            }
            .eraseToAnyPublisher()
            .sinkTest(equalTo: 27, on: exp)
        
        wait(for: [exp], timeout: 5)
    }
    
    func testRunOptionalReturningInt() {
        let exp = expectation(description: "intResponse")
        
        cancellable = webView
            .runReturning(named: "intResponse")
            .map { (val: Int?) in
                XCTAssert(type(of: val) == Optional<Int>.self)
                return val
            }
            .eraseToAnyPublisher()
            .sinkTest(equalTo: 27 as Int?, on: exp)
        
        wait(for: [exp], timeout: 5)
    }
    
    func testRunReturningDouble() {
        let exp = expectation(description: "doubleResponse")
        
        cancellable = webView
            .runReturning(named: "doubleResponse")
            .map { (val: Double) in
                XCTAssert(type(of: val) == Double.self)
                return val
            }
            .eraseToAnyPublisher()
            .sinkTest(equalTo: 10.5, on: exp)
        
        wait(for: [exp], timeout: 5)
    }
    
    func testRunOptionalReturningDouble() {
        let exp = expectation(description: "doubleResponse")
        
        cancellable = webView
            .runReturning(named: "doubleResponse")
            .map { (val: Double?) in
                XCTAssert(type(of: val) == Optional<Double>.self)
                return val
            }
            .eraseToAnyPublisher()
            .sinkTest(equalTo: 10.5 as Double?, on: exp)
        
        wait(for: [exp], timeout: 5)
    }
    
    func testRunReturningBool() {
        let exp = expectation(description: "boolResponse")
        
        cancellable = webView
            .runReturning(named: "boolResponse")
            .map { (val: Bool) in
                XCTAssert(type(of: val) == Bool.self)
                return val
            }
            .eraseToAnyPublisher()
            .sinkTest(equalTo: true, on: exp)
        
        wait(for: [exp], timeout: 5)
    }
    
    func testRunOptionalReturningBool() {
        let exp = expectation(description: "boolResponse")
        
        cancellable = webView
            .runReturning(named: "boolResponse")
            .map { (val: Bool?) in
                XCTAssert(type(of: val) == Optional<Bool>.self)
                return val
            }
            .eraseToAnyPublisher()
            .sinkTest(equalTo: true as Bool?, on: exp)
        
        wait(for: [exp], timeout: 5)
    }
    
    func testRunReturningArray() {
        let exp = expectation(description: "arrayResponse")
        
        cancellable = webView
            .runReturning(named: "arrayResponse")
            .map { (val: [Int]) in
                XCTAssert(type(of: val) == [Int].self)
                return val
            }
            .eraseToAnyPublisher()
            .sinkTest(equalTo: [1,2,3,4], on: exp)
        
        wait(for: [exp], timeout: 5)
    }
    
    func testRunOptionalReturningArray() {
        let exp = expectation(description: "arrayResponse")
        
        cancellable = webView
            .runReturning(named: "arrayResponse")
            .map { (val: [Int]?) in
                XCTAssert(type(of: val) == Optional<[Int]>.self)
                return val
            }
            .eraseToAnyPublisher()
            .sinkTest(equalTo: [1,2,3,4] as [Int]?, on: exp)
        
        wait(for: [exp], timeout: 5)
    }
    
    func testRunReturningJSON() {
        let exp = expectation(description: "jsonResponse")
                
        let compare = JSON(name: "tmac", age: 27)
        
        cancellable = webView
            .runReturning(named: "jsonResponse")
            .map { (val: JSON) in
                XCTAssert(type(of: val) == JSON.self)
                return val
            }
            .eraseToAnyPublisher()
            .sinkTest(equalTo: compare, on: exp)
        
        wait(for: [exp], timeout: 5)
    }
    
    func testRunOptionalReturningJSON() {
        let exp = expectation(description: "jsonResponse")
                
        let compare = JSON(name: "tmac", age: 27)
        
        cancellable = webView
            .runReturning(named: "jsonResponse")
            .map { (val: JSON?) in
                XCTAssert(type(of: val) == Optional<JSON>.self)
                return val
            }
            .eraseToAnyPublisher()
            .sinkTest(equalTo: compare as JSON?, on: exp)
        
        wait(for: [exp], timeout: 5)
    }
    
    func testRunReturningContents() {
        let exp = expectation(description: "returnContents")
        
        let compare = JSON(name: "taylor", age: 28)
        
        cancellable = webView
            .runReturning(named: "returnContents", args: [compare])
            .map { (val: JSON) in
                XCTAssert(type(of: val) == JSON.self)
                return val
            }
            .eraseToAnyPublisher()
            .sinkTest(equalTo: compare, on: exp)
        
        wait(for: [exp], timeout: 5)
    }
    
    func testRunReturningData() {
        let exp = expectation(description: "jsonResponse")

        let compare = JSON(name: "tmac", age: 27)
        
        cancellable = webView
            .runReturning(named: "jsonResponse")
            .compactMap { (val: Data) in
                XCTAssert(type(of: val) == Data.self)
                return val
            }
            .eraseToAnyPublisher()
            .decode(type: JSON.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
            .sinkTest(equalTo: compare, on: exp)
        
        wait(for: [exp], timeout: 5)
    }
    
    func testRunReturningFails() {
        let exp = expectation(description: "fails")
        
        cancellable = webView
            .runReturning(named: "fails")
            .sink(receiveCompletion: { result in
                switch result {
                case .finished: XCTFail("should not happen")
                case .failure(let error):
                    XCTAssert(error is JavaScriptError)
                    exp.fulfill()
                }
            }, receiveValue: { (_: [Int]) in
                XCTFail("should not work")
            })
        
        wait(for: [exp], timeout: 5)
    }
    
    func testRunVoid() {
        let exp = expectation(description: "noResponse")
        
        cancellable = webView
            .runVoid(named: "noResponse")
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
            .getVariable(named: "nullable")
            .sinkTest(equalTo: nil as String?, on: exp)
        
        wait(for: [exp], timeout: 5)
    }
    
    func testUndefinedVariableReturnsNull() {
        let exp = expectation(description: "undefinedVarNull")
        
        cancellable = webView
            .getVariable(named: "undefined")
            .sinkTest(equalTo: nil as String?, on: exp)
        
        wait(for: [exp], timeout: 5)
    }
    
    func testNullableVariableReturnsAfterSetting() {
        let exp = expectation(description: "nullVarNonNull")
        
        cancellable = webView
            .getVariable(named: "nullable")
            .map { (str: String?) in XCTAssertNil(str) }
            .flatMap { self.webView.setVariable(named: "nullable", value: "taylor") }
            .flatMap { self.webView.getVariable(named: "nullable") }
            .eraseToAnyPublisher()
            .sinkTest(equalTo: "taylor" as String?, on: exp)
        
        wait(for: [exp], timeout: 5)
    }
    
    func testNullableVariableErrorsOnNullWhenExpecting() {
        let exp = expectation(description: "nullVarNonNullError")
        
        cancellable = webView
            .getVariable(named: "nullable")
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
