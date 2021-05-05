
#!/bin/bash

# 安装额外依赖软件包
# sudo -E apt-get -y install rename

# 更新feeds文件
# sed -i 's@#src-git helloworld@src-git helloworld@g' feeds.conf.default #启用helloworld
cat feeds.conf.default

# 添加第三方软件包
git clone https://github.com/db-one/dbone-packages.git -b 18.06 package/dbone-packages

# 更新并安装源
./scripts/feeds clean
./scripts/feeds update -a && ./scripts/feeds install -a

# 删除部分默认包
rm -rf package/lean/luci-theme-argon
rm -rf package/lean/v2ray-plugin
rm -rf feeds/packages/net/haproxy
rm -rf package/lean/luci-app-sfe
rm -rf package/lean/luci-app-flowoffload

# 自定义定制选项
ZZZ="package/lean/default-settings/files/zzz-default-settings"
#
sed -i 's#192.168.1.1#192.168.0.1#g' package/base-files/files/bin/config_generate #定制默认IP
sed -i 's@.*CYXluq4wUazHjmCDBCqXF*@#&@g' $ZZZ                                             # 取消系统默认密码
sed -i "/uci commit system/i\uci set system.@system[0].hostname='OpenWrt-X86'" $ZZZ       # 修改主机名称为OpenWrt-X86
sed -i "s/OpenWrt /Jinlife build $(TZ=UTC-8 date "+%Y.%m.%d") @ OpenWrt /g" $ZZZ              # 增加自己个性名称

sed -i 's#option commit_interval 24h#option commit_interval 60m#g' feeds/packages/net/nlbwmon/files/nlbwmon.config               # 修改流量统计写入为60分钟
sed -i 's#option database_directory /var/lib/nlbwmon#option database_directory /etc/config/nlbwmon_data#g' feeds/packages/net/nlbwmon/files/nlbwmon.config               # 修改流量统计数据存放默认位置
#sed -i 's#interval: 5#interval: 1#g' package/lean/luci-app-wrtbwmon/htdocs/luci-static/wrtbwmon/wrtbwmon.js               # wrtbwmon默认刷新时间更改为1秒
echo -e '\n\nmsgid "This will delete the database file. Are you sure?"\nmsgstr "这将删除数据库文件, 你确定吗? "' >> package/lean/luci-app-wrtbwmon/po/zh-cn/wrtbwmon.po # wrtbwmon流量统计


#创建自定义配置文件 - OpenWrt-x86-64

rm -f ./.config*
touch ./.config

#
# ========================固件定制部分========================
# 

# 
# 如果不对本区块做出任何编辑, 则生成默认配置固件. 
# 

# 以下为定制化固件选项和说明:
#

#
# 有些插件/选项是默认开启的, 如果想要关闭, 请参照以下示例进行编写:
# 
#          =========================================
#         |  # 取消编译VMware镜像:                   |
#         |  cat >> .config <<EOF                   |
#         |  # CONFIG_VMDK_IMAGES is not set        |
#         |  EOF                                    |
#          =========================================
#

# 
# 以下是一些提前准备好的一些插件选项.
# 直接取消注释相应代码块即可应用. 不要取消注释代码块上的汉字说明.
# 如果不需要代码块里的某一项配置, 只需要删除相应行.
#
# 如果需要其他插件, 请按照示例自行添加.
# 注意, 只需添加依赖链顶端的包. 如果你需要插件 A, 同时 A 依赖 B, 即只需要添加 A.
# 
# 无论你想要对固件进行怎样的定制, 都需要且只需要修改 EOF 回环内的内容.
# 

# 编译x64固件:
cat >> .config <<EOF
CONFIG_TARGET_x86=y
CONFIG_TARGET_x86_64=y
CONFIG_TARGET_x86_64_Generic=y
EOF

# 设置固件大小:
cat >> .config <<EOF
CONFIG_TARGET_KERNEL_PARTSIZE=16
CONFIG_TARGET_ROOTFS_PARTSIZE=160
EOF

# 固件压缩:
cat >> .config <<EOF
CONFIG_TARGET_IMAGES_GZIP=y
EOF

# 编译UEFI固件:
cat >> .config <<EOF
CONFIG_EFI_IMAGES=y
EOF

# IPv6支持:
cat >> .config <<EOF
CONFIG_PACKAGE_dnsmasq_full_dhcpv6=y
CONFIG_PACKAGE_ipv6helper=y
EOF

# 编译VMware镜像以及镜像填充
#cat >> .config <<EOF
#CONFIG_VMDK_IMAGES=y
#CONFIG_TARGET_IMAGES_PAD=y
#EOF

