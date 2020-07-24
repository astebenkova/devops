#!/bin/bash

# Pre-defined variables
MEM_SIZE=512
VCPUS=1
DISK_SIZE=5
# none, spice, vnc
GRAPHICS=none
VM_NAME=ubuntu_$(date +"%d%m%Y_%H%M")_preseed
IMAGE_FILE="/var/lib/libvirt/images/basic_images/ubuntu-16.04.6-server-amd64.iso"
PRESEED_CONF=/share/preseed.cfg

virt-install --name ${VM_NAME} --vcpus ${VCPUS} --memory ${MEM_SIZE} --disk size=${DISK_SIZE},bus=virtio,format=qcow2 \
             --boot cdrom,hd --network network=br1 --graphics ${GRAPHICS} --console pty,target_type=serial \
             --location ${IMAGE_FILE} --initrd-inject=${PRESEED_CONF} --connect qemu:///system \
             --extra-args="auto=true priority=critical netcfg/use_autoconfig=true netcfg/disable_dhcp=false \
             netcfg/get_hostname=ubuntu-preseed network-console/password=instpass network-console/start=true \
             console=ttyS0,115200n8 serial"