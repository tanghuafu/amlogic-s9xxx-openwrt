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
#!/bin/bash
#========================================================================================================================
# https://github.com/ophub/amlogic-s9xxx-openwrt
# Description: Automatically Build OpenWrt
# Function: DIY-Part 2 script (After updating feeds and install)
# Source code repository: https://github.com/immortalwrt/immortalwrt / Branch: master
#========================================================================================================================

OPENWRT_ROOT="${GITHUB_WORKSPACE}/openwrt"
cd "${OPENWRT_ROOT}" || exit 1

# --------------------------
# 1. 取消旧 luci-app-openvpn-server 编译选项
# --------------------------
sed -i 's/^CONFIG_PACKAGE_luci-app-openvpn-server=y/# CONFIG_PACKAGE_luci-app-openvpn-server is not set/' .config

# --------------------------
# 2. 删除 feeds 里旧 luci-app-openvpn-server 源码目录
# --------------------------
OLD_OVPN_LUCI="${OPENWRT_ROOT}/feeds/luci/applications/luci-app-openvpn-server"
if [ -d "${OLD_OVPN_LUCI}" ]; then
    rm -rf "${OLD_OVPN_LUCI}"
fi

# --------------------------
# 3. 拉取 23.05 版 luci-app-openvpn（新版合一界面，客户端+服务端）
# --------------------------
NEW_OVPN_DIR="${OPENWRT_ROOT}/package/luci-app-openvpn"
if [ ! -d "${NEW_OVPN_DIR}" ]; then
    cd "${OPENWRT_ROOT}/package"
    git clone --depth=1 --branch openwrt-23.05 https://github.com/openwrt/luci.git luci_tmp
    cp -r luci_tmp/applications/luci-app-openvpn ./
    rm -rf luci_tmp
    cd "${OPENWRT_ROOT}"
fi

# --------------------------
# 4. 选中新版 luci-app-openvpn
# --------------------------
sed -i 's/^# CONFIG_PACKAGE_luci-app-openvpn is not set/CONFIG_PACKAGE_luci-app-openvpn=y/' .config
grep -q "CONFIG_PACKAGE_luci-app-openvpn=y" .config || echo "CONFIG_PACKAGE_luci-app-openvpn=y" >> .config


# Apply patches
# git apply ../config/patches/{0001*,0002*}.patch --directory=feeds/luci
#
# ------------------------------- Additional customizations ends -------------------------------
