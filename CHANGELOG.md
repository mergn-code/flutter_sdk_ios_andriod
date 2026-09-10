## 3.0.0

The iOS plugin is now a thin bridge over the native Mergn iOS SDK
(`mergn_ios.xcframework`). Previously it carried its own Swift reimplementation
of the SDK -- 18 files duplicating `EventManager`, `SDKManager`, `NetworkManager`
and the rest -- which could drift from the native SDK independently. Those files
are gone; the plugin now delegates to the real SDK and ships only the
method-channel bridge.

No source changes are required. The plugin re-exports `mergn_ios`, so
`import mergn_flutter_plugin` still resolves `SDKManager.shared`,
`EventManager.shared` and the notification hooks with identical signatures, and
existing `AppDelegate` integrations compile as-is. The Dart API is untouched.

CocoaPods vendors the SDK directly. Swift Package Manager downloads it from this
repository's GitHub Releases, because Flutter's plugin symlinking is
incompatible with local SPM binary targets.

Two breaking requirements come with the binary SDK:

- **Xcode 26.0 or later.** Swift binary frameworks are forward-compatible only.
  Apps built with an older Xcode cannot import the module. Stay on 2.1.x if you
  are not on Xcode 26 yet.
- **iOS deployment target 15.0**, raised from 12.0, because Xcode 26 cannot
  archive for anything lower.

## 2.1.3

Added Swift Package Manager support for iOS. CocoaPods remains supported, so no
changes are required in existing apps.

Removed the macOS platform declaration. It was a non-functional stub that only
answered `getPlatformVersion` and could not be resolved or compiled.

## 2.1.2

Added Progaurd rules for internal logging.
