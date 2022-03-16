FROM golang:1.15.2-alpine3.12
WORKDIR /client
RUN apk add git make build-base
ENV CGO_ENABLED=1 \
    GOOS=linux \
    GOARCH=amd64
RUN go get github.com/lucas-clemente/quic-go/http3
ADD src /client/src

WORKDIR /client/src
RUN go build -o run

FROM frankpetrilli/boringtun:latest
WORKDIR /etc/wg_client/
COPY --from=0 /client/src/run .

WORKDIR /etc/wireguard/
