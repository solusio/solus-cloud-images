set -xe

apt -y install perl perl-base

curl -L "https://securedownloads.cpanel.net/latest" -o /root/setup.sh
hostnamectl set-hostname my.example.com
systemctl stop ufw.service
systemctl disable ufw.service

sh /root/setup.sh
/usr/local/cpanel/bin/set_hostname my.example.com
/usr/local/cpanel/scripts/upcp
/usr/local/cpanel/bin/checkallsslcerts
/usr/local/cpanel/scripts/regenerate_tokens
