# Mosh experimental setup

## Build
Dependencies:
 * git
 * docker-compose v1.27.4
 * wireguard v1.0.2 
   * Your machine needs wireguard kernel module even if you are running wireguard in Docker

To build & start setup, simply run
```
docker-compose build && docker-compose up

```

## Run
To run the full suite of perf tests, you can run:

```
docker exec -t client python3 /scripts/perf.py
```




