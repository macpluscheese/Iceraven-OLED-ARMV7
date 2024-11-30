#!/bin/bash

# Download the specified IceRaven APK
wget -q "https://github.com/fork-maintainers/iceraven-browser/releases/download/iceraven-2.26.0/iceraven-2.26.0-browser-arm64-v8a-forkRelease.apk" -O latest.apk

# Download apktool
wget -q https://bitbucket.org/iBotPeaches/apktool/downloads/apktool_2.8.1.jar -O apktool.jar
wget -q https://raw.githubusercontent.com/iBotPeaches/Apktool/master/scripts/linux/apktool
chmod +x apktool*

# Decompile the APK
rm -rf patched patched_signed.apk
./apktool d -s latest.apk -o patched
rm -rf patched/META-INF

# Apply the patches
sed -i 's/<color name="fx_mobile_layer_color_1">.*/<color name="fx_mobile_layer_color_1">@color\/photonBlack<\/color>/g' patched/res/values-night/colors.xml
sed -i 's/<color name="fx_mobile_layer_color_2">.*/<color name="fx_mobile_layer_color_2">@color\/photonDarkGrey90<\/color>/g' patched/res/values-night/colors.xml

# Rebuild the APK
./apktool b patched -o patched.apk --use-aapt2

# Align the APK (signing happens in build.yml)
zipalign 4 patched.apk patched_signed.apk
rm -rf patched patched.apk
