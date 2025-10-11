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

dir ssh2/

for %%I in (%PYTHONVERS%) do %%I\python.exe -V
for %%I in (%PYTHONVERS%) do %%I\python.exe setup.py build_ext
for %%I in (%PYTHONVERS%) do %%I\python.exe setup.py build
for %%I in (%PYTHONVERS%) do %%I\python.exe setup.py install

dir ssh2/

cd dist
for %%I in (%PYTHONVERS%) do %%I\python.exe -c "from ssh2.session import Session; Session()"
cd ..

for %%I in (%PYTHONVERS%) do %%I\python.exe setup.py bdist_wheel
mv dist/* .
