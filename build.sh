#!/bin/bash
set -e
# Download latest Apktool
APKTOOL_URL=$(curl -s https://api.github.com/repos/iBotPeaches/apktool/releases/latest | grep -o "https://.*apktool_[0-9.]*\.jar")
wget -q "$APKTOOL_URL" -O apktool.jar

java -jar apktool.jar d -s iceraven.apk -o iceraven-patched

# Color patching
sed -i 's/<color name="fx_mobile_layer_color_1">.*/<color name="fx_mobile_layer_color_1">@color\/photonBlack<\/color>/g' iceraven-patched/res/values*/colors.xml
sed -i 's/<color name="fx_mobile_layer_color_2">.*/<color name="fx_mobile_layer_color_2">@color\/photonDarkGrey90<\/color>/g' iceraven-patched/res/values*/colors.xml

# Smali color modifications
SMALI_DIRS=($(find iceraven-patched -type d -name "smali_classes*"))
for dir in "${SMALI_DIRS[@]}"; do
 PHOTON_COLOR_FILE="$dir/mozilla/components/ui/colors/PhotonColors.smali"
 if [ -f "$PHOTON_COLOR_FILE" ]; then
   sed -i 's/ff2b2a33/ff000000/g' "$PHOTON_COLOR_FILE"
   sed -i 's/ff42414d/ff15141a/g' "$PHOTON_COLOR_FILE"
   sed -i 's/ff52525e/ff15141a/g' "$PHOTON_COLOR_FILE"
 fi
done

java -jar apktool.jar b iceraven-patched -o iceraven-patched.apk --use-aapt2
zipalign 4 iceraven-patched.apk iceraven-patched-signed.apk
rm -rf iceraven-patched iceraven-patched.apk
