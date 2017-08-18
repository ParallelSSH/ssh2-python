import sys
import os
from glob import glob
import subprocess
import traceback


cmd = ['anaconda', '-t', os.environ['ANACONDA_TOKEN'], 'upload']
cmd.extend(glob('*.tar.bz2'))
try:
    subprocess.check_call(cmd)
except subprocess.CalledProcessError:
    sys.exit(1)
