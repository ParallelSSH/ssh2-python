mkdir src && cd src

%CMD_IN_ENV% cmake ..\libssh2 -G "NMake Makefiles"          ^
	-DCMAKE_BUILD_TYPE=Release             ^
	-DCRYPTO_BACKEND=WinCNG                ^
	-G"Visual Studio 14"
	-DBUILD_SHARED_LIBS=OFF

%CMD_IN_ENV% cmake --build . --config Release
cd ..
ls src/src
cp src/src/libssh2.lib %PYTHON%/libs/ || cp src/src/Release/libssh2.lib %PYTHON%/libs/
ls %PYTHON%/libs/
