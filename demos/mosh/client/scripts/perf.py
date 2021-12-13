import time
import subprocess
from migrator import MigratorThread

n_repeats = 10
SERVER_URL = "http://server/file?size="
SIZES = [1000]
FREQS = [0.01, 0.02, 0.03, 0.04, 0.05, 0.1, 0.2, 0.3, 0.5, 10000000000]
FREQS.reverse()


def cat_once():
  start_time = time.time()
  subprocess.call("./mosh.sh")
  return time.time() - start_time


def cat_n_times():
  return [cat_once() for i in range(n_repeats)]

with open("results.txt", "w") as f:
  for freq in FREQS:
    ifaces = ["eth0", "eth1"]
    migrator = MigratorThread("rr", freq, ifaces=ifaces)
    #process_migrate = subprocess.Popen(["/bin/bash", "./migrate-simple.sh", str(freq)])
    migrator.start()
    try:
      results = cat_n_times()
      f.write(str(results) + "\n")
    finally:
      migrator.join()
