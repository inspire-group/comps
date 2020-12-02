#!/bin/bash
set -e

docker-compose build
docker-compose up -d

echo "GET server index"
docker exec -it wg_client curl --http3 https://server:4433
if [ $? -eq 0 ]; then
	echo "... SUCCESS\n"
else
	echo "... FAILED\n"
fi

docker-compose down
