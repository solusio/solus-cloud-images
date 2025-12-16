# Ensure you're using latest packer version to get plugins working
packer {
  required_plugins {
    qemu = { source = "github.com/hashicorp/qemu", version = ">= 1.1.0" }
  }
}

source "qemu" "opensuse16" {
  iso_url       = "https://download.opensuse.org/distribution/leap/16.0/offline/Leap-16.0-offline-installer-x86_64.install.iso"
  iso_checksum  = "d780a228058fb4688a31b5bde22d7b97c86e04a2ced33f3d7c8e88a710d96d24"

  accelerator    = "kvm"
  headless       = true
  cpus           = 2
  memory         = 4096
  disk_size      = "6G"
  format         = "qcow2"
  vm_name        = "opensuse16-svm2.qcow2"
  output_directory = "output/opensuse"

  http_directory = "opensuse/http"
  communicator   = "ssh"

  vnc_port_min = 5981
  vnc_port_max = 5981

  host_port_min = 2222
  host_port_max = 4444

  ssh_username = "root"
  ssh_password = "linux"
  ssh_timeout = "15m"

  # Replace paths with your values based on existing
  # firmware in OS where packer is installed
  # Install edk2-ovmf or ovmf package if necessary
  efi_firmware_code = "/usr/share/OVMF/OVMF_CODE_4M.fd"
  efi_firmware_vars = "/usr/share/OVMF/OVMF_VARS_4M.fd"

  qemuargs = [
    ["-cpu", "host"]
  ]

  boot_command = [
    "<wait>","<down><wait>","e","<down><down><down><down><end> ",
    "inst.auto=http://{{ .HTTPIP }}:{{ .HTTPPort }}/opensuse16-profile.json agama.shutdown=poweroff console=ttyS0,115200n8<enter>",
    "<f10>"
  ]
  disk_compression = true
  shutdown_timeout = "20m"
  shutdown_command = "/sbin/shutdown -hP now"
}

build {
  sources = ["source.qemu.opensuse16"]

  post-processor "shell-local" {
    inline = [
      "virt-sysprep -a out/opensuse16-svm2.qcow2 --operations bash-history,logfiles,tmp-files,ssh-hostkeys,machine-id,net-hwaddr,net-hostname,udev-persistent-net"
    ]
  }
}