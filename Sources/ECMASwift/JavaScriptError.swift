// JavaScriptError.swift
// Copyright © 2022 hiimtmac

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
        case let .invalidCallingConvention(message): return "Invalid Calling Convention: \(message)"
        case let .unexpectedResult(message): return "Unexpected Result: \(message)"
        case let .encodingError(message): return "Encoding Error: \(message)"
        case let .decodingError(message): return "Decoding Error: \(message)"
        case let .javascriptException(message, line, column): return "Javascript Exception: \(message) (line: \(line), column: \(column))"
        case .unknown: return "Unknown"
        }
    }
}
