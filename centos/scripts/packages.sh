#!/bin/bash

set -euxo pipefail

PACKAGES="
cloud-init
cloud-utils-growpart
qemu-guest-agent
"

yum -y install ${PACKAGES}

systemctl enable cloud-init.service
systemctl enable qemu-guest-agent
