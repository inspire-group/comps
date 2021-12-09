# CoMPS

## Design

```
Wireguard:

 CoMPS client (host)
┌───────────────────────────┐        wg proxies
│             interfaces┌───┴────┐   ┌────────┐
│                    ┌─►│ wgnet1 │──►│ wgnet1 │─┐
│                    │  └───┬────┘   └────────┘ │ wg peer
│┌────────┐  ┌─────┐─┘  ┌───┴────┐   ┌────────┐ └►┌─────┐
││ Client ├─►│ wg0 │───►│ wgnet2 │──►│ wgnet2 │──►│ wg0 │──► Internet
│└────────┘  └─────┘─┐  └───┬────┘   └────────┘ ┌►└─────┘
│                    │  ┌───┴────┐   ┌────────┐ │
│                    └─►│ wgnet3 │──►│ wgnet3 │─┘
│                       └───┬────┘   └────────┘
└───────────────────────────┘
```

Note: PoC setup moved to demos subfolder.


Dependencies:
 * ansible
 * wireguard
 * docker-compose

If you would like to both provision and setup servers, you can simply run `ansible-playbook main.yml`. If you already have servers provisioned, you can fill out a static `hosts` inventory file and just run `ansible-playbook wgnet-setup.yml`

## Provisioning DO servers
In order to provision DO servers with ansible, you'll have to specify your DO credentials and CoMPS network config in `config.cfg`. Copy `config.cfg.example` to `config.cfg` and fill in the appropriate sections.

You can automatically provision the exact number of DO servers you need via `ansible provision.yml`.

Note that if you are running `provision.yml` on its own, you'll still have to generate a static inventory file from the provisioned servers.


## Setting up CoMPS network
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

## Connecting to the CoMPS network
TODO: have ansible run docker-compose up and begin migration automatically

To start a client container connected to the CoMPS network:
```
cd wg_client_generated
docker-compose up
```

Then you can get a shell in the `wgclient` container via: `docker exec -it wgclient /bin/sh`.

To just test each wgnet proxy, you can run the following to change the default route in table 51821:
```
ip -4 route delete 0.0.0.0/0 dev wgnet$CURRENT_INDEX table 51821
ip -4 route add 0.0.0.0/0 dev wgnet$NEW_INDEX table 51821
```

To see what the current default route is for table 51821, you can run `ip route show table 51821`.

## Routing details

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


