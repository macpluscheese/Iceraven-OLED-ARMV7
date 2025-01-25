#!/bin/bash

set -e

# Download latest Apktool
wget -q https://bitbucket.org/iBotPeaches/apktool/downloads/apktool_2.11.0.jar -O apktool.jar
wget -q https://raw.githubusercontent.com/iBotPeaches/Apktool/master/scripts/linux/apktool
chmod +x apktool*

# Decompile the APK
./apktool d -s iceraven.apk -o iceraven-patched

# Remove META-INF (if necessary)
rm -rf iceraven-patched/META-INF

# Color patching 
sed -i 's/<color name="fx_mobile_layer_color_1">.*/<color name="fx_mobile_layer_color_1">@color\/photonBlack<\/color>/g' iceraven-patched/res/values*/colors.xml
sed -i 's/<color name="fx_mobile_layer_color_2">.*/<color name="fx_mobile_layer_color_2">@color\/photonDarkGrey90<\/color>/g' iceraven-patched/res/values*/colors.xml

# Addressing Status Bar Padding (Potential Solution)
# Add the following line (adjust the value if needed)
sed -i 's/android:statusBarColor="?@android:color\/transparent"?/android:statusBarColor="@color\/black"/g' iceraven-patched/res/values*/themes.xml

# Recompile the APK
./apktool b iceraven-patched -o iceraven-patched.apk --use-aapt2

# Align and sign the APK (your existing code)
zipalign 4 iceraven-patched.apk iceraven-patched-signed.apk

# Clean up
rm -rf iceraven-patched iceraven-patched.apk
