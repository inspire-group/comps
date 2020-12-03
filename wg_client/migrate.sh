#!/bin/bash
while true
do
wg setconf wg0 /etc/wireguard/wg1_client.conf
sleep $1
wg setconf wg0 /etc/wireguard/wg2_client.conf
sleep $1
done
