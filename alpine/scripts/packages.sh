#!/bin/bash

set -euxo pipefail

sed -ie "\$ahttp://dl-cdn.alpinelinux.org/alpine/v3.12/main" /etc/apk/repositories
sed -ie "\$ahttp://dl-cdn.alpinelinux.org/alpine/v3.12/community" /etc/apk/repositories
apk add --update-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing --repository http://dl-cdn.alpinelinux.org/alpine/edge/community --repository http://dl-cdn.alpinelinux.org/alpine/edge/main cloud-init
apk add --update-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing --repository http://dl-cdn.alpinelinux.org/alpine/edge/community --repository http://dl-cdn.alpinelinux.org/alpine/edge/main cloud-utils
apk update
apk upgrade --available
apk add --update-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing cloud-init
