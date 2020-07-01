#!/bin/sh

source /jffs/softcenter/scripts/base.sh
alias echo_date='echo 【$(TZ=UTC-8 date -R +%Y年%m月%d日\ %X)】:'
LOG_FILE=/tmp/merlinclash_log.txt
LOCK_FILE=/var/lock/merlinclash.lock
eval `dbus export merlinclash_`

yamlname=$merlinclash_yamlsel
yamlpath=/jffs/softcenter/merlinclash/$yamlname.yaml
chromecast_nu=""
lan_ipaddr=$(nvram get lan_ipaddr)
ssh_port=$(nvram get sshd_port)
dem=$(yq r $yamlpath dns.enhanced-mode)

uploadpath=/tmp/
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
	if [ -f /tmp/$merlinclash_uploadfilename ]; then
		#后台执行上传文件名.yaml处理工作，包括去注释，去空白行，去除dns以上头部，将标准头部文件复制一份到/tmp/ 跟tmp的标准头部文件合并，生成新的head.yaml，再将head.yaml复制到/jffs/softcenter/merlinclash/并命名为上传文件名.yaml
		#echo_date "后台执行yaml文件处理工作"
		#sh /jffs/softcenter/scripts/clash_yaml_sub.sh >/dev/null 2>&1 &
		echo_date "执行yaml文件处理工作"
		sh /jffs/softcenter/scripts/clash_yaml_sub.sh
	else
		echo_date "没找到yaml文件"
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
kill_process() {
	clash_process=$(pidof clash)
	pid_watchdog=$(ps | grep clash_watchdog.sh | grep -v grep | awk '{print $1}')
	kcp_process=$(pidof client_linux)
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
}
flush_nat() {
	proxy_port=23457
	#ssh_port=22
	dem2=$(yq r $yamlpath dns.enhanced-mode)
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
	
	
	#udp
	iptables -t mangle -D merlinclash -p udp -m set --match-set white_list dst -j ACCEPT
	iptables -t mangle -D merlinclash -p udp -j TPROXY --on-port 23457 --tproxy-mark 0x162
	#echo_date 删除ip route规则.
	ip route del local default dev lo table 0x162

	
	iptables -t nat -D merlinclash_dns -p udp -j REDIRECT --to-port 23453
	iptables -t nat -D OUTPUT -p udp --dport 53 -j merlinclash_dns
	iptables -t nat -D PREROUTING -p udp --dport 53 -j REDIRECT --to 23453
	iptables -t nat -D PREROUTING -p tcp -d 8.8.8.8 -j REDIRECT --to-port "$proxy_port"
	iptables -t nat -D PREROUTING -p tcp -d 8.8.4.4 -j REDIRECT --to-port "$proxy_port"
	iptables -t nat -D OUTPUT -p tcp -d 198.18.0.0/16 -j REDIRECT --to-port "$proxy_port"
	

    iptables -t nat -D PREROUTING -p tcp --dport 53 -d $(get_lan_cidr) -j merlinclash_dns
    iptables -t nat -D PREROUTING -p udp --dport 53 -d $(get_lan_cidr) -j merlinclash_dns
	iptables -t nat -D merlinclash_dns -p udp --dport 53 -d $(get_lan_cidr) -j DNAT --to-destination $lan_ipaddr:23453
    iptables -t nat -D merlinclash_dns -p tcp --dport 53 -d $(get_lan_cidr) -j DNAT --to-destination $lan_ipaddr:23453
	iptables -t nat -D PREROUTING -p udp -s $(get_lan_cidr) --dport 53 -j DNAT --to $lan_ipaddr >/dev/null 2>&1
	iptables -t nat -D PREROUTING -p udp --dport 53 -j REDIRECT --to-ports 23453
	iptables -t nat -D PREROUTING -p udp --dport 53 -d $lan_ipaddr -j DNAT --to-destination $lan_ipaddr:23453
	
	

	iptables -t mangle -D merlinclash_GAM -p udp -j TPROXY --on-port 3333 --tproxy-mark 0x07
	iptables -t mangle -D merlinclash -p udp -j merlinclash_GAM
	iptables -t mangle -D PREROUTING -p udp -j merlinclash
		
	iptables -t mangle -F merlinclash >/dev/null 2>&1 && iptables -t mangle -X merlinclash >/dev/null 2>&1
	iptables -t mangle -F merlinclash_GAM >/dev/null 2>&1 && iptables -t mangle -X merlinclash_GAM >/dev/null 2>&1
	
	iptables -t nat -F merlinclash_dns >/dev/null 2>&1 && iptables -t nat -X merlinclash_dns >/dev/null 2>&1
	iptables -t nat -F merlinclash >/dev/null 2>&1 && iptables -t nat -X merlinclash >/dev/null 2>&1
	ip rule del fwmark 0x07 table 310
	ip route del local 0.0.0.0/0 dev lo table 310
	echo_date 清除iptables规则完毕... >> $LOG_FILE
	
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
			echo_date "写入第$num1条自定规则到当前配置文件" >> $LOG_FILE
			yq w -i $yamlpath "rules[$num]" "$type","$content","$lianjie"
			let num++
		done
	else
		echo_date "没有自定规则" >> $LOG_FILE	
	fi
	dbus remove merlinclash_acl_type
	dbus remove merlinclash_acl_content
	dbus remove merlinclash_acl_lianjie
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
	dbus remove merlinclash_acl_type
	dbus remove merlinclash_acl_content
	dbus remove merlinclash_acl_lianjie	
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
		sleep 1
		nat_ready=$(iptables -t nat -L PREROUTING -v -n --line-numbers | grep -v PREROUTING | grep -v destination)
	done
	echo_date "加载nat规则!" >> $LOG_FILE
	sleep 2s
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
	echo_date 加载TPROXY模块，用于udp转发...
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
		echo "One or more modules are missing, only $((modules_loaded + 1)) are loaded. Can't start."
		close_in_five
	fi
}
apply_nat_rules3() {
	proxy_port=23457
	#ssh_port=22
	dem2=$(yq r $yamlpath dns.enhanced-mode)
	echo_date "开始写入iptable规则" >> $LOG_FILE
	
	if [ "$merlinclash_dnsplan" == "rh" ] || [ "$merlinclash_dnsplan" == "rhp" ] || [ $dem2 == 'redir-host' ];then
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

		iptables -t nat -A PREROUTING -p udp --dport 53 -j REDIRECT --to-ports 23453
		#iptables -t nat -A PREROUTING -p udp -s $(get_lan_cidr) --dport 53 -j DNAT --to $lan_ipaddr >/dev/null 2>&1
		
	fi
	#fake-ip rule
	if [ "$merlinclash_dnsplan" == "fi" ] || [ $dem2 == 'fake-ip' ];then
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
		iptables -t nat -A PREROUTING -j merlinclash
		# fake-ip rules
		iptables -t nat -A OUTPUT -p tcp -d 198.18.0.0/16 -j REDIRECT --to-ports $proxy_port

		#DNS
		iptables -t nat -A PREROUTING -p udp -m udp --dport 53 -j DNAT --to-destination $lan_ipaddr:23453			
	fi

#	if [ "$merlinclash_udpr" == "1" ]; then
#		echo_date "检测到开启udp转发，将创建相关iptable规则" >> $LOG_FILE
#		# udp
#		load_tproxy
#		ip rule add fwmark 0x07 table 310
#		ip route add local 0.0.0.0/0 dev lo table 310
#		iptables -t mangle -N merlinclash
#		iptables -t mangle -N merlinclash_GAM
#		iptables -t mangle -A merlinclash_GAM -p udp -j TPROXY --on-port 3333 --tproxy-mark 0x07
#		iptables -t mangle -A merlinclash -p udp -j merlinclash_GAM
#		iptables -t mangle -A PREROUTING -p udp -j merlinclash
#	else
#		echo_date "检测到udp转发未开启，进行下一步" >> $LOG_FILE

#	fi

	echo_date "iptable规则创建完成" >> $LOG_FILE
}
restart_dnsmasq() {
    # Restart dnsmasq
    echo_date "重启 dnsmasq..." >> $LOG_FILE
    service restart_dnsmasq restart >/dev/null 2>&1
}
start_clash(){
	echo_date "启用$yamlname YAML配置" >> $LOG_FILE
	/jffs/softcenter/bin/clash -d /jffs/softcenter/merlinclash/ -f $yamlpath >/dev/null 2>&1 &
}

