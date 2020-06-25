#!/bin/bash

set -euxo pipefail

configure() {
  [[ -f "/etc/rc.d/rc.local" ]] && rc_local_d="/etc/rc.d" || rc_local_d="/etc"
  mv -f /tmp/rc.local ${rc_local_d}/
  chown root:root ${rc_local_d}/rc.local
  chmod +x ${rc_local_d}/rc.local

  if [[ -f "/usr/bin/apt-get" ]]; then
    mkdir -p /lib/systemd/system/rc-local.service.d
    mv -f /tmp/rc-local.conf /lib/systemd/system/rc-local.service.d/rc-local-afters.conf
  elif [[ -f "/usr/bin/dnf" ]] || [[ -f "/usr/bin/yum" ]]; then
    mv -f /tmp/rc-local-fedora.conf /etc/systemd/system/rc-local.service
  fi
}

configure
