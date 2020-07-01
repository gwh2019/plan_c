#!/bin/sh

source /jffs/softcenter/scripts/base.sh
eval $(dbus export merlinclash_)
alias echo_date='echo 【$(date +%Y年%m月%d日\ %X)】:'
LOG_FILE=/tmp/merlinclash_log.txt

echo_date "清空yaml文件" > $LOG_FILE

rm -rf /tmp/*.yaml
rm -rf /www/ext/*.yaml

