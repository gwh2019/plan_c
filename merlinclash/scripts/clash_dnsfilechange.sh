#!/bin/sh

source /jffs/softcenter/scripts/base.sh
eval $(dbus export merlinclash_)
alias echo_date='echo 【$(date +%Y年%m月%d日\ %X)】:'
dnsfile_path=/jffs/softcenter/merlinclash/yaml
rh=$dnsfile_path/redirhost.yaml
rhp=$dnsfile_path/rhplus.yaml
fi=$dnsfile_path/fakeip.yaml
rm -rf /tmp/dnsfile.log
nflag="0"
fflag="0"
#行数固定说明
#merlinclash_rh_nameserver1 第7行
#merlinclash_rh_nameserver2 第8行
#merlinclash_rh_nameserver3 第9行
#merlinclash_rh_fallback1   第11行
#merlinclash_rh_fallback2   第12行
#merlinclash_rh_fallback3   第13行
#cat $rh | grep -n $merlinclash_rh_nameserver1 | awk -F ":" '{print $1}' 获取指定字符串行数

	n1=$merlinclash_rh_nameserver1
	n2=$merlinclash_rh_nameserver2
	n3=$merlinclash_rh_nameserver3
	echo_date "测试" >> /tmp/upload/dnsfile.log
	if [ -n "$n1" ] && [ -n "$n2" ] && [ -n "$n3" ]; then
		nflag="1"
	elif  [ -z "$n1" ] && [ -n "$n2" ] && [ -n "$n3" ]; then
		nflag="2"
	elif  [ -z "$n1" ] && [ -z "$n2" ] && [ -n "$n3" ]; then
		nflag="3"
	elif  [ -n "$n1" ] && [ -z "$n2" ] && [ -n "$n3" ]; then
		nflag="4"
	elif  [ -n "$n1" ] && [ -z "$n2" ] && [ -z "$n3" ]; then
		nflag="5"
	elif  [ -n "$n1" ] && [ -n "$n2" ] && [ -z "$n3" ]; then
		nflag="6"
	elif  [ -z "$n1" ] && [ -z "$n2" ] && [ -z "$n3" ]; then
		nflag="7"
	elif  [ -z "$n1" ] && [ -n "$n2" ] && [ -z "$n3" ]; then
		nflag="8"
	else
		echo_date "啥都没有" >> /tmp/upload/dnsfile.log
	fi	
	echo_date $nflag >> /tmp/dnsfile.log
	echo_date $n1 >> /tmp/dnsfile.log
	echo_date $n2 >> /tmp/dnsfile.log
	echo_date $n3 >> /tmp/dnsfile.log
	case $nflag in
	1)	#三者均有数值，则进行对应替换
		yq w -i $rh dns.nameserver[0] $n1
		yq w -i $rh dns.nameserver[1] $n2
		yq w -i $rh dns.nameserver[2] $n3
		;;
	2)	#1无2有3有，则删除1，然后重写1.2的值
		yq d -i $rh dns.nameserver[0] 
		yq w -i $rh dns.nameserver[0] $n2
		yq w -i $rh dns.nameserver[1] $n3
		;;
	3)	#1无2无3有，删除1,2，3写入1
		yq d -i $rh dns.nameserver[0]
		yq d -i $rh dns.nameserver[1]
		yq w -i $rh dns.nameserver[0] $n3 
		;;
	4)	#1有2无3有，删除2,1重写，3写入2
		yq d -i $rh dns.nameserver[1]
		yq w -i $rh dns.nameserver[0] $n1
		yq w -i $rh dns.nameserver[1] $n3	
		;;
	5)	#1有2无3无，重写1，删除2,3
		yq w -i $rh dns.nameserver[0] $n1
		yq d -i $rh dns.nameserver[1]
		yq d -i $rh dns.nameserver[2]		
		;;
	6)	#1有2有3无，重写1,2，删除3
		yq w -i $rh dns.nameserver[0] $n1
		yq w -i $rh dns.nameserver[1] $n2
		yq d -i $rh dns.nameserver[2]
		;;
	7)	#123全无 不处理！
		echo_date "全空白，不处理" >> /tmp/dnsfile.log
		;;
	8)	#1无2有3无,删除3，删除1,2写入1
		yq d -i $rh dns.nameserver[2]
		yq d -i $rh dns.nameserver[0]
		yq w -i $rh dns.nameserver[0] $n1
	esac

	f1=$merlinclash_rh_fallback1
	f2=$merlinclash_rh_fallback2
	f3=$merlinclash_rh_fallback3
	if [ -n "$f1" ] && [ -n "$f2" ] && [ -n "$f3" ]; then
		fflag="1"
	elif  [ -z "$f1" ] && [ -n "$f2" ] && [ -n "$f3" ]; then
		fflag="2"
	elif  [ -z "$f1" ] && [ -z "$f2" ] && [ -n "$f3" ]; then
		fflag="3"
	elif  [ -n "$f1" ] && [ -z "$f2" ] && [ -n "$f3" ]; then
		fflag="4"
	elif  [ -n "$f1" ] && [ -z "$f2" ] && [ -z "$f3" ]; then
		fflag="5"
	elif  [ -n "$f1" ] && [ -n "$f2" ] && [ -z "$f3" ]; then
		fflag="6"
	elif  [ -z "$f1" ] && [ -z "$f2" ] && [ -z "$f3" ]; then
		fflag="7"
	elif  [ -z "$f1" ] && [ -n "$f2" ] && [ -z "$f3" ]; then
		fflag="8"
	else
		echo_date "啥都没有" >> /tmp/dnsfile.log
	fi

	case $fflag in
	1)	#三者均有数值，则进行对应替换
		yq w -i $rh dns.fallback[0] $f1
		yq w -i $rh dns.fallback[1] $f2
		yq w -i $rh dns.fallback[2] $f3
		;;
	2)	#1无2有3有，则删除1，然后重写1.2的值
		yq d -i $rh dns.fallback[0] 
		yq w -i $rh dns.fallback[0] $f2
		yq w -i $rh dns.fallback[1] $f3
		;;
	3)	#1无2无3有，删除1,2，3写入1
		yq d -i $rh dns.fallback[0]
		yq d -i $rh dns.fallback[1]
		yq w -i $rh dns.fallback[0] $f3 
		;;
	4)	#1有2无3有，删除2,1重写，3写入2
		yq d -i $rh dns.fallback[1]
		yq w -i $rh dns.fallback[0] $f1
		yq w -i $rh dns.fallback[1] $f3	
		;;
	5)	#1有2无3无，重写1，删除2,3
		yq w -i $rh dns.fallback[0] $f1
		yq d -i $rh dns.fallback[1]
		yq d -i $rh dns.fallback[2]		
		;;
	6)	#1有2有3无，重写1,2，删除3
		yq w -i $rh dns.fallback[0] $f1
		yq w -i $rh dns.fallback[1] $f2
		yq d -i $rh dns.fallback[2]
		;;
	7)	#123全无 不处理！
		echo_date "全空白，不处理" >> /tmp/dnsfile.log
		;;
	8)	#1无2有3无,删除3，删除1,2写入1
		yq d -i $rh dns.fallback[2]
		yq d -i $rh dns.fallback[0]
		yq w -i $rh dns.fallback[0] $f1
	esac

