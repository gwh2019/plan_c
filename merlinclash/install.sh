#! /bin/sh

source /jffs/softcenter/scripts/base.sh
eval $(dbus export merlinclash_)
alias echo_date='echo 【$(TZ=UTC-8 date -R +%Y年%m月%d日\ %X)】:'
MODEL=$(nvram get productid)

echo_date 检测jffs分区剩余空间...
if [ "$(nvram get sc_mount)" == 0 ];then
	SPACE_AVAL=$(df|grep jffs | awk '{print $4}')
	SPACE_NEED=$(du -s /tmp/merlinclash | awk '{print $1}')
	if [ "$SPACE_AVAL" -gt "$SPACE_NEED" ];then
		echo_date 当前jffs分区剩余"$SPACE_AVAL" KB, 插件安装需要"$SPACE_NEED" KB，空间满足，继续安装！
	elif [ -n "$merlinclash_enable" ];then
		echo_date 空间满足，继续安装！
	else
		echo_date 当前jffs分区剩余"$SPACE_AVAL" KB, 插件安装需要"$SPACE_NEED" KB，空间不足！
		echo_date 退出安装！
		exit 1
	fi
	mkdir -p /jffs/softcenter/merlinclash
else
	echo_date U盘已挂载，继续安装！
	mdisk=`nvram get sc_disk`
	mkdir -p /tmp/mnt/$mdisk/merlinclash
	ln -sf /tmp/mnt/$mdisk/merlinclash /jffs/softcenter/
fi


if [ "$MODEL" == "GT-AC5300" ] || [ "$MODEL" == "GT-AC2900" ] || [ "$(nvram get merlinr_rog)" == "1" ];then
	ROG=1
fi

if [ "$MODEL" == "TUF-AX3000" ] || [ "$(nvram get merlinr_tuf)" == "1" ];then
	TUF=1
fi

# 先关闭clash
if [ "$merlinclash_enable" == "1" ];then
	echo_date 先关闭clash插件，保证文件更新成功!
	[ -f "/jffs/softcenter/scripts/clash_config.sh" ] && sh /jffs/softcenter/scripts/clash_config.sh stop
fi

