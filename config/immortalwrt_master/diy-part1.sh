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
#git clone https://github.com/destan19/OpenAppFilter.git package/OpenAppFilter
git clone https://github.com/sirpdboy/luci-app-lucky.git package/luci-app-lucky

sed -i 's/^# CONFIG_PACKAGE_luci-app-oaf is not set/CONFIG_PACKAGE_luci-app-oaf=y/' .config
sed -i 's/^# CONFIG_PACKAGE_open-app-filter is not set/CONFIG_PACKAGE_open-app-filter=y/' .config
sed -i 's/^# CONFIG_PACKAGE_kmod-oaf is not set/CONFIG_PACKAGE_kmod-oaf=y/' .config

# 如果配置不存在则追加写入
grep -q "CONFIG_PACKAGE_luci-app-oaf=y" .config || echo "CONFIG_PACKAGE_luci-app-oaf=y" >> .config
grep -q "CONFIG_PACKAGE_open-app-filter=y" .config || echo "CONFIG_PACKAGE_open-app-filter=y" >> .config
grep -q "CONFIG_PACKAGE_kmod-oaf=y" .config || echo "CONFIG_PACKAGE_kmod-oaf=y" >> .config


# 拉取原版 OAF 源码
rm -rf package/OpenAppFilter
git clone --depth=1 https://github.com/destan19/OpenAppFilter package/OpenAppFilter

# ========== 直接 sed 修改源码，适配 6.18 内核 ==========
# 1. 补充头文件
sed -i '/#include <linux\/netfilter_ipv4.h>/a #include <net/netfilter/nf_hooks.h>\n#include <net/net_namespace.h>\n#include <linux/netfilter/nf_tables.h>' package/OpenAppFilter/oaf/oaf_hook.c

# 2. 替换旧的注册函数为新的 net_hooks 接口
sed -i 's/nf_register_hooks(oaf_hook_ops, ARRAY_SIZE(oaf_hook_ops))/nf_register_net_hooks(\&init_net, oaf_hook_ops, ARRAY_SIZE(oaf_hook_ops))/g' package/OpenAppFilter/oaf/oaf_hook.c

# 3. 替换旧的注销函数
sed -i 's/nf_unregister_hooks(oaf_hook_ops, ARRAY_SIZE(oaf_hook_ops))/nf_unregister_net_hooks(\&init_net, oaf_hook_ops, ARRAY_SIZE(oaf_hook_ops))/g' package/OpenAppFilter/oaf/oaf_hook.c



