#!/bin/bash

set -e

# --- Configuration ---
APKTOOL_VERSION="2.9.3"  # Use the latest version
APKTOOL_JAR="apktool_${APKTOOL_VERSION}.jar"
ICERAVEN_APK="iceraven.apk" # You'll need to provide the original APK or download it in the script
PATCHED_APK_DIR="iceraven-patched"
PATCHED_APK="iceraven-patched.apk"
SIGNED_APK="iceraven-patched-signed.apk"

# --- Download Dependencies (if needed) ---

# Download the latest apktool
if [ ! -f "$APKTOOL_JAR" ]; then
  echo "Downloading $APKTOOL_JAR"
  wget -q "https://github.com/iBotPeaches/Apktool/releases/download/v${APKTOOL_VERSION}/${APKTOOL_JAR}" -O "$APKTOOL_JAR"
fi

# --- Download the Latest Iceraven APK ---
# This part is added to automatically fetch the latest Iceraven APK
echo "Downloading latest Iceraven APK..."
LATEST_RELEASE=$(curl -s https://api.github.com/repos/fork-maintainers/iceraven-browser/releases/latest)
APK_URL=$(echo "$LATEST_RELEASE" | jq -r '.assets[] | select(.name | contains("arm64") and contains("forkRelease.apk")) | .browser_download_url')
wget -q "$APK_URL" -O "$ICERAVEN_APK"

# --- Decompile APK ---

echo "Decompiling $ICERAVEN_APK..."
java -jar "$APKTOOL_JAR" d -s "$ICERAVEN_APK" -o "$PATCHED_APK_DIR"

# --- Modify colors.xml (Corrected and Streamlined) ---

echo "Patching colors.xml..."

# Directly modify the correct color values in values-night/colors.xml
sed -i 's/name="fx_mobile_layer_color_1" type="color">#ff2d2e34<\/item>/name="fx_mobile_layer_color_1" type="color">#000000<\/item>/' "$PATCHED_APK_DIR/res/values-night/colors.xml"
sed -i 's/name="fx_mobile_layer_color_2" type="color">#ff35373f<\/item>/name="fx_mobile_layer_color_2" type="color">#181818<\/item>/' "$PATCHED_APK_DIR/res/values-night/colors.xml"

# --- Rebuild APK ---

echo "Rebuilding $PATCHED_APK..."
java -jar "$APKTOOL_JAR" b "$PATCHED_APK_DIR" -o "$PATCHED_APK" --use-aapt2

# --- Zipalign ---

echo "Zipaligning $PATCHED_APK..."
zipalign 4 "$PATCHED_APK" "$SIGNED_APK"

# --- Cleanup ---

echo "Cleaning up..."
rm -rf "$PATCHED_APK_DIR" "$PATCHED_APK"

echo "Build complete! Output: $SIGNED_APK"
