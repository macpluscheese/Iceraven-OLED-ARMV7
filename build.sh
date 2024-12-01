#!/bin/bash

ICERAVEN_VERSION=$1

apktool d -s iceraven.apk -o iceraven-patched

# Search for and replace color values in ALL values*/colors.xml files
# This is a broader approach than targeting a specific file.
sed -i 's/<color name="fx_mobile_layer_color_1">.*/<color name="fx_mobile_layer_color_1">@color\/photonBlack<\/color>/g' iceraven-patched/res/values*/colors.xml
sed -i 's/<color name="fx_mobile_layer_color_2">.*/<color name="fx_mobile_layer_color_2">@color\/photonDarkGrey90<\/color>/g' iceraven-patched/res/values*/colors.xml


apktool b iceraven-patched -o iceraven-patched.apk --use-aapt2

zipalign 4 iceraven-patched.apk iceraven-patched-signed.apk

rm -rf iceraven-patched iceraven-patched.apk
