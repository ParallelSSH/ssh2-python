import unittest

from ssh2.utils import read_line


class UtilsTest(unittest.TestCase):

    def test_line(self):
        lines = [b'a line', b'another line', b'third']
        buf = b"\n".join(lines)
        pos = 0
        line_num = 0
        cur_pos, line = read_line(buf[pos:])
        while line is not None:
            self.assertEqual(lines[line_num], line)
            self.assertEqual(cur_pos, len(lines[line_num]) + 1)
            pos += cur_pos
            line_num += 1
            cur_pos, line = read_line(buf[pos:])
        self.assertEqual(pos, len(buf)+1)
