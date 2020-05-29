//
//  JavaScriptError.swift
//  ECMASwift
//
//  Created by Taylor McIntyre on 2019-07-03.
//  Copyright © 2019 hiimtmac. All rights reserved.
//

import Foundation

let kExceptionMessage = "WKJavaScriptExceptionMessage"
let kExceptionLine = "WKJavaScriptExceptionLineNumber"
let kExceptionColumn = "WKJavaScriptExceptionColumnNumber"

public enum JavaScriptError: Error {
    case invalidCallingConvention(message: String)
    case unknown
    case unexpectedResult(message: String)
    case encodingError(message: String)
    case decodingError(message: String)
    case javascriptException(message: String, line: Int, column: Int)
}

extension JavaScriptError {
    public init?(error: Error) {
        let nserror = error as NSError
        switch nserror.code {
        case 4:
            let message = nserror.userInfo[kExceptionMessage] as? String ?? "message"
            let line = nserror.userInfo[kExceptionLine] as? Int ?? 0
            let column = nserror.userInfo[kExceptionColumn] as? Int ?? 0
            self = .javascriptException(message: message, line: line, column: column)
        default: return nil
        }
    }
}

extension JavaScriptError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidCallingConvention(let message): return "Invalid Calling Convention: \(message)"
        case .unexpectedResult(let message): return "Unexpected Result: \(message)"
        case .encodingError(let message): return "Encoding Error: \(message)"
        case .decodingError(let message): return "Decoding Error: \(message)"
        case .javascriptException(let message, let line, let column): return "Javascript Exception: \(message) (line: \(line), column: \(column))"
        case .unknown: return "Unknown"
        }
    }
}
