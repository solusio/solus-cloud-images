# SolusIO OS Images Builder

The repository was created by the SolusIO team. 

SolusIO comes with a number of OS images available out of the box.
However you may want to build your own custom OS images (with desired parameters, installed packages, OS versions, and so on).

This repository will help you do so. It contains a number of scripts and configs 
to help you build custom `cloud-init` compatible QEMU/KVM OS images.

## 1. Checking prerequisites

Firstly, check if the management server meets the following requirements:

- Enabled nested virtulization
- Installed `qemu-kvm` package
- Free RAM: minimum 2048 MB (by default)
- Free HDD space: minimum 10 GB 

## 2. Installing Packer

Then you need to install Packer by HashiCorp.

1. Access the management server command line via SSH.
2. Download Packer:

   `curl https://releases.hashicorp.com/packer/1.5.1/packer_1.5.1_linux_amd64.zip`

3. Install Unzip. To do so, run the `apt-get install unzip` or `yum install unzip` command.
4. Unzip the Packer archive by running the `unzip packer_1.5.1_linux_amd64.zip` command.
5. Run the `cp packer /usr/sbin/` command to copy the Packer binary to the `/usr/sbin/` directory.

## 3. Downloading the repository and customizing OS images

1. Download the content of the repository to the management server.
2. The repository contains directories named after OSes whose images you can build (`centos`, `debian`, `fedora`, and so on).
   To customize a future OS image, change the content of the `solus-<custom-image-OS>.json` template file in the corresponding directory
   (for example, the `/centos/solus-centos-8.json` file).

   Examples of possible changes are below: 

   - To change the allocated memory (and most probably decrease the build time of an OS image),
     change the value of the `-m` parameter in `qemuargs`. 
   - To change the output OS image name, output directory, or disk size, change the corresponding parameter in the `"variables"`         section.

   **Note**: The disk size must be larger than the packed image size.

   For more information on customizing an OS image, [read the HashiCorp Packer documentation](https://www.packer.io/docs/index.html).

## 4. Building an OS image

To start building an OS image, run the following command specifying the OS of the image as a parameter:
`./build.sh build debian|fedora|centos-8|windows-2019`

For example, if the image OS is Fedora, run the following command:
`./build.sh build fedora`

You can also launch some additional actions that will be executed with the build:

- To transfer a built OS image to another sever via scp, run `./build.sh` with the `--opt_destination` option, for example:
`./build.sh build fedora --opt_destination=root@10.2.3.4:/`
To use this option, you must also set up the SSH_KEY environment variable with a private SSH key of the destination server as the variable value.
- To clean up the output directory after removing a built OS image, run `./build.sh` with the `--cleanup` option.
This option may be useful if you transfer using the `--opt_destination` option. After the image was transferred, you may no longer need it in the output directory.

## 5. Troubleshooting.

When you have launched the build, we recommend that you to the management server via 



## 5. Checking the result

By default, the `./output` and the `./build` directories will be created during the script execution.
The `./output` directory will contain the output OS image, while the `./build` directory will contain
`packer.log`.

## Additional information

- For correct WinRM work, it is necessary to use SSL connection. It is already set up in the configs.
- To enable Windows updates, uncomment the corresponding code block in `html/Autounattend.xml` and 
  increase the disk size in the `.json` file.




