#!/bin/bash
# Don't touch the user's keyring, have our own instead
export GNUPGHOME=/root/keyrings/ubuntu

# Architecture. For Ubuntu can be i386, powerpc or amd64.
arch=i386,amd64

# Minimum Ubuntu system requires main, restricted
# Section (One of the following - main/restricted/universe/multiverse).
section=main,multiverse,universe,restricted

# Release of the system (Quantal, Precise, etc)
release=xenial,xenial-updates,xenial-security,xenial-backports,xenial-proposed

# Server name, minus the protocol and the path at the end
server=vn.archive.ubuntu.com

# Path from the main server, so http://my.web.server/$dir, Server dependant
inPath=/ubuntu

# Protocol to use for transfer (http, ftp, hftp, rsync)
proto=rsync

# Directory to store the mirror in
outPath=/var/www/html/repos/ubuntu/

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