import socket
from pyroute2 import IPRoute
ip = IPRoute()
print(ip.link_lookup(ifname="wgnet0")[0])
try:
    ip.route("del", dst="default", table=51821, 
                         family=socket.AF_INET)
except:
    print("no path")
ip.route("add", dst="default", table=51821,
                     family=socket.AF_INET, oif=ip.link_lookup(ifname="wgnet2")[0])
