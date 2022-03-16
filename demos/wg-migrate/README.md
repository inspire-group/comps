# wg-migrate demo

## How does it work?
```
 CoMPS client
┌───────────────────────────┐        wg proxies
│                       ┌───┴────┐   ┌────────┐
│                    ┌─►│ wgnet1 │──►│ wgnet1 │─┐
│                    │  └───┬────┘   └────────┘ │  also a wg proxy
│┌────────┐  ┌─────┐─┘      │                   └►┌─────┐
││ Client ├─►│ wg0 │        │                     │ wg0 │──►Internet
│└────────┘  └─────┘─┐      │                   ┌►└─────┘
│                    │  ┌───┴────┐   ┌────────┐ │
│                    └─►│ wgnet2 │──►│ wgnet2 │─┘
│                       └───┬────┘   └────────┘
└───────────────────────────┘
```

This PoC demo involves double-tunnelling Wireguard; the wgnet proxies are responsible for providing an overlay network to simulate a multi-homed environment. The wg0 interface on the client alternates between sending and receiving traffic across the two wgnet interfaces.

Essentially, the docker-compose file orchestrates 4 machines: CoMPS client, 2 wgnet proxies, and the CoMPS "server" (wg0 proxy)

wgnet1, wgnet2, and wg0 containers use default `wg-quick` utility. However, we customize the routing rules in the comps client to enable double-tunneling and migration.

It is also possible to deploy wgnet1, wgnet2, and wg0 Wireguard proxies on separate machines, rather than in local containers, so long as they are configured with the appropriate public/private keys.

Similarly to the QUIC PoC demo, we can attach Selenium to a Chromium container, then specify the container to use the same network namespace as our CoMPS client so all of the browser traffic goes through the PoC CoMPS network.


## Build

Dependencies:
 * docker-compose v1.27.4
 * wireguard v1.0.2 
   * Your machine needs wireguard kernel module even if you are running wireguard in Docker


Simply run `docker-compose up` to bring up the network.

### Testing migration
The script for regularly alternating network paths should be mounted in the `wg_client` container at `/etc/wireguard/migrate.sh`. It takes just one argument-- the amount of time to sleep between migrations.

For instance, run `/etc/wireguard/migrate.sh 0.1 &` to switch network interfaces every 100ms (or 0.1s).


### Testing a headless browser
After running dc up, a remote webdriver instance that supports QUIC traffic should be opened on your host machine at port 4444. You can run `selenium/open_website.py www.google.com` for instance in order to fetch the remote page for `https://www.google.com` (or any other QUIC-supporting website), or run your own selenium code and capture the relevant traces on wg_client, wg1, or wg2.









