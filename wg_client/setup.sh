#!/bin/bash

set -x
ip link add wg1 type wireguard
wg setconf wg1 /etc/wireguard/wg1.conf
ip link set mtu 1420 up dev wg1
ip -4 address add 10.0.0.1/32 dev wg1

wg set wg1 fwmark 51820
ip -4 route add 0.0.0.0/0 dev wg1 table 51820
ip -4 rule add not fwmark 51820 table 51820

ip link add wg2 type wireguard
wg setconf wg2 /etc/wireguard/wg2.conf
ip link set mtu 1420 up dev wg2
ip -4 address add 10.0.1.1/32 dev wg2

wg set wg2 fwmark 51821
# ip -4 route add 0.0.0.0/0 dev wg2 table 51821
ip -4 rule add not fwmark 51821 table 51821

ip -4 rule add table main suppress_prefixlength 0
sysctl -q net.ipv4.conf.all.src_valid_mark=1
