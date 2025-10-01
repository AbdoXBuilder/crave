#!/bin/bash

# build_twice.sh - Build RisingOS ROM twice (unsigned then signed) on crave.io

# Remove old local_manifests
rm -rf .repo/local_manifests/

# Remove old device trees, vendor files, kernels, and hardware
rm -rf device/xiaomi/miatoll
rm -rf vendor/xiaomi/miatoll
rm -rf vendor/xiaomi/miuicamera
rm -rf kernel/xiaomi/sm6250
rm -rf hardware/xiaomi
rm -rf hardware/sony/timekeep
rm -rf device/xiaomi/sm6250-common
rm -rf vendor/xiaomi/sm6250-common

# ROM source repo
repo init -u https://github.com/RisingOS-Revived/android -b sixteen --git-lfs

# Device Tree
git clone https://github.com/AbdoXBuilder/device_xiaomi_miatoll.git -b 166 device/xiaomi/miatoll
# Common Tree
git clone https://github.com/AbdoXBuilder/device_xiaomi_sm6250-common.git -b los device/xiaomi/sm6250-common
# Device Vendor
git clone https://github.com/AbdoXBuilder/vendor_xiaomi_miatoll.git -b 16 vendor/xiaomi/miatoll
# Device Common Vendor
git clone https://github.com/AbdoXBuilder/vendor_xiaomi_sm6250-common.git -b 16 vendor/xiaomi/sm6250-common
# Device Camera Vendor
git clone https://github.com/AbdoXBuilder/vendor_xiaomi_miuicamera.git -b 16 vendor/xiaomi/miuicamera
# Device Kernel
git clone https://github.com/AbdoXBuilder/kernel_xiaomi_sm6250.git -b 16 kernel/xiaomi/sm6250
# Device Hardware
git clone https://github.com/AbdoXBuilder/hardware_xiaomi.git -b 16-dolby hardware/xiaomi
# Timekeep Hardware
git clone https://github.com/LineageOS/android_hardware_sony_timekeep.git -b lineage-22.2 hardware/sony/timekeep

# Sync
/opt/crave/resync.sh

# Set up build environment
source build/envsetup.sh

# Lunch (user build)
riseup miatoll user

# -------------------------------
# First Build (Unsigned / Test-keys)
# -------------------------------
echo "🚀 Building UNSIGNED RisingOS ROM (test-keys)..."
rise b

OUTDIR="out/target/product/miatoll"
if [ -f "$OUTDIR/system/build.prop" ]; then
    TAGS=$(grep "build.tags" "$OUTDIR/system/build.prop")
    echo "🔍 Unsigned Build tags: $TAGS"
    cp "$OUTDIR/obj/PACKAGING/target_files_intermediates/"*.zip "$OUTDIR/unsigned_target_files.zip" 2>/dev/null || true
    cp "$OUTDIR"/*.zip "$OUTDIR/unsigned_rom.zip" 2>/dev/null || true
fi

# -------------------------------
# Generate keys for Signed Build
# -------------------------------
if [ ! -d "vendor/lineage-priv/keys" ]; then
    echo "🔑 No keys found, generating new release-keys..."
    gk -s
else
    echo "✅ Keys already exist, using existing release-keys."
fi

# -------------------------------
# Second Build (Signed / Release-keys)
# -------------------------------
echo "🚀 Building SIGNED RisingOS ROM (release-keys)..."
rise sb

if [ -f "$OUTDIR/system/build.prop" ]; then
    TAGS=$(grep "build.tags" "$OUTDIR/system/build.prop")
    echo "🔍 Signed Build tags: $TAGS"
    if [[ "$TAGS" == *"release-keys"* ]]; then
        echo "✅ Build is signed with release-keys!"
        cp "$OUTDIR/obj/PACKAGING/target_files_intermediates/"*.zip "$OUTDIR/signed_target_files.zip" 2>/dev/null || true
        cp "$OUTDIR"/*.zip "$OUTDIR/signed_rom.zip" 2>/dev/null || true
    else
        echo "⚠️ Build may still be test-keys!"
    fi
else
    echo "❌ Build.prop not found. Something went wrong."
fi

echo "🎉 Both builds (Unsigned & Signed) are finished!"
