#!/bin/bash

set -e

# Decompile with Apktool (decode resources + classes)
wget -q https://bitbucket.org/iBotPeaches/apktool/downloads/apktool_2.11.0.jar -O apktool.jar
java -jar apktool.jar d iceraven.apk -o iceraven-patched  # -s flag removed
rm -rf iceraven-patched/META-INF

# Color patching
sed -i 's/<color name="fx_mobile_layer_color_1">.*/<color name="fx_mobile_layer_color_1">#ff000000<\/color>/g' iceraven-patched/res/values-night/colors.xml
sed -i 's/<color name="fx_mobile_layer_color_2">.*/<color name="fx_mobile_layer_color_2">@color\/photonDarkGrey90<\/color>/g' iceraven-patched/res/values-night/colors.xml

# Smali patching
sed -i 's/ff2b2a33/ff000000/g' iceraven-patched/smali_classes2/mozilla/components/ui/colors/PhotonColors.smali
sed -i 's/ff42414d/ff15141a/g' iceraven-patched/smali_classes2/mozilla/components/ui/colors/PhotonColors.smali
sed -i 's/ff52525e/ff15141a/g' iceraven-patched/smali_classes2/mozilla/components/ui/colors/PhotonColors.smali

# Recompile the APK
java -jar apktool.jar b iceraven-patched -o iceraven-patched.apk --use-aapt2

# Align and sign the APK
zipalign 4 iceraven-patched.apk iceraven-patched-signed.apk

# Clean up
rm -rf iceraven-patched iceraven-patch ed.apk
