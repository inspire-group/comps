slice=$1

while true
do
  ip route del 10.0.0.1/32
  ip route add 10.0.0.1/32 dev eth0
  sleep $slice

  ip route del 10.0.0.1/32
  ip route add 10.0.0.1/32 dev eth1
  sleep $slice
done
