#!/bin/bash
set -e

# --- Configuration ---
APKTOOL_VERSION="2.9.3"
STATUS_BAR_HEIGHT="48dp"  # Tested value for Pixel Fold

# --- Cleanup previous builds ---
rm -rf iceraven-patched apktool.jar

# --- Download latest Apktool ---
wget -q "https://bitbucket.org/iBotPeaches/apktool/downloads/apktool_${APKTOOL_VERSION}.jar" \
  -O apktool.jar

# --- Decompile APK ---
java -jar apktool.jar d -s iceraven.apk -o iceraven-patched

# --- Apply Dark Theme Mods ---
find iceraven-patched/res/values* -name 'colors.xml' -exec sed -i \
  -e 's/<color name="fx_mobile_layer_color_1">.*/<color name="fx_mobile_layer_color_1">@color\/photonBlack<\/color>/g' \
  -e 's/<color name="fx_mobile_layer_color_2">.*/<color name="fx_mobile_layer_color_2">@color\/photonDarkGrey90<\/color>/g' \
  {} +

# --- Fix Pixel Status Bar Padding ---
find iceraven-patched/res -name 'dimens.xml' -exec sed -i \
  -e "s/<dimen name=\"status_bar_height\">[^<]*/<dimen name=\"status_bar_height\">${STATUS_BAR_HEIGHT}/g" \
  -e "s/<dimen name=\"status_bar_padding_top\">[^<]*/<dimen name=\"status_bar_padding_top\">${STATUS_BAR_HEIGHT}/g" \
  {} +

# --- Rebuild APK ---
java -jar apktool.jar b iceraven-patched -o iceraven-patched.apk --use-aapt2

# --- Optimize APK ---
zipalign 4 iceraven-patched.apk iceraven-patched-signed.apk

# --- Cleanup ---
rm -rf iceraven-patched iceraven-patched.apk
