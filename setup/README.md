# Setting up CoMPS for data collection

Sketch of the overall design & setup:
```
Wireguard:

 CoMPS client (host)
┌───────────────────────────┐        wg proxies
│             interfaces┌───┴────┐   ┌────────┐
│                    ┌─►│ wgnet1 │──►│ wgnet1 │─┐
│                    │  └───┬────┘   └────────┘ │ wg peer
│┌────────┐  ┌─────┐─┘  ┌───┴────┐   ┌────────┐ └►┌─────┐
││ Client ├─►│ wg0 │───►│ wgnet2 │──►│ wgnet2 │──►│ wg0 │──► Internet
│└───┬┬───┘  └─────┘─┐  └───┬────┘   └────────┘ ┌►└─────┘
│┌───┴┴───┐          │  ┌───┴────┐   ┌────────┐ │
││ Chrome │          └─►│ wgnet3 │──►│ wgnet3 │─┘
│└────────┘             └───┬────┘   └────────┘
└───────────────────────────┘
```

Dependencies:
 * ansible v2.9.6
 * wireguard v1.0.2 
   * Your machine needs wireguard kernel module even if you are running wireguard in Docker
 * docker-compose v1.27.4

Steps
 1. [Provisioning DO servers](#1-provisioning-do-servers)
 2. [Setting up CoMPS network](#2-setting-up-comps-network)
 3. [Connecting to the CoMPS network](#3-connecting-to-the-comps-network)
 4. [Collecting Traces](#4-collecting-traces)

## 1 Provisioning DO servers

Copy `config.cfg.example` to `config.cfg` and fill in the appropriate sections.
 * In order to provision DO servers with ansible, you'll have to specify your DO credentials and CoMPS network config in `config.cfg`. 

From here, you can either:
 1. Automatically provision the exact number of DO servers you need via `ansible provision.yml`.
 2. Fill out the `hosts` file with your newly provisioned servers. Then proceed to the [next section](#2-setting-up-comps-network).

You can also skip directly to [Section 3](#3-connecting-to-the-comps-network) by  running `ansible-playbook main.yml`. However, if you plan on using the same network again in the future, note that this re-provisions servers each time you do it.

Note: This script does not tear down servers. You need to manually shut down these servers after you're done testing or collecting data.

## 2 Setting up CoMPS network

Example `hosts` file for 3 wgnet servers:

```
[vpn]
68.183.60.54
165.22.36.157
159.223.146.72

[comp]
67.207.87.58
```

Then run `ansible-playbook -i hosts wgnet-setup.yml`. This should generate private/public key pairs on each machine, start the Wireguard daemon on each, as well as generating local Docker configuration files for connecting to the CoMPS network.

## 3 Connecting to the CoMPS network

To start a client container connected to the CoMPS network:
```
cd client
docker-compose up
```

Then you can get a shell in the `wgclient` container via: `docker exec -it wgclient /bin/sh`.

To just test each wgnet proxy, you can run the following inside the `wgclient` container to change the default route in table 51821:
```
ip -4 route delete 0.0.0.0/0 dev wgnet$CURRENT_INDEX table 51821
ip -4 route add 0.0.0.0/0 dev wgnet$NEW_INDEX table 51821
```

To see what the current default route is for table 51821, you can run `ip route show table 51821`.

## 4 Collecting data
The `client/scripts` folder gets mounted into the client Docker container, and can help run various experiments from the host. For instance, 

```
echo "https://youtube.com" | docker exec -i wgclient python /comps/fetch_websites.py
```

will begin migration and instrument a Chromium instance to fetch the homepage of Youtube and return captured pcap traces on every wgnet interface. You can change the parameters to `fetch_websites.py` in order to alter the migration frequency.

The code that collects this data utilizes the bundled [wf-tools](https://github.com/jpcsmith/wf-tools) library for the libraries to capture and dump pcap.

### (Extra) Routing details

`client/setup.sh` performs most of the heavy lifting for CoMPS routing; details about the implementation can also be found in the file comments.

The new ip rules are, in order of highest priority to lowest:
```
from all fwmark 51821 lookup main
from all fwmark 51820 lookup 51821
not from all fwmark 51820 lookup 51820
... (default rules)
```
`wg0` interface is configured with fwmark 51820 and `wgnet*` interfaces are configured with fwmark 51821.

Table 51821 manages traffic from wg0, and forwards it to the current wgnet overlay interface. Table 51821's default rule constantly change w/ migration. 

Table 51820 manages any unmarked traffic, and forwards traffic to wg0 wireguard interface.



### Extras
```
QUIC:

 CoMPS client (host)
┌──────────────────┐        wg proxies
│              ┌───┴────┐   ┌────────┐
│           ┌─►│ wgnet1 │──►│ wgnet1 │─┐
│           │  └───┬────┘   └────────┘ │  
│┌────────┐─┘  ┌───┴────┐   ┌────────┐ └──►
││ Client ├───►│ wgnet2 │──►│ wgnet2 │────► QUIC servers
│└────────┘─┐  └───┬────┘   └────────┘ ┌──►
│           │  ┌───┴────┐   ┌────────┐ │
│           └─►│ wgnet3 │──►│ wgnet3 │─┘
│              └───┬────┘   └────────┘
└──────────────────┘
```
