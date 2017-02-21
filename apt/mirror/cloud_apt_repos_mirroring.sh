#!/bin/bash
# Don't touch the user's keyring, have our own instead
export GNUPGHOME=/root/keyrings/ubuntu_cloud

# Architecture. For Ubuntu can be i386, powerpc or amd64.
arch=i386,amd64

# Minimum Ubuntu system requires main, restricted
# Section (One of the following - main/restricted/universe/multiverse).
section=main

# Release of the system (Quantal, Precise, etc)
release=xenial-proposed/newton,xenial-updates/newton,trusty-updates/mitaka,trusty-updates/liberty,\
        trusty-updates/kilo,trusty-updates/juno,trusty-proposed/liberty,trusty-proposed/kilo,\
        trusty-proposed/juno,trusty-proposed/mitaka,

# Server name, minus the protocol and the path at the end
server=ubuntu-cloud.archive.canonical.com

# Path from the main server, so http://my.web.server/$dir, Server dependant
inPath=/ubuntu

# Protocol to use for transfer (http, ftp, hftp, rsync)
proto=http

# Directory to store the mirror in
outPath=/var/www/html/repos/cloud/

# Start script

debmirror   -a $arch \
            --no-source \
            --md5sums \
            --progress \
            --passive \
            --verbose \
            -s $section \
            -h $server \
            -d $release \
            -r $inPath \
            -e $proto \
            $outPath