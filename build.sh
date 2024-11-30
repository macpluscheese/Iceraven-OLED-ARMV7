#!/bin/bash
set -e

# Decompile APK
apktool d iceraven.apk -o iceraven-decompiled

# Navigate to the res/values-night directory and edit colors.xml
cd iceraven-decompiled/res/values-night
sed -i 's/<color name="fx_mobile_layer_color_1">.*/<color name="fx_mobile_layer_color_1">@color\/photonBlack<\/color>/g' colors.xml
sed -i 's/<color name="fx_mobile_layer_color_2">.*/<color name="fx_mobile_layer_color_2">@color\/photonDarkGrey90<\/color>/g' colors.xml
cd ../../..

# Recompile the APK
apktool b iceraven-decompiled -o iceraven-modified.apk

# Create a temporary directory to store the keystore file
mkdir keystore
echo "$KEYSTORE_FILE" | base64 --decode > keystore/my-release-key.jks

# Sign the APK
apksigner sign --ks keystore/my-release-key.jks --ks-key-alias "$KEYSTORE_ALIAS" --ks-pass env:KEYSTORE_PASSWORD --out iceraven-signed.apk iceraven-modified.apk

# Clean up
rm -rf keystore
