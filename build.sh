#!/usr/bin/env bash
set -euo pipefail  # Strict error handling

# Configuration
APKTOOL_VERSION="2.9.2"  # Latest stable as of 2024-07-25
BASE_URL="https://github.com/fork-maintainers/iceraven-browser/releases/download"

# Cleanup function
cleanup() {
    echo "🧹 Cleaning temporary files..."
    rm -rf "${TMP_DIR:-/tmp/iceraven-patch}" iceraven.apk
}
trap cleanup EXIT

# Create isolated workspace
TMP_DIR=$(mktemp -d -t iceraven-XXXXX)
cd "${TMP_DIR}" || exit 1

# Fetch latest apktool (official GitHub source)
echo "⬇️ Downloading apktool ${APKTOOL_VERSION}..."
wget -q "https://github.com/iBotPeaches/Apktool/releases/download/v${APKTOOL_VERSION}/apktool_${APKTOOL_VERSION}.jar" \
     -O apktool.jar

# Decompile with resource preservation
echo "🔨 Decompiling APK..."
java -jar apktool.jar d --force-manifest -o src ../iceraven.apk > /dev/null 2>&1

# Apply OLED patches
echo "🎨 Applying AMOLED patches..."
# 1. XML color overrides
find src/res -name 'colors.xml' -exec sed -i \
    -e 's/<color name="fx_mobile_layer_color_1">.*/<color name="fx_mobile_layer_color_1">@color\/photonBlack<\/color>/' \
    -e 's/<color name="fx_mobile_layer_color_2">.*/<color name="fx_mobile_layer_color_2">@color\/photonDarkGrey90<\/color>/' {} +

# 2. Smali code hex replacements
SMALI_FILE="src/smali_classes2/mozilla/components/ui/colors/PhotonColors.smali"
sed -i \
    -e 's/ff2b2a33/ff000000/g' \
    -e 's/ff42414d/ff15141a/g' \
    -e 's/ff52525e/ff15141a/g' "${SMALI_FILE}"

# Rebuild with AAPT2 optimization
echo "🏗️ Rebuilding APK..."
java -jar apktool.jar b src -o unsigned.apk --use-aapt2 > /dev/null 2>&1

# Signing process
echo "🔏 Signing APK..."
zipalign -p -f 4 unsigned.apk aligned.apk
apksigner sign \
    --ks "${KEYSTORE}" \
    --ks-pass "pass:${KEYSTORE_PASS}" \
    --out iceraven-oled.apk aligned.apk

# Finalize
mv iceraven-oled.apk "${GITHUB_WORKSPACE}/"  # For GitHub Actions
echo "✅ Build completed successfully!"
