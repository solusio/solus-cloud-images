#!/bin/bash

set -euxo pipefail

sed -ie "\$ahttp://dl-cdn.alpinelinux.org/alpine/v3.15/main" /etc/apk/repositories
sed -ie "\$ahttp://dl-cdn.alpinelinux.org/alpine/v3.15/community" /etc/apk/repositories
apk update
apk upgrade --available
apk add --no-cache cloud-init cloud-utils qemu-guest-agent
# According to https://git.alpinelinux.org/aports/tree/community/cloud-init/README.Alpine
# After the cloud-init package is installed you will need to run the
# "setup-cloud-init" command to prepare the OS for cloud-init use.
setup-cloud-init

# Alpine qemu-guest-agent has invalid path to socket, fix it.
sed -i 's/#GA_PATH=.*$/GA_PATH="\/dev\/vport2p1"/' /etc/conf.d/qemu-guest-agent
rc-update add qemu-guest-agent
rc-service qemu-guest-agent restart
