// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Swiftees",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .executable(
            name: "swiftees",
            targets: ["Swiftees"]
        )
    ],
    targets: [
        .executableTarget(
            name: "Swiftees",
            path: "Sources"
        )
    ]
)
