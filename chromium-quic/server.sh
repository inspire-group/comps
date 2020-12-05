#!/bin/bash

if [ ! -f "/src/out/Debug/quic_server" ]; then
        echo "Building quic_server..."
        cd /src/src

        set -e
        set -x
        gclient runhooks
        gn gen out/Debug
        ninja -C out/Debug quic_server
        set +x
fi

if [ ! -f "/site/tls/leaf_cert.pem" ]; then
        cd /src/net/tools/quic/certs
        ./generate-certs.sh
        cp /src/net/tools/quic/certs/out/leaf_cert.pem /site/tls/
        cp /src/net/tools/quic/certs/out/leaf_cert.pkcs8 /site/tls/
        cd -
fi

set -x
/src/out/Debug/quic_server --quic_response_cache_dir=/site/example.com --certificate_file=/site/tls/leaf_cert.pem --key_file=/site/tls/leaf_cert.pkcs8
