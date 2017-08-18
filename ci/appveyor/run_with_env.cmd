:: To build extensions for 64 bit Python 3.5 or later no special environment needs
:: to be configured for the Python extension code alone, however, all dependent
:: libraries also need to be compiled with the same SDK in order to be able to
:: link them together. 
::
:: This script sets SDK version and environment for all commands.
::
:: To build extensions for 64 bit Python 3.4 or earlier, we need to configure environment
:: variables to use the MSVC 2010 C++ compilers from GRMSDKX_EN_DVD.iso of:
:: MS Windows SDK for Windows 7 and .NET Framework 4 (SDK v7.1)
::
:: To build extensions for 64 bit Python 2, we need to configure environment
:: variables to use the MSVC 2008 C++ compilers from GRMSDKX_EN_DVD.iso of:
:: MS Windows SDK for Windows 7 and .NET Framework 3.5 (SDK v7.0)
::
:: 32 bit builds do not require specific environment configurations.
::
:: Note: this script needs to be run with the /E:ON and /V:ON flags for the
:: cmd interpreter, at least for (SDK v7.0)
::
:: More details at:
:: https://github.com/cython/cython/wiki/64BitCythonExtensionsOnWindows
:: https://stackoverflow.com/a/13751649/163740
::
:: Original Author: Olivier Grisel
:: License: CC0 1.0 Universal: https://creativecommons.org/publicdomain/zero/1.0/
:: This version based on updates for python 3.5 by Phil Elson at:
::     https://github.com/pelson/Obvious-CI/tree/master/scripts
:: Further updates to always correctly set SDK version and environment so
:: that compiled library dependencies use same SDK as Python extension.

@ECHO OFF

SET COMMAND_TO_RUN=%*
SET WIN_SDK_ROOT=C:\Program Files\Microsoft SDKs\Windows

SET MAJOR_PYTHON_VERSION="%PYTHON_VERSION:~0,1%"
SET MINOR_PYTHON_VERSION=%PYTHON_VERSION:~2,1%
IF %MAJOR_PYTHON_VERSION% == "2" (
    SET WINDOWS_SDK_VERSION="v7.0"
    SET SET_SDK_64=Y
) ELSE IF %MAJOR_PYTHON_VERSION% == "3" (
    SET WINDOWS_SDK_VERSION="v7.1"
    IF %MINOR_PYTHON_VERSION% LEQ 4 (
        SET SET_SDK_64=Y
    ) ELSE (
        SET "PATH=C:\\Program Files (x86)\\Microsoft Visual Studio 14.0\\VC\\BIN;%PATH%"
        SET SET_SDK_64=N
    )
) ELSE (
    ECHO Unsupported Python version: "%MAJOR_PYTHON_VERSION%"
    EXIT 1
)

"%WIN_SDK_ROOT%\%WINDOWS_SDK_VERSION%\Setup\WindowsSdkVer.exe" -q -version:%WINDOWS_SDK_VERSION%

IF "%PYTHON_ARCH%"=="64" (
    IF %SET_SDK_64% == Y (
        ECHO Configuring Windows SDK %WINDOWS_SDK_VERSION% for Python %MAJOR_PYTHON_VERSION% on a 64 bit architecture
        SET DISTUTILS_USE_SDK=1
        SET MSSdk=1
    )
    ECHO Setting MSVC %WINDOWS_SDK_VERSION% build environment for 64 bit architecture
    "%WIN_SDK_ROOT%\%WINDOWS_SDK_VERSION%\Bin\SetEnv.cmd" /x64 /release
    ECHO Executing: %COMMAND_TO_RUN%
    call %COMMAND_TO_RUN% || EXIT 1
) ELSE (
    ECHO Setting MSVC %WINDOWS_SDK_VERSION% build environment for 32 bit architecture
    "%WIN_SDK_ROOT%\%WINDOWS_SDK_VERSION%\Bin\SetEnv.cmd" /x86 /release
    ECHO Executing: %COMMAND_TO_RUN%
    call %COMMAND_TO_RUN% || EXIT 1
)
