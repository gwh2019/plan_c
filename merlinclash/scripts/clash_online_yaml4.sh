#!/bin/sh

source /jffs/softcenter/scripts/base.sh
eval $(dbus export merlinclash_)
alias echo_date='echo 【$(date +%Y年%m月%d日\ %X)】:'
LOG_FILE=/tmp/merlinclash_log.txt

rm -rf /tmp/merlinclash_log.txt
rm -rf /tmp/*.yaml
LOCK_FILE=/var/lock/yaml_online_update.lock
flag=0
upname=""
upname_tmp=""

start_online_update(){
	merlinc_link=$merlinclash_links3
	LINK_FORMAT=$(echo "$merlinc_link" | grep -E "^http|^https")
	echo_date "订阅地址是：$LINK_FORMAT"
	if [ -z "$LINK_FORMAT" ]; then
		echo_date "订阅地址错误！检测到你输入的订阅地址并不是标准网址格式！"
		sleep 2
		echo_date "退出订阅程序,请手动刷新退出" >> $LOG_FILE
	else
		upname_tmp="$merlinclash_uploadrename4"
		#echo_date "订阅文件重命名为：$upname_tmp" >> $LOG_FILE
		time=$(date "+%Y%m%d-%H%M%S")
		newname=$(echo $time | awk -F'-' '{print $2}')
		case $merlinclash_acl4ssrsel in
		Online)
			_name="OL_"
			links="https://gfwsb.114514.best/sub?target=clashr&new_name=true&url=$merlinc_link&insert=false&config=https%3A%2F%2Fraw.githubusercontent.com%2FACL4SSR%2FACL4SSR%2Fmaster%2FClash%2Fconfig%2FACL4SSR_Online.ini"			
			;;
		AdblockPlus)
			_name="AP_"
			links="https://gfwsb.114514.best/sub?target=clashr&new_name=true&url=$merlinc_link&insert=false&config=https%3A%2F%2Fraw.githubusercontent.com%2FACL4SSR%2FACL4SSR%2Fmaster%2FClash%2Fconfig%2FACL4SSR_Online_AdblockPlus.ini"
			;;
		NoAuto)
			_name="NA_"
			links="https://gfwsb.114514.best/sub?target=clashr&new_name=true&url=$merlinc_link&insert=false&config=https%3A%2F%2Fraw.githubusercontent.com%2FACL4SSR%2FACL4SSR%2Fmaster%2FClash%2Fconfig%2FACL4SSR_Online_NoAuto.ini"
			;;
		NoReject)
			_name="NR_"
			links="https://gfwsb.114514.best/sub?target=clashr&new_name=true&url=$merlinc_link&insert=false&config=https%3A%2F%2Fraw.githubusercontent.com%2FACL4SSR%2FACL4SSR%2Fmaster%2FClash%2Fconfig%2FACL4SSR_Online_NoReject.ini"
			;;
		Mini)
			_name="Mini_"
			links="https://gfwsb.114514.best/sub?target=clashr&new_name=true&url=$merlinc_link&insert=false&config=https%3A%2F%2Fraw.githubusercontent.com%2FACL4SSR%2FACL4SSR%2Fmaster%2FClash%2Fconfig%2FACL4SSR_Online_Mini.ini"
			;;
		Mini_AdblockPlus)
			_name="MAP_"
			links="https://gfwsb.114514.best/sub?target=clashr&new_name=true&url=$merlinc_link&insert=false&config=https%3A%2F%2Fraw.githubusercontent.com%2FACL4SSR%2FACL4SSR%2Fmaster%2FClash%2Fconfig%2FACL4SSR_Online_Mini_AdblockPlus.ini"
			;;
		Mini_NoAuto)
			_name="MNA_"
			links="https://gfwsb.114514.best/sub?target=clashr&new_name=true&url=$merlinc_link&insert=false&config=https%3A%2F%2Fraw.githubusercontent.com%2FACL4SSR%2FACL4SSR%2Fmaster%2FClash%2Fconfig%2FACL4SSR_Online_Mini_NoAuto.ini"
			;;
		Mini_Fallback)
			_name="MF_"
			links="https://gfwsb.114514.best/sub?target=clashr&new_name=true&url=$merlinc_link&insert=false&config=https%3A%2F%2Fraw.githubusercontent.com%2FACL4SSR%2FACL4SSR%2Fmaster%2FClash%2Fconfig%2FACL4SSR_Online_Mini_Fallback.ini"
			;;
		Mini_MultiMode)
			_name="MMM_"
			links="https://gfwsb.114514.best/sub?target=clashr&new_name=true&url=$merlinc_link&insert=false&config=https%3A%2F%2Fraw.githubusercontent.com%2FACL4SSR%2FACL4SSR%2Fmaster%2FClash%2Fconfig%2FACL4SSR_Online_Mini_MultiMode.ini"
			;;
		esac
		if [ -n "$upname_tmp" ]; then
			upname="$_name$upname_tmp.yaml"
		else
			upname="$_name$newname.yaml"
		fi
			#links="https://gfwsb.114514.best/sub?target=clashr&new_name=true&url=$merlinc_link&insert=false&config=https%3A%2F%2Fraw.githubusercontent.com%2FACL4SSR%2FACL4SSR%2Fmaster%2FClash%2Fconfig%2FACL4SSR_Online.ini"
			#echo_date merlinclash_link=$merlinc_link >> $LOG_FILE
			#wget下载文件
			wget --no-check-certificate -t3 -T30 -4 -O /tmp/$upname "$links"
			if [ "$?" == "0" ];then
				echo_date "检查文件完整性" >> $LOG_FILE
				if [ -z "$(cat /tmp/$upname)" ];then 
					echo_date "获取clash配置文件失败！" >> $LOG_FILE
					failed_warning_clash
				else
					echo_date "已获取clash配置文件" >> $LOG_FILE
					echo_date "yaml文件合法性检查" >> $LOG_FILE	
					check_yamlfile
					if [ $flag == "1" ]; then
					#后台执行上传文件名.yaml处理工作，包括去注释，去空白行，去除dns以上头部，将标准头部文件复制一份到/tmp/ 跟tmp的标准头部文件合并，生成新的head.yaml，再将head.yaml复制到/jffs/softcenter/merlinclash/并命名为upload.yaml
						echo_date "后台执行yaml文件处理工作" >> $LOG_FILE
						sh /jffs/softcenter/scripts/clash_yaml_sub.sh >/dev/null 2>&1 &
					else
						echo_date "yaml文件格式不合法" >> $LOG_FILE
					fi
				fi
			else
				failed_warning_clash
			fi
	fi

	

}
check_yamlfile(){
	#通过获取的文件是否存在port: Rule: Proxy: Proxy Group: 标题头确认合法性
	para1=$(sed -n '/^port:/p' /tmp/$upname)
	para1_1=$(sed -n '/^mixed-port:/p' /tmp/$upname)
	para2=$(sed -n '/^socks-port:/p' /tmp/$upname)
	#para3=$(sed -n '/^mode:/p' /tmp/$upname)
	#para4=$(sed -n '/^name:/p' /tmp/upload.yaml)
	#para5=$(sed -n '/^type:/p' /tmp/upload.yaml)

	if ([ ! -n "$para1" ] && [ ! -n "$para1_1" ]) && [ ! -n "$para2" ]; then
		echo_date "clash配置文件不是合法的yaml文件，转换格式可能有误" >> $LOG_FILE
		rm -rf /tmp/$upname
	else
		echo_date "clash配置文件检查通过" >> $LOG_FILE
		flag=1
	fi
}

failed_warning_clash(){
	rm -rf /tmp/$upname
	echo_date "获取文件失败！！请检查网络！" >> $LOG_FILE
	echo_date "===================================================================" >> $LOG_FILE
	echo BBABBBBC
	exit 1
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

case $ACTION in
restart)
	set_lock
	echo "" > $LOG_FILE
	echo_date "ACL4SSR订阅处理" >> $LOG_FILE
	start_online_update >> $LOG_FILE
	echo BBABBBBC >> $LOG_FILE
	unset_lock
	;;
esac

