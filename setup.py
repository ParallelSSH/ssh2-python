from __future__ import print_function

import platform
import os
import sys
import glob

# import versioneer
from setuptools import setup, find_packages, Extension

cpython = platform.python_implementation() == 'CPython'

try:
    from Cython.Build import cythonize
except ImportError:
    USING_CYTHON = False
else:
    USING_CYTHON = True

ext = 'pyx' if USING_CYTHON else 'c'

sources = glob.glob("ssh2/ext/*.%s" % (ext,))
extensions = sources

extensions = [
    Extension('ssh2/*',
              sources=['ssh2/*.pyx'],
              libraries=['ssh2'],
              # extra_compile_args=["-O3"],
              extra_compile_args=["-ggdb"],
              # For conditional compilation
              # pyrex_compile_time_env
    )
    # for ext in extensions
]

if USING_CYTHON:
    extensions = cythonize(
        extensions,
        compiler_directives={'embedsignature': True,
                             'optimize.use_switch': True,
                             # 'boundscheck': False,
                             'wraparound': False,
                         })

setup(
    name='ssh2-python',
    # version=versioneer.get_version(),
    version='0.2.0',
    url='https://github.com/ParallelSSH/ssh2-python',
    license='LGPLv2',
    author='Panos Kittenis',
    author_email='22e889d8@opayq.com',
    description=('Python bindings for libssh2 based on Cython'),
    long_description=open('README.rst').read(),
    packages=find_packages('.'),
    zip_safe=False,
    include_package_data=True,
    platforms='any',
    classifiers=[
        'Intended Audience :: Developers',
        'Operating System :: OS Independent',
        'Programming Language :: Python',
        'Programming Language :: Python :: 2',
        'Programming Language :: Python :: 3',
    ],
    ext_modules=extensions,
)
