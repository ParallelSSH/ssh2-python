import unittest

from ssh2.utils import find_eol


class UtilsTest(unittest.TestCase):

    def test_find_eol_no_lines(self):
        buf = b"a buffer"
        linepos, new_line_pos = find_eol(buf, 0)
        self.assertEqual(linepos, -1)
        self.assertEqual(new_line_pos, 0)

    def test_read_line(self):
        lines = [b'a line', b'another line', b'third']
        buf = b"\n".join(lines)
        pos = 0
        line_num = 0
        linesep, new_line_pos = find_eol(buf, 0)
        self.assertTrue(linesep > 0)
        self.assertTrue(linesep < len(buf))
        while pos < len(buf):
            if linesep < 0:
                break
            end_of_line = pos + linesep
            line = buf[pos:end_of_line]
            self.assertEqual(lines[line_num], line)
            pos += linesep + new_line_pos
            line_num += 1
            linesep, new_line_pos = find_eol(buf, pos)
        line = buf[pos:]
        self.assertEqual(lines[line_num], line)

    def test_read_line_crnl(self):
        lines = [b'a line', b'another line', b'third']
        buf = b"\r\n".join(lines)
        pos = 0
        line_num = 0
        linesep, new_line_pos = find_eol(buf, 0)
        self.assertTrue(linesep > 0)
        self.assertTrue(linesep < len(buf))
        while pos < len(buf):
            if linesep < 0:
                break
            end_of_line = pos + linesep
            line = buf[pos:end_of_line]
            self.assertEqual(lines[line_num], line)
            pos += linesep + new_line_pos
            line_num += 1
            linesep, new_line_pos = find_eol(buf, pos)
        line = buf[pos:]
        self.assertEqual(lines[line_num], line)

    def test_read_line_cr_only(self):
        lines = [b'a line', b'another line', b'third']
        buf = b"\r".join(lines)
        linesep, new_line_pos = find_eol(buf, 0)
        self.assertEqual(linesep, -1)

    def test_read_line_bad_data(self):
        linesep, new_line_pos = find_eol(b"", 0)
        self.assertEqual(linesep, -1)
        self.assertEqual(new_line_pos, 0)
        linesep, new_line_pos = find_eol(b'\n', 0)
        self.assertEqual(linesep, 0)
        self.assertEqual(new_line_pos, 1)
        linesep, new_line_pos = find_eol(b'\r\n', 0)
        self.assertEqual(linesep, 0)
        self.assertEqual(new_line_pos, 2)
        linesep, new_line_pos = find_eol(b'\r', 0)
        self.assertEqual(linesep, -1)
        self.assertEqual(new_line_pos, 0)
