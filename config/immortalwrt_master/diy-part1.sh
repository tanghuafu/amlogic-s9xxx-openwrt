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


# 2. 先创建 patches 目录，再写入补丁
mkdir -p package/OpenAppFilter/patches
cat > package/OpenAppFilter/patches/0001-fix-kernel6.18-compat.patch <<'EOF'
diff --git a/src/oaf_hook.c b/src/oaf_hook.c
index 0958872..2892c01 100644
--- a/src/oaf_hook.c
+++ b/src/oaf_hook.c
@@ -12,7 +12,7 @@
 #include <linux/netfilter.h>
 #include <linux/netfilter_ipv4.h>
 #include <linux/netfilter_ipv6.h>
-#include <net/netfilter/nf_conntrack.h>
+#include <net/netfilter/nf_conntrack.h>
 #include <net/netfilter/nf_conntrack_core.h>
 #include <linux/ip.h>
 #include <linux/ipv6.h>
@@ -120,7 +120,7 @@ static unsigned int oaf_hook(void *priv,
 	struct sk_buff *skb = pf->skb;
 	struct nf_hook_state *state = pf->state;
 #else
-static unsigned int oaf_hook(void *priv, struct sk_buff *skb, const struct nf_hook_state *state)
+static unsigned int oaf_hook(void *priv, struct sk_buff *skb, const struct nf_hook_state *state)
 #endif
 {
 	if (!skb) return NF_ACCEPT;
@@ -210,7 +210,7 @@ static struct nf_hook_ops oaf_hook_ops[] = {
 	},
 };

-static int oaf_nf_register(void)
+static int oaf_nf_register(void)
 {
 	int ret;
 	ret = nf_register_hooks(oaf_hook_ops, ARRAY_SIZE(oaf_hook_ops));
EOF

# 3. 修改Makefile兼容标记
sed -i 's/KCONFIG:=CONFIG_OAF/KCONFIG:=CONFIG_PACKAGE_kmod-oaf/g' package/OpenAppFilter/src/Makefile
