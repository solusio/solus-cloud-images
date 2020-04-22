# SolusIO OS images builder

The repository was created by the SolusIO team. 

SolusIO comes with a number of OS images available out of the box.
However you may want to build your own custom OS images (with desired parameters, installed packages, OS versions, and so on).

This repository will help you do so. It contains a number of scripts and configs 
to help you build custom `cloud-init` compatible QEMU/KVM OS images.


## 1. Installing Packer

Firstly, you need to install HashiCorp Packer.

1. Access the management server command line via SSH.
2. Download Packer:

   `curl https://releases.hashicorp.com/packer/1.5.1/packer_1.5.1_linux_amd64.zip`

3. Install Unzip. To do so, run the `apt-get install unzip` or `yum install unzip` command.
4. Unzip the Packer archive by running the `unzip packer_1.5.1_linux_amd64.zip` command.
5. Run the `cp packer /usr/sbin/` command to copy the Packer binary to the `/usr/sbin/` directory.

## 2. Checking prerequisites

Check if the management server meets the following requirements:

- Enabled nested virtulization
- Installed `qemu-kvm` package
- Free RAM: minimum 2048 MB (by default)
- Free HDD space: minimum 10 GB 

## 3. Downloading the repository and customizing OS images

1. Download the content of the repository to the management server.
2. The repository contains directories named after OSes whose images you can build (`centos`, `debian`, `fedora`, and so on).
   To customize a future OS image, change the content of the `solus-<custom-image-OS>.json` file in the corresponding directory
   (for example, the `/centos/solus-centos-8.json` file).

   Examples of possible changes are below: 

   - To change the allocated memory (and most probably decrease the build time of an OS image),
     change the value of the `-m` parameter in `qemuargs`. 
   - To change the output OS image name, output directory, or disk size, change the corresponding parameter in the `"variables"` section.

   **Note**: The disk size must be larger than the packed image size.

   For more information on customizing an OS image, [read the HashiCorp Packer documentation](https://www.packer.io/docs/index.html).

## 4. Building a custom image

Building a custom OS image differs depending on the OS of the management server 
and the OS of the image that you want to build.

### Debian images

To build a Debian OS image:

1. If the management server OS is CentOS 7, add the following line to the `debian/solus-debian-8.json` file under the `"builders"` section:

   `"qemu_binary": "/usr/libexec/qemu-kvm",`

   If the management server OS is not CentOS 7, skip this step and go to the next one.

2. Run `./build.sh build debian`.

### Fedora images

To build a Fedora OS image:

1. If the management server OS is CentOS 7, add the following line to the `fedora/solus-fedora-29.json` file under the `"builders"` section:

   `"qemu_binary": "/usr/libexec/qemu-kvm",`

   If the management server OS is not CentOS 7, skip this step and go to the next one.

2. Run `./build.sh build fedora`.

### CentOS images

To build a CentOS OS image:

1. If the management server OS is CentOS 7, add the following line to the `centos/solus-centos-8.json` file under the `"builders"` section:

   `"qemu_binary": "/usr/libexec/qemu-kvm",`

   If the management server OS is not CentOS 7, skip this step and go to the next one.

2. Run `/build.sh build centos-8`.

### Windows images

To build a Windows OS image:

1. If the management server OS is CentOS 7, add the following line to the `windows/windows.json` file under the `"builders"` section:

   `"qemu_binary": "/usr/libexec/qemu-kvm",`

   If the management server OS is not CentOS 7, skip this step and go to the next one.

2. Run `./build.sh build windows-2019`.

## 5. Checking the result

By default, the `./output` and the `./build` directories will be created during the script execution.
The `./output` directory will contain the output OS image, while the `./build` directory will contain
`packer.log`.

## Additional information

- For correct WinRM work, it is necessary to use SSL connection. It is already set up in the configs.
- To enable Windows updates, uncomment the corresponding code block in `html/Autounattend.xml` and 
  increase the disk size in the `.json` file.