check_yaml(){
	if [ -f $yamlpath ]; then
    echo_date "检查到Clash配置文件存在！选中的配置文件是【$yamlname】,Clash启动中.." >> $LOG_FILE

	# 确保启用 DNS
    yq w -i $yamlpath dns.enable "true"
	#sed -i 's/enable: '$de'/enable: true /g' /jffs/softcenter/merlinclash/上传文件名.yaml
	# 修改dns监听端口为23453
    yq w -i $yamlpath.yaml dns.listen "0.0.0.0:23453"
	#sed -i 's/listen: '$dl'/listen: 0.0.0.0:23453 /g' /jffs/softcenter/merlinclash/上传文件名.yaml

	#echo_date "判断是否存在 DNS 字段、DNS 是否启用、DNS 是否使用 redir-host / fake-ip 模式"
		if [ $(yq r $yamlpath dns.enable) == 'true' ] && ([[ $dem == 'fake-ip' || $dem == 'redir-host' ]]); then

			echo_date "Clash 配置文件DNS可用！"
		else
			echo_date "在 Clash 配置文件中没有找到 DNS 配置！后续操作将为你配置dns继续启动"
			#dbus set $merlinclash_dnsplan="de"
			#echo_date "...MerlinClash！退出中..."
			#close_in_five
		fi
	else
		echo_date "没有找到上传的配置文件！请先上传您的配置文件！"
		echo_date "...MerlinClash！退出中..."
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
	#配合自定规则，此处修改为每次都从BAK恢复原版文件来操作-20200621
	echo_date "当前dns方案是$merlinclash_dnsplan"
	#每次从/jffs/softcenter/merlinclash/yaml 复制一份上传的 上传文件名.yaml 使用
	cp -rf /jffs/softcenter/merlinclash/yaml_bak/$yamlname.yaml $yamlpath
	case $merlinclash_dnsplan in
de)
	#默认方案
	echo_date "采用配置文件的默认DNS方案";
	# 确保启用 DNS
    yq w -i $yamlpath dns.enable "true"
	# 修改dns监听端口为23453
    yq w -i $yamlpath dns.listen "0.0.0.0:23453"
	;;
