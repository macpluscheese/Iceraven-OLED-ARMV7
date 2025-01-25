#!/bin/bash

set -e

# Download and extract Baksmali and Smali tools
wget -q https://bitbucket.org/JesusFreke/smali/downloads/smali-2.4.0.jar -O smali.jar
wget -q https://bitbucket.org/JesusFreke/smali/downloads/baksmali-2.4.0.jar -O baksmali.jar

# Decompile the APK using Baksmali
java -jar baksmali.jar d iceraven.apk -o iceraven-patched

# Color patching for colors.xml
sed -i 's/<color name="fx_mobile_layer_color_1">.*/<color name="fx_mobile_layer_color_1">@color\/photonBlack<\/color>/g' iceraven-patched/res/values*/colors.xml
sed -i 's/<color name="fx_mobile_layer_color_2">.*/<color name="fx_mobile_layer_color_2">@color\/photonDarkGrey90<\/color>/g' iceraven-patched/res/values*/colors.xml

# Color patching for PhotonColors.smali
sed -i 's/ff2b2a33/ff000000/g' iceraven-patched/smali_classes2/mozilla/components/ui/colors/PhotonColors.smali
sed -i 's/ff42414d/ff15141a/g' iceraven-patched/smali_classes2/mozilla/components/ui/colors/PhotonColors.smali
sed -i 's/ff52525e/ff15141a/g' iceraven-patched/smali_classes2/mozilla/components/ui/colors/PhotonColors.smali

# Reassemble the APK using Smali
java -jar smali.jar a iceraven-patched -o iceraven-patched.apk

# Zipalign and sign the APK
zipalign 4 iceraven-patched.apk iceraven-patched-signed.apk

# Clean up temporary files
rm -rf iceraven-patched smali.jar baksmali.jar iceraven-patched.apk
