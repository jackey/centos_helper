#!/usr/bin/env bash

euro_src="user@x.x.x.x:/path/to/source"
euro_tgt="/path/to/local"
euro_exclude=".git"

rsync_option="vaz -e ssh "

if [[ -e /lib/lsb/init-functions ]]; then
	. /lib/lsb/init-functions
else
	. /etc/init.d/functions
fi

start_workname1() {
	echo "开始同步文件..."  
	rsync -$rsync_option --exclude=$euro_exclude $euro_src $euro_tgt
}


[ $# -eq 0 ] && ( echo "usage: sync.sh [euro]"; exit 4 );

case $1 in
	work_name1)
		start_workname1
		;;
	
esac
