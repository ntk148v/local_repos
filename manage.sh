#!/bin/bash

choose_apt()
{
	read -p "## Do you want setup APT/YUM repo?: " TYPE
	case $TYPE in
		APT|Apt|apt)
			read -e -p "## Setup local APT Repo. Choose your repo type (mirror/generate):  " APT_TYPE
			case $APT_TYPE in
				Mirror|MIRROR|mirror)
					echo "## Setup local APT Repo mirror ##"
					cd ./apt/mirror/
					chmod +x local_apt_mirror_repos.sh
					sudo bash ./local_apt_mirror_repos
					;;
				Generate|GENERATE|generate)
					echo "## Setup local APT Repo generate ##"
					cd ./apt/generate/
					chmod +x local_owned_apt_generate_repos.sh
					sudo bash ./local_owned_apt_generate_repos.sh
					;;
			esac
			;;
		YUM|Yum|yum)
			echo "## Setup local YUM Repo ##"
			cd ./yum/
			chmod +x local_yum_repos.sh
			sudo bash ./local_yum_repos.sh
			;;
	esac
}

choose_apt
