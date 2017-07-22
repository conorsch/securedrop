# -*- coding: utf-8 -*-

from datetime import datetime
import mock
from multiprocessing import Process
import os
from os.path import abspath, dirname, join, realpath
from os.path import abspath, dirname, expanduser, join, realpath
import shutil
import signal
import socket
import time
import traceback
import requests

from Crypto import Random
from selenium import webdriver
import gnupg
from selenium.common.exceptions import WebDriverException
from tbselenium.tbdriver import TorBrowserDriver

os.environ['SECUREDROP_ENV'] = 'test'  # noqa
import db
import journalist
import source
import tests.utils.env as env

FUNCTIONAL_TEST_DIR = abspath(dirname(__file__))
LOGFILE_PATH = abspath(join(FUNCTIONAL_TEST_DIR, '../log/firefox.log'))
TBB_PATH = abspath(join(expanduser('~'), '.local/tbb/tor-browser_en-US'))


class FunctionalTest():

    def _unused_port(self):
        s = socket.socket()
        s.bind(('127.0.0.1', 0))
        port = s.getsockname()[1]
        s.close()
        return port

    def _create_webdriver(self):
        log_msg = '\n\n[{}] Running Functional Tests\n'.format(datetime.now())
        with open(LOGFILE_PATH, 'a') as f:
            f.write(log_msg)
        # Don't use Tor when reading from localhost, and turn off private
        # browsing. We need to turn off private browsing because we won't be
        # able to access the browser's cookies in private browsing mode. Since
        # we use session cookies in SD anyway (in private browsing mode all
        # cookies are set as session cookies), this should not affect session
        # lifetime.
        pref_dict = {'network.proxy.no_proxies_on': '127.0.0.1',
                     'browser.privatebrowsing.autostart': False}
        tbb_path = abspath(join(expanduser('~'),
                                '.local/tbb/tor-browser_en-US'))
        driver = TorBrowserDriver(TBB_PATH,
                                  pref_dict=pref_dict,
                                  tbb_logfile_path=LOGFILE_PATH)
        return driver

    def setup(self):
        # Patch the two-factor verification to avoid intermittent errors
        self.patcher = mock.patch('journalist.Journalist.verify_token')
        self.mock_journalist_verify_token = self.patcher.start()
        self.mock_journalist_verify_token.return_value = True

        signal.signal(signal.SIGUSR1, lambda _, s: traceback.print_stack(s))

        env.create_directories()
        self.gpg = env.init_gpg()
        db.init_db()

        source_port = self._unused_port()
        journalist_port = self._unused_port()

        self.source_location = "http://127.0.0.1:%d" % source_port
        self.journalist_location = "http://127.0.0.1:%d" % journalist_port

        def start_source_server():
            # We call Random.atfork() here because we fork the source and
            # journalist server from the main Python process we use to drive
            # our browser with multiprocessing.Process() below. These child
            # processes inherit the same RNG state as the parent process, which
            # is a problem because they would produce identical output if we
            # didn't re-seed them after forking.
            Random.atfork()
            source.app.run(
                port=source_port,
                debug=True,
                use_reloader=False,
                threaded=True)

        def start_journalist_server():
            Random.atfork()
            journalist.app.run(
                port=journalist_port,
                debug=True,
                use_reloader=False,
                threaded=True)

        self.source_process = Process(target=start_source_server)
        self.journalist_process = Process(target=start_journalist_server)

        self.source_process.start()
        self.journalist_process.start()
        self.driver = self._create_webdriver()

        for tick in range(30):
            try:
                requests.get(self.source_location)
                requests.get(self.journalist_location)
            except:
                time.sleep(1)
            else:
                break

        # Set window size and position explicitly to avoid potential bugs due
        # to discrepancies between environments.
        self.driver.set_window_position(0, 0)
        self.driver.set_window_size(1024, 768)

        # Poll the DOM briefly to wait for elements. It appears .click() does
        # not always do a good job waiting for the page to load, or perhaps
        # Firefox takes too long to render it (#399)
        self.driver.implicitly_wait(5)
        self.secret_message = 'blah blah blah'

    def teardown(self):
        self.patcher.stop()
        env.teardown()
        self.driver.quit()
        self.source_process.terminate()
        self.journalist_process.terminate()

    def wait_for(self, function_with_assertion, timeout=5):
        """Polling wait for an arbitrary assertion."""
        # Thanks to
        # http://chimera.labs.oreilly.com/books/1234000000754/ch20.html#_a_common_selenium_problem_race_conditions
        start_time = time.time()
        while time.time() - start_time < timeout:
            try:
                return function_with_assertion()
            except (AssertionError, WebDriverException):
                time.sleep(0.1)
        # one more try, which will raise any errors if they are outstanding
        return function_with_assertion()
