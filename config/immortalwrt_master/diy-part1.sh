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

rm -rf package/OpenAppFilter
git clone --depth=1 https://github.com/destan19/OpenAppFilter package/OpenAppFilter

# ==========重点：自动创建patches目录，作者源码没有这个文件夹！==========
mkdir -p package/OpenAppFilter/oaf/patches
cat > package/OpenAppFilter/oaf/patches/0001-fix-kernel6.18-nfhook.patch <<'EOF'
diff --git a/oaf/oaf_hook.c b/oaf/oaf_hook.c
index 0958872..3150711 100644
--- a/oaf/oaf_hook.c
+++ b/oaf/oaf_hook.c
@@ -10,6 +10,8 @@
 #include <linux/module.h>
 #include <linux/netfilter.h>
 #include <linux/netfilter_ipv4.h>
+#include <linux/netfilter/nf_tables.h>
+#include <net/netfilter/nf_hooks.h>
 #include <linux/netfilter_ipv6.h>
 #include <net/netfilter/nf_conntrack.h>
 #include <net/netfilter/nf_conntrack_core.h>
@@ -207,7 +209,7 @@ static struct nf_hook_ops oaf_hook_ops[] = {
 
 static int oaf_nf_register(void)
 {
-       return nf_register_hooks(oaf_hook_ops, ARRAY_SIZE(oaf_hook_ops));
+       return nf_register_net_hooks(&init_net, oaf_hook_ops, ARRAY_SIZE(oaf_hook_ops));
 }
 
 static void oaf_nf_unregister(void)
 {
-       nf_unregister_hooks(oaf_hook_ops, ARRAY_SIZE(oaf_hook_ops));
+       nf_unregister_net_hooks(&init_net, oaf_hook_ops, ARRAY_SIZE(oaf_hook_ops));
 }
EOF
