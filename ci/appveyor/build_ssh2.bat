mkdir src && cd src

cmake ..\libssh2 -G "NMake Makefiles"          ^
	-DCMAKE_BUILD_TYPE=Release             ^
	-DCRYPTO_BACKEND=WinCNG                ^
	-DBUILD_SHARED_LIBS=OFF

cmake --build . --config Release
cd ..
ls src/src
cp src/src/libssh2.lib C:/Python27-x64/libs/
