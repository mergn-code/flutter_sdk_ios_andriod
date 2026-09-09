// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "mergn_flutter_plugin",
    platforms: [
        .iOS("12.0")
    ],
    products: [
        .library(name: "mergn-flutter-plugin", targets: ["mergn_flutter_plugin"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "mergn_flutter_plugin",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ],
            resources: []
        )
    ]
)
