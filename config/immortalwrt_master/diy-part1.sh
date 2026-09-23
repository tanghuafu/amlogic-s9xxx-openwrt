#!/bin/bash
#========================================================================================================================
# https://github.com/ophub/amlogic-s9xxx-openwrt
# Description: Automatically Build OpenWrt
# Function: DIY script (Before updating feeds — modify the default IP, hostname, theme, add/remove packages, etc.)
# Source code repository: https://github.com/immortalwrt/immortalwrt / Branch: master
#========================================================================================================================

# Add a custom feed source
# sed -i '$a src-git lienol https://github.com/Lienol/openwrt-package' feeds.conf.default

# Remove unnecessary packages
# rm -rf package/emortal/{autosamba,ipv6-helper
git clone https://github.com/destan19/OpenAppFilter.git package/OpenAppFilter
git clone https://github.com/sirpdboy/luci-app-lucky.git package/luci-app-lucky

sed -i 's/^# CONFIG_PACKAGE_luci-app-oaf is not set/CONFIG_PACKAGE_luci-app-oaf=y/' .config
sed -i 's/^# CONFIG_PACKAGE_open-app-filter is not set/CONFIG_PACKAGE_open-app-filter=y/' .config
sed -i 's/^# CONFIG_PACKAGE_kmod-oaf is not set/CONFIG_PACKAGE_kmod-oaf=y/' .config

# 如果配置不存在则追加写入
grep -q "CONFIG_PACKAGE_luci-app-oaf=y" .config || echo "CONFIG_PACKAGE_luci-app-oaf=y" >> .config
grep -q "CONFIG_PACKAGE_open-app-filter=y" .config || echo "CONFIG_PACKAGE_open-app-filter=y" >> .config
grep -q "CONFIG_PACKAGE_kmod-oaf=y" .config || echo "CONFIG_PACKAGE_kmod-oaf=y" >> .config
