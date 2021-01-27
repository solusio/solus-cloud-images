#!/bin/bash

set -euxo pipefail

PACKAGES="
cloud-init
cloud-utils-growpart
qemu-guest-agent
shim-x64
grub2-efi-x64
efibootmgr
"

yum -y install ${PACKAGES}

systemctl enable cloud-init.service
systemctl enable qemu-guest-agent

# Creating config for UEFI boot
grub2-mkconfig -o /boot/efi/EFI/centos/grub.cfg
sed -i 's/linux16/linuxefi/g' /boot/efi/EFI/centos/grub.cfg
sed -i 's/initrd16/initrdefi/g' /boot/efi/EFI/centos/grub.cfg
