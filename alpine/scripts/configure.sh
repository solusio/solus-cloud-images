#!/bin/bash

set -euxo pipefail

rc-update add local boot
mkdir -p /etc/local.d
mv -f /tmp/local.start /etc/local.d/local.start
chmod 755 /etc/local.d/local.start
