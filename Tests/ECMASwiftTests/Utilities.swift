//
//  File.swift
//  
//
//  Created by Taylor McIntyre on 2020-03-27.
//

import XCTest

extension XCTestCase {
    func webURL() -> URL {
        let currentFileURL = URL(fileURLWithPath: "\(#file)", isDirectory: false)
        return currentFileURL
            .deletingLastPathComponent()
            .appendingPathComponent("web")
    }
}
