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
            .getVariable(named: "string", as: String.self)
            .map { XCTAssertEqual($0, "taylor") }
            .flatMap { self.webView.setVariable(named: "string", value: "hello!") }
            .flatMap { self.webView.getVariable(named: "string", as: String.self) }
            .eraseToAnyPublisher()
            .sinkTest(equalTo: "hello!", on: exp)
        
        wait(for: [exp], timeout: 5)
    }
    
    func testIntVar() {
        let exp = expectation(description: "int")
        
        cancellable = webView
            .getVariable(named: "int", as: Int.self)
            .map { XCTAssertEqual($0, 27) }
            .flatMap { self.webView.setVariable(named: "int", value: 37) }
            .flatMap { self.webView.getVariable(named: "int", as: Int.self) }
            .eraseToAnyPublisher()
            .sinkTest(equalTo: 37, on: exp)
        
        wait(for: [exp], timeout: 5)
    }
    
    func testDoubleVar() {
        let exp = expectation(description: "double")
        
        cancellable = webView
            .getVariable(named: "double", as: Double.self)
            .map { XCTAssertEqual($0, 10.5) }
            .flatMap { self.webView.setVariable(named: "double", value: 26.6) }
            .flatMap { self.webView.getVariable(named: "double", as: Double.self) }
            .eraseToAnyPublisher()
            .sinkTest(equalTo: 26.6, on: exp)
        
        wait(for: [exp], timeout: 5)
    }
    
    func testBoolVar() {
        let exp = expectation(description: "bool")
        
        cancellable = webView
            .getVariable(named: "bool", as: Bool.self)
            .map { XCTAssertEqual($0, true) }
            .flatMap { self.webView.setVariable(named: "bool", value: false) }
            .flatMap { self.webView.getVariable(named: "bool", as: Bool.self) }
            .eraseToAnyPublisher()
            .sinkTest(equalTo: false, on: exp)
        
        wait(for: [exp], timeout: 5)
    }
    
    func testArrayVar() {
        let exp = expectation(description: "array")
        
        cancellable = webView
            .getVariable(named: "array", as: [Int].self)
            .map { XCTAssertEqual($0, [1, 2, 3, 4]) }
            .flatMap { self.webView.setVariable(named: "array", value: [5, 6, 7, 8]) }
            .flatMap { self.webView.getVariable(named: "array", as: [Int].self) }
            .eraseToAnyPublisher()
            .sinkTest(equalTo: [5,6,7,8], on: exp)
        
        wait(for: [exp], timeout: 5)
    }
    
    func testJSONVar() {
        let exp = expectation(description: "json")
                
        struct JSON: Codable, JavaScriptParameterEncodable, Equatable {
            let name: String
            let age: Int
        }
        
        let compare = JSON(name: "taylor", age: 37)
        
        cancellable = webView
            .getVariable(named: "json", as: JSON.self)
            .map {
                XCTAssertEqual($0.name, "tmac")
                XCTAssertEqual($0.age, 27)
            }
            .flatMap { self.webView.setVariable(named: "json", value: JSON(name: "taylor", age: 37)) }
            .flatMap { self.webView.getVariable(named: "json", as: JSON.self) }
            .eraseToAnyPublisher()
            .sinkTest(equalTo: compare, on: exp)
        
        wait(for: [exp], timeout: 5)
    }
    
    func testDataVar() {
        let exp = expectation(description: "json")
                
        struct JSON: Codable, JavaScriptParameterEncodable, Equatable {
            let name: String
            let age: Int
        }
        
        let compare = JSON(name: "taylor", age: 37)
        
        cancellable = webView
            .getVariable(named: "json", as: Data.self)
            .decode(type: JSON.self, decoder: JSONDecoder())
            .map {
                XCTAssertEqual($0.name, "tmac")
                XCTAssertEqual($0.age, 27)
            }
            .flatMap { self.webView.setVariable(named: "json", value: JSON(name: "taylor", age: 37)) }
            .flatMap { self.webView.getVariable(named: "json", as: JSON.self) }
            .eraseToAnyPublisher()
            .sinkTest(equalTo: compare, on: exp)
        
        wait(for: [exp], timeout: 5)
    }
    
    func testRunReturningString() {
        let exp = expectation(description: "stringResponse")
        
        cancellable = webView
            .runReturning(named: "stringResponse", as: String.self)
            .sinkTest(equalTo: "taylor", on: exp)
        
        wait(for: [exp], timeout: 5)
    }
    
    func testRunReturningInt() {
        let exp = expectation(description: "intResponse")
        
        cancellable = webView
            .runReturning(named: "intResponse", as: Int.self)
            .sinkTest(equalTo: 27, on: exp)
        
        wait(for: [exp], timeout: 5)
    }
    
    func testRunReturningDouble() {
        let exp = expectation(description: "doubleResponse")
        
        cancellable = webView
            .runReturning(named: "doubleResponse", as: Double.self)
            .sinkTest(equalTo: 10.5, on: exp)
        
        wait(for: [exp], timeout: 5)
    }
    
    func testRunReturningBool() {
        let exp = expectation(description: "boolResponse")
        
        cancellable = webView
            .runReturning(named: "boolResponse", as: Bool.self)
            .sinkTest(equalTo: true, on: exp)
        
        wait(for: [exp], timeout: 5)
    }
    
    func testRunReturningArray() {
        let exp = expectation(description: "arrayResponse")
        
        cancellable = webView
            .runReturning(named: "arrayResponse", as: [Int].self)
            .sinkTest(equalTo: [1,2,3,4], on: exp)
        
        wait(for: [exp], timeout: 5)
    }
    
    func testRunReturningJSON() {
        let exp = expectation(description: "jsonResponse")
                
        struct JSON: Codable, Equatable {
            let name: String
            let age: Int
        }
        
        let compare = JSON(name: "tmac", age: 27)
        
        cancellable = webView
            .runReturning(named: "jsonResponse", as: JSON.self)
            .sinkTest(equalTo: compare, on: exp)
        
        wait(for: [exp], timeout: 5)
    }
    
    func testRunReturningContents() {
        let exp = expectation(description: "returnContents")
        
        struct JSON: Codable, JavaScriptParameterEncodable, Equatable {
            let name: String
            let age: Int
        }
        
        let compare = JSON(name: "taylor", age: 28)
        
        cancellable = webView
            .runReturning(named: "returnContents", args: [compare], as: JSON.self)
            .sinkTest(equalTo: compare, on: exp)
        
        wait(for: [exp], timeout: 5)
    }
    
    func testRunReturningData() {
        let exp = expectation(description: "jsonResponse")
                
        struct JSON: Codable, Equatable {
            let name: String
            let age: Int
        }
        
        let compare = JSON(name: "tmac", age: 27)
        
        cancellable = webView
            .runReturning(named: "jsonResponse", as: Data.self)
            .decode(type: JSON.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
            .sinkTest(equalTo: compare, on: exp)
        
        wait(for: [exp], timeout: 5)
    }
    
    func testRunReturningFails() {
        let exp = expectation(description: "fails")
        
        cancellable = webView
            .runReturning(named: "fails", as: [Int].self)
            .sink(receiveCompletion: { result in
                switch result {
                case .finished: XCTFail("should not happen")
                case .failure(let error):
                    XCTAssert(error is JavaScriptError)
                    exp.fulfill()
                }
            }, receiveValue: { _ in
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

}
