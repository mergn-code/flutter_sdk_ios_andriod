## 2.1.3

Added Swift Package Manager support for iOS. CocoaPods remains supported, so no
changes are required in existing apps.

Removed the macOS platform declaration. It was a non-functional stub that only
answered `getPlatformVersion` and could not be resolved or compiled.

## 2.1.2

Added Progaurd rules for internal logging.
