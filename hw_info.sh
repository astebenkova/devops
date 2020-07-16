#! /bin/bash

RESULT_FILE=~/hw_info.txt

# Get the CPU info
CPU_MODEL=$(cat /proc/cpuinfo  |grep -im 1 "model name" | cut -f3- -d ' ')
echo "[!] CPU model: $CPU_MODEL" > "$RESULT_FILE"

RAM_SIZE=$(free -mh |grep -i mem |awk '{print $2}')
echo "[!] RAM size: $RAM_SIZE" >> $RESULT_FILE

MOTHERBOARD=$(dmidecode -t baseboard | grep -i manufacturer | cut -f2- -d ' ' || echo "Unknown")
echo "[!] Motherboard: $MOTHERBOARD" >> $RESULT_FILE

exit 0