#升级前先删除无关文件,保留已上传配置文件
echo_date 清理旧文件,保留已上传配置文件
rm -rf /jffs/softcenter/merlinclash/Country.mmdb
rm -rf /jffs/softcenter/merlinclash/*.yaml
rm -rf /jffs/softcenter/merlinclash/clashconfig.sh
rm -rf /jffs/softcenter/merlinclash/version
rm -rf /jffs/softcenter/merlinclash/yaml/
rm -rf /jffs/softcenter/merlinclash/dashboard/
rm -rf /jffs/softcenter/bin/clash
rm -rf /jffs/softcenter/bin/yq
rm -rf /tmp/*.yaml
rm -rf /jffs/softcenter/webs/Module_merlinclash*
rm -rf /jffs/softcenter/res/icon-merlinclash.png
rm -rf /jffs/softcenter/scripts/clash*

find /jffs/softcenter/init.d/ -name "*clash.sh" | xargs rm -rf
cd /jffs/softcenter/bin && mkdir -p Music
cd /jffs/softcenter/merlinclash && mkdir -p dashboard
cd /jffs/softcenter/merlinclash && mkdir -p yaml
cd /jffs/softcenter/merlinclash && mkdir -p yaml_bak
echo_date 开始复制文件！
cd /tmp

echo_date 复制相关二进制文件！此步时间可能较长！
cp -rf /tmp/merlinclash/clash/clash /jffs/softcenter/bin/
cp -rf /tmp/merlinclash/clash/yq /jffs/softcenter/bin/
cp -rf /tmp/merlinclash/clash/Country.mmdb /jffs/softcenter/merlinclash/
cp -rf /tmp/merlinclash/clash/clashconfig.sh /jffs/softcenter/merlinclash/
cp -rf /tmp/merlinclash/version /jffs/softcenter/merlinclash/

cp -rf /tmp/merlinclash/yaml/* /jffs/softcenter/merlinclash/yaml/
cp -rf /tmp/merlinclash/dashboard/* /jffs/softcenter/merlinclash/dashboard/

echo_date 复制相关的脚本文件！
cp -rf /tmp/merlinclash/scripts/* /jffs/softcenter/scripts/
cp -rf /tmp/merlinclash/install.sh /jffs/softcenter/scripts/merlinclash_install.sh
cp -rf /tmp/merlinclash/uninstall.sh /jffs/softcenter/scripts/uninstall_merlinclash.sh

echo_date 复制相关的网页文件！
cp -rf /tmp/merlinclash/webs/* /jffs/softcenter/webs/
cp -rf /tmp/merlinclash/res/* /jffs/softcenter/res/
if [ "$ROG" == "1" ];then
	cp -rf /tmp/merlinclash/rog/res/* /jffs/softcenter/res/
elif [ "$TUF" == "1" ];then
	sed -i 's/3e030d/3e2902/g;s/91071f/92650F/g;s/680516/D0982C/g;s/cf0a2c/c58813/g;s/700618/74500b/g;s/530412/92650F/g' /tmp/merlinclash/rog/res/merlinclash.css >/dev/null 2>&1
	cp -rf /tmp/merlinclash/rog/res/* /jffs/softcenter/res/
fi
echo_date 为新安装文件赋予执行权限...
chmod 755 /jffs/softcenter/bin/clash
chmod 755 /jffs/softcenter/bin/yq
chmod 755 /jffs/softcenter/merlinclash/Country.mmdb
chmod 755 /jffs/softcenter/merlinclash/yaml/*
chmod 755 /jffs/softcenter/merlinclash/*
chmod 755 /jffs/softcenter/scripts/clash*

echo_date 创建一些二进制文件的软链接！
[ ! -L "/jffs/softcenter/init.d/S99merlinclash.sh" ] && ln -sf /jffs/softcenter/merlinclash/clashconfig.sh /jffs/softcenter/init.d/S99merlinclash.sh
[ ! -L "/jffs/softcenter/init.d/N99merlinclash.sh" ] && ln -sf /jffs/softcenter/merlinclash/clashconfig.sh /jffs/softcenter/init.d/N99merlinclash.sh

# 离线安装时设置软件中心内储存的版本号和连接
CUR_VERSION=$(cat /jffs/softcenter/merlinclash/version)
dbus set merlinclash_version_local="$CUR_VERSION"
dbus set merlinclash_clash_version=$(/jffs/softcenter/bin/clash -v 2>/dev/null | head -n 1 | cut -d " " -f2)
dbus set softcenter_module_merlinclash_install="1"
dbus set softcenter_module_merlinclash_version="$CUR_VERSION"
dbus set softcenter_module_merlinclash_title="Merlin Clash"
dbus set softcenter_module_merlinclash_description="Merlin Clash"

echo_date 一点点清理工作...
rm -rf /tmp/clash* >/dev/null 2>&1

echo_date clash插件安装成功！
	#生成yamls.txt
	dir=/jffs/softcenter/merlinclash/yaml_bak
	a=$(ls $dir | wc -l)
	if [ $a -gt 0 ]
	then
		cp -rf /jffs/softcenter/merlinclash/yaml_bak/*.yaml /jffs/softcenter/merlinclash/
	fi
		
	#生成新的txt文件

	rm -rf /jffs/softcenter/merlinclash/yaml_bak/yamls.txt
	echo_date "创建yaml文件列表"
	#find $fp  -name "*.yaml" |sed 's#.*/##' >> $fp/yamls.txt
	find /jffs/softcenter/merlinclash/yaml_bak  -name "*.yaml" |sed 's#.*/##' |sed '/^$/d' | awk -F'.' '{print $1}' >> /jffs/softcenter/merlinclash/yaml_bak/yamls.txt
	#创建软链接
	ln -s /jffs/softcenter/merlinclash/yaml_bak/yamls.txt /tmp/yamls.txt
	#
	echo_date "初始化配置文件处理完成"
if [ "$merlinclash_enable" == "1" ];then
	echo_date 重启clash插件！
	sh /jffs/softcenter/scripts/clash_config.sh start
fi

echo_date 更新完毕，请等待网页自动刷新！
exit 0

