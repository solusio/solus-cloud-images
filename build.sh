#!/bin/bash
### Copyright 2020 Plesk International GmbH. All rights reserved.

set -euo pipefail

die() {
  echo "ERROR: $*" >&2
  exit 1
}

step() {
  echo
  echo "===> $*"
  echo
}

trap 'cleanup' EXIT

cleanup() {
    if [[ -f "./test_private_key" ]]; then
        rm test_private_key
    fi
    if [[ -n "$opt_cleanup" ]]; then
		rm -rf output/
	fi
}

usage() {
  cat <<-EOT
		Usage:
			$0 <action> <image type> [options]
			$0 build <image type>

		Actions:
			build         Executes Packer to build the specified OS image.

		Supported OS images:
		    debian                      Debian  images
		    fedora                      Fedora  images
		    centos-8                    CentOS 8 images
		    windows-2019                Windows images

        Options:
            --cleanup                   Cleans up the output directory after the build by removing a built OS image. This option may be useful if you transfer the image via scp to another server using the --opt_destination option. After the image was transferred, you may no longer need it in the output directory.
		    --opt_destination=          Transfers a built OS image to another sever via scp, for example: root@10.2.3.4:/. To use this option, you must also set up the SSH_KEY environment variable with a private SSH key of the destination server as the variable value.
		EOT
  exit 2
}

get_arg() {
  local arg=
  local param="$1"
  shift

  case "$param" in
  --*) : ;;
  *)
    arg="$param"
    echo $arg
    ;;
  esac

  while [[ $# -ne 0 ]]; do
    [[ "$arg" != "$1" ]] || return 0
    shift
  done

  return 1
}

get_opt_val()
{
    echo "$*"|awk -F '=' '{print $2}'
}

get_host_val()
{
    echo "$opt_destination"|awk -F ':' '{print $1}'
}

packer_build() {
  local cfg="$1"

  PACKER_LOG=1 packer build $1 || die "check for details build/packer.log"

  return 0
}

do_build() {
  rm -rf ./build
  mkdir -p ./build

  local inten=
  local config=

  case "$opt_type" in
  debian)
    inten="Build debian 8 cloud-init image"
    config="debian/solus-debian-8.json"
    image_path="output/debian"
    [[ ! -d image_path ]] || rm -rf image_path
    ;;
  fedora)
    inten="Build fedora 29 cloud-init image"
    config="fedora/solus-fedora-29.json"
    image_path="output/fedora"
    [[ ! -d image_path ]] || rm -rf image_path
    ;;
  centos-8)
    inten="Build centos 8 cloud-init image"
    config="centos/solus-centos-8.json"
    image_path="output/centos"
    [[ ! -d image_path ]] || rm -rf image_path
    ;;
  windows-2019)
    inten="Build windows server 2019 cloud-based-init image"
    config="windows/windows-2019.json"
    image_path="output/windows"
    [[ ! -d image_path ]] || rm -rf image_path
    if [[ ! -f "./virtio-win.iso" ]]; then
        wget https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/archive-virtio/virtio-win-0.1.173-5/virtio-win.iso
    fi
    ;;
  *)
    echo "An unknown image type $opt_type"
    return 1
    ;;
  esac

  step ${inten}
  packer_build ${config} || return 1

    if [[ -n "$opt_destination" ]]; then
		    do_transfer || return 1
    fi

  return 0
}

do_transfer()
{
	scp -i test_private_key -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -r "$image_path"/* "$opt_destination"
	retVal=$?
		if [[ ! ${retVal} -eq 0 ]]; then
		    exit 1
		fi
	echo "Transferred images from path $image_path to $opt_destination"
}

do_ssh_connection_check()
{
    if [[ -z "${SSH_KEY}" ]]; then
        echo "Provide the SSH private key."
        exit 1
    fi
    if [[ -f "./test_private_key" ]]; then
        rm test_private_key
    fi
    echo "${SSH_KEY}" > test_private_key
    chmod 600 test_private_key
    destination="`get_host_val`"
    ssh -i test_private_key -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$destination"
    retVal=$?
    if [[ ! ${retVal} -eq 0 ]]; then
        echo "can't connect to ${destination} with next private key:\n ${SSH_KEY}"
        exit 1
    fi
    exit
}

[[ $# -eq 0 ]] && usage

# --- parse arguments ---
opt_command=
opt_type=
opt_destination=
image_path=
destination=
opt_cleanup=

image_types_allowed="debian fedora centos-8 windows-2019"
allowed_actions="build"

opt_command="$(get_arg $1 $allowed_actions)"
if [[ $? -ne 0 ]]; then
  echo "Unknown action: $opt_command"
  echo
  usage
fi

shift

if [[ "$opt_command" != "test" ]]; then
  opt_type="$(get_arg $1 $image_types_allowed)"
  if [[ $? -ne 0 ]]; then
    echo "An unknown image type: $opt_type"
    echo
    usage
  fi

  shift
fi

while [[ "$#" -gt 0 ]]; do
    case "$1" in
        -h | --help)
        usage
        ;;
        --destination=*)
            opt_destination="`get_opt_val $1`"
            do_ssh_connection_check
            shift
            ;;
        --cleanup)
            opt_cleanup="yes"
            shift
            ;;
        *)
        echo "An unknown option: $1"
        echo
        usage
        ;;
    esac
done

# --- action ---
FULL_PATH=$(readlink -f $0)
TOP_DIR="$(dirname "$FULL_PATH")"

export SOURCE_DATE_EPOCH="$(date +%s)"

export PACKER_LOG=1
export PACKER_LOG_PATH=build/packer.log

do_${opt_command} || exit 1

step "Finished!"
exit 0
