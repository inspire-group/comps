#!/bin/bash

set -e

# Set up overlay interfaces
ip link add wgnet1 type wireguard
wg setconf wgnet1 /etc/wireguard/wgnet1.conf
ip link set mtu 1420 up dev wgnet1
ip -4 address add 10.10.0.2/32 dev wgnet1

ip link add wgnet2 type wireguard
wg setconf wgnet2 /etc/wireguard/wgnet2.conf
ip link set mtu 1420 up dev wgnet2
ip -4 address add 10.20.0.2/32 dev wgnet2


# Set up server interface
ip link add wg0 type wireguard
wg setconf wg0 /etc/wireguard/wg0.conf
ip link set mtu 1420 up dev wg0
ip -4 address add 10.30.0.2/32 dev wg0


# Initialize routing tables & fwmark
# Overlay interface table
wg set wgnet1 fwmark 51821
wg set wgnet2 fwmark 51821
# Alternate between these two interfaces
ip -4 route add 0.0.0.0/0 dev wgnet1 table 51821 # wgnet1
# ip -4 route add 0.0.0.0/0 dev wgnet2 table 51821 # wgnet2

# wg interface table
wg set wg0 fwmark 51820
ip -4 route add 0.0.0.0/0 dev wg0 table 51820


# Set up rules
# Packet => table 51820 => wg0 => fwmark 51820 =>
#        => table 51821 => wgnet1 or wgnet2 => fwmark 51821 =>
#        => table main => eth0
# 
# 51821 manages traffic from wg0, and forwards it to the appropriate
#       wgnet overlay interface. This table's default rules constantly change.
# 51820 manages any unmarked traffic, and forwards traffic to wg0
#       wireguard interface.
# 
ip -4 rule add not fwmark 51820 table 51820 # lowest priority
ip -4 rule add fwmark 51820 table 51821
ip -4 rule add fwmark 51821 table main  # highest priority

