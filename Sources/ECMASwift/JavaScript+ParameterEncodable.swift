//
//  JavaScriptParameterEncodable.swift
//  ECMASwift
//
//  Created by Taylor McIntyre on 2019-07-03.
//  Copyright © 2019 hiimtmac. All rights reserved.
//

import Foundation

public protocol JavaScriptParameterEncodable {
    func jsEncode() throws -> String
}

extension JavaScriptParameterEncodable where Self: Encodable {
    public func jsEncode() throws -> String {
        let content = try JSONEncoder().encode(self)
        return String(decoding: content, as: UTF8.self)
    }
}

extension String: JavaScriptParameterEncodable {
    public func jsEncode() throws -> String {
        return #""\#(self)""#
    }
}
extension Int: JavaScriptParameterEncodable {
    public func jsEncode() throws -> String {
        return "\(self)"
    }
}
extension Double: JavaScriptParameterEncodable {
    public func jsEncode() throws -> String {
        return "\(self)"
    }
}
extension Bool: JavaScriptParameterEncodable {
    public func jsEncode() throws -> String {
        return "\(self)"
    }
}

extension Array: JavaScriptParameterEncodable where Element: JavaScriptParameterEncodable {
    public func jsEncode() throws -> String {
        let joins = try self
            .map { try $0.jsEncode() }
            .joined(separator: ", ")
        return "[\(joins)]"
    }
}
