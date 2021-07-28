// swift-tools-version:5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ECMASwift",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13)
    ],
    products: [
        .library(name: "ECMASwift", targets: ["ECMASwift"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "ECMASwift", dependencies: []),
        .testTarget(
            name: "ECMASwiftTests",
            dependencies: [
                .target(name: "ECMASwift")
            ],
            resources: [
                .copy("web")
            ]
        ),
    ]
)
