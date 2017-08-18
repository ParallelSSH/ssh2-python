mkdir src && cd src

cmake ..\libssh2 -G "NMake Makefiles"          ^
	-DCMAKE_BUILD_TYPE=Release             ^
	-DCRYPTO_BACKEND=WinCNG                ^
	-G"Visual Studio %MSVC_VER%"           ^
	-DCMAKE_SYSTEM_PROCESSOR=MSVC_ARCH%    ^
	-DBUILD_SHARED_LIBS=OFF

cmake --build . --config Release
cd ..
ls src/src
cp src/src/libssh2.lib %PYTHON%/libs/ || cp src/src/Release/libssh2.lib %PYTHON%/libs/
ls %PYTHON%/libs/
