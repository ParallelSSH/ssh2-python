mkdir src
cd src

ECHO "Building with platform %MSVC%"
cmake ..\libssh2 -G "NMake Makefiles"         ^
       -DCMAKE_BUILD_TYPE=Release             ^
       -DCRYPTO_BACKEND=OpenSSL               ^
       -G"%MSVC%"                             ^
       -DBUILD_SHARED_LIBS=OFF                ^
       -DENABLE_ZLIB_COMPRESSION=ON           ^
       -DENABLE_CRYPT_NONE=ON                 ^
       -DENABLE_MAC_NONE=ON                   ^
       -DZLIB_LIBRARY=C:/zlib/lib/zlib.lib    ^
       -DZLIB_INCLUDE_DIR=C:/zlib/include     ^
       -DOPENSSL_ROOT_DIR=%OPENSSL_DIR%
)

cp %OPENSSL_DIR%\lib\VC\libcrypto%PYTHON_ARCH%MD.lib %APPVEYOR_BUILD_FOLDER%
cp %OPENSSL_DIR%\lib\VC\libssl%PYTHON_ARCH%MD.lib %APPVEYOR_BUILD_FOLDER%

cmake --build . --config Release
cd ..
cp src/src/libssh2.lib %PYTHON%/libs/ || cp src/src/Release/libssh2.lib %PYTHON%/libs/
