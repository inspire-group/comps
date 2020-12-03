#!/bin/bash

docker-compose build > /dev/null
docker-compose up -d

function dotest {
	out="$($@)"
	if [ $? -eq 0 ]; then
		echo "  ... SUCCESS"
	else
		echo "$out"
		echo "  ... FAILED"
	fi
}

docker exec -it wg_client wg setconf wg0 /etc/wireguard/wg1_client.conf > /dev/null
timeout 5 docker exec wg1 sh -c "tcpdump -U -c 5 udp > tmp.out" &
sleep 1
echo "###GET server index via wg1"
dotest docker exec -it wg_client curl --http3 https://10.3.0.4:4433
echo "### wg1 sees UDP traffic"
dotest docker exec -it wg1 grep UDP tmp.out
docker exec -it wg1 rm tmp.out

# changing from wg1 to wg2
docker exec -it wg_client wg setconf wg0 /etc/wireguard/wg2_client.conf > /dev/null
timeout 5 docker exec wg2 sh -c "tcpdump -U -c 5 udp > tmp.out" &
sleep 1
echo "###GET server index via wg2"
dotest docker exec -it wg_client curl --http3 https://10.3.0.4:4433
echo "###wg2 sees UDP traffic"
dotest docker exec -it wg2 grep UDP tmp.out
docker exec -it wg2 rm tmp.out

# docker-compose down

