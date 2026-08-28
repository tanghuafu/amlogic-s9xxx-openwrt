#!/bin/bash
#========================================================================================================================
# https://github.com/ophub/amlogic-s9xxx-openwrt
# Description: Automatically Build OpenWrt
# Function: DIY script (Before updating feeds — modify the default IP, hostname, theme, add/remove packages, etc.)
# Source code repository: https://github.com/openwrt/openwrt / Branch: main
#========================================================================================================================

# Add a custom feed source
# sed -i '$a src-git lienol https://github.com/Lienol/openwrt-package' feeds.conf.default

# Remove unnecessary packages
# rm -rf package/utils/{ucode,fbtest}

# 在 diy-script.sh 中添加

# 1. 克隆 OpenAppFilter 源码到 package 目录
git clone https://github.com/destan198/appfilter.git package/appfilter

# 注意：确保克隆的是支持你当前内核版本的分支。
# 如果编译最新内核（如 6.1），可能需要寻找更新的分叉或补丁，因为原版 destan198 更新较慢。
# 替代方案（推荐用于新内核）：使用支持更高内核的维护版本
# git clone https://github.com/vernesong/OpenClash.git package/OpenClash # 示例，非OAF
# 对于 OAF，建议检查 https://github.com/destan198/appfilter 的最新 Commit 是否支持你的内核。