###################################################################
	n1=$merlinclash_rhp_nameserver1
	n2=$merlinclash_rhp_nameserver2
	n3=$merlinclash_rhp_nameserver3
	echo_date "测试" >> /tmp/dnsfile.log
	if [ -n "$n1" ] && [ -n "$n2" ] && [ -n "$n3" ]; then
		nflag="1"
	elif  [ -z "$n1" ] && [ -n "$n2" ] && [ -n "$n3" ]; then
		nflag="2"
	elif  [ -z "$n1" ] && [ -z "$n2" ] && [ -n "$n3" ]; then
		nflag="3"
	elif  [ -n "$n1" ] && [ -z "$n2" ] && [ -n "$n3" ]; then
		nflag="4"
	elif  [ -n "$n1" ] && [ -z "$n2" ] && [ -z "$n3" ]; then
		nflag="5"
	elif  [ -n "$n1" ] && [ -n "$n2" ] && [ -z "$n3" ]; then
		nflag="6"
	elif  [ -z "$n1" ] && [ -z "$n2" ] && [ -z "$n3" ]; then
		nflag="7"
	elif  [ -z "$n1" ] && [ -n "$n2" ] && [ -z "$n3" ]; then
		nflag="8"
	else
		echo_date "啥都没有" >> /tmp/dnsfile.log
	fi	
	echo_date $nflag >> /tmp/dnsfile.log
	echo_date $n1 >> /tmp/dnsfile.log
	echo_date $n2 >> /tmp/dnsfile.log
	echo_date $n3 >> /tmp/dnsfile.log
	case $nflag in
	1)	#三者均有数值，则进行对应替换
		yq w -i $rhp dns.nameserver[0] $n1
		yq w -i $rhp dns.nameserver[1] $n2
		yq w -i $rhp dns.nameserver[2] $n3
		;;
	2)	#1无2有3有，则删除1，然后重写1.2的值
		yq d -i $rhp dns.nameserver[0] 
		yq w -i $rhp dns.nameserver[0] $n2
		yq w -i $rhp dns.nameserver[1] $n3
		;;
	3)	#1无2无3有，删除1,2，3写入1
		yq d -i $rhp dns.nameserver[0]
		yq d -i $rhp dns.nameserver[1]
		yq w -i $rhp dns.nameserver[0] $n3 
		;;
	4)	#1有2无3有，删除2,1重写，3写入2
		yq d -i $rhp dns.nameserver[1]
		yq w -i $rhp dns.nameserver[0] $n1
		yq w -i $rhp dns.nameserver[1] $n3	
		;;
	5)	#1有2无3无，重写1，删除2,3
		yq w -i $rhp dns.nameserver[0] $n1
		yq d -i $rhp dns.nameserver[1]
		yq d -i $rhp dns.nameserver[2]		
		;;
	6)	#1有2有3无，重写1,2，删除3
		yq w -i $rhp dns.nameserver[0] $n1
		yq w -i $rhp dns.nameserver[1] $n2
		yq d -i $rhp dns.nameserver[2]
		;;
	7)	#123全无 不处理！
		echo_date "全空白，不处理" >> /tmp/dnsfile.log
		;;
	8)	#1无2有3无,删除3，删除1,2写入1
		yq d -i $rhp dns.nameserver[2]
		yq d -i $rhp dns.nameserver[0]
		yq w -i $rhp dns.nameserver[0] $n1
	esac

	f1=$merlinclash_rhp_fallback1
	f2=$merlinclash_rhp_fallback2
	f3=$merlinclash_rhp_fallback3
	if [ -n "$f1" ] && [ -n "$f2" ] && [ -n "$f3" ]; then
		fflag="1"
	elif  [ -z "$f1" ] && [ -n "$f2" ] && [ -n "$f3" ]; then
		fflag="2"
	elif  [ -z "$f1" ] && [ -z "$f2" ] && [ -n "$f3" ]; then
		fflag="3"
	elif  [ -n "$f1" ] && [ -z "$f2" ] && [ -n "$f3" ]; then
		fflag="4"
	elif  [ -n "$f1" ] && [ -z "$f2" ] && [ -z "$f3" ]; then
		fflag="5"
	elif  [ -n "$f1" ] && [ -n "$f2" ] && [ -z "$f3" ]; then
		fflag="6"
	elif  [ -z "$f1" ] && [ -z "$f2" ] && [ -z "$f3" ]; then
		fflag="7"
	elif  [ -z "$f1" ] && [ -n "$f2" ] && [ -z "$f3" ]; then
		fflag="8"
	else
		echo_date "啥都没有" >> /tmp/dnsfile.log
	fi

	case $fflag in
	1)	#三者均有数值，则进行对应替换
		yq w -i $rhp dns.fallback[0] $f1
		yq w -i $rhp dns.fallback[1] $f2
		yq w -i $rhp dns.fallback[2] $f3
		;;
	2)	#1无2有3有，则删除1，然后重写1.2的值
		yq d -i $rhp dns.fallback[0] 
		yq w -i $rhp dns.fallback[0] $f2
		yq w -i $rhp dns.fallback[1] $f3
		;;
	3)	#1无2无3有，删除1,2，3写入1
		yq d -i $rhp dns.fallback[0]
		yq d -i $rhp dns.fallback[1]
		yq w -i $rhp dns.fallback[0] $f3 
		;;
	4)	#1有2无3有，删除2,1重写，3写入2
		yq d -i $rhp dns.fallback[1]
		yq w -i $rhp dns.fallback[0] $f1
		yq w -i $rhp dns.fallback[1] $f3	
		;;
	5)	#1有2无3无，重写1，删除2,3
		yq w -i $rhp dns.fallback[0] $f1
		yq d -i $rhp dns.fallback[1]
		yq d -i $rhp dns.fallback[2]		
		;;
	6)	#1有2有3无，重写1,2，删除3
		yq w -i $rhp dns.fallback[0] $f1
		yq w -i $rhp dns.fallback[1] $f2
		yq d -i $rhp dns.fallback[2]
		;;
	7)	#123全无 不处理！
		echo_date "全空白，不处理" >> /tmp/dnsfile.log
		;;
	8)	#1无2有3无,删除3，删除1,2写入1
		yq d -i $rhp dns.fallback[2]
		yq d -i $rhp dns.fallback[0]
		yq w -i $rhp dns.fallback[0] $f1
	esac