rh)
	#redir-host方案，将/jffs/softcenter/merlinclash/上传文件名.yaml 跟 redirhost.yaml 合并
	echo_date "采用Redir-Host的DNS方案";
	#先删除原有dns内容，再合并
	echo_date "删除Clash配置文件中原有的DNS配置"
    yq d -i $yamlpath dns
	echo_date "将Redir-Host设置覆盖Clash配置文件..."
	yq m -x -i $yamlpath /jffs/softcenter/merlinclash/yaml/redirhost.yaml
	;;
rhp)
	#redir-host-plus方案，将/jffs/softcenter/merlinclash/上传文件名.yaml 跟 rhplus.yaml 合并
	echo_date "采用Redir-Host-Plus的DNS方案";
	#先删除原有dns内容，再合并
	echo_date "删除Clash配置文件中原有的DNS配置"
    yq d -i $yamlpath dns
	echo_date "将Redir-Host-Plus设置覆盖Clash配置文件..."
	yq m -x -i $yamlpath /jffs/softcenter/merlinclash/yaml/rhplus.yaml
	;;
fi)
	#fake-ip方案，将/jffs/softcenter/merlinclash/上传文件名.yaml 跟 fakeip.yaml 合并
	echo_date "采用Fake-ip的DNS方案";
	echo_date "删除Clash配置文件中原有的 DNS 配置"
    yq d -i $yamlpath dns
	echo_date "将Fake-ip设置覆盖Clash配置文件..."
	yq m -x -i $yamlpath /jffs/softcenter/merlinclash/yaml/fakeip.yaml
	;;
