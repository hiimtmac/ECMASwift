//
//  WKWebView+Combine.swift
//  ECMASwift
//
//  Created by Taylor McIntyre on 2019-10-15.
//  Copyright © 2019 hiimtmac. All rights reserved.
//

import Foundation
import WebKit
import Combine

enum ECMAError: Error {
    case invalidCallingConvention
}

extension AnyPublisher {
    public func resolve(completion: @escaping (Swift.Result<Output, Failure>) -> Void) -> AnyCancellable {
        return sink(receiveCompletion: { res in
            switch res {
            case .finished: break
            case .failure(let error): completion(.failure(error))
            }
        }, receiveValue: {
            completion(.success($0))
        })
    }
}

extension WKWebView {
    func evaluateJavaScript(_ javaScriptString: String) -> AnyPublisher<Any, Error> {
        return Future<Any, Error> { promise in
            self.evaluateJavaScript(javaScriptString, completionHandler: { (any, error) in
                if let error = error {
                    if let jsError = JavaScriptError(error: error) {
                        promise(.failure(jsError))
                    } else {
                        promise(.failure(error))
                    }
                } else if let any = any {
                    promise(.success(any))
                } else {
                    promise(.failure(ECMAError.invalidCallingConvention))
                }
            })
        }.eraseToAnyPublisher()
    }
}

public extension WKWebView {
    func evaluateJavaScript(_ javaScriptString: String) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            self.evaluateJavaScript(javaScriptString, completionHandler: { (any, error) in
                if let error = error {
                    if let jsError = JavaScriptError(error: error) {
                        promise(.failure(jsError))
                    } else {
                        promise(.failure(error))
                    }
                } else if any != nil {
                    promise(.failure(ECMAError.invalidCallingConvention))
                } else {
                    promise(.success(()))
                }
            })
        }.eraseToAnyPublisher()
    }
    
    func evaluateJavaScript<T: Decodable>(_ javaScriptString: String, as: T.Type) -> AnyPublisher<T, Error> {
        return evaluateJavaScript(javaScriptString)
            .tryMap { (any: Any) in
                switch T.self {
                case
                is String.Type, is [String].Type,
                is Int.Type, is [Int].Type,
                is Double.Type, is [Double].Type,
                is Float.Type, is [Float].Type,
                is Bool.Type, is [Bool].Type
                    :
                    if let val = any as? T {
                        return val
                    } else {
                        throw JavaScriptError.decodingError(message: "value is not \(T.self)")
                    }
                case is Data.Type:
                    let encoded = try JSONSerialization.data(withJSONObject: any, options: [])
                    return encoded as! T
                default:
                    let encoded = try JSONSerialization.data(withJSONObject: any, options: [])
                    return try JSONDecoder().decode(T.self, from: encoded)
                }
        }.eraseToAnyPublisher()
    }
}

public extension WKWebView {
    func getVariable<T: Decodable>(named: String, as type: T.Type) -> AnyPublisher<T, Error> {
        return evaluateJavaScript("\(named);", as: type)
    }
    
    func setVariable(named: String, value: JavaScriptParameterEncodable) -> AnyPublisher<Void, Error> {
        do {
            let javaScript = try "\(named) = \(value.jsEncode());"
            return evaluateJavaScript(javaScript)
                .map { (_: Any) in () }
                .eraseToAnyPublisher()
        } catch {
            return Fail<Void, Error>(error: JavaScriptError.encodingError(message: "Could not encode \(value)"))
                .eraseToAnyPublisher()
        }
    }
    
    func runVoid(named: String, args: [JavaScriptParameterEncodable] = []) -> AnyPublisher<Void, Error> {
        do {
            let params = try args
                .map { try $0.jsEncode() }
                .joined(separator: ", ")
            let javaScript = "\(named)(\(params));"
            return evaluateJavaScript(javaScript)
                .map { (_: Void) in () }
                .eraseToAnyPublisher()
        } catch {
            return Fail<Void, Error>(error: JavaScriptError.encodingError(message: "Could not encode \(args)"))
                .eraseToAnyPublisher()
        }
    }
    
    func runReturning<T: Decodable>(named: String, args: [JavaScriptParameterEncodable] = [], as type: T.Type) -> AnyPublisher<T, Error> {
        do {
            let params = try args
                .map { try $0.jsEncode() }
                .joined(separator: ", ")
            let javaScript = "\(named)(\(params));"
            return evaluateJavaScript(javaScript, as: type)
        } catch {
            return Fail<T, Error>(error: JavaScriptError.encodingError(message: "Could not encode \(args)"))
                .eraseToAnyPublisher()
        }
    }
}
