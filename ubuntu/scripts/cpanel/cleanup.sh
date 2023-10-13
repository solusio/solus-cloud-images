#!/bin/bash

set -euxo pipefail

clean_garbage()
{
	# Clean package manager caches
	if [[ -f "/usr/bin/apt-get" ]]; then
		if ! apt-get clean; then
			sleep 120
			apt-get clean
		fi
		rm -rf /var/lib/apt/lists/*
	fi

	if [[ -f "/usr/bin/yum" ]]; then
		yum clean all
		rm -rf /var/cache/yum /var/tmp/yum-*
	fi

	if [[ -f "/usr/bin/dnf" ]]; then
		dnf clean all
	fi

	echo "==> Cleaning up leftover dhcp leases"
	if [[ -d "/var/lib/dhcp" ]]; then
		rm -rf /var/lib/dhcp
	fi

  	# Remove default network configs
  	rm -f /etc/sysconfig/network-scripts/ifcfg-ens3

	# Clean /tmp
	rm -rf /tmp/*

	# Clean SSH Host Key Pairs
	rm -rf /etc/ssh/*_key /etc/ssh/*_key.pub

	if [[ -d /root/.ssh ]]; then
		# Clean keys for root user
		rm -f /root/.ssh/authorized_keys

		echo -n > /root/.ssh/known_hosts
		chmod 0644 /root/.ssh/known_hosts
	fi

  	# Lock root password
  	passwd -l root

	# Clean up log files
	find /var/log -type f | while read f; do echo -ne '' > ${f}; done;

	# Clean evidences of your activity
	echo -n > /root/.bash_history

	# We do not clean /etc/resolv.conf because cPanel supports only PowerDNS for nameserver on Ubuntu 20.04 https://docs.cpanel.net/installation-guide/system-requirements-ubuntu/#nameservers
	# During cPanel installation systemd-resolved (default Ubuntu resolver) is disabled and content of /etc/resolv.conf is replaced with 8.8.8.8 and 1.1.1.1 nameservers.
	# This behaviour was reported on a cPanel forum https://forums.cpanel.net/threads/install-issue-dns-changing.712857/

}

clean_garbage
