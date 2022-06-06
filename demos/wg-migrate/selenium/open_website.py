import sys
import time

from selenium import webdriver
from selenium.webdriver import ChromeOptions


if len(sys.argv) < 2:
  sys.exit("Please supply a hostname to fetch.")

hostname = sys.argv[1]

opt = ChromeOptions()
# opt.add_argument("--no-sandbox")
# opt.add_argument("--headless")
# opt.add_argument("--origin-to-force-quic-on=*")
# opt.add_argument("--origin-to-force-quic-on=www.example.org:443")
# opt.add_argument("--host-resolver-rules=MAP www.example.org:443 server:6121")


# remote driver
driver = webdriver.Remote(
  desired_capabilities=opt.to_capabilities(),
  command_executor="http://localhost:4444/wd/hub") 

driver.get(hostname)

print("get done")

time.sleep(20)
