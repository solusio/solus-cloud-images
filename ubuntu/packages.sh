#!/bin/bash

set -euxo pipefail

PACKAGES="
tuned
cloud-init
cloud-guest-utils
"

apt-get install -y --no-install-recommends ${PACKAGES}

systemctl enable cloud-init.service
systemctl enable tuned
systemctl start tuned
tuned-adm profile virtual-guest
