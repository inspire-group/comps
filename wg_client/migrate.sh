#!/bin/bash
while true
do
ip route add default dev wg2 table 51821
#wg setconf wg0 /etc/wireguard/wg1_client.conf
sleep $1
ip route delete default dev wg2 table 51821
#wg setconf wg0 /etc/wireguard/wg2_client.conf
sleep $1
done
