#!/bin/sh

source /jffs/softcenter/scripts/base.sh
eval $(dbus export merlinclash_)
alias echo_date='echo 【$(date +%Y年%m月%d日\ %X)】:'
LOG_FILE=/tmp/merlinclash_log.txt
url_main="https://raw.githubusercontent.com/zusterben/plan_c/master/bin_arch"
url_back=""
yamlname=$merlinclash_yamlsel
yamlpath=/jffs/softcenter/merlinclash/$yamlname.yaml
ARCH=`uname -m`
KVER=`uname -r`
if [ "$ARCH" == "armv7l" ]; then
	if [ "$KVER" == "4.1.52" -o "$KVER" == "3.14.77" ];then
		ARCH_SUFFIX="armng"
	else
		ARCH_SUFFIX="arm"
	fi
elif [ "$ARCH" == "aarch64" ]; then
	ARCH_SUFFIX="arm64"
elif [ "$ARCH" == "mips" ]; then
	if [ "$KVER" == "3.10.14" ];then
		ARCH_SUFFIX="mipsle"
	else
		ARCH_SUFFIX="mips"
	fi
#elif [ "$ARCH" == "mipsle" ]; then//mtk move to mips
#	ARCH_SUFFIX="mipsle"
else
	ARCH_SUFFIX="arm"
fi



get_binary_history(){
	rm -rf /jffs/softcenter/merlinclash/clash_binary_history.txt
	rm -rf /tmp/clash_bin_history.txt
	#插入hosts,免得raw.githubusercontent.com解析失败
	#if grep -q "raw.githubusercontent.com" /etc/hosts; then
	#	echo_date "已存在raw.githubusercontent.com的host记录" >> $LOG_FILE
	#else
	#	echo_date "创建raw.githubusercontent.com的host记录" >> $LOG_FILE
	#	sed -i '$a\151.101.64.133 raw.githubusercontent.com' /etc/hosts
	#fi
	
	echo_date "下载clash历史版本号文件..." >> $LOG_FILE
	curl --connect-timeout 8 -s ${url_main}/${ARCH_SUFFIX}/clash_binary_history.txt > /tmp/clash_bin_history.txt
	if [ "$?" == "0" ];then
		echo_date "检查文件完整性" >> $LOG_FILE
		if [ -z "$(cat /tmp/clash_bin_history.txt)" ];then 
			echo_date "获取clash版本文件失败！" >> $LOG_FILE
			failed_warning_clash
		fi
		#if [ -n "$(cat /tmp/upload/clash_binary_history.txt|grep "404")" ];then
		#	echo_date "error:404 | 获取clash版本文件失败！" >> $LOG_FILE
		#	failed_warning_clash
		#fi
		if [ -n "$(cat /tmp/clash_bin_history.txt|grep "clash")" ];then
			echo_date "已获取服务器端clash版本号文件" >> $LOG_FILE
			mv -f /tmp/clash_bin_history.txt /jffs/softcenter/merlinclash/clash_binary_history.txt
			ln -s /jffs/softcenter/merlinclash/clash_binary_history.txt /tmp/clash_binary_history.txt 
		else
			echo_date "获取clash版本文件失败！" >> $LOG_FILE
			failed_warning_clash
		fi
		
	else
		echo_date "获取clash版本文件失败！" >> $LOG_FILE
		failed_warning_clash
	fi
}

failed_warning_clash(){
	rm -rf /jffs/softcenter/merlinclash/clash_binary_history.txt
	rm -rf /tmp/clash_bin_history.txt
	echo_date "获取文件失败！！请检查网络！注意raw.githubusercontent.com的DNS解析结果" >> $LOG_FILE
	echo_date "===================================================================" >> $LOG_FILE
	echo BBABBBBC
	exit 1
}

replace_clash_binary(){
	echo_date "选中clash二进制版本为：$merlinclash_clashbinarysel" >> $LOG_FILE
	echo_date "开始替换处理" >> $LOG_FILE
	binarysel=$merlinclash_clashbinarysel

	rm -rf /tmp/clash_binary
	mkdir -p /tmp/clash_binary && cd /tmp/clash_binary
	echo_date "开始下载校验文件：md5sum.txt" >> $LOG_FILE
	wget --no-check-certificate --timeout=20 -qO - ${url_main}/${ARCH_SUFFIX}/md5sum.txt > /tmp/clash_binary/md5sum.txt
	
	if [ "$?" != "0" ];then
		echo_date "md5sum.txt下载失败！" >> $LOG_FILE
		md5sum_ok=0
	else
		md5sum_ok=1
		echo_date "md5sum.txt下载成功..." >> $LOG_FILE
	fi
	
	echo_date "开始下载clash二进制" >> $LOG_FILE
	wget --no-check-certificate --timeout=20 --tries=1 $url_main/${ARCH_SUFFIX}/clash
	#curl -4sSk --connect-timeout 20 $url_main/$binarysel/clash > /tmp/clash_binary/clash
	if [ "$?" != "0" ];then
		echo_date "clash下载失败！" >> $LOG_FILE
		clash_ok=0
	else
		clash_ok=1
		echo_date "clash程序下载成功..." >> $LOG_FILE
	fi	

	if [ "$md5sum_ok=1" ] && [ "$clash_ok=1" ]; then
		check_md5sum
	else
		echo_date "下载失败，请检查你的网络！" >> $LOG_FILE
		echo_date "===================================================================" >> $LOG_FILE
		echo BBABBBBC
		exit 1
	fi
}

check_md5sum(){
	cd /tmp/clash_binary
	echo_date "校验下载的文件!" >> $LOG_FILE
	clash_LOCAL_MD5=$(md5sum clash|awk '{print $1}')
	clash_ONLINE_MD5=$(cat md5sum.txt|awk '{print $1}')
	if [ "$clash_LOCAL_MD5"x = "$clash_ONLINE_MD5"x ]; then
		echo_date "文件校验通过!" >> $LOG_FILE
		replace_binary
	else
		echo_date "校验未通过，可能是下载过程出现了什么问题，请检查你的网络！" >> $LOG_FILE
		rm -rf /tmp/clash_binary/*
		echo_date "===================================================================" >> $LOG_FILE
		echo BBABBBBC
		exit 1
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
	ln -s /jffs/softcenter/merlinclash/clash_binary_history.txt /tmp/clash_binary_history.txt 
}

move_binary(){
	echo_date "开始替换clash二进制文件... " >> $LOG_FILE
	mv /tmp/clash_binary/clash /jffs/softcenter/bin/clash
	chmod +x /jffs/softcenter/bin/clash
	clash_LOCAL_VER=`/jffs/softcenter/bin/clash -v 2>/dev/null | head -n 1 | cut -d " " -f2`
	[ -n "$clash_LOCAL_VER" ] && dbus set merlinclash_clash_version="$clash_LOCAL_VER"
	echo_date "clash二进制文件替换成功... " >> $LOG_FILE
}

start_clash(){
	echo_date "开启clash进程... " >> $LOG_FILE
	cd /jffs/softcenter/bin
	#export GOGC=30
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

case $1 in
start)
	echo "" > $LOG_FILE
	echo_date "获取远程服务器clash版本号" >> $LOG_FILE
	get_binary_history >> $LOG_FILE
	echo BBABBBBC >> $LOG_FILE	
	;;
restart)
	echo "替换clash二进制" > $LOG_FILE
	replace_clash_binary >> $LOG_FILE 2>&1
	echo BBABBBBC >> $LOG_FILE
	;;
esac

