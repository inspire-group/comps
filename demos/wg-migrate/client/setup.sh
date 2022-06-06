#!/bin/bash

ip link add wg0 type wireguard
wg setconf wg0 /etc/wireguard/client.conf
ip link set mtu 1420 up dev wg0

wg set wg0 fwmark 51820

ip -4 address add 10.0.0.2/32 dev wg0
ip -4 route add 0.0.0.0/0 dev wg0 table 51820
ip -4 rule add not fwmark 51820 table 51820
ip -4 rule add table main suppress_prefixlength 0

# ./migrate.sh
ip route add 10.0.0.1/32 dev eth0

sleep infinity
