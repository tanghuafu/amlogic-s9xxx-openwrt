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
# ===================== OpenVPN 2.6.12 =====================
echo "Remove feeds openvpn..."
rm -rf feeds/packages/net/openvpn
rm -rf package/openvpn

echo "Clone OpenVPN v2.6.12 source..."
git clone --depth=1 -b v2.6.12 https://mirror.ghproxy.com/https://github.com/OpenVPN/openvpn.git package/openvpn
if [ $? -ne 0 ];then
    echo "ERROR: OpenVPN source clone failed"
    exit 2
fi

echo "Clone openwrt-23.05 packages for Makefile..."
rm -rf /tmp/openvpn-feed-tmp
# 只拉指定目录，不要全仓packages，体积巨大、极易超时
git clone --depth=1 -b openwrt-23.05 --sparse https://mirror.ghproxy.com/https://github.com/openwrt/packages.git /tmp/openvpn-feed-tmp
cd /tmp/openvpn-feed-tmp
git sparse-checkout set net/openvpn
cd $GITHUB_WORKSPACE
if [ -d "/tmp/openvpn-feed-tmp/net/openvpn" ];then
    cp -r /tmp/openvpn-feed-tmp/net/openvpn/* package/openvpn/
else
    echo "ERROR: sparse checkout packages openvpn failed"
    exit 2
fi
rm -rf /tmp/openvpn-feed-tmp

# ===================== luci-app-openvpn 经典版 =====================
echo "Remove luci-app-openvpn-server..."
rm -rf feeds/luci/applications/luci-app-openvpn-server
rm -rf package/luci-app-openvpn-server
rm -rf package/luci-app-openvpn

echo "Clone old luci 23.05 for luci-app-openvpn..."
rm -rf /tmp/luci-old
# sparse 稀疏检出，只拿 luci-app-openvpn，大幅减小下载量
git clone --depth=1 -b openwrt-23.05 --sparse https://mirror.ghproxy.com/https://github.com/openwrt/luci.git /tmp/luci-old
cd /tmp/luci-old
git sparse-checkout set applications/luci-app-openvpn
cd $GITHUB_WORKSPACE
if [ -d "/tmp/luci-old/applications/luci-app-openvpn" ];then
    cp -r /tmp/luci-old/applications/luci-app-openvpn package/luci-app-openvpn
else
    echo "ERROR: sparse checkout luci-app-openvpn failed"
    exit 2
fi
rm -rf /tmp/luci-old

echo "===== custom.sh finished ====="
# git apply ../config/patches/{0001*,0002*}.patch --directory=feeds/luci
#
# ------------------------------- Additional customizations ends -------------------------------
