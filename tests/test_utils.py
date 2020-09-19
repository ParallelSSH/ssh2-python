import unittest

from ssh2.utils import read_line


class UtilsTest(unittest.TestCase):

    def test_read_line(self):
        lines = [b'a line', b'another line', b'third']
        buf = b"\n".join(lines)
        line_num = 0
        line, pos = read_line(buf, 0)
        self.assertTrue(pos > 0)
        self.assertTrue(pos < len(buf))
        while pos < len(buf):
            self.assertEqual(lines[line_num], line)
            line_num += 1
            line, pos = read_line(buf, pos)

    def test_read_line_crnl(self):
        lines = [b'a line', b'another line', b'third']
        buf = b"\r\n".join(lines)
        line_num = 0
        line, pos = read_line(buf, 0)
        self.assertTrue(pos > 0)
        self.assertTrue(pos < len(buf))
        while pos < len(buf):
            self.assertEqual(lines[line_num], line)
            line_num += 1
            line, pos = read_line(buf, pos)

    def test_read_line_cr_only(self):
        lines = [b'a line', b'another line', b'third']
        buf = b"\r".join(lines)
        line, pos = read_line(buf, 0)
        self.assertEqual(line, buf)

    def test_read_line_nonewline(self):
        buf = b"a line"
        line, pos = read_line(buf, 0)
        self.assertEqual(line, buf)
        self.assertEqual(pos, len(buf))

    def test_read_line_bad_data(self):
        line, pos = read_line(b"", 0)
        self.assertEqual(line, b"")
        self.assertEqual(pos, 0)
        line, pos = read_line(b'\n', 0)
        self.assertEqual(line, b"")
        self.assertEqual(pos, 1)
        line, pos = read_line(b'\r\n', 0)
        self.assertEqual(line, b"")
        self.assertEqual(pos, 2)
        line, pos = read_line(b'\r', 0)
        self.assertEqual(line, b"\r")
        self.assertEqual(pos, 1)
