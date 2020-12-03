FROM golang:1.14.4-alpine as build
WORKDIR /src
COPY . .
ENV CGO_ENABLED=0 \
    GOOS=linux \
    GOARCH=amd64
RUN go build .

FROM frankpetrilli/boringtun:latest as boringtun

# WORKDIR /etc/wg_client/
# # COPY --from=0 /src/goclient .

FROM ubuntu:focal

WORKDIR /etc/wireguard/
COPY --from=boringtun /app/boringtun /app/boringtun
COPY --from=build /src/goclient /app/goclient
RUN apt-get update && apt-get install -y --no-install-suggests wireguard-tools iproute2 iptables tcpdump