###################################################################
	n1=$merlinclash_fi_nameserver1
	n2=$merlinclash_fi_nameserver2
	n3=$merlinclash_fi_nameserver3
	echo_date "测试" >> /tmp/dnsfile.log
	if [ -n "$n1" ] && [ -n "$n2" ] && [ -n "$n3" ]; then
		nflag="1"
	elif  [ -z "$n1" ] && [ -n "$n2" ] && [ -n "$n3" ]; then
		nflag="2"
	elif  [ -z "$n1" ] && [ -z "$n2" ] && [ -n "$n3" ]; then
		nflag="3"
	elif  [ -n "$n1" ] && [ -z "$n2" ] && [ -n "$n3" ]; then
		nflag="4"
	elif  [ -n "$n1" ] && [ -z "$n2" ] && [ -z "$n3" ]; then
		nflag="5"
	elif  [ -n "$n1" ] && [ -n "$n2" ] && [ -z "$n3" ]; then
		nflag="6"
	elif  [ -z "$n1" ] && [ -z "$n2" ] && [ -z "$n3" ]; then
		nflag="7"
	elif  [ -z "$n1" ] && [ -n "$n2" ] && [ -z "$n3" ]; then
		nflag="8"
	else
		echo_date "啥都没有" >> /tmp/dnsfile.log
	fi	
	echo_date $nflag >> /tmp/dnsfile.log
	echo_date $n1 >> /tmp/dnsfile.log
	echo_date $n2 >> /tmp/dnsfile.log
	echo_date $n3 >> /tmp/dnsfile.log
	case $nflag in
	1)	#三者均有数值，则进行对应替换
		yq w -i $fi dns.nameserver[0] $n1
		yq w -i $fi dns.nameserver[1] $n2
		yq w -i $fi dns.nameserver[2] $n3
		;;
	2)	#1无2有3有，则删除1，然后重写1.2的值
		yq d -i $fi dns.nameserver[0] 
		yq w -i $fi dns.nameserver[0] $n2
		yq w -i $fi dns.nameserver[1] $n3
		;;
	3)	#1无2无3有，删除1,2，3写入1
		yq d -i $fi dns.nameserver[0]
		yq d -i $fi dns.nameserver[1]
		yq w -i $fi dns.nameserver[0] $n3 
		;;
	4)	#1有2无3有，删除2,1重写，3写入2
		yq d -i $fi dns.nameserver[1]
		yq w -i $fi dns.nameserver[0] $n1
		yq w -i $fi dns.nameserver[1] $n3	
		;;
	5)	#1有2无3无，重写1，删除2,3
		yq w -i $fi dns.nameserver[0] $n1
		yq d -i $fi dns.nameserver[1]
		yq d -i $fi dns.nameserver[2]		
		;;
	6)	#1有2有3无，重写1,2，删除3
		yq w -i $fi dns.nameserver[0] $n1
		yq w -i $fi dns.nameserver[1] $n2
		yq d -i $fi dns.nameserver[2]
		;;
	7)	#123全无 不处理！
		echo_date "全空白，不处理" >> /tmp/dnsfile.log
		;;
	8)	#1无2有3无,删除3，删除1,2写入1
		yq d -i $fi dns.nameserver[2]
		yq d -i $fi dns.nameserver[0]
		yq w -i $fi dns.nameserver[0] $n1
	esac

	f1=$merlinclash_fi_fallback1
	f2=$merlinclash_fi_fallback2
	f3=$merlinclash_fi_fallback3
	if [ -n "$f1" ] && [ -n "$f2" ] && [ -n "$f3" ]; then
		fflag="1"
	elif  [ -z "$f1" ] && [ -n "$f2" ] && [ -n "$f3" ]; then
		fflag="2"
	elif  [ -z "$f1" ] && [ -z "$f2" ] && [ -n "$f3" ]; then
		fflag="3"
	elif  [ -n "$f1" ] && [ -z "$f2" ] && [ -n "$f3" ]; then
		fflag="4"
	elif  [ -n "$f1" ] && [ -z "$f2" ] && [ -z "$f3" ]; then
		fflag="5"
	elif  [ -n "$f1" ] && [ -n "$f2" ] && [ -z "$f3" ]; then
		fflag="6"
	elif  [ -z "$f1" ] && [ -z "$f2" ] && [ -z "$f3" ]; then
		fflag="7"
	elif  [ -z "$f1" ] && [ -n "$f2" ] && [ -z "$f3" ]; then
		fflag="8"
	else
		echo_date "啥都没有" >> /tmp/dnsfile.log
	fi

	case $fflag in
	1)	#三者均有数值，则进行对应替换
		yq w -i $fi dns.fallback[0] $f1
		yq w -i $fi dns.fallback[1] $f2
		yq w -i $fi dns.fallback[2] $f3
		;;
	2)	#1无2有3有，则删除1，然后重写1.2的值
		yq d -i $fi dns.fallback[0] 
		yq w -i $fi dns.fallback[0] $f2
		yq w -i $fi dns.fallback[1] $f3
		;;
	3)	#1无2无3有，删除1,2，3写入1
		yq d -i $fi dns.fallback[0]
		yq d -i $fi dns.fallback[1]
		yq w -i $fi dns.fallback[0] $f3 
		;;
	4)	#1有2无3有，删除2,1重写，3写入2
		yq d -i $fi dns.fallback[1]
		yq w -i $fi dns.fallback[0] $f1
		yq w -i $fi dns.fallback[1] $f3	
		;;
	5)	#1有2无3无，重写1，删除2,3
		yq w -i $fi dns.fallback[0] $f1
		yq d -i $fi dns.fallback[1]
		yq d -i $fi dns.fallback[2]		
		;;
	6)	#1有2有3无，重写1,2，删除3
		yq w -i $fi dns.fallback[0] $f1
		yq w -i $fi dns.fallback[1] $f2
		yq d -i $fi dns.fallback[2]
		;;
	7)	#123全无 不处理！
		echo_date "全空白，不处理" >> /tmp/dnsfile.log
		;;
	8)	#1无2有3无,删除3，删除1,2写入1
		yq d -i $fi dns.fallback[2]
		yq d -i $fi dns.fallback[0]
		yq w -i $fi dns.fallback[0] $f1
	esac

#http_response "success"

