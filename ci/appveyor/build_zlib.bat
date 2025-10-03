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
