@echo off
chcp 65001 >nul 2>&1

cd /d "%~dp0APPS"
REM echo Checking for ELF files in APPS...
"%~dp0BAT\DiagBox" gd 0c
setlocal DisableDelayedExpansion
dir /b /o:n *.ELF >ELF.ELFTMP 2>nul || REM echo .ELF Files NOT FOUND
for /f "delims=" %%a in (ELF.ELFTMP) do (
set APPFolder=%%a
set APPELF=%%~na
setlocal EnableDelayedExpansion
"%~dp0BAT\Diagbox" gd 07

IF NOT EXIST "%~dp0APPS\!APPELF!" (

	md "!APPELF!"
	cd "!APPELF!"
	REM echo [%%a]
	cd..
	Move "!APPFolder!" "%~dp0APPS\!APPELF!\!APPFolder!" >nul 2>&1
	) else (
	
   "%~dp0BAT\DiagBox" gd 0c
   echo Application Already exist [!APPFolder!]
   "%~dp0BAT\DiagBox" gd 07
	)
endlocal
cd /d "%~dp0APPS"
)
endlocal
IF EXIST ELF.ELFTMP DEL ELF.ELFTMP

"%~dp0BAT\DiagBox" gd 07
echo\
echo Checking for ELF files in APPS\Folders...
echo\

setlocal DisableDelayedExpansion
for /f "delims=" %%a in ('dir /ad /b') do (
set APPFolder=%%a
set APPELF=%%~na
setlocal EnableDelayedExpansion

IF EXIST "%~dp0APPS\!APPFolder!\*.ELF" (
Cd "!APPFolder!"
dir /b /o:n *.ELF >ELF.ELFTMP 2>nul & set /P BOOTELF=<"%~dp0APPS\!APPFolder!\ELF.ELFTMP"

  Echo title=!APPFolder!>title.cfg
  Echo boot=!BOOTELF!>>title.cfg

  "%~dp0BAT\DiagBox" gd 0a
  echo [!appfolder!\!BOOTELF!]
  "%~dp0BAT\Diagbox" gd 07

IF EXIST ELF.ELFTMP DEL ELF.ELFTMP

 ) else (
  "%~dp0BAT\DiagBox" gd 0c
  echo [!appfolder!] .ELF Files NOT FOUND
  "%~dp0BAT\DiagBox" gd 07
    )
 endlocal
cd /d "%~dp0APPS"
)
endlocal

cd /d "%~dp0"
chcp 1252 >nul 2>&1