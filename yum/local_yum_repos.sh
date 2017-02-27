#!/bin/bash/

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

                echo "******************************************************************************************************"
                echo "                                     Thank You Using Script                                          "
                echo "******************************************************************************************************"
                exit $1
            ;;
        esac
    done
}

install_requirements()
{
	yum update
	yum install httpd createrepo rsync epel-release firewalld -y
}

init_repo()
{
	# Create local directory
	mkdir -p /var/www/html/repos/centos/$1/$2/
	while true
	do
		# Init database
		echo "******************************************************************************************************"
		echo "                    Run command createrepo /var/www/html/repos/centos/$1/$2/                          "
		echo "******************************************************************************************************"
		createrepo /var/www/html/repos/centos/$1/$2/
		if [ $? -eq 0 ]
		then
			echo "******************************************************************************************************"
			echo "					Createrepo /var/www/html/repos/centos/$1/$2/ successfully                           "
			echo "******************************************************************************************************"
			break
		else
			echo "******************************************************************************************************"
			echo "                                   ERROR! CreateRepo failed                                           "
			echo "******************************************************************************************************"
			pause_error
		fi	
	done
}

rsync_repos()
{
	while true
	do
		echo "******************************************************************************************************"
		echo "                                     Run command rsync                                                "
		echo "******************************************************************************************************"
		/usr/bin/rsync -avz --exclude='repo*' rsync://mirrors.viethosting.com/centos/$1/$2/ /var/www/html/repos/centos/$1/$2
		if [ $? -eq 0 ]
		then
			echo "******************************************************************************************************"
			echo "  Rsync from mirrors.viethosting.com/centos/$1/$2/ to /var/www/html/repos/centos/$1/$2/ successfully  "
			echo "******************************************************************************************************"
			break
		else
			echo "******************************************************************************************************"
			echo "                                       ERROR! Rsync failed                                            "
			echo "******************************************************************************************************"
			pause_error
		fi	
	done
}


keep_repos_uptodate()
{
	echo "******************************************************************************************************"
	echo "                            Schedule Job! Keep your repos up to date                                  "
	echo "******************************************************************************************************"
	HOURRSYNC=$3
	MINUTERSYNC=$4
	HOURCREATEREPO=$((HOURRSYNC+1))
	MINUTECREATEREPO=$((MINUTERSYNC+30))
	echo "$MINUTERSYNC $HOURRSYNC * * * /usr/bin/rsync -avz --exclude='repo*' rsync://mirrors.viethosting.com/centos/$1/$2/ /var/www/html/repos/centos/$1/$2" >> /etc/crontab
	echo -en "\n"
	echo "$MINUTECREATEREPO $HOURCREATEREPO * * * /usr/bin/createrepo --update /var/www/html/repos/centos/$1/$2" >> /etc/crontab
	echo -en "\n"
}

read_configfile_and_run()
{
	# CONFIG_FILE - list all repos you want to clone
	RELEASE=$1
	REPOS_FILE=$2
	# Config to schedule rsync at HOUR:MINUTE
	echo "Execute at (Crontab):\n"
	read -e -p "* HOUR (default - 3) and press [ENTER]: " -i "3" HOUR
	read -e -p "* MINUTE (default - 0) and press [ENTER]: " -i "0" MINUTE
	while read line; do
		init_repo $RELEASE $line
		rsync_repos $RELEASE $line
		keep_repos_uptodate $RELEASE $line $HOUR $MINUTE
		$HOUR=$((HOUR+2))
	done < $REPOS_FILE
}

main()
{
	read -e -p "Enter CENTOS release (6, 6.7, 7, 7.1,...for e.x) and press [ENTER]: " -i "7" OSRELEASE
	read -e -p "Enter CENTOS repos config file (look at repos_list file for e.x) and press [ENTER]: " -i "repos_list" REPOS_FILE
	install_requirements
	read_configfile_and_run $OSRELEASE $REPOS_FILE
	echo "******************************************************************************************************"
	echo "                                       DONE! Restart HTTPD                                            "
	echo "******************************************************************************************************"
	systemctl enable httpd
	systemctl restart httpd
}

main