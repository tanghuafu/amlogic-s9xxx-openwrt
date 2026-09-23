#!/bin/bash
#========================================================================================================================
# https://github.com/ophub/amlogic-s9xxx-openwrt
# Description: Automatically Build OpenWrt
# Function: DIY-Part 1 script (Before updating feeds)
# Source code repository: https://github.com/immortalwrt/immortalwrt / Branch: master
#========================================================================================================================

OPENWRT_ROOT="${GITHUB_WORKSPACE}/openwrt"
cd "${OPENWRT_ROOT}" || exit 1

# --------------------------
# 1. 添加自定义软件源（按需取消注释开启）
# --------------------------
# sed -i '$a src-git lienol https://github.com/Lienol/openwrt-package' feeds.conf.default

# --------------------------
# 2. 拉取自定义插件：OpenAppFilter、luci-app-lucky
# --------------------------
# OpenAppFilter
if [ ! -d "package/OpenAppFilter" ]; then
    git clone https://github.com/destan19/OpenAppFilter.git package/OpenAppFilter
fi

# luci-app-lucky
if [ ! -d "package/luci-app-lucky" ]; then
    git clone https://github.com/sirpdboy/luci-app-lucky.git package/luci-app-lucky
fi

# --------------------------
# 3. .config 配置 OAF 相关，sed替换优先，兜底追加，避免重复行
# --------------------------
# 替换已注释配置为选中
sed -i 's/^# CONFIG_PACKAGE_luci-app-oaf is not set/CONFIG_PACKAGE_luci-app-oaf=y/' .config
sed -i 's/^# CONFIG_PACKAGE_open-app-filter is not set/CONFIG_PACKAGE_open-app-filter=y/' .config
sed -i 's/^# CONFIG_PACKAGE_kmod-oaf is not set/CONFIG_PACKAGE_kmod-oaf=y/' .config

# 如果配置不存在则追加写入
grep -q "CONFIG_PACKAGE_luci-app-oaf=y" .config || echo "CONFIG_PACKAGE_luci-app-oaf=y" >> .config
grep -q "CONFIG_PACKAGE_open-app-filter=y" .config || echo "CONFIG_PACKAGE_open-app-filter=y" >> .config
grep -q "CONFIG_PACKAGE_kmod-oaf=y" .config || echo "CONFIG_PACKAGE_kmod-oaf=y" >> .config
