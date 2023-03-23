#!/bin/bash

set -xe

psa_d="/usr/local/psa"

do_prepare()
{
	## Set hostname (avoid mk_reverse_zone failure)
	hostname localhost.localdomain
	sed -i /etc/hosts -e '/^127.0.0.1/ i \127.0.0.1 localhost.localdomain'

	if [ -f "/etc/centos-release" ]; then
		if ! yum update -y; then
			sleep 120
			yum update -y
		fi

		## Check wget
		which wget >/dev/null 2>&1 || yum install -y wget
	else
		if ! apt-get update; then
			sleep 120
			apt-get update
		fi

		if ! env DEBIAN_FRONTEND=noninteractive apt -y --show-progress -o DPkg::options::="--force-all" upgrade; then
			sleep 120
			env DEBIAN_FRONTEND=noninteractive apt -y --show-progress -o Dpkg::Options::="--force-all" upgrade
		fi

		## Check wget
		which wget >/dev/null 2>&1 || apt-get install -y wget
	fi

	wget http://autoinstall.plesk.com/plesk-installer
	chmod +x plesk-installer

	[ ! -f /tmp/pleskswaprc ] || mv -f /tmp/pleskswaprc /etc/pleskswaprc
}

plesk_install()
{
	local version="$1"
	local preset="$2"
	local with="$3"
	local without="$4"

	ai_args="install plesk $version --preset $preset --tries 9"

	[ -z "$with" ] || ai_args="$ai_args --with $with"
	[ -z "$without" ] || ai_args="$ai_args --without $without"

	env PLESK_INSTALLER_VERBOSE=1 ./plesk-installer $ai_args

	if [ -f "/etc/centos-release" ]; then
		  yum-config-manager --setopt=\*.skip_if_unavailable=1 --save
	else
		  [ ! -f /etc/apt/sources.list.d/plesk.list ] || rm -rf /etc/apt/sources.list.d/plesk.list
	fi

	## Init panel and install default key to get the posiblity to configure some extensions like f2b, mod_security etc..
	plesk bin init_conf --init

	## Use Plesk temporary license key if it requered for some features
	# This key will be deleted at the end
	tempkey_install
}

## Configure psa-firewall
firewall_install()
{
	$psa_d/bin/modules/firewall/settings --enable

	# The ssh connection can be freezed on ubt18 after firewall was enabled.
	# So we should wait before confirm operation.
	sleep 20

	# Firewall confirmation requires the another ssh session.
	# So we do emulate this.
	SSH_CLIENT="127.0.0.1 65535 22" $psa_d/bin/modules/firewall/settings --confirm
}

## Install extensions
extensions_install()
{
	extensions="$*"

	for ext in $extensions; do
		plesk bin extension --install "$ext"
	done
}

# temporary license key is required to enable features like modsecurity or fail2ban
tempkey_install()
{
  if [ -z "$PLESK_TEMPORARY_LICENSE_KEY" ]; then
    return 0
  fi

	# save swkeys data
	rsync -avr /etc/sw/keys/ /etc/sw/keys.saved
	cat >> /usr/local/psa/admin/conf/panel.ini <<-EOT
	[ext-catalog]
	extensionAutoInstall = false
	EOT

	plesk bin license -i "$PLESK_TEMPORARY_LICENSE_KEY"

	rm -f "$PLESK_TEMPORARY_LICENSE_KEY"
}

# Rollback temporary license key
tempkey_rollback()
{
  if [ ! -d /etc/sw/keys.saved ]; then
    return 0
  fi

	mv -f /etc/sw/keys /etc/sw/keys.tmp
	mv -f /etc/sw/keys.saved /etc/sw/keys
	rm -rf /etc/sw/keys.tmp || true
	rm -f /usr/local/psa/admin/conf/panel.ini
}

##----------------------------------------------------------------------------------------------

[ -z "$IS_SOLUS" ] || instance_type="solus"

[ -z "$INSTALL_BYOL" ] || install_type="byol"
[ -z "$INSTALL_BUSINESS" ] || install_type="business"
[ -z "$INSTALL_WEBHOST" ] || install_type="webhost"
[ -z "$INSTALL_WORDPRESS" ] || install_type="wordpress"
[ -z "$INSTALL_LITE" ] || install_type="lite"

if [ -z "$instance_type" -o -z "$install_type" ]; then
	echo "Unknown installation or instance types."
	echo "Please define IS_* and INSTALL_* env variable before continue."
	exit 1
fi

do_prepare

case ${instance_type}_${install_type} in

	solus_byol)
		plesk_install  "$INSTALL_PLESK_VERSION" "$INSTALL_PLESK_PRESET" "$INSTALL_WITH_PLESK_COMPONENTS" "$INSTALL_WITHOUT_PLESK_COMPONENTS"
	;;

	*)
		echo "Unknown installation type: $install_type"
		exit 1
	;;
esac

tempkey_rollback

echo "SOLUSVM2 > $psa_d/var/cloud_id
/usr/local/psa/admin/sbin/nginxmng -d
/usr/local/psa/admin/sbin/nginxmng -e

exit 0
