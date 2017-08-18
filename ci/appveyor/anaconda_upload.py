import sys
import os
from glob import glob
import subprocess
import traceback


subprocess.check_call(['anaconda', 'logout'])
cmd = ['anaconda', 'login', '--username', 'parallelssh',
       '--password', os.environ['ANACONDA_PASSWORD']]
try:
    subprocess.check_call(cmd)
except subprocess.CalledProcessError, ex:
    sys.exit(1)
cmd = ['anaconda', 'upload']
cmd.extend(glob('*.tar.bz2'))
try:
    subprocess.check_call(cmd)
except subprocess.CalledProcessError:
    traceback.print_exc()
