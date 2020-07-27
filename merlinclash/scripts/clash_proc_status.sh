#!/bin/sh

source /jffs/softcenter/scripts/base.sh
eval $(dbus export merlinclash_)
alias echo_date='echo 【$(date +%Y年%m月%d日\ %X)】:'

echo_version() {
	echo_date
	SOFVERSION=$(dbus get softcenter_module_merlinclash_version)
	
	if [ -f "/jffs/softcenter/bin/UnblockNeteaseMusic" ]; then
		merlinclash_UnblockNeteaseMusic_version="$(dbus get unblockmusic_bin_version)"
		dbus set merlinclash_UnblockNeteaseMusic_version="$merlinclash_UnblockNeteaseMusic_version"
	else
		merlinclash_UnblockNeteaseMusic_version="null"
	fi
	echo ① 程序版本（插件版本：$SOFVERSION）：
	echo -----------------------------------------------------------
	echo "程序			版本		备注"
	echo "clash			$merlinclash_clash_version"
	echo "UnblockNeteaseMusic	$merlinclash_UnblockNeteaseMusic_version"
	echo -----------------------------------------------------------
}
check_status() {
	#echo
	pid_clash=$(pidof clash)
	pid_watchdog=$(ps | grep clash_watchdog.sh | grep -v grep | awk '{print $1}')
	DMQ=$(pidof dnsmasq)
	kcp=$(pidof client_linux)
	ubm=$(pidof UnblockNeteaseMusic)
	echo_version
	echo
	echo ② 检测当前相关进程工作状态：（你正在使用clash）
	echo -----------------------------------------------------------
	echo "程序		状态	PID"
	[ -n "$pid_clash" ] && echo "clash		工作中	pid：$pid_clash" || echo "clash		未运行"
	[ -n "$pid_watchdog" ] && echo "看门狗		工作中	pid：$pid_watchdog" || echo "看门狗		未运行"
	[ -n "$DMQ" ] && echo "dnsmasq		工作中	pid：$DMQ" || echo "dnsmasq		未运行"
	[ -n "$kcp" ] && echo "kcp		工作中	pid：$kcp" || echo "kcp		未运行"
	[ -n "$ubm" ] && echo "网易云音乐解锁	工作中	pid：$ubm" || echo "网易云音乐解锁	未运行"
	echo -----------------------------------------------------------
	echo
	echo ③ 检测iptbales工作状态：
	echo ----------------------------------------------------- nat表 PREROUTING 链 --------------------------------------------------------
	iptables -nvL PREROUTING -t nat
	echo
	echo ----------------------------------------------------- nat表 OUTPUT 链 ------------------------------------------------------------
	iptables -nvL OUTPUT -t nat
	echo ----------------------------------------------------- nat表 merlinclash 链 --------------------------------------------------------
	iptables -nvL merlinclash -t nat
	echo ----------------------------------------------------- nat表 clash_dns 链 --------------------------------------------------------
	iptables -nvL clash_dns -t nat
	echo ----------------------------------------------------- nat表 cloud_music 链 --------------------------------------------------------
	iptables -nvL cloud_music -t nat
	echo ----------------------------------------------------- mangle表 merlinclash 链 --------------------------------------------------------
	iptables -nvL merlinclash -t mangle
	echo ----------------------------------------------------- mangle表 PREROUTING 链 --------------------------------------------------------
	iptables -nvL PREROUTING -t mangle
	echo -----------------------------------------------------------------------------------------------------------------------------------
	echo
}

if [ "$merlinclash_enable" == "1" ]; then
	check_status >/tmp/clash_proc_status.txt 2>&1
	#echo XU6J03M6 >> /tmp/ss_proc_status.txt
else
	echo 插件尚未启用！ >/tmp/clash_proc_status.txt 2>&1
fi

