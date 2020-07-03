#!/bin/sh

source /jffs/softcenter/scripts/base.sh
eval $(dbus export merlinclash_)
alias echo_date='echo 【$(date +%Y年%m月%d日\ %X)】:'
LOG_FILE=/tmp/merlinclash_log.txt
LOCK_FILE=/tmp/yaml_online_del.lock

start_online_del(){
    echo_date "定位文件" >> $LOG_FILE

    delpath1=/jffs/softcenter/merlinclash
    delpath2=/jffs/softcenter/merlinclash/yaml_bak
    yamlname=$merlinclash_delyamlsel

    rm -rf $delpath1/$yamlname.yaml
    rm -rf $delpath2/$yamlname.yaml
    echo_date "删除文件" >> $LOG_FILE

    echo_date "重建yaml文件列表" >> $LOG_FILE
    #find $fp  -name "*.yaml" |sed 's#.*/##' >> $fp/yamls.txt
    rm -rf /$delpath2/yamls.txt
    rm /tmp/yamls.txt
    find $delpath2  -name "*.yaml" |sed 's#.*/##' |sed '/^$/d' | awk -F'.' '{print $1}' >> $delpath2/yamls.txt
    #创建软链接
    ln -s $delpath2/yamls.txt /tmp/yamls.txt
    #
    echo_date "配置文件删除完毕" >>"$LOG_FILE"
}
case $1 in
clean)
	set_lock
	echo "" > $LOG_FILE
	echo_date "删除配置文件" >> $LOG_FILE
	start_online_del >> $LOG_FILE
	echo BBABBBBC >> $LOG_FILE
	unset_lock
	;;
esac
#http_response "$text1@$text2@$host@$secret"
