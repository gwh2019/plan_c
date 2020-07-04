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
head_tmp=/tmp/head.yaml

echo_date "yaml文件【后台处理ing】，请在日志页面看到完成后，再启动Clash！！！" >>"$LOG_FILE"
echo_date "将标准头部文件复制一份到/tmp/" >>"$LOG_FILE"
cp -rf /jffs/softcenter/merlinclash/yaml/head.yaml /tmp/head.yaml >/dev/null 2>&1 &
sleep 2s
#去注释
echo_date "文件标准化格式" >>"$LOG_FILE"
sed -i 's/#.*//' $yaml_tmp
#将所有DNS都转化成dns
sed -i 's/DNS/dns/g' $yaml_tmp
#老标题更新成新标题
#当文件存在Proxy:开头的行数，将Proxy: ~替换成proxies: ~并删除
para1=$(sed -n '/^Proxy:/p' $yaml_tmp)
if [ -n "$para1" ] ; then
    echo_date "将Proxy:替换成proxies:" >> $LOG_FILE
    sed -i 's/Proxy:/proxies:/g' $yaml_tmp
fi
sed -i 's/proxies: ~//g' $yaml_tmp

para2=$(sed -n '/^Proxy Group:/p' $yaml_tmp)
#当文件存在Proxy Group:开头的行数，将Proxy Group: ~替换成proxy-groups: ~并删除
if [ -n "$para2" ] ; then
    echo_date "将Proxy Group:替换成proxy-groups:" >> $LOG_FILE
    sed -i 's/Proxy Group:/proxy-groups:/g' $yaml_tmp
fi
sed -i 's/proxy-groups: ~//g' $yaml_tmp

para3=$(sed -n '/^Rule:/p' $yaml_tmp)
#当文件存在Rule:开头的行数，将Rule: ~替换成rules: ~并删除
if [ -n "$para3" ] ; then
    echo_date "将Rule:替换成rules:" >> $LOG_FILE
    sed -i 's/Rule:/rules:/g' $yaml_tmp
fi
sed -i 's/rules: ~//g' $yaml_tmp
#去空白行
sed -i '/^ *$/d' $yaml_tmp
#删除文件自带的port、socks-port、redir-port、allow-lan、mode、log-level、external-controller、experimental段
echo_date "删除配置文件头并与标准文件头拼接" >> $LOG_FILE 
yq d  -i $yaml_tmp port
yq d  -i $yaml_tmp socks-port
yq d  -i $yaml_tmp redir-port
yq d  -i $yaml_tmp allow-lan
yq d  -i $yaml_tmp mode
yq d  -i $yaml_tmp log-level
yq d  -i $yaml_tmp external-controller
yq d  -i $yaml_tmp experimental

#至此，.yaml将是从dns:开始，头部在后，减少合并时间接下来进行合并
yq m -x -i $yaml_tmp $head_tmp
#对external-controller赋值
yq w -i $yaml_tmp external-controller $lan_ip:9990
#写入hosts
yq w -i $yaml_tmp 'hosts.[router.asus.com]' $lan_ip
#检查配置文件dns
echo_date "检查配置文件dns" >> $LOG_FILE
if [ $(yq r $yaml_tmp dns.enable) == 'true' ] && ([[ $(yq r $yaml_tmp dns.enhanced-mode) == 'fake-ip' || $(yq r $yaml_tmp dns.enhanced-mode) == 'redir-host' ]]); then
    echo_date "上传Clash 配置文件DNS可用！" >>"$LOG_FILE"
else
    echo_date "在 Clash 配置文件中没有找到 DNS 配置！默认用redir-host模式补全" >>"$LOG_FILE"
    yq m -x -i $yaml_tmp /jffs/softcenter/merlinclash/yaml/redirhost.yaml
fi
#再次检查dns是否补全，如果仍没有检查到dns配置，退出
if [ $(yq r $yaml_tmp dns.enable) == 'true' ] && ([[ $(yq r $yaml_tmp dns.enhanced-mode) == 'fake-ip' || $(yq r $yaml_tmp dns.enhanced-mode) == 'redir-host' ]]); then
    echo_date "再次检查Clash 配置文件DNS可用！"
else
	echo_date "在 Clash 配置文件中没有找到 DNS 配置！请检查你的配置文件！"
	echo_date "...MerlinClash！退出中..."
	exit
fi


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

