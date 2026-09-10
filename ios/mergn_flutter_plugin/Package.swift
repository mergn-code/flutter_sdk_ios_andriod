// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

// This package is only the method-channel bridge. All SDK behaviour lives in the
// prebuilt native mergn_ios framework, which FlutterPluginMergn re-exports so
// apps can keep writing `import mergn_flutter_plugin`.
//
// mergn_ios must be a *remote* binary target. A local `.binaryTarget(path:)`
// cannot work here: Flutter symlinks each plugin into the SPM workspace under the
// plugin root's basename (which carries a version suffix for pub.dev installs),
// while the real package directory is named mergn_flutter_plugin. SPM
// canonicalizes that symlink when resolving binary artifacts and rejects the
// mismatch with "identity ... doesn't match override's identity".
//
// Release checklist: ./scripts/package_sdk.sh, upload the zip to a release tagged
// v<version>, then update `url` and `checksum` below. The zip is not
// reproducible, so paste the checksum printed for the exact zip you uploaded.
//
// The url below deliberately points at the v3.0.0 release even while the plugin
// is on 3.0.0-beta.1: the native SDK binary does not change between the beta and
// the stable release, so both consume the same verified artifact. Note that
// package_sdk.sh derives the url from the podspec version, so re-running it
// during the beta would rewrite this to a v3.0.0-beta.1 tag that does not exist.
let package = Package(
    name: "mergn_flutter_plugin",
    platforms: [
        .iOS("15.0")
    ],
    products: [
        .library(name: "mergn-flutter-plugin", targets: ["mergn_flutter_plugin"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .binaryTarget(
            name: "mergn_ios",
            url: "https://github.com/mergn-code/flutter_sdk_ios_andriod/releases/download/v3.0.0/mergn_ios.xcframework.zip",
            checksum: "ccd33251a446663f35bb1ab1af6c281ff4fe9ba422558199997596613319e128"
        ),
        .target(
            name: "mergn_flutter_plugin",
            dependencies: [
                "mergn_ios",
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ],
            resources: []
        )
    ]
)
