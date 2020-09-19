import unittest

from ssh2.utils import read_line


class UtilsTest(unittest.TestCase):

    def test_read_line(self):
        lines = [b'a line', b'another line', b'third']
        buf = b"\n".join(lines)
        line_num = 0
        line, pos = read_line(buf, 0)
        while pos < len(buf):
            self.assertEqual(lines[line_num], line)
            line_num += 1
            line, pos = read_line(buf, pos)