esac

	#20200623
	if [ "$merlinclash_enable" == "1" ] && [ "$merlinclash_ipv6switch" == "1" ];then
		echo_date "检测到开启ipv6，将为你设置dns.ipv6为true" >> $LOG_FILE
		yq w -i $yamlpath dns.ipv6 "true"
	else
		echo_date "关闭clash或未开启ipv6，将为你设置dns.ipv6为false" >> $LOG_FILE
		yq w -i $yamlpath dns.ipv6 "false"
	fi

}
stop_config(){
	echo_date 触发脚本stop_config
	#ss_pre_stop
	# now stop first
	echo_date ======================= MERLIN CLASH ========================
	echo_date
	echo_date --------------------------- 启动 ----------------------------
	#stop_status
	echo_date ---------------------- 结束相关进程--------------------------
	restart_dnsmasq
	kill_process
	echo_date -------------------- 相关进程结束完毕 -----------------------
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
	echo_date ----------------------清除iptables规则-----------------------
	flush_nat
}

auto_start() {
	echo_date "创建开机/iptable重启任务" >> $LOG_FILE
	[ ! -L "/jffs/softcenter/init.d/S100merlinclash.sh" ] && ln -sf /jffs/softcenter/merlinclash/clashconfig.sh /jffs/softcenter/init.d/S99merlinclash.sh
	[ ! -L "/jffs/softcenter/init.d/N100merlinclash.sh" ] && ln -sf /jffs/softcenter/merlinclash/clashconfig.sh /jffs/softcenter/init.d/N99merlinclash.sh
}

apply_mc() {
	# router is on boot
	WAN_ACTION=`ps|grep /jffs/scripts/wan-start|grep -v grep`
	echo_date 触发脚本apply_mc
	# now stop first
	echo_date ======================= MERLIN CLASH ========================
	echo_date --------------------- 检查是否存冲突插件 -----------------------
	check_ss
	echo_date ---------------------- 重启dnsmasq --------------------------
	restart_dnsmasq
	echo_date ----------------------- 结束相关进程---------------------------
	kill_process
	echo_date --------------------- 相关进程结束完毕 ------------------------
	echo_date -------------------- 检查配置文件是否存在 ---------------------
	check_yaml
	echo_date ------------------------ 确认DNS方案 --------------------------
	check_dnsplan
	echo_date -------------------- 检查自定义规则 --------------------------
	check_rule
	# 清除iptables规则和ipset...
	echo_date --------------------- 清除iptables规则 ------------------------
	flush_nat
	echo_date ---------------------- 启动插件相关功能 ------------------------
	start_clash && echo_date "start_clash" >> $LOG_FILE
	watchdog
	#===load nat start===
	load_nat
	#----------------------------------KCP进程--------------------------------
	start_kcp
	restart_dnsmasq
	#===load nat end===
	# 创建开机/IPT重启任务！
	auto_start
    echo_date ""
	echo_date "             ++++++++++++++++++++++++++++++++++++++++"
    echo_date "             +        管理面板：$lan_ipaddr:9990     +"
    echo_date "             +       Http代理：$lan_ipaddr:3333     +" 
    echo_date "             +      Socks代理：$lan_ipaddr:23456    +" 
    echo_date "             ++++++++++++++++++++++++++++++++++++++++"
	echo_date ""
    echo_date "                     恭喜！开启MerlinClash成功！"
	echo_date ""
	echo_date   如果不能科学上网，请刷新设备dns缓存，或者等待几分钟再尝试
	echo_date ""
	echo_date -------------- 【MERLIN CLASH】 启动完毕 ---------------------
}


case $ACTION in
start)
	set_lock
	if [ "$merlinclash_enable" == "1" ]; then
		logger "[软件中心]: 启动MerlinClash插件！"
		apply_mc >>"$LOG_FILE"
	else
		logger "[软件中心]: MerlinClash插件未开启，不启动！"
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
	echo_date
	echo_date 你已经成功关闭Merlin Clash~
	echo_date See you again!
	echo_date
	echo_date ======================= Merlin Clash ========================
	unset_lock
	;;
restart)
	set_lock
	apply_mc
	echo_date
	echo_date "Across the Great Wall we can reach every corner in the world!"
	echo_date
	echo_date ======================= Merlin Clash ========================
	unset_lock
	;;
start_nat)
	set_lock
	if [ "$merlinclash_enable" == "1" ]; then
		logger "[软件中心]: Merlin Clash nat重启！"
		apply_mc
	fi
	unset_lock
	;;
esac

