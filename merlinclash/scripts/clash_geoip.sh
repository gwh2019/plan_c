#!/bin/sh

source /jffs/softcenter/scripts/base.sh
eval $(dbus export merlinclash_)
alias echo_date='echo 【$(TZ=UTC-8 date -R +%Y年%m月%d日\ %X)】:'

url_main="https://raw.githubusercontent.com/zusterben/plan_a/master/v2ray_binary"
url_back=""
ARCH=`uname -m`
if [ "$ARCH" == "armv7l" ]; then
	ARCH_SUFFIX="arm"
elif [ "$ARCH" == "aarch64" ]; then
	ARCH_SUFFIX="arm64"
elif [ "$ARCH" == "mips" ]; then
	ARCH_SUFFIX="mips"
elif [ "$ARCH" == "mipsle" ]; then
	ARCH_SUFFIX="mipsle"
else
	ARCH_SUFFIX="arm"
fi
KVER=`uname -r`
if [ "$KVER" == "4.1.52" -o "$KVER" == "3.14.77" ];then
	ARCH_SUFFIX="armng"
fi
if [ "$KVER" == "3.10.14" ];then
	ARCH_SUFFIX="mipsle"
fi
get_latest_version(){
	rm -rf /tmp/geoip_latest_info.txt
	echo_date "检测geoip最新版本..."
	curl --connect-timeout 8 -s $url_main/latest.txt > /tmp/v2ray_latest_info.txt
	if [ "$?" == "0" ];then
		if [ -z "`cat /tmp/v2ray_latest_info.txt`" ];then
			echo_date "获取V2Ray最新版本信息失败！使用备用服务器检测！"
			failed_warning_v2ray
		fi
		if [ -n "`cat /tmp/v2ray_latest_info.txt|grep "404"`" ];then
			echo_date "获取V2Ray最新版本信息失败！使用备用服务器检测！"
			failed_warning_v2ray
		fi
		V2VERSION=`cat /tmp/v2ray_latest_info.txt | sed 's/v//g'` || 0
		echo_date "检测到V2Ray最新版本：v$V2VERSION"
		if [ ! -f "/jffs/softcenter/bin/v2ray" -o ! -f "/jffs/softcenter/bin/v2ctl" ];then
			echo_date "v2ray安装文件丢失！重新下载！"
			CUR_VER="0"
		else
			CUR_VER=`v2ray -version 2>/dev/null | head -n 1 | cut -d " " -f2 | sed 's/v//g'` || 0
			echo_date "当前已安装V2Ray版本：v$CUR_VER"
		fi
		COMP=`versioncmp $CUR_VER $V2VERSION`
		if [ "$COMP" == "1" ];then
			[ "$CUR_VER" != "0" ] && echo_date "V2Ray已安装版本号低于最新版本，开始更新程序..."
			update_now $V2VERSION
		else
			V2RAY_LOCAL_VER=`/jffs/softcenter/bin/v2ray -version 2>/dev/null | head -n 1 | cut -d " " -f2`
			V2RAY_LOCAL_DATE=`/jffs/softcenter/bin/v2ray -version 2>/dev/null | head -n 1 | cut -d " " -f4`
			[ -n "$V2RAY_LOCAL_VER" ] && dbus set ss_basic_v2ray_version="$V2RAY_LOCAL_VER"
			[ -n "$V2RAY_LOCAL_DATE" ] && dbus set ss_basic_v2ray_date="$V2RAY_LOCAL_DATE"
			echo_date "V2Ray已安装版本已经是最新，退出更新程序!"
		fi
	else
		echo_date "获取V2Ray最新版本信息失败！使用备用服务器检测！"
		failed_warning_v2ray
	fi
}

failed_warning_v2ray(){
	echo_date "获取V2Ray最新版本信息失败！请检查到你的网络！"
	echo_date "==================================================================="
	echo XU6J03M6
	exit 1
}

