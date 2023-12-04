#!/bin/bash

set -euxo pipefail

configure() {
  [[ -f "/etc/rc.d/rc.local" ]] && rc_local_d="/etc/rc.d" || rc_local_d="/etc"
  mv -f /tmp/rc.local ${rc_local_d}/
  chown root:root ${rc_local_d}/rc.local
  chmod +x ${rc_local_d}/rc.local

  mv -f /tmp/rc-local.conf /etc/systemd/system/rc-local.service
}

configure
