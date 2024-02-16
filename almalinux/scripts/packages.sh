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
sed -i -e 's/#LogLevel=info/LogLevel=notice/'  /etc/systemd/user.conf

sed -i 's/quiet/console=tty0 console=ttyS0,115200n8/' /etc/default/grub
grub2-mkconfig -o /boot/grub2/grub.cfg

# Creating config for UEFI boot
grub2-mkconfig -o /boot/efi/EFI/almalinux/grub.cfg
sed -i 's/linux16/linuxefi/g' /boot/efi/EFI/almalinux/grub.cfg
sed -i 's/initrd16/initrdefi/g' /boot/efi/EFI/almalinux/grub.cfg
