#!/bin/bash

#开放ssh端口、回环、外网、默认策略
config_default(){
    systemctl stop firewalld
    systemctl disable firewalld
    yum install -y iptables-services
    systemctl start iptables
    systemctl enable iptables
    iptables -F
    ssh_port=$(awk '$1=="Port" {print $2}' /etc/ssh/sshd_config)
    if [ ! -n "$ssh_port" ]; then
        iptables -A INPUT -p tcp -m tcp --dport 22 -j ACCEPT
    else
        iptables -A INPUT -p tcp -m tcp --dport ${ssh_port} -j ACCEPT
    fi
    iptables -A INPUT -p tcp -m tcp --dport 80 -j ACCEPT
    iptables -A INPUT -p tcp -m tcp --dport 443 -j ACCEPT
    iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
    iptables -A INPUT -i lo -j ACCEPT
    iptables -P INPUT DROP
    iptables -P FORWARD DROP
    iptables -P OUTPUT ACCEPT
    service iptables save
    echo "初始配置完成"
}

#禁止邮箱
config_mail(){
    iptables -A OUTPUT -p tcp -m multiport --dports 24,25,26,50,57,105,106,109,110,143 -j REJECT --reject-with tcp-reset
    iptables -A OUTPUT -p udp -m multiport --dports 24,25,26,50,57,105,106,109,110,143 -j DROP
    iptables -A OUTPUT -p tcp -m multiport --dports 158,209,218,220,465,587,993,995,1109,60177,60179 -j REJECT --reject-with tcp-reset
    iptables -A OUTPUT -p udp -m multiport --dports 158,209,218,220,465,587,993,995,1109,60177,60179 -j DROP
    service iptables save
    echo "禁止邮箱完毕"
}

#禁止关键字
config_keyword(){
    iptables -A OUTPUT -m string --string "torrent" --algo bm -j DROP
    iptables -A OUTPUT -m string --string ".torrent" --algo bm -j DROP
    iptables -A OUTPUT -m string --string "peer_id=" --algo bm -j DROP
    iptables -A OUTPUT -m string --string "announce" --algo bm -j DROP
    iptables -A OUTPUT -m string --string "info_hash" --algo bm -j DROP
    iptables -A OUTPUT -m string --string "get_peers" --algo bm -j DROP
    iptables -A OUTPUT -m string --string "find_node" --algo bm -j DROP
    iptables -A OUTPUT -m string --string "BitToorent" --algo bm -j DROP
    iptables -A OUTPUT -m string --string "announce_peer" --algo bm -j DROP
    iptables -A OUTPUT -m string --string "BitTorrent protocol" --algo bm -j DROP
    iptables -A OUTPUT -m string --string "announce.php?passkey=" --algo bm -j DROP
    iptables -A OUTPUT -m string --string "magnet:" --algo bm -j DROP
    iptables -A OUTPUT -m string --string "xunlei" --algo bm -j DROP
    iptables -A OUTPUT -m string --string "sandai" --algo bm -j DROP
    iptables -A OUTPUT -m string --string "Thunder" --algo bm -j DROP
    iptables -A OUTPUT -m string --string "XLLiveUD" --algo bm -j DROP
    iptables -A OUTPUT -m string --string "youtube.com" --algo bm -j DROP
    iptables -A OUTPUT -m string --string "google.com" --algo bm -j DROP
    iptables -A OUTPUT -m string --string "youku.com" --algo bm -j DROP
    iptables -A OUTPUT -m string --string "iqiyi.com" --algo bm -j DROP
    iptables -A OUTPUT -m string --string "qq.com" --algo bm -j DROP
    iptables -A OUTPUT -m string --string "huya.com" --algo bm -j DROP
    iptables -A OUTPUT -m string --string "douyu.com" --algo bm -j DROP
    iptables -A OUTPUT -m string --string "twitch.tv" --algo bm -j DROP
    iptables -A OUTPUT -m string --string "panda.tv" --algo bm -j DROP
    service iptables save
    echo "禁止关键字完毕"
}

#开放自定义端口
config_port(){
    echo "开放一个自定义的端口段"
    read -p "输入开始端口：" start_port
    read -p "输入结束端口：" stop_port
    iptables -A INPUT -p tcp -m tcp --dport ${start_port}:${stop_port} -j ACCEPT
    iptables -A INPUT -p udp -m udp --dport ${start_port}:${stop_port} -j ACCEPT
    service iptables save
    echo "开放端口完毕"
}

#连接数限制
config_conn(){
    echo "限制一个端口段的连接数"
    read -p "输入开始端口：" start_conn
    read -p "输入结束端口：" stop_conn
    read -p "输入每个ip允许的连接数：" conn_num
    iptables -A INPUT -p tcp --dport ${start_conn}:${stop_conn} -m connlimit --connlimit-above ${conn_num} -j DROP
    iptables -A INPUT -p udp --dport ${start_conn}:${stop_conn} -m connlimit --connlimit-above ${conn_num} -j DROP
    service iptables save
    echo "限制连接数完毕"
}

#清空规则
config_clear(){
    iptables -P INPUT ACCEPT
    iptables -P FORWARD ACCEPT
    iptables -F
    service iptables save
    echo "清除规则完毕"
}

#start
start_menu(){
while [ 1 ] 
do
    echo "========================="
    echo " 介绍：适用于CentOS7"
    echo " 作者：天工开物"
    echo " 网站：www.heidongwang.top"
    echo " 公众号：黑洞宅"
    echo "========================="
    echo "1. 开启ssh（必须）"
    echo "2. 禁止邮箱"
    echo "3. 禁止常用关键字"
    echo "4. 开放自定义端口"
    echo "5. 连接数限制"
    echo "6. 清除所有规则"
    echo "0. 退出"
    echo
    read -p "请输入数字:" num
    case "$num" in
    	1)
	config_default
	;;
	2)
	config_mail
	;;
        3)
	config_keyword
	;;
        4)
	config_port
	;;
        5)
	config_conn
	;;
        6)
	config_clear
	;;
	0)
	exit 1
	;;
	*)
	clear
	echo "请输入正确数字"
	sleep 5s
	start_menu
	;;
    esac
done
}

start_menu
