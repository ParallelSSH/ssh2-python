import pwd
import os
import socket
import threading
import gc

from .base_test import SSH2TestCase, PKEY_FILENAME, PUB_FILE
from ssh2.session import Session
from ssh2.channel import Channel


class TestClient:
    _session = None
    _sock = None

    def __init__(self, host, port, user_key, user_pub_key, user):
        self._host = host
        self._port = port
        self._user_key = user_key
        self._user_pub_key = user_pub_key
        self._user = user

    def connect(self):
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.connect((self._host, self._port))
        self._sock = sock
        self._session = Session()
        self._session.set_timeout(500)
        self._session.set_blocking(0)
        self._session.handshake(self._sock)

    def auth(self):
        return self._session.userauth_publickey_fromfile(self._user, self._user_key)

    def open_channel(self):
        try:
            return self._session.open_session()
        except:
            return None

    def execute(self, cmd):
        chan = self._session.open_session()
        chan.execute(cmd)
        chan.wait_eof()
        chan.close()
        chan.wait_closed()
        return chan.get_exit_status(), chan.read(), chan.read_stderr()

    def disconnect(self):
        self._session.disconnect()


def run_in_multiple_threads(num, body):
    threads = []
    for _ in range(num):
        threads.append(threading.Thread(target=body))

    for thread in threads:
        thread.start()

    for thread in threads:
        thread.join()

threadLocal = threading.local()

class MultiThreadingTest(SSH2TestCase):
    def test_execute_in_thread(self):
        while True:
            def thread_body():
                threadLocal.cl = TestClient('127.0.0.1', 2222, PKEY_FILENAME, PUB_FILE, pwd.getpwuid(os.geteuid()).pw_name)
                threadLocal.cl.connect()
                threadLocal.cl.auth()
                threadLocal.channs = []
                for n in range(10):
                    if chan := threadLocal.cl.open_channel():
                        if isinstance(chan, Channel):
                            chan.execute('true')
                            print(len(threadLocal.channs))
                            threadLocal.channs.append(chan)
            run_in_multiple_threads(10, thread_body)
