#!/bin/bash -xe

clean_garbage()
{
	# Clean package manager caches
	if [ -f "/usr/bin/apt-get" ]; then
		if ! apt-get clean; then
			sleep 120
			apt-get clean
		fi
		rm -rf /var/lib/apt/lists/*
	fi

	if [ -f "/usr/bin/yum" ]; then
		yum clean all
		rm -rf /var/cache/yum /var/tmp/yum-*
	fi

	# Clean /tmp
	rm -rf /tmp/cache_* /tmp/horde_cache_gc /tmp/11-link-to-plesk /tmp/*.zip

	# Clean feedback agreement flags
	rm -f /var/parallels/feedback-enabled
	rm -f /var/parallels/feedback-disabled

	# Clean SSH Host Key Pairs
	rm -rf /etc/ssh/*_key /etc/ssh/*_key.pub

	if [ -d /root/.ssh ]; then
		# Clean keys for root user
		rm -f /root/.ssh/authorized_keys

		echo -n > /root/.ssh/known_hosts
		chmod 0644 /root/.ssh/known_hosts
	fi

  # Lock root password
  passwd -l root

	# Clean some logfiles and welcome message
	echo -n > /var/log/maillog
	echo -n > /var/log/messages
	[ ! -f /var/log/plesk/panel.log ] || : > /var/log/plesk/panel.log

	# remove plesk-installer
	rm -rf /root/plesk-installer /root/parallels /var/cache/parallels_installer

	# remove swap file configuration
	rm -f /etc/pleskswaprc

	local logfiles="alternatives.log auth.log bootstrap.log dpkg.log fontconfig.log kern.log mail.log cloud-init.log cloud-init-output.log php7.2-fpm.log"
	for f in $logfiles; do
		[ ! -f "/var/log/$f" ] || rm -f /var/log/$f
	done
	# failban.log should not be removed, because fail2ban refuses to start with 
	# enable recidieve jail in such case
	echo -n > /var/log/fail2ban.log

	# Clean evidences of your activity
	echo -n > /root/.bash_history
}

clean_garbage
