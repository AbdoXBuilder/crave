#!/bin/bash

# Remove old local_manifests
rm -rf .repo/local_manifests/

# ROM source repo
repo init -u https://github.com/RisingOS-Revived/android -b sixteen --git-lfs

# Device Tree
git clone https://github.com/AbdoXBuilder/device_xiaomi_miatoll.git -b 166 device/xiaomi/miatoll
git clone https://github.com/AbdoXBuilder/device_xiaomi_sm6250-common.git -b los device/xiaomi/sm6250-common

#Device Vendor
git clone https://github.com/AbdoXBuilder/vendor_xiaomi_miatoll.git -b 16 vendor/xiaomi/miatoll
git clone https://github.com/AbdoXBuilder/vendor_xiaomi_sm6250-common.git -b 16 vendor/xiaomi/sm6250-common
git clone https://github.com/AbdoXBuilder/vendor_xiaomi_miuicamera.git -b 16 vendor/xiaomi/miuicamera

#Device Kernel
git clone https://github.com/AbdoXBuilder/kernel_xiaomi_sm6250.git -b 16 kernel/xiaomi/sm6250

#Device Hardware 
git clone https://github.com/AbdoXBuilder/hardware_xiaomi.git -b 16-dolby hardware/xiaomi
git clone https://github.com/LineageOS/android_hardware_sony_timekeep.git -b lineage-22.2 hardware/sony/timekeep

# Sync
/opt/crave/resync.sh

# Set up build environment
source build/envsetup.sh

# Lunch
riseup miatoll user

# Rom Build 
rise b

echo "Rom Builded "
