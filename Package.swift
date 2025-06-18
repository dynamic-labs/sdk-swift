// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DynamicSwiftSDK",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "DynamicSwiftSDK",
            targets: ["DynamicSwiftSDK"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-http-types.git", exact: "1.4.0"),
        .package(url: "https://github.com/apple/swift-openapi-runtime.git", exact: "1.8.2"),
    ],
    targets: [
        .binaryTarget(
            name: "DynamicSwiftSDK",
            path: "./DynamicSwiftSDK.xcframework"
        ),
    ]
)