#!/bin/bash
set -e
# Download latest Apktool
APKTOOL_URL=$(curl -s https://api.github.com/repos/iBotPeaches/apktool/releases/latest | grep -o "https://.*apktool_[0-9.]*\.jar")
wget -q "$APKTOOL_URL" -O apktool.jar

java -jar apktool.jar d -s iceraven.apk -o iceraven-patched

# Find correct smali path
SMALI_PATH=$(find iceraven-patched -name "PhotonColors.smali")

# Color patching with dynamic path
sed -i 's/<color name="fx_mobile_layer_color_1">.*/<color name="fx_mobile_layer_color_1">@color\/photonBlack<\/color>/g' iceraven-patched/res/values*/colors.xml
sed -i 's/<color name="fx_mobile_layer_color_2">.*/<color name="fx_mobile_layer_color_2">@color\/photonDarkGrey90<\/color>/g' iceraven-patched/res/values*/colors.xml

# Smali color modifications
if [ -n "$SMALI_PATH" ]; then
  sed -i 's/ff2b2a33/ff000000/g' "$SMALI_PATH"
  sed -i 's/ff42414d/ff15141a/g' "$SMALI_PATH"
  sed -i 's/ff52525e/ff15141a/g' "$SMALI_PATH"
fi

java -jar apktool.jar b iceraven-patched -o iceraven-patched.apk --use-aapt2
zipalign 4 iceraven-patched.apk iceraven-patched-signed.apk
rm -rf iceraven-patched iceraven-patched.apk
