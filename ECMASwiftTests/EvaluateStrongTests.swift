//
//  EvaluateStongTests.swift
//  ECMASwiftTests
//
//  Created by Taylor McIntyre on 2019-07-03.
//  Copyright © 2019 hiimtmac. All rights reserved.
//

import XCTest
import PromiseKit
@testable import ECMASwift

class EvaluateStrongTests: ECMASwiftTestCase {

    func testStringVar() {
        let exp = expectation(description: "string")
        
        firstly {
            webView.getVariable(named: "string", as: String.self)
        }.get {
            XCTAssertEqual($0, "taylor")
        }.then { _ in
            self.webView.setVariable(named: "string", value: "hello!")
        }.then {
            self.webView.getVariable(named: "string", as: String.self)
        }.get {
            XCTAssertEqual($0, "hello!")
            exp.fulfill()
        }.catch {
            XCTFail($0.localizedDescription)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5)
    }
    
    func testIntVar() {
        let exp = expectation(description: "int")
        
        firstly {
            webView.getVariable(named: "int", as: Int.self)
        }.get {
            XCTAssertEqual($0, 27)
        }.then { _ in
            self.webView.setVariable(named: "int", value: 37)
        }.then {
            self.webView.getVariable(named: "int", as: Int.self)
        }.get {
            XCTAssertEqual($0, 37)
            exp.fulfill()
        }.catch {
            XCTFail($0.localizedDescription)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5)
    }
    
    func testDoubleVar() {
        let exp = expectation(description: "double")
        
        firstly {
            webView.getVariable(named: "double", as: Double.self)
        }.get {
            XCTAssertEqual($0, 10.5)
        }.then { _ in
            self.webView.setVariable(named: "double", value: 26.6)
        }.then {
            self.webView.getVariable(named: "double", as: Double.self)
        }.get {
            XCTAssertEqual($0, 26.6)
            exp.fulfill()
        }.catch {
            XCTFail($0.localizedDescription)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5)
    }
    
    func testBoolVar() {
        let exp = expectation(description: "bool")
        
        firstly {
            webView.getVariable(named: "bool", as: Bool.self)
        }.get {
            XCTAssertEqual($0, true)
        }.then { _ in
            self.webView.setVariable(named: "bool", value: false)
        }.then {
            self.webView.getVariable(named: "bool", as: Bool.self)
        }.get {
            XCTAssertEqual($0, false)
            exp.fulfill()
        }.catch {
            XCTFail($0.localizedDescription)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5)
    }
    
    func testArrayVar() {
        let exp = expectation(description: "array")
        
        firstly {
            webView.getVariable(named: "array", as: [Int].self)
        }.get {
            XCTAssertEqual($0, [1, 2, 3, 4])
        }.then { _ in
            self.webView.setVariable(named: "array", value: [5, 6, 7, 8])
        }.then {
            self.webView.getVariable(named: "array", as: [Int].self)
        }.get {
            XCTAssertEqual($0, [5, 6, 7, 8])
            exp.fulfill()
        }.catch {
            XCTFail($0.localizedDescription)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5)
    }
    
    func testJSONVar() {
        let exp = expectation(description: "json")
        
        struct JSON: Codable, JavaScriptParameterEncodable {
            let name: String
            let age: Int
        }
        
        firstly {
            webView.getVariable(named: "json", as: JSON.self)
        }.get {
            XCTAssertEqual($0.name, "tmac")
            XCTAssertEqual($0.age, 27)
        }.then { _ in
            self.webView.setVariable(named: "json", value: JSON(name: "taylor", age: 37))
        }.then {
            self.webView.getVariable(named: "json", as: JSON.self)
        }.get {
            XCTAssertEqual($0.name, "taylor")
            XCTAssertEqual($0.age, 37)
            exp.fulfill()
        }.catch {
            XCTFail($0.localizedDescription)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5)
    }
    
