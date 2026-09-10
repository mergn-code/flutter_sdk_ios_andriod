#!/usr/bin/env bash
#
# Packages the vendored native SDK for release.
#
# CocoaPods consumes ios/mergn_flutter_plugin/Frameworks/mergn_ios.xcframework in
# place. Swift Package Manager cannot use a local binary target here (see the
# comment in Package.swift), so it downloads a zip from GitHub Releases instead.
# This script produces that zip and its checksum.
#
# Usage:
#   ./scripts/package_sdk.sh                      # package the vendored copy
#   ./scripts/package_sdk.sh /path/to/new.xcframework   # sync a new SDK build first

set -euo pipefail

MODULE_NAME=mergn_flutter_plugin
SDK_NAME=mergn_ios
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FRAMEWORKS_DIR="$ROOT/ios/$MODULE_NAME/Frameworks"
XCFRAMEWORK="$FRAMEWORKS_DIR/$SDK_NAME.xcframework"
ZIP="$FRAMEWORKS_DIR/$SDK_NAME.xcframework.zip"

if [[ $# -gt 0 ]]; then
  source_xcframework="$1"
  if [[ ! -d "$source_xcframework" ]]; then
    echo "error: no xcframework at $source_xcframework" >&2
    exit 1
  fi
  echo "==> Syncing SDK from $source_xcframework"
  rm -rf "$XCFRAMEWORK"
  mkdir -p "$FRAMEWORKS_DIR"
  ditto "$source_xcframework" "$XCFRAMEWORK"
fi

if [[ ! -d "$XCFRAMEWORK" ]]; then
  echo "error: no vendored SDK at $XCFRAMEWORK" >&2
  exit 1
fi

# Fail loudly if a slice is missing rather than shipping a framework that cannot
# build on device or in the simulator.
for required in ios-arm64 ios-arm64_x86_64-simulator; do
  if [[ ! -d "$XCFRAMEWORK/$required" ]]; then
    echo "error: $XCFRAMEWORK is missing the $required slice" >&2
    exit 1
  fi
done

echo "==> Packaging $SDK_NAME.xcframework"
rm -f "$ZIP"
(cd "$FRAMEWORKS_DIR" && ditto -c -k --sequesterRsrc --keepParent "$SDK_NAME.xcframework" "$SDK_NAME.xcframework.zip")

CHECKSUM="$(cd "$ROOT/ios/$MODULE_NAME" && swift package compute-checksum "$ZIP")"
VERSION="$(sed -n "s/^  s\.version *= *'\(.*\)'/\1/p" "$ROOT/ios/$MODULE_NAME.podspec")"

PACKAGE_SWIFT="$ROOT/ios/$MODULE_NAME/Package.swift"
REPO_URL="$(git -C "$ROOT" remote get-url origin 2>/dev/null | sed 's/\.git$//')"
if [[ -z "$REPO_URL" ]]; then
  echo "error: could not read the origin remote to build the release URL" >&2
  exit 1
fi
URL="$REPO_URL/releases/download/v$VERSION/$SDK_NAME.xcframework.zip"

# Rewrite the manifest in lockstep with the zip we just produced. ditto is not
# deterministic, so re-zipping identical content still yields a new checksum --
# leaving this to a human guarantees an eventual mismatch and a broken consumer
# build that only shows up after the release is public.
sed -i '' "s|^            url: \".*\"|            url: \"$URL\"|" "$PACKAGE_SWIFT"
sed -i '' "s|^            checksum: \".*\"|            checksum: \"$CHECKSUM\"|" "$PACKAGE_SWIFT"

echo
echo "    zip      : $ZIP"
echo "    checksum : $CHECKSUM"
echo "    manifest : updated $PACKAGE_SWIFT"
echo
echo "Next step to publish $VERSION:"
echo "  gh release create v$VERSION \"$ZIP\" --title v$VERSION --notes-file CHANGELOG.md"
echo
echo "Upload this exact zip -- rebuilding it changes the checksum."
