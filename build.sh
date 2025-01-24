#!/bin/bash

set -e

# --- Configuration ---
APKTOOL_VERSION="2.9.3"  # Use the latest version
APKTOOL_JAR="apktool_${APKTOOL_VERSION}.jar"
ICERAVEN_APK="iceraven.apk"
PATCHED_APK_DIR="iceraven-patched"
PATCHED_APK="iceraven-patched.apk"
SIGNED_APK="iceraven-patched-signed.apk"

# --- Functions ---

# Function to download a file if it doesn't exist
download_if_not_exists() {
  local url=$1
  local filename=$2
  if [ ! -f "$filename" ]; then
    echo "Downloading $filename from $url"
    wget -q "$url" -O "$filename"
  else
    echo "$filename already exists. Skipping download."
  fi
}

# --- Download Dependencies (if needed) ---

# Download the latest apktool
download_if_not_exists "https://github.com/iBotPeaches/Apktool/releases/download/v${APKTOOL_VERSION}/${APKTOOL_JAR}" "$APKTOOL_JAR"

# --- Decompile APK ---

echo "Decompiling $ICERAVEN_APK..."
java -jar "$APKTOOL_JAR" d -s "$ICERAVEN_APK" -o "$PATCHED_APK_DIR"

# --- Modify colors.xml (Using IronFox color lines) ---

echo "Patching colors.xml..."

# Replace the color values in values-night/colors.xml with IronFox's values
sed -i 's/name="fx_mobile_layer_color_1" type="color">#ff2d2e34<\/item>/name="fx_mobile_layer_color_1" type="color">@color\/photonBlack<\/item>/g' "$PATCHED_APK_DIR/res/values-night/colors.xml"
sed -i 's/name="fx_mobile_layer_color_2" type="color">#ff35373f<\/item>/name="fx_mobile_layer_color_2" type="color">@color\/photonDarkGrey90<\/item>/g' "$PATCHED_APK_DIR/res/values-night/colors.xml"

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
