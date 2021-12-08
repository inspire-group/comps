#!/bin/bash
# Expects first argument to be migration period in seconds.

while true
do
ip route delete default dev wgnet1 table 51821
ip route add default dev wgnet2 table 51821
sleep $1
ip route delete default dev wgnet2 table 51821
ip route add default dev wgnet1 table 51821
sleep $1
done
