FROM golang:1.15.2-alpine3.12

WORKDIR /server

RUN apk add git
RUN go get github.com/lucas-clemente/quic-go/http3
ENV CGO_ENABLED=0 \
    GOOS=linux \
    GOARCH=amd64

ADD tls /server/tls
ADD site /server/site
ADD src /server/src
ADD server.sh ./

WORKDIR /server/src
RUN go build -o run

EXPOSE 443
CMD ["/server/src/run"]