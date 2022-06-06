import requests
import statistics
import time
import subprocess

n_repeats = 20
SERVER_URL = "http://server/file?size="
SIZES = [1000]
FREQS = [0.1, 0.3]


def fetch_perf(url):
  start_time = time.time()
  response = requests.get(url)
  return time.time() - start_time


def fetch_perf_n(url):
  return [fetch_perf(url) for i in range(n_repeats)]


for freq in FREQS:
  process_migrate = subprocess.Popen(["/bin/bash", "./migrate-simple.sh", str(freq)])
  for size in SIZES:
    url = SERVER_URL + str(size)
    results = fetch_perf_n(url)
    print(f"Fetching {url} results at freq {freq}:")
    print(",".join([str(num) for num in results]))
  process_migrate.kill()

