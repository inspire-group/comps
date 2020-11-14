# quic-migrate
exploring intentional connection migration over quic

## Building & running the curl-quic dockerfile

```
cd docker
docker build . -t qurl
```

Running a standalone command:

```
docker run --rm qurl --http3 https://quic.tech:8443
```

Get shell:
```
docker run --rm -it --entrypoint /bin/bash qurl
```
