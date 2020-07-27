#!/bin/sh

source /jffs/softcenter/scripts/base.sh
eval $(dbus export merlinclash_)
alias echo_date='echo 【$(date +%Y年%m月%d日\ %X)】:'

pid_clash=$(pidof clash)
pid_watchdog=$(ps | grep clash_watchdog.sh | grep -v grep | awk '{print $1}')
date=$(echo_date)
yamlname=$merlinclash_yamlsel
yamlpath=/jffs/softcenter/merlinclash/$yamlname.yaml
lan_ipaddr=$(nvram get lan_ipaddr)
board_port="9990"
if [ ! -f $yamlpath ]; then
    host=''
    port=''
    secret=''
else
    host=$(yq r $yamlpath external-controller | awk -F":" '{print $1}')
    port=$(yq r $yamlpath external-controller | awk -F":" '{print $2}')
    secret=$(yq r $yamlpath secret)
fi

if [ -n "$pid_clash" ]; then
    text1="<span style='color: green'>$date Clash 进程运行正常！(PID: $pid_clash)</span>"
    text3="<span style='color: gold'>面板host：$lan_ipaddr</span>"
    text4="<span style='color: gold'>面板端口：$board_port</span>"
else
    text1="<span style='color: red'>$date Clash 进程未在运行！</span>"
fi

if [ -n "$pid_watchdog" ]; then
    text2="<span style='color: green'>$date Clash 看门狗运行正常！(PID: $pid_watchdog)</span>"
else
    text2="<span style='color: orange'>$date Clash 看门狗未在运行！</span>"
fi
yamlsel_tmp2=$yamlname

[ ! -L "/www/ext/yacd" ] && ln -sf /jffs/softcenter/merlinclash/dashboard/yacd /www/ext/
[ ! -L "/www/ext/razord" ] && ln -sf /jffs/softcenter/merlinclash/dashboard/razord /www/ext/
#网易云音乐解锁状态
unblockmusic_pid=`pidof UnblockNeteaseMusic`
unblockmusic_LOCAL_VER=$(dbus get unblockmusic_bin_version)
if [ -n "$unblockmusic_LOCAL_VER" ]; then
    text8="<span style='color: gold'>插件版本： $unblockmusic_LOCAL_VER</span>"
else
    text8="<span style='color: red'>获取插件版本失败，请重新安装网易云插件！</span>"
fi
if [ -n "$unblockmusic_pid" ];then
    if [ "$merlinclash_unblockmusic_bestquality" == "1" ]; then
	    text9="<span style='color: gold'>运行中 | 已开启高音质</span>"
    else
        text9="<span style='color: gold'>运行中 | 未开启高音质</span>"
    fi
else
	text9="<span style='color: gold'>未启动</span>"
fi

#内置规则文件版本
if [ "$merlinclash_proxygroup_version" != "" ]; then
    text10="<span style='color: gold'>当前版本：v$merlinclash_proxygroup_version</span>"
else    
    text10="<span style='color: gold'>当前版本：v0</span>"
fi
#内置游戏规则文件版本
ggver=$merlinclash_proxygame_version
if [ "$ggver" != "" ]; then
    text11="<span style='color: gold'>当前版本：g$merlinclash_proxygame_version</span>"
else    
    text11="<span style='color: gold'>当前版本：g0</span>"
fi
echo "$text1@$text2@$host@$port@$secret@$text3@$text4@$yamlsel_tmp2@$text8@$text9@$text10@$text11" > /tmp/merlinclash.log

