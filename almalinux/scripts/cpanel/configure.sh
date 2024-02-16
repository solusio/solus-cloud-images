#!/bin/bash

set -euxo pipefail

configure() {
  SCRIPT_TARGET_FILE=/etc/execute-once.sh
  mv -f /tmp/execute-once.sh $SCRIPT_TARGET_FILE
  chown root:root $SCRIPT_TARGET_FILE
  chmod +x $SCRIPT_TARGET_FILE

  mv -f /tmp/cloud-image-execute-once.service /etc/systemd/system/cloud-image-execute-once.service
  systemctl enable cloud-image-execute-once.service
}

configure

passwd -l almalinux || true
