import platform
import os
import sys
from glob import glob

from _setup_libssh2 import build_ssh2

import versioneer
from setuptools import setup, find_packages

cpython = platform.python_implementation() == 'CPython'

try:
    from Cython.Distutils.extension import Extension
    from Cython.Distutils import build_ext
    from Cython.Build import cythonize
except ImportError:
    from setuptools import Extension
    USING_CYTHON = False
else:
    USING_CYTHON = True

ON_WINDOWS = platform.system() == 'Windows'
SYSTEM_LIBSSH2 = bool(os.environ.get('SYSTEM_LIBSSH2', 0)) or ON_WINDOWS

# Only build libssh2 if SYSTEM_LIBSSH2 is not set and running a build
if not SYSTEM_LIBSSH2 and (len(sys.argv) >= 2 and not (
        '--help' in sys.argv[1:] or
        sys.argv[1] in (
            '--help-commands', 'egg_info', '--version', 'clean',
            'sdist', '--long-description')) and
                           __name__ == '__main__'):
    build_ssh2()

ext = 'pyx' if USING_CYTHON else 'c'
sources = glob('ssh2/*.%s' % (ext,))
_arch = platform.architecture()[0][0:2]
_libs = ['ssh2'] if not ON_WINDOWS else [
    'Ws2_32', 'libssh2', 'user32',
    'libcrypto%sMD' % _arch, 'libssl%sMD' % _arch,
    'zlibstatic',
]

# _comp_args = ["-ggdb"]
_fwd_default = 0
_comp_args = ["-O2"] if not ON_WINDOWS else None

compiler_directives = {'embedsignature': True,
                     'boundscheck': False,
                     'optimize.use_switch': True,
                     'wraparound': False,
                     'language_level': 2,
}
cython_args = {
    'compiler_directives': compiler_directives,
    'compile_time_env': {},
}

if USING_CYTHON:
    sys.stdout.write("Cython arguments: %s%s" % (cython_args, os.linesep))


runtime_library_dirs = ["$ORIGIN/."] if not SYSTEM_LIBSSH2 else None
_lib_dir = os.path.abspath("./build_dir/src") if not SYSTEM_LIBSSH2 else "/usr/local/lib"
include_dirs = ["libssh2/include"] if ON_WINDOWS or not SYSTEM_LIBSSH2 else ["/usr/local/include"]

extensions = [
    Extension(sources[i].split('.')[0].replace(os.path.sep, '.'),
              sources=[sources[i]],
              include_dirs=include_dirs,
              libraries=_libs,
              library_dirs=[_lib_dir],
              runtime_library_dirs=runtime_library_dirs,
              extra_compile_args=_comp_args,
              )
    for i in range(len(sources))]

for ext in extensions:
    if ext.name == 'ssh2.utils':
        ext.sources.append('ssh2/ext/find_eol.c')

package_data = {'ssh2': ['*.pxd', 'libssh2.so*']}

if ON_WINDOWS:
    package_data['ssh2'].extend([
        'libcrypto*.dll', 'libssl*.dll',
        'msvc*.dll', 'vcruntime*.dll',
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
    description='Bindings for libssh2 C library',
    long_description=open('README.rst').read(),
    packages=find_packages(
        '.', exclude=('embedded_server', 'embedded_server.*',
                      'tests', 'tests.*',
                      '*.tests', '*.tests.*')),
    zip_safe=False,
    include_package_data=False,
    platforms='any',
    classifiers=[
        'Development Status :: 5 - Production/Stable',
        'License :: OSI Approved :: GNU Lesser General Public License v2 (LGPLv2)',
        'Intended Audience :: Developers',
        'Operating System :: OS Independent',
        'Programming Language :: C',
        'Programming Language :: Python',
        'Programming Language :: Python :: 3',
        'Programming Language :: Python :: 3.6',
        'Programming Language :: Python :: 3.7',
        'Programming Language :: Python :: 3.8',
        'Programming Language :: Python :: 3.9',
        'Programming Language :: Python :: 3.10',
        'Topic :: System :: Shells',
        'Topic :: System :: Networking',
        'Topic :: Software Development :: Libraries',
        'Topic :: Software Development :: Libraries :: Python Modules',
        'Operating System :: POSIX',
        'Operating System :: POSIX :: Linux',
        'Operating System :: POSIX :: BSD',
        'Operating System :: Microsoft :: Windows',
        'Operating System :: MacOS :: MacOS X',
    ],
    ext_modules=cythonize(extensions, **cython_args) if USING_CYTHON else extensions,
    package_data=package_data,
)
