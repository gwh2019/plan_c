#!/bin/sh

source /jffs/softcenter/scripts/base.sh
eval $(dbus export merlinclash_)
alias echo_date='echo 【$(date +%Y年%m月%d日\ %X)】:'

check_status() {
	#echo
	pid_clash=$(pidof clash)
	pid_watchdog=$(ps | grep clash_watchdog.sh | grep -v grep | awk '{print $1}')
	DMQ=$(pidof dnsmasq)
	kcp=$(pidof client_linux)
	#echo_version
	echo
	echo ① 检测当前相关进程工作状态：（你正在使用clash）
	echo -----------------------------------------------------------
	echo "程序		状态	PID"
	[ -n "$pid_clash" ] && echo "clash		工作中	pid：$pid_clash" || echo "clash		未运行"
	[ -n "$pid_watchdog" ] && echo "看门狗		工作中	pid：$pid_watchdog" || echo "看门狗		未运行"
	[ -n "$DMQ" ] && echo "dnsmasq		工作中	pid：$DMQ" || echo "dnsmasq		未运行"
	[ -n "$kcp" ] && echo "kcp		工作中	pid：$kcp" || echo "kcp		未运行"
	echo -----------------------------------------------------------
	echo
	echo ② 检测iptbales工作状态：
	echo ----------------------------------------------------- nat表 PREROUTING 链 --------------------------------------------------------
	iptables -nvL PREROUTING -t nat
	echo
	echo ----------------------------------------------------- nat表 OUTPUT 链 ------------------------------------------------------------
	iptables -nvL OUTPUT -t nat
	echo
	echo ----------------------------------------------------- nat表 merlinclash 链 --------------------------------------------------------
	iptables -nvL merlinclash -t nat
	echo ----------------------------------------------------- nat表 merlinclash_dns 链 --------------------------------------------------------
	iptables -nvL merlinclash_dns -t nat
	echo ----------------------------------------------------- mangle表 merlinclash 链 --------------------------------------------------------
	iptables -nvL merlinclash -t mangle
	echo ----------------------------------------------------- mangle表 merlinclash_GAM 链 --------------------------------------------------------
	iptables -nvL merlinclash_GAM -t mangle
	echo -----------------------------------------------------------------------------------------------------------------------------------
	echo
}

if [ "$merlinclash_enable" == "1" ]; then
	check_status >/tmp/clash_proc_status.txt 2>&1
	#echo XU6J03M6 >> /tmp/upload/ss_proc_status.txt
else
	echo 插件尚未启用！ >/tmp/clash_proc_status.txt 2>&1
fi

