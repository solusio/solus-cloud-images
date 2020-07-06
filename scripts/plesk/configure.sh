#!/bin/bash -xe

reset_mysql_passwd()
{
    [ -f "/etc/mysql/debian.cnf" ] || return 0

    sed -i 's|^\(password[[:space:]]*=\).*|\1|g' /etc/mysql/debian.cnf
}

configure_image()
{

	# Plesk creates .plesk_banner in plesk-core package but
	# some images has custom motd which do not require default banner
	[ -f "/tmp/.plesk_banner_remove" ] && rm -f /tmp/.plesk_banner_remove && rm -f /root/.plesk_banner || :

	# Other images replace default banner
	[ ! -f "/tmp/.plesk_banner" ] || mv -f /tmp/.plesk_banner /root/.plesk_banner

	[ -f "/tmp/pl.sh" ] && mv -f /tmp/pl.sh /root/pl.sh && chmod +x /root/pl.sh || :

	[ ! -f "/tmp/plesk-login-link.service" ] || rm -f /tmp/plesk-login-link.service

	[ ! -f "/tmp/plesk_site_preview.conf" ] || mv -f /tmp/plesk_site_preview.conf /etc/sw-cp-server/conf.d/plesk_site_preview.conf

	# Decrease password strength
	plesk bin server_pref -u -min_password_strength very_weak

	# Prepare image for cloning
	plesk bin cloning -u -prepare-public-image true -reset-license true -reset-init-conf true -skip-update true -update-master-key "${UPDATE_MASTER_KEY:-false}" -maintenance true

	# First execution of ipmanage can be soo long.
	# Expecially if docker was installed.
	# So we are trying to reduce first boot time by means of this construction here
	plesk bin ipmanage --reread

	# Remap ip addresses after reboot an instance automatically
	plesk bin ipmanage --auto-remap-ip-addresses true

	# Clean-up default password for deb-based images
	reset_mysql_passwd

	# Install an image ID: required for KA reports.
	date +"%D %H:00:00 %z" > $psa_d/.image-buildtime
	mv -f /tmp/.image-revision $psa_d/.image-revision

	# Reset the unique machine dependent ID
	true > /etc/machine-id

	# Install custom motd, remove ubuntu-specific motds
	if [ -f "/tmp/motd" ]; then
		mv -f "/tmp/motd" /etc/motd
		: > /etc/legal
		if [ -d "/etc/update-motd.d" ]; then
			chmod -x /etc/update-motd.d/10-help-text /etc/update-motd.d/51-cloudguest || :
			mv -f /tmp/11-link-to-plesk /etc/update-motd.d/ || :
			chmod 0755 /etc/update-motd.d/11-link-to-plesk || :
		fi
	else
		: > /etc/motd
	fi

	touch /root/firstrun
}

configure_image
