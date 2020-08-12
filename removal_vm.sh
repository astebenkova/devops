#!/bin/bash

VM_DOMAIN=$1

virsh shutdown ${VM_DOMAIN}
sleep 3

# Destroy just in case
virsh destroy ${VM_DOMAIN} > /dev/null 2>&1
virsh undefine --domain ${VM_DOMAIN} --remove-all-storage

exit 0
