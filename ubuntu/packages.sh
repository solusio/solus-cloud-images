#!/bin/bash

set -euxo pipefail

PACKAGES="
tuned
cloud-init
cloud-guest-utils
qemu-guest-agent
"

apt-get install -y --no-install-recommends ${PACKAGES}

systemctl enable cloud-init.service
systemctl enable qemu-guest-agent
systemctl enable tuned
systemctl start tuned
tuned-adm profile virtual-guest
