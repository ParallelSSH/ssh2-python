@REM This file is part of ssh2-python.
@REM Copyright (C) 2017-2025 Panos Kittenis
@REM
@REM This library is free software; you can redistribute it and/or
@REM modify it under the terms of the GNU Lesser General Public
@REM License as published by the Free Software Foundation, version 2.1.
@REM
@REM This library is distributed in the hope that it will be useful,
@REM but WITHOUT ANY WARRANTY; without even the implied warranty of
@REM MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
@REM Lesser General Public License for more details.
@REM
@REM You should have received a copy of the GNU Lesser General Public
@REM License along with this library; if not, write to the Free Software
@REM Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

mkdir build_dir
cd build_dir

ECHO "Building with platform %MSVC%"
cmake ..\libssh2 -G "NMake Makefiles" ^
       -DCMAKE_BUILD_TYPE=Release             ^
       -DCRYPTO_BACKEND=OpenSSL               ^
       -G"%MSVC%"                             ^
       -A x64                                 ^
       -DBUILD_SHARED_LIBS=OFF                ^
       -DENABLE_ZLIB_COMPRESSION=ON           ^
       -DENABLE_CRYPT_NONE=ON                 ^
       -DENABLE_MAC_NONE=ON                   ^
       -DZLIB_LIBRARY=C:/zlib/lib/zlib.lib    ^
       -DZLIB_INCLUDE_DIR=C:/zlib/include     ^
       -DBUILD_EXAMPLES=OFF                   ^
       -DBUILD_TESTING=OFF                    ^
       -DOPENSSL_ROOT_DIR=%OPENSSL_DIR%       ^
       -DOPENSSL_LIBRARIES=%OPENSSL_DIR%/lib/VC/x64/MD


dir %OPENSSL_DIR%\lib\VC\x64\MD\
cp %OPENSSL_DIR%\lib\VC\x64\MD\libcrypto.lib %APPVEYOR_BUILD_FOLDER%\libcrypto64MD.lib
cp %OPENSSL_DIR%\lib\VC\x64\MD\libssl.lib %APPVEYOR_BUILD_FOLDER%\libssl64MD.lib

dir %APPVEYOR_BUILD_FOLDER%\

cmake --build . --config Release
cd ..
