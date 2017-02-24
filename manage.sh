#!/bin/bash

choose_apt()
{
	echo "******************************************************************************************************"
	read -e -p "Do you want setup APT/YUM repo?: " TYPE
	echo "******************************************************************************************************"
	case $TYPE in
		"APT|Apt|apt")
			read -e -p "Setup local APT Repo. Choose your repo type (mirror/generate):  " APT_TYPE
			case $APT_TYPE in
				"Mirror|MIRROR|mirror")
					cd ./apt/mirror/
					chmod +x local_apt_mirror_repos.sh
					sudo ./local_apt_mirror_repos
					;;
				"Generate|GENERATE|generate")
					cd ./apt/generate/
					chmod +x local_owned_apt_generate_repos.sh
					sudo ./local_owned_apt_generate_repos.sh
					;;
			esac
			;;
		"YUM|Yum|yum")
			echo "Setup local YUM Repo "
			cd ./yum/
			chmod +x local_yum_repos.sh
			sudo ./local_yum_repos.sh
			;;
	esac
}

choose_apt