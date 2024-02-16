#!/bin/bash

clear_user() {
  rm -f /etc/sudoers.d/*
  for user in almalinux; do
    userdel --force --remove "$user" || passwd -l "$user" || true
    rm -rf "/home/$user/"
  done
}

cpanel_regenerate_token() {
  /usr/local/cpanel/scripts/regenerate_tokens
}

cpanel_post_install() {
  sh /root/run_scripts.sh
}

clean_up() {
  rm -rf /etc/execute-once.sh

  systemctl disable cloud-image-execute-once.service
  systemctl stop cloud-image-execute-once.service
  rm -rf /etc/systemd/system/cloud-image-execute-once.service
  rm -rf /etc/subgid.lock
}

clear_user
cpanel_regenerate_token
cpanel_post_install
clean_up
