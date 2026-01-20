#!/bin/bash

set -euxo pipefail

PACKAGES="
cloud-init-22.4.2
cloud-utils
qemu-guest-agent
netcat-openbsd
net-tools
resolvconf
"
apt-get install -y --no-install-recommends ${PACKAGES}
systemctl enable qemu-guest-agent
