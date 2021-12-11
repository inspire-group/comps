import copy
import time
import random
import sys
import pathlib
from typing import List

from selenium import webdriver
from selenium.webdriver.remote.webdriver import WebDriver
from selenium.common.exceptions import WebDriverException, UnexpectedAlertPresentException

from lab.fetch_websites import (
  ChromiumSessionFactory, ChromiumFactory, Result, encode_result, FetchTimeout, FetchFailed
)
from lab.sniffer import TCPDumpPacketSniffer

from urllib3.exceptions import MaxRetryError

from migrator import MigratorThread

import logging

_LOGGER = logging.getLogger(pathlib.Path(__file__).name)

class RemoteChromiumFactory(ChromiumFactory):
  def __init__(self, cmd_executor: str = "http://localhost:4444/wd/hub",
               max_attempts: int = 3, retry_delay: int = 2):
    self.cmd_executor = cmd_executor
    super(RemoteChromiumFactory, self).__init__(max_attempts=max_attempts,
                                            retry_delay=retry_delay)

  def create(self, url: str, protocol: str) -> WebDriver:
    options = ChromiumFactory.chrome_options(url, protocol)
    for attempt in range(self.max_attempts):
      try:
        driver = webdriver.Remote(
          desired_capabilities=options.to_capabilities(),
          command_executor=self.cmd_executor)
        return driver
      except (WebDriverException, MaxRetryError):
        if attempt == (self.max_attempts - 1):
          raise
        time.sleep(self.retry_delay)


def get_trace(url, strategy, period, max_tries=3, try_no=0):
  _LOGGER.info(f"Collecting trace for {url}")
  ifaces = ["wgnet0", "wgnet1", "wgnet2"]
  migrator = MigratorThread(strategy, period, ifaces=ifaces)
  result: Result = dict(url=url, protocol="tcp", final_url=None,
                      page_source=None, status='success', http_trace=[],
                      packets=b'')
  session_factory = ChromiumSessionFactory(driver_factory=RemoteChromiumFactory())
  sniffers = []
  for iface in ifaces:
    sniffers.append(TCPDumpPacketSniffer(iface=iface))
    if strategy == "none":
      break

  with session_factory.create(url, "tcp") as session:
    migrator.start()
    for sniffer in sniffers:
      sniffer.start_delay = 0.1
      sniffer.start()
    time.sleep(2) # delay here instead of in thread
    try:
      result['page_source'] = session.fetch_page()
      result.update({'final_url': session.current_url,
                     'http_trace': session.performance_log(),
                     'status': 'success'})
    except FetchTimeout as error:
      result["status"] = "timeout"
    except (
        FetchFailed, UnexpectedAlertPresentException, WebDriverException
    ) as error:
        result['status'] = 'failure'
        _LOGGER.info('Failed to fetch %s [%s]: %s', url, "tcp", error)
    finally:
      time.sleep(2) # delay here instead of in thread
      for sniffer in sniffers:
        sniffer.stop_delay = 0.1
        sniffer.stop()
      migrator.join()

    if result["status"] == "success":
      results = []
      for sniffer in sniffers:
        resultcopy = copy.deepcopy(result)
        resultcopy["packets"] = sniffer.results
        results.append(resultcopy)
    else:
      _LOGGER.warning(f"Trace collection for {url} failed")
      return [result]
    return results


def sample_traces(urls, n_traces=30, outfile=sys.stdout):
  for url in urls:
    results = []
    while len(results) < n_traces:
      new_traces =  get_trace(url, "wr", 0.1)
      results += new_traces
      if len(new_traces) == 1:
        break
    for result in results:
      outfile.write(encode_result(result))
      outfile.write('\n')
      outfile.flush()


def collect_all_traces(strategy="none", period=0.2, outfile=sys.stdout):
  lines = sys.stdin.readlines()
  #sample_traces(lines, n_traces=1)
  sample_traces(lines, n_traces=100)


if __name__=="__main__":
  logging.basicConfig(
    format='[%(asctime)s] %(name)s - %(levelname)s - %(message)s',
    level=logging.INFO)
  random.seed(42)
  #sample_traces(lines, n_traces=3)
  collect_all_traces("ur", 0.1)
