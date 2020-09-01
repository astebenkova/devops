#!/bin/bash

VM_DOMAIN=$1
SNAPSHOTS=$(virsh snapshot-list ${VM_DOMAIN} | tail -n +3 | head -n -1 | awk '{ print $1 }')

if [[ ${SNAPSHOTS} ]]; then
    echo -e "[*] This domain has the following snapshots:\n${SNAPSHOTS}"
    read -p "[!] Are you sure you want to delete the domain with snapshots (y/n)?" -n 1 -r
    echo 

    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        for SNAPSHOT in ${SNAPSHOTS}; do virsh snapshot-delete ${VM_DOMAIN} ${SNAPSHOT}; done;
    else
	echo "[*] Aborting..." && exit 0
    fi
fi

virsh shutdown ${VM_DOMAIN} > /dev/null 2>&1
sleep 3
# Destroy just in case
virsh destroy ${VM_DOMAIN} > /dev/null 2>&1
virsh undefine --domain ${VM_DOMAIN} --remove-all-storage

exit 0
