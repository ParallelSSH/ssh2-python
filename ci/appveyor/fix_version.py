#  This file is part of ssh2-python.
#  Copyright (C) 2017-2025 Panos Kittenis.
#  Copyright (C) 2017-2025 ssh2-python Contributors.
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

import os
from datetime import datetime
import subprocess
import json
import sys


def get_describe_tag():
    return subprocess.check_output(['git', 'describe', '--tags']).strip().decode('utf-8').split('-')[0]


def make_version_file(basedir):
    rev = os.environ.get('APPVEYOR_REPO_COMMIT',
                         subprocess.check_output(['git', 'rev-list', '--max-count=1', 'HEAD']).strip().decode('utf-8'))
    basedir = os.path.abspath(basedir)
    git_desc = get_describe_tag()
    version_json = {'date': datetime.now().isoformat(),
                    'dirty': False,
                    'error': None,
                    'full-revisionid': rev,
                    'version': git_desc}
    data = """
import json

version_json = '''
%s'''  # END VERSION_JSON


def get_versions():
    return json.loads(version_json)

""" % (json.dumps(version_json))
    with open(os.path.join(basedir, 'ssh2', '_version.py'), 'w') as fh:
        fh.write(data)


if __name__ == "__main__":
    if not len(sys.argv) > 1:
        sys.stderr.write("Need basedir of repo" + os.linesep)
        sys.exit(1)
    make_version_file(sys.argv[1])
