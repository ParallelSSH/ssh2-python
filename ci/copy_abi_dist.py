from __future__ import print_function

import os
from glob import glob
import re
import sys
import shutil


re_c = re.compile(r'.+-.+-.+-(.+)-.+\.')


def rename_dist_files(files):
    for _file in glob(files):
        match = re_c.match(_file)
        abi = match.group(1)
        new_file = _file.replace(abi, 'none')
    print("Copying %s to new file %s" % (_file, new_file))
    shutil.copy2(_file, new_file)

if __name__ == "__main__":
    if len(sys.argv) < 2:
        sys.stderr.write("Need files argument" + os.linesep)
        sys.exit(1)
    rename_dist_files(os.path.abspath(sys.argv[1]))
