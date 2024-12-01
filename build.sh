#!/bin/bash

set -e  # Exit immediately on error

ICERAVEN_VERSION=$1

# Explicitly use apktool.jar (sometimes apktool wrapper has issues)
wget -q https://bitbucket.org/iBotPeaches/apktool/downloads/apktool_2.8.1.jar -O apktool.jar # Download latest version
java -jar apktool.jar d -s iceraven.apk -o iceraven-patched || { echo "Decompile failed"; exit 1; }


#  ***CRITICAL***: Verify these color names in the decompiled APK!
sed -i 's/<color name="fx_mobile_layer_color_1">.*/<color name="fx_mobile_layer_color_1">@color\/photonBlack<\/color>/g' iceraven-patched/res/values*/colors.xml
sed -i 's/<color name="fx_mobile_layer_color_2">.*/<color name="fx_mobile_layer_color_2">@color\/photonDarkGrey90<\/color>/g' iceraven-patched/res/values*/colors.xml


java -jar apktool.jar b iceraven-patched -o iceraven-patched.apk --use-aapt2 || { echo "Build failed"; exit 1; }

zipalign 4 iceraven-patched.apk iceraven-patched-signed.apk  || { echo "Zipalign failed"; exit 1; }

rm -rf iceraven-patched iceraven-patched.apk
