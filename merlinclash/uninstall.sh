#!/bin/sh
eval `dbus export merlinclash_`
source /jffs/softcenter/scripts/base.sh


if [ "$merlinclash_enable" == "1" ];then
	echo_date 关闭clash插件！
	sh /jffs/softcenter/merlinclash/clashconfig.sh stop
    sleep 1
fi


find /jffs/softcenter/init.d/ -name "*clash*" | xargs rm -rf
rm -rf /jffs/softcenter/bin/clash
rm -rf /jffs/softcenter/bin/yq
rm  /tmp/yamls.txt
rm -rf /jffs/softcenter/res/icon-merlinclash.png
rm -rf /jffs/softcenter/res/clash-dingyue.png
rm -rf /jffs/softcenter/res/merlinclash.css
rm -rf /jffs/softcenter/res/mc-tablednd.js
rm -rf /jffs/softcenter/res/mc-menu.js
rm -rf /jffs/softcenter/merlinclash/Country.mmdb
rm -rf /jffs/softcenter/merlinclash/clashconfig.sh
rm -rf /jffs/softcenter/merlinclash/yaml_bak/*
rm -rf /jffs/softcenter/merlinclash/yaml/*
rm -rf /jffs/softcenter/merlinclash/dashboard/*
rm -rf /jffs/softcenter/scripts/clash*.sh
rm -rf /jffs/softcenter/webs/Module_merlinclash.asp
rm -rf /jffs/softcenter/merlinclash
rm -f /jffs/softcenter/scripts/merlinclash_install.sh
rm -f /jffs/softcenter/scripts/uninstall_merlinclash.sh


dbus remove softcenter_module_merlinclash_install
dbus remove softcenter_module_merlinclash_version
dbus remove merlinclash_version_local

