slice=$1

while true
do
    ip -4 route del 0.0.0.0/0 dev wgnet0 table 51821
    ip -4 route add 0.0.0.0/0 dev wgnet1 table 51821
    sleep $slice
    
    ip -4 route del 0.0.0.0/0 dev wgnet1 table 51821
    ip -4 route add 0.0.0.0/0 dev wgnet2 table 51821
    sleep $slice
    
    ip -4 route del 0.0.0.0/0 dev wgnet2 table 51821
    ip -4 route add 0.0.0.0/0 dev wgnet0 table 51821
    sleep $slice
done
