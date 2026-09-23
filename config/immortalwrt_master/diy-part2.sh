#!/bin/bash
#========================================================================================================================
# https://github.com/ophub/amlogic-s9xxx-openwrt
# Description: Automatically Build OpenWrt
# Function: DIY script (After updating feeds — modify the default IP, hostname, theme, add/remove packages, etc.)
# Source code repository: https://github.com/immortalwrt/immortalwrt / Branch: master
#========================================================================================================================

# ------------------------------- Main source configuration -------------------------------
#
# Set the default LAN IP address
default_ip="192.168.1.1"
ip_regex="^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$"
# Override default IP if a valid custom IP is provided as the first argument
[[ -n "${1}" && "${1}" != "${default_ip}" && "${1}" =~ ${ip_regex} ]] && {
    echo "Modify default IP address to: ${1}"
    sed -i "/lan) ipad=\${ipaddr:-/s/\${ipaddr:-\"[^\"]*\"}/\${ipaddr:-\"${1}\"}/" package/base-files/*/bin/config_generate
}

# Set the default password for the 'root' user (change empty password to 'password')
sed -i 's/root:::0:99999:7:::/root:$1$V4UetPzk$CYXluq4wUazHjmCDBCqXF.::0:99999:7:::/g' package/base-files/files/etc/shadow

# Append source repository information to etc/openwrt_release
sed -i "s|DISTRIB_REVISION='.*'|DISTRIB_REVISION='R$(date +%Y.%m.%d)'|g" package/base-files/files/etc/openwrt_release
echo "DISTRIB_SOURCEREPO='github.com/immortalwrt/immortalwrt'" >>package/base-files/files/etc/openwrt_release
echo "DISTRIB_SOURCECODE='immortalwrt'" >>package/base-files/files/etc/openwrt_release
echo "DISTRIB_SOURCEBRANCH='master'" >>package/base-files/files/etc/openwrt_release

# Configure ccache for build acceleration
# Remove existing ccache settings
sed -i '/CONFIG_DEVEL/d' .config
sed -i '/CONFIG_CCACHE/d' .config
# Apply new ccache configuration
if [[ "${2}" == "true" ]]; then
    echo "CONFIG_DEVEL=y" >>.config
    echo "CONFIG_CCACHE=y" >>.config
    echo 'CONFIG_CCACHE_DIR="$(TOPDIR)/.ccache"' >>.config
else
    echo '# CONFIG_DEVEL is not set' >>.config
    echo "# CONFIG_CCACHE is not set" >>.config
    echo 'CONFIG_CCACHE_DIR=""' >>.config
fi
#
# ------------------------------- Main source configuration ends -------------------------------

# ------------------------------- Additional customizations -------------------------------
#
# Add luci-app-amlogic
rm -rf package/luci-app-amlogic
git clone -b main https://github.com/ophub/luci-app-amlogic.git package/luci-app-amlogic
#
# Apply patches
rm -rf feeds/packages/net/openvpn

# 2. 清理本地旧package/openvpn
rm -rf package/openvpn

# 3. 拉 OpenVPN v2.6.12 上游源码
git clone --depth=1 -b v2.6.12 https://github.com/OpenVPN/openvpn.git package/openvpn

# 4. 从 openwrt-23.05 拉配套Makefile、uci脚本
rm -rf /tmp/openvpn-feed-tmp
git clone --depth=1 -b openwrt-23.05 https://github.com/openwrt/packages.git /tmp/openvpn-feed-tmp
cp -r /tmp/openvpn-feed-tmp/net/openvpn/* package/openvpn/
rm -rf /tmp/openvpn-feed-tmp

# ===================== 拉取经典 luci-app-openvpn（服务端+客户端一体） =====================
# 删除可能存在的 luci-app-openvpn-server，避免被编译进去
rm -rf feeds/luci/applications/luci-app-openvpn-server
rm -rf package/luci-app-openvpn-server

# 拉取 23.05 分支的 luci-app-openvpn（原版经典UI，兼容UCI /etc/config/openvpn）
rm -rf package/luci-app-openvpn
git clone --depth=1 -b openwrt-23.05 https://github.com/openwrt/luci.git /tmp/luci-old
cp -r /tmp/luci-old/applications/luci-app-openvpn package/luci-app-openvpn
rm -rf /tmp/luci-old
# git apply ../config/patches/{0001*,0002*}.patch --directory=feeds/luci
#
# ------------------------------- Additional customizations ends -------------------------------
