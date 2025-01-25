#!/bin/bash
set -e
# Explicitly use apktool.jar
wget -q https://bitbucket.org/iBotPeaches/apktool/downloads/apktool_2.8.1.jar -O apktool.jar
java -jar apktool.jar d -s iceraven.apk -o iceraven-patched

# Color patching
sed -i 's/<color name="fx_mobile_layer_color_1">.*/<color name="fx_mobile_layer_color_1">@color\/photonBlack<\/color>/g' iceraven-patched/res/values*/colors.xml
sed -i 's/<color name="fx_mobile_layer_color_2">.*/<color name="fx_mobile_layer_color_2">@color\/photonDarkGrey90<\/color>/g' iceraven-patched/res/values*/colors.xml

# Smali color modifications for true black OLED theme
sed -i 's/ff2b2a33/ff000000/g' iceraven-patched/smali_classes2/mozilla/components/ui/colors/PhotonColors.smali
sed -i 's/ff42414d/ff15141a/g' iceraven-patched/smali_classes2/mozilla/components/ui/colors/PhotonColors.smali
sed -i 's/ff52525e/ff15141a/g' iceraven-patched/smali_classes2/mozilla/components/ui/colors/PhotonColors.smali

java -jar apktool.jar b iceraven-patched -o iceraven-patched.apk --use-aapt2
zipalign 4 iceraven-patched.apk iceraven-patched-signed.apk
rm -rf iceraven-patched iceraven-patched.apk
