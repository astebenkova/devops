#!/bin/bash

# Predefined variables
IMAGES_DIR=/var/lib/libvirt/images/basic_images
WORKDIR=/var/lib/libvirt/images
DISK_SIZE=5G
VM_HOSTNAME=ubuntu18_$(date +"%d_%m_%H%M")_cloud
# Please, download the image to IMAGES_DIR
CLOUD_IMAGE_NAME="ubuntu-server-18.04.qcow2"
VM_USER="arina"
SSH_PUBLIC_KEY=$(cat ${HOME}/.ssh/id_rsa.pub)

#NETWORK
NET1=my-net-nat
NET2=net-dhcp-arina

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

echo "[*] Creating network-config and cloud-config..."
cat > /tmp/network-config-v2.yaml <<EOF
version: 2
ethernets:
  ens3:
     dhcp4: true
  ens4:
     dhcp4: no

vlans:
  vlan38:
    id: 38
    link: ens4
    dhcp4: no
    addresses: [ 10.10.10.15/24 ]
EOF

cat > /tmp/user-data.yaml <<EOF
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

packages:
  - ifenslave
  - vlan
  - net-tools
  - bash-completion

runcmd:
  - modprobe bonding
  - modprobe 8021q
  - echo "8021q" >> /etc/modules
  - echo "bonding" >> /etc/modules
EOF

cat > /tmp/meta-data.yaml <<EOF
hostname: cloud
local-hostname: cloud
EOF

echo "[*] Creating a disk to attach with Cloud-Init configuration..."
sudo cloud-localds -v --network-config=/tmp/network-config-v2.yaml ${WORKDIR}/${VM_HOSTNAME}.iso /tmp/user-data.yaml /tmp/meta-data.yaml

echo "[*] Launching a Virtual Machine..."
virt-install --connect qemu:///system --virt-type kvm --name ${VM_HOSTNAME} --ram 512 --vcpus=1 --os-type linux \
             --os-variant ubuntu16.04 --disk path=${WORKDIR}/${VM_HOSTNAME}.qcow2,format=qcow2 --graphics vnc \
             --disk ${WORKDIR}/${VM_HOSTNAME}.iso,device=cdrom --import --network network=${NET1} --network network=${NET2} --noautoconsole

echo "[*] Getting an IP address. Wait a bit..."
sleep 20
VM_IP_ADDRESS=$(virsh domifaddr ${VM_HOSTNAME} | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b")
echo "[*] You can login to VM with: ssh ${VM_USER}@${VM_IP_ADDRESS}"

exit 0
