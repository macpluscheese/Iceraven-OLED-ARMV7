#!/bin/bash
set -e

# --- Configuration ---
APKTOOL_VERSION="2.9.3"
STATUS_BAR_HEIGHT="48dp"

# --- Cleanup previous builds ---
rm -rf iceraven-patched apktool.jar

# --- Download latest Apktool ---
wget -q "https://bitbucket.org/iBotPeaches/apktool/downloads/apktool_${APKTOOL_VERSION}.jar" \
  -O apktool.jar

# --- Decompile APK ---
java -jar apktool.jar d -s iceraven.apk -o iceraven-patched

# --- Apply Dark Theme Mods ---
echo "Applying dark theme modifications..."

# XML Color Resources
find iceraven-patched/res/values* -name 'colors.xml' -exec sed -i \
  -e 's/<color name="fx_mobile_layer_color_1">.*/<color name="fx_mobile_layer_color_1">@color\/photonBlack<\/color>/g' \
  -e 's/<color name="fx_mobile_layer_color_2">.*/<color name="fx_mobile_layer_color_2">@color\/photonDarkGrey90<\/color>/g' \
  {} +

# Smali Color Values (robust implementation)
echo "Modifying PhotonColors.smali..."
SMALI_PATHS=$(find iceraven-patched/smali_classes* -path '*/mozilla/components/ui/colors/PhotonColors.smali')

if [ -z "$SMALI_PATHS" ]; then
  echo "Error: PhotonColors.smali not found in any smali_classes directory!"
  exit 1
fi

while IFS= read -r smali_file; do
  sed -i \
    -e 's/ff2b2a33/ff000000/g' \
    -e 's/ff42414d/ff15141a/g' \
    -e 's/ff52525e/ff15141a/g' \
    "$smali_file"
done <<< "$SMALI_PATHS"

# --- Fix Pixel Status Bar Padding ---
echo "Adjusting status bar dimensions..."
find iceraven-patched/res -name 'dimens.xml' -exec sed -i \
  -e "s/<dimen name=\"status_bar_height\">[^<]*/<dimen name=\"status_bar_height\">${STATUS_BAR_HEIGHT}/g" \
  -e "s/<dimen name=\"status_bar_padding_top\">[^<]*/<dimen name=\"status_bar_padding_top\">${STATUS_BAR_HEIGHT}/g" \
  {} +

# --- Rebuild APK ---
echo "Rebuilding APK..."
java -jar apktool.jar b iceraven-patched -o iceraven-patched.apk --use-aapt2

# --- Optimize APK ---
echo "Optimizing APK..."
zipalign 4 iceraven-patched.apk iceraven-patched-signed.apk

# --- Cleanup ---
echo "Cleaning up..."
rm -rf iceraven-patched iceraven-patched.apk
