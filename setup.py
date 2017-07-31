from __future__ import print_function

import platform
import os
import sys
from glob import glob
from multiprocessing import cpu_count

import versioneer
from setuptools import setup, find_packages, Extension

cpython = platform.python_implementation() == 'CPython'

try:
    from Cython.Build import cythonize
except ImportError:
    USING_CYTHON = False
else:
    USING_CYTHON = True

ext = 'pyx' if USING_CYTHON else 'c'
sources = ['ssh2/*.%s' % (ext,)]
_libs = ['ssh2']
_comp_args = ["-ggdb"] # , "-O3"]

if USING_CYTHON:
    extensions = [
        Extension('ssh2/*',
                  sources=sources,
                  libraries=_libs,
                  extra_compile_args=_comp_args,
                  # For conditional compilation
                  # pyrex_compile_time_env
        )
    ]
    extensions = cythonize(
        extensions,
        compiler_directives={'embedsignature': True,
                             'optimize.use_switch': True,
                             'boundscheck': False,
                             'wraparound': False,
                         },
        nthreads=cpu_count())
else:
    sources = glob(sources[0])
    extensions = [
        Extension(sources[i].split('.')[0].replace('/', '.'),
                  sources=[sources[i]],
                  libraries=_libs,
                  extra_compile_args=_comp_args,
                  # For conditional compilation
                  # pyrex_compile_time_env
        )
        for i in range(len(sources))]

setup(
    name='ssh2-python',
    version=versioneer.get_version(),
    cmdclass=versioneer.get_cmdclass(),
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
    package_data={'ssh2': ['*.pxd']},
)
