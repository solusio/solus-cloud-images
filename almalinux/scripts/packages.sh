#!/bin/bash

set -eux

PACKAGES="
cloud-init
cloud-utils-growpart
qemu-guest-agent
shim-x64
grub2-efi-x64
efibootmgr
"

dnf -y install ${PACKAGES} || dnf -y install ${PACKAGES} # https://bugzilla.redhat.com/show_bug.cgi?id=1714706

systemctl enable cloud-init.service
systemctl enable qemu-guest-agent

systemctl disable NetworkManager-wait-online.service
systemctl mask NetworkManager-wait-online.service

systemctl enable serial-getty@ttyS0.service

# Logs flooded with systemd messages: Created slice, Starting Session https://access.redhat.com/solutions/1564823
# Supposedly this issue does not affect Alma 10, lets skip it if file does not exist.
if [ -e /etc/systemd/user.conf ]; then
	sed -i -e 's/#LogLevel=info/LogLevel=notice/'  /etc/systemd/user.conf
fi

sed -i 's/quiet/console=tty0 console=ttyS0,115200n8/' /etc/default/grub
grub2-mkconfig -o /boot/grub2/grub.cfg

# Disable kdump service
systemctl mask kdump
systemctl disable kdump
# Remove crashkernel=1G-4G:192M,4G-64G:256M,64G-:512M from /boot/loader/entries/
grubby --remove-args="crashkernel" --update=ALL
