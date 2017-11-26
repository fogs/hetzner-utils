#!/bin/bash

# Get IP from default interface and perform reverse lookup for getting the actual hostname
default_route=$(route -n | grep 0.0.0.0)
default_nic=${default_route##* }
main_ip=$(ifconfig $default_nic | grep "inet addr" | awk -F ':' '{ print $2}' | awk '{ print $1 }')
servername=$(host -t PTR $main_ip)
servername=${servername##* }
servername=${servername::-1}
test -z $servername && echo "No hostname found for $main_ip. Setup Reverse DNS Name for this server in the Hetzner Robot. Exiting" && exit 2

# Install a post-install script, to be run within the chroot after install completed
cat << 'EOF' > post.sh
#!/bin/bash

# Install all system updates plus some basic applications
apt update
apt dist-upgrade -y
apt install -y command-not-found software-properties-common moreutils apg mc language-pack-de-base

# Enable Intel's IOMMU by default
sed '/GRUB_CMDLINE_LINUX=/c\GRUB_CMDLINE_LINUX="intel_iommu=on"' /etc/default/grub -i
update-grub2

# Allow searching the Bash history using page-up / page-down
sed -i 's;# "\\e\[5~": history-search-backward;"\\e\[5~": history-search-backward;' /etc/inputrc
sed -i 's;# "\\e\[6~": history-search-forward;"\\e\[6~": history-search-forward;' /etc/inputrc

# Make Bash a bit more handy
cat << 'ENDOFFILE' > /root/.bashrc
# ~/.bashrc: executed by bash(1) for non-login shells.

#export PS1='\h:\w\$ '
export PS1='\[\033[01;31m\]\u\[\033[01;33m\]@\[\033[01;32m\]\h \[\033[01;33m\]\w \[\033[01;35m\]\$ \[\033[00m\]'
umask 022

export LS_OPTIONS='--color=auto -h'
eval "`dircolors`"

alias ls='ls $LS_OPTIONS'
alias ll='ls $LS_OPTIONS -l'
alias l='ls $LS_OPTIONS -lA'
alias ..='cd ..'
alias ...='cd ../..'
ENDOFFILE
cp /root/.bashrc /etc/skel/
EOF
chmod 755 post.sh

# Install Ubuntu 16.04 and run above post-install script
installimage \
-a \
-n $servername \
-b grub \
-r yes \
-l 1 \
-i /root/.oldroot/nfs/images/Ubuntu-1604-xenial-64-minimal.tar.gz \
-p /boot:ext2:1G,lvm:vg0:16G \
-d sda,sdb \
-t yes \
-v vg0:root:/:ext4:4G,vg0:tmp:/tmp:ext4:4G,vg0:var:/var:ext4:4G \
-x post.sh \
&& reboot
