#!/bin/sh

source /jffs/softcenter/scripts/base.sh
alias echo_date='echo 【$(TZ=UTC-8 date -R +%Y年%m月%d日\ %X)】:'
LOG_FILE=/tmp/merlinclash_log.txt
LOCK_FILE=/var/lock/merlinclash.lock
eval `dbus export merlinclash_`

yamlname=$merlinclash_yamlsel
#配置文件路径
yamlpath=/jffs/softcenter/merlinclash/$yamlname.yaml
#提取配置认证码
secret=$(cat $yamlpath | awk '/secret:/{print $2}' | sed 's/"//g')
#提取配置监听端口
ecport=$(cat $yamlpath | awk -F: '/external-controller/{print $3}')
chromecast_nu=""
lan_ipaddr=$(nvram get lan_ipaddr)
ssh_port=$(nvram get sshd_port)
head_tmp=/jffs/softcenter/merlinclash/yaml/head.yaml

ip_prefix_hex=$(nvram get lan_ipaddr | awk -F "." '{printf ("0x%02x", $1)} {printf ("%02x", $2)} {printf ("%02x", $3)} {printf ("00/0xffffff00\n")}')
uploadpath=/tmp/
bridge=$(ifconfig | grep br | awk -F' ' '{print $1}')
set_lock() {
	exec 1000>"$LOCK_FILE"
	flock -x 1000
}

unset_lock() {
	flock -u 1000
	rm -rf "$LOCK_FILE"
}