    func testDataVar() {
        let exp = expectation(description: "json")
        
        struct JSON: Codable, JavaScriptParameterEncodable {
            let name: String
            let age: Int
        }
        
        firstly {
            webView.getVariable(named: "json", as: Data.self)
        }.map {
            return try JSONDecoder().decode(JSON.self, from: $0)
        }.get {
            XCTAssertEqual($0.name, "tmac")
            XCTAssertEqual($0.age, 27)
        }.then { _ in
            self.webView.setVariable(named: "json", value: JSON(name: "taylor", age: 37))
        }.then {
            self.webView.getVariable(named: "json", as: JSON.self)
        }.get {
            XCTAssertEqual($0.name, "taylor")
            XCTAssertEqual($0.age, 37)
            exp.fulfill()
        }.catch {
            XCTFail($0.localizedDescription)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5)
    }
    
    func testRunReturningString() {
        let exp = expectation(description: "stringResponse")
        
        firstly {
            webView.runReturning(named: "stringResponse", as: String.self)
        }.get {
            XCTAssertEqual($0, "taylor")
            exp.fulfill()
        }.catch {
            XCTFail($0.localizedDescription)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5)
    }
    
    func testRunReturningInt() {
        let exp = expectation(description: "intResponse")
        
        firstly {
            webView.runReturning(named: "intResponse", as: Int.self)
        }.get {
            XCTAssertEqual($0, 27)
            exp.fulfill()
        }.catch {
            XCTFail($0.localizedDescription)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5)
    }
    
    func testRunReturningDouble() {
        let exp = expectation(description: "doubleResponse")
        
        firstly {
            webView.runReturning(named: "doubleResponse", as: Double.self)
        }.get {
            XCTAssertEqual($0, 10.5)
            exp.fulfill()
        }.catch {
            XCTFail($0.localizedDescription)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5)
    }
    
    func testRunReturningBool() {
        let exp = expectation(description: "boolResponse")
        
        firstly {
            webView.runReturning(named: "boolResponse", as: Bool.self)
        }.get {
            XCTAssertEqual($0, true)
            exp.fulfill()
        }.catch {
            XCTFail($0.localizedDescription)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5)
    }
    
    func testRunReturningArray() {
        let exp = expectation(description: "arrayResponse")
        
        firstly {
            webView.runReturning(named: "arrayResponse", as: [Int].self)
        }.get {
            XCTAssertEqual($0, [1, 2, 3, 4])
            exp.fulfill()
        }.catch {
            XCTFail($0.localizedDescription)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5)
    }
    
    func testRunReturningJSON() {
        let exp = expectation(description: "jsonResponse")
        
        struct JSON: Codable {
            let name: String
            let age: Int
        }
        
        firstly {
            webView.runReturning(named: "jsonResponse", as: JSON.self)
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
    
    func testRunReturningContents() {
        let exp = expectation(description: "returnContents")
        
        struct JSON: Codable, JavaScriptParameterEncodable {
            let name: String
            let age: Int
        }
        
        let json = JSON(name: "tmac", age: 28)
        
        firstly {
            webView.runReturning(named: "returnContents", args: [json], as: JSON.self)
        }.get {
            XCTAssertEqual($0.name, "tmac")
            XCTAssertEqual($0.age, 28)
            exp.fulfill()
        }.catch {
            XCTFail($0.localizedDescription)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5)
    }
    
    func testRunReturningData() {
        let exp = expectation(description: "jsonResponse")
        
        struct JSON: Codable {
            let name: String
            let age: Int
        }
        
        firstly {
            webView.runReturning(named: "jsonResponse", as: Data.self)
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
    
    func testRunReturningFails() {
        let exp = expectation(description: "fails")
        
        firstly {
            webView.runReturning(named: "fails", as: [Int].self)
        }.get { _ in
            XCTFail("should not work")
            exp.fulfill()
        }.catch {
            XCTAssert($0 is JavaScriptError)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5)
    }
    
    func testRunVoid() {
        let exp = expectation(description: "noResponse")
        
        firstly {
            webView.runVoid(named: "noResponse")
        }.done {
            exp.fulfill()
        }.catch {
            XCTFail($0.localizedDescription)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5)
    }

}