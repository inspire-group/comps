#!/bin/bash

function dotest {
	out="$($@)"
	if [ $? -eq 0 ]; then
		echo "  ... SUCCESS"
	else
		echo "$out"
		echo "  ... FAILED"
	fi
}

docker exec -it wg_client ip route add default dev wg1 table 51820
docker exec -it wg_client ip route delete default dev wg2 table 51821
timeout 10 docker exec wg1 sh -c "tcpdump -U -c 5 udp > tmp.out" &
sleep 1
echo "###GET server index via wg1"
dotest docker exec -it wg_client /src/out/Debug/quic_client --host=server --port=6121 --disable_certificate_verification https://www.example.org
echo "### wg1 sees UDP traffic"
dotest docker exec -it wg1 grep UDP tmp.out
docker exec -it wg1 rm tmp.out

# changing from wg1 to wg2
# docker exec -it wg_client ip link set dev wg2 up
docker exec -it wg_client ip route add default dev wg2 table 51821
docker exec -it wg_client ip route delete default dev wg1 table 51820
# docker exec -it wg_client ip link set dev wg1 down
timeout 10 docker exec wg2 sh -c "tcpdump -U -c 5 udp > tmp.out" &
sleep 1
echo "###GET server index via wg2"
dotest docker exec -it wg_client /src/out/Debug/quic_client --host=server --port=6121 --disable_certificate_verification https://www.example.org
echo "###wg2 sees UDP traffic"
dotest docker exec -it wg2 grep UDP tmp.out
docker exec -it wg2 rm tmp.out

# Connection migration test
timeout 10 docker exec -it wg_client /etc/wireguard/migrate.sh 0.1 &
timeout 10 docker exec wg1 sh -c "tcpdump -U -c 500 udp > tmp.out" &
timeout 10 docker exec wg2 sh -c "tcpdump -U -c 500 udp > tmp.out" &
dotest docker exec -it wg_client /src/out/Debug/quic_client --host=server --port=6121 --disable_certificate_verification https://www.example.org --num_requests=1000
dotest docker exec -it wg1 grep UDP tmp0.out
dotest docker exec -it wg2 grep UDP tmp0.out

