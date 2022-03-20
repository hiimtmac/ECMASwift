// JavaScript+StringInterpolation.swift
// Copyright © 2022 hiimtmac

import Foundation

extension String.StringInterpolation {
    /// Interpolates object as javascript friendly representation
    /// - Parameter asJS: javscript value to encode
    /// - Warning: This will silently fail if encoding fails
    public mutating func appendInterpolation<T>(asJS: T) where T: JavaScriptParameterEncodable {
        guard let encoded = try? asJS.jsEncode() else {
            assertionFailure("Could not encode")
            return
        }

        appendLiteral(encoded)
    }
}
