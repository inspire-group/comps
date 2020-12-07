# quic-migrate
exploring intentional connection migration over quic

## Build

Dependencies:
 * git
 * docker-compose

```
git submodule update --init --recursive
docker-compose build

# installing chromium source
git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git chromium-src/depot_tools
export PATH="$PATH:$(pwd)/chromium-src/depot_tools"
cd chromium-src/
# this command will take a lot of time and space
fetch --nohooks --no-history chromium
export CHROMIUM_SRC_DIR="$(pwd)/src"
cd ..
```

We took the `fetch` step out of the Docker build process, bind-mounting it into the volume, since the source is so large. We expect $CHROMIUM_SRC_DIR to be set when running `docker-compose`.

Then, you can run 
```
docker-compose up
```
to bring up the network. The first run will take a little bit of time as the server and client containers should attempt to build the quic binaries from the chromium source.


#### Why the Chromium QUIC server/client?

It's a hassle to build (especially into a Docker container) since it requires the entire Chromium source and build chain, but it is the most mature QUIC library that supports connection migration.

### Testing migration
Running the following:
```
/src/out/Debug/quic_client --host=server --port=6121 --disable_certificate_verification https://www.example.org
```
should work in the `wg_client` container.

### Testing a headless browser
After running dc up, a remote webdriver instance that supports QUIC traffic should be opened on your host machine at port 4444. You can run `selenium/open_website.py www.google.com` for instance in order to fetch the remote page for `https://www.google.com` (or any other QUIC-supporting website), or run your own selenium code and capture the relevant traces on wg_client, wg1, or wg2.




