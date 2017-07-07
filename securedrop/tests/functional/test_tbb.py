from tbselenium.tbdriver import TorBrowserDriver


TBB_PATH = "/home/anon/.local/share/torbrowser/tbb/"

with TorBrowserDriver(TBB_PATH) as driver:
        driver.et('https://check.torproject.org')
