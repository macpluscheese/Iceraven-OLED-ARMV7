#!/bin/bash

# Decompile the APK
apktool d -s iceraven.apk -o patched
rm -rf patched/META-INF

# Apply patches
sed -i 's/<color name="fx_mobile_layer_color_1">.*/<color name="fx_mobile_layer_color_1">@color\/photonBlack<\/color>/g' patched/res/values-night/colors.xml
sed -i 's/<color name="fx_mobile_layer_color_2">.*/<color name="fx_mobile_layer_color_2">@color\/photonDarkGrey90<\/color>/g' patched/res/values-night/colors.xml

# Rebuild the APK
apktool b patched -o patched.apk --use-aapt2

# Align the APK
zipalign 4 patched.apk patched_signed.apk
rm -rf patched patched.apk
