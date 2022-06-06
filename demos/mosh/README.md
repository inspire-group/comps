# Mosh experimental setup

## Build
Dependencies:
 * bash
 * git
 * ssh-keygen
 * docker-compose v1.27.4

To build & start setup, run from this directory:
```

# Generate private/public keypairs
ssh-keygen -t rsa -b 4096 -f client/ssh_keys/id_rsa

# Generate random serverdata files to fetch
cd server/data
./gen.sh
cd ../..

# Build and start the Docker network
docker-compose build && docker-compose up
```

If you are running this experiment after the other demos, you may have to run `docker network prune` in between.

## Run
To run the full suite of perf tests, you can run:

```
docker exec -t mosh_client_1 python3 /scripts/perf.py
```

It should take around 10-15 minutes to complete fully.

The timing results will be written to a file in the container called `results.txt`, which you can retrieve by copying the file or `cat`-ing it:

```
# Read results:
docker exec -t mosh_client_1 cat result.txt

# Copy file to host:
docker cp mosh_client_1:results.txt .
```

