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
SCRIPT_PATH="$(dirname "$0")"


#******1.7.5.4035-313f93718 version installs deb repo for Plex.tv self own repo to Sources.list******
#systemd file gets saved under /lib/systemd/system
#ignore cache folder, plug-ins folder,
#https://gist.github.com/ssmereka/8773626



#Modes (Variables)
# b=backup i=install r=restore u=update U=Force Update
mode="$1"
Programloc='/var/lib/plexmediaserver/Library/Application Support/Plex Media Server'
backupdir=/opt/backup/Plex
time=$(date +"%m_%d_%y-%H_%M")

case $mode in
	(-i|"")
	echo "<--- Installing Plex Media Server ->"
	bash ${SCRIPT_PATH}/plexupdate.sh -p -a -d
	;;
	(-b)
	echo "Backing up Plex Media Server"
	echo "<--- Stopping Plex Media Server ->"
	sudo systemctl stop plexmediaserver
	echo "Making sure Backup Dir exists"
	mkdir -p $backupdir
	echo "Please Wait Checking Size of Plex Media Server to be backed up"
	echo "Once done total memory is on the bottom of list"
	du -h --max-depth=1 "$Programloc"
	#tar -zcf will compress 61M dir to 11M file
	#tar -azcf same results with 11M file
	#tar -cf /opt/backup/PlexMediaServer_FullBackup-$time.tar.gz --lzma $backupdir results 3.8M File
    	tar -cf /opt/backup/PlexMediaServer_FullBackup-$time.tar.gz --lzma "$Programloc"
    	echo "Restarting up Plex Media Server"
	systemctl start plexmediaserver
	;;
	(-r)
	echo "<--- Restoring Plex Media Server ->"
	echo "<--- Stopping Plex Media Server ->"
	sudo systemctl stop plexmediaserver
	chmod 0777 -R "$Programloc"
	tar xjf $backupdir/PlexMediaServer_FullBackup-*.tar.gz "$Programloc"
	sleep 20
	echo "Restarting up Plex Media Server"
	systemctl start plexmediaserver
	;;
	(-u)
	echo "<--- Updating Plex Media Server ->"
	bash ${SCRIPT_PATH}/plexupdate.sh -p -a -d
	;;
	(-U)
	echo "<--- Force Updating Plex Media Server ->"
	bash ${SCRIPT_PATH}/plexupdate.sh -p -a -d -f
	;;
	(-*) echo "Invalid Argument"; exit 0;;
esac
exit 0
