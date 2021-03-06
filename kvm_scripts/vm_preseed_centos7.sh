#!/bin/bash

# Pre-defined variables
MEM_SIZE=512
VCPUS=1
DISK_SIZE=5
# none, spice, vnc
GRAPHICS=none
VM_NAME=centos_$(date +"%d%m%Y_%H%M")_preseed
#IMAGE_FILE="/var/lib/libvirt/images/basic_images/ubuntu-16.04.6-server-amd64.iso"
IMAGE_FILE="/var/lib/libvirt/images/basic_images/centos-7-x86_64-minimal.iso"
PRESEED_CONF=preseed_centos.cfg
NETWORK="salt-network"

virt-install --name ${VM_NAME} \
     	     --vcpus ${VCPUS} \
    	     --memory ${MEM_SIZE} \
             --os-type=linux  \
             --os-variant=rhel7 \
	         --quiet \
	         --disk size=${DISK_SIZE},bus=virtio,format=qcow2 \
	         --network network=${NETWORK} \
	         --boot hd \
	         --graphics ${GRAPHICS} \
	         --console pty,target_type=serial \
             --location ${IMAGE_FILE} \
	         --initrd-inject=${PRESEED_CONF} \
             --extra-args="auto=true priority=critical netcfg/use_autoconfig=true netcfg/disable_dhcp=false \
             netcfg/get_hostname=docker network-console/password=instpass network-console/start=true \
             console=ttyS0,115200n8 serial"


VM_IP_ADDRESS=$(virsh domifaddr ${VM_NAME} | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b")
echo "[*] You can login to VM with: ssh arina@${VM_IP_ADDRESS}"

exit 0
