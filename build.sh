#!/bin/bash
set -e

# Download apktool
wget -q https://bitbucket.org/iBotPeaches/apktool/downloads/apktool_2.8.1.jar -O apktool.jar
wget -q https://raw.githubusercontent.com/iBotPeaches/Apktool/master/scripts/linux/apktool
chmod +x apktool*

# Clean up any previous builds
rm -rf patched patched_signed.apk
java -jar apktool.jar d -s latest.apk -o patched 
rm -rf patched/META-INF

# Modify colors.xml
sed -i 's/<color name="fx_mobile_layer_color_1">.*/<color name="fx_mobile_layer_color_1">@color\/photonBlack<\/color>/g' patched/res/values-night/colors.xml
sed -i 's/<color name="fx_mobile_layer_color_2">.*/<color name="fx_mobile_layer_color_2">@color\/photonDarkGrey90<\/color>/g' patched/res/values-night/colors.xml

# Recompile the APK
java -jar apktool.jar b patched -o patched.apk --use-aapt2

# Align and clean up
zipalign 4 patched.apk patched_signed.apk
rm -rf patched patched.apk
