# quic-migrate
Exploring intentional connection migration over quic

## Build

Dependencies:
 * git
 * docker-compose v1.27.4
 * wireguard v1.0.2 
   * Your machine needs wireguard kernel module even if you are running wireguard in Docker

```
git submodule update --init --recursive
docker-compose build
```

The next large step is to build the Chromium source with modified QUIC client, since their default toy client [does not support connection migration](https://bugs.chromium.org/p/chromium/issues/detail?id=1104647). The following steps are adapted from the build and experiment instructions from MIMIQ ([paper](https://www.usenix.org/system/files/foci20-paper-govil.pdf), [code](https://github.com/liangw89/p4privacy/blob/master/mimiq/walkthrough)).

Note that this step requires a large amount of disk space due to the size of the Chromium git repository. However, the build process is not too long since we are only building `quiche` (their QUIC library) tooling.

```
# 1. Download Chromium source & history
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
```

We consulted these tutorials extensively for the above process, if you run into any trouble:
 * [Chromium Build for Linux](https://chromium.googlesource.com/chromium/src/+/main/docs/linux/build_instructions.md)
 * [Building Old Revisions](https://chromium.googlesource.com/chromium/src/+/master/docs/building_old_revisions.md)
 * [Working with Release Branches](https://www.chromium.org/developers/how-tos/get-the-code/working-with-release-branches/)

We bind-mount Chromium source into the Docker volume instead of building it in one, since the source is so large. We expect $CHROMIUM_SRC_DIR to be set when running `docker-compose`.

Then, you can run 
```
docker-compose build && docker-compose up
```
to bring up the network. The first run will take a little bit of time as the server and client containers should attempt to build the quic binaries from the chromium source.


#### Why the Chromium QUIC server/client?

It's a hassle to build (especially into a Docker container) since it requires the entire Chromium source and build chain, but it is the most mature QUIC library that supports connection migration.

### Testing migration

Running the following:
```
/src/out/Debug/quic_client --host=server --port=6121 --disable_certificate_verification https://www.example.org
```
should work in the `wg_client` container. You can run `tcpdump` on any of the containers to capture the result-- we prefer running at the server to capture traffic coming in from both IP addresses.

![demo of quic migration working in action](quic-migrate-demo.gif)

