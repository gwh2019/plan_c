#!/bin/sh

source /jffs/softcenter/scripts/base.sh
eval $(dbus export merlinclash_)
alias echo_date='echo 【$(date +%Y年%m月%d日\ %X)】:'
dnsfile_path=/jffs/softcenter/merlinclash/yaml
rh=$dnsfile_path/redirhost.yaml
rhp=$dnsfile_path/rhplus.yaml
fi=$dnsfile_path/fakeip.yaml
rm -rf /tmp/dnsfile.log
echo_date $merlinclash_rh_nameserver1 >> /tmp/dnsfile.log
echo_date $merlinclash_rh_nameserver2 >> /tmp/dnsfile.log
echo_date $merlinclash_rh_nameserver3 >> /tmp/dnsfile.log
	
	if [ "$merlinclash_rh_nameserver1" == "" ]; then
		yq d -i $rh dns.nameserver[0] 
	fi
	rhname1=$(echo $merlinclash_rh_nameserver1 | grep ^[a-zA-Z1-9] )
	if [ -n "$rhname1" ]; then
		yq w -i $rh dns.nameserver[0] $merlinclash_rh_nameserver1	
	fi

	if [ "$merlinclash_rh_nameserver2" == "" ]; then
		yq d -i $rh dns.nameserver[1] 
	fi
	rhname2=$(echo $merlinclash_rh_nameserver2 | grep ^[a-zA-Z1-9] )
	if [ -n "$rhname2" ]; then
		yq w -i $rh dns.nameserver[1] $merlinclash_rh_nameserver2	
	fi

	if [ "$merlinclash_rh_nameserver3" == "" ]; then
		yq d -i $rh dns.nameserver[2] 
	fi
	rhname3=$(echo $merlinclash_rh_nameserver3 | grep ^[a-zA-Z1-9] )
	echo_date $rhname3 >> /tmp/dnsfile.log
	if [ -n "$rhname3" ]; then
		echo_date "写入" >> /tmp/dnsfile.log
		yq w -i $rh dns.nameserver[1] $merlinclash_rh_nameserver3	
	fi

	echo_date "fb1=$merlinclash_rh_fallback1" >> /tmp/dnsfile.log
	if [ "$merlinclash_rh_fallback1" == "" ]; then
		echo_date "fb1为空，删除fb1" >> /tmp/dnsfile.log
		yq d -i $rh dns.fallback[0] 
	fi
	rhfallback1=$(echo $merlinclash_rh_fallback1 | grep ^[a-zA-Z1-9] )
	if [ -n "$rhfallback1" ]; then
		echo_date "写入fb1" >> /tmp/dnsfile.log
		yq w -i $rh dns.fallback[0] $merlinclash_rh_fallback1	
	fi

	if [ "$merlinclash_rh_fallback2" == "" ]; then
		yq d -i $rh dns.fallback[1] 
	fi
	rhfallback2=$(echo $merlinclash_rh_fallback2 | grep ^[a-zA-Z1-9] )
	if [ -n "$rhfallback2" ]; then
		yq w -i $rh dns.fallback[1] $merlinclash_rh_fallback2	
	fi

	if [ "$merlinclash_rh_fallback3" == "" ]; then
		yq d -i $rh dns.fallback[2] 
	fi
	rhfallback3=$(echo $merlinclash_rh_fallback3 | grep ^[a-zA-Z1-9] )
	if [ -n "$rhfallback3" ]; then
		yq w -i $rh dns.fallback[2] $merlinclash_rh_fallback3	
	fi
	
	rhfb=$(yq r $rh dns.fallback)
	if [ "$rhfb" == "[]" ]; then
		yq d -i $rh dns.fallback
	fi	
