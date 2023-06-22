#!/bin/bash
######################################################
# These have been moved to the beginning to reduce the delay in getting
# a valid IP address out of whmlogin.
/usr/local/cpanel/scripts/build_cpnat
/usr/local/cpanel/scripts/mainipcheck
if [ -x "/usr/local/cpanel/scripts/ensure_hostname_resolves" ]; then
    /usr/local/cpanel/scripts/ensure_hostname_resolves -y
fi
/usr/local/cpanel/scripts/check_valid_server_hostname
/usr/local/cpanel/scripts/mkwwwacctconf --reset
# whmlogin checks for this file and waits until it's gone to spit out
# a login URL.
rm -f /var/cpanel/cpinit-ip.wait
######################################################
# It should already be stopped, but this is an extra precaution
yum -y install mysql-community-server
systemctl stop mysqld
MYCNF=/root/.my.cnf
if [ -f $MYCNF ]; then
    echo "WARNING: $MYCNF already exists."
    rm -f $MYCNF
fi
DBDIR=/var/lib/mysql
if [ -e $DBDIR ]; then
    echo "WARNING: $DBDIR already exists."
    mv $DBDIR ${DBDIR}.bak
fi
/usr/local/cpanel/bin/build_mysql_conf
/usr/local/cpanel/scripts/mysqlconnectioncheck
######################################################
pdns_conf=/etc/pdns/pdns.conf
if [ -f $pdns_conf.TEMPLATE ]; then
    apikey=`openssl rand -hex 18`
    webpass=`openssl rand -hex 18`
    cp -pf $pdns_conf.TEMPLATE $pdns_conf
    sed -i \
        -e 's/^###api=yes/api=yes/' \
        -e "s/^###api-key=REPLACE/api-key=$apikey/" \
        -e "s/^###webserver-password=REPLACE/webserver-password=$webpass/" \
        $pdns_conf
    unset apikey
    unset webpass
    /usr/local/cpanel/scripts/restartsrv_pdns
fi
unset pdns_conf
######################################################
/usr/local/cpanel/bin/hulkdsetup
dovecot_key=`cat /var/cpanel/cphulkd/keys/dovecot`
sed -i "s/^###auth_policy_server_api_header = .*/auth_policy_server_api_header = X-API-Key:dovecot:$dovecot_key/" /etc/dovecot/auth_policy.conf
unest dovecot_key
/usr/local/cpanel/scripts/restartsrv_cphulkd
/usr/local/cpanel/scripts/restartsrv_dovecot
######################################################
/usr/local/cpanel/bin/mmpass > /dev/null
# Regenerate default list
rpm -e --nodeps cpanel-mailman
/usr/local/cpanel/scripts/check_cpanel_rpms --fix --targets mailman
######################################################
srs_conf=/var/cpanel/exim_hidden/srs_config
# See libsrs_alt/MTAs/README.EXIM for allowed lengths and characters.
# 21 binary bytes translates to 28 base64 digits, which is within the acceptable range.
srs_secret=`head -c21 /dev/urandom | base64`
# s,,, instead of s/// because replacement may contain slashes but will never contain commas.
sed -Ei \
  -e 's/^##(SRSENABLED=1).*$/\1/' \
  -e 's,^##(hide srs_config =).*$,\1 '${srs_secret}':60:6,' \
  $srs_conf
unset srs_secret
unset srs_conf
######################################################
/usr/local/cpanel/3rdparty/bin/perl -Mstrict -w -MCpanel::ServiceAuth -e '
    opendir my $dh, "/var/cpanel/serviceauth";
    while ( my $entry = readdir $dh ) {
        next if $entry =~ /^\.\.?$/;
        Cpanel::ServiceAuth->new($entry)->generate_authkeys_if_missing();
    }
    closedir $dh;
'
(
    cd /var/cpanel/serviceauth
    for service in *; do
        script=/usr/local/cpanel/scripts/restartsrv_$service
        if [ -x $script ]; then
            $script
        fi
        unset script
    done
)
######################################################
/usr/local/cpanel/scripts/fixetchosts
/usr/local/cpanel/bin/dbindex
/usr/local/cpanel/scripts/update_db_cache
/usr/local/cpanel/scripts/rebuildhttpdconf
/usr/local/cpanel/bin/checkallsslcerts --allow-retry
/usr/local/cpanel/scripts/upcp --force
/usr/local/cpanel/scripts/restartsrv_cpsrvd
######################################################
echo "1" > /var/cpanel/cpinit.done