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
	echo "                     Install apache2 reprepro                              "
	echo "***************************************************************************"
	apt install apache2 reprepro wget -y
}

generate_gpg_keys()
{
	# GnuPG keys is used here for two purposes:\
	# - Signing the Debian packages (manually)
	# - Signing the catalog files (automatically by reprepro)
	echo "***************************************************************************"
	echo "                 Creating a GPG Key for Signing Stuff                      "
	echo "- Run the following command: gpg --gen-key                                 "
	echo "- Select Option 1 to generate an RSA Key                                   "
	echo "- Choose your keysize from the options given                               "
	echo "- Enter your name and email address when prompted                          "
	echo "***************************************************************************"
	sleep 15
	gpg --gen-key
}

configure_apache2()
{
	# Repo name = owned, you can change it to whatever you want
	# Company name for e.x.
	mkdir -p /var/www/html/repos/owned/
	cp owned_repos.conf /etc/apache2/conf-availabe/owned_repos.conf
	a2enconf owned_repos
	apache2ctl configtest
	service apache2 restart
}

configure_reprepro()
{
	mkdir -p /var/www/html/repos/owned/conf/
	while true
	do
		echo "***************************************************************************"
		echo "             Create /var/www/html/repos/owned/conf/distributions           "
		echo "- Edit example_distributions with your editor                              "
		echo "- Explain sections in that file:                                           "
		echo "  + <osrelease> is an official Ubuntu release name (e.g. xenial or trusty) "
		echo "  + <key-id> is the ID of the GnuPG key you generated. Open another        "
		echo "    terminal, run:                                                         "
		echo "    gpg --list-keys | awk '/^pub/ { print $2 }' | awk -F'/' '{print $2}'   "
		echo "    Get this number and replace <key-id> with this                         "
		echo "***************************************************************************"
		sleep 15
		read -p "Are you ready to config?(Y/n). 'Y' for edit, 'N' for read it again" -n 1 -r
		echo    # (optional) move to a new line
		if [[ $REPLY =~ ^[Yy]$ ]]
		then
			cp example_distributions /var/www/html/repos/owned/conf/distributions
			nano /var/www/html/repos/owned/conf/distributions
			break
		else
			sleep 10
		fi
	done
	cp example_options /var/www/html/repos/owned/conf/options
}

add_owned_pkg_to_repo()
{
	while true
		echo "**********************************************************************************"
		echo "Run command to add your package: reprepro includedeb <osrelease> <path-to-debfile>"
		echo "**********************************************************************************"
		sleep 5
		read -p "Do you want to add more packages?(Y/n)" -n 1 -r
		echo    # (optional) move to a new line
		if [[ $REPLY =~ ^[Yy]$ ]]
		then

			echo -n "Enter your package path and press [ENTER]: "
			read package_path
			osrelease=cat /var/www/html/repos/owned/conf/distributions | awk '/^Codename/ { print $2 }'
			reprepro includedeb $osrelease $package_path
			if [ $? -eq 0 ]
			then
				echo "**********************************************************************************"
				echo " 					   Add $package_path to repo successfully                       "
				echo "**********************************************************************************"
			else
				echo "**********************************************************************************"
				echo "                               		ERROR                                       "
				echo "**********************************************************************************"
				pause_error
		else
			break
		fi
}

export_gnupg_keys()
{
	keyid=gpg --list-keys | awk '/^pub/ { print $2 }' | awk -F'/' '{print $2}'
	gpg --armor --output public.gpg.key --export $keyid
	mv public.gpg.key /var/www/html/repos/owned/conf/
}

main(){
	install_require
	generate_gpg_keys
	configure_apache2
	configure_reprepro
	add_owned_pkg_to_repo
	export_gnupg_keys
	echo "******************************************************************************************"
	echo "                 Done! Now you can install package using this repository              	"
	echo "**Set up client side: 															        "
	echo "wget -O - http://YOUR_REPO_SERVER/repos/owned/conf/public.gpg.key | apt-key add -         "  
 	echo "echo \"deb http://YOUR_REPO_SERVER/repos/owned <osrelease> main\" >> /etc/apt/sources.list"  
 	echo "apt-get update && apt-get install YOUR_PACKAGE  											"
	echo "******************************************************************************************"
}

main