import os
import glob
import shutil
from conda_build.config import Config

binary_package_glob = os.path.join(Config().bldpkgs_dir, '*.tar.bz2')

try:
    binary_package = glob.glob(binary_package_glob)[0]
except IndexError:
    pass
else:
    shutil.move(binary_package, '.')
