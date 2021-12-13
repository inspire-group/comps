#!/bin/bash

slice=$1

while true
do
  ip route del 10.6.0.2/32
  ip route add 10.6.0.2/32 dev eth0
  sleep $slice

  ip route del 10.6.0.2/32
  ip route add 10.6.0.2/32 dev eth1
  sleep $slice

done
