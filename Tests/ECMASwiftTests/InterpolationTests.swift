// InterpolationTests.swift
// Copyright © 2022 hiimtmac

import XCTest
@testable import ECMASwift

class InterpolationTests: XCTestCase {
    struct Test: Codable, JavaScriptParameterEncodable {
        let name: String
        let age: Int
    }

    func testObjectInterpolation() {
        let object = Test(name: "taylor", age: 28)

        let string = "var cool = \(asJS: object);"
        let compare = #"var cool = {"name":"taylor","age":28};"#
        XCTAssertEqual(string, compare)
    }

    func testStringInterpolation() {
        let object = "hello"
        let string = "var cool = \(asJS: object);"
        let compare = #"var cool = "hello";"#
        XCTAssertEqual(string, compare)
    }

    func testIntInterpolation() {
        let object = 8
        let string = "var cool = \(asJS: object);"
        let compare = #"var cool = 8;"#
        XCTAssertEqual(string, compare)
    }

    func testRegularStringFails() {
        let object = "hello"
        let string = "var cool = \(object);"
        let compare = #"var cool = "hello";"#
        XCTAssertNotEqual(string, compare)
    }
}
