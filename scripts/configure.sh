#!/bin/bash

set -euxo pipefail

configure() {
  [[ -f "/etc/rc.d/rc.local" ]] && rc_local_d="/etc/rc.d" || rc_local_d="/etc"
  mv -f /tmp/rc.local ${rc_local_d}/
  chown root:root ${rc_local_d}/rc.local
  chmod +x ${rc_local_d}/rc.local

  if [[ -f "/usr/bin/apt-get" ]]; then
    mkdir -p /lib/systemd/system/rc-local.service.d
    mv -f /tmp/rc-local-debian.conf /lib/systemd/system/rc-local.service.d/rc-local-afters.conf
  elif [[ -f "/usr/bin/dnf" ]] || [[ -f "/usr/bin/yum" ]]; then
    mv -f /tmp/rc-local-fedora.conf /etc/systemd/system/rc-local.service
  fi
}

setup_fedora() {
  if [[ -f "/usr/bin/apt-get" ]]; then
    exit 0
  fi

  systemctl disable NetworkManager.service
  systemctl enable network
  systemctl enable rc-local
  if [[ -f "/etc/sysconfig/network-scripts/ifcfg-ens3" ]]; then
    rm /etc/sysconfig/network-scripts/ifcfg-ens3
  fi

  sed -i -e 's/\<quiet\>/& net.ifnames=0 biosdevname=0/' /etc/default/grub
  grub2-mkconfig -o /boot/grub2/grub.cfg
}

configure
setup_fedora
