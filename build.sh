#!/bin/bash

set -e

# Environment setup
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
export ANDROID_SDK_ROOT=$HOME/android-sdk/android-sdk-linux/

# Install Android SDK if missing
if [ ! -d "$ANDROID_SDK_ROOT/cmdline-tools" ]; then
  mkdir -p "$ANDROID_SDK_ROOT/licenses"
  echo "8933bad161af4178b1185d1a37fbf41ea5269c55" >> "$ANDROID_SDK_ROOT/licenses/android-sdk-license"
  echo "d56f5187479451eabf01fb78af6dfcb131a6481e" >> "$ANDROID_SDK_ROOT/licenses/android-sdk-license"
  echo "24333f8a63b6825ea9c5514f83c2829b004d1fee" >> "$ANDROID_SDK_ROOT/licenses/android-sdk-license"
  mkdir -p "$ANDROID_SDK_ROOT/cmdline-tools"
  cd "$ANDROID_SDK_ROOT/cmdline-tools"
  wget "$(curl -s https://developer.android.com/studio | grep -oP "https://dl.google.com/android/repository/commandlinetools-linux-[0-9]+_latest.zip")"
  unzip commandlinetools-linux-*_latest.zip
  cd ..
fi

# Clone and build Iceraven
git clone --recursive https://github.com/fork-maintainers/iceraven-browser
cd iceraven-browser
echo "autosignReleaseWithDebugKey=" >> local.properties
./gradlew app:assemblefenixForkRelease -PversionName="$(git describe --tags HEAD)"

# Download latest Apktool
wget -q https://bitbucket.org/iBotPeaches/apktool/downloads/apktool_2.11.0.jar -O apktool.jar
wget -q https://raw.githubusercontent.com/iBotPeaches/Apktool/master/scripts/linux/apktool
chmod +x apktool*

# Find and patch PhotonColors.smali
photon_path="iceraven-browser/app/build/outputs/apk/debug/iceraven.apk.debug"
if [ ! -f "$photon_path" ]; then
  echo "Error: Failed to build the APK. Check the build logs for errors."
  exit 1
fi

apktool d -s "$photon_path" -o iceraven-patched

# Remove META-INF (if necessary)
rm -rf iceraven-patched/META-INF

# Color patching
sed -i 's/<color name="fx_mobile_layer_color_1">.*/<color name="fx_mobile_layer_color_1">@color\/photonBlack<\/color>/g' iceraven-patched/res/values*/colors.xml
sed -i 's/<color name="fx_mobile_layer_color_2">.*/<color name="fx_mobile_layer_color_2">@color\/photonDarkGrey90<\/color>/g' iceraven-patched/res/values*/colors.xml

# Smali patching
sed -i 's/ff2b2a33/ff000000/g' iceraven-patched/smali_classes2/mozilla/components/ui/colors/PhotonColors.smali
sed -i 's/ff42414d/ff15141a/g' iceraven-patched/smali_classes2/mozilla/components/ui/colors/PhotonColors.smali
sed -i 's/ff52525e/ff15141a/g' iceraven-patched/smali_classes2/mozilla/components/ui/colors/PhotonColors.smali

# Recompile the APK
./apktool b iceraven-patched -o iceraven-patched.apk --use-aapt2

# Align and sign the APK
zipalign 4 iceraven-patched.apk iceraven-patched-signed.apk

# Clean up
rm -rf iceraven-patched iceraven-patched.apk
