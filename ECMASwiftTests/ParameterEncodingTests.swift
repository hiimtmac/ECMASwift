//
//  ParameterEncodingTests.swift
//  ECMASwiftTests
//
//  Created by Taylor McIntyre on 2019-07-03.
//  Copyright © 2019 hiimtmac. All rights reserved.
//

import XCTest
@testable import ECMASwift

class ParameterEncodingTests: XCTestCase {

    func testString() throws {
        let param = try "hello".jsEncode()
        XCTAssertEqual(param, #""hello""#)
    }
    
    func testInt() throws {
        let param = try 1.jsEncode()
        XCTAssertEqual(param, "1")
    }
    
    func testDouble() throws {
        let param = try 2.5.jsEncode()
        XCTAssertEqual(param, "2.5")
    }
    
    func testBool() throws {
        let param = try true.jsEncode()
        XCTAssertEqual(param, "true")
    }
    
    func testEncodable() throws {
        struct JSON: Codable, JavaScriptParameterEncodable {
            let name: String
            let age: Int
        }
        
        let param = try JSON(name: "tmac", age: 27).jsEncode()
        XCTAssertEqual(param, #"{"name":"tmac","age":27}"#)
    }
    
    func testArray() throws {
        let param = try [1, 2, 3, 4].jsEncode()
        XCTAssertEqual(param, "[1, 2, 3, 4]")
    }
}