###################################################################
	if [ "$merlinclash_rhp_nameserver1" == "" ]; then
		yq d -i $rhp dns.nameserver[0] 
	fi
	rhpname1=$(echo $merlinclash_rhp_nameserver1 | grep ^[a-zA-Z1-9] )
	if [ -n "$rhpname1" ]; then
		yq w -i $rhp dns.nameserver[0] $merlinclash_rhp_nameserver1	
	fi

	if [ "$merlinclash_rhp_nameserver2" == "" ]; then
		yq d -i $rhp dns.nameserver[1] 
	fi
	rhpname2=$(echo $merlinclash_rhp_nameserver2 | grep ^[a-zA-Z1-9] )
	if [ -n "$rhpname2" ]; then
		yq w -i $rhp dns.nameserver[1] $merlinclash_rhp_nameserver2	
	fi

	if [ "$merlinclash_rhp_nameserver3" == "" ]; then
		yq d -i $rhp dns.nameserver[2] 
	fi
	rhpname3=$(echo $merlinclash_rhp_nameserver3 | grep ^[a-zA-Z1-9] )
	if [ -n "$rhpname3" ]; then
		yq w -i $rhp dns.nameserver[2] $merlinclash_rhp_nameserver3	
	fi

	if [ "$merlinclash_rhp_fallback1" == "" ]; then
		yq d -i $rhp dns.fallback[0] 
	fi
	rhpfallback1=$(echo $merlinclash_rhp_fallback1 | grep ^[a-zA-Z1-9] )
	if [ -n "$rhpfallback1" ]; then
		yq w -i $rhp dns.fallback[0] $merlinclash_rhp_fallback1	
	fi

	if [ "$merlinclash_rhp_fallback2" == "" ]; then
		yq d -i $rhp dns.fallback[1] 
	fi
	rhpfallback2=$(echo $merlinclash_rhp_fallback2 | grep ^[a-zA-Z1-9] )
	if [ -n "$rhpfallback2" ]; then
		yq w -i $rhp dns.fallback[1] $merlinclash_rhp_fallback2	
	fi

	if [ "$merlinclash_rhp_fallback3" == "" ]; then
		yq d -i $rhp dns.fallback[2] 
	fi
	rhpfallback3=$(echo $merlinclash_rhp_fallback3 | grep ^[a-zA-Z1-9] )
	if [ -n "$rhpfallback3" ]; then
		yq w -i $rhp dns.fallback[2] $merlinclash_rhp_fallback3	
	fi

	rhpfb=$(yq r $rhp dns.fallback)
	if [ "$rhpfb" == "[]" ]; then
		yq d -i $rhp dns.fallback
	fi	

###################################################################
	if [ "$merlinclash_fi_nameserver1" == "" ]; then
		yq d -i $fi dns.nameserver[0] 
	fi
	finame1=$(echo $merlinclash_fi_nameserver1 | grep ^[a-zA-Z1-9] )
	if [ -n "$finame1" ]; then
		yq w -i $fi dns.nameserver[0] $merlinclash_fi_nameserver1	
	fi

	if [ "$merlinclash_fi_nameserver2" == "" ]; then
		yq d -i $fi dns.nameserver[1] 
	fi
	finame2=$(echo $merlinclash_fi_nameserver2 | grep ^[a-zA-Z1-9] )
	if [ -n "$finame2" ]; then
		yq w -i $fi dns.nameserver[1] $merlinclash_fi_nameserver2	
	fi

	if [ "$merlinclash_fi_nameserver3" == "" ]; then
		yq d -i $fi dns.nameserver[2] 
	fi
	finame3=$(echo $merlinclash_fi_nameserver3 | grep ^[a-zA-Z1-9] )
	if [ -n "$finame3" ]; then
		yq w -i $fi dns.nameserver[2] $merlinclash_fi_nameserver3	
	fi

	if [ "$merlinclash_fi_fallback1" == "" ]; then
		yq d -i $fi dns.fallback[0] 
	fi
	fifallback1=$(echo $merlinclash_fi_fallback1 | grep ^[a-zA-Z1-9] )
	if [ -n "$fifallback1" ]; then
		yq w -i $fi dns.fallback[0] $merlinclash_fi_fallback1	
	fi

	if [ "$merlinclash_fi_fallback2" == "" ]; then
		yq d -i $fi dns.fallback[1] 
	fi
	fifallback2=$(echo $merlinclash_fi_fallback2 | grep ^[a-zA-Z1-9] )
	if [ -n "$fifallback2" ]; then
		yq w -i $fi dns.fallback[1] $merlinclash_fi_fallback2	
	fi

	if [ "$merlinclash_fi_fallback3" == "" ]; then
		yq d -i $fi dns.fallback[2] 
	fi
	fifallback3=$(echo $merlinclash_fi_fallback3 | grep ^[a-zA-Z1-9] )
	if [ -n "$fifallback3" ]; then
		yq w -i $fi dns.fallback[2] $merlinclash_fi_fallback3	
	fi

	fifb=$(yq r $fi dns.fallback)
	if [ "$fifb" == "[]" ]; then
		yq d -i $fi dns.fallback
	fi	


http_response "success"



