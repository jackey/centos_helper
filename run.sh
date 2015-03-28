#!/bin/bash


OS=$(uname -s)
ARCH=$(uname -m)
VER=$(uname -v)
CENTOS=


# 只允许在Centos上允许
file /etc/centos-release 1 > /dev/null 2>&1 || $( echo "请在Centos 运行此脚本" && exit 1 )

CENTOS=`cat /etc/centos-release`
case "6.6" in
	*6.* )
		CENTOS=6
		;;
	*5.* )
		CENTOS=5
		;;
	*)	echo "只支持Centos 5 和 Centos 6"
		;;
esac

EPEL="http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.3-1.el${CENTOS}.rf.${ARCH}.rpm"
REMI="http://rpms.famillecollet.com/enterprise/remi-release-${CENTOS}.rpm"


# 引入常用方法集
. /etc/init.d/functions

show_success() {
	return 0
}

show_failed() {
	return 1;
}

# 安装应用库
setup_new_repo () {
	action "安装软件库中..." show_success	
	for REPO in $EPEL $REMI; do
		action "${REPO}" show_success
		rpm -Uvh $REPO 1>/dev/null 2>/tmp/Error
		if [[ $? -eq 0 ]]; then
			action "软件库安装成功" show_success
		else
			ERROR=$(</tmp/Error)
			action "软件库安装失败" show_failed
			echo "REPO: ${REPO}"
			echo "错误: ${ERROR}"	
		fi
	done

	action "更新软件包中..."
	yum update 1>/dev/null 2>/tmp/Error
	if [[ $? -eq 0 ]]; then
		action "更新软件包成功" show_success
	else
		action "更新软件包失败" show_failed
		ERROR=$(</tmp/Error)
		echo -n "错误: $ERROR"
		echo
	fi
}


# 安装VPN客户端

setup_vpn_client() {
	action "安装pptp 客户端" show_success
	yum install pptp -y 1>/dev/null 2>/tmp/Error
	ERROR=$(</tmp/Error)
	if [[ $? -eq 0 ]]; then
		action "安装失败 错误消息:" show_failed
		echo $ERROR
	fi

	read -p "`echo -e '请输入VPN服务器地址\n\b'`" SERVER
	read -p "$(echo -e '请输入VPN帐号\n\b')" ACCOUNT
	read -p "$(echo -e '请输入VPN密码\n\b')" PASS

	CS="/etc/ppp/chap-secrets"
	[[ -f $CS ]] || touch $CS

	SERVER_NAME="RUNJSSERVER"
	
	printf "\n" >> $CS

	action "写入VPN帐号到配置" show_success
	printf "%s    %s    %s    *\n" $ACCOUNT $SERVER_NAME $PASS  >> $CS
	action "写入VPN帐号成功" show_success
	
	PP="/etc/ppp/peers"
	[[ -d $PP ]] || mkdir $PP

	PPNAME="vpn.$SERVER_NAME.fumer.me"
	PPF="${PP}/$PPNAME"	

	action "写入VPN客户端配置"
	printf "pty \"pptp $s --nolaunchpppd\"\n name %s \n remotename %s \n require-mppe-128 \n file /etc/ppp/options.pptp \n ipparam %s\n" $SERVER $ACCOUNT $SERVER_NAME $PPNAME > $PPF
	
	action "开启ppp_mppe 模块" modprobe ppp_mppe 


	action "更改/etc/ppp/options.pptp 配置中" show_success
	action "备份/etc/ppp/options.pptp" cp /etc/ppp/options.pptp /etc/ppp/options.pptp.bk 

	printf "lock \n noauth \n refuse-pap \n refuse-eap \n refuse-chap \n nobsdcomp \n nodeflate \n require-mppe-128" > /etc/ppp/options.pptp	
	echo "运行 fumervpnd 链接vpn "
	
	touch /usr/local/bin/fumervpnd && printf "!#/usr/bin/env bash \n echo '链接VPN中' \n pppd call $PPNAME" > /usr/local/bin/fumervpn && chmod +x /usr/local/bin/fumervpnd	

	action "VPN 客户端安装成功" show_success
		
}


# 安装PHP 5.4 / MySQL 5.5 / Apache 2.4

install_lamp() {
	echo "LAMP"
}


install_git () {
	action "安装GIT" yum install git
}

case "$1" in 
	setup)
		setup_new_repo
		;;
	vpn)
		setup_vpn_client
		;;
	git)
		install_git
		;;

	*)
		echo "使用: run.sh [setup | lamp | systool | vpn | ftp | git | update ]"
		exit 0
esac

	









