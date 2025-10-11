#  This file is part of ssh2-python.
#  Copyright (C) 2017-2025 Panos Kittenis
#
#  This library is free software; you can redistribute it and/or
#  modify it under the terms of the GNU Lesser General Public
#  License as published by the Free Software Foundation, version 2.1.
#
#  This library is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#  Lesser General Public License for more details.
#
#  You should have received a copy of the GNU Lesser General Public
#  License along with this library; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

import sys
import subprocess
import os


def upload_pypi(files):
    repo_tag = os.environ['APPVEYOR_REPO_TAG']
    if repo_tag == 'false':
        sys.stderr.write("Not a tagged release, skipping upload" + os.linesep)
        return
    _user, _pass = os.environ['PYPI_USER'], os.environ['PYPI_PASS']
    try:
        subprocess.check_call(['twine', 'upload', '-u', _user,
                               '-p', _pass, files])
    except Exception:
        sys.stderr.write("Error uploading to PyPi" + os.linesep)


if __name__ == "__main__":
    if not len(sys.argv) > 1:
        sys.stderr.write("Need files to upload argument" + os.linesep)
        sys.exit(1)
    upload_pypi(os.path.abspath(sys.argv[1]))
