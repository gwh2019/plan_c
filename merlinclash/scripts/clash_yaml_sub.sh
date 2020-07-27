#!/bin/sh

source /jffs/softcenter/scripts/base.sh
eval $(dbus export merlinclash_)
alias echo_date='echo 【$(date +%Y年%m月%d日\ %X)】:'
LOG_FILE=/tmp/merlinclash_log.txt
lan_ip=$(nvram get lan_ipaddr)
uploadpath=/tmp
fp=/jffs/softcenter/merlinclash/yaml_bak

name=$(find $uploadpath  -name "*.yaml" |sed 's#.*/##')
#echo_date "yaml文件名是：$name" >> $LOG_FILE
yaml_tmp=/tmp/$name
#echo_date "yaml_tmp路径是：$yaml_tmp" >> $LOG_FILE
head_tmp=/jffs/softcenter/merlinclash/yaml/head.yaml

echo_date "yaml文件【后台处理ing】，请在日志页面看到完成后，再启动Clash！！！" >>"$LOG_FILE"
#echo_date "将标准头部文件复制一份到/tmp/" >>"$LOG_FILE"
#cp -rf /jffs/softcenter/merlinclash/yaml/head.yaml /tmp/head.yaml >/dev/null 2>&1 &
sleep 2s
#去注释
echo_date "文件格式标准化" >> $LOG_FILE
#将所有DNS都转化成dns
sed -i 's/DNS/dns/g' $yaml_tmp
#老格式处理
#当文件存在Proxy:开头的行数，将Proxy: ~替换成空格
para1=$(sed -n '/^Proxy: ~/p' $yaml_tmp)
if [ -n "$para1" ] ; then
    sed -i 's/Proxy: ~//g' $yaml_tmp
fi

para2=$(sed -n '/^Proxy Group: ~/p' $yaml_tmp)
#当文件存在Proxy Group:开头的行数，将Proxy Group: ~替换成空格
if [ -n "$para2" ] ; then
    sed -i 's/Proxy Group: ~//g' $yaml_tmp
fi

para3=$(sed -n '/Rule: ~/p' $yaml_tmp)
#当文件存在Rule:开头的行数，将Rule: ~替换成空格
if [ -n "$para3" ] ; then
    echo_date "将Rule:替换成rules:" >> $LOG_FILE
    sed -i 's/Rule: ~//g' $yaml_tmp
fi
#当文件存在Proxy:开头的行数，将Proxy:替换成proxies:
para1=$(sed -n '/^Proxy:/p' $yaml_tmp)
if [ -n "$para1" ] ; then
    sed -i 's/Proxy:/proxies:/g' $yaml_tmp
fi

para2=$(sed -n '/^Proxy Group:/p' $yaml_tmp)
#当文件存在Proxy Group:开头的行数，将Proxy Group:替换成proxy-groups:
if [ -n "$para2" ] ; then
    sed -i 's/Proxy Group:/proxy-groups:/g' $yaml_tmp
fi

para3=$(sed -n '/Rule:/p' $yaml_tmp)
#当文件存在Rule:开头的行数，将Rule:替换成rules:
if [ -n "$para3" ] ; then
    sed -i 's/Rule:/rules:/g' $yaml_tmp
fi

proxies_line=$(cat $yaml_tmp | grep -n "^proxies:" | awk -F ":" '{print $1}')
tail +$proxies_line $yaml_tmp > /tmp/a.yaml
cat /tmp/a.yaml > $yaml_tmp
echo_date "删除原文件头部内容" >> $LOG_FILE
#检查原文件是否存在头部参数,存在则删除，避免与后面处理重复
port=$(cat $yaml_tmp | grep -n "^port:" | awk -F ":" '{print $1}')
[ -n "$port" ] && sed -i "$port d" $yaml_tmp

sport=$(cat $yaml_tmp | grep -n "^socks-port:" | awk -F ":" '{print $1}')
[ -n "$sport" ] && sed -i "$sport d" $yaml_tmp

rport=$(cat $yaml_tmp | grep -n "^redir-port:" | awk -F ":" '{print $1}')
[ -n "$rport" ] && sed -i "$rport d" $yaml_tmp

allowlan=$(cat $yaml_tmp | grep -n "^allow-lan:" | awk -F ":" '{print $1}')
[ -n "$allowlan" ] && sed -i "$allowlan d" $yaml_tmp

mode=$(cat $yaml_tmp | grep -n "^mode:" | awk -F ":" '{print $1}')
[ -n "$mode" ] && sed -i "$mode d" $yaml_tmp

