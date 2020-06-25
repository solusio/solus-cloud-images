#!/bin/bash

set -euxo pipefail

clean_garbage()
{
    rm -rf /var/cache/apk/*

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

	# Clean up log files
	find /var/log -type f | while read f; do echo -ne '' > ${f}; done;

	# Clean evidences of your activity
	echo -n > /root/.bash_history

}

clean_garbage
