from __future__ import print_function

import platform
import os
import sys
from glob import glob
from multiprocessing import cpu_count

import versioneer
from setuptools import setup, find_packages

cpython = platform.python_implementation() == 'CPython'

try:
    from Cython.Distutils.extension import Extension
    from Cython.Distutils import build_ext
except ImportError:
    from setuptools import Extension
    USING_CYTHON = False
else:
    USING_CYTHON = True

ON_WINDOWS = platform.system() == 'Windows'

ext = 'pyx' if USING_CYTHON else 'c'
sources = glob('ssh2/*.%s' % (ext,))
_libs = ['ssh2'] if not ON_WINDOWS else [
    'Ws2_32', 'libssh2', 'user32',
    'libeay32MD', 'ssleay32MD',
    'zlibstatic',
]

# _comp_args = ["-ggdb"]
_comp_args = ["-O3"] if not ON_WINDOWS else None
_embedded_lib = bool(os.environ.get('EMBEDDED_LIB', 1))
cython_directives = {'embedsignature': True,
                     'boundscheck': False,
                     'optimize.use_switch': True,
                     'wraparound': False,
}
cython_args = {
    'cython_directives': cython_directives,
    'cython_compile_time_env': {'EMBEDDED_LIB': _embedded_lib}} \
    if USING_CYTHON else {}

extensions = [
    Extension(sources[i].split('.')[0].replace(os.path.sep, '.'),
              sources=[sources[i]],
              include_dirs=["libssh2/include"],
              libraries=_libs,
              extra_compile_args=_comp_args,
              **cython_args
    )
    for i in range(len(sources))]

package_data = {'ssh2': ['*.pxd']}

if ON_WINDOWS:
    package_data['ssh2'].extend([
        'libeay32.dll', 'ssleay32.dll',
    ])

cmdclass = versioneer.get_cmdclass()
if USING_CYTHON:
    cmdclass['build_ext'] = build_ext

setup(
    name='ssh2-python',
    version=versioneer.get_version(),
    cmdclass=cmdclass,
    url='https://github.com/ParallelSSH/ssh2-python',
    license='LGPLv2',
    author='Panos Kittenis',
    author_email='22e889d8@opayq.com',
    description=('Super fast SSH library - bindings for libssh2'),
    long_description=open('README.rst').read(),
    packages=find_packages(
        '.', exclude=('embedded_server', 'embedded_server.*',
                      'tests', 'tests.*',
                      '*.tests', '*.tests.*')),
    zip_safe=False,
    include_package_data=True,
    platforms='any',
    classifiers=[
        'License :: OSI Approved :: GNU Lesser General Public License v2 (LGPLv2)',
        'Intended Audience :: Developers',
        'Operating System :: OS Independent',
        'Programming Language :: Python',
        'Programming Language :: Python :: 2',
        'Programming Language :: Python :: 2.6',
        'Programming Language :: Python :: 2.7',
        'Programming Language :: Python :: 3',
        'Programming Language :: Python :: 3.4',
        'Programming Language :: Python :: 3.5',
        'Programming Language :: Python :: 3.6',
        'Topic :: Software Development :: Libraries :: Python Modules',
        'Operating System :: POSIX :: Linux',
        'Operating System :: POSIX :: BSD',
    ],
    ext_modules=extensions,
    package_data=package_data,
)
