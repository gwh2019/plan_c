#!/bin/sh

source /jffs/softcenter/scripts/base.sh
eval $(dbus export merlinclash_)
alias echo_date='echo 【$(date +%Y年%m月%d日\ %X)】:'
#
ln -s /jffs/softcenter/merlinclash/yaml_bak/yamls.txt /tmp/yamls.txt


