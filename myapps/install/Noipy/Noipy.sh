#!/bin/bash

###########################################################
# Created by @tazboyz16 
# This Script was created at 
# https://github.com/tazboyz16/Ubuntu-Server-Auto-Install
# @ 2017 Copyright
# GNU General Public License v3.0
###########################################################

if [[ $EUID -ne 0 ]]; then
	echo "This Script must be run as root"
	exit 1
fi

#Modes (Variables)
# b=backup i=install r=restore u=updateIP
mode="$1"
Programloc=~/.noipy
backupdir=/opt/backup/Noipy
time=$(date +"%m_%d_%y-%H_%M")

case $mode in
	(-i|"")
	apt update
	apt install python python-pip
	pip install noipy
	#to create auth config file to service
	noipy --store -u xxxusernamxxx -p xxxpasswordxxx -n xxxdomainxxx --provider generic --url https://api.dynu.com IP_ADDRESS
	;;
	(-r)
	echo "<--- Restoring Noipy Settings --->"
	cp $backupdir  $Programloc
	;;
	(-b)
    	echo "Making sure Backup Dir exists"
    	mkdir -p $backupdir
    	echo "Backing up Noipy to /opt/backup"
	cp -rf $Programloc $backupdir
    	tar -zcvf /opt/backup/Noipy_FullBackup-$time.tar.gz $backupdir
	;;
	(-u)
	noipy -n xxxdomainxxx --url https://api.dynu.com
	;;
	(-*) echo "Invalid Argument"; exit 0;;
esac
exit 0