update_now(){
	rm -rf /tmp/v2ray
	mkdir -p /tmp/v2ray && cd /tmp/v2ray

	echo_date "开始下载校验文件：md5sum.txt"
	wget --no-check-certificate --timeout=20 -qO - $url_main/$ARCH_SUFFIX/$1/md5sum.txt > /tmp/v2ray/md5sum.txt
	if [ "$?" != "0" ];then
		echo_date "md5sum.txt下载失败！"
		md5sum_ok=0
	else
		md5sum_ok=1
		echo_date "md5sum.txt下载成功..."
	fi
	
	echo_date "开始下载v2ray程序"
	wget --no-check-certificate --timeout=20 --tries=1 $url_main/$ARCH_SUFFIX/$1/v2ray
	#curl -L -H "Cache-Control: no-cache" -o /tmp/v2ray/v2ray $url_main/$1/v2ray
	if [ "$?" != "0" ];then
		echo_date "v2ray下载失败！"
		v2ray_ok=0
	else
		v2ray_ok=1
		echo_date "v2ray程序下载成功..."
	fi

	echo_date "开始下载v2ctl程序"
	wget --no-check-certificate --timeout=20 --tries=1 $url_main/$ARCH_SUFFIX/$1/v2ctl
	if [ "$?" != "0" ];then
		echo_date "v2ctl下载失败！"
		v2ctl_ok=0
	else
		v2ctl_ok=1
		echo_date "v2ctl程序下载成功..."
	fi

	if [ "$md5sum_ok=1" ] && [ "$v2ray_ok=1" ] && [ "$v2ctl_ok=1" ];then
		check_md5sum
	else
		echo_date "使用备用服务器下载..."
		echo_date "下载失败，请检查你的网络！"
		echo_date "==================================================================="
		echo XU6J03M6
		exit 1
	fi
}

check_md5sum(){
	cd /tmp/v2ray
	echo_date "校验下载的文件!"
	V2RAY_LOCAL_MD5=`md5sum v2ray|awk '{print $1}'`
	V2RAY_ONLINE_MD5=`cat md5sum.txt|grep -w v2ray|awk '{print $1}'`
	V2CTL_LOCAL_MD5=`md5sum v2ctl|awk '{print $1}'`
	V2CTL_ONLINE_MD5=`cat md5sum.txt|grep v2ctl|awk '{print $1}'`
	if [ "$V2RAY_LOCAL_MD5"x = "$V2RAY_ONLINE_MD5"x ] && [ "$V2CTL_LOCAL_MD5"x = "$V2CTL_ONLINE_MD5"x ];then
		echo_date "文件校验通过!"
		install_binary
	else
		echo_date "校验未通过，可能是下载过程出现了什么问题，请检查你的网络！"
		echo_date "==================================================================="
		echo XU6J03M6
		exit 1
	fi
}

install_binary(){
	echo_date "开始覆盖最新二进制!"
	if [ "`pidof v2ray`" ];then
		echo_date "为了保证更新正确，先关闭v2ray主进程... "
		killall v2ray >/dev/null 2>&1
		move_binary
		sleep 1
		start_v2ray
	else
		move_binary
	fi
}

move_binary(){
	echo_date "开始替换v2ray二进制文件... "
	cp -rf /tmp/v2ray/v2ray /jffs/softcenter/bin/v2ray
	cp -rf /tmp/v2ray/v2ctl /jffs/softcenter/bin/
	chmod +x /jffs/softcenter/bin/v2*
	V2RAY_LOCAL_VER=`/jffs/softcenter/bin/v2ray -version 2>/dev/null | head -n 1 | cut -d " " -f2`
	V2RAY_LOCAL_DATE=`/jffs/softcenter/bin/v2ray -version 2>/dev/null | head -n 1 | cut -d " " -f5`
	[ -n "$V2RAY_LOCAL_VER" ] && dbus set ss_basic_v2ray_version="$V2RAY_LOCAL_VER"
	[ -n "$V2RAY_LOCAL_DATE" ] && dbus set ss_basic_v2ray_date="$V2RAY_LOCAL_DATE"
	echo_date "v2ray二进制文件替换成功... "
}

start_v2ray(){
	echo_date "开启v2ray进程... "
	cd /jffs/softcenter/bin
	export GOGC=30
	v2ray --config=/jffs/softcenter/ss/v2ray.json >/dev/null 2>&1 &
	
	local i=10
	until [ -n "$V2PID" ]
	do
		i=$(($i-1))
		V2PID=`pidof v2ray`
		if [ "$i" -lt 1 ];then
			echo_date "v2ray进程启动失败！"
			close_in_five
		fi
		sleep 1
	done
	echo_date v2ray启动成功，pid：$V2PID
}

case $1 in
1)
	echo " " > /tmp/clash_log.txt
	echo_date "===================================================================" >> /tmp/clash_log.txt
	echo_date "                GeoIP程序更新" >> /tmp/clash_log.txt
	echo_date "===================================================================" >> /tmp/clash_log.txt
	get_latest_version >> /tmp/clash_log.txt 2>&1
	echo_date "===================================================================" >> /tmp/clash_log.txt
	echo "DONE" >> /tmp/clash_log.txt
	;;
esac
