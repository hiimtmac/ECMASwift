//
//  EvaluateWeakTests.swift
//  ECMASwiftTests
//
//  Created by Taylor McIntyre on 2019-07-03.
//  Copyright © 2019 hiimtmac. All rights reserved.
//

import XCTest
import Combine
@testable import ECMASwift

class EvaluateWeakTestsCombine: ECMASwiftTestCase {
    
    func testGetStringVar() {
        let exp = expectation(description: "string")
        
        cancellable = webView
            .evaluateJavaScript("string;", as: String.self)
            .sinkTest(equalTo: "taylor", on: exp)
        
        wait(for: [exp], timeout: 5)
    }
    
    func testGetIntVar() {
        let exp = expectation(description: "int")
        
        cancellable = webView
            .evaluateJavaScript("int;", as: Int.self)
            .sinkTest(equalTo: 27, on: exp)
        
        wait(for: [exp], timeout: 5)
    }
    
    func testGetDoubleVar() {
        let exp = expectation(description: "double")
        
        cancellable = webView
            .evaluateJavaScript("double;", as: Double.self)
            .sinkTest(equalTo: 10.5, on: exp)
        
        wait(for: [exp], timeout: 5)
    }
    
    func testGetBoolVar() {
        let exp = expectation(description: "bool")
        
        cancellable = webView
            .evaluateJavaScript("bool;", as: Bool.self)
            .sinkTest(equalTo: true, on: exp)
        
        wait(for: [exp], timeout: 5)
    }
    
    func testGetArrayVar() {
        let exp = expectation(description: "array")
        
        cancellable = webView
            .evaluateJavaScript("array;", as: [Int].self)
            .sinkTest(equalTo: [1,2,3,4], on: exp)
        
        wait(for: [exp], timeout: 5)
    }
    
    func testGetJSONVar() {
        let exp = expectation(description: "json")
        
        struct JSON: Codable, Equatable {
            let name: String
            let age: Int
        }
        
        let compare = JSON(name: "tmac", age: 27)
        
        cancellable = webView
            .evaluateJavaScript("json;", as: JSON.self)
            .sinkTest(equalTo: compare, on: exp)
        
        wait(for: [exp], timeout: 5)
    }
    
    
    func testGetDataVar() {
        let exp = expectation(description: "json")
        
        struct JSON: Codable, Equatable {
            let name: String
            let age: Int
        }
        
        let compare = JSON(name: "tmac", age: 27)
        
        cancellable = webView
            .evaluateJavaScript("json;", as: Data.self)
            .decode(type: JSON.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
            .sinkTest(equalTo: compare, on: exp)
        
        wait(for: [exp], timeout: 5)
    }
    
    func testGetStringFunc() {
        let exp = expectation(description: "stringResponse")
        
        cancellable = webView
            .evaluateJavaScript("stringResponse();", as: String.self)
            .sinkTest(equalTo: "taylor", on: exp)
        
        wait(for: [exp], timeout: 5)
    }
    
    func testGetIntFunc() {
        let exp = expectation(description: "intResponse")
        
        cancellable = webView
            .evaluateJavaScript("intResponse();", as: Int.self)
            .sinkTest(equalTo: 27, on: exp)
        
        wait(for: [exp], timeout: 5)
    }
    
    func testGetDoubleFunc() {
        let exp = expectation(description: "doubleResponse")
        
        cancellable = webView
            .evaluateJavaScript("doubleResponse();", as: Double.self)
            .sinkTest(equalTo: 10.5, on: exp)
        
        wait(for: [exp], timeout: 5)
    }
    
    func testGetBoolFunc() {
        let exp = expectation(description: "boolResponse")
        
        cancellable = webView
            .evaluateJavaScript("boolResponse();", as: Bool.self)
            .sinkTest(equalTo: true, on: exp)
        
        wait(for: [exp], timeout: 5)
    }
    
    func testGetArrayFunc() {
        let exp = expectation(description: "arrayResponse")
        
        cancellable = webView
            .evaluateJavaScript("arrayResponse();", as: [Int].self)
            .sinkTest(equalTo: [1,2,3,4], on: exp)
        
        wait(for: [exp], timeout: 5)
    }
    
    func testGetJSONFunc() {
        let exp = expectation(description: "jsonResponse")
        
        struct JSON: Codable, Equatable {
            let name: String
            let age: Int
        }
        
        let compare = JSON(name: "tmac", age: 27)
        
        cancellable = webView
            .evaluateJavaScript("jsonResponse();", as: JSON.self)
            .sinkTest(equalTo: compare, on: exp)
        
        wait(for: [exp], timeout: 5)
    }
    
    func testGetDataFunc() {
        let exp = expectation(description: "jsonResponse")
        
        struct JSON: Codable, Equatable {
            let name: String
            let age: Int
        }
        
        let compare = JSON(name: "tmac", age: 27)
        
        cancellable = webView
            .evaluateJavaScript("jsonResponse();", as: Data.self)
            .decode(type: JSON.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
            .sinkTest(equalTo: compare, on: exp)
        
        wait(for: [exp], timeout: 5)
    }
    
    func testGetFails() {
        let exp = expectation(description: "fails")
        
        cancellable = webView
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
}
