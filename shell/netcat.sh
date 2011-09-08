#!/bin/sh

# Variables
sudo=/usr/bin/sudo
chroot=/bin/chroot
user=$(id -u)
group=$(id -g)
newroot=/tmp/netcat
netcat=/usr/local/bin/netcat

# Execute
echo -e "Program running [User: $(id -un), Group: $(id -gn)]\n"
$sudo $chroot --userspec=$user:$group $newroot $netcat "$@"
