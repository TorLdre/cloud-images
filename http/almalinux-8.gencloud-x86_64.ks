# AlmaLinux 8 kickstart file for Generic Cloud (OpenStack) image

url --url https://repo.almalinux.org/almalinux/8/BaseOS/x86_64/kickstart/
repo --name=BaseOS --baseurl=https://repo.almalinux.org/almalinux/8/BaseOS/x86_64/os/
repo --name=AppStream --baseurl=https://repo.almalinux.org/almalinux/8/AppStream/x86_64/os/

text
skipx
eula --agreed
firstboot --disabled

lang en_US.UTF-8
keyboard us
timezone UTC --isUtc

network --bootproto=dhcp
firewall --enabled --service=ssh
services --disabled="kdump" --enabled="chronyd,rsyslog,sshd"
selinux --enforcing

# Partitioning and bootloader configuration
# Note: biosboot and efi partitions are pre-created in %pre.
# TODO: remove "console=tty0" from here
bootloader --append="console=ttyS0,115200n8 console=tty0 crashkernel=auto net.ifnames=0 no_timer_check" --location=mbr --timeout=1
mount /dev/sda1 / --reformat=xfs
mount /dev/sda15 /boot/efi --reformat=efi

%pre --log=/var/log/anaconda/pre-install.log --erroronfail
#!/bin/bash

# Pre-create the EFI partition
#  - Ensure that efi is created at the start of the disk to
#    allow resizing of the OS disk.
#  - Label biosboot and efi as sda14/sda15 for better compat - some tools
#    may assume that sda1/sda2 are '/boot' and '/' respectively.
sgdisk --clear /dev/sda
sgdisk -n 15:1MiB:200MiB -t 15:EF00 -c 15:"EFI System Partition" /dev/sda
sgdisk -n 1:0:+4000MiB -t 1:8300 /dev/sda

%end

rootpw --plaintext almalinux

reboot --eject


%packages
@core
grub2-efi-x64
-biosdevname
-open-vm-tools
-plymouth
-dnf-plugin-spacewalk
-rhn*
-iprutils
-iwl*-firmware
%end


# disable kdump service
%addon com_redhat_kdump --disable
%end


%post
%end
