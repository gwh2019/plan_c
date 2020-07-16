#!/bin/sh

source /jffs/softcenter/scripts/base.sh
eval `dbus export merlinclash_`

unblockmusic_pid=`ps|grep -w UnblockNeteaseMusic | grep -cv grep`

unblockmusic_LOCAL_VER=$(dbus get unblockmusic_bin_version)

if [ -n "$unblockmusic_LOCAL_VER" ]; then
    text1="<span style='color: gold'>插件版本： $unblockmusic_LOCAL_VER</span>"
else
    text1="<span style='color: red'>获取插件版本失败，请重新安装网易云插件！</span>"
fi


if [ "$unblockmusic_pid" -gt 0 ];then
	text2="<span style='color: gold'>运行中</span>"

else
	text2="<span style='color: gold'>未启动</span>"
fi

echo "$text1@$text2" > /tmp/unblockmusic_status.log

