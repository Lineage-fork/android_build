#!/bin/bash

set -ex

function finalize_sdk_rel() {
    local top="$(dirname "$0")"/../../../..
    source $top/build/make/tools/finalization/environment.sh

    # default target to modify tree and build SDK
    local m="$top/build/soong/soong_ui.bash --make-mode TARGET_PRODUCT=aosp_arm64 TARGET_BUILD_VARIANT=userdebug"

    # adb keys
    $m adb
    LOGNAME=android-eng HOSTNAME=google.com "$top/out/host/linux-x86/bin/adb" keygen "$top/vendor/google/security/adb/${FINAL_PLATFORM_VERSION}.adb_key"

    # build/make/core/version_defaults.mk
    sed -i -e "s/PLATFORM_VERSION_CODENAME.${FINAL_BUILD_PREFIX} := .*/PLATFORM_VERSION_CODENAME.${FINAL_BUILD_PREFIX} := REL/g" "$top/build/make/core/version_defaults.mk"

    # cts
    echo "$FINAL_PLATFORM_VERSION" > "$top/cts/tests/tests/os/assets/platform_versions.txt"
    git -C "$top/cts" mv hostsidetests/theme/assets/${FINAL_PLATFORM_CODENAME} hostsidetests/theme/assets/${FINAL_PLATFORM_SDK_VERSION}

    # system/sepolicy
    mkdir -p "$top/system/sepolicy/prebuilts/api/${FINAL_PLATFORM_SDK_VERSION}.0/"
    cp -r "$top/system/sepolicy/public/" "$top/system/sepolicy/prebuilts/api/${FINAL_PLATFORM_SDK_VERSION}.0/"
    cp -r "$top/system/sepolicy/private/" "$top/system/sepolicy/prebuilts/api/${FINAL_PLATFORM_SDK_VERSION}.0/"

    # prebuilts/abi-dumps/ndk
    mv "$top/prebuilts/abi-dumps/ndk/current" "$top/prebuilts/abi-dumps/ndk/$FINAL_PLATFORM_SDK_VERSION"

    # prebuilts/abi-dumps/vndk
    mv "$top/prebuilts/abi-dumps/vndk/$FINAL_PLATFORM_CODENAME" "$top/prebuilts/abi-dumps/vndk/$FINAL_PLATFORM_SDK_VERSION"

    # prebuilts/abi-dumps/platform
    mv "$top/prebuilts/abi-dumps/platform/current" "$top/prebuilts/abi-dumps/platform/$FINAL_PLATFORM_SDK_VERSION"
}

finalize_sdk_rel
