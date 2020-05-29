//
//  JavaScript+StringInterpolation.swift
//  ECMASwift
//
//  Created by Taylor McIntyre on 2019-07-03.
//  Copyright © 2019 hiimtmac. All rights reserved.
//

import Foundation

public extension String.StringInterpolation {
    /// Interpolates object as javascript friendly representation
    /// - Parameter asJS: javscript value to encode
    /// - Warning: This will silently fail if encoding fails
    mutating func appendInterpolation<T>(asJS: T) where T: JavaScriptParameterEncodable {
        guard let encoded = try? asJS.jsEncode() else {
            assertionFailure("Could not encode")
            return
        }
        
        appendLiteral(encoded)
    }
}
