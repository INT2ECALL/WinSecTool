@echo off

:: search for installation media
FOR %%i IN (C D E F G H I J K L N M O P Q R S T U V W X Y Z) DO IF EXIST %%i:\osprovision.exe set DVDDrive=%%i:

start /wait %DVDDrive%\osprovision.exe /quiet

exit