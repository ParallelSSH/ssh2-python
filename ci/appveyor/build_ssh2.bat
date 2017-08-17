mkdir src && cd src

cmake ..\libssh2 -G "NMake Makefiles"          ^
	-DCMAKE_BUILD_TYPE=Release             ^
	-DCRYPTO_BACKEND=WinCNG                ^
	-DBUILD_SHARED_LIBS=OFF

cmake --build . --config Release
ls src
