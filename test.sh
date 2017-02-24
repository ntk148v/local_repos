#!/bin/bash

fun1()
{
    read -p "Enter directory path to storage trustedkeys.gpg(For e.x:/home/$USER/keyrings/ubuntu_cloud): " UBUNTU_CLOUD_KEYRING
    #UBUNTU_CLOUD_KEYRING=${UBUNTU_CLOUD_KEYRING%/}
    case $UBUNTU_CLOUD_KEYRING in *[!/]*/) UBUNTU_CLOUD_KEYRING=${UBUNTU_CLOUD_KEYRING%"${UBUNTU_CLOUD_KEYRING##*[!/]}"};; esac
    echo $UBUNTU_CLOUD_KEYRING
}

fun2()
{
    KEYID=$(gpg --list-keys | awk '/^pub/ { print $2 }' | awk -F'/' '{print $2}')
    echo $KEYID
}

fun2
