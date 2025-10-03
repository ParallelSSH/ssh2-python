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
