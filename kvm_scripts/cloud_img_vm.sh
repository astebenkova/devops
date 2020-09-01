#!/bin/bash

# Predefined variables
IMAGES_DIR=/var/lib/libvirt/images/basic_images
WORKDIR=/var/lib/libvirt/images
DISK_SIZE=5G
VM_HOSTNAME=ubuntu_$(date +"%d_%m_%Y_%H%M")_cloud
# Please, download the image to IMAGES_DIR
CLOUD_IMAGE_NAME="ubuntu-server-20.04.qcow2"
VM_USER="arina"
SSH_PUBLIC_KEY=$(cat ${HOME}/.ssh/id_rsa.pub)

echo "[*] Checking the image format..."
[ ! -f ${IMAGES_DIR}/${CLOUD_IMAGE_NAME} ] && { echo "[!] There is no such file: ${IMAGES_DIR}/${CLOUD_IMAGE_NAME}. Aborting" ; exit 1; }
IMG_FORMAT=$(sudo qemu-img info ${IMAGES_DIR}/${CLOUD_IMAGE_NAME} | grep -i 'file format' | awk '{ print $3 } ')

if [ ${IMG_FORMAT} != "qcow2" ]
then
    echo "[!] This is not a .qcow2 format! Aborting."
    exit 1
fi

echo "[*] Creating a disk image..."
sudo qemu-img create -f qcow2 -o backing_file=${IMAGES_DIR}/${CLOUD_IMAGE_NAME} ${WORKDIR}/${VM_HOSTNAME}.qcow2

echo "[*] Resizing the image to ${DISK_SIZE}..."
sudo qemu-img resize ${WORKDIR}/${VM_HOSTNAME}.qcow2 ${DISK_SIZE}

echo "[*] Creating meta-data and user-data..."
cat > /tmp/meta-data <<EOF
hostname: ubuntu-cloud
local-hostname: ubuntu-cloud
network-interfaces: |
  auto ens3
  iface ens3 inet dhcp
EOF

cat > /tmp/user-data <<EOF
#cloud-config
users:
  - name: ${VM_USER}
    password: vfnmdfie
    chpasswd: { expire: False }
    ssh_pwauth: True
    ssh-authorized-keys:
      - ${SSH_PUBLIC_KEY} 
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    groups: sudo
    shell: /bin/bash
EOF

echo "[*] Creating a disk to attach with Cloud-Init configuration..."
sudo mkisofs -o "${WORKDIR}/${VM_HOSTNAME}.iso" -volid cidata -joliet -rock /tmp/user-data /tmp/meta-data > /dev/null

echo "[*] Launching a Virtual Machine..."
virt-install --connect qemu:///system --virt-type kvm --name ${VM_HOSTNAME} --ram 512 --vcpus=1 --os-type linux \
             --os-variant ubuntu16.04 --disk path=${WORKDIR}/${VM_HOSTNAME}.qcow2,format=qcow2 \
             --disk ${WORKDIR}/${VM_HOSTNAME}.iso,device=cdrom --import --network network=br1 --noautoconsole

echo "[*] Getting an IP address. Wait a bit..."
sleep 20
VM_IP_ADDRESS=$(virsh domifaddr ${VM_HOSTNAME} | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b")
echo "[*] You can login to VM with: ssh ${VM_USER}@${VM_IP_ADDRESS}"

exit 0
