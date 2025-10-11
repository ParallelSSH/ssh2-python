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

IF "%PYTHON_VERSION%" == "2.7" (exit 0)

mkdir zlib_build && cd zlib_build

cmake ..\zlib-1.3.1                              ^
    -A x64                                       ^
    -DCMAKE_INSTALL_PREFIX="C:\zlib"             ^
    -DCMAKE_BUILD_TYPE=Release                   ^
    -DBUILD_SHARED_LIBS=OFF
)

cmake --build . --config Release --target install
cd ..