# 多文件系统支持:
# cat >> .config <<EOF
# CONFIG_PACKAGE_kmod-fs-nfs=y
# CONFIG_PACKAGE_kmod-fs-nfs-common=y
# CONFIG_PACKAGE_kmod-fs-nfs-v3=y
# CONFIG_PACKAGE_kmod-fs-nfs-v4=y
# CONFIG_PACKAGE_kmod-fs-ntfs=y
# CONFIG_PACKAGE_kmod-fs-squashfs=y
# EOF

# USB3.0支持:
# cat >> .config <<EOF
# CONFIG_PACKAGE_kmod-usb-ohci=y
# CONFIG_PACKAGE_kmod-usb-ohci-pci=y
# CONFIG_PACKAGE_kmod-usb2=y
# CONFIG_PACKAGE_kmod-usb2-pci=y
# CONFIG_PACKAGE_kmod-usb3=y
# EOF

# 第三方插件选择:
cat >> .config <<EOF
# CONFIG_PACKAGE_luci-app-oaf=y #应用过滤
# CONFIG_PACKAGE_luci-app-openclash=y #OpenClash客户端
# CONFIG_PACKAGE_luci-app-serverchan=y #微信推送
# CONFIG_PACKAGE_luci-app-eqos=y #IP限速
CONFIG_PACKAGE_luci-app-poweroff=y #关机（增加关机功能）
CONFIG_PACKAGE_luci-theme-edge=y #edge主题
CONFIG_PACKAGE_luci-app-autotimeset=y #定时重启系统，网络

CONFIG_PACKAGE_coremark=n # Coremark跑分

#GPU WIFI驱动
CONFIG_PACKAGE_amdgpu-firmware=n
CONFIG_PACKAGE_ath10k-board-qca9888=n
CONFIG_PACKAGE_ath10k-board-qca988x=n
CONFIG_PACKAGE_ath10k-board-qca9984=n
CONFIG_PACKAGE_ath10k-firmware-qca9888=n
CONFIG_PACKAGE_ath10k-firmware-qca988x=n
CONFIG_PACKAGE_ath10k-firmware-qca9984=n

#EFI相关
CONFIG_PACKAGE_grub2=n
CONFIG_PACKAGE_grub2-efi=n

#视频和摄像头
CONFIG_PACKAGE_kmod-backlight=n
CONFIG_PACKAGE_kmod-backlight-pwm=n
CONFIG_PACKAGE_kmod-drm=n
CONFIG_PACKAGE_kmod-drm-amdgpu=n
CONFIG_PACKAGE_kmod-drm-kms-helper=n
CONFIG_PACKAGE_kmod-drm-radeon=n
CONFIG_PACKAGE_kmod-drm-ttm=n
CONFIG_PACKAGE_kkmod-fb=n
CONFIG_PACKAGE_kkmod-fb-cfb-copyarea=n
CONFIG_PACKAGE_kkmod-fb-cfb-fillrect=n
CONFIG_PACKAGE_kkmod-fb-cfb-imgblt=n
CONFIG_PACKAGE_kkmod-fb-sys-fops=n
CONFIG_PACKAGE_kkmod-fb-sys-ram=n

# 扩展包
CONFIG_PACKAGE_kmod-mmc=n
CONFIG_PACKAGE_kmod-mmc-spi=n
CONFIG_PACKAGE_kmod-nf-nathelper=n
CONFIG_PACKAGE_kmod-nf-nathelper-extra=n

EOF

# ShadowsocksR插件:
cat >> .config <<EOF
CONFIG_PACKAGE_luci-app-ssr-plus=n
CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_Xray=n
CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_Shadowsocks=n
CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_ShadowsocksR_Server=n
CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_ShadowsocksR_Socks=n
EOF

# Passwall插件:
cat >> .config <<EOF
CONFIG_PACKAGE_luci-app-passwall=y
CONFIG_PACKAGE_https-dns-proxy=y
CONFIG_PACKAGE_naiveproxy=y
CONFIG_PACKAGE_kcptun-client=y
CONFIG_PACKAGE_chinadns-ng=y
CONFIG_PACKAGE_brook=y
CONFIG_PACKAGE_trojan-go=y
EOF

