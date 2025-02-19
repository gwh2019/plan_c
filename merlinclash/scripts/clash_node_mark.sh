#!/bin/sh

source /jffs/softcenter/scripts/base.sh
alias echo_date='echo 【$(TZ=UTC-8 date -R +%Y年%m月%d日\ %X)】:'
LOG_FILE=/tmp/merlinclash_node_mark.log
eval `dbus export merlinclash_`
alias echo_date='echo 【$(TZ=UTC-8 date -R +%Y年%m月%d日\ %X)】:'

yamlname=$merlinclash_yamlsel
#配置文件路径
yamlpath=/jffs/softcenter/merlinclash/$yamlname.yaml
#提取配置认证码
secret=$(cat $yamlpath | awk '/secret:/{print $2}' | sed 's/"//g')
#提取配置监听端口
ecport=$(cat $yamlpath | awk -F: '/external-controller/{print $3}')

lan_ipaddr=$(nvram get lan_ipaddr)

name=clash

#闪存配置文件夹
dirconf=/jffs/softcenter/merlinclash/mark
#内存目录文件夹
dirtmp=/tmp/clash


#在内存里对比并保存节点记忆文件到闪存，放进程守护里定时运行
setmark () {
	while [ "$merlinclash_enable" == "1" ]; do
		[ ! -d $dirtmp/mark ] && mkdir -p $dirtmp/mark
		[ ! -d $dirconf ] && mkdir -p $dirconf
		echo_date "创建/tmp/clash/mark文件夹,存放策略组节点记录" >> $LOG_FILE
		curl -s -X GET "http://$lan_ipaddr:$ecport/proxies" -H "Authorization: Bearer $secret" | sed 's/\},/\},\n/g'  | grep "Selector" | grep "now" |grep -Eo "name.*" > $dirtmp/mark/mark_new.txt
		if [ ! -s $dirtmp/mark/mark_old.txt ] ; then
			if [ ! -s $dirconf/mark.txt ] ; then
			#mark.txt为空，则执行
				echo -e \\n"\e[36m  ▶直接保存[节点位置记录]到$dirconf/mark.txt ...\e[0m" >> $LOG_FILE
				cp -f $dirtmp/mark/mark_new.txt $dirtmp/mark/mark_old.txt
				cp -f $dirtmp/mark/mark_new.txt $dirconf/mark.txt
				[ -f $dirtmp/mark/mark_ok_* ] && rm $dirtmp/mark/mark_ok_*
				> $dirtmp/mark/mark_ok_0
				exit
			else
				cp -f $dirconf/mark.txt $dirtmp/mark/mark_old.txt
			fi
		fi
		#new=$(openssl SHA1 $dirtmp/mark/mark_new.txt |awk '{print $2}')
		#old=$(openssl SHA1 $dirtmp/mark/mark_old.txt |awk '{print $2}')
		new=$(md5sum $dirtmp/mark/mark_new.txt | awk '{print $1}')
		old=$(md5sum $dirtmp/mark/mark_old.txt | awk '{print $1}')
		if [ "$new" != "$old" ] ; then
			echo -e \\n"\e[36m  ▶保存新[节点位置记录]到$dirconf/mark.txt ...\e[0m" >> $LOG_FILE
			cp -f $dirtmp/mark/mark_new.txt $dirtmp/mark/mark_old.txt
			cp -f $dirtmp/mark/mark_new.txt $dirconf/mark.txt
			[ -f $dirtmp/mark/mark_ok_* ] && rm $dirtmp/mark/mark_ok_*
			> $dirtmp/mark/mark_ok_0
		else
			echo "节点位置记录文件无需更新" >> $LOG_FILE
			[ -f $dirtmp/mark/mark_ok_* ] && rm $dirtmp/mark/mark_ok_*
			> $dirtmp/mark/mark_ok_1
		fi
		sleep 60s
    	continue
	done
}

#还原节点记忆
remark () {
	[ ! -d $dirtmp/mark ] && mkdir -p $dirtmp/mark
	secret=$(cat $yamlpath | awk '/secret:/{print $2}' | sed 's/"//g')
	port=$(cat $yamlpath | awk -F: '/external-controller/{print $3}')
	#从闪存里读取节点记录文件
	if [ -s $dirconf/mark.txt ] && [ "$merlinclash_yamlselchange" != "1" ] ; then
		echo_date "▶还原节点位置记录..."
		filename=/jffs/softcenter/merlinclash/mark/mark.txt

		lines=$(cat $filename | wc -l)
		echo_date "符合Selector的策略组为：$lines个"
		i=1
		while [ "$i" -le "$lines" ]
		do
			line=$(sed -n ''$i'p' "$filename")
			#echo $line
			#echo ""
			names=$(echo $line |grep -o "name.*"|awk -F\" '{print $3}')
			now=$(echo $line | grep -o "now.*"|awk -F\" '{print $3}')
			#echo "names=$names"
			#echo "now=$now"
			#echo "策略组=$names"
       	 	#echo "选中节点=$now"
       	 	#echo ""
			if [ -z "$(echo "$names"  | grep -E '^[A-Za-z0-9]+$')" ] ; then
				nameencode=$(curl -sv -G --data-urlencode "$names" -X GET "http://$lan_ipaddr:$ecport" 2>&1 |awk '/GET/{print $3}'|sed 's@/?@@')
			else
				nameencode=$names
			fi
			echo -e \\n"●代理集：$names → 上次位置：$now"
			echo -e "■encode编码：$nameencode"
			curl -sv \
			-H "Authorization: Bearer $secret" \
			-X PUT "http://$lan_ipaddr:$ecport/proxies/$nameencode"  -d "{\"name\": \"$now\"}" 2>&1
			echo ""
			let i=i+1
		done > /tmp/mark_status.txt
		sed -i "1i\######$(date "+%Y-%m-%d %H:%M:%S") #######" /tmp/mark_status.txt
		sed -i '$a BBABBBBC' /tmp/mark_status.txt
	else
		echo_date "▶节点位置记录文件不存在 或 配置文件更换首次启动，跳过还原。" 
		rm -rf /tmp/mark_status.txt
	fi
}

#检查进程端口日志都启动成功，成功就执行还原节点记录。
start_remark () {
	if [ ! -z "$(pidof $name)" -a ! -z "$(netstat -anp | grep $name)" -a ! -z "$(grep "Parse config error" /tmp/clash_run.log)" ] ; then
		remark
	else
		echo_date "remark：$name进程没启动成功或端口没监听，跳过还原节点记录。"
	fi
}


#按钮，外部调用。
#如在进程守护脚本里定时运行脚本
#sh /etc/clash/clash.sh setmark
#判断结果
#[ -f /tmp/clash/mark/mark_ok_0 ] && echo "节点记录已更新"


case $1 in
start_remark)
	start_remark
	;;
remark)
	remark
	;;
setmark)
	setmark
	;;
esac

