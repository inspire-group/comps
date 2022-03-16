#!/bin/bash
set -e

# Set up overlay interfaces
{% for host in groups['vpn'] %}
  {% set i = hostvars[host].wireguard_index %}
  ip link add wgnet{{i}} type wireguard
  wg setconf wgnet{{i}} /etc/wireguard/wgnet{{i}}.conf
  ip link set mtu 1420 up dev wgnet{{i}}
  ip -4 address add {{ hostvars[host].wireguard_address }} dev wgnet{{i}}
  wg set wgnet{{i}} fwmark 51821

  # # Below sets the default route for table 51821. To migrate,
  # # alternate this route between different wgnet interfaces.
  # ip -4 route add 0.0.0.0/0 dev wgnet{{i}} table 51821
{% endfor %}

# Set up wg server interface
{% set comps_host = groups['comp'][0] %}
ip link add wg0 type wireguard
wg setconf wg0 /etc/wireguard/wg0.conf
ip link set mtu 1420 up dev wg0
ip -4 address add {{ hostvars[comps_host].wireguard_address }} dev wg0

# Set up routing table for wg server interface
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

ip -4 rule add not fwmark 51820 table 51820 # lowest priority
ip -4 rule add fwmark 51820 table 51821
ip -4 rule add fwmark 51821 table main  # highest priority


