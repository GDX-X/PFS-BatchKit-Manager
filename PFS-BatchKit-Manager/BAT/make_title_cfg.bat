@echo off
chcp 65001 >nul 2>&1
IF NOT EXIST "%rootpath%\TMP" MD "%rootpath%\TMP"

echo\
"%rootpath%\BAT\Diagbox" gd 0e
echo Do you want to change the default directory^?
"%rootpath%\BAT\Diagbox" gd 07
echo ^(Useful if your APPS folder are on another HDD^)
CHOICE /C YN
echo\
if !errorlevel!==1 (
echo Example: E:\
set /p "HDDPATH=Enter the root path where yours APPS folder:"
)
if not defined HDDPATH set HDDPATH=%rootpath%

echo\
"%rootpath%\BAT\Diagbox" gd 0e
echo Do you want to add a prefix^? in front of shortcut names
"%rootpath%\BAT\Diagbox" gd 07
CHOICE /C YN
IF !ERRORLEVEL!==1 (
echo\
echo Select Prefix option
echo 1 = [APP]
echo 2 = CUSTOM
echo 3 = Nothing
CHOICE /C 123
IF !ERRORLEVEL!==1 set prefix=[APP]
IF !ERRORLEVEL!==2 echo\& set /p "prefix=Enter your prefix:"
IF !ERRORLEVEL!==3 set "prefix="

echo\
echo As it will be displayed Example: !Prefix!My APP
echo Confirm^?
CHOICE /C YN
IF !ERRORLEVEL!==2 goto OPLManagement >nul 2>&1
)

dir /b /o:n "!HDDPATH!\POPS\*.VCD" > "%rootpath%\TMP\PS1GamesTMP.txt"
echo\
echo\
echo.-------------------------------------------
cd /d "!HDDPATH!\APPS" & dir /b /o:n *.ELF> "%rootpath%\TMP\ELF.ELFTMP" 2>nul || REM echo .ELF Files NOT FOUND
for /f "usebackq delims=" %%f in ("%rootpath%\TMP\ELF.ELFTMP") do (

    setlocal DisableDelayedExpansion
    set filename=%%f
    set APPELF=%%~nf
    setlocal EnableDelayedExpansion
	
		IF NOT EXIST "!APPELF!" (
		md "!APPELF!"
		move "!filename!" "!APPELF!" >nul 2>&1
		) else (
		"%rootpath%\BAT\DiagBox" gd 0c
		echo Application Already exist [!APPELF!]
		"%rootpath%\BAT\DiagBox" gd 07
		)
 endlocal
endlocal
)

dir /b /o:n "!HDDPATH!\APPS\*" > "%rootpath%\TMP\APPFolder.txt"
for /f "usebackq delims=" %%f in ("%rootpath%\TMP\APPFolder.txt") do (

    setlocal DisableDelayedExpansion
    set APPFolder=%%f
    setlocal EnableDelayedExpansion
		
IF NOT EXIST "!HDDPATH!\POPS\!APPFolder!.VCD" (
	IF EXIST "!APPFolder!\*.ELF" (
		dir /b /on "!HDDPATH!\APPS\!APPfolder!\*.ELF"> "%rootpath%\TMP\ELF.ELFTMP" & set /P BOOTELF=<"%rootpath%\TMP\ELF.ELFTMP"
		
		IF EXIST "!APPFolder!\title.cfg" (
		"%rootpath%\BAT\busybox" sed -i -e "s/title=.*/title=/g; s/title=/title=!Prefix!!APPFolder!/g" "!APPfolder!\title.cfg"
		"%rootpath%\BAT\busybox" sed -i -e "s/boot=.*/boot=/g; s/boot=/boot=!BOOTELF!/g" "!APPfolder!\title.cfg"
		) else (
		echo title=!Prefix!!APPFolder!>"!APPfolder!\title.cfg"
		echo boot=!BOOTELF!>>"!APPfolder!\title.cfg"
		)
		
		"%rootpath%\BAT\DiagBox" gd 0a
		echo [!APPfolder!\!BOOTELF!]
		"%rootpath%\BAT\Diagbox" gd 07
		) else (
		"%rootpath%\BAT\DiagBox" gd 0c
		echo [!APPfolder!] .ELF Files NOT FOUND
		"%rootpath%\BAT\DiagBox" gd 07
		)
	)
	endlocal
endlocal
)
chcp 1252 >nul 2>&1