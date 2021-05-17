#!/bin/bash

set -xe

curl -L "https://securedownloads.cpanel.net/latest" -o /root/setup.sh
hostnamectl set-hostname my.example.com
setenforce 0
systemctl stop NetworkManager
systemctl disable NetworkManager
systemctl enable network.service
systemctl start network.service

sh /root/setup.sh
/usr/local/cpanel/bin/set_hostname my.example.com
/usr/local/cpanel/scripts/configure_firewall_for_cpanel
/usr/local/cpanel/scripts/upcp
/usr/local/cpanel/bin/checkallsslcerts
/usr/local/cpanel/scripts/regenerate_tokens
