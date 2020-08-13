#!/bin/sh
 
source /jffs/softcenter/scripts/base.sh
eval $(dbus export merlinclash_)
alias echo_date='echo 【$(date +%Y年%m月%d日\ %X)】:'
LOG_FILE=/tmp/merlinclash_log.txt
upload_path=/tmp
upload_file=/tmp/clash

yamlname=$merlinclash_yamlsel
yamlpath=/jffs/softcenter/merlinclash/$yamlname.yaml

local_binary_replace(){
	chmod +x $upload_file
	clash_upload_ver=$($upload_file -v 2>/dev/null | head -n 1 | cut -d " " -f2)
	if [ -n "$clash_upload_ver" ]; then
		echo_date "上传clash二进制版本为：$clash_upload_ver" >> $LOG_FILE
		echo_date "开始替换处理" >> $LOG_FILE
		replace_binary
	else
		echo_date "上传的二进制不合法！！！" >> $LOG_FILE
	fi
	
}

replace_binary(){
	echo_date "开始替换clash二进制!" >> $LOG_FILE
	if [ "$(pidof clash)" ];then
		echo_date "为了保证更新正确，先关闭clash主进程... " >> $LOG_FILE
		killall clash >/dev/null 2>&1
		move_binary
		sleep 1
		start_clash
	else
		move_binary
	fi
}

move_binary(){
	echo_date "开始替换clash二进制文件... " >> $LOG_FILE
	mv $upload_file /jffs/softcenter/bin/clash
	chmod +x /jffs/softcenter/bin/clash
	clash_LOCAL_VER=$(/jffs/softcenter/bin/clash -v 2>/dev/null | head -n 1 | cut -d " " -f2)
	[ -n "$clash_LOCAL_VER" ] && dbus set merlinclash_clash_version="$clash_LOCAL_VER"
	echo_date "clash二进制文件替换成功... " >> $LOG_FILE
}

start_clash(){
	echo_date "开启clash进程... " >> $LOG_FILE
	cd /jffs/softcenter/bin
	
	echo_date "启用$yamlname YAML配置" >> $LOG_FILE
	/jffs/softcenter/bin/clash -d /jffs/softcenter/merlinclash/ -f $yamlpath >/dev/null 2>/tmp/clash_error.log &
	local i=10
	until [ -n "$clashPID" ]
	do
		i=$(($i-1))
		clashPID=$(pidof clash)
		if [ "$i" -lt 1 ];then
			echo_date "clash进程启动失败！" >> $LOG_FILE
			close_in_five
		fi
		sleep 1
	done
	echo_date clash启动成功，pid：$clashPID >> $LOG_FILE
}

close_in_five() {
	echo_date "插件将在5秒后自动关闭！！"
	local i=5
	while [ $i -ge 0 ]; do
		sleep 1
		echo_date $i
		let i--
	done
	dbus set merlinclash_enable="0"
	if [ "$merlinclash_unblockmusic_enable" == "1" ]; then
		sh /jffs/softcenter/scripts/clash_unblockneteasemusic.sh stop
	fi
	sh /jffs/softcenter/merlinclash/clashconfig.sh stop
}

case $ACTION in
start)
	echo "本地上传clash二进制替换" > $LOG_FILE
	local_binary_replace >> $LOG_FILE
	echo BBABBBBC >> $LOG_FILE	
	;;
esac
