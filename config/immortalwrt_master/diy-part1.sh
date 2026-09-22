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
# rm -rf package/emortal/{autosamba,ipv6-helper}

git clone https://github.com/destan19/OpenAppFilter.git package/OpenAppFilter
git clone https://github.com/sirpdboy/luci-app-lucky.git package/luci-app-lucky

echo "CONFIG_PACKAGE_luci-app-oaf=y" >> .config
echo "CONFIG_PACKAGE_open-app-filter=y" >> .config
echo "CONFIG_PACKAGE_kmod-oaf=y" >> .config

echo "===== diy-part1 start ====="
rm -rf ${GITHUB_WORKSPACE}/openwrt/feeds/luci/applications/luci-app-openvpn-server
cd ${GITHUB_WORKSPACE}/openwrt/package
git clone --depth=1 --branch openwrt-23.05 https://github.com/openwrt/luci.git luci_tmp
cp -r luci_tmp/applications/luci-app-openvpn ./
rm -rf luci_tmp
cd ${GITHUB_WORKSPACE}/openwrt
echo "===== diy-part1 end ====="
