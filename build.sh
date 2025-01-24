#!/bin/bash

set -e

# --- Configuration ---
APKTOOL_VERSION="2.9.3"
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

# --- Modify colors.xml (Refined Patching) ---

echo "Patching colors.xml..."

# 1. Manually back up the original colors.xml
cp "$PATCHED_APK_DIR/res/values/colors.xml" "$PATCHED_APK_DIR/res/values/colors.xml.bak"

# 2. Carefully modify colors.xml using a more robust method (sed with backup)
sed -i.bak -E 's|<color name="fx_mobile_layer_color_1">(#.{6,8})</color>|<color name="fx_mobile_layer_color_1">@color/photonBlack</color>|g' "$PATCHED_APK_DIR/res/values/colors.xml"
sed -i.bak -E 's|<color name="fx_mobile_layer_color_2">(#.{6,8})</color>|<color name="fx_mobile_layer_color_2">@color/photonDarkGrey90</color>|g' "$PATCHED_APK_DIR/res/values/colors.xml"

# --- Modify Layout to Address Overlap Issue ---

echo "Modifying layout to fix status bar overlap..."

# Find the main activity layout file (replace with the actual file if different)
MAIN_ACTIVITY_LAYOUT=$(find "$PATCHED_APK_DIR/res/layout" -name "browser.xml" -print -quit)  # Changed

if [ -z "$MAIN_ACTIVITY_LAYOUT" ]; then
  echo "Error: Could not find the main activity layout file (browser.xml)."
  exit 1
fi

# 1. Ensure the root layout has fitsSystemWindows="true"
if ! grep -q "android:fitsSystemWindows=\"true\"" "$MAIN_ACTIVITY_LAYOUT"; then
  echo "Adding android:fitsSystemWindows=\"true\" to root layout"
  sed -i '/<.*Layout/s/$/\    android:fitsSystemWindows="true"/' "$MAIN_ACTIVITY_LAYOUT"
fi

# 2. Add a top padding to the main content container to account for the status bar height.
#    We'll use a dimension resource for this to handle different screen densities.

# Create dimens.xml if it doesn't exist
DIMENS_FILE="$PATCHED_APK_DIR/res/values/dimens.xml"
if [ ! -f "$DIMENS_FILE" ]; then
    echo "<resources>" > "$DIMENS_FILE"
    echo "    <dimen name=\"status_bar_height\">24dp</dimen>" >> "$DIMENS_FILE" # Add this line
    echo "</resources>" >> "$DIMENS_FILE"
else
    # Add the dimension if it doesn't exist
    if ! grep -q "status_bar_height" "$DIMENS_FILE"; then
        sed -i '/<\/resources>/i\    <dimen name="status_bar_height\">24dp</dimen>' "$DIMENS_FILE"
    fi
fi

# Add the padding to the main content view (replace 'main_content' with the actual ID)
if grep -q "android:id=\"@\+id\/main_content\"" "$MAIN_ACTIVITY_LAYOUT"; then
    sed -i '/android:id="@\+id\/main_content"/s/$/\    android:paddingTop="@dimen\/status_bar_height"/' "$MAIN_ACTIVITY_LAYOUT"
else
    echo "Warning: Could not find main content view with ID 'main_content'. Padding not added."
fi

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
