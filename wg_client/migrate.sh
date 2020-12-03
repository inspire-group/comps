#!/bin/bash
while true
do
# ip link set dev wg1 up
ip route add default dev wg1 table 51820
ip route delete default dev wg2 table 51821
# ip link set dev wg2 down
sleep $1
# ip link set dev wg2 up
ip route add default dev wg2 table 51821
ip route delete default dev wg1 table 51820
# ip link set dev wg1 down
sleep $1
done
