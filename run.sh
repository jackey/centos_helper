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


# 安装PHP 5.4 / MySQL 5.5 / Apache 2.4

install_lamp() {
	echo "LAMP"
}

case "$1" in 
	setup)
		echo "setup"
		;;

	*)
		echo "使用: run.sh [setup | lamp | systool | vpn ]"
		exit 0
esac

	









