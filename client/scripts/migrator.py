import threading
import time
from pyroute2 import IPRoute
import numpy as np

class MigratorThread(threading.Thread):
  def __init__(self, strategy="wr", period=0.2, ifaces=["eth0"]):
    self.strategy = strategy
    self.period = period
    self.ifaces = ifaces
    self._ip = IPRoute()
    self._iface_idx = 0
    self._stopevent = threading.Event()
    if self.strategy == "wr":
        self._distribution = np.random.dirichlet(np.ones(len(self.ifaces)), size=1)[0]
    super(MigratorThread, self).__init__(name="MigratorThread")

  def choose_next_path(self):
    if self.strategy == "rr":
      self._iface_idx = (self._iface_idx + 1) % len(self.ifaces)
      return self.ifaces[self._iface_idx]
    elif self.strategy == "ur":
      return np.random.choice(self.ifaces)
    elif self.strategy == "wr":
      return np.random.choice(self.ifaces, p=self._distribution)

  def run(self):
    if self.strategy == "none":
      return
    while not self._stopevent.isSet():
      path = self.choose_next_path()
      try:
        self._ip.route("del", dst="default", table=51821, rtscope="RT_SCOPE_LINK")
      except:
        pass #print("MigratorThread: No such ip route currently exists.")
      self._ip.route("add", dst="default", table=51821, rtscope="RT_SCOPE_LINK",
                     oif=self._ip.link_lookup(ifname=path)[0])
      time.sleep(self.period)

  def join(self, timeout=None):
    self._stopevent.set()
    super().join(timeout)

