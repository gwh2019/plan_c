#!/bin/sh

source /jffs/softcenter/scripts/base.sh
eval $(dbus export merlinclash_)
alias echo_date='echo 【$(date +%Y年%m月%d日\ %X)】:'

while [ "$merlinclash_enable" == "1" ]; do
    echo_date "开始检查进程状态..."

    if [ ! -n "$(pidof clash)" ]; then
        sh /jffs/softcenter/merlinclash/clashconfig.sh restart >/dev/null 2>&1 &
        echo_date "重启 Clash 进程"
    fi
    sleep 60
    continue
done
