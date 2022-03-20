// Utilities.swift
// Copyright © 2022 hiimtmac

import XCTest

extension XCTestCase {
    func webURL() -> URL {
        let currentFileURL = URL(fileURLWithPath: "\(#file)", isDirectory: false)
        return currentFileURL
            .deletingLastPathComponent()
            .appendingPathComponent("web")
    }
}
