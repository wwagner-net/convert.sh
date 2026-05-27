#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
#  Build WebM Converter.app
#  Usage:  bash build-app.sh [--open]
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_NAME="WebM Converter"
BUNDLE_ID="net.wwagner.WebMConverter"
VERSION="1.0.0"
MIN_MACOS="13.0"
BUILD_DIR="$SCRIPT_DIR/build"
APP_BUNDLE="$BUILD_DIR/$APP_NAME.app"

echo "🔨  Building $APP_NAME v$VERSION …"

# ── 1. Swift build ─────────────────────────────────────────────────────────
cd "$SCRIPT_DIR"
swift build -c release 2>&1 | grep -v "^warning:" | grep -v "^note:" || true

BINARY_SRC="$SCRIPT_DIR/.build/release/WebMConverter"
if [[ ! -f "$BINARY_SRC" ]]; then
    echo "❌  Build failed – binary not found"
    exit 1
fi
echo "✓  Binary compiled"

# ── 2. App bundle ──────────────────────────────────────────────────────────
rm -rf "$APP_BUNDLE"
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

cp "$BINARY_SRC" "$APP_BUNDLE/Contents/MacOS/WebMConverter"
chmod +x "$APP_BUNDLE/Contents/MacOS/WebMConverter"
echo "✓  Binary bundled"

# ── 3. Info.plist ──────────────────────────────────────────────────────────
cat > "$APP_BUNDLE/Contents/Info.plist" << PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
    "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>
    <string>${APP_NAME}</string>
    <key>CFBundleDisplayName</key>
    <string>${APP_NAME}</string>
    <key>CFBundleIdentifier</key>
    <string>${BUNDLE_ID}</string>
    <key>CFBundleVersion</key>
    <string>${VERSION}</string>
    <key>CFBundleShortVersionString</key>
    <string>${VERSION}</string>
    <key>CFBundleExecutable</key>
    <string>WebMConverter</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>LSMinimumSystemVersion</key>
    <string>${MIN_MACOS}</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSSupportsAutomaticGraphicsSwitching</key>
    <true/>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
    <key>CFBundleDevelopmentRegion</key>
    <string>de</string>
    <key>NSHumanReadableCopyright</key>
    <string>Copyright © 2025 Wolfgang Wagner</string>
</dict>
</plist>
PLIST
echo "✓  Info.plist written"

# ── 4. Icon ────────────────────────────────────────────────────────────────
echo "→  Generating app icon …"

ICONSET="$BUILD_DIR/AppIcon.iconset"
mkdir -p "$ICONSET"

ICON_SCRIPT="$SCRIPT_DIR/create-icon.swift"

generate_png() {
    local size="$1"
    local dest="$2"

    # 1. Try our native Swift renderer
    if swift "$ICON_SCRIPT" "$size" "$dest" 2>/dev/null; then
        return 0
    fi

    # 2. Try rsvg-convert (brew install librsvg)
    if command -v rsvg-convert &>/dev/null; then
        rsvg-convert -w "$size" -h "$size" "$SCRIPT_DIR/icon.svg" -o "$dest"
        return 0
    fi

    echo "   ⚠ Could not generate ${size}px icon – using placeholder"
    return 1
}

generate_png 16   "$ICONSET/icon_16x16.png"
generate_png 32   "$ICONSET/icon_16x16@2x.png"
generate_png 32   "$ICONSET/icon_32x32.png"
generate_png 64   "$ICONSET/icon_32x32@2x.png"
generate_png 128  "$ICONSET/icon_128x128.png"
generate_png 256  "$ICONSET/icon_128x128@2x.png"
generate_png 256  "$ICONSET/icon_256x256.png"
generate_png 512  "$ICONSET/icon_256x256@2x.png"
generate_png 512  "$ICONSET/icon_512x512.png"
generate_png 1024 "$ICONSET/icon_512x512@2x.png"

if iconutil -c icns "$ICONSET" -o "$APP_BUNDLE/Contents/Resources/AppIcon.icns" 2>/dev/null; then
    echo "✓  AppIcon.icns packaged"
else
    echo "⚠  iconutil failed – app will use system default icon"
fi
rm -rf "$ICONSET"

# ── 5. Ad-hoc code signing (required on macOS 13+) ────────────────────────
if codesign --sign - --force --deep "$APP_BUNDLE" 2>/dev/null; then
    echo "✓  Ad-hoc code signature applied"
else
    echo "⚠  Code signing skipped (app may show Gatekeeper warning)"
fi

# ── Done ───────────────────────────────────────────────────────────────────
echo ""
echo "┌─────────────────────────────────────────────────────┐"
echo "│  ✅  ${APP_NAME}.app built successfully!          │"
echo "└─────────────────────────────────────────────────────┘"
echo ""
echo "   📦  $(du -sh "$APP_BUNDLE" | cut -f1)  →  $APP_BUNDLE"
echo ""
echo "   Starten:"
echo "   open \"$APP_BUNDLE\""
echo ""
echo "   Oder in /Applications installieren:"
echo "   cp -r \"$APP_BUNDLE\" /Applications/"
echo ""

if [[ "${1:-}" == "--open" ]]; then
    open "$APP_BUNDLE"
fi
