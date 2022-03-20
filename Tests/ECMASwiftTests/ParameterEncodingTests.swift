// ParameterEncodingTests.swift
// Copyright © 2022 hiimtmac

import XCTest
@testable import ECMASwift

class ParameterEncodingTests: XCTestCase {
    func testString() {
        let param = "hello".jsEncode()
        XCTAssertEqual(param, #""hello""#)
    }

    func testInt() {
        let param = 1.jsEncode()
        XCTAssertEqual(param, "1")
    }

    func testDouble() {
        let param = 2.5.jsEncode()
        XCTAssertEqual(param, "2.5")
    }

    func testBool() {
        let param = true.jsEncode()
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
