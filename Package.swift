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
            targets: ["DynamicSwiftSDKWrapper"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-http-types.git", exact: "1.4.0"),
        .package(url: "https://github.com/apple/swift-openapi-runtime.git", exact: "1.8.2"),
        .package(url: "https://github.com/attaswift/BigInt", exact: "5.5.1"),
    ],
    targets: [
        .binaryTarget(
            name: "DynamicSwiftSDK",
            path: "./DynamicSwiftSDK.xcframework"
        ),
        .target(
            name: "DynamicSwiftSDKWrapper",
            dependencies: [
                "DynamicSwiftSDK",
                .product(name: "HTTPTypes", package: "swift-http-types"),
                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
                .product(name: "BigInt", package: "BigInt"),
            ],
            swiftSettings: [
                .unsafeFlags(["-enable-library-evolution"])
            ]
        ),
    ]
)
