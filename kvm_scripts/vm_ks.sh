#!/bin/bash

# Pre-defined variables
MEM_SIZE=512
VCPUS=1
OS_VARIANT="ubuntu16.04"
ISO_FILE="/var/lib/libvirt/images/basic_images/ubuntu-16.04.6-server-amd64.iso"
VM_IMAGE_DIR=/var/lib/libvirt/images
OS_TYPE="linux"
DISK_SIZE=5
VM_NAME=${OS_VARIANT}_$(date +"%d%m%Y_%H%M")_ks
KS_CONFIG="172.18.195.61:/share/ks.cfg"

sudo virt-install \
     --connect qemu:///system \
     --name ${VM_NAME} \
     --memory=${MEM_SIZE} \
     --vcpus=${VCPUS} \
     --os-type ${OS_TYPE} \
     --location ${ISO_FILE} \
     --disk="${VM_IMAGE_DIR}/${VM_NAME}.img,size=${DISK_SIZE}" \
     --network network=br1 \
     --graphics=none \
     --os-variant=${OS_VARIANT} \
     --console pty,target_type=serial \
     -x 'console=ttyS0,115200n8 serial' \
     -x "ks=nfs:${KS_CONFIG}" 


VM_IP_ADDRESS=$(virsh domifaddr ${VM_NAME} | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b")
echo "[*] You can login to VM with: ssh arina@${VM_IP_ADDRESS}"

exit 0
