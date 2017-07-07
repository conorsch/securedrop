from tbselenium.tbdriver import TorBrowserDriver
import os


TBB_DIR = os.environ["TBB_DIR"]
TBB_PATH = "{}/tor-browser_en-US".format(TBB_DIR)

print("TBB fails to initialize hereafter.")
driver = TorBrowserDriver(TBB_PATH)
driver.et('https://check.torproject.org')
