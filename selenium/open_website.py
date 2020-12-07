from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.webdriver import ChromeOptions


opt = ChromeOptions()
opt.add_argument("--no-sandbox")
opt.add_argument("--disable-setuid-sandbox")
opt.add_argument("--enable-quic")
opt.add_argument("--origin-to-force-quic-on=www.google.com")


# remote driver
driver = webdriver.Remote(
  desired_capabilities=opt.to_capabilities(),
  command_executor="http://localhost:4444/wd/hub") 

# driver = webdriver.Chrome()

driver.get("https://www.google.com")
assert "Goog" in driver.title
driver.close()
