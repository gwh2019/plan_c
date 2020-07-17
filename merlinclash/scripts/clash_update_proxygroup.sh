#!/bin/sh

source /jffs/softcenter/scripts/base.sh
eval $(dbus export merlinclash_)
alias echo_date='echo 【$(TZ=UTC-8 date -R +%Y年%m月%d日\ %X)】:'
LOG_FILE=/tmp/merlinclash_log.txt
url_main="https://raw.staticdn.net/flyhigherpi/merlinclash_clash_binary/master/proxy-group"
url_back=""
yamlname=$merlinclash_yamlsel
yamlpath=/jffs/softcenter/merlinclash/$yamlname.yaml
pgver=""

set_firewall(){
	rm -f /tmp/dnsmasq-proxygroup.conf
	touch /tmp/dnsmasq-proxygroup.conf
	echo "server=/raw.staticdn.net/8.8.8.8#53" >> /tmp/dnsmasq-proxygroup.conf
	service restart_dnsmasq
}
get_latest_version(){
	rm -rf /tmp/proxygroup_latest_info.txt

	if [ -z "$merlinclash_proxygroup_version" ]; then
		echo_date "为规则文件版本赋初始值0" >> $LOG_FILE		
		merlinclash_proxygroup_version=0
		dbus set merlinclash_proxygroup_version=$merlinclash_proxygroup_version
	#	dbus set merlinclash_proxygroup_version="0"
		echo_date "规则文件版本为$merlinclash_proxygroup_version" >> $LOG_FILE
	fi

	echo_date "检测规则文件最新版本..." >> $LOG_FILE
	#插入hosts,免得raw.staticdn.net解析失败
	#if grep -q "raw.staticdn.net" /etc/hosts; then
	#	echo_date "已存在raw.staticdn.net的host记录" >> $LOG_FILE
	#else
	#	echo_date "创建raw.staticdn.net的host记录" >> $LOG_FILE
	#	sed -i '$a\151.101.64.133 raw.staticdn.net' /etc/hosts
	#fi
	#set_firewall

	curl --connect-timeout 10 -s $url_main/lastest.txt > /tmp/proxygroup_latest_info.txt
	if [ "$?" == "0" ];then
		if [ -z "`cat /tmp/proxygroup_latest_info.txt`" ];then 
			echo_date "获取规则文件最新版本失败！" >> $LOG_FILE
			failed_warning_clash
		fi
		if [ -n "`cat /tmp/proxygroup_latest_info.txt|grep "404"`" ];then
			echo_date "error:404 | 获取规则文件最新版本失败！" >> $LOG_FILE
			failed_warning_clash
		fi
		if [ -n "$(cat /tmp/proxygroup_latest_info.txt|grep "500")" ];then
			echo_date "error:500 | 获取规则文件最新版本失败！" >> $LOG_FILE
			failed_warning_clash
		fi
		pgVERSION=$(cat /tmp/proxygroup_latest_info.txt | sed 's/v//g') || 0
	
		echo_date "检测到规则文件最新版本：v$pgVERSION" >> $LOG_FILE
		if [ ! -f "/jffs/softcenter/merlinclash/yaml/proxy-group.yaml" ];then
			echo_date "规则文件丢失！重新下载！" >> $LOG_FILE
			CUR_VER="0"
		else
			CUR_VER=$merlinclash_proxygroup_version
			echo_date "当前已内置规则文件版本：v$CUR_VER" >> $LOG_FILE
		fi
		COMP=$(versioncmp $CUR_VER $pgVERSION)
		if [ "$COMP" == "1" ];then
			[ "$CUR_VER" != "0" ] && echo_date "内置规则文件低于最新版本，开始更新..." >> $LOG_FILE
			pgver=$pgVERSION
			update_now v$pgVERSION
		else				
			echo_date "内置规则文件已经是最新，退出更新程序!" >> $LOG_FILE
		fi
	else
		echo_date "获取规则文件最新版本信息失败！" >> $LOG_FILE
		failed_warning_clash
	fi
}

failed_warning_clash(){
	echo_date "获取文件失败！！请检查网络！注意raw.staticdn.net的DNS解析结果" >> $LOG_FILE
	echo_date "===================================================================" >> $LOG_FILE
	echo BBABBBBC
	exit 1
}

update_now(){
	rm -rf /tmp/proxygroup
	mkdir -p /tmp/proxygroup && cd /tmp/proxygroup

	echo_date "开始下载校验文件：md5sum.txt" >> $LOG_FILE
	wget --no-check-certificate --timeout=20 -qO - $url_main/$1/md5sum.txt > /tmp/proxygroup/md5sum.txt
	if [ "$?" != "0" ];then
		echo_date "md5sum.txt下载失败！" >> $LOG_FILE
		md5sum_ok=0
	else
		md5sum_ok=1
		echo_date "md5sum.txt下载成功..." >> $LOG_FILE
	fi
	
	echo_date "开始下载规则文件" >> $LOG_FILE
	wget --no-check-certificate --timeout=20 --tries=1 $url_main/$1/proxy-group.yaml
	if [ "$?" != "0" ];then
		echo_date "规则文件下载失败！" >> $LOG_FILE
		clash_ok=0
	else
		clash_ok=1
		echo_date "规则文件下载成功..." >> $LOG_FILE
	fi	

	if [ "$md5sum_ok" == "1" ] && [ "$clash_ok" == "1" ]; then
		check_md5sum
	else
		echo_date "使用备用服务器下载..." >> $LOG_FILE
		echo_date "下载失败，请检查你的网络！" >> $LOG_FILE
		echo_date "===================================================================" >> $LOG_FILE
		echo BBABBBBC
		exit 1
	fi
}

check_md5sum(){
	cd /tmp/proxygroup
	echo_date "校验下载的文件!" >> $LOG_FILE
	pg_LOCAL_MD5=$(md5sum proxy-group.yaml|awk '{print $1}')
	pg_ONLINE_MD5=$(cat md5sum.txt|awk '{print $1}')
	if [ "$pg_LOCAL_MD5"x = "$pg_ONLINE_MD5"x ]; then
		echo_date "文件校验通过!" >> $LOG_FILE
		install_proxygroup
	else
		echo_date "校验未通过，可能是下载过程出现了什么问题，请检查你的网络！" >> $LOG_FILE
		echo_date "===================================================================" >> $LOG_FILE
		echo BBABBBBC
		exit 1
	fi
}

install_proxygroup(){
	echo_date "开始覆盖最新规则!" >> $LOG_FILE
	move_proxygroup
}

move_proxygroup(){
	echo_date "开始替换规则文件... " >> $LOG_FILE
	mv /tmp/proxygroup/proxy-group.yaml /jffs/softcenter/merlinclash/yaml/proxy-group.yaml
	dbus set merlinclash_proxygroup_version="$pgver"
	echo_date "规则文件文件替换成功... " >> $LOG_FILE
	echo_date "使用内置订阅时将使用新的规则文件... " >> $LOG_FILE
}

case $1 in
start)
	echo "更新规则文件" > $LOG_FILE
	echo_date "===================================================================" >> $LOG_FILE
	get_latest_version >> $LOG_FILE 2>&1
	echo_date "===================================================================" >> $LOG_FILE
	echo BBABBBBC >> $LOG_FILE
	;;
esac
