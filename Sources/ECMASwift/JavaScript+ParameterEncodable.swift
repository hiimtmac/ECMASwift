// JavaScript+ParameterEncodable.swift
// Copyright © 2022 hiimtmac

import Foundation

public protocol JavaScriptParameterEncodable {
    func jsEncode() throws -> String
}

extension JavaScriptParameterEncodable where Self: Encodable {
    public func jsEncode() throws -> String {
        do {
            let content = try JSONEncoder().encode(self)
            return String(decoding: content, as: UTF8.self)
        } catch {
            throw JavaScriptError.encodingError(message: "Could not encode \(self)")
        }
    }
}

extension String: JavaScriptParameterEncodable {
    public func jsEncode() -> String {
        return #""\#(self)""#
    }
}

extension Int: JavaScriptParameterEncodable {
    public func jsEncode() -> String {
        return "\(self)"
    }
}

extension Double: JavaScriptParameterEncodable {
    public func jsEncode() -> String {
        return "\(self)"
    }
}

extension Bool: JavaScriptParameterEncodable {
    public func jsEncode() -> String {
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
