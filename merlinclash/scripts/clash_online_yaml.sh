#!/bin/sh

source /jffs/softcenter/scripts/base.sh
eval $(dbus export merlinclash_)
alias echo_date='echo 【$(date +%Y年%m月%d日\ %X)】:'
LOG_FILE=/tmp/merlinclash_log.txt
lan_ip=$(nvram get lan_ipaddr)
rm -rf /tmp/merlinclash_log.txt
rm -rf /tmp/*.yaml
LOCK_FILE=/tmp/yaml_online_update.lock
flag=0
upname=""
upname_tmp=""

start_online_update(){
	merlinc_link=$merlinclash_links
	LINK_FORMAT=$(echo "$merlinc_link" | grep -E "^http://|^https://")
	upname_tmp=$merlinclash_uploadrename
	echo_date "上传文件重命名为：$upname_tmp" >> $LOG_FILE
	time=$(date "+%Y%m%d-%H%M%S")
	newname=$(echo $time | awk -F'-' '{print $2}')
	if [ -n "$upname_tmp" ]; then
		upname=$upname_tmp.yaml
	else
		upname=$newname.yaml
	fi
	if [ -z "$LINK_FORMAT" ]; then
		echo_date "订阅地址错误！检测到你输入的订阅地址并不是标准网址格式！"
		sleep 2
		echo_date "退出订阅程序" >> $LOG_FILE
		unset_lock
	else
		#echo_date merlinclash_link=$merlinc_link >> $LOG_FILE
		#wget下载文件
		wget --no-check-certificate -t3 -T30 -4 -O /tmp/$upname "$merlinc_link"
		if [ -f /tmp/$upname ]; then		
			echo_date "yaml文件合法性检查" >> $LOG_FILE
			check_yamlfile
			if [ $flag == "1" ]; then
				#后台执行上传文件名.yaml处理工作，包括去注释，去空白行，去除dns以上头部，将标准头部文件复制一份到/tmp/ 跟tmp的标准头部文件合并，生成新的head.yaml，再将head.yaml复制到/jffs/softcenter/merlinclash/并命名为upload.yaml
				echo_date "后台执行yaml文件处理工作" >> $LOG_FILE
				sh /jffs/softcenter/scripts/clash_yaml_sub.sh >/dev/null 2>&1 &
			else
				echo_date "没找到.yaml文件或.yaml文件格式不合法" >> $LOG_FILE
				unset_lock
			fi
		else
			echo_date "下载订阅文件失败，请稍后再试，退出" >> $LOG_FILE
		fi
	fi

	

}
check_yamlfile(){
	#通过获取的文件是否存在port: Rule: Proxy: Proxy Group: 标题头确认合法性
	para1=$(sed -n '/^port:/p' /tmp/$upname)
	para2=$(sed -n '/^socks-port:/p' /tmp/$upname)
	para3=$(sed -n '/^mode:/p' /tmp/$upname)
	#para4=$(sed -n '/^name:/p' /tmp/upload.yaml)
	#para5=$(sed -n '/^type:/p' /tmp/upload.yaml)
	if [ ! -n "$para1" ] || [ ! -n "$para2" ] || [ ! -n "$para3" ]; then
		echo_date "获取的文件不是合法的yaml文件，请检查订阅连接是否有误" >> $LOG_FILE
		rm -rf /tmp/$upname
		unset_lock
	else
		echo_date "获取的文件检查通过" >> $LOG_FILE
		flag=1
	fi
}
set_lock(){
	exec 233>"$LOCK_FILE"
	flock -n 233 || {
		echo_date "订阅脚本已经在运行，请稍候再试！" >> $LOG_FILE	
		unset_lock
	}
}

unset_lock(){
	flock -u 233
	rm -rf "$LOCK_FILE"
}

case $1 in
2)
	set_lock
	echo "" > $LOG_FILE
	echo_date "订阅链接处理" >> $LOG_FILE
	start_online_update >> $LOG_FILE
	echo BBABBBBC >> $LOG_FILE
	unset_lock
	;;
esac