ll=$(cat $yaml_tmp | grep -n "^log-level:" | awk -F ":" '{print $1}')
[ -n "$ll" ] && sed -i "$ll d" $yaml_tmp

ec=$(cat $yaml_tmp | grep -n "^external-controller:" | awk -F ":" '{print $1}')
[ -n "$ec" ] && sed -i "$ec d" $yaml_tmp

ei=$(cat $yaml_tmp | grep -n "^experimental:" | awk -F ":" '{print $1}')
[ -n "$ei" ] && sed -i "$ei d" $yaml_tmp

irf=$(cat $yaml_tmp | grep -n "ignore-resolve-fail:" | awk -F ":" '{print $1}')
[ -n "$irf" ] && sed -i "$irf d" $yaml_tmp

hs=$(cat $yaml_tmp | grep -n "^hosts:" | awk -F ":" '{print $1}')
[ -n "$hs" ] && sed -i "$hs d" $yaml_tmp

rtr=$(cat $yaml_tmp | grep -n "router.asus.com:" | awk -F ":" '{print $1}')
[ -n "$rtr" ] && sed -i "$rtr d" $yaml_tmp
#插入一行免得出错
sed -i '$a' $yaml_tmp
cat $head_tmp >> $yaml_tmp
echo_date "标准头文件合并完毕" >> $LOG_FILE
#对external-controller赋值
#yq w -i $yaml_tmp external-controller $lan_ip:9990
sed -i "s/192.168.2.1:9990/$lan_ip:9990/g" $yaml_tmp

#写入hosts
#yq w -i $yaml_tmp 'hosts.[router.asus.com]' $lan_ip
sed -i '$a hosts:' $yaml_tmp
sed -i '$a \ \ router.asus.com: '"$lan_ip"'' $yaml_tmp

#不再检查，直接用redir-host替换 20200721++++++++++++++++
#检查配置文件dns
#echo_date "检查配置文件dns" >> $LOG_FILE
#yq r $yaml_tmp dns.enable 1>/dev/null 2>/tmp/dns_read_error.log
#dnserror=$(sed -n 1p /tmp/dns_read_error.log | awk -F':' '{print $1}')
#if [ $dnserror == "Error" ]; then
#    echo_date "yq 读取异常，yaml文件可能存在格式问题，即将退出！" >> $LOG_FILE
#    echo_date "以下是错误原因：" >> $LOG_FILE
#    a=$(cat /tmp/dns_read_error.log)
#    echo_date $a >> $LOG_FILE
#    rm -rf $yaml_tmp
#	echo_date "...MerlinClash！退出中..." >> $LOG_FILE
#	exit
#fi

#if [ $(yq r $yaml_tmp dns.enable) == 'true' ] && ([[ $(yq r $yaml_tmp dns.enhanced-mode) == 'fake-ip' || $(yq r $yaml_tmp dns.enhanced-mode) == 'redir-host' ]]); then
#    echo_date "上传Clash 配置文件DNS可用！" >> $LOG_FILE
#else
#    echo_date "在 Clash 配置文件中没有找到 DNS 配置！" >> $LOG_FILE
#echo_date "DNS默认采用redir-host模式" >> $LOG_FILE
#yq d -i $yaml_tmp dns
#yq m -x -i $yaml_tmp /jffs/softcenter/merlinclash/yaml/redirhost.yaml 1>/dev/null 2>/tmp/clash_error.log
#cat /jffs/softcenter/merlinclash/yaml/redirhost.yaml >> $yaml_tmp
#fi

#不再检查，直接用redir-host替换 20200721---------------------
echo_date "移动yaml文件到/jffs/softcenter/merlinclash/yaml_bak/ 目录下" >> $LOG_FILE
mv -f $yaml_tmp /jffs/softcenter/merlinclash/yaml_bak/$name
cp -rf /jffs/softcenter/merlinclash/yaml_bak/$name /jffs/softcenter/merlinclash/$name
#删除可能残留的yaml格式文件
rm -rf /tmp/*.yaml
#生成新的txt文件

rm -rf $fp/yamls.txt
echo_date "创建yaml文件列表" >> $LOG_FILE
#find $fp  -name "*.yaml" |sed 's#.*/##' >> $fp/yamls.txt
find $fp  -name "*.yaml" |sed 's#.*/##' |sed '/^$/d' | awk -F'.' '{print $1}' >> $fp/yamls.txt
#创建软链接
ln -s /jffs/softcenter/merlinclash/yaml_bak/yamls.txt /tmp/yamls.txt
#
echo_date "配置文件【处理完成】，如下拉框没找到配置文件，请手动刷新" >>"$LOG_FILE"

#http_response "$text1@$text2@$host@$secret"

