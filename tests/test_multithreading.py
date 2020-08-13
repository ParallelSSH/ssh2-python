import pwd
import os
import socket
import threading
import gc

from .base_test import SSH2TestCase, PKEY_FILENAME, PUB_FILE
from ssh2.session import Session


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
        self._session.handshake(self._sock)

    def auth(self):
        return self._session.userauth_publickey_fromfile(self._user, self._user_key)

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


class MultiThreadingTest(SSH2TestCase):
    def test_execute_in_thread(self):
        for _ in range(10):
            cl = TestClient('127.0.0.1', 2222, PKEY_FILENAME, PUB_FILE, pwd.getpwuid(os.geteuid()).pw_name)
            cl.connect()
            cl.auth()
            
            def thread_body():
                cl.execute('echo "123123"')
            run_in_multiple_threads(5, thread_body)
            gc.collect()
