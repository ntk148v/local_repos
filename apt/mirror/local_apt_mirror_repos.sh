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
                echo "                        Thanks You Using Script                            "
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
	wget http://pa.archive.ubuntu.com/ubuntu/pool/main/u/ubuntu-keyring/ubuntu-keyring_2016.10.27.tar.gz
	tar -xvf ubuntu-keyring_2016.10.27.tar.gz
	mv ubuntu-keyring_2016.10.27/ ubuntu-keyring/
	mkdir -p /root/keyrings/ubuntu/
	gpg --no-default-keyring --keyring /root/keyrings/ubuntu/trustedkeys.gpg --import ubuntu-keyring/keyrings/ubuntu-archive-keyring.gpg
}

install_ubuntu_cloud_keyring()
{
	echo "***************************************************************************"
	echo "                Install and import ubuntu cloud keyring                    "
	echo "***************************************************************************"
	wget https://launchpad.net/ubuntu/+archive/primary/+files/ubuntu-cloud-keyring_2012.08.14.tar.gz
	tar -xvf ubuntu-cloud-keyring_2012.08.14.tar.gz
	mv ubuntu-cloud-keyring_2012.08.14/ ubuntu-cloud-keyring/
	mkdir -p /root/keyrings/ubuntu_cloud/
	gpg --no-default-keyring --keyring /root/keyrings/ubuntu_cloud/trustedkeys.gpg --import ubuntu-cloud-keyring/keyrings/ubuntu-cloud-keyring.gpg
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
			if [ pidof systemd > /dev/null ]
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
			echo "                                ERROR!                                           "
			echo "*********************************************************************************"
			pause_error
		fi
	done
}

cloud_apt_repos_mirroring()
{
	install_ubuntu_keyring
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
			echo "                                ERROR!                                           "
			echo "*********************************************************************************"
			pause_error
		fi
	done
}

schedule_job()
{
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
 	echo "apt-get update && apt-get install YOUR_PACKAGE  											 "
	echo "*******************************************************************************************"
}

main