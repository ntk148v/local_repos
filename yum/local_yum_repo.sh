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

                echo "**********************************************************************************************************************"
                echo "Thanks You Using Script"
                echo "**********************************************************************************************************************"
                exit $1
            ;;
        esac
    done
}

install_requirements()
{
	yum update
	yum install httpd createrepo rsync epel-release firewalld 
	-y
}

init_repo()
{
	# Create local directory
	mkdir -p /var/www/html/repos/centos/$1/$2/
	while true
	do
		# Init database
		createrepo /var/www/html/repos/centos/$1/$2/
		if [ $? -eq 0 ]
		then
			echo "**********************************************************************************************************************"
			echo "Createrepo /var/www/html/repos/centos/$1/$2/ successfully"
			echo "**********************************************************************************************************************"
			break
		else
			echo "**********************************************************************************************************************"
			echo "Error!"
			echo "**********************************************************************************************************************"
			pause_error
		fi	
	done
}

rsync_repos()
{
	while true
	do
		/usr/bin/rsync -avz --exclude='repo*' rsync://mirrors.viethosting.com/centos/$1/$2/ /var/www/html/repos/centos/$1/$2
		if [ $? -eq 0 ]
		then
			echo "**********************************************************************************************************************"
			echo "Rsync from rsync://mirrors.viethosting.com/centos/$1/$2/ to rsync://mirrors.viethosting.com/centos/$1/$2/ successfully"
			echo "**********************************************************************************************************************"
			break
		else
			echo "**********************************************************************************************************************"
			echo "Error!"
			echo "**********************************************************************************************************************"
			pause_error
		fi	
	done
}


keep_repos_uptodate()
{
	HOUR=$3
	MINUTE=$4
	echo "$MINUTE $HOUR * * * /usr/bin/rsync -avz --exclude='repo*' rsync://mirrors.viethosting.com/centos/$1/$2/ /var/www/html/repos/centos/$1/$2" >> /etc/crontab
	echo -en "\n"
}

read_configfile_and_run()
{
	# CONFIG_FILE - list all repos you want to clone
	RELEASE=$1
	REPOS_FILE=$2
	# Config to schedule rsync at HOUR:MINUTE
	HOUR=1
	MINUTE=30
	while read line; do
		init_repo $RELEASE $line
		rsync_repos $RELEASE $line
		keep_repos_uptodate $RELEASE $line $HOUR $MINUTE
		$HOUR=$[$HOUR+1]
	done < $REPOS_FILE
}

main()
{
	install_requirements
	read_configfile $1 $2
	systemctl enable httpd
	systemctl restart httpd
}

main $1 $2