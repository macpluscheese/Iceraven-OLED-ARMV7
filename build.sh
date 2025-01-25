#!/bin/bash

set -e

# Download latest Apktool
wget -q https://bitbucket.org/iBotPeaches/apktool/downloads/apktool_2.11.0.jar -O apktool.jar  # Download latest version
wget -q https://raw.githubusercontent.com/iBotPeaches/Apktool/master/scripts/linux/apktool
chmod +x apktool*

# Decompile the APK
./apktool d -s iceraven.apk -o iceraven-patched

# Remove META-INF (if necessary)
rm -rf iceraven-patched/META-INF

# Color patching 
sed -i 's/<color name="fx_mobile_layer_color_1">.*/<color name="fx_mobile_layer_color_1">@color\/photonBlack<\/color>/g' iceraven-patched/res/values*/colors.xml
sed -i 's/<color name="fx_mobile_layer_color_2">.*/<color name="fx_mobile_layer_color_2">@color\/photonDarkGrey90<\/color>/g' iceraven-patched/res/values*/colors.xml

# Recompile the APK
./apktool b iceraven-patched -o iceraven-patched.apk --use-aapt2

# Align and sign the APK (your existing code)
zipalign 4 iceraven-patched.apk iceraven-patched-signed.apk

# Clean up
rm -rf iceraven-patched iceraven-patched.apk
