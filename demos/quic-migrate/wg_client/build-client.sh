#!/bin/bash

if [ ! -f "/src/out/Debug/quic_client" ]; then
        echo "Building quic_client..."
        cd /src/

        set -e
        set -x
        gclient runhooks
        gn gen out/Debug
        ninja -C out/Debug quic_client
        set +x
fi
