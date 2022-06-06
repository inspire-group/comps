## Build

Dependencies:
 * docker-compose v1.27.4

```
# Generate {1M, 10M, 100M, 1G} test files for server.
cd server/data && bash gen.sh && cd ../..

# Build and deploy docker network.
docker-compose build && docker-compose up
```

## Manual demo with Webdriver and VNC
(This is the setup for the HotPETS demo)
For the full demo, you will also need to install:
 * python3 
 * pip
 * selenium python package
 * a VNC client like [VNC Viewer](https://www.realvnc.com/en/connect/download/viewer/linux/)

For instance, on a Debian-based distribution, you might install these via:
```
apt install python3 python3-pip
pip3 install selenium
```

### Watching packets flow through either path
To watch packets flow through each particular path for this demo, you can run
```
docker exec -it wg tcpdump -i eth0
docker exec -it wg tcpdump -i eth1
```
each in different windows.

Then, you can start migration by running
```
docker exec -it wg_client bash migrate-simple.sh 0.1
```

And then finally, in yet another window, run the test:
```
docker exec -it wg_client bash test.sh
```
You should see packets bounce between the two interfaces above.

### OpenVNC and driving a chrome browser

Instead of fetching from a toy server as is done in test.sh, can also bind to a Chrome instance running in the `chrome` container and shares the same network namespace as the wg client, and simulate a real web request. This `chrome` container is also running a VNC server, which you can connect to for demo purposes.

1. Open your VNC client and connect to server running on `127.0.0.1:9000` with password `secret`.
2. Run `python3 selenium/open_website https://google.com`

Google should open on the browser visible via VNC, and you can freely browse until the Python script exits. If you have the above `tcpdump` and path migration commands running, you should also be able to see the traffic bouncing between the two interfaces.

## Run tests automatically
You can also run performance tests with:

```
docker exec -t wg_client python3 /scripts/perf.py
```

Which should then print the results of your performance testing. To change the size of the file being sent over the network, or the switching frequency, you can change the parameters at the top of `client/scripts/perf.py` and rebuild the Docker container via `docker-compose build`.

