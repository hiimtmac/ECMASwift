// WKWebView+Combine.swift
// Copyright © 2022 hiimtmac

import Foundation

extension AnyPublisher {
    /// Sinks publisher into a `Result<Output, Failure>` object such that `.finished` case does not have to be handled
    /// - Parameter completion: result handler
    /// - Returns: cancellable
    public func resolve(completion: @escaping (Result<Output, Failure>) -> Void) -> AnyCancellable {
        sink(receiveCompletion: { res in
            switch res {
            case .finished: break
            case let .failure(error): completion(.failure(error))
            }
        }, receiveValue: {
            completion(.success($0))
        })
    }
}

extension WKWebView {
    func evaluateJavaScript(_ javaScriptString: String) -> AnyPublisher<Any?, Error> {
        Future<Any?, Error> { promise in
            self.evaluateJavaScript(javaScriptString, completionHandler: { any, error in
                if let error = error {
                    if let jsError = JavaScriptError(error: error) {
                        promise(.failure(jsError))
                    } else {
                        promise(.failure(error))
                    }
                } else {
                    promise(.success(any))
                }
            })
        }
        .eraseToAnyPublisher()
    }
}

extension WKWebView {
    /// Runs a void operation on the webview
    /// - Parameter javaScriptString: javascript string to run (this is not js escaped)
    /// - Returns: Void publisher
    public func evaluateJavaScript(_ javaScriptString: String) -> AnyPublisher<Void, Error> {
        self.evaluateJavaScript(javaScriptString)
            // need to explicitly state `(any: Any?)` otherwise calls itself
            .tryMap { (any: Any?) in
                // void function should not return anything
                guard any == nil else {
                    throw JavaScriptError.invalidCallingConvention(message: "Returned value from expected void.")
                }
            }
            .eraseToAnyPublisher()
    }

    /// Runs an operation returning `T` on the webview
    /// - Parameters:
    ///   - javaScriptString: javascript string to run (this is not js escaped)
    ///   - as: desired type to return to attempt decoding
    /// - Returns: T publisher
    public func evaluateJavaScript<T: Decodable>(_ javaScriptString: String) -> AnyPublisher<T, Error> {
        self.evaluateJavaScript(javaScriptString)
            .tryMap { (any: Any?) in

                // check if `T` is actually `Optional<T>`
                if let valueType = T.self as? AnyOptionalType.Type {
                    // check is `any is NSNull` -> null
                    if any is NSNull {
                        return valueType.nil as! T
                    }

                    // check if `any == nil` -> undefined
                    if let value = any {
                        return try self.decode(value, as: T.self, scalarBase: valueType.wrappedType)
                    } else {
                        return valueType.nil as! T
                    }
                }

                guard let value = any else {
                    throw JavaScriptError.decodingError(message: "Expected value and received nothing")
                }

                return try self.decode(value, as: T.self, scalarBase: T.self)
            }
            .eraseToAnyPublisher()
    }

    public func decode<T: Decodable>(_ value: Any, as _: T.Type, scalarBase: Any.Type) throws -> T {
        switch scalarBase.self {
        case
            is String.Type, is [String].Type,
            is Int.Type, is [Int].Type,
            is Double.Type, is [Double].Type,
            is Float.Type, is [Float].Type,
            is Bool.Type, is [Bool].Type
            :
            if let val = value as? T {
                return val
            } else {
                throw JavaScriptError.decodingError(message: "value is not scalar \(T.self)")
            }
        case is Data.Type:
            let encoded = try JSONSerialization.data(withJSONObject: value, options: [])
            return encoded as! T
        default:
            let encoded = try JSONSerialization.data(withJSONObject: value, options: [])
            return try JSONDecoder().decode(T.self, from: encoded)
        }
    }
}

extension WKWebView {
    /// Returns value of javascript variable from webview
    ///
    /// This method does the work of encoding the javascript (ie `;`) and attempts to
    /// decode the specified type when it returns
    ///
    /// - Parameters:
    ///   - named: name of variable
    ///   - type: desired type to return to attempt decoding
    /// - Returns: `T` publisher
    public func getVariable<T: Decodable>(named: String) -> AnyPublisher<T, Error> {
        self.evaluateJavaScript("\(named);")
    }

    /// Sets the value of javascript variable from webview
    ///
    /// This method does the work of encoding the javascript (ie `;` and making swift
    /// types javascript friendly) and attempts to decode the specified type when it returns
    ///
    /// - Parameters:
    ///   - named: name of variable
    ///   - value: value set the variable to
    /// - Returns: Void publisher
    public func setVariable(named: String, value: JavaScriptParameterEncodable) -> AnyPublisher<Void, Error> {
        Result {
            try "\(named) = \(value.jsEncode());"
        }
        .publisher
        .flatMap { self.evaluateJavaScript($0) }
        .map { (_: Any?) in () }
        .eraseToAnyPublisher()
    }

    /// Run javascript void function
    ///
    /// This method does the work of encoding the arguments (ie `;` and making swift
    /// types javascript friendly)
    ///
    /// - Parameters:
    ///   - named: Name of the function
    ///   - args: Arguments to the function
    /// - Returns: Void publisher
    /// - Warning: This will return with an error if the method actually returns any value
    public func runVoid(named: String, args: [JavaScriptParameterEncodable] = []) -> AnyPublisher<Void, Error> {
        Result {
            let params = try args
                .map { try $0.jsEncode() }
                .joined(separator: ", ")

            return "\(named)(\(params));"
        }
        .publisher
        .flatMap { self.evaluateJavaScript($0) }
        .eraseToAnyPublisher()
    }

    /// Runs javascript function with return value
    ///
    /// This method does the work of encoding the arguments (ie `;` and making swift
    /// types javascript friendly) and attempts to decode the specified type when it returns
    ///
    /// - Parameters:
    ///   - named: Name of the function
    ///   - args: Arguments to the function
    ///   - type: desired type to return to attempt decoding
    /// - Returns: `T` publisher
    public func runReturning<T: Decodable>(named: String, args: [JavaScriptParameterEncodable] = []) -> AnyPublisher<T, Error> {
        Result {
            let params = try args
                .map { try $0.jsEncode() }
                .joined(separator: ", ")

            return "\(named)(\(params));"
        }
        .publisher
        .flatMap { self.evaluateJavaScript($0) }
        .eraseToAnyPublisher()
    }
}
