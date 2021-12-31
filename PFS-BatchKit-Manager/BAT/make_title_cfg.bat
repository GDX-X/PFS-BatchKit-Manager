@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0APPS"

"%~dp0BAT\Diagbox" gd 0f
echo\
echo Title.cfg maker by matias israelson ^& Modified By GDX

echo\
"%~dp0BAT\Diagbox" gd 06
echo Please MAKE SURE you have only one ELF per folders
echo Because if it detects several ELFs in the same folders, It will choose one at random
"%~dp0BAT\Diagbox" gd 07

set q=echo ------------------------------------------------------------------------------------------------------------------------
set w=echo ========================================================================================================================
echo\
REM echo Checking for ELF files in APPS...
"%~dp0BAT\DiagBox" gd 0c
dir /b /o:n *.ELF >ISR.ETL 2>nul || REM echo .ELF Files NOT FOUND
for /f "delims=" %%a in (ISR.ETL) do (
::timeout /t 2 >nul
"%~dp0BAT\Diagbox" gd 07

IF NOT EXIST "%CD%\%%~na\" (

	MD "%%~na"
	Cd "%%~na"
	REM echo [%%a]
	Cd..
	Move "%%a" "%CD%\%%~na\%%a" >nul 2>&1
	) ELSE (
	
   "%~dp0BAT\DiagBox" gd 0c
   echo Application Already exist [%%a]
   "%~dp0BAT\DiagBox" gd 07
  
	)
)
IF EXIST ISR.ETL DEL ISR.ETL

REM ###########################################################################################################################

"%~dp0BAT\DiagBox" gd 07
set q=echo ------------------------------------------------------------------------------------------------------------------------
set w=echo ========================================================================================================================

REM echo Check if there is any dot in the name of the folders
REM set "under=_"
REM set "dot=."
REM for /D /r %%d in (*) do (
REM set name=%%~nxd
REM ren "%%d" "!name:%dot%=%under%!"
REM )

REM echo Check if there is any dot in the name of the folders
set "under=_"
set "space= "
for /D /r %%d in (*) do (
set name=%%~nxd
ren "%%d" "!name:%under%=%space%!"
)

REM checking for ELF files exist in ONLY folders NOT subfolders
echo\
echo Checking for ELF files in APPS\Folders...
echo\
for /f "delims=" %%a in ('dir /ad /b') do (
set appfolder=%%a
pushd "!appfolder!"
IF EXIST "%CD%\!appfolder!\title.cfg" del "%CD%\!appfolder!\title.cfg" >nul 2>&1

REM for /f "delims= " %%b in ('dir /a-d /b') do ren "%%b" "%%a%%~xb" 
popd
REM timeout /t 2 >nul
REM IF EXIST "%CD%\%%~na\%%~na.cfg" del "%CD%\%%~na\%%~na.cfg"

IF EXIST "%CD%\!appfolder!\*.ELF" (
Cd "!appfolder!"
dir /b /o:n *.ELF >ISR.ETL 2>nul
set /P BOOTELF=<"%~dp0APPS\!appfolder!\ISR.ETL"
"%~dp0BAT\busybox" sed -i "2,10d" "%~dp0APPS\!appfolder!\ISR.ETL"
IF EXIST ISR.ETL DEL ISR.ETL

      REM dir >> "%~dp0APPS\!appfolder!\tmpfiles.txt"
      REM "%~dp0BAT\busybox" grep -i -e ".*\.ELF$" "%~dp0APPS\!appfolder!\tmpfiles.txt" | "%~dp0BAT\busybox" cut -c37-999 > "%~dp0APPS\!appfolder!\tmpfiles2.txt"
      REM "%~dp0BAT\busybox" sed -i "2,10d" "%~dp0APPS\!appfolder!\tmpfiles2.txt"
      REM set /P BOOTELF=<"%~dp0APPS\!appfolder!\tmpfiles2.txt"
(
Echo title=!appfolder!
Echo boot=!BOOTELF!
)>title.cfg

"%~dp0BAT\DiagBox" gd 0a
echo [!appfolder!\!BOOTELF!]
"%~dp0BAT\Diagbox" gd 07

REM del tmpfiles.txt >nul 2>&1
REM del tmpfiles2.txt >nul 2>&1

   Cd..
   ) ELSE (
   "%~dp0BAT\DiagBox" gd 0c
   echo [!appfolder!] .ELF Files NOT FOUND
   "%~dp0BAT\DiagBox" gd 07
    )
 )
::LOOP###############################################################################################################
cd /d "%~dp0"