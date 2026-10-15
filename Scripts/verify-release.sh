#!/bin/sh
# Archives the example app in Release (unsigned) and checks that no ScreenBridge
# inspector code, credentials, connection file or absolute source paths are present.
set -eu
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
command -v xcodegen >/dev/null && xcodegen generate --quiet
rm -rf "$ROOT/.build/archive"
xcodebuild archive -project ScreenBridgeDemo.xcodeproj -scheme ScreenBridgeDemo -configuration Release \
  -destination 'generic/platform=iOS' -archivePath "$ROOT/.build/archive/Demo.xcarchive" \
  -derivedDataPath "$ROOT/.build/archive-dd" CODE_SIGNING_ALLOWED=NO -quiet
APP="$ROOT/.build/archive/Demo.xcarchive/Products/Applications/ScreenBridgeDemo.app"
fail=0
if [ -e "$APP/ScreenBridgeConnection.json" ]; then echo "FAIL: connection file in Release bundle"; fail=1; fi
for s in pskBase64 ReceiverSession "Tap an element" _screenbridge._tcp ScreenBridgeConnection LogSanitizer; do
  if strings -a "$APP/ScreenBridgeDemo" | grep -q "$s"; then echo "FAIL: found '$s' in Release binary"; fail=1; fi
done
if strings -a "$APP/ScreenBridgeDemo" | grep -q '^/Users/'; then echo "FAIL: absolute source path in Release binary"; fail=1; fi
[ $fail -eq 0 ] && echo "OK: Release archive contains no ScreenBridge tooling, credentials or source paths."
exit $fail
