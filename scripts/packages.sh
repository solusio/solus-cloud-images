#!/bin/bash

set -euxo pipefail

PACKAGES="
cloud-init
cloud-utils-growpart
qemu-guest-agent
"
if [[ -f "/usr/bin/apt-get" ]]; then
  apt-get install -y --no-install-recommends ${PACKAGES}
fi

if [[ -f "/usr/bin/dnf" ]]; then
  #Uncomment this for fedora 30 build untill the bug is not being fixed https://bugzilla.redhat.com/show_bug.cgi?id=1706627
  #echo "zchunk=False">>/etc/dnf/dnf.conf
  dnf -y install ${PACKAGES}
  systemctl enable cloud-init.service
fi

systemctl enable qemu-guest-agent
