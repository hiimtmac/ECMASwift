//
//  JavaScript+StringInterpolation.swift
//  ECMASwift
//
//  Created by Taylor McIntyre on 2019-07-03.
//  Copyright © 2019 hiimtmac. All rights reserved.
//

import Foundation

public extension String.StringInterpolation {
    mutating func appendInterpolation<T: JavaScriptParameterEncodable>(asJS: T) {
        guard let encoded = try? asJS.jsEncode() else {
            assertionFailure("Could not encode")
            return
        }
        
        appendLiteral(encoded)
    }
}
