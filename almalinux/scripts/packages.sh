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

systemctl disable NetworkManager-wait-online.service
systemctl mask NetworkManager-wait-online.service

# Creating config for UEFI boot
grub2-mkconfig -o /boot/efi/EFI/almalinux/grub.cfg
sed -i 's/linux16/linuxefi/g' /boot/efi/EFI/almalinux/grub.cfg
sed -i 's/initrd16/initrdefi/g' /boot/efi/EFI/almalinux/grub.cfg
