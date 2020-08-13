#!/bin/sh

source /jffs/softcenter/scripts/base.sh
eval `dbus export merlinclash_`

echo "" > /tmp/merlinclash_log.txt

case $ACTION in
start)
	if [ "$merlinclash_enable" == "1" ];then
		echo start >> /tmp/merlinclash_log.txt
		sh /jffs/softcenter/merlinclash/clashconfig.sh restart >> /tmp/merlinclash_log.txt
	else
		echo stop >> /tmp/merlinclash_log.txt
		sh /jffs/softcenter/merlinclash/clashconfig.sh stop >> /tmp/merlinclash_log.txt
	fi

	echo BBABBBBC >> /tmp/merlinclash_log.txt
	;;
clean)
	echo upload >> /tmp/merlinclash_log.txt
	sh /jffs/softcenter/merlinclash/clashconfig.sh upload
	echo BBABBBBC >> /tmp/merlinclash_log.txt
	;;
update)
	echo update >> /tmp/merlinclash_log.txt
	sh /jffs/softcenter/merlinclash/clash_update_ipdb.sh
	echo BBABBBBC >> /tmp/merlinclash_log.txt
	;;
restart)
	if [ "$merlinclash_enable" == "1" ];then
		echo "快速重启" >> /tmp/merlinclash_log.txt
		sh /jffs/softcenter/merlinclash/clashconfig.sh quicklyrestart >> /tmp/merlinclash_log.txt
	else
		echo "请先启用merlinclash" >> /tmp/merlinclash_log.txt		
	fi
	echo BBABBBBC >> /tmp/merlinclash_log.txt
	;;
toolscript)
	if [ "$merlinclash_enable" == "1" ];then
		echo "网易云音乐解锁快速重启" >> /tmp/merlinclash_log.txt
		sh /jffs/softcenter/scripts/clash_unblockneteasemusic.sh restart
	else
		echo "请先启用merlinclash" >> /tmp/merlinclash_log.txt		
	fi
	echo BBABBBBC >> /tmp/merlinclash_log.txt
	;;
esac

