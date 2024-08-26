#!/bin/bash

set -xe

hostnamectl set-hostname my.example.com
setenforce 0

# https://support.cpanel.net/hc/en-us/articles/360052251053-How-to-Install-a-Specific-Version-of-cPanel-WHM
echo "CPANEL=$INSTALL_CPANEL_VERSION
RPMUP=daily
SARULESUP=daily
STAGING_DIR=/usr/local/cpanel
UPDATES=daily" > /etc/cpupdate.conf

curl -L "https://securedownloads.cpanel.net/latest" -o /root/setup.sh

sh /root/setup.sh
/usr/local/cpanel/bin/set_hostname my.example.com
/usr/local/cpanel/scripts/configure_firewall_for_cpanel
/usr/local/cpanel/scripts/upcp
touch /var/cpanel/ssl/disable_auto_hostname_certificate # https://docs.cpanel.net/whm/scripts/the-checkallsslcerts-script/
/usr/local/cpanel/bin/checkallsslcerts
/usr/local/cpanel/scripts/regenerate_tokens
