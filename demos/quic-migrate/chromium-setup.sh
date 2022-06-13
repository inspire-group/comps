#!/bin/bash
set -ex

# 1. Download Chromium source & history
mkdir chromium-src
git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git chromium-src/depot_tools
export PATH="$PATH:$(pwd)/chromium-src/depot_tools"
cd chromium-src/
fetch --nohooks chromium # will take a lot of time depending on network
./build/install-build-deps.sh
gclient runhooks

# 2. Fetching & building tags
gclient sync --with_branch_heads --with_tags
git fetch --tags
git checkout tags/79.0.3934.0

# 2a. (optional) check to see normal build works
gn gen out/Debug
ninja -C out/Debug quic_server quic_client

# 3. Apply patches
cd net/third_party/quiche
git stash apply -p ../../../../quiche.patch
cd ../../..

# 4. Build
gn gen out/Debug
ninja -C out/Debug quic_server quic_client

# 5. Export Chromium source path for Docker
export CHROMIUM_SRC_DIR="$(pwd)/src"
cd ..