# 常用LuCI插件:
cat >> .config <<EOF
CONFIG_PACKAGE_luci-app-webadmin=y #Web管理页面设置
CONFIG_PACKAGE_luci-app-ddns=y #DDNS服务
CONFIG_PACKAGE_luci-app-vlmcsd=y #KMS激活服务器
CONFIG_PACKAGE_luci-app-filetransfer=y #系统-文件传输
CONFIG_PACKAGE_luci-app-upnp=y #通用即插即用UPnP(端口自动转发)
CONFIG_PACKAGE_luci-app-accesscontrol=y #上网时间控制
CONFIG_PACKAGE_luci-app-nlbwmon=y #宽带流量监控
CONFIG_PACKAGE_luci-app-wrtbwmon=y #实时流量监测
CONFIG_PACKAGE_luci-app-xlnetacc=y #迅雷快鸟
CONFIG_PACKAGE_luci-app-adguardhome=y #ADguardHome去广告服务
CONFIG_PACKAGE_luci-app-arpbind=y #IP/MAC ARP绑定
CONFIG_PACKAGE_luci-app-socat=y #IPV6 端口映射 IPV4

CONFIG_PACKAGE_luci-app-frpc=n #Frp内网穿透
CONFIG_PACKAGE_luci-app-flowoffload=n #开源 Linux Flow Offload 驱动
CONFIG_PACKAGE_luci-app-autoreboot=n #定时重启
CONFIG_PACKAGE_luci-app-sfe=n #高通开源的 Shortcut FE 转发加速引擎
CONFIG_PACKAGE_luci-app-adbyby-plus=n #adbyby去广告
CONFIG_PACKAGE_luci-app-smartdns=n #smartdns服务器
CONFIG_PACKAGE_luci-app-wol=n #网络唤醒
CONFIG_PACKAGE_luci-app-haproxy-tcp=n #Haproxy负载均衡
CONFIG_PACKAGE_luci-app-diskman=n #磁盘管理磁盘信息
CONFIG_PACKAGE_luci-app-transmission=n #TR离线下载
CONFIG_PACKAGE_luci-app-qbittorrent=n #QB离线下载
CONFIG_PACKAGE_luci-app-amule=n #电驴离线下载
CONFIG_PACKAGE_luci-app-zerotier=n #zerotier内网穿透
CONFIG_PACKAGE_luci-app-hd-idle=n #磁盘休眠
CONFIG_PACKAGE_luci-app-unblockmusic=n #解锁网易云灰色歌曲
CONFIG_PACKAGE_luci-app-airplay2=n #Apple AirPlay2音频接收服务器
CONFIG_PACKAGE_luci-app-music-remote-center=n #PCHiFi数字转盘遥控
CONFIG_PACKAGE_luci-app-usb-printer=n #USB打印机
CONFIG_PACKAGE_luci-app-sqm=n #SQM智能队列管理
CONFIG_PACKAGE_luci-app-jd-dailybonus=n #京东签到服务
CONFIG_PACKAGE_luci-app-uugamebooster=n #UU游戏加速器

#
# VPN相关插件(禁用):
#
CONFIG_PACKAGE_luci-app-v2ray-server=n #V2ray服务器
CONFIG_PACKAGE_luci-app-pptp-server=n #PPTP VPN 服务器
CONFIG_PACKAGE_luci-app-ipsec-vpnd=n #ipsec VPN服务
CONFIG_PACKAGE_luci-app-openvpn-server=n #openvpn服务
CONFIG_PACKAGE_luci-app-softethervpn=n #SoftEtherVPN服务器
#
# 文件共享相关(禁用):
#
CONFIG_PACKAGE_luci-app-minidlna=n #miniDLNA服务
CONFIG_PACKAGE_luci-app-vsftpd=n #FTP 服务器
CONFIG_PACKAGE_luci-app-samba=n #网络共享
CONFIG_PACKAGE_autosamba=n #网络共享
CONFIG_PACKAGE_samba36-server=n #网络共享
EOF

# LuCI主题:
cat >> .config <<EOF
CONFIG_PACKAGE_luci-theme-argon=n
CONFIG_PACKAGE_luci-theme-netgear=n
EOF

# 常用软件包:
cat >> .config <<EOF
CONFIG_PACKAGE_curl=y
CONFIG_PACKAGE_htop=y
CONFIG_PACKAGE_nano=y
# CONFIG_PACKAGE_screen=y
# CONFIG_PACKAGE_tree=y
# CONFIG_PACKAGE_vim-fuller=y
CONFIG_PACKAGE_wget=y
CONFIG_PACKAGE_bash=y
CONFIG_PACKAGE_kmod-tun=y
CONFIG_PACKAGE_libcap=y
CONFIG_PACKAGE_libcap-bin=y
CONFIG_PACKAGE_ip6tables-mod-nat=y
CONFIG_PACKAGE_iptables-mod-extra=y
EOF

# 其他软件包:
cat >> .config <<EOF
CONFIG_HAS_FPU=y
EOF


# 
# ========================固件定制部分结束========================
# 


sed -i 's/^[ \t]*//g' ./.config

# 配置文件创建完成