move_config(){
	#查找upload文件夹是否有刚刚上传的yaml文件，正常只有一份
	#name=$(find $uploadpath  -name "$yamlname.yaml" |sed 's#.*/##')
	echo_date "上传的文件名是$merlinclash_uploadfilename" >> $LOG_FILE
	if [ -f "/tmp/$merlinclash_uploadfilename" ]; then
		#后台执行上传文件名.yaml处理工作，包括去注释，去空白行，去除dns以上头部，将标准头部文件复制一份到/tmp/ 跟tmp的标准头部文件合并，生成新的head.yaml，再将head.yaml复制到/jffs/softcenter/merlinclash/并命名为上传文件名.yaml
		#echo_date "后台执行yaml文件处理工作"
		#sh /jffs/softcenter/scripts/clash_yaml_sub.sh >/dev/null 2>&1 &
		echo_date "执行yaml文件处理工作"
		mkdir -p /tmp/yaml
		rm -rf /tmp/yaml/*
		cp -rf /tmp/$merlinclash_uploadfilename /tmp/yaml/$merlinclash_uploadfilename
		sh /jffs/softcenter/scripts/clash_yaml_upload_sub.sh
	else
		echo_date "没找到yaml文件"
		rm -rf /tmp/*.yaml
		exit 1
	fi


}

select_config(){
	y=$(find /jffs/softcenter/merlinclash/config -name "*.yaml")
    for y_tmp in $y
	do
		y_tmp=$(echo $y | cut -d '/' -f 5)
		echo $y_tmp
	done
}
watchdog(){
	if [ "$merlinclash_enable" == "1" ] && [ "$merlinclash_watchdog" == "1" ];then
		/bin/sh /jffs/softcenter/scripts/clash_watchdog.sh >/dev/null 2>&1 &
	else
		pid_watchdog=$(ps | grep clash_watchdog.sh | grep -v grep | awk '{print $1}')
		if [ -n "$pid_watchdog" ]; then
		echo_date 关闭看门狗进程...
		# 有时候killall杀不了v2ray进程，所以用不同方式杀两次
		kill -9 "$pid_watchdog" >/dev/null 2>&1
		fi
	fi
}
auto_setmark(){
	if [ "$merlinclash_enable" == "1" ];then
		if [ ! -z "$(pidof clash)" -a ! -z "$(netstat -anp | grep clash)" -a ! -n "$(grep "Parse config error" /tmp/clash_run.log)" ] ; then
			/bin/sh /jffs/softcenter/scripts/clash_node_mark.sh setmark >/dev/null 2>&1 &
			echo_date "开启自动获取节点信息" >> $LOG_FILE
		else	
			echo_date "clash进程故障，不开启自动获取节点信息" >> $LOG_FILE
		fi
	else
		pid_setmark=$(ps | grep clash_node_mark.sh | grep -v grep | awk '{print $1}')
		if [ -n "$pid_setmark" ]; then
		echo_date 关闭节点状态获取进程...
		# 有时候killall杀不了v2ray进程，所以用不同方式杀两次
		kill -9 "$pid_setmark" >/dev/null 2>&1
		fi
	fi
}

kill_setmark(){
	pid_setmark=$(ps | grep clash_node_mark.sh | grep -v grep | awk '{print $1}')
	if [ -n "$pid_setmark" ]; then
		echo_date 关闭节点状态获取进程...
		# 有时候killall杀不了v2ray进程，所以用不同方式杀两次
		kill -9 "$pid_setmark" >/dev/null 2>&1
	fi
}
kill_process() {
	clash_process=$(pidof clash)
	pid_watchdog=$(ps | grep clash_watchdog.sh | grep -v grep | awk '{print $1}')
	kcp_process=$(pidof client_linux)
	pid_setmark=$(ps | grep clash_node_mark.sh | grep -v grep | awk '{print $1}')
	if [ -n "$kcp_process" ]; then
		echo_date 关闭kcp协议进程... >> $LOG_FILE
		killall client_linux >/dev/null 2>&1
	fi
	if [ -n "$clash_process" ]; then
		echo_date 关闭clash进程...
		# 有时候killall杀不了clash进程，所以用不同方式杀两次
		killall clash >/dev/null 2>&1
		kill -9 "$clash_process" >/dev/null 2>&1
	fi
	if [ -n "$pid_watchdog" ]; then
		echo_date 关闭看门狗进程...
		# 有时候killall杀不了watchdog进程，所以用不同方式杀两次
		kill -9 "$pid_watchdog" >/dev/null 2>&1
	fi
	if [ -n "$pid_setmark" ]; then
		echo_date 关闭节点状态获取进程...
		# 有时候killall杀不了v2ray进程，所以用不同方式杀两次
		kill -9 "$pid_setmark" >/dev/null 2>&1
	fi
}
kill_clash() {
	clash_process=$(pidof clash)	
		if [ -n "$clash_process" ]; then
		echo_date 关闭clash进程...
		# 有时候killall杀不了clash进程，所以用不同方式杀两次
		killall clash >/dev/null 2>&1
		kill -9 "$clash_process" >/dev/null 2>&1
	fi	
}
flush_nat() {
	proxy_port=23457
	#ssh_port=22
	echo_date 清除iptables规则... >> $LOG_FILE
	# flush rules and set if any
	nat_indexs=$(iptables -nvL PREROUTING -t nat | sed 1,2d | sed -n '/clash/=' | sort -r)
	for nat_index in $nat_indexs; do
		iptables -t nat -D PREROUTING $nat_index >/dev/null 2>&1
	done
	mangle_indexs=$(iptables -nvL PREROUTING -t mangle | sed 1,2d | sed -n '/clash/=' | sort -r)
    for mangle_index in $mangle_indexs; do
        iptables -t mangle -D PREROUTING $mangle_index >/dev/null 2>&1
    done
	iptables -t nat -D PREROUTING -p tcp --dport $ssh_port -j ACCEPT >/dev/null 2>&1
	#DNS端口
	iptables -t nat -D PREROUTING -p udp -m udp --dport 53 -j DNAT --to-destination $lan_ipaddr:23453 >/dev/null 2>&1
	iptables -t nat -D PREROUTING -p tcp -j merlinclash
	iptables -t nat -D PREROUTING -p tcp -i br0 -j merlinclash
	#20200725清除设备绕行，测试++
	ipt_1=$(echo $lan_ipaddr | awk -F"." '{print $1}')
	ipt_2=$(echo $lan_ipaddr | awk -F"." '{print $2}')
	ipt_3=$ipt_1.$ipt_2
	pass_indexs=$(iptables -nvL PREROUTING -t nat | sed 1,2d |  grep 'RETURN' | sed -n "/$ipt_3/=" | sort -r)
	for pass_index in $pass_indexs; do
		iptables -t nat -D PREROUTING $pass_index >/dev/null 2>&1
		iptables -t mangle -D PREROUTING $pass_index >/dev/null 2>&1
	done
	#---------------------------
	iptables -t nat -D clash_dns -p udp -j REDIRECT --to-ports 23453
	iptables -t nat -D PREROUTING -p udp --dport 53 -j clash_dns
	iptables -t nat -D OUTPUT -p udp --dport 53 -j clash_dns
	iptables -t nat -F clash_dns >/dev/null 2>&1
	iptables -t nat -X clash_dns >/dev/null 2>&1
	#udp
	#转发UDP流量到clash端口
	iptables -t mangle -D merlinclash -d 192.168.2.1 -j RETURN
	iptables -t mangle -D merlinclash -p udp -j TPROXY --on-port "$proxy_port" --tproxy-mark 0x01/0x01
	iptables -t mangle -D merlinclash -p udp -j TPROXY --on-port "$proxy_port" --tproxy-mark 0x07
	#透明代理UDP流量到clash mangle链
	iptables -t mangle -D PREROUTING -p udp -j merlinclash
	iptables -t mangle -D PREROUTING -p udp -i $bridge -j merlinclash

	iptables -t nat -D PREROUTING -p udp --dport 53 -j REDIRECT --to 23453
	iptables -t nat -D OUTPUT -p tcp -d 198.18.0.0/16 -j REDIRECT --to-port "$proxy_port"
	iptables -t nat -D PREROUTING -p udp -s $(get_lan_cidr) --dport 53 -j DNAT --to $lan_ipaddr >/dev/null 2>&1
	iptables -t nat -D PREROUTING -p udp --dport 53 -j REDIRECT --to-ports 23453
	iptables -t nat -D PREROUTING -p udp --dport 53 -d $lan_ipaddr -j DNAT --to-destination $lan_ipaddr:23453
	
	iptables -t mangle -F merlinclash >/dev/null 2>&1 && iptables -t mangle -X merlinclash >/dev/null 2>&1
	
	iptables -t nat -F merlinclash >/dev/null 2>&1 && iptables -t nat -X merlinclash >/dev/null 2>&1
	#echo_date 删除ip route规则.
	ip rule del fwmark 1 lookup 100
	ip route del local default dev lo table 100
	#ip rule del fwmark 0x07 table 310
	#ip route del local 0.0.0.0/0 dev lo table 310
	echo_date 清除iptables规则完毕... >> $LOG_FILE
	
}

close_in_five() {
	echo_date "插件将在5秒后自动关闭！！"
	local i=5
	while [ $i -ge 0 ]; do
		sleep 1s
		echo_date $i
		let i--
	done
	dbus set merlinclash_enable="0"
	if [ "$merlinclash_unblockmusic_enable" == "1" ]; then
		sh /jffs/softcenter/scripts/clash_unblockneteasemusic.sh stop
	fi
	stop_config >/dev/null
	echo_date "插件已关闭！！"
	echo_date ======================= Merlin Clash ========================
	unset_lock
	exit
}
#自定规则20200621
check_rule() {	
	# acl_nu 获取已存数据序号
	acl_nu=$(dbus list merlinclash_acl_type_ | cut -d "=" -f 1 | cut -d "_" -f 4 | sort -n)
	num=0
	if [ -n "$acl_nu" ]; then
		for acl in $acl_nu; do
			type=$(eval echo \$merlinclash_acl_type_$acl)
			#ipaddr_hex=$(echo $ipaddr | awk -F "." '{printf ("0x%02x", $1)} {printf ("%02x", $2)} {printf ("%02x", $3)} {printf ("%02x\n", $4)}')
			content=$(eval echo \$merlinclash_acl_content_$acl)
			lianjie=$(eval echo \$merlinclash_acl_lianjie_$acl)
			#写入自定规则到当前配置文件
			num1=$(($num+1))
			rules_line=$(sed -n -e '/^rules:/=' $yamlpath)
			echo_date "写入第$num1条自定规则到当前配置文件" >> $LOG_FILE
			
			sed "$rules_line a \ \ -\ $type,$content,$lianjie" -i $yamlpath
			let num++
		done
	else
		echo_date "没有自定规则" >> $LOG_FILE	
	fi
	dbus remove merlinclash_acl_type
	dbus remove merlinclash_acl_content
	dbus remove merlinclash_acl_lianjie
	#格式化文本,避免rules:规则 - 未对齐而报错 -20200727
	sed -i '/rules:/,/port:/s/^[][ ]*- /  - /g' $yamlpath
	
}
lan_bypass(){
	# deivce_nu 获取已存数据序号
	echo_date ---------------------- 设备绕行检查区 开始 ------------------------ >> $LOG_FILE
	echo_date "【检查是否存在设备绕行】" >> $LOG_FILE
	device_nu=$(dbus list merlinclash_device_ip_ | cut -d "=" -f 1 | cut -d "_" -f 4 | sort -n)
	num=0
	if [ -n "$device_nu" ]; then
		echo_date "【已设置设备绕行，将写入iptables】" >> $LOG_FILE
		for device in $device_nu; do
			ip=$(eval echo \$merlinclash_device_ip_$device)
			name=$(eval echo \$merlinclash_device_name_$device)
			echo_date "绕行设备名为【$name】,IP为【$ip】"
			#写入绕行规则到iptables
			#iptables -t nat -I merlinclash -s $ip/32 -j RETURN
  			#iptables -t mangle -I merlinclash -s $ip/32 -j RETURN
			iptables -t nat -I PREROUTING -s $ip/32 -j RETURN
  			iptables -t mangle -I PREROUTING -s $ip/32 -j RETURN
		done
	else
		echo_date "没有设置设备绕行" >> $LOG_FILE	
	fi
	dbus remove merlinclash_device_ip
	dbus remove merlinclash_device_name
	echo_date ---------------------- 设备绕行检查区 结束 ------------------------ >> $LOG_FILE
}
start_bind(){
	pgnodes_nu=$(dbus list merlinclash_pgnodes_nodesel_ | cut -d "=" -f 1 | cut -d "_" -f 4 | sort -n)
	pgnum=0
	if [ -n "$pgnodes_nu" ] ; then
		echo_date "检查到已配置节点记忆，将对策略组进行处理" >> $LOG_FILE
		#将/jffs/softcenter/merlinclash/$yamlname.yaml中的proxy-groups导出
		#定位proxy-group:跟rules:行数
		#proxygroup_line=$(cat $yamlpath | grep -n "^proxy-groups:" | awk -F ":" '{print $1}')
		#rules_line=$(cat $yamlpath | grep -n "^rules:" | awk -F ":" '{print $1}')
		#let rules_line=$rules_line-1
		#sed -n "$proxygroup_line,$rules_line p" $yamlpath > /tmp/b.yaml
		#删除原有
		#sed -i "$proxygroup_line,$rules_line d" $yamlpath
		#for pgnode in $pgnodes_nu; do
		#	proxygroup=$(eval echo \$merlinclash_pgnodes_proxygroup_$pgnode)
		#	nodesel=$(eval echo \$merlinclash_pgnodes_nodesel_$pgnode)
		#	echo_date "proxygroup的值是$proxygroup" >> $LOG_FILE
		#	echo_date "nodesel的值是$nodesel" >> $LOG_FILE
			#对proxygroup值进行分割，取序号
		#	order=$(echo $proxygroup | awk -F"." '{print $1}')
		#	let order=order-1
			#选中节点插到对应策略组最前
			#  order proxygroup      nodesel
			#比如12.聊天软件 --> [Trojan]台湾测试
			#yq w -i $yamlpath proxy-groups[$order].proxies[+0] "$nodesel"
		#	yq w -i /tmp/b.yaml proxy-groups[$order].proxies[+0] "$nodesel"
			#再将b.yaml内容导回去$yamlpath
			#插入换行符免得出错
		#	sed -i '$a' $yamlpath
		#	cat /tmp/b.yaml >> $yamlpath
		for pgnode in $pgnodes_nu; do
			proxygroup=$(eval echo \$merlinclash_encode_proxygroup_$pgnode)
			nodesel=$(eval echo \$merlinclash_pgnodes_nodesel_$pgnode)
			proxygroup=$(echo $proxygroup | awk -F"." '{print $2}')
			echo_date "已配置策略组:$proxygroup"
			echo_date "已指定节点:$nodesel"
			#热更新配置
			curl  -v \
			#-H "Content-Type: application/json; charset=utf-8" \
			-H "Authorization: Bearer $secret" \
			-X PUT "http://$lan_ipaddr:$ecport/proxies/$proxygroup" -d "{\"name\":\"${nodesel}\"}" >/dev/null 2>&1 &
		done
	else
		echo_date "未配置节点记忆" >> $LOG_FILE
	fi
	dbus remove merlinclash_pgnodes_proxygroup
	dbus remove merlinclash_pgnodes_nodesel
}
start_remark(){
	/bin/sh /jffs/softcenter/scripts/clash_node_mark.sh remark
}

start_kcp(){
	# kcp_nu 获取已存数据序号

	kcp_nu=$(dbus list merlinclash_kcp_lport_ | cut -d "=" -f 1 | cut -d "_" -f 4 | sort -n)
	kcpnum=0
	if [ -n "$kcp_nu" ] && [ "$merlinclash_kcpswitch" == "1" ]; then
		echo_date "检查到KCP开启且有KCP配置，将启动KCP加速" >> $LOG_FILE
		for kcp in $kcp_nu; do
			lport=$(eval echo \$merlinclash_kcp_lport_$kcp)
			server=$(eval echo \$merlinclash_kcp_server_$kcp)
			port=$(eval echo \$merlinclash_kcp_port_$kcp)
			param=$(eval echo \$merlinclash_kcp_param_$kcp)
			#根据传入值启动kcp进程
			kcpnum1=$(($kcpnum+1))
			echo_date "启动第$kcpnum1个kcp进程" >> $LOG_FILE
			/jffs/softcenter/bin/client_linux -l :$lport -r $server:$port $param >/dev/null 2>&1 &
			local kcppid
			kcppid=$(pidof client_linux)
			if [ -n "$kcppid" ];then
				echo_date "kcp进程启动成功，pid:$kcppid! "
			else
				echo_date "kcp进程启动失败！"
			fi
			let kcpnum++
		done
	else
		echo_date "没有打开KCP开关或者不存在KCP设置，不启动KCP加速" >> $LOG_FILE
		kcp_process=$(pidof client_linux)
		if [ -n "$kcp_process" ]; then
			echo_date "关闭残留KCP协议进程"... >> $LOG_FILE
			killall client_linux >/dev/null 2>&1
		fi	
	fi
	dbus remove merlinclash_kcp_lport
	dbus remove merlinclash_kcp_server
	dbus remove merlinclash_kcp_port
	dbus remove merlinclash_kcp_param	
}
creat_ipset() {
	echo_date 开始创建ipset名单
	ipset -! create merlinclash_white nethash && ipset flush merlinlclash_white
}

load_nat() {
	nat_ready=$(iptables -t nat -L PREROUTING -v -n --line-numbers | grep -v PREROUTING | grep -v destination)
	i=120
	until [ -n "$nat_ready" ]; do
		i=$(($i - 1))
		if [ "$i" -lt 1 ]; then
			echo_date "错误：不能正确加载nat规则!" >> $LOG_FILE
			close_in_five
		fi
		sleep 1s
		nat_ready=$(iptables -t nat -L PREROUTING -v -n --line-numbers | grep -v PREROUTING | grep -v destination)
	done
	echo_date "加载nat规则!" >> $LOG_FILE
	sleep 1s
	apply_nat_rules3
	#chromecast
}
add_white_black_ip() {
    # black ip/cidr
    #ip_tg="149.154.0.0/16 91.108.4.0/22 91.108.56.0/24 109.239.140.0/24 67.198.55.0/24"
    #for ip in $ip_tg; do
    #    ipset -! add koolclash_black $ip >/dev/null 2>&1
    #done

    # white ip/cidr
    echo_date '应用局域网 IP 白名单'
    ip_lan="0.0.0.0/8 10.0.0.0/8 100.64.0.0/10 127.0.0.0/8 169.254.0.0/16 172.16.0.0/12 192.168.0.0/16 224.0.0.0/4 240.0.0.0/4 $lan_ipaddr"
    for ip in $ip_lan; do
        ipset -! add merlinclash_white $ip >/dev/null 2>&1
    done

    #if [ ! -z $koolclash_firewall_whiteip_base64 ]; then
    #   ip_white=$(echo $koolclash_firewall_whiteip_base64 | base64_decode | sed '/\#/d')
    #    echo_date '应用外网目标 IP/CIDR 白名单'
    #    for ip in $ip_white; do
    #        ipset -! add koolclash_white $ip >/dev/null 2>&1
    #    done
    #fi
}
load_tproxy() {
	MODULES="xt_TPROXY xt_socket xt_comment"
	OS=$(uname -r)
	# load Kernel Modules
	echo_date 加载TPROXY模块，用于udp转发... >> $LOG_FILE
	checkmoduleisloaded() {
		if lsmod | grep $MODULE &>/dev/null; then return 0; else return 1; fi
	}

	for MODULE in $MODULES; do
		if ! checkmoduleisloaded; then
			insmod /lib/modules/${OS}/kernel/net/netfilter/${MODULE}.ko
		fi
	done

	modules_loaded=0

	for MODULE in $MODULES; do
		if checkmoduleisloaded; then
			modules_loaded=$((j++))
		fi
	done

	if [ $modules_loaded -ne 2 ]; then
		echo "One or more modules are missing, only $((modules_loaded + 1)) are loaded. Can't start." >> $LOG_FILE
		close_in_five
	fi
}
apply_nat_rules3() {
	proxy_port=23457
	#ssh_port=22
	dem2=$(cat $yamlpath | grep "enhanced-mode:" | awk -F "[: ]" '{print $5}')
	echo_date "开始写入iptable规则" >> $LOG_FILE
	
	if [ "$merlinclash_dnsplan" == "rh" ] || [ "$merlinclash_dnsplan" == "rhp" ] || [ "$dem2" == "redir-host" ];then
		# ports redirect for clash except port 22 for ssh connection
		echo_date "dns方案是$merlinclash_dnsplan;配置文件dns方案是$dem2" >> $LOG_FILE
		echo_date "lan_ip是$lan_ipaddr" >> $LOG_FILE
		iptables -t nat -A PREROUTING -p tcp --dport $ssh_port -j ACCEPT
		#new
		iptables -t nat -N merlinclash
		iptables -t nat -A merlinclash -d 192.168.0.0/16 -j RETURN
		iptables -t nat -A merlinclash -d 0.0.0.0/8 -j RETURN
		iptables -t nat -A merlinclash -d 10.0.0.0/8 -j RETURN
		iptables -t nat -A merlinclash -d 127.0.0.0/8 -j RETURN
		iptables -t nat -A merlinclash -d 169.254.0.0/16 -j RETURN
		iptables -t nat -A merlinclash -d 172.16.0.0/12 -j RETURN
		iptables -t nat -A merlinclash -d 224.0.0.0/4 -j RETURN
		iptables -t nat -A merlinclash -d 240.0.0.0/4 -j RETURN

		#redirect to Clash
		iptables -t nat -A merlinclash -p tcp -j REDIRECT --to-ports $proxy_port
		#iptables -t nat -A PREROUTING -j merlinclash
		iptables -t nat -A PREROUTING -p tcp -j merlinclash
		#DNS
		if [ "$merlinclash_dnsplan" == "rh" ]; then
			iptables -t nat -A PREROUTING -p udp --dport 53 -j REDIRECT --to-ports 23453
		fi
		if [ "$merlinclash_dnsplan" == "rhp" ]; then
			iptables -t nat -N clash_dns >/dev/null 2>&1
			iptables -t nat -F clash_dns >/dev/null 2>&1
			iptables -t nat -A clash_dns -p udp -j REDIRECT --to-ports 23453
			iptables -t nat -A PREROUTING -p udp --dport 53 -j clash_dns
			iptables -t nat -A OUTPUT -p udp --dport 53 -j clash_dns
		fi
		
	fi
	#fake-ip rule
	if [ "$merlinclash_dnsplan" == "fi" ] || [ "$dem2" == "fake-ip" ];then
		echo_date "dns方案是$merlinclash_dnsplan;配置文件dns方案是$dem2" >> $LOG_FILE
		echo_date "lan_ip是$lan_ipaddr" >> $LOG_FILE
		# ports redirect for clash except port 22 for ssh connection
		iptables -t nat -A PREROUTING -p tcp --dport $ssh_port -j ACCEPT
		#new
		iptables -t nat -N merlinclash
		iptables -t nat -A merlinclash -d 192.168.0.0/16 -j RETURN
		iptables -t nat -A merlinclash -d 10.0.0.0/8 -j RETURN
		iptables -t nat -A merlinclash -d 0.0.0.0/8 -j RETURN
		iptables -t nat -A merlinclash -d 127.0.0.0/8 -j RETURN
		iptables -t nat -A merlinclash -d 169.254.0.0/16 -j RETURN
		iptables -t nat -A merlinclash -d 172.16.0.0/12 -j RETURN
		iptables -t nat -A merlinclash -d 224.0.0.0/4 -j RETURN
		iptables -t nat -A merlinclash -d 240.0.0.0/4 -j RETURN

		#redirect to Clash
		iptables -t nat -A merlinclash -p tcp -j REDIRECT --to-ports $proxy_port
		iptables -t nat -A PREROUTING -p tcp -j merlinclash
		
		
		# fake-ip rules
		#iptables -t nat -A OUTPUT -p tcp -m mark --mark "$ip_prefix_hex" -d 198.18.0.0/16 -j RETURN
		#iptables -t nat -A OUTPUT -p tcp -d 198.18.0.0/16 -j REDIRECT --to-ports $proxy_port
		#DNS
		iptables -t nat -A PREROUTING -p udp -m udp --dport 53 -j DNAT --to-destination $lan_ipaddr:23453			
	fi

	if [ "$merlinclash_udpr" == "1" ]; then
		echo_date "检测到开启udp转发，将创建相关iptable规则" >> $LOG_FILE
		# udp
		load_tproxy
		# 设置策略路由
		#modprobe xt_TPROXY
		#ip rule add fwmark 0x07 table 310
		
		#ip route add local 0.0.0.0/0 dev lo table 310
		ip rule add fwmark 1 lookup 100
		ip route add local default dev lo table 100
		iptables -t mangle -N merlinclash
		iptables -t mangle -F merlinclash
		#绕过内网
		
		#iptables -t mangle -A merlinclash -d 192.168.0.0/16 -j RETURN
		iptables -t mangle -A merlinclash -d 192.168.0.0/16 -p tcp -j RETURN
		iptables -t mangle -A merlinclash -d 192.168.0.0/16 -p udp ! --dport 53 -j RETURN
		iptables -t mangle -A merlinclash -d 192.168.0.0/16 -p udp ! --dport 23453 -j RETURN
		iptables -t mangle -A merlinclash -d 10.0.0.0/8 -j RETURN
		iptables -t mangle -A merlinclash -d 0.0.0.0/8 -j RETURN
		iptables -t mangle -A merlinclash -d 127.0.0.0/8 -j RETURN
		iptables -t mangle -A merlinclash -d 169.254.0.0/16 -j RETURN
		iptables -t mangle -A merlinclash -d 172.16.0.0/12 -j RETURN
		iptables -t mangle -A merlinclash -d 224.0.0.0/4 -j RETURN
		iptables -t mangle -A merlinclash -d 240.0.0.0/4 -j RETURN	
		#转发UDP流量到clash端口
		iptables -t mangle -A merlinclash -p udp -j TPROXY --on-port "$proxy_port" --tproxy-mark 0x01/0x01
		#透明代理UDP流量到clash mangle链
		iptables -t mangle -A PREROUTING -p udp -i $bridge -j merlinclash
		#iptables -t mangle -A PREROUTING -p udp -j merlinclash
	else
		echo_date "【检测到udp转发未开启，进行下一步】" >> $LOG_FILE

	fi
	#设备绕行
	lan_bypass

	echo_date "iptable规则创建完成" >> $LOG_FILE
}
restart_dnsmasq() {
    # Restart dnsmasq
    echo_date "重启 dnsmasq..." >> $LOG_FILE
    service restart_dnsmasq >/dev/null 2>&1
}
start_clash(){
	echo_date "启用$yamlname YAML配置" >> $LOG_FILE
	#/jffs/softcenter/bin/clash -d /jffs/softcenter/merlinclash/ -f $yamlpath >/dev/null 2>/tmp/clash_error.log &
	/jffs/softcenter/bin/clash -d /jffs/softcenter/merlinclash/ -f $yamlpath 1>/tmp/clash_run.log  2>&1 &
	#检查clash进程
	sleep 2s
	if [ ! -z "$(pidof clash)" -a ! -z "$(netstat -anp | grep clash)" -a ! -n "$(grep "Parse config error" /tmp/clash_run.log)" ] ; then
		echo_date "Clash 进程启动成功！(PID: $(pidof clash))"
		#复制文件到/tmp/upload/，且重命名为view.yaml
		rm -rf /tmp/upload/*.yaml
		#cp -rf $yamlpath /tmp/view.txt 
		ln -sf $yamlpath /tmp/view.txt 
		#20200706读取当前配置proxy-groups保存
		echo_date "创建节点指定相关文件" >> $LOG_FILE
		cp -rf $yamlpath /jffs/softcenter/merlinclash/list.yaml
		list=/jffs/softcenter/merlinclash/list.yaml
		yq r $list proxy-groups[*].name > /jffs/softcenter/merlinclash/proxygroups_tmp.txt
		#加上行号
		awk '$0=NR"."$0' /jffs/softcenter/merlinclash/proxygroups_tmp.txt > /jffs/softcenter/merlinclash/proxygroups.txt
		#20200706读取当前配置proxies保存
		yq r $list proxy-groups[*].name > /jffs/softcenter/merlinclash/proxies.txt
		yq r $list proxies[*].name > /jffs/softcenter/merlinclash/proxies.txt
		#往头部插入两个连接方式
		sed -i "1i\REJECT" /jffs/softcenter/merlinclash/proxies.txt
		sed -i "1i\DIRECT" /jffs/softcenter/merlinclash/proxies.txt
		rm -rf $list
		[ ! -L "/tmp/proxies.txt" ] && ln -s /jffs/softcenter/merlinclash/proxies.txt /tmp/proxies.txt
		[ ! -L "/tmp/proxygroups.txt" ] && ln -s /jffs/softcenter/merlinclash/proxygroups.txt /tmp/proxygroups.txt
		[ ! -L "/tmp/yamls.txt" ] && ln -s /jffs/softcenter/merlinclash/yaml_bak/yamls.txt /tmp/yamls.txt
		[ ! -L "/www/ext/yacd" ] && ln -sf /jffs/softcenter/merlinclash/dashboard/yacd /www/ext/
		[ ! -L "/www/ext/razord" ] && ln -sf /jffs/softcenter/merlinclash/dashboard/razord /www/ext/
	else
		echo_date "Clash 进程启动失败！请检查配置文件是否存在问题，即将退出"
		echo_date "失败原因："
		error1=$(cat /tmp/clash_run.log | grep -oE "Parse config error.*")
		if [ -n "$error1" ]; then
    		echo_date $error1 >> $LOG_FILE
		fi
		error2=$(cat /tmp/clash_run.log | grep -oE "clashconfig.sh.*")
		if [ -n "$error2" ]; then
    		echo_date $error2 >> $LOG_FILE
		fi
		close_in_five
	fi

	[ -f "/jffs/softcenter/merlinclash/clash_binary_history.txt" ] && ln -s /jffs/softcenter/merlinclash/clash_binary_history.txt /tmp/clash_binary_history.txt 
	
}

check_yaml(){
	#配合自定规则，此处修改为每次都从BAK恢复原版文件来操作-20200629
	#每次从/jffs/softcenter/merlinclash/yaml 复制一份上传的 上传文件名.yaml 使用
	echo_date "从yaml_bak恢复初始文件" >> $LOG_FILE
	cp -rf /jffs/softcenter/merlinclash/yaml_bak/$yamlname.yaml $yamlpath
	if [ -f "$yamlpath" ]; then
		echo_date "检查到Clash配置文件存在！选中的配置文件是【$yamlname】" >> $LOG_FILE
		#echo_date "将标准头部文件复制一份到/tmp/" >>"$LOG_FILE"
		#cp -rf /jffs/softcenter/merlinclash/yaml/head.yaml /tmp/head.yaml >/dev/null 2>&1 &
		#sleep 1s
		#不再重复处理 20200721+++++++++++++++++++++++++++++++++++
		#不再重复处理 20200721--------------------------------
	else
		echo_date "文件丢失，没有找到上传的配置文件！请先上传您的配置文件！" >> $LOG_FILE
		echo_date "...MerlinClash！退出中..." >> $LOG_FILE
		close_in_five
	fi
}
check_ss(){
	
	pid_ss=$(pidof ss-redir)
	pid_rss=$(pidof rss-redir)
	pid_v2ray=$(pidof v2ray)
	pid_trojan=$(pidof trojan)
	pid_trojango=$(pidof trojan-go)
	pid_koolgame=$(pidof koolgame)
	if [ -n "$pid_ss" ] || [ -n "$pid_v2ray" ] || [ -n "$pid_trojan" ] || [ -n "$pid_trojango" ] || [ -n "$pid_koolgame" ] || [ -n "$pid_rss" ]; then
    	echo_date "检测到【科学上网】插件启用中，请先关闭该插件，再运行MerlinClash！"
		echo_date "...MerlinClash！退出中..."
		close_in_five 	
    else
	    echo_date "没有检测到冲突插件，准备开启MerlinClash！"
	fi
}

get_lan_cidr() {
	local netmask=$(nvram get lan_netmask)
	local x=${netmask##*255.}
	set -- 0^^^128^192^224^240^248^252^254^ $(((${#netmask} - ${#x}) * 2)) ${x%%.*}
	x=${1%%$3*}
	suffix=$(($2 + (${#x} / 4)))
	#prefix=`nvram get lan_ipaddr | cut -d "." -f1,2,3`
	echo $lan_ipaddr/$suffix
}


check_dnsplan(){
	echo_date "当前dns方案是$merlinclash_dnsplan"
	#插入换行符免得出错
	sed -i '$a' $yamlpath
	case $merlinclash_dnsplan in
rh)
	#默认方案
	echo_date "采用配置文件的默认DNS方案Redir-Host" >> $LOG_FILE
	cat /jffs/softcenter/merlinclash/yaml/redirhost.yaml >> $yamlpath
	;;
#rh)
	#redir-host方案，将/jffs/softcenter/merlinclash/上传文件名.yaml 跟 redirhost.yaml 合并
#	echo_date "采用Redir-Host的DNS方案" >> $LOG_FILE

#	cat /jffs/softcenter/merlinclash/yaml/redirhost.yaml >> $yamlpath
#	;;
rhp)
	#redir-host-plus方案，将/jffs/softcenter/merlinclash/上传文件名.yaml 跟 rhplus.yaml 合并
	echo_date "采用Redir-Host-Plus的DNS方案" >> $LOG_FILE

	cat /jffs/softcenter/merlinclash/yaml/rhplus.yaml >> $yamlpath
	;;
fi)
	#fake-ip方案，将/jffs/softcenter/merlinclash/上传文件名.yaml 跟 fakeip.yaml 合并
	echo_date "采用Fake-ip的DNS方案" >> $LOG_FILE 

	cat /jffs/softcenter/merlinclash/yaml/fakeip.yaml >> $yamlpath
	;;
esac

	#20200623
	if [ "$merlinclash_enable" == "1" ] && [ "$merlinclash_ipv6switch" == "1" ];then
		echo_date "检测到开启ipv6，将为你设置dns.ipv6为true" >> $LOG_FILE
		
		#查找行数
		ipv6_line=$(cat $yamlpath | grep -n "ipv6:" | awk -F ":" '{print $1}')
		#删除行，再重写
		sed -i "$ipv6_line d" $yamlpath
		sed "$ipv6_line a \ \ ipv6: true" -i $yamlpath
	else
		echo_date "关闭clash或未开启ipv6，将为你设置dns.ipv6为false" >> $LOG_FILE
		
		ipv6_line=$(cat $yamlpath | grep -n "ipv6:" | awk -F ":" '{print $1}')
		#删除行，再重写
		sed -i "$ipv6_line d" $yamlpath
		sed "$ipv6_line a \ \ ipv6: false" -i $yamlpath
	fi

}
stop_config(){
	echo_date 触发脚本stop_config >> $LOG_FILE
	#ss_pre_stop
	# now stop first
	echo_date ======================= MERLIN CLASH ======================== >> $LOG_FILE
	echo_date
	echo_date --------------------------- 启动 ---------------------------- >> $LOG_FILE
	#stop_status 
	echo_date ---------------------- 结束相关进程-------------------------- >> $LOG_FILE
	if [ "$merlinclash_unblockmusic_enable" == "1" ]; then
		sh /jffs/softcenter/scripts/clash_unblockneteasemusic.sh stop
	fi
	restart_dnsmasq
	kill_process
	echo_date -------------------- 相关进程结束完毕 -----------------------  >> $LOG_FILE
	#echo_date --------------- 删除插件触发重启定时任务 -------------------
	#remove_ss_trigger_job
	#echo_date --------------------- 删除完毕 -----------------------------
	#echo_date -------------- 删除插件自动重启定时任务 --------------------
	#remove_ss_reboot_job
	#echo_date ---------------------- 删除完毕 ----------------------------
	# 删除ss相关的名单配置文件
	#restore_conf
	# restart dnsmasq when ss server is not ip or on router boot
	#umount_dnsmasq_now
	#restart_dnsmasq
	# 清除iptables规则和ipset...
	echo_date ----------------------清除iptables规则----------------------- >> $LOG_FILE
	flush_nat
}
check_unblockneteasemusic(){
	if [ "$merlinclash_enable" == "1" ]; then
		if [ ! -f "/jffs/softcenter/bin/UnblockNeteaseMusic" ];then
			dbus set merlinclash_unblockmusic_enable=0
			merlinclash_unblockmusic_enable=0
		elif [ "$(dbus get unblockmusic_enable)" == "1" ];then
			dbus set unblockmusic_enable=0
			sh /jffs/softcenter/scripts/unblockmusic_config.sh stop
		fi
		if [ "$merlinclash_unblockmusic_enable" == "1" ];then
			echo_date "检测到开启网易云解锁功能，开始处理" >> $LOG_FILE	
			[ ! -L "/www/ext/ca.crt" ] && ln -sf /jffs/softcenter/bin/Music/ca.crt /www/ext
			sh /jffs/softcenter/scripts/clash_unblockneteasemusic.sh restart
			sleep 1s
			#write_unblock
		else
			echo_date "网易云解锁未开启" >> $LOG_FILE
			sh /jffs/softcenter/scripts/clash_unblockneteasemusic.sh stop					
		fi
	fi
}
write_unblock(){
			ubm_process=$(pidof UnblockNeteaseMusic);
			if [ -n "$ubm_process" ]; then			
				#获取proxies跟rules行号
				proxy_line=$(sed -n -e '/^proxies:/=' $yamlpath)
				rules_line=$(sed -n -e '/^rules:/=' $yamlpath)
				#ubm="\ \ - {name: 网易云解锁WINDOWS/ANDORID, server: music.desperadoj.com, port: 30001, type: ss, cipher: aes-128-gcm, password: desperadoj.com_free_proxy_x80j}"
				ubmlocal="\ \ - {name: 网易云解锁-本地, server: 127.0.0.1, port: 5200, type: http}"
				#ubm2="\ \ - {name: 网易云解锁MAC/IOS, server: music.desperadoj.com, port: 30003, type: ss, cipher: aes-128-gcm, password: desperadoj.com_free_proxy_x80j}"
				#写入proxies
				echo_date "写入网易云解锁的proxy跟proxy-group" 	>> $LOG_FILE
				#sed "$proxy_line a$ubm2" -i $yamlpath
				#sed "$proxy_line a$ubm" -i $yamlpath
				sed "$proxy_line a$ubmlocal" -i $yamlpath
				#写入proxy-groups
				pg1="\ \ - name: Netease Music"
				pg2="\ \ \ \ type: select"
				pg3="\ \ \ \ proxies:"
				pg7="\ \ \ \ \ \ - 网易云解锁-本地"
				pg5="\ \ \ \ \ \ - DIRECT"
				sed "$rules_line a$pg1" -i $yamlpath
                
				let rules_line=$rules_line+1
				sed "$rules_line a$pg2" -i $yamlpath
               
				let rules_line=$rules_line+1
				sed "$rules_line a$pg3" -i $yamlpath
                
				let rules_line=$rules_line+1
				sed "$rules_line a$pg7" -i $yamlpath
                
				let rules_line=$rules_line+1
				sed "$rules_line a$pg5" -i $yamlpath
               
				#写入网易云的clash rule部分  格式:  - "DOMAIN-SUFFIX,acl4ssr,\U0001F3AF 全球直连"				
				echo_date 写入网易云的clash rule部分 >> $LOG_FILE
				rules_line=$(sed -n -e '/^rules:/=' $yamlpath)
                
				sed "$rules_line a \ \ -\ IP-CIDR,223.252.199.67/32,Netease Music" -i $yamlpath
				sed "$rules_line a \ \ -\ IP-CIDR,223.252.199.66/32,Netease Music" -i $yamlpath
				sed "$rules_line a \ \ -\ IP-CIDR,193.112.159.225/32,Netease Music" -i $yamlpath
				sed "$rules_line a \ \ -\ IP-CIDR,118.24.63.156/32,Netease Music" -i $yamlpath
				sed "$rules_line a \ \ -\ IP-CIDR,115.236.121.3/32,Netease Music" -i $yamlpath
				sed "$rules_line a \ \ -\ IP-CIDR,115.236.121.1/32,Netease Music" -i $yamlpath
				sed "$rules_line a \ \ -\ IP-CIDR,115.236.118.33/32,Netease Music" -i $yamlpath
				sed "$rules_line a \ \ -\ IP-CIDR,112.13.122.1/32,Netease Music" -i $yamlpath
				sed "$rules_line a \ \ -\ IP-CIDR,112.13.119.17/32,Netease Music" -i $yamlpath
				sed "$rules_line a \ \ -\ IP-CIDR,103.126.92.133/32,Netease Music" -i $yamlpath
				sed "$rules_line a \ \ -\ IP-CIDR,103.126.92.132/32,Netease Music" -i $yamlpath
				sed "$rules_line a \ \ -\ IP-CIDR,101.71.154.241/32,Netease Music" -i $yamlpath
				sed "$rules_line a \ \ -\ IP-CIDR,59.111.238.29/32,Netease Music" -i $yamlpath
				sed "$rules_line a \ \ -\ IP-CIDR,59.111.181.35/32,Netease Music" -i $yamlpath
				sed "$rules_line a \ \ -\ IP-CIDR,59.111.160.197/32,Netease Music" -i $yamlpath
				sed "$rules_line a \ \ -\ IP-CIDR,59.111.160.195/32,Netease Music" -i $yamlpath
				sed "$rules_line a \ \ -\ IP-CIDR,59.111.181.60/32,Netease Music" -i $yamlpath
				sed "$rules_line a \ \ -\ IP-CIDR,59.111.181.38/32,Netease Music" -i $yamlpath
				sed "$rules_line a \ \ -\ IP-CIDR,59.111.179.214/32,Netease Music" -i $yamlpath
				sed "$rules_line a \ \ -\ IP-CIDR,59.111.21.14/31,Netease Music" -i $yamlpath
				sed "$rules_line a \ \ -\ IP-CIDR,47.100.127.239/32,Netease Music" -i $yamlpath
				sed "$rules_line a \ \ -\ IP-CIDR,45.254.48.1/32,Netease Music" -i $yamlpath
				sed "$rules_line a \ \ -\ IP-CIDR,42.186.120.199/32,Netease Music" -i $yamlpath
				sed "$rules_line a \ \ -\ IP-CIDR,39.105.63.80/32,Netease Music" -i $yamlpath
				sed "$rules_line a \ \ -\ DOMAIN-SUFFIX,nstool.netease.com,Netease Music" -i $yamlpath
				sed "$rules_line a \ \ -\ DOMAIN-SUFFIX,hz.netease.com,Netease Music" -i $yamlpath
				sed "$rules_line a \ \ -\ DOMAIN-SUFFIX,mam.netease.com,Netease Music" -i $yamlpath
				sed "$rules_line a \ \ -\ DOMAIN-SUFFIX,interface3.music.163.com,Netease Music" -i $yamlpath
				sed "$rules_line a \ \ -\ DOMAIN-SUFFIX,interface.music.163.com,Netease Music" -i $yamlpath
				
				sed "$rules_line a \ \ -\ DOMAIN-SUFFIX,apm.music.163.com,Netease Music" -i $yamlpath
				sed "$rules_line a \ \ -\ DOMAIN-SUFFIX,apm3.music.163.com,Netease Music" -i $yamlpath 
				sed "$rules_line a \ \ -\ DOMAIN-SUFFIX,api.iplay.163.com,Netease Music" -i $yamlpath
				sed "$rules_line a \ \ -\ DOMAIN-SUFFIX,music.163.com,Netease Music" -i $yamlpath
				sed "$rules_line a \ \ -\ DOMAIN-SUFFIX,163yun.com,Netease Music" -i $yamlpath
				[ ! -L "/www/ext/ca.crt" ] && ln -sf /jffs/softcenter/bin/Music/ca.crt /www/ext
			else
				echo_date "网易云音乐解锁无法启动" >> $LOG_FILE
				dbus set $merlinclash_unblockmusic_enable="0";
	fi
}
auto_start() {
	echo_date "创建开机/iptable重启任务" >> $LOG_FILE
	[ ! -L "/jffs/softcenter/init.d/S99merlinclash.sh" ] && ln -sf /jffs/softcenter/merlinclash/clashconfig.sh /jffs/softcenter/init.d/S99merlinclash.sh
	[ ! -L "/jffs/softcenter/init.d/N99merlinclash.sh" ] && ln -sf /jffs/softcenter/merlinclash/clashconfig.sh /jffs/softcenter/init.d/N99merlinclash.sh
}

apply_mc() {
	# router is on boot
	WAN_ACTION=`ps|grep /jffs/scripts/wan-start|grep -v grep`
	mkdir -p /var/wwwext
	# now stop first
	echo_date ======================= MERLIN CLASH ======================== >> $LOG_FILE
	echo_date --------------------- 检查是否存冲突插件 ----------------------- >> $LOG_FILE
	check_ss
	echo_date ---------------------- 重启dnsmasq -------------------------- >> $LOG_FILE
	restart_dnsmasq
	echo_date ----------------------- 结束相关进程--------------------------- >> $LOG_FILE
	kill_process
	echo_date --------------------- 相关进程结束完毕 ------------------------ >> $LOG_FILE
	echo_date -------------------- 检查配置文件是否存在 --------------------- >> $LOG_FILE
	check_yaml
	echo_date ------------------------ 确认DNS方案 -------------------------- >> $LOG_FILE
	check_dnsplan
	echo_date -------------------- 自定义规则检查区 开始-------------------------- >> $LOG_FILE
	check_rule
	echo_date -------------------- 自定义规则检查区 结束-------------------------- >> $LOG_FILE

	# 清除iptables规则和ipset...
	echo_date --------------------- 清除iptables规则 ------------------------ >> $LOG_FILE
	flush_nat
	echo_date --------------------- 网易云功能检查区 开始------------------------ >> $LOG_FILE
	check_unblockneteasemusic
	echo_date --------------------- 网易云功能检查区 结束------------------------ >> $LOG_FILE
	start_bind
	echo_date ---------------------- 启动插件相关功能 ------------------------ >> $LOG_FILE
	start_clash && echo_date "start_clash" >> $LOG_FILE
	#echo_date ------------------------ 节点记忆检查区 开始---------------------- >> $LOG_FILE 
	#start_bind
	#echo_date ------------------------ 节点记忆检查区 结束---------------------- >> $LOG_FILE
	echo_date ------------------------ 恢复记忆节点 开始---------------------- >> $LOG_FILE 
	start_remark
	echo_date ------------------------ 恢复记忆节点 结束---------------------- >> $LOG_FILE
	load_nat
	#----------------------------------KCP进程--------------------------------
	echo_date ---------------------- KCP设置检查区 开始 ------------------------ >> $LOG_FILE
	start_kcp
	echo_date ---------------------- KCP设置检查区 结束 ------------------------ >> $LOG_FILE
	#----------------------------------应用节点记忆----------------------------
	restart_dnsmasq
	auto_start
	watchdog
	auto_setmark
    echo_date "" >> $LOG_FILE
	echo_date "             ++++++++++++++++++++++++++++++++++++++++" >> $LOG_FILE
    echo_date "             +        管理面板：$lan_ipaddr:9990     +" >> $LOG_FILE
    echo_date "             +       Http代理：$lan_ipaddr:3333     +"  >> $LOG_FILE
    echo_date "             +      Socks代理：$lan_ipaddr:23456    +" >> $LOG_FILE
    echo_date "             ++++++++++++++++++++++++++++++++++++++++" >> $LOG_FILE
	echo_date "" >> $LOG_FILE
    echo_date "                     恭喜！开启MerlinClash成功！" >> $LOG_FILE
	echo_date "" >> $LOG_FILE
	echo_date   "如果不能科学上网，请刷新设备dns缓存，或者等待几分钟再尝试" >> $LOG_FILE
	echo_date "" >> $LOG_FILE
	echo_date ==================== 【MERLIN CLASH】 启动完毕 ==================== >> $LOG_FILE
}
restart_mc_quickly(){
	echo_date ----------------------- 结束相关进程--------------------------- >> $LOG_FILE
	kill_clash
	echo_date ---------------------- 启动插件相关功能 ------------------------ >> $LOG_FILE
	start_clash && echo_date "start_clash" >> $LOG_FILE
	echo_date ------------------------ 恢复记忆节点 开始---------------------- >> $LOG_FILE 
	start_remark
	echo_date ------------------------ 恢复记忆节点 结束---------------------- >> $LOG_FILE
	restart_dnsmasq
	#===load nat end===
	# 创建开机/IPT重启任务！
	auto_start
	kill_setmark
	auto_setmark
    echo_date "" >> $LOG_FILE
	echo_date "             ++++++++++++++++++++++++++++++++++++++++" >> $LOG_FILE
    echo_date "             +        管理面板：$lan_ipaddr:9990     +" >> $LOG_FILE
    echo_date "             +       Http代理：$lan_ipaddr:3333     +"  >> $LOG_FILE
    echo_date "             +      Socks代理：$lan_ipaddr:23456    +" >> $LOG_FILE
    echo_date "             ++++++++++++++++++++++++++++++++++++++++" >> $LOG_FILE
	echo_date "" >> $LOG_FILE
    echo_date "                     恭喜！开启MerlinClash成功！" >> $LOG_FILE
	echo_date "" >> $LOG_FILE
	echo_date   "如果不能科学上网，请刷新设备dns缓存，或者等待几分钟再尝试" >> $LOG_FILE
	echo_date "" >> $LOG_FILE
	echo_date ==================== 【MERLIN CLASH】 启动完毕 ==================== >> $LOG_FILE
}


case $ACTION in
start)
	set_lock
	if [ "$merlinclash_enable" == "1" ]; then
		echo_date "[软件中心]: 开机启动MerlinClash插件！" >> $LOG_FILE
		apply_mc >>"$LOG_FILE"
	fi
	unset_lock
	;;
upload)
	move_config >>"$LOG_FILE"
	;;
select)
	select_config
	;;
stop)
	set_lock
	stop_config
	echo_date >> $LOG_FILE
	echo_date 你已经成功关闭Merlin Clash~ >> $LOG_FILE
	echo_date See you again! >> $LOG_FILE
	echo_date >> $LOG_FILE
	echo_date ======================= Merlin Clash ======================== >> $LOG_FILE
	unset_lock
	;;
restart)
	set_lock
	apply_mc
	echo_date >> $LOG_FILE
	echo_date "Across the Great Wall we can reach every corner in the world!" >> $LOG_FILE
	echo_date >> $LOG_FILE
	echo_date ======================= Merlin Clash ======================== >> $LOG_FILE
	unset_lock
	;;
quicklyrestart)
	set_lock
	restart_mc_quickly
	echo_date >> $LOG_FILE
	echo_date "Across the Great Wall we can reach every corner in the world!" >> $LOG_FILE
	echo_date >> $LOG_FILE
	echo_date ======================= Merlin Clash ======================== >> $LOG_FILE
	unset_lock
	;;
start_nat)
	#set_lock
	if [ "$merlinclash_enable" == "1" -a -n "$(pidof clash)" ]; then
		logger "[软件中心]: iptable发生变化，Merlin Clash nat重启！"
		echo_date "============= Merlin Clash iptable 重写开始=============" >> $LOG_FILE
		echo_date "[软件中心]: iptable发生变化，Merlin Clash nat重启！" >> $LOG_FILE
		if [ "$merlinclash_unblockmusic_enable" == "1" ]; then
			sh /jffs/softcenter/scripts/clash_unblockneteasemusic.sh restart
		fi
		apply_nat_rules3
		echo_date "============= Merlin Clash iptable 重写完成=============" >> $LOG_FILE
	fi
	#unset_lock
	;;
esac

