from __future__ import print_function

import platform
import os
import sys
from glob import glob

# import versioneer
from setuptools import setup, find_packages, Extension

cpython = platform.python_implementation() == 'CPython'

try:
    from Cython.Build import cythonize
except ImportError:
    USING_CYTHON = False
else:
    USING_CYTHON = True

names = 'ssh2/*'
ext = 'pyx' if USING_CYTHON else 'c'
sources = ['ssh2/*.%s' % (ext,)]


if USING_CYTHON:
    extensions = [
        Extension('ssh2/*',
                  sources=sources,
                  libraries=['ssh2'],
                  # extra_compile_args=["-O3"],
                  extra_compile_args=["-ggdb"],
                  # For conditional compilation
                  # pyrex_compile_time_env
        )
        # for ext in extensions
    ]
    extensions = cythonize(
        extensions,
        compiler_directives={'embedsignature': True,
                             'optimize.use_switch': True,
                             # 'boundscheck': False,
                             'wraparound': False,
                         })
else:
    sources = glob(sources[0])
    # names = [ for s in sources]
    extensions = [
        Extension(sources[i].split('.')[0].replace('/', '.'),
                  sources=[sources[i]],
                  libraries=['ssh2'],
                  # extra_compile_args=["-O3"],
                  extra_compile_args=["-ggdb"],
                  # For conditional compilation
                  # pyrex_compile_time_env
        )
        for i in range(len(sources))]

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
