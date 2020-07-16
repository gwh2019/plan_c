#!/bin/sh

source /jffs/softcenter/scripts/base.sh
eval $(dbus export merlinclash_)
alias echo_date='echo 【$(date +%Y年%m月%d日\ %X)】:'
LOG_FILE=/tmp/merlinclash_log.txt

ROUTE_IP=$(nvram get lan_ipaddr)
ipt_n="iptables -t nat"
serverCrt="/jffs/softcenter/bin/Music/server.crt"
serverKey="/jffs/softcenter/bin/Music/server.key"

add_rule()
{
	echo_date 加载网易云音乐解锁nat规则... >> $LOG_FILE
	ipset -! -N music hash:ip
	ipset add music 39.105.63.80
	ipset add music 42.186.120.199
	ipset add music 45.254.48.1
	ipset add music 47.100.127.239
	ipset add music 59.111.21.14
	ipset add music 59.111.160.195
	ipset add music 59.111.160.197
	ipset add music 59.111.179.214
	ipset add music 59.111.181.60
	ipset add music 59.111.181.38
	ipset add music 59.111.181.35
	ipset add music 59.111.238.29
	ipset add music 101.71.154.241
	ipset add music 103.126.92.133
	ipset add music 103.126.92.132
	ipset add music 112.13.122.1
	ipset add music 112.13.119.17
	ipset add music 115.236.121.1
	ipset add music 115.236.118.33
	ipset add music 118.24.63.156
	ipset add music 193.112.159.225
	ipset add music 223.252.199.66
	ipset add music 223.252.199.67

	$ipt_n -N cloud_music
	$ipt_n -A cloud_music -d 0.0.0.0/8 -j RETURN
	$ipt_n -A cloud_music -d 10.0.0.0/8 -j RETURN
	$ipt_n -A cloud_music -d 127.0.0.0/8 -j RETURN
	$ipt_n -A cloud_music -d 169.254.0.0/16 -j RETURN
	$ipt_n -A cloud_music -d 172.16.0.0/12 -j RETURN
	$ipt_n -A cloud_music -d 192.168.0.0/16 -j RETURN
	$ipt_n -A cloud_music -d 224.0.0.0/4 -j RETURN
	$ipt_n -A cloud_music -d 240.0.0.0/4 -j RETURN
	$ipt_n -A cloud_music -p tcp --dport 80 -j REDIRECT --to-ports 5200
	$ipt_n -A cloud_music -p tcp --dport 443 -j REDIRECT --to-ports 5300
	$ipt_n -I PREROUTING -p tcp -m set --match-set music dst -j cloud_music
	iptables -I OUTPUT -d 223.252.199.10 -j DROP
}

del_rule(){
	echo_date 移除网易云音乐解锁nat规则... >> $LOG_FILE
	$ipt_n -D PREROUTING -p tcp -m set --match-set music dst -j cloud_music >/dev/null 2>&1 
	iptables -D OUTPUT -d 223.252.199.10 -j DROP >/dev/null 2>&1 
	$ipt_n -F cloud_music  >/dev/null 2>&1 
	$ipt_n -X cloud_music  >/dev/null 2>&1 	
	ipset flush music 2>/dev/null
	rm -f /tmp/etc/dnsmasq.user/dnsmasq-music.conf
	service restart_dnsmasq
}

set_firewall(){

	rm -f /tmp/etc/dnsmasq.user/dnsmasq-music.conf
	#echo "ipset=/music.163.com/music" >> /tmp/etc/dnsmasq.user/dnsmasq-music.conf #20200524
	echo "ipset=/.music.163.com/music" >> /tmp/etc/dnsmasq.user/dnsmasq-music.conf
	echo "ipset=/interface.music.163.com/music" >> /tmp/etc/dnsmasq.user/dnsmasq-music.conf
	echo "ipset=/interface3.music.163.com/music" >> /tmp/etc/dnsmasq.user/dnsmasq-music.conf
	echo "ipset=/apm.music.163.com/music" >> /tmp/etc/dnsmasq.user/dnsmasq-music.conf
	echo "ipset=/apm3.music.163.com/music" >> /tmp/etc/dnsmasq.user/dnsmasq-music.conf
	echo "ipset=/clientlog.music.163.com/music" >> /tmp/etc/dnsmasq.user/dnsmasq-music.conf
	echo "ipset=/clientlog3.music.163.com/music" >> /tmp/etc/dnsmasq.user/dnsmasq-music.conf
	service restart_dnsmasq >/dev/null 2>&1
	add_rule
}

start_unblockmusic(){
	echo_date "开启网易云音乐解锁功能" >> $LOG_FILE
	
	stop_unblockmusic
	if [ $merlinclash_unblockmusic_enable -eq 0 ]; then
		echo_date "解锁开关未开启，退出" >> $LOG_FILE
		exit 0
	fi
	if [ "$merlinclash_unblockmusic_bestquality" == "1" ]; then
		bestquality="-b"
	else
		bestquality=" "
	fi
	if [ "$merlinclash_unblockmusic_musicapptype" == "default" ]; then
		nohup /jffs/softcenter/bin/UnblockNeteaseMusic -p 5200 -sp 5300 -m 0 -c "${serverCrt}" -k "${serverKey}" -e "$bestquality" >/dev/null 2>&1 &
	else
		nohup /jffs/softcenter/bin/UnblockNeteaseMusic -p 5200 -sp 5300 -o "$merlinclash_unblockmusic_musicapptype" -m 0 -c "${serverCrt}" -k "${serverKey}" -e "$bestquality" >/dev/null 2>&1 &
	fi
	echo_date "设置相关iptable规则" >> $LOG_FILE
	mkdir -p /var/wwwext
	ln -sf /jffs/softcenter/bin/Music/ca.crt /www/ext
	set_firewall
}

stop_unblockmusic(){
	kill -9 $(busybox ps -w | grep UnblockNeteaseMusic | grep -v grep | awk '{print $1}') >/dev/null 2>&1 &
	del_rule
}

case $1 in
start)
	if [ "$merlinclash_unblockmusic_enable" == "1" ]; then
		echo_date "开启网易云音乐解锁" >> $LOG_FILE
		start_unblockmusic
	fi
	;;
restart)
	if [ "$merlinclash_unblockmusic_enable" == "1" ]; then
		echo_date "开启网易云音乐解锁" >> $LOG_FILE
		start_unblockmusic
	fi
	;;
stop)
	echo_date "关闭网易云音乐解锁" >> $LOG_FILE
	stop_unblockmusic
	;;
*)
	if [ "$merlinclash_unblockmusic_enable" == "1" ]; then
		start_unblockmusic
	else
		stop_unblockmusic
	fi
	;;
esac

