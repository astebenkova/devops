#!/bin/bash

WORKDIR=/var/lib/libvirt/images
DISK_SIZE=5G
VM_HOSTNAME=ubuntu1
CLOUD_IMAGE_URL="https://cloud-images.ubuntu.com/xenial/current/xenial-server-cloudimg-amd64-disk1.img"
SSH_USER_KEY=$(cat ${HOME}/.ssh/id_rsa.pub)

echo "[*] Downloading the image to ${WORKDIR}..."
sudo wget -O ${WORKDIR}/ubuntu-server-16.04.qcow2 ${CLOUD_IMAGE_URL} || { echo "[!] The download has failed. Check the URL. Aborting."; exit 1; }

echo "[*] Checking the image format..."
IMG_FORMAT=$(sudo qemu-img info ${WORKDIR}/ubuntu-server-16.04.qcow2 | grep -i 'file format' |awk '{ print $3 } ')

if [ ${IMG_FORMAT} != "qcow2" ]
then
    echo "[!] This is not a .qcow2 format! Aborting."
    exit 1
fi

echo "[*] Creating a disk image..."
sudo qemu-img create -f qcow2 -o backing_file=${WORKDIR}/ubuntu-server-16.04.qcow2 ${WORKDIR}/ubuntu-16.04-instance.qcow2

echo "[*] Resizing the image to ${DISK_SIZE}..."
sudo qemu-img resize ${WORKDIR}/ubuntu-16.04-instance.qcow2 ${DISK_SIZE}

echo "[*] Creating meta-data and user-data..."
cat > /tmp/meta-data <<EOF
hostname: ${VM_HOSTNAME}
local-hostname: ${VM_HOSTNAME}
network-interfaces: |
  auto eth0
  iface eth0 inet dhcp
EOF

cat > /tmp/user-data <<EOF
users:
  - name: astebenkova
    ssh-authorized-keys:
      - ${SSH_USER_KEY}
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    groups: sudo
    shell: /bin/bash
runcmd:
  - echo "AllowUsers astebenkova" >> /etc/ssh/sshd_config
  - restart ssh
EOF

echo "[*] Create a disk to attach with Cloud-Init configuration..."
sudo mkisofs -o "${WORKDIR}/ubuntu-16.04-instance.iso" -volid cidata -joliet -rock /tmp/user-data /tmp/meta-data

echo "[*] Launching a Virtual Machine..."
virt-install --connect qemu:///system --virt-type kvm --name ${VM_HOSTNAME} --ram 512 --vcpus=1 --os-type linux --os-variant ubuntu16.04 --disk path=${WORKDIR}//ubuntu-16.04-instance.qcow2,format=qcow2 --disk ${WORKDIR}/ubuntu-16.04-instance.iso,device=cdrom --import --network network=br1 --noautoconsole
