#!/bin/bash

pause_error()
{
    while true
    do
        read -p "Do you want to continue(Y/n) ?: " INPUT_STRING
        case $INPUT_STRING in
            c|C|y|Y|yes|YES"")
                echo ""
                break
            ;;
            n|N|no|NO)

                echo "***************************************************************************"
                echo "                        Thank You Using Script                            "
                echo "***************************************************************************"
                exit $1
            ;;
        esac
    done
}

install_require()
{
	echo "***************************************************************************"
	echo "                     Install apache2 debmirror                             "
	echo "***************************************************************************"
	apt install apache2 debmirror wget -y
}

install_ubuntu_keyring()
{
	echo "***************************************************************************"
	echo "                 Install and import ubuntu keyring                         "
	echo "***************************************************************************"
	wget http://pa.archive.ubuntu.com/ubuntu/pool/main/u/ubuntu-keyring/ubuntu-keyring_2012.05.19.tar.gz
	tar -xvf ubuntu-keyring_2012.05.19.tar.gz
	mv ubuntu-keyring-2012.05.19/ ubuntu-keyring/
	read -p "Enter directory path to storage trustedkeys.gpg(For e.x: /home/$USER/keyrings/ubuntu) and press [ENTER]: " UBUNTU_KEYRING
	UBUNTU_KEYRING=${UBUNTU_KEYRING%/} 
	#case $UBUNTU_KEYRING in *[!/]*/) UBUNTU_KEYRING=${UBUNTU_KEYRING%"${UBUNTU_KEYRING##*[!/]}"};; esac
	mkdir -p $UBUNTU_KEYRING
	gpg --no-default-keyring --keyring $UBUNTU_KEYRING/trustedkeys.gpg --import ./ubuntu-keyring/keyrings/ubuntu-archive-keyring.gpg
}

install_ubuntu_cloud_keyring()
{
	echo "***************************************************************************"
	echo "                Install and import ubuntu cloud keyring                    "
	echo "***************************************************************************"
	wget https://launchpad.net/ubuntu/+archive/primary/+files/ubuntu-cloud-keyring_2012.08.14.tar.gz
	tar -xvf ubuntu-cloud-keyring_2012.08.14.tar.gz
	mv ubuntu-cloud-keyring-2012.08.14/ ubuntu-cloud-keyring/
	read -p "Enter directory path to storage trustedkeys.gpg(For e.x: /home/$USER/keyrings/ubuntu_cloud) and press [ENTER]: " UBUNTU_CLOUD_KEYRING
	UBUNTU_CLOUD_KEYRING=${UBUNTU_CLOUD_KEYRING%/} 
	#case $UBUNTU_CLOUD_KEYRING in *[!/]*/) UBUNTU_CLOUD_KEYRING=${UBUNTU_CLOUD_KEYRING%"${UBUNTU_CLOUD_KEYRING##*[!/]}"};; esac
	mkdir -p $UBUNTU_CLOUD_KEYRING
	gpg --no-default-keyring --keyring UBUNTU_CLOUD_KEYRING/trustedkeys.gpg --import ./ubuntu-cloud-keyring/keyrings/ubuntu-cloud-keyring.gpg
}

apt_repos_mirroring()
{
	install_ubuntu_keyring
	mkdir -p /var/www/html/repos/ubuntu/
	chmod +x apt_repos_mirroring.sh
	while true
	do
		bash apt_repos_mirroring.sh
		if [ $? -eq 0 ]
		then
			# Check system is using systemd or sysvinit
			if pidof systemd > /dev/null
			then
				systemctl enable apache2.service
				systemctl restart apache2.service
			else
				/etc/init.d/apache2 restart
			fi
			echo "*********************************************************************************"
			echo "     Mirroring apt repository successfully, check /var/www/html/repos/ubuntu/    "
			echo "  Access http://localhost/repos/ubuntu/ to check your repos is published or not  "
			echo "*********************************************************************************"
			break
		else
			echo "*********************************************************************************"
			echo "                    ERROR! Mirroring apt repository failed                       "
			echo "*********************************************************************************"
			pause_error
		fi
	done
}

cloud_apt_repos_mirroring()
{
	install_ubuntu_cloud_keyring
	mkdir -p /var/www/html/repos/cloud/
	chmod +x cloud_apt_repos_mirroring.sh
	while true
	do
		bash cloud_apt_repos_mirroring.sh
		if [ $? -eq 0 ]
		then
			# Check system is using systemd or sysvinit
			if [ pidof systemd > /dev/null ]
			then
				systemctl enable apache2.service
				systemctl restart apache2.service
			else
				/etc/init.d/apache2 restart
			fi
			echo "*********************************************************************************"
			echo "  Mirroring cloud apt repository successfully, check /var/www/html/repos/cloud/  "
			echo "  Access http://localhost/repos/cloud/ to check your repos is published or not   "
			echo "*********************************************************************************"
			break
		else
			echo "*********************************************************************************"
			echo "                  ERROR! Mirroring cloud apt repository failed                   "
			echo "*********************************************************************************"
			pause_error
		fi
	done
}

schedule_job()
{
	mkdir -p /root/scripts
	cp apt_repos_mirroring.sh /root/scripts/
	cp cloud_apt_repos_mirroring.sh /root/scripts
	echo "***************************************************************************"
	echo "                        Schedule job(Crontab)                              "
	echo "***************************************************************************"
	echo -en "\n"
	echo "0 0 * * * bash /root/scripts/apt_repos_mirroring.sh" >> /etc/crontab
	echo "30 2 * * * bash /root/scripts/cloud_apt_repos_mirroring.sh" >> /etc/crontab
	echo -en "\n"
}

main()
{
	install_require
	apt_repos_mirroring
	cloud_apt_repos_mirroring
	schedule_job
	echo "*******************************************************************************************"
	echo "                 Done! Now you can install package using this repository              	 "
	echo "**Set up client side: 															         "
 	echo "echo \"deb http://YOUR_REPO_SERVER/repos/ubuntu <osrelease> main\" >> /etc/apt/sources.list"
 	echo "apt-key adv --keyserver keyserver.ubuntu.com --recv-keys "`apt update 2>&1 |grep NO_PUBKEY |sed -e 's?^.*NO_PUBKEY ??'`" && apt update"
 	echo "apt-get update && apt-get install YOUR_PACKAGE  											 "
	echo "*******************************************************************************************"
}

main
