#!/bin/sh

source /jffs/softcenter/scripts/base.sh
eval $(dbus export merlinclash_)
alias echo_date='echo 【$(TZ=UTC-8 date -R +%Y年%m月%d日\ %X)】:'
LOG_FILE=/tmp/merlinclash_log.txt
url_main="https://raw.githubusercontent.com/zusterben/plan_c/master/bin"
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

get_latest_version(){
	rm -rf /tmp/clash_latest_info.txt
	echo_date "检测clash最新版本..." >> $LOG_FILE
	#插入hosts,免得raw.githubusercontent.com解析失败
	#if grep -q "raw.githubusercontent.com" /etc/hosts; then
	#	echo_date "已存在raw.githubusercontent.com的host记录" >> $LOG_FILE
	#else
	#	echo_date "创建raw.githubusercontent.com的host记录" >> $LOG_FILE
	#	sed -i '$a\151.101.128.133 raw.githubusercontent.com' /etc/hosts
	#fi
	curl --connect-timeout 8 -s ${url_main}/${ARCH_SUFFIX}/version > /tmp/clash_latest_info.txt
	if [ "$?" == "0" ];then
		if [ -z "`cat /tmp/clash_latest_info.txt`" ];then 
			echo_date "获取clash最新版本信息失败！" >> $LOG_FILE
			failed_warning_clash
		fi
		if [ -n "`cat /tmp/clash_latest_info.txt|grep "404"`" ];then
			echo_date "error:404 | 获取clash最新版本信息失败！" >> $LOG_FILE
			failed_warning_clash
		fi
		if [ -n "$(cat /tmp/clash_latest_info.txt|grep "500")" ];then
			echo_date "error:500 | 获取clash版本文件失败！" >> $LOG_FILE
			failed_warning_clash
		fi
		ClashVERSION=`cat /tmp/clash_latest_info.txt |head -n 1` || 0
		ClashVERSION_TMP=$(echo $ClashVERSION | awk -F"." '{print $1"."$2}')
		echo_date "检测到clash最新版本：v$ClashVERSION" >> $LOG_FILE
		CUR_VER=`dbus get softcenter_module_merlinclash_version`
		CUR_VER_TMP=$(echo $CUR_VER | awk -F"." '{print $1"."$2}')
		echo_date "当前已安装clash版本：v$CUR_VER" >> $LOG_FILE
		COMP=$(versioncmp $CUR_VER_TMP $ClashVERSION_TMP)
		if [ "$COMP" == "1" ];then
			[ "$CUR_VER" != "0" ] && echo_date "clash已安装版本号低于最新版本，开始更新程序..." >> $LOG_FILE
			update_now ${ARCH_SUFFIX}
		else
			echo_date "clash已安装版本已经是最新，退出更新程序!" >> $LOG_FILE
		fi
	else
		echo_date "获取clash最新版本信息失败！" >> $LOG_FILE
		failed_warning_clash
	fi
}

failed_warning_clash(){
	echo_date "获取文件失败！！请检查网络！注意raw.githubusercontent.com的DNS解析结果" >> $LOG_FILE
	echo_date "===================================================================" >> $LOG_FILE
	echo BBABBBBC
	exit 1
}

update_now(){
	rm -rf /tmp/clash
	mkdir -p /tmp/clash && cd /tmp/clash

	echo_date "开始下载clash程序" >> $LOG_FILE
	wget --no-check-certificate --timeout=20 --tries=1 $url_main/$1/merlinclash.tar.gz
	if [ "$?" != "0" ];then
		echo_date "clash下载失败！" >> $LOG_FILE
		echo_date "下载失败，请检查你的网络！" >> $LOG_FILE
		echo_date "===================================================================" >> $LOG_FILE
		echo BBABBBBC
		exit 1
	else
		echo_date "clash程序下载成功..." >> $LOG_FILE
		check_md5sum
	fi	
}

check_md5sum(){
	cd /tmp/clash
	echo_date "校验下载的文件!" >> $LOG_FILE
	clash_LOCAL_MD5=$(md5sum merlinclash.tar.gz|awk '{print $1}')
	clash_ONLINE_MD5=$(cat /tmp/clash_latest_info.txt|sed -n '2p')
	if [ "$clash_LOCAL_MD5"x = "$clash_ONLINE_MD5"x ]; then
		echo_date "文件校验通过!" >> $LOG_FILE
		install_binary
	else
		echo_date "校验未通过，可能是下载过程出现了什么问题，请检查你的网络！" >> $LOG_FILE
		echo_date "===================================================================" >> $LOG_FILE
		echo BBABBBBC
		exit 1
	fi
}

install_binary(){
	echo_date "开始覆盖最新二进制!" >> $LOG_FILE
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
	cd /tmp/clash
	tar -zxvf merlinclash.tar.gz >/dev/null 2>&1
	chmod a+x /tmp/clash/merlinclash/install.sh
	sh /tmp/clash/merlinclash/install.sh
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
restart)
	echo " " > $LOG_FILE
	echo_date "===================================================================" >> $LOG_FILE
	get_latest_version >> $LOG_FILE 2>&1
	echo_date "===================================================================" >> $LOG_FILE
	echo BBABBBBC >> $LOG_FILE
	;;
esac

