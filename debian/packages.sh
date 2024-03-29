#!/bin/bash

set -euxo pipefail

PACKAGES="
cloud-init
cloud-utils
qemu-guest-agent
systemd-resolved
"
apt-get install -y --no-install-recommends ${PACKAGES}
systemctl enable qemu-guest-agent systemd-resolved
