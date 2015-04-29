#!/usr/bin/env bash

USERROOT=$(cd ~ && pwd)
WORKSPACE=$USERROOT/Workspace

if [[ ! -f ~/.npsetting ]]; then
	echo 'np 第一次使用 需要初始化 请稍等...'

	touch ~/.npsetting || echo "${USERROOT} 您没有写权限"
	
	echo "workspace=$WORKSPACE" >> ~/.npsetting	
	sleep 3
fi


read -p "项目名称:
> " pname

DIR=$WORKSPACE/$pname

if [[ -e $DIR ]]; then
	read -p "Project $name is already exist, would you like to delete ? Y/n 
" ans
	case $ans in
		[yY])
			echo "哈 还是自己删除吧..."	
			;;	
	esac
	exit 2
fi

mkdir {$WORKSPACE/$pname,$WORKSPACE/$pname/docs} && echo "inited project folder successed "

read -p "ssh git url 
> " sshurl

if [[ ${#sshurl} -gt 0 ]]; then

	echo "开始Clone 项目"

	(cd $DIR && git clone $sshurl html)

fi

echo "项目已经创建 $WORKSPACE/$pname"






