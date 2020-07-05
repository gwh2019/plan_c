#!/bin/sh

source /jffs/softcenter/scripts/base.sh
eval $(dbus export merlinclash_)
alias echo_date='echo 【$(date +%Y年%m月%d日\ %X)】:'
LOG_FILE=/tmp/merlinclash_log.txt

echo_date "download" >> $LOG_FILE
echo_date "定位文件" >> $LOG_FILE
filepath=/jffs/softcenter/merlinclash

filename=$(echo ${merlinclash_delyamlsel}.yaml)
echo_date "$filename" >> $LOG_FILE
mkdir -p /var/wwwext
cp -rf $filepath/$filename /www/ext/${merlinclash_delyamlsel}.json
if [ -f /www/ext/$filename ]; then
	echo_date "文件已复制" >> $LOG_FILE
else
	echo_date "文件复制失败" >> $LOG_FILE
fi

