#!/bin/sh

source /jffs/softcenter/scripts/base.sh
eval $(dbus export merlinclash_)
alias echo_date='echo 【$(date +%Y年%m月%d日\ %X)】:'
LOG_FILE=/tmp/merlinclash_log.txt
pronum=0
test=$(echo $(yq r /tmp/proxies.yaml proxies[*].name))
for t in $test
do
    yq w -i /tmp/proxies.yaml proxy-groups[1].proxies[$pronum] "$t"
    #echo_date $t
    #echo_date $num

    let pronum++
done
