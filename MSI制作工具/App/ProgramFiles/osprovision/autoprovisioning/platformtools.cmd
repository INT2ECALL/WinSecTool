@echo off

:: search for installation media
FOR %%i IN (C D E F G H I J K L N M O P Q R S T U V W X Y Z) DO IF EXIST %%i:\osprovision.exe set DVDDrive=%%i:

if "%PROCESSOR_ARCHITECTURE%"=="AMD64" goto 64BIT

$PLATFORM_TOOLS_X86$

goto END
:64BIT

$PLATFORM_TOOLS_X64$

:END

exit