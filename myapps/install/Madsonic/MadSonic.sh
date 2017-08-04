#!/bin/bash

if [[ $EUID -ne 0 ]]; then
	echo "This Script must be run as root"
	exit 1
fi

#Modes (Variables)
# b=backup i=install r=restore u=update(coming soon)
mode="$1"
Programloc=/etc/default/madsonic
backupdir=/opt/backup/Madsonic
time=$(date +"%m_%d_%y-%H_%M")

case $mode in
	(-i|"")
	add-apt-repository -y ppa:webupd8team/java
	apt update
	echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections
	echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections
	apt install oracle-java8-installer -y
	adduser --disabled-password --system --gecos "Madsonic Service" --group Madsonic
	#Latest Stable as of 5/29/2017
	#http://beta.madsonic.org/pages/download.jsp
	wget http://madsonic.org/download/6.2/20161208_madsonic-6.2.9040.deb
	dpkg -i 20161208_madsonic-6.2.9040.deb
	#edit MADSONIC_USER variable to not run as root under /var/madsonic or /etc/default/madsonic
	sed -i
	echo "Creating Startup Script"
	cp /opt/install/Madsonic/madsonic.service /etc/systemd/system/
	chmod 644 /etc/systemd/system/madsonic.service
	systemctl enable madsonic.service
	systemctl restart madsonic.service
	;;
	(-r)
	echo "<-- Restoring Madsonic Settings -->"
	echo "Stopping Jackett"
	systemctl stop madsonic
	sudo chmod 0777 -R $Programloc
	cp /opt/install/Madsonic/ServerConfig.json ~/.config/Jackett/
	echo "Restarting up Madsonic"
	systemctl start madsonic
	;;
	(-b)
	echo "Stopping Madsonic"
    	systemctl stop madsonic
    	echo "Making sure Backup Dir exists"
    	mkdir -p $backupdir
    	echo "Backing up Madsonic to /opt/backup"
	cp ~/.config/Madsonic/ServerConfig.json $backupdir
	tar -zcvf /opt/backup/Madsonic_FullBackup-$time.tar.gz $backupdir
    	echo "Restarting up Madsonic"
	systemctl start madsonic
	;;
	(-*) echo "Invalid Argument"; exit 0;;
esac
exit 0
	
	
	
