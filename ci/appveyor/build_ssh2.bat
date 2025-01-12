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


dir %OPENSSL_DIR%\lib\VC\x64\
cp %OPENSSL_DIR%\lib\VC\x64\MD\libcrypto.lib %APPVEYOR_BUILD_FOLDER%\libcrypto64MD.lib
cp %OPENSSL_DIR%\lib\VC\x64\MD\libssl.lib %APPVEYOR_BUILD_FOLDER%\libssl64MD.lib

dir %APPVEYOR_BUILD_FOLDER%\

cmake --build . --config Release
cd ..
