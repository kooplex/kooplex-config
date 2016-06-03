#!/bin/bash

dec2ip () {
    local ip dec=$@
    for e in {3..0}
    do
        ((octet = dec / (256 ** e) ))
        ((dec -= octet * 256 ** e))
        ip+=$delim$octet
        delim=.
    done
    printf '%s\n' "$ip"
}

ip2dec () {
    local a b c d ip=$@
    IFS=. read -r a b c d <<< "$ip"
    printf '%d\n' "$((a * 256 ** 3 + b * 256 ** 2 + c * 256 + d))"
}

CIDR=$1
OFFSET=$2
NETWORK=`echo "$CIDR" | egrep '^[0-9\.]+' -o`
NETMASK=`echo "$CIDR" | egrep '[0-9]+$' -o`

A=`ip2dec "$NETWORK"`
B=$OFFSET
IP=$((A + B))

dec2ip "$IP"
