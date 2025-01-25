@echo off

:--------------------------------------
REM  --> Check for permissions
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

REM --> If error flag set, we do not have admin.
if "%errorlevel%" NEQ "0" (
REM    echo Requesting Administrative Privileges...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"
:--------------------------------------

REM ****************************************************************************************
REM * Hey, if you look at this code, be aware that some parts of the code may be weird     *
REM * But I had to adapt to windows syntax and busybox to make them work properly,         *
REM * Especially for illegal characters and accents, and limitation of PS2 tools           *
REM * The script can be better optimized and avoid spaghetti code                          *
REM *                                                                                      *
REM * This script use hdl_dump & pfsshell commands                                         *
REM *                                                                                      *
REM * https://github.com/ps2homebrew/hdl-dump                                              *
REM * https://github.com/ps2homebrew/pfsshell                                              *
REM * Thanks to AKuHAK and Uyjulian                                                        *
REM *                                                                                      *
REM * GDX 2022/18/06                                                                       *
REM ****************************************************************************************

chcp 1252 >nul 2>&1
IF EXIST "%~dp0TMP" rmdir /Q/S "%~dp0TMP" >nul 2>&1
attrib +h "BAT" >nul 2>&1
set rootpath=%~dp0

IF NOT EXIST "%~dp0APPS\" MD "%~dp0APPS"
IF NOT EXIST "%~dp0ART\"  MD "%~dp0ART"
IF NOT EXIST "%~dp0CD\"   MD "%~dp0CD"
IF NOT EXIST "%~dp0CFG\"  MD "%~dp0CFG"
IF NOT EXIST "%~dp0CHT\"  MD "%~dp0CHT"
IF NOT EXIST "%~dp0DVD\"  MD "%~dp0DVD"
IF NOT EXIST "%~dp0LNG\"  MD "%~dp0LNG"
IF NOT EXIST "%~dp0LOG\"  MD "%~dp0LOG"
IF NOT EXIST "%~dp0POPS\" MD "%~dp0POPS"
IF NOT EXIST "%~dp0THM\"  MD "%~dp0THM"
IF NOT EXIST "%~dp0VMC\"  MD "%~dp0VMC"

IF NOT EXIST "%~dp0POPS\VMC" MD "%~dp0POPS\VMC"
IF NOT EXIST "%~dp0POPS-Binaries\" MD "%~dp0POPS-Binaries\"
IF NOT EXIST "%~dp0HDD-OSD\__sysconf" MD "%~dp0HDD-OSD\__sysconf"
IF NOT EXIST "%~dp0HDD-OSD\__system" MD "%~dp0HDD-OSD\__system"
IF NOT EXIST "%~dp0HDD-OSD\__common" MD "%~dp0HDD-OSD\__common"
IF NOT EXIST "%~dp0HDD-OSD\__common\OPL" MD "%~dp0HDD-OSD\__common\OPL"
IF NOT EXIST "%~dp0HDD-OSD\PP.HEADER\res" MD "%~dp0HDD-OSD\PP.HEADER\PFS\res\image" >nul 2>&1

IF NOT EXIST "%~dp0BAT\__Cache" MD "%~dp0BAT\__Cache"
IF NOT EXIST "%~dp0TMP" MD "%~dp0TMP"

REM Move PS1 Games If Batch Crash
IF EXIST "%~dp0POPS\Temp" for /r "%~dp0POPS\Temp" %%i in (*.VCD *.CUE *.BIN) do (
setlocal DisableDelayedExpansion
set filename=%%i
setlocal EnableDelayedExpansion
move "!filename!" "%~dp0POPS" >nul 2>&1
endlocal
endlocal
)
cd /d "%~dp0POPS" & for %%x in (TROJAN_?.BIN PATCH_?.BIN CHEATS.TXT Readme.txt) do del "%%x" >nul 2>&1
rmdir /Q/S "%~dp0POPS\Temp" >nul 2>&1

if not defined GithubUPDATE (
echo Checking for updates...
cd /d "%~dp0TMP"

ping -n 1 -w 2000 github.com >nul
	if errorlevel 1 (
			"%~dp0BAT\Diagbox" gd 0c
			echo Unable to PING^^!
			"%~dp0BAT\Diagbox" gd 07
			) else (
"%~dp0BAT\wget" -q "https://raw.githubusercontent.com/GDX-X/PFS-BatchKit-Manager/main/PFS-BatchKit-Manager/!PFS-BatchKit-Manager.bat" -O "%~dp0TMP\!PFS-BatchKit-Manager2.bat" >nul 2>&1
for %%F in ( "!PFS-BatchKit-Manager2.bat" ) do if %%~zF==0 del "%%F"

"%~dp0BAT\busybox" md5sum "%~dp0TMP\!PFS-BatchKit-Manager2.bat" 2>&1 | "%~dp0BAT\busybox" grep -o "[0-9a-z]\{32\}" > "%~dp0TMP\CheckUPDATE.txt" & set /p CheckUPDATE=<"%~dp0TMP\CheckUPDATE.txt"
"%~dp0BAT\busybox" md5sum "%~dp0!PFS-BatchKit-Manager.bat" 2>&1 | "%~dp0BAT\busybox" grep -o "[0-9a-z]\{32\}" > "%~dp0TMP\CheckOriginal.txt" & set /p CheckOriginal=<"%~dp0TMP\CheckOriginal.txt"
	)
)
set "GithubUPDATE="
if exist "!PFS-BatchKit-Manager2.bat" if "%CheckUPDATE%"=="%CheckOriginal%" (set "update=") else (set update=UPDATE AVAILABLE)

setlocal EnableDelayedExpansion
setlocal EnableExtensions
if not exist "%~dp0settings.ini" (
:DBLangSettings
call "%~dp0BAT\settings.bat" >nul 2>&1

if not defined UpdateDB (
cls
if not defined TitlesLang set TitlesLang=NONE
echo Database languages - Current: !TitlesLang!
echo ---------------------------------------------------
echo\
echo Choose the database language you want to use
echo Will be used for game information:
echo Title
echo Release
echo Descriptions
echo\
"%~dp0BAT\Diagbox" gd 0e
echo NOTE: Some titles may not be translated
"%~dp0BAT\Diagbox" gd 07
echo ---------------------------------------------------
echo\
echo 1 English ^(Default^)
echo 2 French
echo 3 German
echo 4 Spanish
echo 5 Italian
echo 6 Portuguese
echo\
CHOICE /C 123456 /M "Select Option:"
IF !ERRORLEVEL!==1 set "DBLang=En" & set TitlesLang=English
IF !ERRORLEVEL!==2 set "DBLang=Fr" & set TitlesLang=French
IF !ERRORLEVEL!==3 set "DBLang=De" & set TitlesLang=German
IF !ERRORLEVEL!==4 set "DBLang=Es" & set TitlesLang=Spanish
IF !ERRORLEVEL!==5 set "DBLang=It" & set TitlesLang=Italian
IF !ERRORLEVEL!==6 set "DBLang=Pt" & set TitlesLang=Portuguese

if not exist "%~dp0settings.ini" (
echo TitlesLang=!TitlesLang!>"%~dp0settings.ini"
echo DBLang=!DBLang!>>"%~dp0settings.ini"
) else (
"%~dp0BAT\busybox" sed -i -e "s/TitlesLang=.*/TitlesLang=/g; s/TitlesLang=/TitlesLang=!TitlesLang!/g" "%~dp0settings.ini"
"%~dp0BAT\busybox" sed -i -e "s/DBLang=.*/DBLang=/g; s/DBLang=/DBLang=!DBLang!/g" "%~dp0settings.ini"
	)
)

echo\
echo Downloading latest database updates..
ping -n 1 -w 2000 github.com >nul
	if errorlevel 1 (
			"%~dp0BAT\Diagbox" gd 0c
			echo Unable to PING^^!
			"%~dp0BAT\Diagbox" gd 07
			) else (
"%~dp0BAT\wget" -q --show-progress "https://github.com/GDX-X/OPL-Games-Infos-Database-Project/releases/download/Latest/OPL-Games-Infos-Database-Project.7z" >nul 2>&1 -O "%~dp0TMP\OPL-Games-Infos-Database-Project.7z"
for %%F in ("%~dp0TMP\OPL-Games-Infos-Database-Project.7z") do if %%~zF==0 (del %%F >nul 2>&1) else (echo Updated^^! & move "%~dp0TMP\OPL-Games-Infos-Database-Project.7z" "%~dp0BAT" >nul 2>&1)

for %%f in (PS1 PS2) do (
"%~dp0BAT\7-Zip\7z" e -bso0 "%~dp0BAT\OPL-Games-Infos-Database-Project.7z" -o"%~dp0TMP" %%fDB_!DBLang!.xml -r -y >nul 2>&1
"%~dp0BAT\busybox" sed -i "s/\&amp;/\&/g" "%~dp0TMP\%%fDB_!DBLang!.xml"
move "%~dp0TMP\%%fDB_!DBLang!.xml" "%~dp0BAT\%%fDB.xml" >nul 2>&1
)

"%~dp0BAT\busybox" sed "s/^/set /" "%~dp0settings.ini" > "%~dp0BAT\settings.bat"
if defined ChangeDBLang goto PFSBMSettings
	)
)

:ScanningPS2HDD
cls
rmdir /Q/S "%~dp0BAT\__Cache"
IF NOT EXIST "%~dp0BAT\__Cache" MD "%~dp0BAT\__Cache"
IF NOT EXIST "%~dp0TMP" MD "%~dp0TMP"
type nul>"%~dp0TMP\hdd-typetmp.txt"
"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning for Playstation 2 HDDs:
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "Playstation 2 HDD" | "%~dp0BAT\busybox" sed -e "/^$/d" | "%~dp0BAT\busybox" wc -l > "%~dp0TMP\TotalPS2HDD.txt" & set /P @TotalPS2HDD=<"%~dp0TMP\TotalPS2HDD.txt"

if !@TotalPS2HDD! gtr 1 (
   "%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "Playstation 2 HDD" | "%~dp0BAT\busybox" grep -o "hdd[0-9]:\|hdd[0-9][0-9]:" | "%~dp0BAT\busybox" sed "s/hdd//g; s/://g" > "%~dp0TMP\hdl-hdd.txt" 
   
   powershell -Command "Get-WmiObject -Query \"SELECT Model, Name FROM Win32_DiskDrive\" | Format-Table Model, Name, Status -AutoSize" | "%~dp0BAT\busybox" sed "s/[[:space:]]*$//" > "%~dp0TMP\hdd-type.txt"
   for /f "usebackq tokens=*" %%f in ("%~dp0TMP\hdl-hdd.txt") do "%~dp0BAT\busybox" grep "PHYSICALDRIVE%%f" "%~dp0TMP\hdd-type.txt" >> "%~dp0TMP\hdd-typetmp.txt"
   type "%~dp0TMP\hdd-typetmp.txt"

   "%~dp0BAT\Diagbox" gd 0e
   echo\
   echo Several HDDs in PS2 format have been detected.
   echo\
   echo Only type the number after \\.\PHYSICALDRIVE
   echo If you want to use PhysicalDrive2, type: 2
   "%~dp0BAT\Diagbox" gd 07
   
    set "NumberPS2HDD="
    set /p NumberPS2HDD="Select Option:"
    if "!NumberPS2HDD!"=="" (goto Mainmenu)

        "%~dp0BAT\busybox" grep -ow "\\\\.\\\PHYSICALDRIVE!NumberPS2HDD!" "%~dp0TMP\hdd-typetmp.txt" > "%~dp0TMP\SelectedPS2HDD.txt" & set /P SelectedPS2HDD=<"%~dp0TMP\SelectedPS2HDD.txt"
	    if "!SelectedPS2HDD!"=="\\.\PHYSICALDRIVE!NumberPS2HDD!" (
        "%~dp0BAT\Diagbox" gd 03
	    echo\
		REM echo         !SelectedPS2HDD! Selected
		echo hdd!NumberPS2HDD!:> "%~dp0TMP\hdl-hdd.txt"
	    "%~dp0BAT\Diagbox" gd 07
		echo.-------------------------------------------------------
	    ) else (
	    "%~dp0BAT\Diagbox" gd 0c
		echo\
	    echo         HDD Not Detected
	    echo\
	    echo\
	    "%~dp0BAT\Diagbox" gd 07
		del "%~dp0BAT\__Cache\HDD.BAT" >nul 2>&1
	    rmdir /Q/S "%~dp0TMP" >nul 2>&1
	    pause & (goto Mainmenu)
	    )
	 ) else ("%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "Playstation 2 HDD" | "%~dp0BAT\busybox" grep -o "hdd[0-9]:\|hdd[0-9][0-9]:" > "%~dp0TMP\hdl-hdd.txt")
	
    set /P @hdl_path=<"%~dp0TMP\hdl-hdd.txt"
	
	if not defined @hdl_path (
   "%~dp0BAT\Diagbox" gd 0c
   		echo         Playstation 2 HDD Not Detected
   		echo         Drive Must Be Formatted First
   		echo\
   		echo\
   "%~dp0BAT\Diagbox" gd 07
   		rmdir /Q/S "%~dp0TMP" >nul 2>&1
   	    pause & (goto mainmenu)
   	 ) else (
	 
	REM GET HDD Informations
	echo !@hdl_path!| "%~dp0BAT\busybox" sed "s/hdd//g; s/://g" > "%~dp0TMP\NumberPS2HDD.txt" & set /P @NumberPS2HDD=<"%~dp0TMP\NumberPS2HDD.txt"
	set @pfsshell_path=\\.\PhysicalDrive!@NumberPS2HDD!
	powershell -Command "Get-WmiObject -Query \"SELECT Model FROM Win32_DiskDrive WHERE DeviceID='\\\\.\\PHYSICALDRIVE!@NumberPS2HDD!'\" | Select-Object -ExpandProperty Model" | "%~dp0BAT\busybox" sed "s/USB Device//g; s/Disk Device//g; s/[[:space:]]*$//g" > "%~dp0TMP\ModelePS2HDD.txt" & set /P @ModelePS2HDD=<"%~dp0TMP\ModelePS2HDD.txt"
	powershell -Command "Get-WmiObject -Query \"SELECT Status FROM Win32_DiskDrive WHERE DeviceID='\\\\.\\PHYSICALDRIVE!@NumberPS2HDD!'\" | Select-Object -ExpandProperty Status" > "%~dp0TMP\StatusPS2HDD.txt" & set /P @StatusPS2HDD=<"%~dp0TMP\StatusPS2HDD.txt" & if not defined @StatusPS2HDD set @StatusPS2HDD=UNKNOWN
	
	"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "!@hdl_path!" > "%~dp0TMP\TotalHDD_Size.txt"
	for /f "usebackq tokens=2" %%s in ("%~dp0TMP\TotalHDD_Size.txt") do set TotalHDD_Size=%%s
	if !TotalHDD_Size! LSS 1000 (set @TotalHDD_Size=!TotalHDD_Size!MB) else (set /a "value=!TotalHDD_Size! / 1000" & set /a "remainder=!TotalHDD_Size! %% 1000" & set @TotalHDD_Size=!value!.!remainder!GB)

	"%~dp0BAT\Diagbox" gd 0f
	 echo Model: [!@ModelePS2HDD!]
	 echo Drive: [!@pfsshell_path!]
	 echo Size:  [!@TotalHDD_Size!]
	 echo Status: !@StatusPS2HDD!..

     REM Creating HDD Cache
	 call "%~dp0BAT\__ReloadHDD_cache.bat"
     )
 endlocal
endlocal

cd /d "%~dp0" & IF EXIST "%~dp0TMP" rmdir /Q/S "%~dp0TMP" >nul 2>&1

:mainmenu
"%~dp0BAT\Diagbox" gd 0f
IF NOT EXIST "%~dp0TMP" MD "%~dp0TMP"
cd /d "%~dp0"
cls
title PFS BatchKit Manager v1.2.0 By GDX
echo.PFS BatchKit Manager v1.2.0 By GDX
echo.-------------------------------------------------------------------------------------------------------------
endlocal
endlocal
setlocal EnableDelayedExpansion
setlocal EnableExtensions
call "%~dp0BAT\__Cache\HDD.BAT" >nul 2>&1 & call "%~dp0BAT\settings.bat" >nul 2>&1
if defined @hdl_path (
"%~dp0BAT\Diagbox" gd 03
echo [!@hdl_path! !@ModelePS2HDD!] - [Total: !@TotalHDD_Size! - Used: !@TotalHDD_Used! !@TotalHDD_Percentage! - Free: !@TotalHDD_Available!] - [Loaded: !OPLPART!]
) else (
"%~dp0BAT\Diagbox" gd 0c
echo [NO DEVICE] PLEASE RELOAD HDD
)
"%~dp0BAT\Diagbox" gd 0f                                      
echo.-------------------------------------------------------------------------------------------------------------
echo.
ECHO  [=====^| Main Menu ^|=====]
echo.
ECHO  [1] Install PS1 Games
ECHO  [2] Install PS2 Games
ECHO.
ECHO  [3] OPL Management
ECHO  [4] POPS Management
ECHO  [5] Games Management
ECHO  [6] Downloads/Update Management
ECHO  [7] Networking OnlinePlay
ECHO.
ECHO  [8] OSD/XMB Management
ECHO  [9] HDD Management
ECHO.
ECHO  [11] Exit
ECHO  [12] About
ECHO  [13] Change/Reload HDD
ECHO  [14] Settings
ECHO.
"%~dp0BAT\Diagbox" gd 0e
ECHO  [15] Donate                    
"%~dp0BAT\Diagbox" gd 0f
if defined update ("%~dp0BAT\Diagbox" gd 0a & ECHO  [20] !update!)
if not defined update ECHO  [20] Check for Updates
"%~dp0BAT\Diagbox" gd 0f
echo.------------------------------------------
set "choice=" & set /p choice=Select Option:

if "!choice!"=="1" (goto TransferPS1Games)
if "!choice!"=="2" (goto TransferPS2Games)
if "!choice!"=="3" (goto OPLManagement)
if "!choice!"=="4" (goto POPSManagement)
if "!choice!"=="5" (goto GamesManagement)
if "!choice!"=="6" (goto DownloadsMenu)
if "!choice!"=="7" (goto PS2OnlineMenu)
if "!choice!"=="8" (goto HDDOSDMenu)
if "!choice!"=="9" (goto HDDManagementMenu)

if "!choice!"=="11" exit
if "!choice!"=="12" (goto About)
if "!choice!"=="13" (goto ScanningPS2HDD)
if "!choice!"=="14" (goto PFSBMSettings)

if "!choice!"=="15" (start https://ko-fi.com/J3J6PIQ9O)
if "!choice!"=="20" (start https://github.com/GDX-X/PFS-BatchKit-Manager)

(goto mainmenu)

:About
"%~dp0BAT\Diagbox" gd 0f
cd /d "%~dp0"
cls
title PFS BatchKit Manager v1.2.0 By GDX
echo.PFS BatchKit Manager v1.2.0 By GDX
endlocal
endlocal
echo.------------------------------------------
echo.
ECHO  [=====^| ABOUT ME ^|=====]
echo.
ECHO I was inspired by the scripts of NeMesiS, Dekkit and Rs1n to make this script
ECHO.
ECHO This batch script is intended to help and automate operations on the PS2 hard drive!
ECHO. 
ECHO Many thanks to the PS2 community for contributing the programs used to create these scripts!
ECHO.                                                            _______
ECHO GDX                                                        /!      !
ECHO.                                                          / ! [][] !___
echo.------------------------------------------               /  !      !   !
ECHO  [1] My Twitter                                         /   !      !   !
ECHO  [2] My Discord : .gdx.                                /    !      ! = !
ECHO  [3] My Youtube Channel                               !     !  PS  ! = !
ECHO  [4] My Github                                        !     !      ! = !
ECHO  [5] Donate                                           !     !      ! = !
ECHO  [6] Special Thanks                                   !     !      ! = !
ECHO  [7] Official PS2 Forum                               !     !      ! = !
ECHO  [8] Official PS2 Discord                             !     ! !! !!! = !
ECHO  [9] PS2 Space Discord                                !     ! !! !!! = !
ECHO.                                                      !     ! !! !!! = !
ECHO  [10] Back to main menu                               !     !      ! = !
ECHO  [11] Exit                                            !_____! !! !!! _ ! 
echo.------------------------------------------           /     /! !! !!!! !!\ 
echo                                                     /     / ! !! !!!! !! \ 
echo                                                    /_____/__!______!!_!!__\            
set "choice=" & set /p choice=Select Option:

setlocal EnableDelayedExpansion
if "!choice!"=="1" start https://twitter.com/GDX_SM
if "!choice!"=="3" start https://www.youtube.com/user/GDXTV/videos
if "!choice!"=="4" start https://github.com/GDX-X/PFS-BatchKit-Manager
if "!choice!"=="5" start https://ko-fi.com/J3J6PIQ9O
if "!choice!"=="6" cls & type "%~dp0\Credits.txt" & echo\ & echo\ & echo\ & pause
if "!choice!"=="7" start https://www.psx-place.com/forums/#playstation-2-forums.6
if "!choice!"=="7" start https://discord.gg/PWGvKXjRgy
if "!choice!"=="9" start https://discord.gg/3yEp3ubcG2

if "!choice!"=="10" (goto mainmenu)
if "!choice!"=="11" exit

if "!choice!"=="99" (goto poop)
if "!choice!"=="100" (goto GDX-X)
endlocal
(goto About)

:PFSBMSettings
"%~dp0BAT\Diagbox" gd 0f
cd /d "%~dp0"
cls
title PFS BatchKit Manager v1.2.0 By GDX
echo.PFS BatchKit Manager v1.2.0 By GDX
endlocal
endlocal
setlocal EnableDelayedExpansion
setlocal EnableExtensions
call "%~dp0BAT\settings.bat" >nul 2>&1
"%~dp0BAT\Diagbox" gd 0f                                      
echo.------------------------------------------
echo.
ECHO  [=====^| Settings ^|=====]
ECHO.
ECHO  [1] Change database language - [!TitlesLang!]
ECHO  [2] Download the latest database
ECHO.
ECHO  [10] Back
ECHO  [12] Exit
ECHO.
echo.------------------------------------------
set "choice=" & set /p choice=Select Option:

if "!choice!"=="1" set "ChangeDBLang=Yes" & set "UpdateDB=" & goto DBLangSettings
if "!choice!"=="2" set "ChangeDBLang=Yes" & set "UpdateDB=Yes" & cls & goto DBLangSettings

if "!choice!"=="10" (goto Mainmenu)
if "!choice!"=="12" exit

(goto PFSBMSettings)

:OPLManagement
"%~dp0BAT\Diagbox" gd 0f
cd /d "%~dp0"
cls
title PFS BatchKit Manager v1.2.0 By GDX
echo.PFS BatchKit Manager v1.2.0 By GDX
echo.-------------------------------------------------------------------------------------------------------------
endlocal
endlocal
setlocal EnableDelayedExpansion
setlocal EnableExtensions
call "%~dp0BAT\__Cache\HDD.BAT" >nul 2>&1 & call "%~dp0BAT\settings.bat" >nul 2>&1
if defined @hdl_path (
"%~dp0BAT\Diagbox" gd 03
echo [!@hdl_path! !@ModelePS2HDD!] - [Total: !@TotalHDD_Size! - Used: !@TotalHDD_Used! !@TotalHDD_Percentage! - Free: !@TotalHDD_Available!] - [Loaded: !OPLPART!]
) else (
"%~dp0BAT\Diagbox" gd 0c
echo [NO DEVICE] PLEASE RELOAD HDD
)
"%~dp0BAT\Diagbox" gd 0f                                      
echo.-------------------------------------------------------------------------------------------------------------
echo.
ECHO  [=====^| OPL Management ^|=====]
ECHO.
ECHO  [1] Transfer OPL Resources
ECHO  [2] Extract OPL Resources
ECHO  [3] Create Cheat file with mastercode
ECHO  [4] Create Virtual Memory Card
ECHO  [5] Create shortcuts for your APPs or PS1 games in APPS tab
ECHO.
REM ECHO  [8] Clean OPL Ressource Partition 
ECHO  [9] Change OPL Resources Partition
ECHO.
ECHO  [10] Back
ECHO  [12] Exit
ECHO.
echo.------------------------------------------
set "choice=" & set /p choice=Select Option:

if "!choice!"=="1" (goto TransferAPPSARTCFGCHTTHMVMC)
if "!choice!"=="2" (goto BackupARTCFGCHTVMC)
if "!choice!"=="3" call "%~dp0BAT\make_cheat_mastercode.bat"
if "!choice!"=="4" (goto CreateVMC)
if "!choice!"=="5" (goto CreateShortcutsOPL)
if "!choice!"=="9" (goto ChangeOPLResources)

if "!choice!"=="10" (goto Mainmenu)
if "!choice!"=="12" exit

(goto OPLManagement)

:POPSManagement
"%~dp0BAT\Diagbox" gd 0f
cd /d "%~dp0"
cls
title PFS BatchKit Manager v1.2.0 By GDX
echo.PFS BatchKit Manager v1.2.0 By GDX
echo.-------------------------------------------------------------------------------------------------------------
endlocal
endlocal
setlocal EnableDelayedExpansion
setlocal EnableExtensions
call "%~dp0BAT\__Cache\HDD.BAT" >nul 2>&1 & call "%~dp0BAT\settings.bat" >nul 2>&1
if defined @hdl_path (
"%~dp0BAT\Diagbox" gd 03
echo [!@hdl_path! !@ModelePS2HDD!] - [Total: !@TotalHDD_Size! - Used: !@TotalHDD_Used! !@TotalHDD_Percentage! - Free: !@TotalHDD_Available!] - [Loaded: !OPLPART!]
) else (
"%~dp0BAT\Diagbox" gd 0c
echo [NO DEVICE] PLEASE RELOAD HDD
)
"%~dp0BAT\Diagbox" gd 0f                                      
echo.-------------------------------------------------------------------------------------------------------------
echo.
ECHO  [=====^| POPS Management ^|=====]
ECHO.
ECHO  [1] Transfer POPS Binaries
ECHO  [2] Transfer/Extract POPS VMC
ECHO  [3] Assign titles database for your .VCDs
if exist "%~dp0POPS-Binaries\Hugopocked_POPStarter_Fixes.zip" ECHO  [9] Apply HugoPocked's patches
ECHO.
ECHO  [10] Back
ECHO  [12] Exit
ECHO.
echo.------------------------------------------
set "choice=" & set /p choice=Select Option:

if "!choice!"=="1" (goto TransferPOPSBinaries)
if "!choice!"=="2" (goto TransferBackupPOPSVMC)
if "!choice!"=="3" (goto RenameVCDDB)
if exist "%~dp0POPS-Binaries\Hugopocked_POPStarter_Fixes.zip" if "!choice!"=="9" (goto POPSHugoPatch)

if "!choice!"=="10" (goto Mainmenu)
if "!choice!"=="12" exit

(goto POPSManagement)

:ConversionMenu
"%~dp0BAT\Diagbox" gd 0f
cd /d "%~dp0"
cls
title PFS BatchKit Manager v1.2.0 By GDX
echo.PFS BatchKit Manager v1.2.0 By GDX
echo.-------------------------------------------------------------------------------------------------------------
endlocal
endlocal
setlocal EnableDelayedExpansion
setlocal EnableExtensions
call "%~dp0BAT\__Cache\HDD.BAT" >nul 2>&1 & call "%~dp0BAT\settings.bat" >nul 2>&1
if defined @hdl_path (
"%~dp0BAT\Diagbox" gd 03
echo [!@hdl_path! !@ModelePS2HDD!] - [Total: !@TotalHDD_Size! - Used: !@TotalHDD_Used! !@TotalHDD_Percentage! - Free: !@TotalHDD_Available!] - [Loaded: !OPLPART!]
) else (
"%~dp0BAT\Diagbox" gd 0c
echo [NO DEVICE] PLEASE RELOAD HDD
)
"%~dp0BAT\Diagbox" gd 0f                                      
echo.-------------------------------------------------------------------------------------------------------------
echo.
ECHO  [=====^| Conversion Menu ^|=====]
ECHO.
ECHO  [1] Convert .BIN to .VCD ^(Only for PS1 Games^) ^(Multi-Tracks Compatible^)
ECHO  [2] Convert .VCD to .BIN ^(Only for PS1 Games^)
ECHO  [3] Convert .BIN to .ISO ^(Only for PS2 Games Usefull for PCSX2^) ^(Multi-Tracks Compatible^)
ECHO  [4] Convert Multi-Tracks .BIN to Single .BIN
ECHO  [5] Compress/Decompress .ZSO ^(Only for PS2 Games^)
ECHO  [6]
ECHO  [7]
ECHO  [8]
ECHO  [9] Restore Single .BIN to Multi-Tracks ^(If compatible, it will rebuild the original .bin with the Multi-Track^)
ECHO.
ECHO  [10] Back
ECHO  [11] Back to main menu
ECHO  [12] Exit
ECHO.
echo.------------------------------------------
set "choice=" & set /p choice=Select Option:

if "!choice!"=="1" set "Convert=BIN2VCD" & set "GameType=PS1" & goto ConvertTools
if "!choice!"=="2" set "UnConvert=VCD2BIN" & set "GameType=PS1" & goto ConvertTools
if "!choice!"=="3" set "Convert=BIN2ISO" & set "GameType=PS2" & goto ConvertTools
if "!choice!"=="4" set "Convert=multibin2bin" & set "GameType=PS1" & goto ConvertTools
if "!choice!"=="5" set "Convert=ISO2ZSO" & set "GameType=PS2" & set UnConvert=yes & goto ConvertTools

if "!choice!"=="9" set "Convert=bin2split" & set "GameType=PS1" & set "split=-s" & goto ConvertTools
 
if "!choice!"=="10" (goto GamesManagement)
if "!choice!"=="11" (goto mainmenu)
if "!choice!"=="12" exit

(goto ConversionMenu)

:GamesManagement
"%~dp0BAT\Diagbox" gd 0f
cd /d "%~dp0"
cls
title PFS BatchKit Manager v1.2.0 By GDX
echo.PFS BatchKit Manager v1.2.0 By GDX
echo.-------------------------------------------------------------------------------------------------------------
endlocal
endlocal
setlocal EnableDelayedExpansion
setlocal EnableExtensions
call "%~dp0BAT\__Cache\HDD.BAT" >nul 2>&1 & call "%~dp0BAT\settings.bat" >nul 2>&1
if defined @hdl_path (
"%~dp0BAT\Diagbox" gd 03
echo [!@hdl_path! !@ModelePS2HDD!] - [Total: !@TotalHDD_Size! - Used: !@TotalHDD_Used! !@TotalHDD_Percentage! - Free: !@TotalHDD_Available!] - [Loaded: !OPLPART!]
) else (
"%~dp0BAT\Diagbox" gd 0c
echo [NO DEVICE] PLEASE RELOAD HDD
)
"%~dp0BAT\Diagbox" gd 0f                                      
echo.-------------------------------------------------------------------------------------------------------------
echo.
ECHO  [=====^| Games Management ^|=====]
ECHO.
ECHO  [1] Convert a game
ECHO  [2] Extract a game
ECHO  [3] Copy a game
ECHO  [4] Delete a game
ECHO  [5] Rename a game
ECHO  [6] Export game list
ECHO  [7]
ECHO  [8] Dump your CD/DVD-ROM PS1 ^& PS2
ECHO  [9] Check MD5 Hash of your PS2 .ISO/.BIN with the redump database
ECHO.
ECHO  [10] Back
ECHO  [12] Exit
ECHO.
echo.------------------------------------------
set "choice=" & set /p choice=Select Option:

if "!choice!"=="1" (goto ConversionMenu)
if "!choice!"=="2" (goto ExtractGameChoice)
if "!choice!"=="3" (goto CopyPS2GamesHDD)
if "!choice!"=="4" (goto DeleteChoiceGamesHDD)
if "!choice!"=="5" set "@GameManagementMenu=" & (goto RenameChoiceGames)
if "!choice!"=="6" (goto ExportChoiceGamesListHDD)

if "!choice!"=="8" (goto DumpCDDVD)
if "!choice!"=="9" (goto checkMD5Hash)

if "!choice!"=="10" (goto mainmenu)
if "!choice!"=="12" exit

(goto GamesManagement)

:DownloadsMenu
"%~dp0BAT\Diagbox" gd 0f
cd /d "%~dp0"
cls
title PFS BatchKit Manager v1.2.0 By GDX
echo.PFS BatchKit Manager v1.2.0 By GDX
echo.-------------------------------------------------------------------------------------------------------------
endlocal
endlocal
setlocal EnableDelayedExpansion
setlocal EnableExtensions
call "%~dp0BAT\__Cache\HDD.BAT" >nul 2>&1 & call "%~dp0BAT\settings.bat" >nul 2>&1
if defined @hdl_path (
"%~dp0BAT\Diagbox" gd 03
echo [!@hdl_path! !@ModelePS2HDD!] - [Total: !@TotalHDD_Size! - Used: !@TotalHDD_Used! !@TotalHDD_Percentage! - Free: !@TotalHDD_Available!] - [Loaded: !OPLPART!]
) else (
"%~dp0BAT\Diagbox" gd 0c
echo [NO DEVICE] PLEASE RELOAD HDD
)
"%~dp0BAT\Diagbox" gd 0f                                      
echo.-------------------------------------------------------------------------------------------------------------
echo.
ECHO  [=====^| Downloads Management ^|=====]
ECHO.
ECHO  [1] Applications
ECHO  [2] Artworks
ECHO  [3] Configs
ECHO  [4] Cheats
REM ECHO 9. Update your APPS,ART,CFG,CHT (Automatically updates files found in your +OPL partition
ECHO.
ECHO  [10] Back
ECHO  [12] Exit
ECHO.
echo.------------------------------------------
set "choice=" & set /p choice=Select Option:

if "!choice!"=="1" set checkappsupdate=yes& (goto DownloadAPPSMenu)
if "!choice!"=="2" (goto DownloadARTChoice)
if "!choice!"=="3" (goto DownloadCFG)
if "!choice!"=="4" (goto DownloadCheatsMenu)

if "!choice!"=="10" (goto Mainmenu)
if "!choice!"=="12" exit

(goto DownloadsMenu)

:DownloadAPPSMenu
"%~dp0BAT\Diagbox" gd 0f

if defined checkappsupdate (
cd /d "%~dp0TMP"
cls
echo\
echo Checking for APPS Database updates...
ping -n 1 -w 2000 github.com >nul
	if errorlevel 1 (
			"%~dp0BAT\Diagbox" gd 0c
			echo Unable to PING^^!
			"%~dp0BAT\Diagbox" gd 07
			) else (
"%~dp0BAT\wget" -q "https://raw.githubusercontent.com/GDX-X/PFS-BatchKit-Manager/main/PFS-BatchKit-Manager/BAT/APPS.BAT" -O "%~dp0TMP\APPS.BAT" >nul 2>&1
for %%F in ( "APPS.BAT" ) do if %%~zF==0 (del "%%F")

if exist "APPS.BAT" (
"%~dp0BAT\busybox" md5sum "%~dp0TMP\APPS.BAT" 2>&1 | "%~dp0BAT\busybox" grep -o "[0-9a-z]\{32\}" > "%~dp0TMP\CheckUPDATE.txt" & set /p CheckUPDATE=<"%~dp0TMP\CheckUPDATE.txt"
"%~dp0BAT\busybox" md5sum "%~dp0\BAT\APPS.BAT" 2>&1 | "%~dp0BAT\busybox" grep -o "[0-9a-z]\{32\}" > "%~dp0TMP\CheckOriginal.txt" & set /p CheckOriginal=<"%~dp0TMP\CheckOriginal.txt"

if "!CheckUPDATE!"=="!CheckOriginal!" (echo ) else (
echo\
echo\
echo Updating...
move "APPS.BAT" "%~dp0BAT" >nul 2>&1
"%~dp0BAT\wget" -q "https://raw.githubusercontent.com/GDX-X/PFS-BatchKit-Manager/main/PFS-BatchKit-Manager/BAT/APPS.zip" -O "%~dp0TMP\APPS.zip" >nul 2>&1
for %%F in ( "APPS.zip" ) do if %%~zF==0 (del "%%F" ) else (move "APPS.zip" "%~dp0BAT" >nul 2>&1)
"%~dp0BAT\wget" -q "https://raw.githubusercontent.com/GDX-X/PFS-BatchKit-Manager/main/PFS-BatchKit-Manager/BAT/APPDB.xml" -O "%~dp0TMP\APPDB.xml" >nul 2>&1
for %%F in ( "APPDB.xml" ) do if %%~zF==0 (del "%%F" ) else (move "APPDB.xml" "%~dp0BAT" >nul 2>&1)
  			)
 		) else (set "checkappsupdate=")
	)
)

rmdir /Q/S "%~dp0TMP" >nul 2>&1
cd /d "%~dp0"
cls
title PFS BatchKit Manager v1.2.0 By GDX
echo.PFS BatchKit Manager v1.2.0 By GDX
echo.-------------------------------------------------------------------------------------------------------------
endlocal
endlocal
setlocal EnableDelayedExpansion
setlocal EnableExtensions
call "%~dp0BAT\__Cache\HDD.BAT" >nul 2>&1 & call "%~dp0BAT\settings.bat" >nul 2>&1
if defined @hdl_path (
"%~dp0BAT\Diagbox" gd 03
echo [!@hdl_path! !@ModelePS2HDD!] - [Total: !@TotalHDD_Size! - Used: !@TotalHDD_Used! !@TotalHDD_Percentage! - Free: !@TotalHDD_Available!] - [Loaded: !OPLPART!]
) else (
"%~dp0BAT\Diagbox" gd 0c
echo [NO DEVICE] PLEASE RELOAD HDD
)
"%~dp0BAT\Diagbox" gd 0f                                      
echo.-------------------------------------------------------------------------------------------------------------
echo.
ECHO  [=====^| Applications Downloads Management ^|=====]
ECHO.
ECHO  [1] Open PS2 Loader
ECHO  [2] wLaunchELF
ECHO  [3] Utilities
ECHO  [4] Emulators
ECHO  [5] MultiMedia
ECHO  [6] Hardware
ECHO  [7]
ECHO  [8] 
REM ECHO 8. Others
ECHO  [9] Update APPS (Already installed as partition)
ECHO.
ECHO  [10] Back
ECHO  [11] Back to main menu
ECHO  [12] Exit
ECHO.
echo.------------------------------------------
set "choice=" & set /p choice=Select Option:

if "!choice!"=="1" set "@DownloadOPL=yes" & (call "%~dp0BAT\APPS.BAT")
if "!choice!"=="2" set "@DownloadwLaunchELF=yes" & (call "%~dp0BAT\APPS.BAT")
if "!choice!"=="3" set "@DownloadUtilities=yes" & (call "%~dp0BAT\APPS.BAT")
if "!choice!"=="4" set "@DownloadEmulators=yes" & (call "%~dp0BAT\APPS.BAT")
if "!choice!"=="5" set "@DownloadMultiMedia=yes" & (call "%~dp0BAT\APPS.BAT")
if "!choice!"=="6" set "@DownloadHardware=yes" & (call "%~dp0BAT\APPS.BAT")

if "!choice!"=="9" (goto UpdatePartAPPS)

if "!choice!"=="10" (goto DownloadsMenu)
if "!choice!"=="11" (goto mainmenu)
if "!choice!"=="12" exit

(goto DownloadAPPSMenu)

:DownloadCheatsMenu
"%~dp0BAT\Diagbox" gd 0f
cd /d "%~dp0"
cls
title PFS BatchKit Manager v1.2.0 By GDX
echo.PFS BatchKit Manager v1.2.0 By GDX
echo.-------------------------------------------------------------------------------------------------------------
endlocal
endlocal
setlocal EnableDelayedExpansion
setlocal EnableExtensions
call "%~dp0BAT\__Cache\HDD.BAT" >nul 2>&1 & call "%~dp0BAT\settings.bat" >nul 2>&1
if defined @hdl_path (
"%~dp0BAT\Diagbox" gd 03
echo [!@hdl_path! !@ModelePS2HDD!] - [Total: !@TotalHDD_Size! - Used: !@TotalHDD_Used! !@TotalHDD_Percentage! - Free: !@TotalHDD_Available!] - [Loaded: !OPLPART!]
) else (
"%~dp0BAT\Diagbox" gd 0c
echo [NO DEVICE] PLEASE RELOAD HDD
)
"%~dp0BAT\Diagbox" gd 0f                                      
echo.-------------------------------------------------------------------------------------------------------------
echo.
ECHO  [=====^| Cheats Downloads Management ^|=====]
ECHO.
ECHO  [1] Rockstar Games Uncensored Cheats
ECHO  [2] Widescreen Cheats (4/3 to 16/9)

ECHO.
ECHO  [10] Back
ECHO  [11] Back to main menu
ECHO  [12] Exit
ECHO.
echo.------------------------------------------
set "choice=" & set /p choice=Select Option:

if "!choice!"=="1" (start https://github.com/GDX-X/Rockstar-Games-Uncensored-PS2)
if "!choice!"=="2" (start https://github.com/PS2-Widescreen/OPL-Widescreen-Cheats)

if "!choice!"=="10" (goto DownloadsMenu)
if "!choice!"=="11" (goto mainmenu)
if "!choice!"=="12" exit

(goto DownloadCheatsMenu)

:HDDOSDMenu
"%~dp0BAT\Diagbox" gd 0f
cd /d "%~dp0"
cls
title PFS BatchKit Manager v1.2.0 By GDX
echo.PFS BatchKit Manager v1.2.0 By GDX
echo.-------------------------------------------------------------------------------------------------------------
endlocal
endlocal
setlocal EnableDelayedExpansion
setlocal EnableExtensions
call "%~dp0BAT\__Cache\HDD.BAT" >nul 2>&1 & call "%~dp0BAT\settings.bat" >nul 2>&1
if defined @hdl_path (
"%~dp0BAT\Diagbox" gd 03
echo [!@hdl_path! !@ModelePS2HDD!] - [Total: !@TotalHDD_Size! - Used: !@TotalHDD_Used! !@TotalHDD_Percentage! - Free: !@TotalHDD_Available!] - [Loaded: !OPLPART!]
) else (
"%~dp0BAT\Diagbox" gd 0c
echo [NO DEVICE] PLEASE RELOAD HDD
)
"%~dp0BAT\Diagbox" gd 0f                                      
echo.-------------------------------------------------------------------------------------------------------------
echo.
ECHO  [=====^| OSD/XMB Management ^|=====]
ECHO.
ECHO  [1] Install HDD-OSD ^(Browser 2.0^)
ECHO  [2] Uninstall HDD-OSD
ECHO  [3] Partitions Management
ECHO  [4] FreeHDBoot Management
REM ECHO [5] Install PSBBN ^(Playstation Broadband Navigator^)
REM ECHO [6] Install Linux Kernel
ECHO.
ECHO  [10] Back
ECHO  [12] Exit
ECHO.
echo.------------------------------------------
set "choice=" & set /p choice=Select Option:

if "!choice!"=="1" (goto InstallHDDOSD)
if "!choice!"=="2" (goto UnInstallHDDOSD)
if "!choice!"=="3" (goto HDDOSDPartManagement)
if "!choice!"=="4" (goto FreeHDBootManagement)

if "!choice!"=="10" (goto Mainmenu)
if "!choice!"=="12" exit

(goto HDDOSDMenu)

:HDDOSDPartManagement
"%~dp0BAT\Diagbox" gd 0f
cd /d "%~dp0"
cls
title PFS BatchKit Manager v1.2.0 By GDX
echo.PFS BatchKit Manager v1.2.0 By GDX
echo.-------------------------------------------------------------------------------------------------------------
endlocal
endlocal
setlocal EnableDelayedExpansion
setlocal EnableExtensions
call "%~dp0BAT\__Cache\HDD.BAT" >nul 2>&1 & call "%~dp0BAT\settings.bat" >nul 2>&1
if defined @hdl_path (
"%~dp0BAT\Diagbox" gd 03
echo [!@hdl_path! !@ModelePS2HDD!] - [Total: !@TotalHDD_Size! - Used: !@TotalHDD_Used! !@TotalHDD_Percentage! - Free: !@TotalHDD_Available!] - [Loaded: !OPLPART!]
) else (
"%~dp0BAT\Diagbox" gd 0c
echo [NO DEVICE] PLEASE RELOAD HDD
)
"%~dp0BAT\Diagbox" gd 0f                                      
echo.-------------------------------------------------------------------------------------------------------------
echo.
ECHO  [=====^| HDD-OSD/PSBBN/XMB Partitions Management ^|=====]
ECHO.
ECHO  [1] Transfer PS1 Games ^(Install as Partition Launch PS1 games from HDD-OSD, PSBBN, XMB Menu^)
ECHO  [2] Transfer Custom ELF APPS ^(Install as Partition Launch your APP from HDD-OSD, PSBBN, XMB Menu^)
ECHO  [3] Hide Partition ^(Hide partitions in HDD-OSD^)
ECHO  [4] Unhide Partition ^(Show partitions in HDD-OSD^)
ECHO  [5] Rename a title ^(Displayed in HDD-OSD, PSBBN, XMB Menu^)
echo  [6]
ECHO  [7]
ECHO  [8] Extract/Inject Partition Resources Header ^(Customize your partition header^)
ECHO  [9] Update Partition Resources Header ^(Updates: Title, Icons, Gameinfo, ART, OPL-Launcher^)
ECHO.
ECHO  [10] Back
ECHO  [11] Back to main menu
ECHO  [12] Exit
ECHO.
echo.------------------------------------------
set "choice=" & set /p choice=Select Option:

if "!choice!"=="1" set "@pfs_popHDDOSDMAIN=" & (goto TransferPS1GamesHDDOSD)
if "!choice!"=="2" (goto TransferAPPSPart)
if "!choice!"=="3" set "@pfs_PartHidePS2Games=yes" & set "Pfs_Part_Option=Hide" & set "@hdl_option=-hide" & (goto pphide_unhide)
if "!choice!"=="4" set "@pfs_PartUnHidePS2Games=yes" & set "Pfs_Part_Option=Unhide" & set "@hdl_option=-unhide" & (goto pphide_unhide)
if "!choice!"=="5" (goto RenameTitleHDDOSD)

if "!choice!"=="8" (goto CustomPPHeader)
if "!choice!"=="9" (goto UpdatePPHeader)

if "!choice!"=="10" (goto HDDOSDMenu)
if "!choice!"=="11" (goto mainmenu)
if "!choice!"=="12" exit

(goto HDDOSDPartManagement)

:FreeHDBootManagement
"%~dp0BAT\Diagbox" gd 0f
cd /d "%~dp0"
cls
title PFS BatchKit Manager v1.2.0 By GDX
echo.PFS BatchKit Manager v1.2.0 By GDX
echo.-------------------------------------------------------------------------------------------------------------
endlocal
endlocal
setlocal EnableDelayedExpansion
setlocal EnableExtensions
call "%~dp0BAT\__Cache\HDD.BAT" >nul 2>&1 & call "%~dp0BAT\settings.bat" >nul 2>&1
if defined @hdl_path (
"%~dp0BAT\Diagbox" gd 03
echo [!@hdl_path! !@ModelePS2HDD!] - [Total: !@TotalHDD_Size! - Used: !@TotalHDD_Used! !@TotalHDD_Percentage! - Free: !@TotalHDD_Available!] - [Loaded: !OPLPART!]
) else (
"%~dp0BAT\Diagbox" gd 0c
echo [NO DEVICE] PLEASE RELOAD HDD
)
"%~dp0BAT\Diagbox" gd 0f                                      
echo.-------------------------------------------------------------------------------------------------------------
echo.
ECHO  [=====^| FreeHDBoot Management ^|=====]
ECHO.
ECHO  [1] Fix Graphical Corruption OSD
ECHO.
ECHO  [10] Back
ECHO  [11] Back to main menu
ECHO  [12] Exit
ECHO.
echo.------------------------------------------
set "choice=" & set /p choice=Select Option:

if "!choice!"=="1" (goto FreeHDBootFixOSDCorruption)

if "!choice!"=="10" (goto HDDOSDMenu)
if "!choice!"=="11" (goto mainmenu)
if "!choice!"=="12" exit

(goto FreeHDBootManagement)

:PS2OnlineMenu
"%~dp0BAT\Diagbox" gd 0f
cd /d "%~dp0"
cls
title PFS BatchKit Manager v1.2.0 By GDX
echo.PFS BatchKit Manager v1.2.0 By GDX
echo.-------------------------------------------------------------------------------------------------------------
endlocal
endlocal
setlocal EnableDelayedExpansion
setlocal EnableExtensions
call "%~dp0BAT\__Cache\HDD.BAT" >nul 2>&1 & call "%~dp0BAT\settings.bat" >nul 2>&1
if defined @hdl_path (
"%~dp0BAT\Diagbox" gd 03
echo [!@hdl_path! !@ModelePS2HDD!] - [Total: !@TotalHDD_Size! - Used: !@TotalHDD_Used! !@TotalHDD_Percentage! - Free: !@TotalHDD_Available!] - [Loaded: !OPLPART!]
) else (
"%~dp0BAT\Diagbox" gd 0c
echo [NO DEVICE] PLEASE RELOAD HDD
)
"%~dp0BAT\Diagbox" gd 0f                                      
echo.-------------------------------------------------------------------------------------------------------------
echo.
ECHO  [=====^| Networking OnlinePlay ^|=====]
ECHO.
ECHO  [1] Discord Retro-Online
ECHO  [2] Discord PS2 Online Gaming
ECHO  [3] Show PS2 Games Compatibles
ECHO.
ECHO  [10] Back
ECHO  [11] Back to main menu
ECHO  [12] Exit
ECHO.
echo.------------------------------------------
set "choice=" & set /p choice=Select Option:

if "!choice!"=="1" start https://discord.gg/kxXJjrZaSP
if "!choice!"=="2" start https://discord.gg/t2JY9awkwD
if "!choice!"=="3" start https://docs.google.com/spreadsheets/d/1bbxOGm4dPxZ4Vbzyu3XxBnZmuPx3Ue-cPqBeTxtnvkQ
if "!choice!"=="10" (goto Mainmenu)
if "!choice!"=="12" exit

(goto PS2OnlineMenu)

:HDDManagementMenu
"%~dp0BAT\Diagbox" gd 0f
cd /d "%~dp0"
cls
title PFS BatchKit Manager v1.2.0 By GDX
echo.PFS BatchKit Manager v1.2.0 By GDX
echo.-------------------------------------------------------------------------------------------------------------
endlocal
endlocal
setlocal EnableDelayedExpansion
setlocal EnableExtensions
call "%~dp0BAT\__Cache\HDD.BAT" >nul 2>&1 & call "%~dp0BAT\settings.bat" >nul 2>&1
if defined @hdl_path (
"%~dp0BAT\Diagbox" gd 03
echo [!@hdl_path! !@ModelePS2HDD!] - [Total: !@TotalHDD_Size! - Used: !@TotalHDD_Used! !@TotalHDD_Percentage! - Free: !@TotalHDD_Available!] - [Loaded: !OPLPART!]
) else (
"%~dp0BAT\Diagbox" gd 0c
echo [NO DEVICE] PLEASE RELOAD HDD
)
"%~dp0BAT\Diagbox" gd 0f                                      
echo.-------------------------------------------------------------------------------------------------------------
echo.
ECHO  [=====^| HDD Management ^|=====]
ECHO.
ECHO  [1] Create a Partition
ECHO  [2] Delete a Partition
ECHO  [3] Blank a Partition
ECHO  [4] Show Partition Informations
ECHO  [5] Backup or Inject PS2 MBR Program
ECHO  [6] Explore PS2 HDD (Mount PFS partition from Windows Explorer)
ECHO  [7] NBD Server (Only to access PS2 HDD from network)
"%~dp0BAT\Diagbox" gd 06
ECHO  [8] Hack your HDD To PS2 Format ^(Only intended to be used as a boot entry point on wLaunchELF^)
"%~dp0BAT\Diagbox" gd 0c
ECHO  [9] Format HDD To PS2 Format
"%~dp0BAT\Diagbox" gd 0f
ECHO.
ECHO  [10] Back
ECHO  [12] Exit
ECHO.
echo.------------------------------------------
set "choice=" & set /p choice=Select Option:

if "!choice!"=="1" set "Part_Option=Create" & set "PFS_Option=mkpart" & set "Part_Option2=Creating" & (goto CreateDelPART)
if "!choice!"=="2" set "Part_Option=Delete" & set "PFS_Option=rmpart" & set "Part_Option2=Deleting" & (goto CreateDelPART)
if "!choice!"=="3" (goto BlankPart)
if "!choice!"=="4" (goto ShowPartitionInfos) 
if "!choice!"=="5" (goto MBRProgram)
if "!choice!"=="6" (goto PS2HDDExplore)
if "!choice!"=="7" (goto NBDServer)
if "!choice!"=="8" (goto hackHDDtoPS2)
if "!choice!"=="9" (goto formatHDDtoPS2)

if "!choice!"=="10" (goto Mainmenu)
if "!choice!"=="12" exit

(goto HDDManagementMenu)

:ShowPartitionInfos
"%~dp0BAT\Diagbox" gd 0f
cd /d "%~dp0"
cls
title PFS BatchKit Manager v1.2.0 By GDX
echo.PFS BatchKit Manager v1.2.0 By GDX
echo.-------------------------------------------------------------------------------------------------------------
endlocal
endlocal
setlocal EnableDelayedExpansion
setlocal EnableExtensions
call "%~dp0BAT\__Cache\HDD.BAT" >nul 2>&1 & call "%~dp0BAT\settings.bat" >nul 2>&1
if defined @hdl_path (
"%~dp0BAT\Diagbox" gd 03
echo [!@hdl_path! !@ModelePS2HDD!] - [Total: !@TotalHDD_Size! - Used: !@TotalHDD_Used! !@TotalHDD_Percentage! - Free: !@TotalHDD_Available!] - [Loaded: !OPLPART!]
) else (
"%~dp0BAT\Diagbox" gd 0c
echo [NO DEVICE] PLEASE RELOAD HDD
)
"%~dp0BAT\Diagbox" gd 0f                                      
echo.-------------------------------------------------------------------------------------------------------------
echo.
ECHO  [=====^| Partition Informations ^|=====]
ECHO.
ECHO  [1] Show PS1 Games Partitions Table
ECHO  [2] Show PS2 Games Partitions Table
ECHO  [3] Show APP Homebrew Partitions Table
ECHO  [4] Show PFS System Partitions Table
ECHO  [5] 
ECHO  [6]
ECHO  [7]
ECHO  [8] Show Total POPS Partitions Size
ECHO  [9] Show Total Partitions Size
REM ECHO 9. Scan Partitions Error
ECHO.
ECHO  [10] Back
ECHO  [11] Back to main menu
ECHO  [12] Exit
ECHO.
echo.------------------------------------------
set "choice=" & set /p choice=Select Option:

if "!choice!"=="1" set "ShowPartitionList=PS1 Games" & (goto PartitionInfoList)
if "!choice!"=="2" set "ShowPartitionList=PS2 Games" & (goto PartitionInfoList)
if "!choice!"=="3" set "ShowPartitionList=APP" & (goto PartitionInfoList)
if "!choice!"=="4" set "ShowPartitionList=System" & (goto PartitionInfoList)

if "!choice!"=="8" set "ShowPartitionList=Total POPS Size" & (goto PartitionInfoList)
if "!choice!"=="9" set "ShowPartitionList=Total Size" & (goto PartitionInfoList)
REM if "!choice!"=="9" set DiagPartitionError=yes & (goto PartitionInfoList)

if "!choice!"=="10" (goto HDDManagementMenu)
if "!choice!"=="11" (goto mainmenu)
if "!choice!"=="12" exit

(goto ShowPartitionInfos)

:PS2HDDExplore
"%~dp0BAT\Diagbox" gd 0f
cd /d "%~dp0"
cls
IF NOT EXIST "%~dp0TMP" MD "%~dp0TMP" 
title PFS BatchKit Manager v1.2.0 By GDX
echo.PFS BatchKit Manager v1.2.0 By GDX
echo.-------------------------------------------------------------------------------------------------------------
endlocal
endlocal
setlocal EnableDelayedExpansion
setlocal EnableExtensions
call "%~dp0BAT\__Cache\HDD.BAT" >nul 2>&1 & call "%~dp0BAT\settings.bat" >nul 2>&1
if defined @hdl_path (
"%~dp0BAT\Diagbox" gd 03
echo [!@hdl_path! !@ModelePS2HDD!] - [Total: !@TotalHDD_Size! - Used: !@TotalHDD_Used! !@TotalHDD_Percentage! - Free: !@TotalHDD_Available!] - [Loaded: !OPLPART!]
) else (
"%~dp0BAT\Diagbox" gd 0c
echo [NO DEVICE] PLEASE RELOAD HDD
)
"%~dp0BAT\Diagbox" gd 0f                                      
echo.-------------------------------------------------------------------------------------------------------------
echo.
ECHO  [=====^| Explore PS2 HDD ^|=====]
ECHO.
ECHO  [1] Mount Partition from PS2 HDD
ECHO  [2] Mount Partition from IMAGE
ECHO  [3] Umount All Partition
ECHO  [4]
ECHO  [5]
ECHO  [6]
ECHO  [7] Show driver version
ECHO  [8] Install/Update Driver
ECHO  [9] Uninstall Driver
ECHO.
ECHO  [10] Back
ECHO  [11] Back to main menu
ECHO  [12] Exit
ECHO.
echo.------------------------------------------
set "choice=" & set /p choice=Select Option:

"%~dp0BAT\busybox" ls "C:\Program Files\Dokan" > "%~dp0TMP\DokanFolder.txt" & set /P DokanFolder=<"%~dp0TMP\DokanFolder.txt"
if "!choice!"=="1" set "mount=HDD" & (goto PS2HDD2WinExplorer)
if "!choice!"=="2" cls & set "mount=IMG" & (goto DokanMountIMG)
if "!choice!"=="3" cls & (goto DokanUmountDoManuallyPartition)

if "!choice!"=="7" set CheckDokanVersion=yes & (goto PS2HDD2WinExplorer)
if "!choice!"=="8" cls & set "InstallDokanDriver=yes" & (goto InstallDokanDriver)
if "!choice!"=="9" cls & set "UninstallDokanDriver=yes" & (goto UninstallDokanDriver)

if "!choice!"=="10" (goto HDDManagementMenu)
if "!choice!"=="11" (goto mainmenu)
if "!choice!"=="12" exit

(goto PS2HDDExplore)

:NBDServer
"%~dp0BAT\Diagbox" gd 0f
cd /d "%~dp0"
cls
title PFS BatchKit Manager v1.2.0 By GDX
echo.PFS BatchKit Manager v1.2.0 By GDX
echo.-------------------------------------------------------------------------------------------------------------
endlocal
endlocal
setlocal EnableDelayedExpansion
setlocal EnableExtensions
call "%~dp0BAT\__Cache\HDD.BAT" >nul 2>&1 & call "%~dp0BAT\settings.bat" >nul 2>&1
if defined @hdl_path (
"%~dp0BAT\Diagbox" gd 03
echo [!@hdl_path! !@ModelePS2HDD!] - [Total: !@TotalHDD_Size! - Used: !@TotalHDD_Used! !@TotalHDD_Percentage! - Free: !@TotalHDD_Available!] - [Loaded: !OPLPART!]
) else (
"%~dp0BAT\Diagbox" gd 0c
echo [NO DEVICE] PLEASE RELOAD HDD
)
"%~dp0BAT\Diagbox" gd 0f                                      
echo.-------------------------------------------------------------------------------------------------------------
echo.
ECHO  [=====^| Network block device Server ^|=====]
ECHO.
ECHO  [1] Mount Device 
ECHO  [2] Umount Device
ECHO  [3] Show list of mounted devices
ECHO  [4]
ECHO  [5]
ECHO  [6]
ECHO  [7]
ECHO  [8] Install/Update NBD Driver
ECHO  [9] Uninstall NBD Driver
ECHO.
ECHO  [10] Back
ECHO  [11] Back to main menu
ECHO  [12] Exit
ECHO.
echo.------------------------------------------
set "choice=" & set /p choice=Select Option:

if "!choice!"=="1" (
echo\
echo\
set /p nbdip="Enter your PS2 NBD server IP:"
cls
echo Connection to the server 
echo Please wait...
echo\
"%~dp0BAT\wnbd-client.exe" map PS2HDD !nbdip!
echo\
echo\
pause & goto ScanningPS2HDD
)

if "!choice!"=="2" cls & "%~dp0BAT\wnbd-client.exe" unmap PS2HDD & echo\ & echo\ & pause
if "!choice!"=="3" cls & "%~dp0BAT\wnbd-client.exe" list & echo\ & echo\ & pause
if "!choice!"=="8"  (goto InstallNBDDriver)
if "!choice!"=="9" (
cls
echo\
echo Are you sure you want to uninstall NBD-Server drivers^?
choice /c YN 
if errorlevel 2 (goto NBDServer)

"%~dp0BAT\wnbd-client.exe" uninstall-driver
echo\ 
pause
)

if "!choice!"=="10" (goto HDDManagementMenu)
if "!choice!"=="11" (goto mainmenu)
if "!choice!"=="12" exit

(goto NBDServer)

REM ############################################################################################################################################################
:TransferPS2Games
cls
mkdir "%~dp0TMP" >nul 2>&1

IF NOT DEFINED @hdl_path (

"%~dp0BAT\Diagbox" gd 06
	echo Do you want to install your games over the network with hdl_svr^?
	"%~dp0BAT\Diagbox" gd 0f
	echo it is an alternative to NBD Server
	echo But some features will not be available like file transfer
	echo\
	choice /c YN
	if !errorlevel!==1 (set transferHDLServ=yes)
	if !errorlevel!==2 (rmdir /Q/S "%~dp0TMP" >nul 2>&1 & goto ScanningPS2HDD)	
	)

if not defined transferHDLServ (
"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning for Playstation 2 HDDs:
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "!@hdl_path!" | "%~dp0BAT\busybox" grep "Playstation 2 HDD" >nul
if errorlevel 1 set "@hdl_path=" & goto ScanningPS2HDD
echo       [!@hdl_path! !@TotalHDD_Size! - !@ModelePS2HDD!]


"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Install PS2 Games:
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1^) Yes
"%~dp0BAT\Diagbox" gd 0c
echo         2^) No
echo\
"%~dp0BAT\Diagbox" gd 07
CHOICE /C 123 /M "Select Option:"

if !ERRORLEVEL!==2 (goto mainmenu)

) else (
copy "%~dp0BAT\hdl_svr_093.elf" "%~dp0" >nul 2>&1
echo\
echo 1 - Launch hdl_svr_093.elf with wLaunchELF
echo 2 - Once launched, type IP address here
set /p "@hdl_path=Enter IP address of the Playstation 2:"
ping -n 1 -w 2000 !@hdl_path!
if errorlevel 1 (
"%~dp0BAT\Diagbox" gd 0c
echo Unable to ping !@hdl_path!
"%~dp0BAT\Diagbox" gd 0f
pause & (goto mainmenu)
	)
)

cls
echo\
"%~dp0BAT\Diagbox" gd 0e
echo Do you want to change the default directory^?
"%~dp0BAT\Diagbox" gd 07
echo ^(Useful if your games are on another hard drive or path^)
CHOICE /C YN
echo\
if !errorlevel!==1 (
echo Example: E:\PS2\Games
set /p "HDDPATH=Enter the path where yours PS2 Games located:"
if "!HDDPATH!"=="" set "HDDPATH="
)

if defined HDDPATH (
    set filepath="!HDDPATH!\*.iso" "!HDDPATH!\*.cue" "!HDDPATH!\*.zso" "!HDDPATH!\*.7z" "!HDDPATH!\*.zip" "!HDDPATH!\*.rar"
) else (
	set HDDPATH=%~dp0
    set filepath="%~dp0DVD\*.iso" "%~dp0DVD\*.cue" "%~dp0DVD\*.zso" "%~dp0DVD\*.7z" "%~dp0DVD\*.zip" "%~dp0DVD\*.rar" "%~dp0CD\*.iso" "%~dp0CD\*.cue" "%~dp0CD\*.zso" "%~dp0CD\*.7z" "%~dp0CD\*.zip" "%~dp0CD\*.rar"
)

  echo\
  "%~dp0BAT\Diagbox" gd 0e
  echo Do you want to use the title database for your games^? [Yes recommended]
  "%~dp0BAT\Diagbox" gd 07
  echo If you choose NO the file names will be used as titles.
  choice /c YN
  if errorlevel 2 (set usedb=no) else (set usedb=yes)

IF !usedb!==yes (
if not exist "%~dp0BAT\TitlesDB\TitlesDB_PS2_!TitlesLang!.txt" set "TitlesLang=English"
"%~dp0BAT\busybox" iconv -f utf8 -t ascii//TRANSLIT//IGNORE "%~dp0BAT\TitlesDB\TitlesDB_PS2_!TitlesLang!.txt" > "%~dp0TMP\gameid.txt"
copy "%~dp0BAT\TitlesDB\TitlesDB_PS2_!TitlesLang!.txt" "%~dp0TMP\gameid_HDD-OSD.txt" >nul 2>&1
)

echo\
echo\
echo\
"%~dp0BAT\Diagbox" gd 0e
echo Do you want to use recommended installation settings^?
"%~dp0BAT\Diagbox" gd 07
echo If you put no, you can customize the installation. like HDD-OSD, ZSO etc...
CHOICE /C YN /M "Select Option:"
if errorlevel 1 set RecommendedSettings=yes
if errorlevel 2 set RecommendedSettings=no

if !RecommendedSettings!==yes (
set InfoGameConfig=Yes
) else (
echo ---------------------------------------------------
echo\
"%~dp0BAT\Diagbox" gd 0e
echo Do you want inject OPL-Launcher ^(Optional^)
"%~dp0BAT\Diagbox" gd 07
echo Allows you to launch your game from HDD-OSD ^(Browser 2.0^)
CHOICE /C YN /M "Select Option:"
if errorlevel 1 set InjectKELF=yes
if errorlevel 2 set InjectKELF=no

IF !InjectKELF!==yes (
echo\
"%~dp0BAT\Diagbox" gd 0e
echo Do you want to download game icons for HDD-OSD^?
"%~dp0BAT\Diagbox" gd 07
CHOICE /C YN /M "Select Option:"
if errorlevel 1 set DownloadICO=yes
if errorlevel 2 set DownloadICO=no

if !DownloadICO!==yes (
if exist "%~dp0HDD-OSD-Icons-Pack.zip" (
echo\
"%~dp0BAT\Diagbox" gd 0e
echo HDD-OSD-Icons-Pack.zip detected do you want use it^?
"%~dp0BAT\Diagbox" gd 0f
CHOICE /C YN /M "Select Option:"
IF ERRORLEVEL 1 set uselocalARTHDDOSD=yes
IF ERRORLEVEL 2 set uselocalARTHDDOSD=no
) else (set uselocalARTHDDOSD=no)

if !uselocalARTHDDOSD!==no (
    cd /d "%~dp0TMP"
    echo\
	echo Checking internet Or Website connection... For HDD-OSD ART
	ping -n 1 -w 2000 archive.org >nul
	if errorlevel 1 (
			"%~dp0BAT\Diagbox" gd 0c
			echo Unable to PING^^!
			if exist "%~dp0HDD-OSD-Icons-Pack.zip" set uselocalARTHDDOSD=yes
			"%~dp0BAT\Diagbox" gd 07
			) else (
	"%~dp0BAT\wget" -q --show-progress "https://archive.org/download/hdd-osd-icons-pack/HDD-OSD-Icons-Pack.zip/PS1%%2FSCES_000.01%%2FPreview.png" -O "%~dp0TMP\Preview.png" >nul 2>&1
	for %%F in (Preview.png) do if %%~zF==0 del "%%F"

if not exist Preview.png (
"%~dp0BAT\Diagbox" gd 0c
    echo\
	echo Unable to connect to internet Or Website
	if exist "%~dp0HDD-OSD-Icons-Pack.zip" set uselocalARTHDDOSD=yes
	echo You will switch to offline mode
	echo\
	echo\
"%~dp0BAT\Diagbox" gd 0f
	pause
			) else (set DownloadARTHDDOSD=yes)
		)
	)
)
 
echo\
"%~dp0BAT\Diagbox" gd 0e
echo Do you want to hide ps2 game partitions in HDD-OSD^?
"%~dp0BAT\Diagbox" gd 07
echo Allows you to display only the games you want
CHOICE /C YN /M "Select Option:"
if errorlevel 1 set "GameHide=-hide"
if errorlevel 2 set "GameHide="
)

echo\
"%~dp0BAT\Diagbox" gd 0e
echo Do you want to add game information in CFG for OPL ^? ^(Optional^)
"%~dp0BAT\Diagbox" gd 07
echo Like: Title, Description, Developer 
CHOICE /C YN /M "Select Option:"
if errorlevel 1 set InfoGameConfig=Yes
if errorlevel 2 set "InfoGameConfig="

echo\
"%~dp0BAT\Diagbox" gd 0e
echo Compress your games in .ZSO^? ^(EXPERIMENTAL^)
"%~dp0BAT\Diagbox" gd 07
echo Allows you to reduce the size of your games
echo Requires the latest version of OPL development build
echo Download Here: https://github.com/ps2homebrew/Open-PS2-Loader/releases

"%~dp0BAT\Diagbox" gd 06
echo\
echo EXPERIMENTAL, NOT RECOMMENDED For the average user
echo NOTE: Some games require mode 1 to be enabled in OPL to work with zso format
"%~dp0BAT\Diagbox" gd 07
echo\
CHOICE /C YN /M "Select Option:"
if errorlevel 1 set ConvZSO=yes
if errorlevel 2 set ConvZSO=no
echo\

if !ConvZSO!==yes (
echo 1. Normal Compression
echo 2. Max Compression LZ4 HC
CHOICE /C 12 /M "Select Option:"
if errorlevel 1 set "LZ4HC="
if errorlevel 2 set "LZ4HC=--lz4hc"

echo\
"%~dp0BAT\Diagbox" gd 0e
echo Do you want to delete .ZSO files after installation^?
"%~dp0BAT\Diagbox" gd 07
CHOICE /C YN /M "Select Option:"
if errorlevel 1 set DelConvZSO=yes
if errorlevel 2 set DelConvZSO=no
 )
)

echo\
echo\
echo Please wait...
if !ConvZSO!==yes if defined transferHDLServ ("%~dp0BAT\hdl_dump" hdl_toc !@hdl_path!> "%~dp0TMP\GameslistHDD.txt") else (type "%~dp0BAT\__Cache\PS2_GAMES_HDD.txt" > "%~dp0TMP\GameslistHDD.txt")

REM Download Compatibility Database
"%~dp0BAT\wget" -q --show-progress "https://github.com/GDX-X/PS2-OPL-CFG-Compatibility-Database/releases/download/Latest/PS2-OPL-CFG-Compatibility-Database.7z" >nul 2>&1 -O "%~dp0TMP\PS2-OPL-CFG-Compatibility-Database.7z"
for %%F in ("%~dp0TMP\PS2-OPL-CFG-Compatibility-Database.7z") do if %%~zF==0 (del %%F >nul 2>&1) else (move "%~dp0TMP\PS2-OPL-CFG-Compatibility-Database.7z" "%~dp0BAT" >nul 2>&1)

echo ---------------------------------------------------
"%rootpath%\BAT\busybox" ls -p !filepath! 2>&1| "%rootpath%\BAT\busybox" grep -v /| "%rootpath%\BAT\busybox" sed "/No such file or directory/d" | "%rootpath%\BAT\busybox" sed "s/.*\\\(.*\)/\1\t&/" >>"%rootpath%\TMP\GameslistTMP.txt" & type "%rootpath%\TMP\GameslistTMP.txt" | "%rootpath%\BAT\busybox" sort | "%rootpath%\BAT\busybox" cut -f 2- >"%rootpath%\TMP\Gameslist.txt"
set /a gamecount=0
for /f "usebackq delims=" %%f in ("%~dp0TMP\Gameslist.txt") do (
set /a gamecount+=1

	setlocal DisableDelayedExpansion
	set fpath=%%~dpf
	set filename=%%~nxf
    set fname=%%~nf
	set disctype=unknown
	set "dbtitle="
	set "dbtitleosd="
	set "region="
	set "Game_Installed="
	set "CheckTitle="
	set "MultiTrack="
	setlocal EnableDelayedExpansion
	
	if "!filename!"=="!fname!.zip" set compressed=zip
	if "!filename!"=="!fname!.ZIP" set compressed=ZIP
	if "!filename!"=="!fname!.7z" set compressed=7z
	if "!filename!"=="!fname!.7Z" set compressed=7Z
	if "!filename!"=="!fname!.rar" set compressed=rar
	if "!filename!"=="!fname!.RAR" set compressed=RAR
	REM if "!filename!"=="!fname!.zso" set zso=ZSO
	REM if "!filename!"=="!fname!.ZSO" set zso=ZSO
	
    echo\
	echo\
	echo !gamecount! - !filename! & cd /d !fpath!
	
	if "!filename!"=="!fname!.!compressed!" (
	"%~dp0BAT\7-Zip\7z" x -bso0 "!fpath!\!fname!.!compressed!" -o"!fpath!\~TMP~_!gamecount!"
	dir /b /a-d "!fpath!\~TMP~_!gamecount!" | "%~dp0BAT\busybox" grep -ie ".*\.iso$" -ie ".*\.cue$" -ie ".*\.zso$" > "%~dp0TMP\GamesUnzip.txt" & set /P filename=<"%~dp0TMP\GamesUnzip.txt"
    dir /b /a-d "!fpath!\~TMP~_!gamecount!" | "%~dp0BAT\busybox" grep -ie ".*\.iso$" -ie ".*\.cue$" -ie ".*\.zso$" | "%~dp0BAT\busybox" sed -e "s/\.[^.]*$//" > "%~dp0TMP\GamesUnzip.txt" & set /P fname=<"%~dp0TMP\GamesUnzip.txt"
	dir /b /a-d "!fpath!\~TMP~_!gamecount!" | "%~dp0BAT\busybox" grep -ie ".*\.iso$" -ie ".*\.cue$" -ie ".*\.zso$" | "%~dp0BAT\busybox" sed -e "s/.*\.//g" > "%~dp0TMP\GamesUnzip.txt"  & set /P ext=<"%~dp0TMP\GamesUnzip.txt"
	move "!fpath!\~TMP~_!gamecount!\*" "!fpath!" >nul 2>&1 & rmdir /Q/S "!fpath!\~TMP~_!gamecount!" >nul 2>&1
	set DelExtracted=yes
	)
     
	if exist "!fpath!\!fname! (Track *).bin" (
	set MultiTrack=Yes
    "%~dp0BAT\binmerge" "!filename!" "%~dp0TMP\!fname!" | findstr "Merging ERROR"
    ren "!fname!.cue" "!fname!~TMP.cue" >nul 2>&1
	move "%~dp0TMP\!fname!.bin" "!fpath!" >nul 2>&1
    move "%~dp0TMP\!fname!.cue" "!fpath!" >nul 2>&1
    )

	if "!filename!"=="!fname!.cue" set ext=CUE
	if "!filename!"=="!fname!.CUE" set ext=CUE
	if "!filename!"=="!fname!.iso" set ext=ISO
	if "!filename!"=="!fname!.ISO" set ext=ISO
	
	if !ext!==zso set filename=!fname!.zso
	if "!filename!"=="!fname!.zso" "%~dp0BAT\ziso" --cache-size 4 --replace !LZ4HC! -i "!fname!.zso" -o "!fname!.iso" & set ext=ISO

	if defined ext ( "%~dp0BAT\hdl_dump" cdvd_info2 ".\!fname!.!ext!" > "%~dp0TMP\cdvd_info.txt"
	for /f "usebackq tokens=1,2,3,4,5*" %%i in ("%~dp0TMP\cdvd_info.txt") do (
	if "%%i"=="CD" set disctype=CD
	if "%%i"=="DVD" set disctype=DVD
	if "%%i"=="dual-layer" set disctype=DVD
		)
	)
	
	REM Get gameid
	"%~dp0BAT\busybox" grep -o -m 1 "[A-Z][A-Z][A-Z][A-Z][_][0-9][0-9][0-9]\.[0-9][0-9]" "%~dp0TMP\cdvd_info.txt" > "%~dp0TMP\game_serial_id.txt" & set /P gameid=<"%~dp0TMP\game_serial_id.txt"
	
    REM else (
	REM "%~dp0BAT\busybox" grep -o -m 1 "[A-Z][A-Z][A-Z][A-Z][_-][0-9][0-9][0-9].[0-9][0-9]" "!filename!" | "%~dp0BAT\busybox" sed "s/-/_/g" | "%~dp0BAT\busybox" head -1 > cdvd_info.txt
	REM set "ext=ZSO" & set "disctype=DVD" & set /P gameid=<cdvd_info.txt
	REM )
	
	set fnheader=!fname:~0,11!
	if "!fnheader!"==%%l (
		  set title=!fname:~12!
		) else (
	      if "!fnheader!"==%%m ( set title=!fname:~12!) else ( set title=!fname!)
		)

    if "!disctype!"=="unknown" (
    "%~dp0BAT\Diagbox" gd 0c
    echo	WARNING: Unable to determine disc type^^! File ignored.
    "%~dp0BAT\Diagbox" gd 07
	echo !date! - !time! - "!filename!">> "%~dp0__Not_Installed_PS2.txt"
		) else (
		
		if "!usedb!"=="yes" (
		
			REM Fix Conflict Games. Rare games that have the same ID
			findstr !gameid! "%~dp0BAT\Fix_Conflict_Gameid_Title.bat" >nul 2>&1
			if errorlevel 1 (echo >NUL) else (set "FixGameInstall=PS2" & call "%~dp0BAT\Fix_Conflict_Gameid_Title.bat")
			
			if not defined dbtitle (
			for /f "tokens=1*" %%A in ( 'findstr !gameid! "%~dp0TMP\gameid.txt"' ) do (
				if not defined dbtitle set dbtitle=%%B
				)
			)
			
			if defined dbtitle (
				if "!dbtitle:~-1,1!"==" " (
					set title=!dbtitle:~0,-1!
				) else (
					set title=!dbtitle!
				)
			)
		)
		
		 REM Game ID with PBPX other region than JAP
		 findstr !gameid! "%~dp0BAT\Fix_Conflict_Gameid_Title.bat" >nul 2>&1
		 if errorlevel 1 (echo >NUL) else (set "FixGameRegion=Yes" & call "%~dp0BAT\Fix_Conflict_Gameid_Title.bat")
	  
		 if not defined region (
		 REM A = Asia
		 if "!gameid:~2,1!"=="A" set region=NTSC-A
		 REM C = China          
       	 if "!gameid:~2,1!"=="C" set region=NTSC-C
		 REM E = Europe         
		 if "!gameid:~2,1!"=="E" set region=PAL
		 REM K = Korean         
		 if "!gameid:~2,1!"=="K" set region=NTSC-K
		 REM P = Japan          
		 if "!gameid:~2,1!"=="P" set region=NTSC-J
		 REM UC = North America 
		 if "!gameid:~2,1!"=="U" set region=NTSC-U/C
         )
		 REM Unknown region
		 if not defined region set region=X
		
		 if "!ConvZSO!"=="yes" (
		 IF EXIST "!fpath!\!fname!.zso" (set DelConvZSO=no) else (
		 
		 REM Check if the game is already installed
		 "%~dp0BAT\busybox" grep -o -m 1 "!gameid!  !title!" "%~dp0TMP\GameslistHDD.txt" > "%~dp0TMP\CheckTitle.txt" & set /P CheckTitle=<"%~dp0TMP\CheckTitle.txt"
		 
		 if "!CheckTitle!"=="" (
		 echo !gameid!  !title!>> "%~dp0TMP\GameslistHDD.txt"
		 
		 REM echo Convert to ZSO... Please wait
         if "!disctype!"=="CD" (
		 if exist "!fname!.iso" (
		 "%~dp0BAT\ziso" --cache-size 4 --replace !LZ4HC! --hdl-fix -i "!fname!.iso" -o "!fname!.zso"
		 REM "%~dp0BAT\maxcso" !LZ4HC! --block=2048 --format=zso "!fname!.iso" >nul 2>&1
		 
		 ) else (
		 "%~dp0BAT\bchunk" "!fname!.bin" "!fname!.cue" "!fname!" >nul 2>&1 & ren "!fname!01.iso" "!fname!.iso" >nul 2>&1
		 "%~dp0BAT\ziso" --cache-size 4 --replace !LZ4HC! --hdl-fix -i "!fname!.iso" -o "!fname!.zso"
		 REM "%~dp0BAT\maxcso" --block=2048 --format=zso "!fname!.iso" >nul 2>&1
		 set filename=!fname!.zso
		 REM del "!fname!.iso" >nul 2>&1
		     )
            )
		 if "!disctype!"=="DVD" "%~dp0BAT\ziso" --cache-size 4 --replace !LZ4HC! --hdl-fix -i "!fname!.iso" -o "!fname!.zso"
           ) else (set Game_Installed=Yes)
		  )
		 )
		 
	   REM GET FILE SIZE
	   if "!filename!"=="!fname!.iso" "%~dp0BAT\busybox" du -csh "!fname!.iso" 2>&1 | "%~dp0BAT\busybox" grep -e "total" | "%~dp0BAT\busybox" sed -e "s/total//g; s/K/KB/g; s/M/MB/g; s/G/GB/g" > "%~dp0TMP\isosize.txt" & set /P size=<"%~dp0TMP\isosize.txt"
	   if "!filename!"=="!fname!.cue" "%~dp0BAT\busybox" du -csh "!fname!.bin" 2>&1 | "%~dp0BAT\busybox" grep -e "total" | "%~dp0BAT\busybox" sed -e "s/total//g; s/K/KB/g; s/M/MB/g; s/G/GB/g" > "%~dp0TMP\binsize.txt" & set /P size=<"%~dp0TMP\binsize.txt"
	   if "!filename!"=="!fname!.zso" set ext=ZSO& "%~dp0BAT\busybox" du -csh "!fname!.zso" 2>&1 | "%~dp0BAT\busybox" grep -e "total" | "%~dp0BAT\busybox" sed -e "s/total//g; s/K/KB/g; s/M/MB/g; s/G/GB/g" > "%~dp0TMP\zsosize.txt" & set /P size=<"%~dp0TMP\zsosize.txt"
       if "!ConvZSO!"=="yes" set ext=ZSO& "%~dp0BAT\busybox" du -csh "!fname!.zso" 2>&1 | "%~dp0BAT\busybox" grep -e "total" | "%~dp0BAT\busybox" sed -e "s/total//g; s/K/KB/g; s/M/MB/g; s/G/GB/g" > "%~dp0TMP\zsosize.txt" & set /P size=<"%~dp0TMP\zsosize.txt"  
            
			echo ---------------------------------------------------
			echo Title:    [!title!]
			echo Gameid:   [!gameid!]
			echo Region:   [!region!]
			echo DiscType: [!disctype!]
			echo Format:   [!ext!]
			echo Size:     [!size!]
			echo ---------------------------------------------------
			
	   "%~dp0BAT\7-Zip\7z" e -bso0 "%~dp0BAT\HDD-OSD_SAMPLE_HEADER.zip" -o"!fpath!" PS2\icon.sys -r -y >nul 2>&1
	   if !DownloadICO!==yes (
	   echo           Downloading Resources...
	   if !DownloadARTHDDOSD!==yes for %%f in (icon.sys list.ico del.ico) do "%~dp0BAT\wget" -q "https://archive.org/download/hdd-osd-icons-pack/HDD-OSD-Icons-Pack.zip/PS2%%2F!gameid!%%2F%%f" -O "%~dp0TMP\%%f" >nul
	   if !uselocalARTHDDOSD!==yes if exist "%~dp0HDD-OSD-Icons-Pack.zip" "%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0HDD-OSD-Icons-Pack.zip" -o"%~dp0TMP" PS2\!gameid!\ -r -y >nul 2>&1 & move "%~dp0TMP\PS2\!gameid!\*" "%~dp0TMP" >nul 2>&1
	   
	   for /r "%~dp0TMP" %%F in (*.ico *.sys) do if %%~zF==0 (del "%%F" >nul 2>&1) else (move "%%F" "!fpath!" >nul 2>&1)
	   if not exist "!fpath!\del.ico" copy "!fpath!\list.ico" "!fpath!\del.ico" >nul 2>&1
       )

	   REM HDD-OSD Infos
	   if exist "!fpath!\icon.sys" (
	   
	   if "!usedb!"=="yes" if not defined dbtitleosd for /f "tokens=1*" %%A in ('findstr !gameid! "%~dp0TMP\gameid_HDD-OSD.txt"') do set dbtitleosd=%%B
	   	
	   if not defined dbtitleosd set dbtitleosd=!title!
       echo "!dbtitleosd!"| "%~dp0BAT\busybox" sed -e "s/\&/\\\&/g; s./.\\\/.g; s/\""//g" > "%~dp0TMP\dbtitle.txt" & set /P dbtitleosd=<"%~dp0TMP\dbtitle.txt"
	   echo !gameid!| "%~dp0BAT\busybox" sed "s/_/-/g" | "%~dp0BAT\busybox" sed "s/\.//" > "%~dp0TMP\DetectID.txt" & set /P gameid2=<"%~dp0TMP\DetectID.txt"
	   "%~dp0BAT\busybox" sed -i -e "s/ = /=/g; s/=/ = /g; s/  =/ = /g" "!fpath!\icon.sys"
	   "%~dp0BAT\busybox" sed -i -e "s/title0 =.*/title0 =/g; s/title0 =/title0 = !dbtitleosd!/g" "!fpath!\icon.sys"
 	   "%~dp0BAT\busybox" sed -i -e "s/title1 =.*/title1 =/g; s/title1 =/title1 = !gameid2!/g" "!fpath!\icon.sys"
	   )

			REM Change the extension file to iso but if it detects the zso file it will install the zso file instead of the iso
			if "!filename!"=="!fname!.zso" set "ext=ISO"
			
			echo           Installing...
			"%~dp0BAT\Diagbox" gd 0d
			if defined Game_Installed (
			echo !@hdl_path! partition with such name already exists: "!title!"
			) else (
			REM Since hdl_dump update DVD9 doesn't seem to work properly anymore
			REM so a stable version will be used for the installation of games in iso/bin
			if exist !fname!.zso (set hdl_dump=hdl_dump) else (set hdl_dump=hdl_dump_stable)
			
			"%~dp0BAT\!hdl_dump!" inject_!disctype! !@hdl_path! "!title!" "!fname!.!ext!" !gameid! *u4 !GameHide!
			if errorlevel 1 (echo.) else (echo.)
			)
			
			echo "!title!"| "%~dp0BAT\busybox" sed "s/^.//g; s/\s*$//g; s/[^A-Za-z0-9.\\\"\\\"]/_/g; s/\./_/g; s/.$//g; y/abcdefghijklmnopqrstuvwxyz/ABCDEFGHIJKLMNOPQRSTUVWXYZ/" | "%~dp0BAT\busybox" sed -e "s/^^/PP.!gameid2!../g; s/[[:space:]]*$//g;" | "%~dp0BAT\busybox" cut -c0-31 > "%~dp0TMP\GPartName.txt" & set /P GPartName=<"%~dp0TMP\GPartName.txt"
			if defined GameHide set GPartName=__.!GPartName:~3!
			REM Inject header in partition
			if !InjectKELF!==yes copy "%~dp0BAT\boot.kelf" "!fpath!" >nul 2>&1
			"%~dp0BAT\hdl_dump" modify_header !@hdl_path! "!GPartName!" >nul 2>&1
			
			REM Game infos 
			if exist "%~dp0CFG\!gameid!.cfg" del "%~dp0CFG\!gameid!.cfg" >nul 2>&1
			
			if !InfoGameConfig!==Yes "%~dp0BAT\busybox" sed -n "/<game serial=\"!gameid2!\">/{:a;N;/<\/game>/^!ba;s/.*<game serial=\"!gameid2!\">\(.*\)<\/game>.*/\1/p}" "%~dp0BAT\PS2DB.xml" | "%~dp0BAT\busybox" sed -e "s/<\([^>]*\)>\([^<]*\)<\/\1>/\1=\2/g; s/<\([^>]*\) \/>/\1=/g; s/^[ \t]*//; s/[ \t]*$//; /^$/d" > "%~dp0CFG\!gameid!.cfg"
			if not exist "%~dp0CFG\!gameid!.cfg" "%~dp0BAT\7-Zip\7z" e -bso0 "%~dp0BAT\OPL-Games-Infos-Database-Project.7z" -o"%~dp0CFG" EXAMPLE.cfg -r -y & ren "%~dp0CFG\EXAMPLE.cfg" "!gameid!.cfg"
			for %%F in ("%~dp0CFG\!gameid!.cfg") do if %%~zF==0 del "%~dp0CFG\!gameid!.cfg" >nul 2>&1 & "%~dp0BAT\7-Zip\7z" e -bso0 "%~dp0BAT\OPL-Games-Infos-Database-Project.7z" -o"%~dp0CFG\!TitlesLang!" EXAMPLE.cfg -r -y & ren "%~dp0CFG\EXAMPLE.cfg" "!gameid!.cfg"
			
			REM Compatibility
			if exist "%~dp0CFG\!gameid!.cfg" (
			"%~dp0BAT\7-Zip\7z" e -bso0 "%~dp0BAT\PS2-OPL-CFG-Compatibility-Database.7z" -o"%~dp0TMP" HDD\!gameid!.cfg -r -y >nul 2>&1
			if exist "%~dp0TMP\!gameid!.cfg" "%~dp0BAT\busybox" grep -ie "^[$]" -ie "Modes=" "%~dp0TMP\!gameid!.cfg" >> "%~dp0CFG\!gameid!.cfg"
			) else (
			"%~dp0BAT\7-Zip\7z" e -bso0 "%~dp0BAT\PS2-OPL-CFG-Compatibility-Database.7z" -o"%~dp0CFG" HDD\!gameid!.cfg -r -y >nul 2>&1
			)
	
			echo "!title!"| "%~dp0BAT\busybox" sed -e "s/\&/\\\&/g; s./.\\\/.g" | "%~dp0BAT\busybox" iconv -f windows-1252 -t utf-8 > "%~dp0TMP\fixtitle.txt"
	        "%~dp0BAT\busybox" sed -i "s/\"//g" "%~dp0TMP\fixtitle.txt"
	        set /P titleCFG=<"%~dp0TMP\fixtitle.txt"
			"%~dp0BAT\busybox" sed -i -e "s/Title=.*/Title=/g; s/Title=/Title=!titleCFG!/g" "%~dp0CFG\!gameid!.cfg" >nul 2>&1
			
			REM Fix OPL Freeze cut the description to 255 characters max
			"%~dp0BAT\busybox" sed -i "s/Description=\(.\{1,254\}\).*/Description=\1/" "%~dp0CFG\!gameid!.cfg"
            
            if defined MultiTrack (
			del "!fpath!\!fname!.bin" >nul 2>&1
			del "!fpath!\!fname!.cue" >nul 2>&1
			ren "!fname!~TMP.cue" "!fname!.cue" >nul 2>&1
			)
			
			if "!DelConvZSO!"=="yes" del "!fname!.zso" >nul 2>&1
			if "!filename!"=="!fname!.zso" del "!fname!.iso" >nul 2>&1
			if "!DelExtracted!"=="yes" del "!fname!.cue" >nul 2>&1 & del "!fname!.bin" >nul 2>&1 & del "!fname!.iso" >nul 2>&1 & del "!fname!.zso" >nul 2>&1 & del "!fname! (Track *).bin" >nul 2>&1 & del "!fname!.cue" >nul 2>&1
			for %%o in (*.ico *.sys boot.kelf) do del "%%o" >nul 2>&1
			echo !gameid!>> "%~dp0TMP\cfg.id"
			"%~dp0BAT\Diagbox" gd 07
			echo ---------------------------------------------------
		)
	endlocal
endlocal
)

	 cd /d "%~dp0CFG" & echo\
	 echo device !@pfsshell_path! > "%~dp0TMP\pfs-OPLconfig.txt"
     echo mount !OPLPART! >> "%~dp0TMP\pfs-OPLconfig.txt"
	 if defined CUSTOM_OPLPART echo mkdir OPL >> "%~dp0TMP\pfs-OPLconfig.txt"
     if defined CUSTOM_OPLPART echo cd OPL >> "%~dp0TMP\pfs-OPLconfig.txt"
	 echo mkdir CFG >> "%~dp0TMP\pfs-OPLconfig.txt"
     echo cd CFG >> "%~dp0TMP\pfs-OPLconfig.txt"
	 for /f "usebackq tokens=*" %%f in ("%~dp0TMP\cfg.id") do (
	 echo rm %%f >> "%~dp0TMP\pfs-OPLconfig.txt"	  
	 echo put %%f >> "%~dp0TMP\pfs-OPLconfig.txt"
	 )
	 echo cd .. >> "%~dp0TMP\pfs-OPLconfig.txt"
	 echo rm games.bin >> "%~dp0TMP\pfs-OPLconfig.txt"
	 echo umount >> "%~dp0TMP\pfs-OPLconfig.txt"
     echo exit >> "%~dp0TMP\pfs-OPLconfig.txt"
     type "%~dp0TMP\pfs-OPLconfig.txt" | "%~dp0BAT\pfsshell" >nul 2>&1
	 
	 REM Reloading HDD Cache
	 echo\
	 echo Reloading HDD Cache...
     call "%~dp0BAT\__ReloadHDD_cache.bat" >nul 2>&1

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo Completed...
echo\
echo\
"%~dp0BAT\Diagbox" gd 0f

cd /d "%~dp0" & rmdir /Q/S "%~dp0TMP" >nul 2>&1

echo\
pause & (goto mainmenu)
REM ########################################################################################################################################################################
:CopyPS2GamesHDD
cls
cd /d "%~dp0" & rmdir /Q/S "%~dp0TMP" >nul 2>&1
mkdir "%~dp0TMP" >nul 2>&1
cd /d "%~dp0TMP"

IF NOT DEFINED @hdl_path ( rmdir /Q/S "%~dp0TMP" >nul 2>&1 & goto ScanningPS2HDD ) else (
"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning for Playstation 2 HDDs:
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "!@hdl_path!" | "%~dp0BAT\busybox" grep "Playstation 2 HDD" >nul
if errorlevel 1 set "@hdl_path=" & goto ScanningPS2HDD
echo       [!@hdl_path! !@TotalHDD_Size! - !@ModelePS2HDD!]
)

set hdlhdd=%@hdl_path%
set PhysicDrive1=\\.\PHYSICALDRIVE%@NumberPS2HDD%
"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning for second HDD:
echo ---------------------------------------------------
    "%~dp0BAT\Diagbox" gd 03

	"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "Playstation 2 HDD" 2>&1 | "%~dp0BAT\busybox" sed "/!hdlhdd!/d" | "%~dp0BAT\busybox" grep -o "hdd[0-9]:\|hdd[0-9][0-9]:" | "%~dp0BAT\busybox" sed "s/hdd//g; s/://g" > "%~dp0TMP\hdl-hdd.txt"
	powershell -Command "Get-WmiObject Win32_DiskDrive | Select-Object Model,DeviceID" > "%~dp0TMP\hdd-type.txt"
	for /f "usebackq tokens=*" %%f in ("%~dp0TMP\hdl-hdd.txt") do "%~dp0BAT\busybox" grep "PHYSICALDRIVE%%f" "%~dp0TMP\hdd-type.txt" >> "%~dp0TMP\hdd-typetmp.txt"
	
	if exist "%~dp0TMP\hdd-typetmp.txt" type "%~dp0TMP\hdd-typetmp.txt"
	"%~dp0BAT\Diagbox" gd 07
    echo.
    echo ---------------------------------------------------
	"%~dp0BAT\Diagbox" gd 06
	echo Connect your second Playstation 2 HDD
    echo Type R For refresh list of hard drives
	echo\
	echo If your HDD is not detected it must be in PS2 format so it will have to be formatted before
    echo\
	echo\
	"%~dp0BAT\Diagbox" gd 0c
	echo NOTE: I strongly recommend creating the +OPL partition before copying your games
	echo\
	echo\
	"%~dp0BAT\Diagbox" gd 0f
	echo 	R. Refresh HDD
	echo 	Q. Back to main menu
	echo\
	echo\
	set choice=
    set /p choice=Enter the number of the second HDD on which you want to copy the games:
    echo\
    IF "!choice!"=="" set "hdlhdd2=" & set "PhysicDrive2=" & (goto CopyPS2GamesHDD)
    IF "!choice!"=="!choice!" set "hdlhdd2=hdd!choice!:" & set PhysicDrive2=\\.\PHYSICALDRIVE!choice!
	IF "!choice!"=="R" (goto CopyPS2GamesHDD)
	IF "!choice!"=="r" (goto CopyPS2GamesHDD)
    IF "!choice!"=="Q" set "hdlhdd=" & set "hdlhdd2=" & (goto GamesManagement)
	IF "!choice!"=="q" set "hdlhdd=" & set "hdlhdd2=" & (goto GamesManagement)

cls
if !PhysicDrive2!==!PhysicDrive1! (
echo\
echo\
"%~dp0BAT\Diagbox" gd 06
echo You cannot use the primary HDD as a destination HDD^^!
"%~dp0BAT\Diagbox" gd 07
echo\
echo\
pause & goto CopyPS2GamesHDD
) else (
"%~dp0BAT\Diagbox" gd 0e
echo HDD 1 Selected: Hard drive that contains your games
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "!hdlhdd!"
"%~dp0BAT\Diagbox" gd 0f
powershell -Command "Get-WmiObject Win32_DiskDrive | Select-Object Model,DeviceID" | findstr "Model !PhysicDrive1!" > "%~dp0TMP\__PhysicDrive1.txt" & type "%~dp0TMP\__PhysicDrive1.txt"
"%~dp0BAT\Diagbox" gd 0e
echo ---------------------------------------------------
echo\

echo HDD 2 Selected: Destination
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "!hdlhdd2!"
"%~dp0BAT\Diagbox" gd 0f
powershell -Command "Get-WmiObject Win32_DiskDrive | Select-Object Model,DeviceID" | findstr "Model !PhysicDrive2!" > "%~dp0TMP\__PhysicDrive2.txt" & type "%~dp0TMP\__PhysicDrive2.txt"
"%~dp0BAT\Diagbox" gd 0e
echo ---------------------------------------------------
echo\
CHOICE /C YN /m "Confirm"
if ERRORLEVEL 1 set AnalyseGameName=Yes
if ERRORLEVEL 2 set "hdlhdd=" & set "hdlhdd2=" & (goto CopyPS2GamesHDD)
echo\
)

:RefreshGamelistHDD
"%~dp0BAT\Diagbox" gd 0f
cls
echo\
echo\
echo Scanning Games List:
"%~dp0BAT\Diagbox" gd e
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 03

if defined AnalyseGameName (
type "%~dp0BAT\__Cache\PS2_GAMES_HDD.txt" | "%~dp0BAT\busybox" sed "s/\(.\{46\}\)./\1/" > "%~dp0TMP\GamelistPS2HDD1Origi.txt"

"%~dp0BAT\busybox" sed -e "1d" "%~dp0TMP\GamelistPS2HDD1Origi.txt" | "%~dp0BAT\busybox" sed -e "$ d" | "%~dp0BAT\busybox" cut -c35-500 > "%~dp0TMP\GamelistPS2HDD1TMP.txt"
"%~dp0BAT\busybox" sort -k2 "%~dp0TMP\GamelistPS2HDD1TMP.txt" > "%~dp0TMP\GamelistPS2HDD1.txt"
"%~dp0BAT\busybox" sed -i "s/$/ n/" "%~dp0TMP\GamelistPS2HDD1TMP.txt"
set "AnalyseGameName="
)
chcp 1252 >nul 2>&1

REM For manual text editor 
if exist "%~dp0TMP\GameSelectedListTMP.txt" "%~dp0BAT\busybox" diff "%~dp0TMP\GameSelectedListTMP.txt" "%~dp0TMP\GameSelectedList.txt" | "%~dp0BAT\busybox" grep "^-" | "%~dp0BAT\busybox" sed "s/^-//" | "%~dp0BAT\busybox" sed -e "1d" > "%~dp0TMP\GameListTMPX.TXT"
copy "%~dp0TMP\GameSelectedList.txt" "%~dp0TMP\GameSelectedListTMP.txt" >nul 2>&1

if exist "%~dp0TMP\GameListTMPX.TXT" (if defined GameNameDeselect (type "%~dp0TMP\GameListTMPX.TXT" >> "%~dp0TMP\GamelistPS2HDD1.txt") else (echo >nul))

if defined DeselectGame (type "%~dp0TMP\GameSelectedList.txt" | "%~dp0BAT\busybox" sort -k2) else (type "%~dp0TMP\GamelistPS2HDD1.txt" | "%~dp0BAT\busybox" sort -k2)
"%~dp0BAT\Diagbox" gd 0e
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0f

    if defined DeselectGame (
	echo\
    echo 	1. Back to selection
	echo\
	echo\
	set "GameNameDeselected="
    set /p GameNameDeselected="Enter the name of the game you want to deselect:"
	IF "!GameNameDeselected!"=="" (goto RefreshGamelistHDD)
	IF "!GameNameDeselected!"=="1" (set "DeselectGame=") else (
	IF "!GameNameDeselected!"=="." (goto RefreshGamelistHDD)
	
	"%~dp0BAT\busybox" grep -Fx "!GameNameDeselected!" "%~dp0TMP\GameSelectedList.txt" >> "%~dp0TMP\GamelistPS2HDD1.txt" 2>&1
	"%~dp0BAT\busybox" sed -i "\|^^!GameNameDeselected!|d" "%~dp0TMP\GameSelectedList.txt"
	"%~dp0BAT\busybox" sort "%~dp0TMP\GamelistPS2HDD1.txt" > "%~dp0TMP\SORTMP.txt" & type "%~dp0TMP\SORTMP.txt" > "%~dp0TMP\GamelistPS2HDD1.txt"
	set "GameNameDeselected="
	)
	
	) else (
	
	echo\
    echo 	1. Proceed to copy
    echo 	2. Deselect a game
    echo 	3. Select All
	echo 	4. Open Text Editor ^(Add games directly with a text editor^)
    echo.
	echo 	9. Back to main menu
    echo\
    echo\
	if not exist "%~dp0TMP\GameSelectedList.txt" type nul>"%~dp0TMP\GameSelectedList.txt"
	type nul>"%~dp0TMP\Size.txt"
	set "GameName="
	set "@Total_Game="
	REM set "Total_Size="
	echo Example: SLES_510.61 Grand Theft Auto : Vice City
    set /p GameName="Enter Gameid + GameName:"
	
	IF "!GameName!"=="" (goto RefreshGamelistHDD)
	IF "!GameName!"=="1" set "GameName=" & goto COPYSELECTEDGAME
	IF "!GameName!"=="2" set "DeselectGame=Yes" & set "GameName=" & (goto RefreshGamelistHDD)
	IF "!GameName!"=="3" type "%~dp0TMP\GamelistPS2HDD1.txt" > "%~dp0TMP\GameSelectedList.txt"
	IF "!GameName!"=="4" set "chcp65=Yes" & "%~dp0TMP\GameSelectedList.txt"
	IF "!GameName!"=="9" cd /d "%~dp0" & rmdir /Q/S "%~dp0TMP" >nul 2>&1 & (goto mainmenu)
	
	REM "%~dp0BAT\busybox" sed -i "/!GameName!$/d" "%~dp0TMP\GameSelectedList.txt"
	"%~dp0BAT\busybox" grep -Fx "!GameName!" "%~dp0TMP\GamelistPS2HDD1.txt" >> "%~dp0TMP\GameSelectedList.txt" 2>&1
	echo Please wait...
	for /f "usebackq tokens=*" %%f in ("%~dp0TMP\GameSelectedList.txt") do (
    setlocal DisableDelayedExpansion
    set GameNameTMP=%%f
    setlocal EnableDelayedExpansion
	"%~dp0BAT\busybox" sed -i "\|^^!GameNameTMP!|d" "%~dp0TMP\GamelistPS2HDD1.txt"
	 endlocal
	endlocal
	)
	"%~dp0BAT\busybox" sed -i -e "$aENDLINEPFSBM" "%~dp0TMP\GameSelectedList.txt" | "%~dp0BAT\busybox" sed -i -e "/ENDLINEPFSBM/d" "%~dp0TMP\GameSelectedList.txt" & "%~dp0BAT\busybox" sed -i -e "/^$/d" "%~dp0TMP\GameSelectedList.txt"
	REM "%~dp0BAT\busybox" sed -i "s/!GameName! n/!GameName! y/" "%~dp0TMP\GamelistPS2HDD1TMP.txt"
	)
	(goto RefreshGamelistHDD)

:COPYSELECTEDGAME
type nul> "%~dp0TMP\GamelistPS2HDD1OrigiTMP.txt"
cls
if defined chcp65 chcp 65001 >nul 2>&1

"%~dp0BAT\busybox" grep -F -f "%~dp0TMP\GameSelectedList.txt" "%~dp0TMP\GamelistPS2HDD1Origi.txt" > "%~dp0TMP\GamelistPS2HDD1OrigiTMP.txt"
"%~dp0BAT\busybox" awk "^!x[$0]++" "%~dp0TMP\GamelistPS2HDD1OrigiTMP.txt" | "%~dp0BAT\busybox" cut -c5-11 > "%~dp0TMP\Size.txt"

REM Calculs
for /f %%s in (Size.txt) do (set /a "Total_GameSize+=%%s/1000")
if !Total_GameSize! LSS 1000 (set @Total_GameSize=!Total_GameSize!MB) else (set /a "value=!Total_GameSize! / 1000" & set /a "remainder=!Total_GameSize! %% 1000" & set @Total_GameSize=!value!.!remainder!GB)

"%~dp0BAT\Diagbox" gd 0e
echo HDD 1 Selected: Hard drive that contains your games
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "!hdlhdd!"
"%~dp0BAT\Diagbox" gd 0f
type "%~dp0TMP\__PhysicDrive1.txt"
"%~dp0BAT\Diagbox" gd 0e
echo ---------------------------------------------------
echo\

echo HDD 2 Selected: Destination
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "!hdlhdd2!"
"%~dp0BAT\Diagbox" gd 0f
type "%~dp0TMP\__PhysicDrive2.txt"
"%~dp0BAT\Diagbox" gd 0e
echo ---------------------------------------------------

echo\
echo\
echo Selected games:
"%~dp0BAT\busybox" sed -e "$aENDLINEPFSBM" "%~dp0TMP\GameSelectedList.txt" | "%~dp0BAT\busybox" sed -e "/ENDLINEPFSBM/d" | "%~dp0BAT\busybox" sed -e "/^$/d" | "%~dp0BAT\busybox" wc -l > "%~dp0TMP\Total_Game.txt" & set /P @Total_Game=<"%~dp0TMP\Total_Game.txt"
"%~dp0BAT\Diagbox" gd 0e
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
type "%~dp0TMP\GameSelectedList.txt" | "%~dp0BAT\busybox" sort -k2
"%~dp0BAT\Diagbox" gd 0e
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0f

"%~dp0BAT\hdl_dump" toc !hdlhdd2! | "%~dp0BAT\busybox" grep "Total slice size:" > "%~dp0TMP\HDD2_FreeSpace.txt"

for /f "usebackq tokens=8" %%s in ("%~dp0TMP\HDD2_FreeSpace.txt") do set "Total_HDDFree=%%s" & set Total_HDDFree=!Total_HDDFree:~0,-2!
if !Total_HDDFree! LSS 1000 (set @Total_HDDFree=!Total_HDDFree!MB) else (set /a "value=!Total_HDDFree! / 1000" & set /a "remainder=!Total_HDDFree! %% 1000" & set @Total_HDDFree=!value!.!remainder!GB)

set /a "Total_HDDAfter=!Total_HDDFree!-!Total_GameSize!" 
if !Total_HDDFree! LSS 1000 (set @Total_HDDAfter=!Total_HDDAfter!MB) else (set /a "value=!Total_HDDAfter! / 1000" & set /a "remainder=!Total_HDDAfter! %% 1000" & set @Total_HDDAfter=!value!.!remainder!GB)

echo\
echo\
echo         TOTAL - Selected:  [!@Total_Game!]
echo         TOTAL - Size:      [!@Total_GameSize!]
echo\
echo         !hdlhdd2! - FreeSpace: [!@Total_HDDFree!]
echo         !hdlhdd2! - FreeAfter: [!@Total_HDDAfter!]

echo\
echo\
CHOICE /C YN /m "Confirm"
IF !ERRORLEVEL!==2 set "Total_GameSize=" & set "@Total_GameSize=" & (goto RefreshGamelistHDD)

if /i !Total_GameSize! gtr !Total_HDDFree! (
"%~dp0BAT\Diagbox" gd 06
echo\
echo\
echo The HDD does not have enough free space to copy the selected games.

echo\
"%~dp0BAT\Diagbox" gd 0f
PAUSE & set "Total_GameSize=" & set "@Total_GameSize=" & (goto RefreshGamelistHDD)
) else (

echo\
"%~dp0BAT\Diagbox" gd 0e
echo Do you want to copy your custom game icons displayed on HDD-OSD?
"%~dp0BAT\Diagbox" gd 0f
CHOICE /C YN
if errorlevel 1 set copyiconHDDOSD=yes
if errorlevel 2 set copyiconHDDOSD=no

echo\
"%~dp0BAT\Diagbox" gd 0e
echo Do you want to install the selected games in alphabetical order?
"%~dp0BAT\Diagbox" gd 0f
CHOICE /C YN /m "Confirm?"
IF %ERRORLEVEL%==1 set "sortgame=UseSort" & "%~dp0BAT\busybox" sort -k2 "%~dp0TMP\GameSelectedList.txt" > "%~dp0TMP\GameSelectedList!sortgame!.txt"

REM I'm using this unoptimized Spaghetti method because hdl dump has a bug that prevents copying the next game after copying the first.
REM I will optimize the code later if the bug is solved
REM see https://github.com/ps2homebrew/hdl-dump/issues/73

"%~dp0BAT\busybox" sed -i "s/&/\\\&/g" "%~dp0TMP\GameSelectedList!sortgame!.txt"
for /f "tokens=*" %%f in (GameSelectedList!sortgame!.txt) do (

   setlocal DisableDelayedExpansion
   set GameName=%%f
   setlocal EnableDelayedExpansion
   
   REM This is only to correctly display the title of the game in the cmd
   "%~dp0BAT\busybox" grep -m1 -w "!GameName!" "%~dp0TMP\GamelistPS2HDD1Origi.txt" | "%~dp0BAT\busybox" cut -c35-500 > "%~dp0TMP\GameSelectedShow.txt" & set /P GameSelectedShow=<"%~dp0TMP\GameSelectedShow.txt"
   echo\
   echo\
   echo !GameSelectedShow!

   "%~dp0BAT\busybox" sed -i "s|!GameName! n|!GameName! y|g" "%~dp0TMP\GamelistPS2HDD1TMP.txt"
   "%~dp0BAT\busybox" grep -oE "[^ ]+$" "%~dp0TMP\GamelistPS2HDD1TMP.txt" | "%~dp0BAT\busybox" tr -d "\n" > "%~dp0TMP\GameSelected.txt" & set /P GameSelected=<"%~dp0TMP\GameSelected.txt"
   
   "%~dp0BAT\hdl_dump_stable" copy_hdd !hdlhdd! !hdlhdd2! !GameSelected!
   "%~dp0BAT\busybox" sed -i "s|!GameName! y|!GameName! n|g" "%~dp0TMP\GamelistPS2HDD1TMP.txt"

    endlocal
endlocal
)

if !copyiconHDDOSD!==yes (
mkdir "%~dp0TMP\PPHEADER" >nul 2>&1
"%~dp0BAT\busybox" grep -e "0x1337" "%~dp0BAT\__Cache\PARTITION_PS2HDD.txt" | "%~dp0BAT\busybox" cut -c30-500 > "%~dp0TMP\PPGamelistPS2HDD1.txt"
REM Why am I using this logic? To increase the compatibility of old format HDL partitions
"%~dp0BAT\busybox" sed -i "s/\&/&/g" "%~dp0TMP\GameSelectedList!sortgame!.txt"
echo --------------------------------------------

"%~dp0BAT\hdl_dump" toc !hdlhdd2! | "%~dp0BAT\busybox" grep -e "0x1337" | "%~dp0BAT\busybox" cut -c30-500 > "%~dp0TMP\PPGamelistPS2HDD2.txt"
"%~dp0BAT\hdl_dump" hdl_toc !hdlhdd2! | "%~dp0BAT\busybox" sed -e "1d" | "%~dp0BAT\busybox" sed -e "$ d" | "%~dp0BAT\busybox" sed "s/\(.\{46\}\)./\1/" | "%~dp0BAT\busybox" cut -c35-500 > "%~dp0TMP\GamelistPS2HDD2TMP.txt"

"%~dp0BAT\busybox" paste -d " " "%~dp0TMP\GamelistPS2HDD1TMP.txt" "%~dp0TMP\PPGamelistPS2HDD1.txt" | "%~dp0BAT\busybox" sed -e "s/ * PP/|PP/g; s/ * __\./|__\./g" > "%~dp0TMP\PPGamelistPS2NEW1.txt
"%~dp0BAT\busybox" paste -d " " "%~dp0TMP\GamelistPS2HDD2TMP.txt" "%~dp0TMP\PPGamelistPS2HDD2.txt" | "%~dp0BAT\busybox" sed -e "s/ * PP/|PP/g; s/ * __\./|__\./g" > "%~dp0TMP\PPGamelistPS2NEW2.txt

   for /f "tokens=*" %%f in (GameSelectedList!sortgame!.txt) do (
   
   setlocal DisableDelayedExpansion
   set GameName=%%f
   setlocal EnableDelayedExpansion
   
   "%~dp0BAT\busybox" grep -m1 -w "!GameName!" "%~dp0TMP\PPGamelistPS2NEW1.txt" | "%~dp0BAT\busybox" sed "s/^.*|//" > "%~dp0TMP\PPHEADER.txt" & set /P PPHEADERHDD1=<"%~dp0TMP\PPHEADER.txt"
   "%~dp0BAT\busybox" grep -m1 -w "!GameName!" "%~dp0TMP\PPGamelistPS2NEW2.txt" | "%~dp0BAT\busybox" sed "s/^.*|//" > "%~dp0TMP\PPHEADER.txt" & set /P PPHEADERHDD2=<"%~dp0TMP\PPHEADER.txt"

   echo\
   echo Backup "!PPHEADERHDD1!" partition header... from !hdlhdd!
   cd /d "%~dp0TMP\PPHEADER" & "%~dp0BAT\hdl_dump_fix_header" dump_header !hdlhdd! "!PPHEADERHDD1!" >nul 2>&1 & cd ..
   
   echo Inject "!PPHEADERHDD2!" partition header... to !hdlhdd2!
   cd /d "%~dp0TMP\PPHEADER" & "%~dp0BAT\hdl_dump" modify_header !hdlhdd2! "!PPHEADERHDD2!" >nul 2>&1 & cd ..
   
   del /Q "%~dp0TMP\PPHEADER\*" >nul 2>&1
   endlocal
 endlocal
  )
 )
)

cd /d "%~dp0" & rmdir /Q/S "%~dp0TMP" >nul 2>&1

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo Copy Completed...
echo\
echo\
"%~dp0BAT\Diagbox" gd 07

pause & (goto GamesManagement)
REM ########################################################################################################################################################################
:TransferAPPSARTCFGCHTTHMVMC
cls
cd /d "%~dp0"
mkdir "%~dp0TMP" >nul 2>&1

IF NOT DEFINED @hdl_path ( rmdir /Q/S "%~dp0TMP" >nul 2>&1 & goto ScanningPS2HDD ) else (
"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning for Playstation 2 HDDs:
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "!@hdl_path!" | "%~dp0BAT\busybox" grep "Playstation 2 HDD" >nul
if errorlevel 1 set "@hdl_path=" & goto ScanningPS2HDD
echo       [!@hdl_path! !@TotalHDD_Size! - !@ModelePS2HDD!]
)

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Transfer Applications: [APPS]
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1^) Yes
"%~dp0BAT\Diagbox" gd 0c
echo         2^) No
"%~dp0BAT\Diagbox" gd 07
echo\
CHOICE /C 12 /M "Select Option:"

IF %ERRORLEVEL%==1 set "@pfs_apps=yes" & echo APPS>"%~dp0TMP\pfs-choice.log"
IF %ERRORLEVEL%==2 set "@pfs_apps=no"

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Transfer Artworks: [ART]
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1^) Yes
"%~dp0BAT\Diagbox" gd 0c
echo         2^) No
"%~dp0BAT\Diagbox" gd 0e
echo		3^) Yes, Convert the art to 8-bit
"%~dp0BAT\Diagbox" gd 07
echo\
CHOICE /C 123 /M "Select Option:"

IF %ERRORLEVEL%==1 set "@pfs_art=yes" & echo ART>>"%~dp0TMP\pfs-choice.log"
IF %ERRORLEVEL%==2 set "@pfs_art=no"
IF %ERRORLEVEL%==3 set "@pfs_art=yes" & set "8BitConversion=Yes" & echo ART>>"%~dp0TMP\pfs-choice.log"

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Transfer Configs: [CFG]
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1^) Yes
"%~dp0BAT\Diagbox" gd 0c
echo         2^) No
"%~dp0BAT\Diagbox" gd 07
echo\
CHOICE /C 12 /M "Select Option:"
IF %ERRORLEVEL%==1 set "@pfs_cfg=yes" & echo CFG>>"%~dp0TMP\pfs-choice.log"
IF %ERRORLEVEL%==2 set "@pfs_cfg=no"

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Transfer Cheats: [CHT]
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1^) Yes
"%~dp0BAT\Diagbox" gd 0c
echo         2^) No
"%~dp0BAT\Diagbox" gd 07
echo\
CHOICE /C 12 /M "Select Option:"

IF %ERRORLEVEL%==1 set "@pfs_cht=yes" & echo CHT>>"%~dp0TMP\pfs-choice.log"
IF %ERRORLEVEL%==2 set "@pfs_cht=no"

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Transfer Languages: [LNG]
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1^) Yes
"%~dp0BAT\Diagbox" gd 0c
echo         2^) No
"%~dp0BAT\Diagbox" gd 07
echo\
CHOICE /C 12 /M "Select Option:"

IF %ERRORLEVEL%==1 set "@pfs_LNG=yes" & echo LNG>>"%~dp0TMP\pfs-choice.log"
IF %ERRORLEVEL%==2 set "@pfs_LNG=no"

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Transfer Themes: [THM]
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1^) Yes
"%~dp0BAT\Diagbox" gd 0c
echo         2^) No
"%~dp0BAT\Diagbox" gd 07
echo\
CHOICE /C 12 /M "Select Option:"

IF %ERRORLEVEL%==1 set "@pfs_thm=yes" & echo THM>>"%~dp0TMP\pfs-choice.log"
IF %ERRORLEVEL%==2 set "@pfs_thm=no"

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Transfer Virtual Memory Cards: [VMC]
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1^) Yes
"%~dp0BAT\Diagbox" gd 0c
echo         2^) No
"%~dp0BAT\Diagbox" gd 07
echo\
CHOICE /C 123 /M "Select Option:"

IF %ERRORLEVEL%==1 set "@pfs_vmc=yes" & echo VMC>>"%~dp0TMP\pfs-choice.log"
IF %ERRORLEVEL%==2 set "@pfs_vmc=no"

"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Estimating File Size:
echo ---------------------------------------------------
echo\
"%~dp0BAT\Diagbox" gd 07

if not exist "%~dp0TMP\pfs-choice.log" type nul>"%~dp0TMP\pfs-choice.log"
for /f "usebackq tokens=*" %%f in ("%~dp0TMP\pfs-choice.log") do (
"%~dp0BAT\busybox" ls -1 "%~dp0%%f" | "%~dp0BAT\busybox" wc -l > "%~dp0TMP\%%fFiles.txt" & set /P @%%f_Files=<"%~dp0TMP\%%fFiles.txt"
"%~dp0BAT\busybox" du -csh "%~dp0%%f" | "%~dp0BAT\busybox" grep -e "total" | "%~dp0BAT\busybox" sed -e "s/total//g; s/K/KB/g; s/M/MB/g; s/G/GB/g" > "%~dp0TMP\%%fSize.txt" & set /P @%%f_Size=<"%~dp0TMP\%%fSize.txt"
set %%f_Path="%~dp0%%f"
)

REM TOTAL INFO
"%~dp0BAT\busybox" du -csh !APPS_Path! !ART_Path! !CFG_Path! !LNG_Path! !CHT_Path! !THM_Path! !VMC_Path! : 2>&1 | "%~dp0BAT\busybox" grep -e "total" | "%~dp0BAT\busybox" sed -e "s/total//g; s/K/KB/g; s/M/MB/g; s/G/GB/g" > "%~dp0TMP\TotalSIZE.txt" & set /P @Total_Size=<"%~dp0TMP\TotalSIZE.txt"
set /a "@Total_Files=!@APPS_Files!+!@ART_Files!+!@CFG_Files!+!@CHT_Files!+!@LNG_Files!+!@THM_Files!+!@VMC_Files!+0"

if defined APPS_Path echo         APP - Files: !@APPS_Files! - Size: !@APPS_Size!
if defined ART_Path echo         ART - Files: !@ART_Files! - Size: !@ART_Size!
if defined CFG_Path echo         CFG - Files: !@CFG_Files! - Size: !@CFG_Size!
if defined CHT_Path echo         CHT - Files: !@CHT_Files! - Size: !@CHT_Size!
if defined LNG_Path echo         LNG - Files: !@LNG_Files! - Size: !@LNG_Size!
if defined THM_Path echo         THM - Files: !@THM_Files! - Size: !@THM_Size!
if defined VMC_Path echo         VMC - Files: !@VMC_Files! - Size: !@VMC_Size!
echo\
echo\
echo         TOTAL - Files: !@Total_Files! 
echo         TOTAL - Size: !@Total_Size!

"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Detecting OPL Resources Partition:
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0f

	"%~dp0BAT\busybox" grep -ow "!OPLPART!" "%~dp0BAT\__Cache\PARTITION_PS2HDD.txt" > "%~dp0TMP\hdd-prt.txt" & set /P @hdd_avl=<"%~dp0TMP\hdd-prt.txt"
	
	IF "!@hdd_avl!"=="!OPLPART!" (
	"%~dp0BAT\Diagbox" gd 0a
	echo         !OPLPART! - Partition Detected
	"%~dp0BAT\Diagbox" gd 07
	) else (
	"%~dp0BAT\Diagbox" gd 0c
	echo         !OPLPART! - Partition NOT Detected
	echo             Partition Must Be Created
	echo\
	echo\
	"%~dp0BAT\Diagbox" gd 07
	rmdir /Q/S "%~dp0TMP" >nul 2>&1
	pause & (goto OPLManagement)
	)

echo\
echo\
pause
cls
setlocal DisableDelayedExpansion

REM OPL APPS
IF %@pfs_apps%==yes (
echo\
echo\
echo Installing Applications [APPS]
echo ---------------------------------------------------
echo\

IF /I EXIST "%~dp0APPS\*" (

	cd "%~dp0APPS"
	echo         Creating Que
	echo device %@pfsshell_path% > "%~dp0TMP\pfs-apps.txt"
	echo mount %OPLPART% >> "%~dp0TMP\pfs-apps.txt"

	REM PARENT DIR (OPL\APPS)
    if defined CUSTOM_OPLPART echo mkdir OPL >> "%~dp0TMP\pfs-apps.txt"
    if defined CUSTOM_OPLPART echo cd OPL >> "%~dp0TMP\pfs-apps.txt"
	echo mkdir APPS >> "%~dp0TMP\pfs-apps.txt"
	echo cd APPS >> "%~dp0TMP\pfs-apps.txt"
	
    REM APPS FILES (OPL\APPS\files.xxx)
 	for %%0 in (*) do (echo put "%%0") >> "%~dp0TMP\pfs-apps.txt"

	REM APPS 1 DIR (OPL\APPS\APP)
	for /D %%a in (*) do (
	echo mkdir "%%a" >> "%~dp0TMP\pfs-apps.txt"
	echo lcd "%%a" >> "%~dp0TMP\pfs-apps.txt"
 	echo cd "%%a" >> "%~dp0TMP\pfs-apps.txt"
 	cd "%%a"

	REM APPS FILES (OPL\APPS\APP\files.xxx)
 	for %%1 in (*) do (echo put "%%1") >> "%~dp0TMP\pfs-apps.txt"

	REM APPS 2 SUBDIR (OPL\APPS\APP\SUBDIR)
	for /D %%b in (*) do (
	echo mkdir "%%b" >> "%~dp0TMP\pfs-apps.txt"
	echo lcd "%%b" >> "%~dp0TMP\pfs-apps.txt"
	echo cd "%%b" >> "%~dp0TMP\pfs-apps.txt"
	cd "%%b"

	REM APPS SUBDIR FILES (OPL\APPS\APP\SUBDIR\files.xxx)
	for %%2 in (*) do (echo put "%%2") >> "%~dp0TMP\pfs-apps.txt"
	
	REM APPS 3 SUBDIR (OPL\APPS\APP\SUBDIR\SUBDIR)
	for /D %%c in (*) do (
	echo mkdir "%%c" >> "%~dp0TMP\pfs-apps.txt"
	echo lcd "%%c" >> "%~dp0TMP\pfs-apps.txt"
	echo cd "%%c" >> "%~dp0TMP\pfs-apps.txt"
	cd "%%c"
	
	REM APPS SUBDIR FILES (OPL\APPS\APP\SUBDIR\SUBDIR\files.xxx)
	for %%3 in (*) do (echo put "%%3") >> "%~dp0TMP\pfs-apps.txt"
	
    REM APPS 4 SUBDIR (OPL\APPS\APP\SUBDIR\SUBDIR\SUBDIR\SUBDIR)
	for /D %%e in (*) do (
	echo mkdir "%%e" >> "%~dp0TMP\pfs-apps.txt"
	echo lcd "%%e" >> "%~dp0TMP\pfs-apps.txt"
	echo cd "%%e" >> "%~dp0TMP\pfs-apps.txt"
	cd "%%e"
	
	REM APPS SUBDIR FILES (OPL\APPS\APP\SUBDIR\SUBDIR\SUBDIR\files.xxx)
	for %%4 in (*) do (echo put "%%4") >> "%~dp0TMP\pfs-apps.txt"
	
	REM APPS 5 SUBDIR (OPL\APPS\APP\SUBDIR\SUBDIR\SUBDIR\SUBDIR\)
	for /D %%f in (*) do (
	echo mkdir "%%f" >> "%~dp0TMP\pfs-apps.txt"
	echo lcd "%%f" >> "%~dp0TMP\pfs-apps.txt"
	echo cd "%%f" >> "%~dp0TMP\pfs-apps.txt"
	cd "%%f"
	
	REM APPS SUBDIR FILES (OPL\APPS\APP\SUBDIR\SUBDIR\SUBDIR\SUBDIR\files.xxx)
	for %%5 in (*) do (echo put "%%5") >> "%~dp0TMP\pfs-apps.txt"
	
	REM APPS 6 SUBDIR (OPL\APPS\APP\SUBDIR\SUBDIR\SUBDIR\SUBDIR\)
	for /D %%g in (*) do (
	echo mkdir "%%g" >> "%~dp0TMP\pfs-apps.txt"
	echo lcd "%%g" >> "%~dp0TMP\pfs-apps.txt"
	echo cd "%%g" >> "%~dp0TMP\pfs-apps.txt"
	cd "%%g"
	
	REM APPS SUBDIR FILES (OPL\APPS\APP\SUBDIR\SUBDIR\SUBDIR\SUBDIR\SUBDIR\files.xxx)
	for %%6 in (*) do (echo put "%%6") >> "%~dp0TMP\pfs-apps.txt"
	
	REM APPS 7 SUBDIR (OPL\APPS\APP\SUBDIR\SUBDIR\SUBDIR\SUBDIR\SUBDIR\SUBDIR\)
	for /D %%h in (*) do (
	echo mkdir "%%h" >> "%~dp0TMP\pfs-apps.txt"
	echo lcd "%%h" >> "%~dp0TMP\pfs-apps.txt"
	echo cd "%%h" >> "%~dp0TMP\pfs-apps.txt"
	cd "%%h"
	
	REM APPS SUBDIR FILES (OPL\APPS\APP\SUBDIR\SUBDIR\SUBDIR\SUBDIR\SUBDIR\SUBDIR\files.xxx)
	for %%7 in (*) do (echo put "%%7") >> "%~dp0TMP\pfs-apps.txt"
	
	REM APPS 8 SUBDIR (OPL\APPS\APP\SUBDIR\SUBDIR\SUBDIR\SUBDIR\SUBDIR\SUBDIR\SUBDIR\)
	for /D %%i in (*) do (
	echo mkdir "%%i" >> "%~dp0TMP\pfs-apps.txt"
	echo lcd "%%i" >> "%~dp0TMP\pfs-apps.txt"
	echo cd "%%i" >> "%~dp0TMP\pfs-apps.txt"
	cd "%%i"
	
	REM APPS SUBDIR FILES (OPL\APPS\APP\SUBDIR\SUBDIR\SUBDIR\SUBDIR\SUBDIR\SUBDIR\SUBDIR\files.xxx)
	for %%8 in (*) do (echo put "%%8") >> "%~dp0TMP\pfs-apps.txt"
	
	REM APPS 9 SUBDIR (OPL\APPS\APP\SUBDIR\SUBDIR\SUBDIR\SUBDIR\SUBDIR\SUBDIR\SUBDIR\SUBDIR\)
	for /D %%j in (*) do (
	echo mkdir "%%j" >> "%~dp0TMP\pfs-apps.txt"
	echo lcd "%%j" >> "%~dp0TMP\pfs-apps.txt"
	echo cd "%%j" >> "%~dp0TMP\pfs-apps.txt"
	cd "%%j"
	
	REM APPS SUBDIR FILES (OPL\APPS\APP\SUBDIR\SUBDIR\SUBDIR\SUBDIR\SUBDIR\SUBDIR\SUBDIR\SUBDIR\files.xxx)
	for %%9 in (*) do (echo put "%%9") >> "%~dp0TMP\pfs-apps.txt"
	
	REM EXIT SUBDIR
	echo lcd .. >> "%~dp0TMP\pfs-apps.txt"
	echo cd .. >> "%~dp0TMP\pfs-apps.txt"
	cd ..
	)
	
	echo lcd .. >> "%~dp0TMP\pfs-apps.txt"
	echo cd .. >> "%~dp0TMP\pfs-apps.txt"
 	cd ..
	)
	
	echo lcd .. >> "%~dp0TMP\pfs-apps.txt"
	echo cd .. >> "%~dp0TMP\pfs-apps.txt"
 	cd ..
	)
	
	echo lcd .. >> "%~dp0TMP\pfs-apps.txt"
	echo cd .. >> "%~dp0TMP\pfs-apps.txt"
 	cd ..
    )
	
	echo lcd .. >> "%~dp0TMP\pfs-apps.txt"
	echo cd .. >> "%~dp0TMP\pfs-apps.txt"
 	cd ..
	)
	
	echo lcd .. >> "%~dp0TMP\pfs-apps.txt"
	echo cd .. >> "%~dp0TMP\pfs-apps.txt"
 	cd ..
	)
	
	echo lcd .. >> "%~dp0TMP\pfs-apps.txt"
	echo cd .. >> "%~dp0TMP\pfs-apps.txt"
 	cd ..
	)
	
	echo lcd .. >> "%~dp0TMP\pfs-apps.txt"
	echo cd .. >> "%~dp0TMP\pfs-apps.txt"
 	cd ..
	)
	
	echo lcd .. >> "%~dp0TMP\pfs-apps.txt"
	echo cd .. >> "%~dp0TMP\pfs-apps.txt"
 	cd ..
	)
	
	REM UNMOUNT
	echo ls -l >> "%~dp0TMP\pfs-apps.txt"
	echo umount >> "%~dp0TMP\pfs-apps.txt"
	echo exit >> "%~dp0TMP\pfs-apps.txt"

	echo         Installing Que
	type "%~dp0TMP\pfs-apps.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" grep -i -e "drwx" | "%~dp0BAT\busybox" sed -e "1,2d" > "%~dp0LOG\PFS-APPS.log"
	echo         APPS Completed...	
	) else ( echo         APPS - Source Not Detected... )
)

REM OPL ARTWORK
IF %@pfs_art%==yes (
echo\
echo\
echo Installing Artworks [ART]
echo ---------------------------------------------------
echo\

IF /I EXIST "%~dp0ART\*.*" (

	cd /d "%~dp0ART" & for %%F in ( "*.*" ) do if %%~zF==0 del "%%F"
	if defined 8BitConversion (
	echo         Converting to 8-bit...
	for %%F in (*.jpg *.png) do "%~dp0BAT\8bit" "%%F" "%~dp0ART\%%~nF.png" >nul 2>&1 & del "%~dp0ART\%%~nF.jpg" >nul 2>&1
	)
	
	echo         Creating Que
	echo device %@pfsshell_path% > "%~dp0TMP\pfs-art.txt"
	echo mount %OPLPART% >> "%~dp0TMP\pfs-art.txt"
    if defined CUSTOM_OPLPART echo mkdir OPL >> "%~dp0TMP\pfs-art.txt"
    if defined CUSTOM_OPLPART echo cd OPL >> "%~dp0TMP\pfs-art.txt"
	echo mkdir ART >> "%~dp0TMP\pfs-art.txt"
	echo cd ART >> "%~dp0TMP\pfs-art.txt"
	for %%f in (*) do (echo put "%%f") >> "%~dp0TMP\pfs-art.txt"
	echo ls -l >> "%~dp0TMP\pfs-art.txt"
	echo umount >> "%~dp0TMP\pfs-art.txt"
	echo exit >> "%~dp0TMP\pfs-art.txt"
	
	echo         Installing Que
	type "%~dp0TMP\pfs-art.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" grep -ie ".png" -ie ".jpg" > "%~dp0LOG\PFS-ART.log"
	echo         ART Completed...	
	) else ( echo         ART - Source Not Detected... )
)

REM OPL CONFIGS
IF %@pfs_cfg%==yes (
echo\
echo\
echo Installing Configs [CFG]
echo ---------------------------------------------------
echo\

IF /I EXIST "%~dp0CFG\*.*" (

	cd "%~dp0CFG"
	echo         Creating Que
	echo device %@pfsshell_path% > "%~dp0TMP\pfs-cfg.txt"
	echo mount %OPLPART% >> "%~dp0TMP\pfs-cfg.txt"
    if defined CUSTOM_OPLPART echo mkdir OPL >> "%~dp0TMP\pfs-cfg.txt"
    if defined CUSTOM_OPLPART echo cd OPL >> "%~dp0TMP\pfs-cfg.txt"
	echo mkdir CFG >> "%~dp0TMP\pfs-cfg.txt"
	echo cd CFG >> "%~dp0TMP\pfs-cfg.txt"
	for %%f in (*.cfg) do (echo put "%%f") >> "%~dp0TMP\pfs-cfg.txt"
	echo ls -l >> "%~dp0TMP\pfs-cfg.txt"
	echo umount >> "%~dp0TMP\pfs-cfg.txt"
	echo exit >> "%~dp0TMP\pfs-cfg.txt"
	
	echo         Installing Que
	type "%~dp0TMP\pfs-cfg.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" grep -ie ".*\.cfg$" > "%~dp0LOG\PFS-CFG.log"
	echo         CFG Completed...	
	) else ( echo         CFG - Source Not Detected... )
)

REM OPL CHEATS
IF %@pfs_cht%==yes (
echo\
echo\
echo Installing Cheats: [CHT]
echo ---------------------------------------------------
echo\

IF /I EXIST "%~dp0CHT\*.*" (

	cd "%~dp0CHT"
	echo         Creating Que
	echo device %@pfsshell_path% > "%~dp0TMP\pfs-cht.txt"
	echo mount %OPLPART% >> "%~dp0TMP\pfs-cht.txt"
    if defined CUSTOM_OPLPART echo mkdir OPL >> "%~dp0TMP\pfs-cht.txt"
    if defined CUSTOM_OPLPART echo cd OPL >> "%~dp0TMP\pfs-cht.txt"
	echo mkdir CHT >> "%~dp0TMP\pfs-cht.txt"
	echo cd CHT >> "%~dp0TMP\pfs-cht.txt"
	for %%f in (*.cht) do (echo put "%%f") >> "%~dp0TMP\pfs-cht.txt"
	echo ls -l >> "%~dp0TMP\pfs-cht.txt"
	echo umount >> "%~dp0TMP\pfs-cht.txt"
	echo exit >> "%~dp0TMP\pfs-cht.txt"
	
	echo         Installing Que
	type "%~dp0TMP\pfs-cht.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" grep -ie ".*\.cht$" > "%~dp0LOG\PFS-CHT.log"
	echo         CHT Completed...
	) else ( echo         CHT - Source Not Detected... )
)

IF %@pfs_LNG%==yes (
echo\
echo\
echo Installing Cheats: [LNG]
echo ---------------------------------------------------
echo\

IF /I EXIST "%~dp0LNG\*.*" (

	cd "%~dp0LNG"
	echo         Creating Que
	echo device %@pfsshell_path% > "%~dp0TMP\pfs-lng.txt"
	echo mount %OPLPART% >> "%~dp0TMP\pfs-lng.txt"
    if defined CUSTOM_OPLPART echo mkdir OPL >> "%~dp0TMP\pfs-lng.txt"
    if defined CUSTOM_OPLPART echo cd OPL >> "%~dp0TMP\pfs-lng.txt"
	echo mkdir LNG >> "%~dp0TMP\pfs-lng.txt"
	echo cd LNG >> "%~dp0TMP\pfs-lng.txt"
	for %%f in (*.lng *.TTF) do (echo put "%%f") >> "%~dp0TMP\pfs-lng.txt"
	echo ls -l >> "%~dp0TMP\pfs-lng.txt"
	echo umount >> "%~dp0TMP\pfs-lng.txt"
	echo exit >> "%~dp0TMP\pfs-lng.txt"
	
	echo         Installing Que
	type "%~dp0TMP\pfs-lng.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" grep -ie ".*\.lng$" > "%~dp0LOG\PFS-lng.log"
	echo         LNG Completed...
	) else ( echo         LNG - Source Not Detected... )
)

REM OPL VMC
IF %@pfs_vmc%==yes (
echo\
echo\
echo Installing Virtual Memory Card: [VMC]
echo ---------------------------------------------------
echo\

IF /I EXIST "%~dp0VMC\*.*" (

	cd "%~dp0VMC"
	echo         Creating Que
	echo device %@pfsshell_path% > "%~dp0TMP\pfs-vmc.txt"
	echo mount %OPLPART% >> "%~dp0TMP\pfs-vmc.txt"
    if defined CUSTOM_OPLPART echo mkdir OPL >> "%~dp0TMP\pfs-vmc.txt"
    if defined CUSTOM_OPLPART echo cd OPL >> "%~dp0TMP\pfs-vmc.txt"
	echo mkdir VMC >> "%~dp0TMP\pfs-vmc.txt"
	echo cd VMC >> "%~dp0TMP\pfs-vmc.txt"
	for %%f in (*.bin) do (echo put "%%f") >> "%~dp0TMP\pfs-vmc.txt"
	echo ls -l >> "%~dp0TMP\pfs-vmc.txt"
	echo umount >> "%~dp0TMP\pfs-vmc.txt"
	echo exit >> "%~dp0TMP\pfs-vmc.txt"
	
	echo         Installing Que
	type "%~dp0TMP\pfs-vmc.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" grep -ie ".*\.bin$" > "%~dp0LOG\PFS-VMC.log"
	echo         VMC Completed...
	) else ( echo         VMC - Source Not Detected... )
)

REM OPL THM
IF %@pfs_thm%==yes (
echo\
echo\
echo Installing Themes: [THM]
echo ---------------------------------------------------
echo\

IF /I EXIST "%~dp0THM\*" (

	cd "%~dp0THM"
	echo         Creating Que
	echo device %@pfsshell_path% > "%~dp0TMP\pfs-thm.txt"
	echo mount %OPLPART% >> "%~dp0TMP\pfs-thm.txt"
    
	REM PARENT DIR (OPL\THM)
    if defined CUSTOM_OPLPART echo mkdir OPL >> "%~dp0TMP\pfs-thm.txt"
    if defined CUSTOM_OPLPART echo cd OPL >> "%~dp0TMP\pfs-thm.txt"
	echo mkdir THM >> "%~dp0TMP\pfs-thm.txt"
	echo cd THM >> "%~dp0TMP\pfs-thm.txt"

	REM THEME DIR (OPL\THM\THEME)
	for /D %%x in (*) do (
	echo mkdir "%%x" >> "%~dp0TMP\pfs-thm.txt"
	echo lcd "%%x" >> "%~dp0TMP\pfs-thm.txt"
 	echo cd "%%x" >> "%~dp0TMP\pfs-thm.txt"
 	cd "%%x"

	REM THEME FILES (OPL\THM\THEME\files.xxx)
 	for %%0 in (*) do (echo put "%%0") >> "%~dp0TMP\pfs-thm.txt"

	REM THEME SUBDIR (OPL\THM\THEME\SUBDIR)
	for /D %%y in (*) do (
	echo mkdir "%%y" >> "%~dp0TMP\pfs-thm.txt"
	echo lcd "%%y" >> "%~dp0TMP\pfs-thm.txt"
	echo cd "%%y" >> "%~dp0TMP\pfs-thm.txt"
	cd "%%y"

	REM THEME SUBDIR FILES (OPL\THM\THEME\SUBDIR\files.xxx)
	for %%l in (*) do (echo put "%%l") >> "%~dp0TMP\pfs-thm.txt"

	REM EXIT SUBDIR
	echo lcd .. >> "%~dp0TMP\pfs-thm.txt"
	echo cd .. >> "%~dp0TMP\pfs-thm.txt"
	cd ..
	)
	
	echo lcd .. >> "%~dp0TMP\pfs-thm.txt"
	echo cd .. >> "%~dp0TMP\pfs-thm.txt"
 	cd ..
	)
	
	REM UNMOUNT
	echo ls -l >> "%~dp0TMP\pfs-thm.txt"
	echo umount >> "%~dp0TMP\pfs-thm.txt"
	echo exit >> "%~dp0TMP\pfs-thm.txt"

	echo         Installing Que
	type "%~dp0TMP\pfs-thm.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" grep -i -e "drwx" | "%~dp0BAT\busybox" sed -e "1,2d" > "%~dp0LOG\PFS-THM.log"
	echo         THM Completed...	
	) else ( echo         THM - Source Not Detected... )
)

cd "%~dp0" & rmdir /Q/S "%~dp0TMP" >nul 2>&1

echo\
echo\
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo Installations Completed...
echo\
echo\
"%~dp0BAT\Diagbox" gd 07

endlocal
pause & (goto OPLManagement)
REM ########################################################################################################################################################################
:TransferPS1Games
cls
mkdir "%~dp0TMP" >nul 2>&1

IF NOT DEFINED @hdl_path ( rmdir /Q/S "%~dp0TMP" >nul 2>&1 & goto ScanningPS2HDD ) else (
"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning for Playstation 2 HDDs:
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "!@hdl_path!" | "%~dp0BAT\busybox" grep "Playstation 2 HDD" >nul
if errorlevel 1 set "@hdl_path=" & goto ScanningPS2HDD
echo       [!@hdl_path! !@TotalHDD_Size! - !@ModelePS2HDD!]
)

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Install PS1 Games:
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1^) Yes
"%~dp0BAT\Diagbox" gd 0c
echo         2^) No
"%~dp0BAT\Diagbox" gd 0e
echo         3^) Yes (Install .VCD as partition for HDD-OSD, PSBBN, XMB Menu)
echo\
"%~dp0BAT\Diagbox" gd 07
CHOICE /C 123 /M "Select Option:"

IF %ERRORLEVEL%==1 set @pfs_pop=yes & set "choice="
IF %ERRORLEVEL%==2 (goto mainmenu)
IF %ERRORLEVEL%==3 set @pfs_popHDDOSDMAIN=yes & (goto TransferPS1GamesHDDOSD)


cls
echo\
"%~dp0BAT\Diagbox" gd 0e
echo Do you want to change the default directory^?
"%~dp0BAT\Diagbox" gd 07
echo ^(Useful if your games are on another hard drive or path^)
CHOICE /C YN
echo\
if !errorlevel!==1 (
echo Example: E:\PS1\Games
set /p "HDDPATH=Enter the path where yours PS2 Games located:"
if "!HDDPATH!"=="" set "HDDPATH="
)

if not defined HDDPATH set HDDPATH=%~dp0POPS

if not exist "%~dp0BAT\TitlesDB\TitlesDB_PS1_!TitlesLang!.txt" set "TitlesLang=English"

echo\
"%~dp0BAT\Diagbox" gd 0e
echo Do you want to create PS1 shortcuts for the OPL APPS TAB^?
"%~dp0BAT\Diagbox" gd 0f
CHOICE /C yn /M "Select Option:"
IF !ERRORLEVEL!==1 set "CreatePS1Shortcut=Yes"
IF !ERRORLEVEL!==2 set "CreatePS1Shortcut=No"

if !CreatePS1Shortcut!==Yes (
echo\
echo Do you want to add a prefix^? in front of shortcut names
CHOICE /C YN
IF !ERRORLEVEL!==1 (
echo\
echo Select Prefix option
echo 1 = [PS1]
echo 2 = CUSTOM
echo 3 = Nothing
CHOICE /C 123
IF !ERRORLEVEL!==1 set prefix=[PS1]
IF !ERRORLEVEL!==2 echo\& set /p "prefix=Enter your prefix:"
IF !ERRORLEVEL!==3 set "prefix="

echo\
echo As it will be displayed Example: !Prefix!Crash Bandicoot
echo Confirm^?
CHOICE /C YN
IF !ERRORLEVEL!==2 goto TransferPS1Games
 )
)

"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Estimating File Size:
echo ---------------------------------------------------
echo\
"%~dp0BAT\Diagbox" gd 0f

IF /I EXIST "!HDDPATH!\*.VCD" (
"%~dp0BAT\busybox" ls -1 "!HDDPATH!\*.VCD" | "%~dp0BAT\busybox" wc -l > "%~dp0TMP\POPSFiles.txt" & set /P @POPS_Files=<"%~dp0TMP\POPSFiles.txt"
"%~dp0BAT\busybox" du -csh "!HDDPATH!\*.VCD" | "%~dp0BAT\busybox" grep -e "total" | "%~dp0BAT\busybox" sed -e "s/total//g; s/K/KB/g; s/M/MB/g; s/G/GB/g" > "%~dp0TMP\POPSSize.txt" & set /P @POPS_Size=<"%~dp0TMP\POPSSize.txt"
	
echo         VCD - Files: !@POPS_Files! - Size: !@POPS_Size!
echo\
echo         TOTAL - Files: !@POPS_Files!
echo         TOTAL - Size: !@POPS_Size!

) else (echo          .VCD - NOT DETECTED IN POPS FOLDER & echo\ & echo\ & pause & goto mainmenu)


"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Detecting POPS Partition:
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0f
    
    "%~dp0BAT\busybox" grep -w "__.POPS\|__.POPS[0-9]" "%~dp0BAT\__Cache\PARTITION_PS2HDD.txt" | "%~dp0BAT\busybox" sort -k5 > "%~dp0TMP\hdd-prt.txt"
	"%~dp0BAT\busybox" sed -e "/^$/d" "%~dp0TMP\hdd-prt.txt" | "%~dp0BAT\busybox" wc -l > "%~dp0TMP\TotalPOPSPart.txt" & set /P @TotalPOPSPart=<"%~dp0TMP\TotalPOPSPart.txt"
	
	for /f "usebackq tokens=1,2,3,4,5" %%f in ("%~dp0TMP\hdd-prt.txt") do (
	set PartSize=%%i
	set POPSPART=%%j
	set TotalUsed=0
	set Remaining=
	 
	echo device !@pfsshell_path! > "%~dp0TMP\pfs-pops.txt"
	echo mount !POPSPART! >> "%~dp0TMP\pfs-pops.txt"
	echo ls -l >> "%~dp0TMP\pfs-pops.txt"
	echo umount >> "%~dp0TMP\pfs-pops.txt"
	type "%~dp0TMP\pfs-pops.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" grep -ie ".*\.VCD$" > "%~dp0TMP\PFS-POPS.log"
	 
	for /f "usebackq tokens=1,2,3,4*" %%f in ("%~dp0TMP\PFS-POPS.log") do (
	set /a "TotalUsed+=%%g / 1048576"
	setlocal DisableDelayedExpansion
	set filename=%%j
	setlocal EnableDelayedExpansion
	echo !filename!>>"%~dp0TMP\Games_Installed.txt"
		endlocal
	endlocal
	)
	
	set /a Remaining=!PartSize:~0,-2! - !TotalUsed!
	
	echo Name: [!POPSPART!] - Size: [!PartSize!] - Used: [!TotalUsed!MB] - Free: [!Remaining!MB]
	echo !POPSPART! !Remaining!>> "%~dp0TMP\POPSPART.txt"
	)

	if "!POPSPART!"=="" (
	"%~dp0BAT\Diagbox" gd 0c
	echo            No POPS partition detected
	echo            Partition Must Be Created
	echo\
	echo\
	"%~dp0BAT\Diagbox" gd 07
	rmdir /Q/S "%~dp0TMP" >nul 2>&1
	pause & (goto mainmenu)
	)

echo\
echo\
echo\
pause
cls

if exist "%~dp0POPS-Binaries\Hugopocked_POPStarter_Fixes.zip" "%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0POPS-Binaries\Hugopocked_POPStarter_Fixes.zip" -o"%~dp0TMP" id.txt -r -y

md "!HDDPATH!\Temp" >nul 2>&1
cd /d "!HDDPATH!" & rename "*.vcd" "*.VCD" & dir /b "*.VCD" >"%~dp0TMP\Gameslist.txt"
set /a gamecount=0
for /f "usebackq delims=" %%f in ("%~dp0TMP\Gameslist.txt") do (
set /a gamecount+=1
	
	setlocal DisableDelayedExpansion
	set filename=%%~nxf
    set fname=%%~nf
	set "gameid="
	set "region="
	set "HugoPatchFix="
	set "POPSPART="
	setlocal EnableDelayedExpansion
    
	echo\
    echo\
    echo !gamecount! - !filename!
	
	REM Get gameid
    "%~dp0BAT\UPSX_SID" "!filename!" -1 > "%~dp0TMP\gameid.txt" & set /p gameid=<"%~dp0TMP\gameid.txt"
	if not defined gameid echo "!filename!"| "%~dp0BAT\busybox" grep -o "[A-Z][A-Z][A-Z][A-Z]_[0-9][0-9][0-9]\.[0-9][0-9]" > "%~dp0TMP\gameid.txt" & set /p gameid=<"%~dp0TMP\gameid.txt"
	
	REM Rename file name to 45 characters for OPL only
	if !CreatePS1Shortcut!==Yes (
	if "!fname:~0,12!"=="!gameid!." (echo >nul) else (set fname=!gameid!.!fname!)
	set fname=!fname:~0,44!
	)
	
	REM Check if Already installed
	"%~dp0BAT\busybox" grep -F -x -m 1 "!fname!.VCD" "%~dp0TMP\Games_Installed.txt" >nul 2>&1
	if errorlevel 1 (
	
	REM GET FILE SIZE
	"%~dp0BAT\busybox" du -csh "!filename!" 2>&1 | "%~dp0BAT\busybox" grep -e "total" | "%~dp0BAT\busybox" sed -e "s/total//g; s/K/KB/g; s/M/MB/g; s/G/GB/g" > "%~dp0TMP\vcdsize.txt" & set /P vcdsize=<"%~dp0TMP\vcdsize.txt"
	for %%s in ("!filename!") do (set /a fsize=%%~zs / 1048576+10)

	REM Get partition space remaining
	for /f "usebackq tokens=1,2,3,4,5" %%f in ("%~dp0TMP\POPSPART.txt") do (
	set Remaining=%%g
	
	if not defined POPSPART if !Remaining! GTR !fsize! (
		set "POPSPART=%%f"
		set /a Remaining2=!Remaining!-!fsize!
		"%~dp0BAT\busybox" sed -i "s/!POPSPART! !Remaining!/!POPSPART! !Remaining2!/" "%~dp0TMP\POPSPART.txt"
		)
	)
	
	if "!POPSPART!"=="" (
    "%~dp0BAT\Diagbox" gd 06
    echo	WARNING: NOT enough space in POPS partitions^^! File ignored.
	echo !date! - !time! - "!filename!">> "%~dp0__Not_Installed_PS1.txt"
    "%~dp0BAT\Diagbox" gd 07
		) else (
		
	REM Game ID with PBPX other region than JAP
	findstr !gameid! "%~dp0BAT\Fix_Conflict_Gameid_Title.bat" >nul 2>&1
	if errorlevel 1 (echo >NUL) else (set "FixGameRegion=Yes" & call "%~dp0BAT\Fix_Conflict_Gameid_Title.bat")
	
	if not defined region (
	REM E = Europe                                 
	if "!gameid:~2,1!"=="E" set region=PAL
	REM K = Korean         
	if "!gameid:~2,1!"=="K" set region=NTSC-K
	REM P = Japan          
	if "!gameid:~2,1!"=="P" set region=NTSC-J
	REM UC = North America 
	if "!gameid:~2,1!"=="U" set region=NTSC-U/C
	REM Lightspan Educational ID
 	if "!gameid:~0,3!"=="LSP" set region=NTSC-U/C
	)
	REM Unknown region
	if not defined region set region=X

	if exist "%~dp0POPS-Binaries\Hugopocked_POPStarter_Fixes.zip" (
	REM echo         Checking if the game has a need patch GameShark...
	findstr !gameid! "%~dp0TMP\id.txt" >nul 2>&1
    if errorlevel 1 (
    REM echo            No need patch
    ) else (
	REM echo             Patch GameShark...
	set HugoPatchFix=Yes
	"%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0POPS-Binaries\Hugopocked_POPStarter_Fixes.zip" -o"%~dp0TMP" !gameid!\* -r -y >nul 2>&1
	if not exist "%~dp0TMP\!gameid!\*.BIN" (
	"%~dp0BAT\busybox" md5sum "!filename!" | "%~dp0BAT\busybox" grep -o "[0-9a-z]\{32\}" > "%~dp0TMP\MD5.txt" & set /p MD5=<"%~dp0TMP\MD5.txt"
	"%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0POPS-Binaries\Hugopocked_POPStarter_Fixes.zip" -o"%~dp0TMP" !gameid!\!MD5!\* -r -y & move "%~dp0TMP\!gameid!\!MD5!\*" "%~dp0TMP\!gameid!" >nul 2>&1
	  )
	  cd /d "%~dp0TMP\!gameid!" & for %%x in (TROJAN_?.BIN PATCH_?.BIN CHEATS.TXT Readme.txt) do move "%%x" "!HDDPATH!\Temp" >nul 2>&1
	 )
	)
	
	echo ---------------------------------------------------
	echo Title:     [!fname!]
	echo Gameid:    [!gameid!]
	echo Region:    [!region!]
	echo Size:      [!vcdsize!]
	echo Partition: [!POPSPART!]
	echo ---------------------------------------------------
	
	cd /d "!HDDPATH!\Temp" & move "!HDDPATH!\!filename!" "!HDDPATH!\Temp" >nul 2>&1
	
	if !CreatePS1Shortcut!==Yes ren "!filename!" "!fname!.VCD"
	
	REM echo         Creating Que
	echo device !@pfsshell_path! > "%~dp0TMP\pfs-pops.txt"
	echo mount !POPSPART! >> "%~dp0TMP\pfs-pops.txt"
	echo put "!fname!.VCD" >> "%~dp0TMP\pfs-pops.txt"
	echo ls -l >> "%~dp0TMP\pfs-pops.txt"
	echo umount >> "%~dp0TMP\pfs-pops.txt"

	if defined HugoPatchFix echo            Patch GameShark...
	echo mount __common >> "%~dp0TMP\pfs-pops.txt"
	echo mkdir POPS >> "%~dp0TMP\pfs-pops.txt"
	echo cd POPS >> "%~dp0TMP\pfs-pops.txt"
	echo mkdir "!fname!" >> "%~dp0TMP\pfs-pops.txt"
	echo cd "!fname!" >> "%~dp0TMP\pfs-pops.txt"
	if defined HugoPatchFix for %%x in (TROJAN_?.BIN PATCH_?.BIN CHEATS.TXT Readme.txt) do echo put "%%x" >> "%~dp0TMP\pfs-pops.txt"
	echo cd .. >> "%~dp0TMP\pfs-pops.txt"
	echo cd .. >> "%~dp0TMP\pfs-pops.txt"
	echo umount >> "%~dp0TMP\pfs-pops.txt"

	REM Create shortcut
	if !CreatePS1Shortcut!==Yes (
	copy "%~dp0POPS-Binaries\POPSTARTER.ELF" "!HDDPATH!\Temp\!fname!.ELF" >nul 2>&1
	echo "title=!prefix!!fname!"| "%~dp0BAT\busybox" sed -E "s/[A-Z][A-Z][A-Z][A-Z][_-][0-9][0-9][0-9]\.[0-9][0-9]\.//g; s/[A-Z][A-Z][A-Z][0-9][0-9][0-9][0-9][0-9]\.[0-9][0-9][0-9]\.//g" | "%~dp0BAT\busybox" iconv -f windows-1252 -t utf-8 > "!HDDPATH!\Temp\title.cfg"
    echo "boot=!fname!.ELF"| "%~dp0BAT\busybox" iconv -f windows-1252 -t utf-8 >> "!HDDPATH!\Temp\title.cfg"
	"%~dp0BAT\busybox" sed -i "s/\"//g" "!HDDPATH!\Temp\title.cfg"
	
	REM Added Game infos
	if exist "%~dp0BAT\PS1DB.xml" "%~dp0BAT\busybox" sed -n "/<game serial=\"!gameid:~0,4!-!gameid:~5,3!!gameid:~9,2!\">/{:a;N;/<\/game>/^!ba;s/.*<game serial=\"!gameid:~0,4!-!gameid:~5,3!!gameid:~9,2!\">\(.*\)<\/game>.*/\1/p}" "%~dp0BAT\PS1DB.xml" | "%~dp0BAT\busybox" sed -e "s/<\([^>]*\)>\([^<]*\)<\/\1>/\1=\2/g; s/<\([^>]*\) \/>/\1=/g; s/^[ \t]*//; s/[ \t]*$//; /^$/d" >> "!HDDPATH!\Temp\title.cfg"

	echo mount !OPLPART! >> "%~dp0TMP\pfs-pops.txt"
	if defined CUSTOM_OPLPART echo mkdir OPL >> "%~dp0TMP\pfs-pops.txt"
	if defined CUSTOM_OPLPART echo cd OPL >> "%~dp0TMP\pfs-pops.txt"
	echo mkdir APPS >> "%~dp0TMP\pfs-pops.txt"
	echo cd APPS >> "%~dp0TMP\pfs-pops.txt"
	echo mkdir "!fname!" >> "%~dp0TMP\pfs-pops.txt"
	echo cd "!fname!" >> "%~dp0TMP\pfs-pops.txt"
	echo put title.cfg >> "%~dp0TMP\pfs-pops.txt"
	echo put "!fname!.ELF" >> "%~dp0TMP\pfs-pops.txt"
	echo umount >> "%~dp0TMP\pfs-pops.txt"
	)
	
	echo exit >> "%~dp0TMP\pfs-pops.txt"
	echo            Installing...
	type "%~dp0TMP\pfs-pops.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" grep -ie ".*\.VCD$" > "%~dp0LOG\PFS-POPS%choice%.log"
	
	move "!HDDPATH!\Temp\*.VCD" "!HDDPATH!\!filename!" >nul 2>&1 & rmdir /Q/S "!HDDPATH!\Temp" >nul 2>&1
	echo            Completed...
    echo ---------------------------------------------------
				)
			) else (echo            A game with this name is already installed)
    endlocal
endlocal
)

cd "%~dp0" & rmdir /Q/S "%~dp0TMP" >nul 2>&1 & rmdir /Q/S "!HDDPATH!\Temp" >nul 2>&1

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo\
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo Completed...
echo\
echo\
"%~dp0BAT\Diagbox" gd 07

pause & (goto mainmenu)
REM ##########################################################################################################################################################
:TransferBackupPOPSVMC
cls
md "%~dp0TMP" >nul 2>&1

IF NOT DEFINED @hdl_path ( rmdir /Q/S "%~dp0TMP" >nul 2>&1 & goto ScanningPS2HDD ) else (
"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning for Playstation 2 HDDs:
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "!@hdl_path!" | "%~dp0BAT\busybox" grep "Playstation 2 HDD" >nul
if errorlevel 1 set "@hdl_path=" & goto ScanningPS2HDD
echo       [!@hdl_path! !@TotalHDD_Size! - !@ModelePS2HDD!]
)

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo POPS Virtual Memory Cards: [VMC]
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1^) Yes ^(Transfer^)
"%~dp0BAT\Diagbox" gd 0c
echo         2^) No
"%~dp0BAT\Diagbox" gd 0e
echo         3^) Yes ^(Extract^)
"%~dp0BAT\Diagbox" gd 07
echo\
CHOICE /C 123 /M "Select Option:"

IF %ERRORLEVEL%==1 set @pfs_popvmc=yes
IF %ERRORLEVEL%==2 (goto POPSManagement)
IF %ERRORLEVEL%==3 set @pfs_popvmc=extract

cls
setlocal DisableDelayedExpansion

IF %@pfs_popvmc%==yes (
echo\
echo\
echo Installing POPS VMC:
echo ---------------------------------------------------
echo\

IF /I EXIST "%~dp0POPS\VMC\*" (

	cd "%~dp0POPS\VMC"
	echo         Creating Que
	echo device %@pfsshell_path% > "%~dp0TMP\pfs-popsmvc.txt"
	echo mount __common >> "%~dp0TMP\pfs-popsmvc.txt"

	REM PARENT DIR (__common\POPS)
	echo mkdir POPS >> "%~dp0TMP\pfs-popsmvc.txt"
	echo cd POPS >> "%~dp0TMP\pfs-popsmvc.txt"

	REM POPS DIR (__common\POPS\SCES_XXX.XX)
	for /D %%x in (*) do (
	echo mkdir "%%x" >> "%~dp0TMP\pfs-popsmvc.txt"
	echo lcd "%%x" >> "%~dp0TMP\pfs-popsmvc.txt"
 	echo cd "%%x" >> "%~dp0TMP\pfs-popsmvc.txt"
 	cd "%%x"

	REM THEME FILES (__common\POPS\SCES_XXX.XX\Files.xxx)
 	for %%1 in (*) do (echo put "%%1") >> "%~dp0TMP\pfs-popsmvc.txt"
	
	REM POPS DIR (__common\POPS\SCES_XXX.XX\Folder\)
	for /D %%w in (*) do (
	echo mkdir "%%w" >> "%~dp0TMP\pfs-popsmvc.txt"
	echo lcd "%%w" >> "%~dp0TMP\pfs-popsmvc.txt"
 	echo cd "%%w" >> "%~dp0TMP\pfs-popsmvc.txt"
 	cd "%%w"

	REM THEME FILES (__common\POPS\SCES_XXX.XX\Folder\Files.xxx)
 	for %%2 in (*) do (echo put "%%2") >> "%~dp0TMP\pfs-popsmvc.txt"
	
	echo lcd .. >> "%~dp0TMP\pfs-popsmvc.txt"
	echo cd .. >> "%~dp0TMP\pfs-popsmvc.txt"
 	cd ..

    )
	
	echo lcd .. >> "%~dp0TMP\pfs-popsmvc.txt"
	echo cd .. >> "%~dp0TMP\pfs-popsmvc.txt"
 	cd ..

    )
    echo ls -l >> "%~dp0TMP\pfs-popsmvc.txt"
	echo umount >> "%~dp0TMP\pfs-popsmvc.txt"
	echo exit >> "%~dp0TMP\pfs-popsmvc.txt"

	echo         Installing Que
	type "%~dp0TMP\pfs-popsmvc.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" grep -i -e "drwx" | "%~dp0BAT\busybox" sed -e "1,2d" > "%~dp0LOG\PFS-POPS-VMC.log"
	) else ( echo         POPS-VMC - Source Not Detected... )
)

IF %@pfs_popvmc%==extract (
echo\
echo\
echo Extraction POPS Virtual Memory Card Files:
echo ---------------------------------------------------
echo\

    IF NOT EXIST "%~dp0POPS\VMC" MD "%~dp0POPS\VMC"
	cd /d "%~dp0TMP"
	echo         Files scan...
	echo device %@pfsshell_path% > "%~dp0TMP\pfs-popsvmc.txt"
	echo mount __common >> "%~dp0TMP\pfs-popsvmc.txt"
	echo cd POPS >> "%~dp0TMP\pfs-popsvmc.txt"
	echo ls -l >> "%~dp0TMP\pfs-popsvmc.txt"
	echo umount >> "%~dp0TMP\pfs-popsvmc.txt"
	echo exit >> "%~dp0TMP\pfs-popsvmc.txt"
	type "%~dp0TMP\pfs-popsvmc.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" grep -i -e "drwx" | "%~dp0BAT\busybox" sed -e "1,2d" | "%~dp0BAT\busybox" cut -c42-500 | "%~dp0BAT\busybox" sed -e "s/\///g" > "%~dp0TMP\pfs-tmp.log"
	
    echo         Extraction...
	for /f "tokens=*" %%f in (pfs-tmp.log) do (
	if not exist "%~dp0POPS\VMC\%%f" mkdir "%~dp0POPS\VMC\%%f"
    echo device %@pfsshell_path% > "%~dp0TMP\pfs-popsvmc.txt"
    echo mount __common >> "%~dp0TMP\pfs-popsvmc.txt"
    echo cd POPS >> "%~dp0TMP\pfs-popsvmc.txt"
	echo cd "%%f" >> "%~dp0TMP\pfs-popsvmc.txt"
	echo ls -l >> "%~dp0TMP\pfs-popsvmc.txt"
	echo cd .. >> "%~dp0TMP\pfs-popsvmc.txt"
	echo umount >> "%~dp0TMP\pfs-popsvmc.txt"
    echo exit >> "%~dp0TMP\pfs-popsvmc.txt"
	type "%~dp0TMP\pfs-popsvmc.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" grep -ie "-rw-" | "%~dp0BAT\busybox" cut -c42-500 > "%~dp0TMP\pfs-popsvmcfiles.txt"

	for /f "tokens=*" %%v in (pfs-popsvmcfiles.txt) do (
    echo device %@pfsshell_path% > "%~dp0TMP\pfs-popsvmc.txt"
    echo mount __common >> "%~dp0TMP\pfs-popsvmc.txt"
    echo cd POPS >> "%~dp0TMP\pfs-popsvmc.txt"
	echo cd "%%f" >> "%~dp0TMP\pfs-popsvmc.txt"
	echo lcd "%~dp0POPS\VMC\%%f" >> "%~dp0TMP\pfs-popsvmc.txt"
	echo get "%%v" >> "%~dp0TMP\pfs-popsvmc.txt"
	echo umount >> "%~dp0TMP\pfs-popsvmc.txt"
    echo exit >> "%~dp0TMP\pfs-popsvmc.txt"
	type "%~dp0TMP\pfs-popsvmc.txt" | "%~dp0BAT\pfsshell" >nul 2>&1
	)
  )
)
	echo         Completed...
	
cd "%~dp0" & rmdir /Q/S "%~dp0TMP" >nul 2>&1

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo\
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo Completed...
echo\
echo\
"%~dp0BAT\Diagbox" gd 07

endlocal
pause & (goto POPSManagement)
REM ##########################################################################################################################################################
:BackupARTCFGCHTVMC
cls
rmdir /Q/S "%~dp0TMP" >nul 2>&1
md "%~dp0TMP" >nul 2>&1
cd "%~dp0"

IF NOT DEFINED @hdl_path ( rmdir /Q/S "%~dp0TMP" >nul 2>&1 & goto ScanningPS2HDD ) else (
"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning for Playstation 2 HDDs:
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "!@hdl_path!" | "%~dp0BAT\busybox" grep "Playstation 2 HDD" >nul
if errorlevel 1 set "@hdl_path=" & goto ScanningPS2HDD
echo       [!@hdl_path! !@TotalHDD_Size! - !@ModelePS2HDD!]
)

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Extract Artwork: [ART]
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1^) Yes
"%~dp0BAT\Diagbox" gd 0c
echo         2^) No
"%~dp0BAT\Diagbox" gd 07
echo\
CHOICE /C 12 /M "Select Option:"

IF %ERRORLEVEL%==1 set "@pfs_art=yes" & echo ART>"%~dp0TMP\pfs-choice.log"
IF %ERRORLEVEL%==2 set "@pfs_art=no"

echo\
echo\
echo Extract Configs: [CFG]
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1^) Yes
"%~dp0BAT\Diagbox" gd 0c
echo         2^) No
"%~dp0BAT\Diagbox" gd 07
echo\
CHOICE /C 12 /M "Select Option:"

IF %ERRORLEVEL%==1 set "@pfs_cfg=yes" & echo CFG>>"%~dp0TMP\pfs-choice.log"
IF %ERRORLEVEL%==2 set @pfs_cfg=no

echo\
echo\
echo Extract Cheats: [CFG]
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1^) Yes
"%~dp0BAT\Diagbox" gd 0c
echo         2^) No
"%~dp0BAT\Diagbox" gd 07
echo\
CHOICE /C 12 /M "Select Option:"

IF %ERRORLEVEL%==1 set "@pfs_cht=yes" & echo CHT>>"%~dp0TMP\pfs-choice.log"
IF %ERRORLEVEL%==2 set @pfs_cht=no

echo\
echo\
echo Extract Virtual Memory Cards: [VMC]
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1^) Yes
"%~dp0BAT\Diagbox" gd 0c
echo         2^) No
"%~dp0BAT\Diagbox" gd 07
echo\
CHOICE /C 12 /M "Select Option:"

IF %ERRORLEVEL%==1 set "pfs_vmc=yes" & echo VMC>>"%~dp0TMP\pfs-choice.log"
IF %ERRORLEVEL%==2 set @pfs_vmc=no

"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Detecting OPL Resources Partition:
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0f

	"%~dp0BAT\busybox" grep -ow "%OPLPART%" "%~dp0BAT\__Cache\PARTITION_PS2HDD.txt" > "%~dp0TMP\hdd-prt.txt" & set /P @hdd_avl=<"%~dp0TMP\hdd-prt.txt"
	
	IF "!@hdd_avl!"=="%OPLPART%" (
	"%~dp0BAT\Diagbox" gd 0a
		echo         %OPLPART% - Partition Detected
		"%~dp0BAT\Diagbox" gd 07
		) else (
		"%~dp0BAT\Diagbox" gd 0c
		echo         %OPLPART% - Partition NOT Detected
		echo             Partition Must Be Created
		echo\
		echo\
		"%~dp0BAT\Diagbox" gd 07
		rmdir /Q/S "%~dp0TMP" >nul 2>&1
		pause & (goto OPLManagement)
		)

echo\
echo\
pause
cls
cd /d "%~dp0TMP"

if not exist "%~dp0TMP\pfs-choice.log" type nul>"%~dp0TMP\pfs-choice.log"
for /f "usebackq tokens=*" %%f in ("%~dp0TMP\pfs-choice.log") do (

	setlocal DisableDelayedExpansion
	set EType=%%f
	setlocal EnableDelayedExpansion

echo\
echo\
echo Extraction !EType!:
echo ---------------------------------------------------
echo\

    IF NOT EXIST "%~dp0!EType!" MD "%~dp0!EType!"
    echo         Files scan...
	echo device %@pfsshell_path% > "%~dp0TMP\pfs-log.txt"
	echo mount %OPLPART% >> "%~dp0TMP\pfs-log.txt"
	if defined CUSTOM_OPLPART echo cd OPL >> "%~dp0TMP\pfs-log.txt"
	echo cd !EType! >> "%~dp0TMP\pfs-log.txt"
	echo ls >> "%~dp0TMP\pfs-log.txt"
    echo umount >> "%~dp0TMP\pfs-log.txt"
	echo exit >> "%~dp0TMP\pfs-log.txt"
	type "%~dp0TMP\pfs-log.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" grep -ie ".*\.png$" -ie ".*\.jpg$" -ie ".*\.cfg$" -ie ".*\.cht$" -ie ".*\.bin$" | "%~dp0BAT\busybox" sed "s/.*/\""&\""/" > "%~dp0TMP\pfs-tmp.log"

	echo         Extraction...
	echo device %@pfsshell_path% > "%~dp0TMP\pfs-!EType!.txt"
	echo mount %OPLPART% >> "%~dp0TMP\pfs-!EType!.txt"
	if defined CUSTOM_OPLPART echo cd OPL >> "%~dp0TMP\pfs-!EType!.txt"
	echo cd !EType! >> "%~dp0TMP\pfs-!EType!.txt"
	echo lcd "%~dp0!EType!" >> "%~dp0TMP\pfs-!EType!.txt"
	"%~dp0BAT\busybox" sed "s/^/get /" "%~dp0TMP\pfs-tmp.log" >> "%~dp0TMP\pfs-!EType!.txt"
	echo umount >> "%~dp0TMP\pfs-!EType!.txt"
	echo exit >> "%~dp0TMP\pfs-!EType!.txt"
	
	type "%~dp0TMP\pfs-!EType!.txt" | "%~dp0BAT\pfsshell" >nul 2>&1
	echo         Completed...
	 endlocal
	endlocal
	)

cd /d "%~dp0" & rmdir /Q/S "%~dp0TMP" >nul 2>&1

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo Extraction Completed...
echo\
echo\
"%~dp0BAT\Diagbox" gd 07

pause & (goto OPLManagement)
REM ########################################################################################################################################################################
:BackupPS1Games
cls
mkdir "%~dp0TMP" >nul 2>&1
cd /d "%~dp0TMP"

IF NOT DEFINED @hdl_path ( rmdir /Q/S "%~dp0TMP" >nul 2>&1 & goto ScanningPS2HDD ) else (
"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning for Playstation 2 HDDs:
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "!@hdl_path!" | "%~dp0BAT\busybox" grep "Playstation 2 HDD" >nul
if errorlevel 1 set "@hdl_path=" & goto ScanningPS2HDD
echo       [!@hdl_path! !@TotalHDD_Size! - !@ModelePS2HDD!]
)

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Extract a PS1 game to VCD^?
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1^) Yes
"%~dp0BAT\Diagbox" gd 0c
echo         2^) No
"%~dp0BAT\Diagbox" gd 0e
echo         3^) Yes ^(Extract All Games from POPS Partition^)
echo         4^) Yes ^(Extract All Games from PFS Partition^)
echo\
"%~dp0BAT\Diagbox" gd 07
CHOICE /C 1234 /M "Select Option:"

IF %ERRORLEVEL%==1 set "@pfs_pop=Manually"
IF %ERRORLEVEL%==2 (goto GamesManagement)
IF %ERRORLEVEL%==3 set "@pfs_pop=yes"
IF %ERRORLEVEL%==4 (goto BackupPS1GamesPFSPart)

"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Detecting POPS Partition:
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0f
	
	"%~dp0BAT\busybox" grep -w "__.POPS\|__.POPS[0-9]" "%~dp0BAT\__Cache\PARTITION_PS2HDD.txt" | "%~dp0BAT\busybox" sort -k5 > "%~dp0TMP\hdd-prt.txt"
	"%~dp0BAT\busybox" sed -e "/^$/d" "%~dp0TMP\hdd-prt.txt" | "%~dp0BAT\busybox" wc -l > "%~dp0TMP\TotalPOPSPart.txt" & set /P @TotalPOPSPart=<"%~dp0TMP\TotalPOPSPart.txt"
	
	for /f "usebackq tokens=1,2,3,4,5" %%f in ("%~dp0TMP\hdd-prt.txt") do (
	set PartSize=%%i
	set POPSPART=%%j
	set TotalUsed=0
	set Remaining=
	 
	echo device !@pfsshell_path! > "%~dp0TMP\pfs-pops.txt"
	echo mount !POPSPART! >> "%~dp0TMP\pfs-pops.txt"
	echo ls -l >> "%~dp0TMP\pfs-pops.txt"
	echo umount >> "%~dp0TMP\pfs-pops.txt"
	type "%~dp0TMP\pfs-pops.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" grep -ie ".*\.VCD$" > "%~dp0TMP\PFS-POPS.log"
	
	for /f "usebackq tokens=1,2,3,4*" %%f in ("%~dp0TMP\PFS-POPS.log") do (
	set /a "TotalUsed+=%%g / 1048576"
	setlocal DisableDelayedExpansion
	set filename=%%j
	set fname=%%~nj
	set game_size=%%g
	setlocal EnableDelayedExpansion
	if "!POPSPART!"=="__.POPS" set "POPSPART=__.POPS "
	echo !POPSPART! - !game_size! - !fname!>>"%~dp0TMP\Games_Installed_tmp.txt"
		endlocal
	endlocal
	)
	
	set /a Remaining=!PartSize:~0,-2! - !TotalUsed!
	echo Name: [!POPSPART!] - Size: [!PartSize!] - Used: [!TotalUsed!MB] - Free: [!Remaining!MB]
	)

	if "!POPSPART!"=="" (
	"%~dp0BAT\Diagbox" gd 0c
	echo            No POPS partition detected
	echo            Partition Must Be Created
	echo\
	echo\
	"%~dp0BAT\Diagbox" gd 07
	rmdir /Q/S "%~dp0TMP" >nul 2>&1
	pause & (goto mainmenu)
	)

echo\
echo\
pause
cls

"%~dp0BAT\Diagbox" gd 07
echo\
echo\
echo Scanning Games List
echo ---------------------------------------------------
echo [Parts]:   [Size]:     [Name]:
"%~dp0BAT\Diagbox" gd 0e
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 07
"%~dp0BAT\busybox" sed -n "/[A-Z][A-Z][A-Z][A-Z]_[0-9][0-9][0-9]\.[0-9][0-9]/p" "%~dp0TMP\Games_Installed_tmp.txt" | "%~dp0BAT\busybox" sort -k5.14 > "%~dp0TMP\Games_Installed.txt"
"%~dp0BAT\busybox" sed -n "/[A-Z][A-Z][A-Z][A-Z]_[0-9][0-9][0-9]\.[0-9][0-9]/^!p" "%~dp0TMP\Games_Installed_tmp.txt" | "%~dp0BAT\busybox" sort -k5 >> "%~dp0TMP\Games_Installed.txt"
type "%~dp0TMP\Games_Installed.txt"
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 07

if !@pfs_pop!==Manually (
echo\
"%~dp0BAT\Diagbox" gd 06
echo Respect upper and lower case
"%~dp0BAT\Diagbox" gd 07
set /p NameVCD=Enter The Game Name:
IF "!NameVCD!"=="" set "@pfs_popmanuallyVCD=" & (goto BackupPS1Games)
"%~dp0BAT\busybox" grep "!NameVCD!" "%~dp0TMP\Games_Installed_tmp.txt" > "%~dp0TMP\Games_Installed.txt"
cls
)

for /f "usebackq tokens=1,2,3,4*" %%f in ("%~dp0TMP\Games_Installed.txt") do (

	setlocal DisableDelayedExpansion
	set POPSPART=%%f
	set filename=%%j
	setlocal EnableDelayedExpansion
	
echo\
echo\
echo Extraction !filename!
echo ---------------------------------------------------
echo\
    
	echo         Extraction...
	echo device !@pfsshell_path! > "%~dp0TMP\pfs-pops.txt"
	echo mount !POPSPART! >> "%~dp0TMP\pfs-pops.txt"
	echo lcd "%~dp0POPS" >> "%~dp0TMP\pfs-pops.txt"
	echo rename "!filename!.vcd" "!filename!.VCD" >> "%~dp0TMP\pfs-pops.txt"
	echo get "!filename!.VCD" >> "%~dp0TMP\pfs-pops.txt"
	echo umount >> "%~dp0TMP\pfs-pops.txt"
	echo exit >> "%~dp0TMP\pfs-pops.txt"
	type "%~dp0TMP\pfs-pops.txt" | "%~dp0BAT\pfsshell" >nul 2>&1
    echo         Completed...

 endlocal
endlocal
)

cd /d "%~dp0" & rmdir /Q/S "%~dp0TMP" >nul 2>&1

echo\
echo\
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo Completed...
echo\
echo\
"%~dp0BAT\Diagbox" gd 07

pause & (goto GamesManagement)
REM ########################################################################################################################################################################
:BackupPS1GamesPFSPart
cls
mkdir "%~dp0TMP" >nul 2>&1
cd /d "%~dp0TMP"

IF NOT DEFINED @hdl_path ( rmdir /Q/S "%~dp0TMP" >nul 2>&1 & goto ScanningPS2HDD ) else (
"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning for Playstation 2 HDDs:
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "!@hdl_path!" | "%~dp0BAT\busybox" grep "Playstation 2 HDD" >nul
if errorlevel 1 set "@hdl_path=" & goto ScanningPS2HDD
echo       [!@hdl_path! !@TotalHDD_Size! - !@ModelePS2HDD!]
)

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Scanning Partitions PS1 Games:
echo ---------------------------------------------------
	"%~dp0BAT\busybox" grep -e "\.POPS\." "%~dp0BAT\__Cache\PARTITION_PS2HDD.txt" | "%~dp0BAT\busybox" sed "s/.\{48\}/& /" | "%~dp0BAT\busybox" sort -k6 | "%~dp0BAT\busybox" sed -e "s/\(.\{48\}\)./\1/" | "%~dp0BAT\busybox" cut -c30-100 > "%~dp0TMP\PARTITION_PS1_GAMES.txt"
	type "%~dp0TMP\PARTITION_PS1_GAMES.txt"
echo ---------------------------------------------------

for /f "tokens=*" %%p in (PARTITION_PS1_GAMES.txt) do (
echo\
echo\
echo Extraction of VCD from %%p
echo ---------------------------------------------------
echo\

    echo         Extraction...
	echo device %@pfsshell_path% > "%~dp0TMP\pfs-log.txt"
	echo mount %%p >> "%~dp0TMP\pfs-log.txt"
	echo get "IMAGE0.VCD" >> "%~dp0TMP\pfs-log.txt"
	echo get "IMAGE1.VCD" >> "%~dp0TMP\pfs-log.txt"
	echo get "IMAGE2.VCD" >> "%~dp0TMP\pfs-log.txt"
	echo get "IMAGE3.VCD" >> "%~dp0TMP\pfs-log.txt"
	echo umount >> "%~dp0TMP\pfs-log.txt"
	echo exit >> "%~dp0TMP\pfs-log.txt"
	type "%~dp0TMP\pfs-log.txt" | "%~dp0BAT\pfsshell" >nul 2>&1
    
	For %%V in (*.VCD) do (
	set filename=%%V
	set "gameid="
	
	REM Get gameid
	"%~dp0BAT\UPSX_SID" "!filename!" -1 > "%~dp0TMP\gameid.txt" & set /p gameid=<"%~dp0TMP\gameid.txt"

	findstr !gameid! "%~dp0BAT\TitlesDB\TitlesDB_PS1_English.txt" >nul
    if errorlevel 1 (move "!filename!" "%~dp0POPS\!gameid!.VCD" >nul 2>&1) else (
	set "dbtitle="
	for /f "tokens=1*" %%A in ( 'findstr !gameid! "%~dp0BAT\TitlesDB\TitlesDB_PS1_English.txt"' ) do (
	if not defined dbtitle set dbtitle=%%B
	move "%%V" "%~dp0POPS\!gameid!.!dbtitle!.VCD" >nul 2>&1
	echo         Completed...
   )
  )
 )
)

cd "%~dp0" & rmdir /Q/S "%~dp0TMP" >nul 2>&1

echo\
echo\
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo Extraction Completed...
echo\
echo\
"%~dp0BAT\Diagbox" gd 07

echo\
echo\
pause & (goto mainmenu)
REM ########################################################################################################################################################################
:TransferPOPSBinaries
cls
mkdir "%~dp0TMP" >nul 2>&1
cd "%~dp0"

IF NOT DEFINED @hdl_path ( rmdir /Q/S "%~dp0TMP" >nul 2>&1 & goto ScanningPS2HDD ) else (
"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning for Playstation 2 HDDs:
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "!@hdl_path!" | "%~dp0BAT\busybox" grep "Playstation 2 HDD" >nul
if errorlevel 1 set "@hdl_path=" & goto ScanningPS2HDD
echo       [!@hdl_path! !@TotalHDD_Size! - !@ModelePS2HDD!]
)

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Transfer POPS Binaries:
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1^) Yes
"%~dp0BAT\Diagbox" gd 0c
echo         2^) No
"%~dp0BAT\Diagbox" gd 07
echo\
CHOICE /C 12 /M "Select Option:"

IF !ERRORLEVEL!==1 set @pfs_pops=yes
IF !ERRORLEVEL!==2 (goto POPSManagement)

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo\
echo POPS Binaries MD5 CHECKING:
echo ---------------------------------------------------

ren "%~dp0POPS-Binaries\POPS.ELF.ELF" POPS.ELF >nul 2>&1
ren "%~dp0POPS-Binaries\IOPRP252.IMG.IMG" IOPRP252.IMG >nul 2>&1

IF EXIST "%~dp0POPS-Binaries\POPS.ELF" (

    "%~dp0BAT\busybox" md5sum "%~dp0POPS-Binaries\POPS.ELF" | "%~dp0BAT\busybox" grep -o "[0-9a-z]\{32\}" > "%~dp0TMP\MD5.txt" & set /p MD5=<"%~dp0TMP\MD5.txt"
    if !MD5! equ 355a892a8ce4e4a105469d4ef6f39a42 (
      "%~dp0BAT\Diagbox" gd 0a
       echo POPS.ELF     - MD5 Match : !md5!
       ) else ( "%~dp0BAT\Diagbox" gd 0c & echo POPS.ELF     MD5 NOT MATCH : !md5! & set POPSNotFound=yes)
       "%~dp0BAT\Diagbox" gd 0c
    ) else ("%~dp0BAT\Diagbox" gd 06 & echo POPS.ELF : Not detected & set POPSNotFound=yes)
    
IF EXIST "%~dp0POPS-Binaries\IOPRP252.IMG" (

    "%~dp0BAT\busybox" md5sum "%~dp0POPS-Binaries\IOPRP252.IMG" | "%~dp0BAT\busybox" grep -o "[0-9a-z]\{32\}" > "%~dp0TMP\MD5.txt" & set /p MD5=<"%~dp0TMP\MD5.txt"
    if !MD5! equ 1db9c6020a2cd445a7bb176a1a3dd418 (
      "%~dp0BAT\Diagbox" gd 0a
       echo IOPRP252.IMG - MD5 Match : !md5!
       "%~dp0BAT\Diagbox" gd 0f
       ) else ( "%~dp0BAT\Diagbox" gd 0c & echo IOPRP252.IMG MD5 NOT MATCH : !md5! & set POPSNotFound=yes)
       "%~dp0BAT\Diagbox" gd 0c
    ) else ("%~dp0BAT\Diagbox" gd 06 & echo IOPRP252.IMG : Not detected & set POPSNotFound=yes) 

    if defined POPSNotFound (
    "%~dp0BAT\Diagbox" gd 06
    echo\
    echo BINARIES POPS NOT DETECTED IN POPS-Binaries FOLDER
    echo YOU NEED TO FIND THESE FILES FOR POPSTARTER WORKS!
    echo\
    "%~dp0BAT\Diagbox" gd 0f
    echo POPS.ELF     - MD5 : 355a892a8ce4e4a105469d4ef6f39a42
    echo IOPRP252.IMG - MD5 : 1db9c6020a2cd445a7bb176a1a3dd418
    echo\
    echo\
    rmdir /Q/S "%~dp0TMP" >nul 2>&1
    pause & (goto POPSManagement)
    )

"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Detecting __common Partition:
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0f

    "%~dp0BAT\busybox" grep -ow "__common" "%~dp0BAT\__Cache\PARTITION_PS2HDD.txt" > "%~dp0TMP\hdd-prt.txt" & set /P @hdd_avl=<"%~dp0TMP\hdd-prt.txt"
	
    IF "!@hdd_avl!"=="__common" (
    "%~dp0BAT\Diagbox" gd 0a
	echo         __common - Partition Detected
	"%~dp0BAT\Diagbox" gd 07
	) else (
	"%~dp0BAT\Diagbox" gd 0c
	echo         __common - Partition NOT Detected
	echo             Partition Must Be Created
	echo\
	echo\
	"%~dp0BAT\Diagbox" gd 07
	rmdir /Q/S "%~dp0TMP" >nul 2>&1
	pause & (goto POPSManagement)
	)

echo\
echo\
pause

IF !@pfs_pops!==yes (
"%~dp0BAT\Diagbox" gd 0f
cls
echo\
echo\
echo Installing POPS Binaries:
echo ---------------------------------------------------
echo\
"%~dp0BAT\Diagbox" gd 07

IF /I EXIST "%~dp0POPS-Binaries\*" (

	cd "%~dp0POPS-Binaries"
	echo         Creating Que
	echo device !@pfsshell_path! > "%~dp0TMP\pfs-pops-binaries.txt"
	echo mount __common >> "%~dp0TMP\pfs-pops-binaries.txt"
	echo mkdir POPS >> "%~dp0TMP\pfs-pops-binaries.txt"
	echo cd POPS >> "%~dp0TMP\pfs-pops-binaries.txt"
	for %%f in (POPS.ELF IOPRP252.IMG POPSTARTER.ELF wLaunchELF_kHn_20200810.ELF TROJAN_7.BIN BIOS.BIN OSD.BIN CHEATS.TXT *.TM2) do (echo put "%%f") >> "%~dp0TMP\pfs-pops-binaries.txt"
	echo ls -l >> "%~dp0TMP\pfs-pops-binaries.txt"
	echo umount >> "%~dp0TMP\pfs-pops-binaries.txt"
	echo exit >> "%~dp0TMP\pfs-pops-binaries.txt"
	
	echo         Installing Que
	type "%~dp0TMP\pfs-pops-binaries.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" grep -ie "-rw-" | "%~dp0BAT\busybox" grep -ie ".ELF" -ie ".IMG" -ie ".BIN" -ie ".TM2" -ie ".TXT" > "%~dp0LOG\PFS-POPS-Binaries.log"
	echo         POPS Binaries Completed...

 	) else ( echo         POPS Binaries - Source Not Detected... )
)

cd /d "%~dp0" & rmdir /Q/S "%~dp0TMP" >nul 2>&1

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo ---------------------------------------------------
 "%~dp0BAT\Diagbox" gd 0a
echo Installation Completed...
echo\
echo\
"%~dp0BAT\Diagbox" gd 07

pause & (goto POPSManagement)
REM #########################################################################################################################################################
:ExtractGameChoice
cls
mkdir "%~dp0TMP" >nul 2>&1

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Extract a game:
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1^) Yes ^(PS2 Games^)
"%~dp0BAT\Diagbox" gd 0c
echo         2^) No
"%~dp0BAT\Diagbox" gd 0e
echo         3^) Yes ^(PS1 Games^)
echo\
"%~dp0BAT\Diagbox" gd 07
CHOICE /C 123 /M "Select Option:"

IF %ERRORLEVEL%==1 (goto BackupPS2Games)
IF %ERRORLEVEL%==2 (goto GamesManagement)
IF %ERRORLEVEL%==3 (goto BackupPS1Games)
REM ###################################################

:BackupPS2Games
cls
mkdir "%~dp0CD-DVD" >nul 2>&1
mkdir "%~dp0TMP" >nul 2>&1
cd /d "%~dp0TMP"

IF NOT DEFINED @hdl_path ( rmdir /Q/S "%~dp0TMP" >nul 2>&1 & goto ScanningPS2HDD ) else (
"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning for Playstation 2 HDDs:
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "!@hdl_path!" | "%~dp0BAT\busybox" grep "Playstation 2 HDD" >nul
if errorlevel 1 set "@hdl_path=" & goto ScanningPS2HDD
echo       [!@hdl_path! !@TotalHDD_Size! - !@ModelePS2HDD!]
)

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Extract a PS2 game to iso^?
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1^) Yes
"%~dp0BAT\Diagbox" gd 0c
echo         2^) No
"%~dp0BAT\Diagbox" gd 0e
echo         3^) Yes ^(Extract all games^)
echo\
"%~dp0BAT\Diagbox" gd 07
CHOICE /C 123 /M "Select Option:"

IF %ERRORLEVEL%==1 set BackupPS2GamesManually=yes
IF %ERRORLEVEL%==2 (goto GamesManagement)
IF %ERRORLEVEL%==3 set BackupPS2AllGames=yes

echo\
"%~dp0BAT\Diagbox" gd 0e
echo Do you want to change the default output directory^?
"%~dp0BAT\Diagbox" gd 07
CHOICE /C YN
echo\
if !errorlevel!==1 (
echo Example: E:\
set /p "HDDPATHOUTPUT=Enter the path:"
)
if not defined HDDPATHOUTPUT set HDDPATHOUTPUT=%~dp0CD-DVD

"%~dp0BAT\Diagbox" gd 0e
cls
echo\
echo\
echo Scanning Games List:
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
type "%~dp0BAT\__Cache\PARTITION_HDL_GAME.txt" | "%~dp0BAT\busybox" sed "s/|.*//" | "%~dp0BAT\busybox" sort -k2 > "%~dp0TMP\GameListPS2.txt" & type "%~dp0TMP\GameListPS2.txt"
"%~dp0BAT\Diagbox" gd 0e
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0f

if !BackupPS2GamesManually!==yes (
    echo\
	"%~dp0BAT\Diagbox" gd 0e
	echo Please type the gameid ^+ GameName as shown in the Games List.
	"%~dp0BAT\Diagbox" gd 07
	set "gname="
    set /p gname=
    if "!gname!"=="" (goto BackupPS2Games)
	if "!gname!"=="!gname:~0,11!" set "gname=!gname:~0,11! "

	"%~dp0BAT\busybox" grep -Fx "!gname!" "%~dp0TMP\GameListPS2.txt" >nul
	if errorlevel 1 (
    "%~dp0BAT\Diagbox" gd 0c
	echo         NOT Detected
	echo\
	echo\
	"%~dp0BAT\Diagbox" gd 07
	rmdir /Q/S "%~dp0TMP" >nul 2>&1
	pause & (goto BackupPS2Games)
	) else ("%~dp0BAT\busybox" grep -F -w -m 1 "!gname!" "%~dp0BAT\__Cache\PARTITION_HDL_GAME.txt" > "%~dp0TMP\PARTITION_HDL_GAME.txt")
    ) else (type "%~dp0BAT\__Cache\PARTITION_HDL_GAME.txt" > "%~dp0TMP\PARTITION_HDL_GAME.txt")

    for /f "usebackq tokens=1* delims=|" %%f in ("%~dp0TMP\PARTITION_HDL_GAME.txt") do (

   	setlocal DisableDelayedExpansion
	set fname=%%f
	set pname=%%g
	setlocal EnableDelayedExpansion
    
	echo "!fname:~12!"| "%~dp0BAT\busybox" sed -e "s/:/-/g; s/?//g; s/\\//g; s/\///g; s/\*//g; s/>//g; s/<//g; s/|//g; s/""//g" > "%~dp0TMP\GameName.txt" & set /P GameName=<"%~dp0TMP\GameName.txt"
	echo\
	echo\
	if defined GameName (echo !fname:~12!) else (echo Unknown Title& set "GameName=__Unknown Title")

    "%~dp0BAT\hdl_dump.exe" extract !@hdl_path! "!pname!" "!HDDPATHOUTPUT!\!GameName! - [!fname:~0,11!].iso"
	
	REM Check ZSO
	"%~dp0BAT\busybox" head -n1 "!HDDPATHOUTPUT!\!GameName! - [!fname:~0,11!].iso" | "%~dp0BAT\busybox" grep -o -m 1 "ZISO" > "%~dp0TMP\CheckZSO.txt" & set /P CheckZSO=<"%~dp0TMP\CheckZSO.txt"
    if defined CheckZSO ren "!HDDPATHOUTPUT!\!GameName! - [!fname:~0,11!].iso" "!GameName! - [!fname:~0,11!].zso" >nul 2>&1
	
	 endlocal
	endlocal
    )
	echo\
    echo\
    cd /d "%~dp0CD-DVD" & ren *. *.iso >nul 2>&1
	echo Extracted.. to CD-DVD\
	
cd /d "%~dp0" & rmdir /Q/S "%~dp0TMP" >nul 2>&1

echo\
echo\
"%~dp0BAT\Diagbox" gd 0f
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo Extraction Completed...
echo\
echo\
"%~dp0BAT\Diagbox" gd 07

pause & (goto GamesManagement)
REM ####################################################################################################################################################
:CreateDelPART
cls
mkdir "%~dp0TMP" >nul 2>&1

IF NOT DEFINED @hdl_path ( rmdir /Q/S "%~dp0TMP" >nul 2>&1 & goto ScanningPS2HDD ) else (
"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning for Playstation 2 HDDs:
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "!@hdl_path!" | "%~dp0BAT\busybox" grep "Playstation 2 HDD" >nul
if errorlevel 1 set "@hdl_path=" & goto ScanningPS2HDD
echo       [!@hdl_path! !@TotalHDD_Size! - !@ModelePS2HDD!]
)

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo !Part_Option! a Partition:
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1^) Yes
"%~dp0BAT\Diagbox" gd 0c
echo         2^) No
"%~dp0BAT\Diagbox" gd 0e
if !Part_Option!==Create echo         3^) POPS Example& set 3=3
"%~dp0BAT\Diagbox" gd 07
echo\
CHOICE /C 12!3! /M "Select Option:"

IF !ERRORLEVEL!==1 set "ShowPartitionList="
IF !ERRORLEVEL!==2 (goto HDDManagementMenu)
if !Part_Option!==Create IF !ERRORLEVEL!==3 set POPSExample=Yes

if !Part_Option!==Delete (
if not defined ShowPartitionList (
echo\
echo\
echo Choose the partitions to display
echo ---------------------------------------------------
echo         1^) PS1 Games
echo         2^) PS2 Games
echo         3^) APP Homebrew
echo         4^) System
echo         5^) All
echo\
CHOICE /C 12345 /M "Select Option:"
IF !ERRORLEVEL!==1 set "ShowPartitionList=PS1 Games"
IF !ERRORLEVEL!==2 set "ShowPartitionList=PS2 Games" & set UnconvertPS2PFS=Yes
IF !ERRORLEVEL!==3 set "ShowPartitionList=APP System"
IF !ERRORLEVEL!==4 set "ShowPartitionList=System"
IF !ERRORLEVEL!==5 set "ShowPartitionList=All"
)

cls
echo\
echo\
echo Scanning Partitions:
"%~dp0BAT\Diagbox" gd 0e
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 07

if "!ShowPartitionList!"=="PS1 Games" type "%~dp0BAT\__Cache\PARTITION_POPS_GAME.txt" | "%~dp0BAT\busybox" sort -k2 > "%~dp0TMP\PARTITION_!ShowPartitionList!.txt"
if "!ShowPartitionList!"=="PS2 Games" (
	"%~dp0BAT\busybox" grep "0x0100" "%~dp0BAT\__Cache\PARTITION_PS2HDD.txt" | "%~dp0BAT\busybox" cut -c30-250 | "%~dp0BAT\busybox" sed "s/.\{15\}/& /" | "%~dp0BAT\busybox" sort -k2 | "%~dp0BAT\busybox" sed -e "s/\(.\{15\}\)./\1/" | "%~dp0BAT\busybox" sed "s/PP\./__\./g" > "%~dp0TMP\PARTITION_PS2_PFS.txt"
	for /f "usebackq tokens=*" %%f in ("%~dp0TMP\PARTITION_PS2_PFS.txt") do "%~dp0BAT\busybox" grep "%%f" "%~dp0BAT\__Cache\PARTITION_HDL_GAME.txt" >> "%~dp0TMP\PARTITION_!ShowPartitionList!.txt"
	)

if "!ShowPartitionList!"=="APP System" type "%~dp0BAT\__Cache\PARTITION_APPS.txt" | "%~dp0BAT\busybox" sort -k2 > "%~dp0TMP\PARTITION_!ShowPartitionList!.txt"
if "!ShowPartitionList!"=="System" (

type "%~dp0BAT\__Cache\PARTITION_HDL_GAME.txt" | "%~dp0BAT\busybox" sed "s/^[^|]*|//g; s/__\./PP\./g" > "%~dp0TMP\PARTITION_HDL_GAME.txt"
"%~dp0BAT\busybox" grep -e "0x0001\|0x0100" "%~dp0BAT\__Cache\PARTITION_PS2HDD.txt" | "%~dp0BAT\busybox" sed "/\.POPS\./d; /PP.APPS-/d" | "%~dp0BAT\busybox" cut -c30-250 > "%~dp0TMP\PARTITION_!ShowPartitionList!.txt"

 for /f "usebackq" %%A in ("%~dp0TMP\PARTITION_!ShowPartitionList!.txt") do (
 "%~dp0BAT\busybox" grep "%%A" "%~dp0TMP\PARTITION_HDL_GAME.txt" >nul
	if errorlevel 1 (echo >nul) else ("%~dp0BAT\busybox" sed -i "/%%A/d" "%~dp0TMP\PARTITION_!ShowPartitionList!.txt")
	)
)

if !ShowPartitionList!==All "%~dp0BAT\busybox" sed "/0x1337/d" "%~dp0BAT\__Cache\PARTITION_PS2HDD.txt"  | "%~dp0BAT\busybox" sed "$d" > "%~dp0TMP\PARTITION_!ShowPartitionList!.txt"

type "%~dp0TMP\PARTITION_!ShowPartitionList!.txt" | "%~dp0BAT\busybox" sed "s/|.*//"
"%~dp0BAT\Diagbox" gd 0e
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 07
)

echo\
"%~dp0BAT\Diagbox" gd 06
if "!ShowPartitionList!"=="PS2 Games" echo Only PFS resource partition will be displayed and deleted & echo NOTE: HDL partition prefix __. will be unhide automatically & echo\ & echo\
 "%~dp0BAT\Diagbox" gd 07
 
if !Part_Option!==Create (
"%~dp0BAT\Diagbox" gd 0e
cls
echo\
echo\
echo Configure your partition
echo ---------------------------------------------------
echo\
"%~dp0BAT\Diagbox" gd 0f

if !POPSExample!==Yes (
echo You can create up to 10 POPS partitions.
echo.
echo __.POPS0
echo __.POPS1
echo __.POPS2
echo __.POPS3
echo __.POPS4
echo __.POPS5
echo __.POPS6
echo __.POPS7
echo __.POPS8
echo __.POPS9
echo __.POPS
echo.
)

echo Enter the name of your Partition 
echo Example: +OPL
)

if !Part_Option!==Delete echo Please type the gameid ^+ GameName or partition name as shown in the List.
set /p "PartName="
if "!PartName!"=="" rmdir /Q/S "%~dp0TMP" >nul 2>&1 & (goto HDDManagementMenu)

if !Part_Option!==Delete (
if defined UnconvertPS2PFS "%~dp0BAT\busybox" grep -F -w -m 1 "!PartName!" "%~dp0TMP\PARTITION_!ShowPartitionList!.txt" | "%~dp0BAT\busybox" sed "s/.*|//g; s/__\./PP\./g" > "%~dp0TMP\PFSDEL.txt" & set /P PartName=<"%~dp0TMP\PFSDEL.txt"
)

echo ---------------------------------------------------
if !Part_Option!==Create (
echo.
echo The size must be multiplied by 128
echo Example: 128 x 5 = 640MB
echo Max size per partition 128GB
echo.
echo Example size:
echo 128mb = 128M
echo 256mb = 256M
echo 384mb = 384M
echo 512mb = 512M
echo 640mb = 640M
echo 768mb = 768M
echo 896mb = 896M
echo   1GB =   1G
echo 128GB = 128G
echo\
echo Example: 
echo If you want a 10GB partition Type: 10G
echo If you want a 512MB partition Type: 512M
echo If you want a 1.5GB partition 1024 ^+ 512 = 1536 Type: 1536M
echo\
echo\
set /p "partsize=Enter partition size:"
IF "!partsize!"=="" rmdir /Q/S "%~dp0TMP" >nul 2>&1 & (goto HDDManagementMenu) 
set fstype=PFS
)

cls
echo\
echo\
echo !Part_Option2! !PartName! Partition:
echo ---------------------------------------------------
echo\

    echo        !Part_Option2! !PartName!
  	echo device !@pfsshell_path! > "%~dp0TMP\pfs-log.txt"
	echo !PFS_Option! "!PartName!" !partsize! !fstype! >> "%~dp0TMP\pfs-log.txt"
  	echo exit >> "%~dp0TMP\pfs-log.txt"
	type "%~dp0TMP\pfs-log.txt" | "%~dp0BAT\pfsshell" >nul 2>&1
	
	if defined UnconvertPS2PFS "%~dp0BAT\hdl_dump" modify !@hdl_path! "__.!PartName:~3!" -unhide >nul 2>&1
	echo        Completed...

    REM Reloading HDD Cache
    call "%~dp0BAT\__ReloadHDD_cache.bat" >nul 2>&1

cd /d "%~dp0" & rmdir /Q/S "%~dp0TMP" >nul 2>&1

echo\
echo\
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo Completed...
echo\
echo\
"%~dp0BAT\Diagbox" gd 07

pause & (goto HDDManagementMenu)
REM #######################################################################################################################################
:BlankPart
cls
mkdir "%~dp0TMP" >nul 2>&1

IF NOT DEFINED @hdl_path ( rmdir /Q/S "%~dp0TMP" >nul 2>&1 & goto ScanningPS2HDD ) else (
"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning for Playstation 2 HDDs:
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "!@hdl_path!" | "%~dp0BAT\busybox" grep "Playstation 2 HDD" >nul
if errorlevel 1 set "@hdl_path=" & goto ScanningPS2HDD
echo       [!@hdl_path! !@TotalHDD_Size! - !@ModelePS2HDD!]
)

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Blank a Partition:
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1^) Yes
"%~dp0BAT\Diagbox" gd 0c
echo         2^) No
"%~dp0BAT\Diagbox" gd 0f
echo\
CHOICE /C 12 /M "Select Option:"

IF !ERRORLEVEL!==2 (goto HDDManagementMenu)

cls
echo\
echo\
echo Scanning Partitions:
"%~dp0BAT\Diagbox" gd 0e
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 07

"%~dp0BAT\busybox" sed "s/^[^|]*|//g; s/__\./PP\./g" "%~dp0BAT\__Cache\PARTITION_HDL_GAME.txt" > "%~dp0TMP\PARTITION_HDL_GAME.txt"
"%~dp0BAT\busybox" grep -e "0x0001\|0x0100" "%~dp0BAT\__Cache\PARTITION_PS2HDD.txt" | "%~dp0BAT\busybox" sed "/\.POPS\./d; /PP.APPS-/d" | "%~dp0BAT\busybox" cut -c30-250 > "%~dp0TMP\PARTITION_PFS.txt"

for /f "usebackq" %%A in ("%~dp0TMP\PARTITION_PFS.txt") do (
 "%~dp0BAT\busybox" grep "%%A" "%~dp0TMP\PARTITION_HDL_GAME.txt" >nul
	if errorlevel 1 (echo >nul) else ("%~dp0BAT\busybox" sed -i "/%%A/d" "%~dp0TMP\PARTITION_PFS.txt")
	)

type "%~dp0TMP\PARTITION_PFS.txt" | "%~dp0BAT\busybox" sed "s/|.*//"
"%~dp0BAT\Diagbox" gd 0e
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 06
echo\
echo WARNING: All files inside the partition will be deleted.
echo\
"%~dp0BAT\Diagbox" gd 07
 
echo Enter the name of your Partition
set /p "PartName="
if "!PartName!"=="" rmdir /Q/S "%~dp0TMP" >nul 2>&1 & (goto HDDManagementMenu)
"%~dp0BAT\busybox" grep -ow "!PartName!" "%~dp0TMP\PARTITION_PFS.txt" > "%~dp0TMP\PARTITION_Selected.txt"

cls
for /f "usebackq tokens=1,2,3,4,5" %%f in ("%~dp0TMP\PARTITION_Selected.txt") do (
set PartSize=%%i
echo\
echo\
echo !PartName!
echo ---------------------------------------------------
echo\

    echo        !PartName!
	echo device !@pfsshell_path! > "%~dp0TMP\pfs-log.txt"
	echo rmpart "!PartName!" >> "%~dp0TMP\pfs-log.txt"
 	echo mkpart "!PartName!" !PartSize:~0,-1! PFS >> "%~dp0TMP\pfs-log.txt"
  	echo exit >> "%~dp0TMP\pfs-log.txt"
	type "%~dp0TMP\pfs-log.txt" | "%~dp0BAT\pfsshell" >nul 2>&1

	echo        Completed...

)

cd /d "%~dp0" & rmdir /Q/S "%~dp0TMP" >nul 2>&1

echo\
echo\
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo Completed...
echo\
echo\
"%~dp0BAT\Diagbox" gd 07

pause & (goto HDDManagementMenu)
REM #######################################################################################################################################
:PartitionInfoList
cls
mkdir "%~dp0TMP" >nul 2>&1
mkdir "%~dp0LOG" >nul 2>&1

IF NOT DEFINED @hdl_path ( rmdir /Q/S "%~dp0TMP" >nul 2>&1 & goto ScanningPS2HDD ) else (
"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning for Playstation 2 HDDs:
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "!@hdl_path!" | "%~dp0BAT\busybox" grep "Playstation 2 HDD" >nul
if errorlevel 1 set "@hdl_path=" & goto ScanningPS2HDD
echo       [!@hdl_path! !@TotalHDD_Size! - !@ModelePS2HDD!]
)

echo\
echo\
"%~dp0BAT\Diagbox" gd 0f
echo Scanning Partitions !ShowPartitionList!:
echo ---------------------------------------------------

if "!ShowPartitionList!"=="PS1 Games" "%~dp0BAT\busybox" grep -e "\.POPS\." "%~dp0BAT\__Cache\PARTITION_PS2HDD.txt" | "%~dp0BAT\busybox" sed "s/.\{48\}/& /" | "%~dp0BAT\busybox" sort -k6 | "%~dp0BAT\busybox" sed -e "s/\(.\{48\}\)./\1/" > "%~dp0LOG\PARTITION_PS1_GAMES.txt" & type "%~dp0LOG\PARTITION_PS1_GAMES.txt"
if "!ShowPartitionList!"=="PS2 Games" "%~dp0BAT\busybox" grep -e "0x1337" "%~dp0BAT\__Cache\PARTITION_PS2HDD.txt" | "%~dp0BAT\busybox" sed "s/.\{44\}/& /" | "%~dp0BAT\busybox" sort -k6 | "%~dp0BAT\busybox" sed -e "s/\(.\{44\}\)./\1/" > "%~dp0LOG\PARTITION_PS2_GAMES.txt" & type "%~dp0LOG\PARTITION_PS2_GAMES.txt"
if "!ShowPartitionList!"=="APP" "%~dp0BAT\busybox" grep -e "PP.APPS-" "%~dp0BAT\__Cache\PARTITION_PS2HDD.txt" | "%~dp0BAT\busybox" sed "s/.\{44\}/& /" | "%~dp0BAT\busybox" sort -k6 | "%~dp0BAT\busybox" sed -e "s/\(.\{44\}\)./\1/" > "%~dp0LOG\PARTITION_APPS.txt" & type "%~dp0LOG\PARTITION_APPS.txt"
if "!ShowPartitionList!"=="System" (

type "%~dp0BAT\__Cache\PARTITION_HDL_GAME.txt" | "%~dp0BAT\busybox" sed "s/^[^|]*|//g; s/__\./PP\./g" > "%~dp0TMP\PARTITION_HDL_GAME.txt"
"%~dp0BAT\busybox" sed "/0x1337/d; /PP.APPS-/d" "%~dp0BAT\__Cache\PARTITION_PS2HDD.txt" | "%~dp0BAT\busybox" sed "$d" | "%~dp0BAT\busybox" sed "/\.POPS\./d" > "%~dp0LOG\PARTITION_SYSTEM.txt"

  type "%~dp0LOG\PARTITION_SYSTEM.txt" | "%~dp0BAT\busybox" cut -c30-500 > "%~dp0TMP\PARTITION_SYSTEM_TMP.txt"
   for /f "usebackq" %%A  in ("%~dp0TMP\PARTITION_SYSTEM_TMP.txt") do (
   "%~dp0BAT\busybox" grep "%%A" "%~dp0TMP\PARTITION_HDL_GAME.txt" >nul
  	if errorlevel 1 (echo >nul) else ("%~dp0BAT\busybox" sed -i "/%%A/d" "%~dp0LOG\PARTITION_SYSTEM.txt")
  	)
type "%~dp0LOG\PARTITION_SYSTEM.txt"
)

if "!ShowPartitionList!"=="Total POPS Size" (

	"%~dp0BAT\busybox" grep -w "__.POPS\|__.POPS[0-9]" "%~dp0BAT\__Cache\PARTITION_PS2HDD.txt" | "%~dp0BAT\busybox" sort -k5 > "%~dp0TMP\hdd-prt.txt"
	for /f "usebackq tokens=1,2,3,4,5" %%f in ("%~dp0TMP\hdd-prt.txt") do (
	set PartSize=%%i
	set POPSPART=%%j
	set TotalUsed=0
	set Remaining=

	echo device !@pfsshell_path! > "%~dp0TMP\pfs-pops.txt"
	echo mount !POPSPART! >> "%~dp0TMP\pfs-pops.txt"
	echo ls -l >> "%~dp0TMP\pfs-pops.txt"
	echo umount >> "%~dp0TMP\pfs-pops.txt"
	type "%~dp0TMP\pfs-pops.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" grep -ie ".*\.VCD$" > "%~dp0TMP\PFS-POPS.log"
	
	for /f "usebackq tokens=1,2,3,4,5" %%f in ("%~dp0TMP\PFS-POPS.log") do (set /a "TotalUsed+=%%g / 1048576")
	set /a Remaining=!PartSize:~0,-2! - !TotalUsed!
	
	echo Name: [!POPSPART!] - Size: [!PartSize!] - Used: [!TotalUsed!MB] - Free: [!Remaining!MB]
	)
)

if "!ShowPartitionList!"=="Total Size" (

	 REM PS1
	 "%~dp0BAT\busybox" grep -e "\.POPS\." "%~dp0BAT\__Cache\PARTITION_PS2HDD.txt" | "%~dp0BAT\busybox" cut -c23-26 > "%~dp0TMP\PS1GamesSize.txt"
	 "%~dp0BAT\busybox" sed -e "/^$/d" "%~dp0TMP\PS1GamesSize.txt" | "%~dp0BAT\busybox" wc -l > "%~dp0TMP\TotalPS1Games.txt" & set /P @TotalPS1Games=<"%~dp0TMP\TotalPS1Games.txt"
     for /f "usebackq" %%s in ("%~dp0TMP\PS1GamesSize.txt") do (set /a "TotalPS1Games_Size+=%%s")
     
	 REM PS2
	 "%~dp0BAT\busybox" grep -e "0x1337" "%~dp0BAT\__Cache\PARTITION_PS2HDD.txt" | "%~dp0BAT\busybox" cut -c23-26 > "%~dp0TMP\PS2GamesSize.txt"
	 "%~dp0BAT\busybox" sed -e "/^$/d" "%~dp0TMP\PS2GamesSize.txt" | "%~dp0BAT\busybox" wc -l > "%~dp0TMP\TotalPS2Games.txt" & set /P @TotalPS2Games=<"%~dp0TMP\TotalPS2Games.txt"
     for /f "usebackq" %%s in ("%~dp0TMP\PS2GamesSize.txt") do (set /a "TotalPS2Games_Size+=%%s")
	 
	 REM APP
     "%~dp0BAT\busybox" sed "/0x1337/d; /\.POPS\./d" "%~dp0BAT\__Cache\PARTITION_PS2HDD.txt" | "%~dp0BAT\busybox" sed "$d" | "%~dp0BAT\busybox" sed "1d" | "%~dp0BAT\busybox" grep "PP.APPS-" | "%~dp0BAT\busybox" cut -c23-26 > "%~dp0TMP\APPSize.txt"
	 "%~dp0BAT\busybox" sed -e "/^$/d" "%~dp0TMP\APPSize.txt" | "%~dp0BAT\busybox" wc -l > "%~dp0TMP\TotalAPP.txt" & set /P @TotalAPP=<"%~dp0TMP\TotalAPP.txt"
	 for /f "usebackq" %%s in ("%~dp0TMP\APPSize.txt") do (set /a "TotalAPP_Size+=%%s")
	 
	 REM PFS
     "%~dp0BAT\busybox" sed "/0x1337/d; /\.POPS\./d; /PP.APPS-/d" "%~dp0BAT\__Cache\PARTITION_PS2HDD.txt" | "%~dp0BAT\busybox" sed "$d" | "%~dp0BAT\busybox" sed "1d" | "%~dp0BAT\busybox" cut -c23-26 > "%~dp0TMP\PFSSize.txt"
	 "%~dp0BAT\busybox" sed -e "/^$/d" "%~dp0TMP\PFSSize.txt" | "%~dp0BAT\busybox" wc -l > "%~dp0TMP\TotalPFS.txt" & set /P @TotalPFS=<"%~dp0TMP\TotalPFS.txt"
	 for /f "usebackq" %%s in ("%~dp0TMP\PFSSize.txt") do (set /a "TotalPFS_Size+=%%s")
	 
	 for %%s in (!TotalPS1Games_Size! !TotalPS2Games_Size! !TotalAPP_Size! !TotalPFS_Size!) do (
	 if %%s LSS 1000 (set TypePartSize=%%sMB) else (set /a "value=%%s / 1000" & set /a "remainder=%%s %% 1000" & set TypePartSize=!value!.!remainder!GB)
	 if %%s==!TotalPS1Games_Size! set @TotalPS1Games_Size=!TypePartSize!
	 if %%s==!TotalPS2Games_Size! set @TotalPS2Games_Size=!TypePartSize!
	 if %%s==!TotalAPP_Size! set @TotalAPP_Size=!TypePartSize!
	 if %%s==!TotalPFS_Size! set @TotalPFS_Size=!TypePartSize!
	 )
	 
echo TOTAL - PS1 Games:  [!@TotalPS1Games!]    TOTAL - Size: [!@TotalPS1Games_Size!]
echo TOTAL - PS2 Games:  [!@TotalPS2Games!]    TOTAL - Size: [!@TotalPS2Games_Size!]
echo TOTAL - APP System: [!@TotalAPP!]    TOTAL - Size: [!@TotalAPP_Size!]
echo TOTAL - PFS System: [!@TotalPFS!]    TOTAL - Size: [!@TotalPFS_Size!]
echo\
echo             TOTAL - Used: [!@TotalHDD_Used! - !@TotalHDD_Percentage!]
echo             TOTAL - Free: [!@TotalHDD_Available!]
)

if defined DiagPartitionError (
echo Scanning Partitions Error:
"%~dp0BAT\Diagbox" gd 06
echo.
echo NOTE: If nothing appears there is no error in the partitions
echo.
"%~dp0BAT\Diagbox" gd 0f
echo ---------------------------------------------------
"%~dp0BAT\hdl_dump" diag %@hdl_path% > "%~dp0LOG\PARTITION_SCAN_ERROR.log" & type "%~dp0LOG\PARTITION_SCAN_ERROR.log")
echo ---------------------------------------------------

cd /d "%~dp0" & rmdir /Q/S "%~dp0TMP" >nul 2>&1

echo\
echo\
pause & (goto ShowPartitionInfos)
REM #######################################################################################################################################
:MBRProgram
cls

IF NOT DEFINED @hdl_path ( rmdir /Q/S "%~dp0TMP" >nul 2>&1 & goto ScanningPS2HDD ) else (
"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning for Playstation 2 HDDs:
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "!@hdl_path!" | "%~dp0BAT\busybox" grep "Playstation 2 HDD" >nul
if errorlevel 1 set "@hdl_path=" & goto ScanningPS2HDD
echo       [!@hdl_path! !@TotalHDD_Size! - !@ModelePS2HDD!]
)

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Backup or Inject MBR Program:
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1^) Yes Backup MBR
"%~dp0BAT\Diagbox" gd 0c
echo         2^) No
"%~dp0BAT\Diagbox" gd 0e
echo         3^) Yes Inject MBR
"%~dp0BAT\Diagbox" gd 07
echo\
CHOICE /C 123 /M "Select Option:"

IF %ERRORLEVEL%==1 set MBR=dump
IF %ERRORLEVEL%==2 (goto HDDManagementMenu)
IF %ERRORLEVEL%==3 set MBR=inject

echo\
echo\
"%~dp0BAT\hdl_dump" %MBR%_mbr %@hdl_path% "%~dp0\__MBR.KELF"
if not exist "%~dp0\__MBR.KELF" ( echo "%~dp0__MBR.KELF" Missing!) else ( echo ^> "%~dp0__MBR.KELF")

REM Reloading HDD Cache
if !MBR!==inject call "%~dp0BAT\__ReloadHDD_cache.bat" >nul 2>&1

echo\
pause & (goto HDDManagementMenu) 
REM ###########################################################################################################################################################################################
:formatHDDtoPS2
cls
mkdir "%~dp0TMP" >nul 2>&1

"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning HDDs:
echo ---------------------------------------------------
    "%~dp0BAT\Diagbox" gd 03
	powershell -Command "Get-WmiObject Win32_DiskDrive | Select-Object Model,DeviceID" | "%~dp0BAT\busybox" sed "/\\\\.\\\PHYSICALDRIVE0/d" | "%~dp0BAT\busybox" grep "PHYSICALDRIVE"
	"%~dp0BAT\Diagbox" gd 07
    echo ---------------------------------------------------
	"%~dp0BAT\Diagbox" gd 0c
	echo WARNING: MAKE SURE YOU CHOOSE THE RIGHT HARD DRIVE YOU WANT TO FORMAT
	"%~dp0BAT\Diagbox" gd 06
	echo.
	"%~dp0BAT\Diagbox" gd 0c
	echo Disclaimer: I can in no way be held responsible for improper use.
	"%~dp0BAT\Diagbox" gd 06
	echo\
	echo If you cannot choose your hard drive from the list, choose option 7.
	"%~dp0BAT\Diagbox" gd 07
	echo. 
	echo Select Physical HDD
	echo 	1. \\.\PHYSICALDRIVE1:
	echo 	2. \\.\PHYSICALDRIVE2:
	echo 	3. \\.\PHYSICALDRIVE3:
	echo 	4. \\.\PHYSICALDRIVE4:
	echo 	5. \\.\PHYSICALDRIVE5:
	echo 	6. \\.\PHYSICALDRIVE6:
	echo 	7. \\.\PHYSICALDRIVE#: Manual search (More HDD)
	echo 	9. Back to main menu
	echo\
	choice /c 123456789 /m "Select Option:"
	
	if errorlevel 1 set hdlhdd=hdd1:
	if errorlevel 2 set hdlhdd=hdd2:
	if errorlevel 3 set hdlhdd=hdd3:
	if errorlevel 4 set hdlhdd=hdd4:
	if errorlevel 5 set hdlhdd=hdd5:
	if errorlevel 6 set hdlhdd=hdd6:
	if errorlevel 7 set hdlhddm=yes
	if errorlevel 9 (goto HDDManagementMenu)
  
    IF "!hdlhddm!"=="yes" (
	echo\
    echo What is the number of my hard drive? / The one next to the \\.\PHYSICALDRIVE#: in the scanned HDDs
    echo Example If you want to hack \\.\PHYSICALDRIVE7: type 7
    echo\
	
    set choice=
    set /p choice=Enter the number of the hard drive you want to format:
    echo\
    IF "!choice!"=="" set "hdlhddm=" & set "hdlhdd=" & set "@pfsshell_path=" & set "@hdl_pathinfo=" & (goto formatHDDtoPS2)
    IF "!choice!"=="!choice!" set hdlhdd=hdd!choice!:
    IF "!choice!"=="Q" (goto  HDDManagementMenu)
    )

"%~dp0BAT\Diagbox" gd 0e
cls
echo\
echo\
echo HDD Selected:
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | findstr "%hdlhdd%"
"%~dp0BAT\hdl_dump" query | findstr "%hdlhdd%" | "%~dp0BAT\busybox" grep -o "%hdlhdd%" | "%~dp0BAT\busybox" sed "s/hdd/\\\\.\\\PhysicalDrive/g; s/://g" > "%~dp0TMP\hdl-hdd.txt" & set /P @pfsshell_path=<"%~dp0TMP\hdl-hdd.txt"
"%~dp0BAT\Diagbox" gd 0f

	echo\
	"%~dp0BAT\busybox" sed -e "s/\\\\.\\\PhysicalDrive/PHYSICALDRIVE/g; s/://g" "%~dp0TMP\hdl-hdd.txt" > "%~dp0TMP\hdl-hddinfo.txt" & set /P @hdl_pathinfo=<"%~dp0TMP\hdl-hddinfo.txt"
	powershell -Command "Get-WmiObject -Query \"SELECT Model, Name, Status FROM Win32_DiskDrive\" | Format-Table Model, Name, Status -AutoSize" > "%~dp0TMP\hdl-hddinfolog.txt"
    type "%~dp0TMP\hdl-hddinfolog.txt" | findstr "Model %@hdl_pathinfo%" | "%~dp0BAT\busybox" sed -e "3,100d" > "%~dp0TMP\hdl-hddinfotmp.txt" & type "%~dp0TMP\hdl-hddinfotmp.txt"
	
"%~dp0BAT\Diagbox" gd 0c
echo\
echo Are you sure you want to format this hard drive to PS2 format ?:
"%~dp0BAT\Diagbox" gd 0f
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1^) Yes
"%~dp0BAT\Diagbox" gd 0c
echo         2^) No
"%~dp0BAT\Diagbox" gd 07
echo\
CHOICE /C 12 /M "Select Option:"

IF %ERRORLEVEL%==1 set @pfs_formathdd=yes
IF %ERRORLEVEL%==2 set @pfs_formathdd=no & set "hdlhddm=" & set "hdlhdd=" & set "@pfsshell_path=" & set "@hdl_pathinfo=" & (goto formatHDDtoPS2)

echo\

CHOICE /C YN /m "Confirm"
IF %ERRORLEVEL%==2 set "hdlhdd=" & set "hdlhddm=" & set "@pfsshell_path=" & set "@hdl_pathinfo=" & (goto formatHDDtoPS2)

	IF "!@PSX2DESR_HDD!"=="Yes" (
	"%~dp0BAT\Diagbox" gd 0c
	    cls
		echo          PSX DESR HDD - Detected
		echo      You should not format your PSX HDD^!
		echo\
		echo              ABORTED OPERATION
		echo\
		echo\
		"%~dp0BAT\Diagbox" gd 0f
		pause & set "hdlhdd=" & set "hdlhddm=" & set "@pfsshell_path=" & set "@hdl_pathinfo=" & (goto formatHDDtoPS2)
		)

IF %@pfs_formathdd%==yes (
"%~dp0BAT\Diagbox" gd 0f
cls
echo\
echo\
echo Formatting HDD:
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
type "%~dp0TMP\hdl-hddinfotmp.txt"
"%~dp0BAT\Diagbox" gd 0f
echo\
    
    echo         Formatting in Progress...
	echo device %@pfsshell_path% > "%~dp0TMP\pfs-log.txt"
    echo initialize yes >> "%~dp0TMP\pfs-log.txt"
  	echo exit >> "%~dp0TMP\pfs-log.txt"
	type "%~dp0TMP\pfs-log.txt" | "%~dp0BAT\pfsshell" >nul 2>&1

	echo %@pfsshell_path% > "%~dp0TMP\disk-log.txt"
	"%~dp0BAT\busybox" sed -i "s/\\\\.\\\PhysicalDrive/select disk /g" "%~dp0TMP\disk-log.txt"
	echo offline disk >> "%~dp0TMP\disk-log.txt"
	type "%~dp0TMP\disk-log.txt" | "diskpart" >nul 2>&1

	echo %@pfsshell_path% > "%~dp0TMP\disk-log.txt"
	"%~dp0BAT\busybox" sed -i "s/\\\\.\\\PhysicalDrive/select disk /g" "%~dp0TMP\disk-log.txt"
	echo online disk >> "%~dp0TMP\disk-log.txt"
	type "%~dp0TMP\disk-log.txt" | "diskpart" >nul 2>&1

	REM echo         Generating PFS filesystem for system partitions...
	REM Reloading HDD Cache
    if !hdlhdd!==hdd!@NumberPS2HDD!: call "%~dp0BAT\__ReloadHDD_cache.bat" >nul 2>&1
	echo         Formatting HDD completed...
	
	) else ( echo          HDD - Not Detected... )

cd /d "%~dp0" & rmdir /Q/S "%~dp0TMP" >nul 2>&1

echo\
echo\
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo Formatting Completed...
echo\
echo\
"%~dp0BAT\Diagbox" gd 07

pause & (goto HDDManagementMenu)
REM ####################################################################################################################################################
:hackHDDtoPS2
cls
cd /d "%~dp0"
mkdir "%~dp0TMP" >nul 2>&1

"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning HDDs:
echo ---------------------------------------------------
    "%~dp0BAT\Diagbox" gd 03
	powershell -Command "Get-WmiObject Win32_DiskDrive | Select-Object Model,DeviceID" | "%~dp0BAT\busybox" sed "/\\\\.\\\PHYSICALDRIVE0/d" | "%~dp0BAT\busybox" grep "PHYSICALDRIVE"
	"%~dp0BAT\Diagbox" gd 07
    echo ---------------------------------------------------
	"%~dp0BAT\Diagbox" gd 0c
	echo WARNING: MAKE SURE YOU CHOOSE THE RIGHT HARD DRIVE YOU WANT TO HACK
	"%~dp0BAT\Diagbox" gd 06
	echo.
	"%~dp0BAT\Diagbox" gd 0c
	echo Disclaimer: I can in no way be held responsible for improper use.
	echo\
	"%~dp0BAT\Diagbox" gd 06
	echo If you cannot choose your hard drive from the list, choose option 7.
	"%~dp0BAT\Diagbox" gd 07
	echo. 
	echo Select Physical HDD
	echo 	1. \\.\PHYSICALDRIVE1:
	echo 	2. \\.\PHYSICALDRIVE2:
	echo 	3. \\.\PHYSICALDRIVE3:
	echo 	4. \\.\PHYSICALDRIVE4:
	echo 	5. \\.\PHYSICALDRIVE5:
	echo 	6. \\.\PHYSICALDRIVE6:
	echo 	7. \\.\PHYSICALDRIVE#: Manual search (More HDD)
	echo 	9. Back to main menu
	echo\
	choice /c 123456789 /m "Select Option:"
	
	if errorlevel 1 set hdlhdd=hdd1:
	if errorlevel 2 set hdlhdd=hdd2:
	if errorlevel 3 set hdlhdd=hdd3:
	if errorlevel 4 set hdlhdd=hdd4:
	if errorlevel 5 set hdlhdd=hdd5:
	if errorlevel 6 set hdlhdd=hdd6:
	if errorlevel 7 set hdlhddm=yes
	if errorlevel 9 (goto HDDManagementMenu)
  
    IF "!hdlhddm!"=="yes" (
	echo\
    echo What is the number of my hard drive? / The one next to the \\.\PHYSICALDRIVE#: in the scanned HDDs
    echo Example If you want to hack \\.\PHYSICALDRIVE7: type 7
    echo\
	
    set choice=
    set /p choice=Enter the number of the hard drive you want to Hack:
    echo\
    IF "!choice!"=="" set "hdlhddm=" & set "hdlhdd=" & set "@pfsshell_path=" & set "@hdl_pathinfo=" & (goto hackHDDtoPS2)
    IF "!choice!"=="!choice!" set hdlhdd=hdd!choice!:
    IF "!choice!"=="Q" (goto  HDDManagementMenu)
    )

"%~dp0BAT\Diagbox" gd 0e
cls
echo\
echo HDD Selected:
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | findstr "%hdlhdd%"
"%~dp0BAT\hdl_dump" query | findstr "%hdlhdd%" | "%~dp0BAT\busybox" grep -o "%hdlhdd%" | "%~dp0BAT\busybox" sed "s/hdd/\\\\.\\\PhysicalDrive/g; s/://g" > "%~dp0TMP\hdl-hdd.txt" & set /P @pfsshell_path=<"%~dp0TMP\hdl-hdd.txt"
"%~dp0BAT\Diagbox" gd 0f

	echo\
	"%~dp0BAT\busybox" sed -e "s/\\\\.\\\PhysicalDrive/PHYSICALDRIVE/g; s/://g" "%~dp0TMP\hdl-hdd.txt" > "%~dp0TMP\hdl-hddinfo.txt" & set /P @hdl_pathinfo=<"%~dp0TMP\hdl-hddinfo.txt"
    powershell -Command "Get-WmiObject -Query \"SELECT Model, Name, Status FROM Win32_DiskDrive\" | Format-Table Model, Name, Status -AutoSize" > "%~dp0TMP\hdl-hddinfolog.txt"
    type "%~dp0TMP\hdl-hddinfolog.txt" | findstr "Model %@hdl_pathinfo%" | "%~dp0BAT\busybox" sed -e "3,100d" > "%~dp0TMP\hdl-hddinfotmp.txt" & type "%~dp0TMP\hdl-hddinfotmp.txt"

    rmdir /Q/S "%~dp0\^!COPY_TO_USB_ROOT" >nul 2>&1
    "%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0BAT\^!COPY_TO_USB_ROOT.7z" -o"%~dp0\^!COPY_TO_USB_ROOT" >nul 2>&1

"%~dp0BAT\Diagbox" gd 06
echo\
echo If you have already installed FreeHDBoot ^(From HDD^), you don't need to do this
"%~dp0BAT\Diagbox" gd 0f
echo.
echo ^(1^) After the hacking put your HDD in your PS2 and format your hard drive with wLaunchELF
echo In wLaunchELF FileBrowser ^> MISC ^> HDDManager ^> Press R1 ^> Format and confirm.
echo.
echo ^(2^) Copy the contents of the ^!COPY_TO_USB_ROOT folder to the root of your USB drive 
echo.
echo ^(3^) Install FreeHDBoot
echo In wLaunchELF FileBrowser ^> Mass ^> APPS ^> FreeMcBoot ^> FMCBInstaller.elf Press Circle for Launch ^> Press R1 ^> Install FHDB ^(From HDD^)
echo.
echo ^(4^) Your hard drive will be properly formatted and hacked after that
echo\
"%~dp0BAT\Diagbox" gd 0c 
echo ARE YOU SURE you want to HACK this hard drive ? this is irreversible:
"%~dp0BAT\Diagbox" gd 0f
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1^) Yes
"%~dp0BAT\Diagbox" gd 0c
echo         2^) No
"%~dp0BAT\Diagbox" gd 07
echo\
CHOICE /C 12 /M "Select Option:"

IF ERRORLEVEL 1 set @pfs_hackhdd=yes
IF ERRORLEVEL 2 rmdir /Q/S "%~dp0\^!COPY_TO_USB_ROOT" >nul 2>&1 & set "hdlhddm=" & set "hdlhdd=" & set "@pfsshell_path=" & set "@hdl_pathinfo=" & (goto hackHDDtoPS2)
IF ERRORLEVEL 2 set @pfs_hackhdd=no

echo\

CHOICE /C YN /m "Confirm"
IF ERRORLEVEL 2 rmdir /Q/S "%~dp0\^!COPY_TO_USB_ROOT" >nul 2>&1 & set "hdlhddm=" & set "hdlhdd=" & set "@pfsshell_path=" & set "@hdl_pathinfo=" & (goto hackHDDtoPS2) 

	IF "!@PSX2DESR_HDD!"=="Yes" (
	"%~dp0BAT\Diagbox" gd 0c
	    cls
		echo             PSX DESR HDD - Detected
		echo      You should not modify the MBR of your PSX HDD^^!
		echo\
		echo                ABORTED OPERATION
		echo\
		echo\
		"%~dp0BAT\Diagbox" gd 0f
		pause & rmdir /Q/S "%~dp0\^!COPY_TO_USB_ROOT" >nul 2>&1 & set "hdlhddm=" & set "hdlhdd=" & set "@pfsshell_path=" & set "@hdl_pathinfo=" & (goto hackHDDtoPS2) 
		)

IF %@pfs_hackhdd%==yes (
cls
echo\
echo\
echo Install BOOT Entry point Hack PS2 HDD:
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
type "%~dp0TMP\hdl-hddinfotmp.txt"
"%~dp0BAT\Diagbox" gd 0f
echo\

    echo         Hacking in progress...
	echo "%~dp0BAT\rawcopy" "%~dp0BAT\mbr.img" %@pfsshell_path% > "%~dp0TMP\disk-log.bat"
	call "%~dp0TMP\disk-log.bat"
	
	echo %@pfsshell_path% > "%~dp0TMP\disk-log.txt"
	"%~dp0BAT\busybox" sed -i "s/\\\\.\\\PhysicalDrive/select disk /g" "%~dp0TMP\disk-log.txt"
	echo offline disk >> "%~dp0TMP\disk-log.txt"
	type "%~dp0TMP\disk-log.txt" | "diskpart" >nul 2>&1
	
	echo %@pfsshell_path% > "%~dp0TMP\disk-log.txt"
	"%~dp0BAT\busybox" sed -i "s/\\\\.\\\PhysicalDrive/select disk /g" "%~dp0TMP\disk-log.txt"
	echo online disk >> "%~dp0TMP\disk-log.txt"
	type "%~dp0TMP\disk-log.txt" | "diskpart" >nul 2>&1
	
    REM Reloading HDD Cache
    if !hdlhdd!==hdd!@NumberPS2HDD!: call "%~dp0BAT\__ReloadHDD_cache.bat" >nul 2>&1
	echo         Hacking completed...
	
	) else ( echo        Hack HDD - Canceled... )

cd /d "%~dp0" & rmdir /Q/S "%~dp0TMP" >nul 2>&1

echo\
echo\
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo MBR Hack Completed...
echo\
echo\
"%~dp0BAT\Diagbox" gd 07

"%~dp0\^!COPY_TO_USB_ROOT\README.txt"

pause & (goto HDDManagementMenu)
REM ##############################################################################################################################################################
:InstallHDDOSD
cls
mkdir "%~dp0TMP" >nul 2>&1
cd /d "%~dp0TMP"

IF NOT DEFINED @hdl_path ( rmdir /Q/S "%~dp0TMP" >nul 2>&1 & goto ScanningPS2HDD ) else (
"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning for Playstation 2 HDDs:
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "!@hdl_path!" | "%~dp0BAT\busybox" grep "Playstation 2 HDD" >nul
if errorlevel 1 set "@hdl_path=" & goto ScanningPS2HDD
echo       [!@hdl_path! !@TotalHDD_Size! - !@ModelePS2HDD!]
)

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Install HDD-OSD: (Browser 2.0)
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1^) Yes
"%~dp0BAT\Diagbox" gd 0c
echo         2^) No
"%~dp0BAT\Diagbox" gd 0f
echo\
CHOICE /C 12 /M "Select Option:"

IF %ERRORLEVEL%==1 set @pfs_installhddosd=yes
IF %ERRORLEVEL%==2 set @pfs_installhddosd=no & (goto HDDOSDMenu)

echo\
echo\
echo Checking Files For HDD-OSD
echo ---------------------------------------------------

    if not exist "%~dp0HDD-OSD\__system\osd100\hosdsys.elf" (
    "%~dp0BAT\Diagbox" gd 0c
    echo         No HDD-OSD files found^^!
    echo\
    echo\
    rmdir /Q/S "%~dp0TMP" >nul 2>&1
	"%~dp0BAT\Diagbox" gd 0f
    pause & (goto HDDOSDMenu)
    ) else (
    "%~dp0BAT\busybox" md5sum "%~dp0HDD-OSD\__system\osd100\hosdsys.elf" | "%~dp0BAT\busybox" grep -o "[0-9a-z]\{32\}" > "%~dp0TMP\MD5.txt" & set /p MD5=<"%~dp0TMP\MD5.txt"
    if !MD5! equ ca9ab553e8b51259ccf1ca4ea2d1bc00 set HDDOSDVER=1.10U
    if !MD5! equ bc00148828ea502597320867ce7a6e76 set HDDOSDVER=1.00U
    if !MD5! equ 9257473af4ecd2b085a782d5d0952cce set HDDOSDVER=1.00J
    )

    if defined HDDOSDVER (
    "%~dp0BAT\Diagbox" gd 0a
    echo         HDD-OSD !HDDOSDVER! - Detected
    ) else (
    "%~dp0BAT\Diagbox" gd 0c
    echo         No compatible version detected
    echo\
    echo\
    rmdir /Q/S "%~dp0TMP" >nul 2>&1
	"%~dp0BAT\Diagbox" gd 0f
    pause & (goto HDDOSDMenu)
 )

"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Detecting __sysconf Partition:
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0f

	"%~dp0BAT\busybox" grep -ow "__sysconf" "%~dp0BAT\__Cache\PARTITION_PS2HDD.txt" > "%~dp0TMP\hdd-prt.txt" & set /P @hdd_avl=<"%~dp0TMP\hdd-prt.txt"
	
	IF "!@hdd_avl!"=="__sysconf" (
	"%~dp0BAT\Diagbox" gd 0a
		echo         __sysconf - Partition Detected
		) else (
		"%~dp0BAT\Diagbox" gd 0c
		echo         __sysconf - Partition NOT Detected
		echo             Partition Must Be Created
		echo\
		echo\
		"%~dp0BAT\Diagbox" gd 07
		rmdir /Q/S "%~dp0TMP" >nul 2>&1
		pause & (goto HDDOSDMenu)
		)

"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Detecting __system Partition:
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0f

	"%~dp0BAT\busybox" grep -ow "__system" "%~dp0BAT\__Cache\PARTITION_PS2HDD.txt" > "%~dp0TMP\hdd-prt.txt" & set /P @hdd_avl=<"%~dp0TMP\hdd-prt.txt"
	
	IF "!@hdd_avl!"=="__system" (
	"%~dp0BAT\Diagbox" gd 0a
		echo         __system - Partition Detected
		) else (
		"%~dp0BAT\Diagbox" gd 0c
		echo         __system - Partition NOT Detected
		echo             Partition Must Be Created
		echo\
		echo\
		"%~dp0BAT\Diagbox" gd 07
		rmdir /Q/S "%~dp0TMP" >nul 2>&1
	    pause & (goto HDDOSDMenu)
		)

"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Detecting OPL Resources Partition:
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0f

    "%~dp0BAT\busybox" grep -ow "%OPLPART%" "%~dp0BAT\__Cache\PARTITION_PS2HDD.txt" > "%~dp0TMP\hdd-prt.txt" & set /P @hdd_avl=<"%~dp0TMP\hdd-prt.txt"
	
	IF "!@hdd_avl!"=="%OPLPART%" (
	"%~dp0BAT\Diagbox" gd 0a
		echo         %OPLPART% - Partition Detected
		) else (
		"%~dp0BAT\Diagbox" gd 0c
		echo           %OPLPART% - Partition NOT Detected
		echo               Partition Must Be Created
		echo\
		echo\
		"%~dp0BAT\Diagbox" gd 07
		rmdir /Q/S "%~dp0TMP" >nul 2>&1
		pause & (goto HDDOSDMenu)
		)

"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Detecting FreeHDBoot:
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0f

	echo device !@pfsshell_path! > "%~dp0TMP\pfs-prt.txt"
	echo mount __system >> "%~dp0TMP\pfs-prt.txt"
	echo cd osd >> "%~dp0TMP\pfs-prt.txt"
	echo ls >> "%~dp0TMP\pfs-prt.txt"
	echo exit >> "%~dp0TMP\pfs-prt.txt"
	type "%~dp0TMP\pfs-prt.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" grep -o "osdmain.elf" > "%~dp0TMP\hdd-prt.txt" & set /P @hdd_FHDB=<"%~dp0TMP\hdd-prt.txt"
	
	IF "!@hdd_FHDB!"=="osdmain.elf" (
	"%~dp0BAT\Diagbox" gd 0a
		echo         FreeHDBoot - Detected
		) else (
		"%~dp0BAT\Diagbox" gd 0c
		echo         FreeHDBoot - Installation NOT Detected
		echo         You need to install FreeHDBoot to use HDD-OSD.
		echo\
		"%~dp0BAT\Diagbox" gd 06
		echo Do you want to continue? You can install FreeHDBoot later
		choice /c YN
	    if errorlevel 2 (set @pfs_installhddosd=no) else (set @pfs_installhddosd=yes)
		)

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
pause
cls

IF %@pfs_installhddosd%==yes (
echo\
echo\
echo Installing HDD-OSD !HDDOSDVER!:
echo ---------------------------------------------------
echo\

    REM __sysconf
	cd /d "%~dp0HDD-OSD\__sysconf"

	REM MOUNT __sysconf
	echo device !@pfsshell_path! > "%~dp0TMP\pfs-hddosd.txt"
	echo mount __sysconf >> "%~dp0TMP\pfs-hddosd.txt"
	
	REM HDD-OSD DIR (__sysconf\files.xxx)
	echo         Installing Que
    for %%0 in (*) do (echo put "%%0") >> "%~dp0TMP\pfs-hddosd.txt"

	REM HDDOSD 1 DIR (__sysconf\SUBDIR)
	for /D %%a in (*) do (
	echo mkdir "%%a" >> "%~dp0TMP\pfs-hddosd.txt"
	echo lcd "%%a" >> "%~dp0TMP\pfs-hddosd.txt"
 	echo cd "%%a" >> "%~dp0TMP\pfs-hddosd.txt"
 	cd "%%a"

	REM HDD-OSD FILES (__sysconf\SUBDIR\files.xxx)
 	for %%1 in (*) do (echo put "%%1") >> "%~dp0TMP\pfs-hddosd.txt"

	REM HDDOSD 2 SUBDIR (__sysconf\SUBDIR\SUBDIR)
	for /D %%b in (*) do (
	echo mkdir "%%b" >> "%~dp0TMP\pfs-hddosd.txt"
	echo lcd "%%b" >> "%~dp0TMP\pfs-hddosd.txt"
	echo cd "%%b" >> "%~dp0TMP\pfs-hddosd.txt"
	cd "%%b"

	REM HDDOSD SUBDIR FILES (__sysconf\SUBDIR\SUBDIR\files.xxx)
	for %%2 in (*) do (echo put "%%2") >> "%~dp0TMP\pfs-hddosd.txt"

	REM HDDOSD 3 SUBDIR (__sysconf\SUBDIR\SUBDIR\SUBDIR)
	for /D %%c in (*) do (
	echo mkdir "%%c" >> "%~dp0TMP\pfs-hddosd.txt"
	echo lcd "%%c" >> "%~dp0TMP\pfs-hddosd.txt"
	echo cd "%%c" >> "%~dp0TMP\pfs-hddosd.txt"
	cd "%%c"
	
	REM HDDOSD SUBDIR FILES (__sysconf\SUBDIR\SUBDIR\SUBDIR\files.xxx)
	for %%3 in (*) do (echo put "%%3") >> "%~dp0TMP\pfs-hddosd.txt"
	
    REM HDDOSD 4 SUBDIR (__sysconf\SUBDIR\SUBDIR\SUBDIR\SUBDIR\SUBDIR)
	for /D %%e in (*) do (
	echo mkdir "%%e" >> "%~dp0TMP\pfs-hddosd.txt"
	echo lcd "%%e" >> "%~dp0TMP\pfs-hddosd.txt"
	echo cd "%%e" >> "%~dp0TMP\pfs-hddosd.txt"
	cd "%%e"
	
	REM HDDOSD SUBDIR FILES (__sysconf\SUBDIR\SUBDIR\SUBDIR\SUBDIR\files.xxx)
	for %%4 in (*) do (echo put "%%4") >> "%~dp0TMP\pfs-hddosd.txt"
	
	REM HDDOSD 5 SUBDIR (__sysconf\SUBDIR\SUBDIR\SUBDIR\SUBDIR\SUBDIR\)
	for /D %%f in (*) do (
	echo mkdir "%%f" >> "%~dp0TMP\pfs-hddosd.txt"
	echo lcd "%%f" >> "%~dp0TMP\pfs-hddosd.txt"
	echo cd "%%f" >> "%~dp0TMP\pfs-hddosd.txt"
	cd "%%f"
	
	REM HDDOSD SUBDIR FILES (__sysconf\SUBDIR\SUBDIR\SUBDIR\SUBDIR\SUBDIR\files.xxx)
	for %%5 in (*) do (echo put "%%5") >> "%~dp0TMP\pfs-hddosd.txt"

	REM EXIT SUBDIR
	echo lcd .. >> "%~dp0TMP\pfs-hddosd.txt"
	echo cd .. >> "%~dp0TMP\pfs-hddosd.txt"
	cd ..
	)
	
	echo lcd .. >> "%~dp0TMP\pfs-hddosd.txt"
	echo cd .. >> "%~dp0TMP\pfs-hddosd.txt"
 	cd ..
	)
	
	echo lcd .. >> "%~dp0TMP\pfs-hddosd.txt"
	echo cd .. >> "%~dp0TMP\pfs-hddosd.txt"
 	cd ..
	)
	
	echo lcd .. >> "%~dp0TMP\pfs-hddosd.txt"
	echo cd .. >> "%~dp0TMP\pfs-hddosd.txt"
 	cd ..
    )
	
	echo lcd .. >> "%~dp0TMP\pfs-hddosd.txt"
	echo cd .. >> "%~dp0TMP\pfs-hddosd.txt"
 	cd ..
	)
	
    REM UNMOUNT __sysconf
	echo umount >> "%~dp0TMP\pfs-hddosd.txt"
	echo exit >> "%~dp0TMP\pfs-hddosd.txt"
	type "%~dp0TMP\pfs-hddosd.txt" | "%~dp0BAT\pfsshell" >nul 2>&1
	echo         Partition __sysconf Completed...

	cd /d "%~dp0HDD-OSD\__system"
	REM MOUNT __SYSTEM
	echo device !@pfsshell_path! > "%~dp0TMP\pfs-hddosd.txt"
	echo mount __system >> "%~dp0TMP\pfs-hddosd.txt"
	
	echo         Installing Que
    for %%0 in (*) do (echo put "%%0") >> "%~dp0TMP\pfs-hddosd.txt"

	REM HDDOSD 1 DIR (__system\SUBDIR)
	for /D %%a in (*) do (
	echo mkdir "%%a" >> "%~dp0TMP\pfs-hddosd.txt"
	echo lcd "%%a" >> "%~dp0TMP\pfs-hddosd.txt"
 	echo cd "%%a" >> "%~dp0TMP\pfs-hddosd.txt"
 	cd "%%a"

	REM HDDOSD FILES (__system\SUBDIR\files.xxx)
 	for %%1 in (*) do (echo put "%%1") >> "%~dp0TMP\pfs-hddosd.txt"

	REM HDDOSD 2 SUBDIR (__system\SUBDIR\SUBDIR)
	for /D %%b in (*) do (
	echo mkdir "%%b" >> "%~dp0TMP\pfs-hddosd.txt"
	echo lcd "%%b" >> "%~dp0TMP\pfs-hddosd.txt"
	echo cd "%%b" >> "%~dp0TMP\pfs-hddosd.txt"
	cd "%%b"

	REM HDDOSD SUBDIR FILES (__system\SUBDIR\SUBDIR\files.xxx)
	for %%2 in (*) do (echo put "%%2") >> "%~dp0TMP\pfs-hddosd.txt"
	
	REM HDDOSD 3 SUBDIR (__system\SUBDIR\SUBDIR\SUBDIR)
	for /D %%c in (*) do (
	echo mkdir "%%c" >> "%~dp0TMP\pfs-hddosd.txt"
	echo lcd "%%c" >> "%~dp0TMP\pfs-hddosd.txt"
	echo cd "%%c" >> "%~dp0TMP\pfs-hddosd.txt"
	cd "%%c"
	
	REM HDDOSD SUBDIR FILES (__system\SUBDIR\SUBDIR\SUBDIR\files.xxx)
	for %%3 in (*) do (echo put "%%3") >> "%~dp0TMP\pfs-hddosd.txt"

    REM HDDOSD 4 SUBDIR (__system\SUBDIR\SUBDIR\SUBDIR\SUBDIR\SUBDIR)
	for /D %%e in (*) do (
	echo mkdir "%%e" >> "%~dp0TMP\pfs-hddosd.txt"
	echo lcd "%%e" >> "%~dp0TMP\pfs-hddosd.txt"
	echo cd "%%e" >> "%~dp0TMP\pfs-hddosd.txt"
	cd "%%e"
	
	REM HDDOSD SUBDIR FILES (__system\SUBDIR\SUBDIR\SUBDIR\SUBDIR\files.xxx)
	for %%4 in (*) do (echo put "%%4") >> "%~dp0TMP\pfs-hddosd.txt"
	
	REM HDDOSD 5 SUBDIR (__system\SUBDIR\SUBDIR\SUBDIR\SUBDIR\SUBDIR\)
	for /D %%f in (*) do (
	echo mkdir "%%f" >> "%~dp0TMP\pfs-hddosd.txt"
	echo lcd "%%f" >> "%~dp0TMP\pfs-hddosd.txt"
	echo cd "%%f" >> "%~dp0TMP\pfs-hddosd.txt"
	cd "%%f"
	
	REM HDDOSD SUBDIR FILES (__system\SUBDIR\SUBDIR\SUBDIR\SUBDIR\SUBDIR\files.xxx)
	for %%5 in (*) do (echo put "%%5") >> "%~dp0TMP\pfs-hddosd.txt"

	REM EXIT SUBDIR
    echo lcd .. >> "%~dp0TMP\pfs-hddosd.txt"
	echo cd .. >> "%~dp0TMP\pfs-hddosd.txt"
	cd ..
	)
	
	echo lcd .. >> "%~dp0TMP\pfs-hddosd.txt"
	echo cd .. >> "%~dp0TMP\pfs-hddosd.txt"
 	cd ..
	)
	
	echo lcd .. >> "%~dp0TMP\pfs-hddosd.txt"
	echo cd .. >> "%~dp0TMP\pfs-hddosd.txt"
 	cd ..
	)
	
	echo lcd .. >> "%~dp0TMP\pfs-hddosd.txt"
	echo cd .. >> "%~dp0TMP\pfs-hddosd.txt"
 	cd ..
    )
	
	echo lcd .. >> "%~dp0TMP\pfs-hddosd.txt"
	echo cd .. >> "%~dp0TMP\pfs-hddosd.txt"
 	cd ..
	)

	REM UNMOUNT __system
	echo umount >> "%~dp0TMP\pfs-hddosd.txt"
	echo exit >> "%~dp0TMP\pfs-hddosd.txt"
	type "%~dp0TMP\pfs-hddosd.txt" | "%~dp0BAT\pfsshell" >nul 2>&1
	echo         Partition __system Completed...
   
    REM Copy OPL Files For Launch Games From HDD-OSD, PSBBN, XMB
    cd /d "%~dp0HDD-OSD\__common\OPL"
    echo device !@pfsshell_path! > "%~dp0TMP\pfs-hddosd.txt"
	echo mount __common >> "%~dp0TMP\pfs-hddosd.txt"
	echo mkdir OPL >> "%~dp0TMP\pfs-hddosd.txt"
	echo cd OPL >> "%~dp0TMP\pfs-hddosd.txt"
	echo hdd_partition=!OPLPART!> "%~dp0HDD-OSD\__common\OPL\conf_hdd.cfg"
 	echo put conf_hdd.cfg >> "%~dp0TMP\pfs-hddosd.txt"
    echo umount >> "%~dp0TMP\pfs-hddosd.txt"
	echo exit >> "%~dp0TMP\pfs-hddosd.txt"
	type "%~dp0TMP\pfs-hddosd.txt" | "%~dp0BAT\pfsshell" >nul 2>&1

    cd /d "%~dp0TMP"
	"%~dp0BAT\7-Zip\7z" e -bso0 "%~dp0BAT\APPS.zip" -o"%~dp0TMP\OPL_STABLE" "APPS\Open PS2 Loader Stable\*.ELF" -r -y >nul 2>&1 & move "%~dp0TMP\OPL_STABLE\*.ELF" "%~dp0TMP\OPNPS2LD.ELF" >nul 2>&1
	echo device !@pfsshell_path! > "%~dp0TMP\pfs-hddosd.txt"
	echo mount %OPLPART% >> "%~dp0TMP\pfs-hddosd.txt"
	if defined CUSTOM_OPLPART echo mkdir OPL >> "%~dp0TMP\pfs-hddosd.txt"
    if defined CUSTOM_OPLPART echo cd OPL >> "%~dp0TMP\pfs-hddosd.txt"
	echo rm OPNPS2LD.ELF >> "%~dp0TMP\pfs-hddosd.txt"
 	echo put OPNPS2LD.ELF >> "%~dp0TMP\pfs-hddosd.txt"
	echo cd .. >> "%~dp0TMP\pfs-hddosd.txt"
    echo umount >> "%~dp0TMP\pfs-hddosd.txt"

	echo mount __sysconf >> "%~dp0TMP\pfs-hddosd.txt"
	echo cd FMCB >> "%~dp0TMP\pfs-hddosd.txt"
	echo get FREEHDB.CNF >> "%~dp0TMP\pfs-hddosd.txt"
    echo umount >> "%~dp0TMP\pfs-hddosd.txt"
	echo exit >> "%~dp0TMP\pfs-hddosd.txt"
	type "%~dp0TMP\pfs-hddosd.txt" | "%~dp0BAT\pfsshell" >nul 2>&1
	
	if exist "%~dp0TMP\FREEHDB.CNF" (
	"%~dp0BAT\busybox" sed -i "/OSDSYS_left_cursor/s/009/006/g; /OSDSYS_right_cursor/s/008/005/g; /OSDSYS_menu_bottom_delimiter/s/006/009/g; /OSDSYS_menu_bottom_delimiter/s/007/010/g" "%~dp0TMP\FREEHDB.CNF"
	echo device !@pfsshell_path! > "%~dp0TMP\pfs-hddosd.txt"
	echo mount __sysconf >> "%~dp0TMP\pfs-hddosd.txt"
	echo cd FMCB >> "%~dp0TMP\pfs-hddosd.txt"
	echo rm FREEHDB.CNF >> "%~dp0TMP\pfs-hddosd.txt"
	echo put FREEHDB.CNF >> "%~dp0TMP\pfs-hddosd.txt"
	echo umount >> "%~dp0TMP\pfs-hddosd.txt"
	echo exit >> "%~dp0TMP\pfs-hddosd.txt"
	type "%~dp0TMP\pfs-hddosd.txt" | "%~dp0BAT\pfsshell" >nul 2>&1
	)
	
	echo         HDD-OSD Completed...
	
 ) else ( echo         HDDOSD - Installation Canceled... )

cd /d "%~dp0" & rmdir /Q/S "%~dp0TMP" >nul 2>&1

echo\
echo\
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo Installation Completed...
echo\
echo\
"%~dp0BAT\Diagbox" gd 07

pause & (goto HDDOSDMenu)
REM ####################################################################################################################################################
:UnInstallHDDOSD
cls
mkdir "%~dp0TMP" >nul 2>&1
cd /d "%~dp0"

IF NOT DEFINED @hdl_path ( rmdir /Q/S "%~dp0TMP" >nul 2>&1 & goto ScanningPS2HDD ) else (
"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning for Playstation 2 HDDs:
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "!@hdl_path!" | "%~dp0BAT\busybox" grep "Playstation 2 HDD" >nul
if errorlevel 1 set "@hdl_path=" & goto ScanningPS2HDD
echo       [!@hdl_path! !@TotalHDD_Size! - !@ModelePS2HDD!]
)

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Uninstall HDD-OSD:
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1^) Yes
"%~dp0BAT\Diagbox" gd 0c
echo         2^) No
"%~dp0BAT\Diagbox" gd 0f
echo\
CHOICE /C 12 /M "Select Option:"

IF %ERRORLEVEL%==1 set @pfs_uninhddosd=yes
IF %ERRORLEVEL%==2 set @pfs_uninhddosd=no & (goto HDDOSDMenu)

"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Detecting __sysconf Partition:
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0f

	"%~dp0BAT\busybox" grep -ow "__sysconf" "%~dp0BAT\__Cache\PARTITION_PS2HDD.txt" > "%~dp0TMP\hdd-prt.txt" & set /P @hdd_avl=<"%~dp0TMP\hdd-prt.txt"
	
	IF "!@hdd_avl!"=="__sysconf" (
	"%~dp0BAT\Diagbox" gd 0a
		echo         __sysconf - Partition Detected
		) else (
		"%~dp0BAT\Diagbox" gd 0c
		echo         __sysconf - Partition NOT Detected
		echo              Partition Must Be Created
		echo\
		echo\
		"%~dp0BAT\Diagbox" gd 0f
		rmdir /Q/S "%~dp0TMP" >nul 2>&1
		pause & (goto HDDOSDMenu)
		)

"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Detecting __system Partition:
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0f

	"%~dp0BAT\busybox" grep -ow "__system" "%~dp0BAT\__Cache\PARTITION_PS2HDD.txt" > "%~dp0TMP\hdd-prt.txt" & set /P @hdd_avl=<"%~dp0TMP\hdd-prt.txt"
	
	IF "!@hdd_avl!"=="__system" (
	"%~dp0BAT\Diagbox" gd 0a
		echo         __system - Partition Detected
		"%~dp0BAT\Diagbox" gd 0c
		) else (
		echo         __system - Partition NOT Detected
		echo             Partition Must Be Created
		echo\
		echo\
		"%~dp0BAT\Diagbox" gd 0f
		rmdir /Q/S "%~dp0TMP" >nul 2>&1
		pause & (goto HDDOSDMenu)
		)

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
pause

cd /d "%~dp0TMP"
IF %@pfs_uninhddosd%==yes (
cls
echo\
echo\
echo Uninstall HDD-OSD:
echo ---------------------------------------------------
echo\

    REM __sysconf	
    echo        Uninstall HDD-OSD...
  	echo device %@pfsshell_path% > "%~dp0TMP\pfs-hddosd.txt"
	echo mount __sysconf >> "%~dp0TMP\pfs-hddosd.txt"
	
	REM FOLDER ATOK
	echo cd ATOK >> "%~dp0TMP\pfs-hddosd.txt"
	echo rm ATOK100.ERX >> "%~dp0TMP\pfs-hddosd.txt"
	echo rm ATOKP.DIC >> "%~dp0TMP\pfs-hddosd.txt"
	echo rm ATOKPYOU.DIC >> "%~dp0TMP\pfs-hddosd.txt"
	echo cd .. >> "%~dp0TMP\pfs-hddosd.txt"
	echo rmdir ATOK >> "%~dp0TMP\pfs-hddosd.txt"
	
	REM FOLDER CONF
	echo cd CONF >> "%~dp0TMP\pfs-hddosd.txt"
	echo rm FILETYPE.INI >> "%~dp0TMP\pfs-hddosd.txt"
    echo rm SYSTEM.INI >> "%~dp0TMP\pfs-hddosd.txt"
    echo rm SYSTEM101.INI >> "%~dp0TMP\pfs-hddosd.txt"
    echo rm SYSTEMDUT.INI >> "%~dp0TMP\pfs-hddosd.txt"
    echo rm SYSTEMEUK.INI >> "%~dp0TMP\pfs-hddosd.txt"
    echo rm SYSTEMFCA.INI >> "%~dp0TMP\pfs-hddosd.txt"
    echo rm SYSTEMFRE.INI >> "%~dp0TMP\pfs-hddosd.txt"
    echo rm SYSTEMGER.INI >> "%~dp0TMP\pfs-hddosd.txt"
    echo rm SYSTEMITA.INI >> "%~dp0TMP\pfs-hddosd.txt"
    echo rm SYSTEMPOR.INI >> "%~dp0TMP\pfs-hddosd.txt"
    echo rm SYSTEMSPA.INI >> "%~dp0TMP\pfs-hddosd.txt"
	echo cd .. >> "%~dp0TMP\pfs-hddosd.txt"
	echo rmdir CONF >> "%~dp0TMP\pfs-hddosd.txt"

    REM FOLDER FONT
	echo cd FONT >> "%~dp0TMP\pfs-hddosd.txt"
    echo rm S22I646.GF >> "%~dp0TMP\pfs-hddosd.txt"
    echo rm S22J201.GF >> "%~dp0TMP\pfs-hddosd.txt"
    echo rm S22J213.GF >> "%~dp0TMP\pfs-hddosd.txt"
    echo rm S22ULST.GF >> "%~dp0TMP\pfs-hddosd.txt"
    echo rm S26I646.GF >> "%~dp0TMP\pfs-hddosd.txt"
    echo rm S26J201.GF >> "%~dp0TMP\pfs-hddosd.txt"
    echo rm S26J213.GF >> "%~dp0TMP\pfs-hddosd.txt"
    echo rm S26ULST.GF >> "%~dp0TMP\pfs-hddosd.txt"
    echo rm SCE20I22.GF >> "%~dp0TMP\pfs-hddosd.txt"
    echo rm SCE24I26.GF >> "%~dp0TMP\pfs-hddosd.txt"
	echo cd .. >> "%~dp0TMP\pfs-hddosd.txt"
	echo rmdir FONT >> "%~dp0TMP\pfs-hddosd.txt"
	
	REM FOLDER ICON
	echo cd ICON >> "%~dp0TMP\pfs-hddosd.txt"
	echo rm ICON.SYS >> "%~dp0TMP\pfs-hddosd.txt"
    echo rm OTHERS.ICO >> "%~dp0TMP\pfs-hddosd.txt"
	
	REM FOLDER AUDIO
	echo cd ICON >> "%~dp0TMP\pfs-hddosd.txt"
	echo cd AUDIO >> "%~dp0TMP\pfs-hddosd.txt"
    echo rm AUDIO.ICO >> "%~dp0TMP\pfs-hddosd.txt"
	echo rm ICON.SYS >> "%~dp0TMP\pfs-hddosd.txt"
	echo cd .. >> "%~dp0TMP\pfs-hddosd.txt"
	echo rmdir AUDIO >> "%~dp0TMP\pfs-hddosd.txt"
	
    REM FOLDER HTML
	echo cd ICON >> "%~dp0TMP\pfs-hddosd.txt"
	echo cd HTML >> "%~dp0TMP\pfs-hddosd.txt"
    echo rm HTML.ICO >> "%~dp0TMP\pfs-hddosd.txt"
	echo rm ICON.SYS >> "%~dp0TMP\pfs-hddosd.txt"
	echo cd .. >> "%~dp0TMP\pfs-hddosd.txt"
	echo rmdir HTML >> "%~dp0TMP\pfs-hddosd.txt"
	
	REM FOLDER IMAGE
	echo cd ICON >> "%~dp0TMP\pfs-hddosd.txt"
	echo cd IMAGE >> "%~dp0TMP\pfs-hddosd.txt"
	echo rm ICON.SYS >> "%~dp0TMP\pfs-hddosd.txt"
	echo rm IMAGE.ICO >> "%~dp0TMP\pfs-hddosd.txt"
	echo cd .. >> "%~dp0TMP\pfs-hddosd.txt"
	echo rmdir IMAGE >> "%~dp0TMP\pfs-hddosd.txt"
	
	REM FOLDER TEXT
	echo cd ICON >> "%~dp0TMP\pfs-hddosd.txt"
	echo cd TEXT >> "%~dp0TMP\pfs-hddosd.txt"
	echo rm ICON.SYS >> "%~dp0TMP\pfs-hddosd.txt"
	echo rm TEXT.ICO >> "%~dp0TMP\pfs-hddosd.txt"
	echo cd .. >> "%~dp0TMP\pfs-hddosd.txt"
	echo rmdir TEXT >> "%~dp0TMP\pfs-hddosd.txt"
	
	REM FOLDER VIDEO
	echo cd ICON >> "%~dp0TMP\pfs-hddosd.txt"
	echo cd VIDEO >> "%~dp0TMP\pfs-hddosd.txt"
	echo rm ICON.SYS >> "%~dp0TMP\pfs-hddosd.txt"
	echo rm VIDEO.ICO >> "%~dp0TMP\pfs-hddosd.txt"
	echo cd .. >> "%~dp0TMP\pfs-hddosd.txt"
	echo rmdir VIDEO >> "%~dp0TMP\pfs-hddosd.txt"
 
    echo cd .. >> "%~dp0TMP\pfs-hddosd.txt"	
	echo rmdir ICON >> "%~dp0TMP\pfs-hddosd.txt"
	echo umount >> "%~dp0TMP\pfs-hddosd.txt"
	echo exit >> "%~dp0TMP\pfs-hddosd.txt"
	type "%~dp0TMP\pfs-hddosd.txt" | "%~dp0BAT\pfsshell" >nul 2>&1

    REM __system 
  	echo device %@pfsshell_path% > "%~dp0TMP\pfs-hddosd.txt"
	echo mount __system  >> "%~dp0TMP\pfs-hddosd.txt"
	
    REM FOLDER OSD100
	echo cd osd100 >> "%~dp0TMP\pfs-hddosd.txt"
	echo rm FNTOSD >> "%~dp0TMP\pfs-hddosd.txt"
	echo rm hosdsys.elf >> "%~dp0TMP\pfs-hddosd.txt"
	echo rm ICOIMAGE >> "%~dp0TMP\pfs-hddosd.txt"
	echo rm JISUCS >> "%~dp0TMP\pfs-hddosd.txt"
	echo rm SKBIMAGE >> "%~dp0TMP\pfs-hddosd.txt"
	echo rm SNDIMAGE >> "%~dp0TMP\pfs-hddosd.txt"
	echo rm TEXIMAGE >> "%~dp0TMP\pfs-hddosd.txt"
	echo cd .. >> "%~dp0TMP\pfs-hddosd.txt"
	echo rmdir osd100 >> "%~dp0TMP\pfs-hddosd.txt"

    REM FOLDER FSCK100
	echo cd fsck100 >> "%~dp0TMP\pfs-hddosd.txt"
	
	echo rm FSCK_A.XLF >> "%~dp0TMP\pfs-hddosd.txt"
	echo cd files >> "%~dp0TMP\pfs-hddosd.txt"
	echo rm FILES_A.PAK >> "%~dp0TMP\pfs-hddosd.txt"
	echo cd .. >> "%~dp0TMP\pfs-hddosd.txt"
	echo rmdir files >> "%~dp0TMP\pfs-hddosd.txt"
	
	echo rm FSCK100.ELF >> "%~dp0TMP\pfs-hddosd.txt"
	echo cd FILES >> "%~dp0TMP\pfs-hddosd.txt"
	echo rm FILES.PAK >> "%~dp0TMP\pfs-hddosd.txt"
	echo cd .. >> "%~dp0TMP\pfs-hddosd.txt"
	echo rmdir FILES >> "%~dp0TMP\pfs-hddosd.txt"
	
	echo cd .. >> "%~dp0TMP\pfs-hddosd.txt"
	echo rmdir fsck100 >> "%~dp0TMP\pfs-hddosd.txt"
	
    echo umount >> "%~dp0TMP\pfs-hddosd.txt"
	echo lcd "%~dp0TMP" >> "%~dp0TMP\pfs-hddosd.txt"
	echo cd ... >> "%~dp0TMP\pfs-hddosd.txt"
	echo mount __sysconf >> "%~dp0TMP\pfs-hddosd.txt"
	echo cd FMCB >> "%~dp0TMP\pfs-hddosd.txt"
	echo get FREEHDB.CNF >> "%~dp0TMP\pfs-hddosd.txt"
	echo rm FREEHDB.CNF >> "%~dp0TMP\pfs-hddosd.txt"
	
    echo umount >> "%~dp0TMP\pfs-hddosd.txt"
	echo exit >> "%~dp0TMP\pfs-hddosd.txt"
	type "%~dp0TMP\pfs-hddosd.txt" | "%~dp0BAT\pfsshell" >nul 2>&1

	if exist "%~dp0TMP\FREEHDB.CNF" (
	"%~dp0BAT\busybox" sed -i "/OSDSYS_left_cursor/s/006/009/g; /OSDSYS_right_cursor/s/005/008/g; /OSDSYS_menu_bottom_delimiter/s/009/006/g; /OSDSYS_menu_bottom_delimiter/s/010/007/g" "%~dp0TMP\FREEHDB.CNF"
	echo device !@pfsshell_path! > "%~dp0TMP\pfs-hddosd.txt"
	echo mount __sysconf >> "%~dp0TMP\pfs-hddosd.txt"
	echo cd FMCB >> "%~dp0TMP\pfs-hddosd.txt"
	echo put FREEHDB.CNF >> "%~dp0TMP\pfs-hddosd.txt"
	echo umount >> "%~dp0TMP\pfs-hddosd.txt"
	echo exit >> "%~dp0TMP\pfs-hddosd.txt"
	type "%~dp0TMP\pfs-hddosd.txt" | "%~dp0BAT\pfsshell" >nul 2>&1
	)
	
	echo        Uninstall Completed...	
	) else ( echo         HDDOSD - Uninstall Canceled... )

cd /d "%~dp0" & rmdir /Q/S "%~dp0TMP" >nul 2>&1

echo\
echo\
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo Uninstall Completed...
echo\
echo\
"%~dp0BAT\Diagbox" gd 07

pause & (goto HDDOSDMenu)
REM ##################################################################################################################################################
:pphide_unhide
cls
mkdir "%~dp0TMP" >nul 2>&1

IF NOT DEFINED @hdl_path ( rmdir /Q/S "%~dp0TMP" >nul 2>&1 & goto ScanningPS2HDD ) else (
"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning for Playstation 2 HDDs:
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "!@hdl_path!" | "%~dp0BAT\busybox" grep "Playstation 2 HDD" >nul
if errorlevel 1 set "@hdl_path=" & goto ScanningPS2HDD
echo       [!@hdl_path! !@TotalHDD_Size! - !@ModelePS2HDD!]
)

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo !Pfs_Part_Option! PS2 Game partition in HDD-OSD:
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1^) Yes
"%~dp0BAT\Diagbox" gd 0c
echo         2^) No
"%~dp0BAT\Diagbox" gd 0e
echo         3^) Yes (!Pfs_Part_Option! all PS2 Games partitions)
REM echo         4^) Yes (Hide all PS1 Games partitions)
"%~dp0BAT\Diagbox" gd 07
echo\
CHOICE /C 123 /M "Select Option:"

IF !ERRORLEVEL!==1 set @pfs_part=Manually
IF !ERRORLEVEL!==2 (goto HDDOSDPartManagement)
REM IF %ERRORLEVEL%==4 set @pfs_pphidePS1Games=yes & set @pfs_pphide=yes

cls
echo\
echo\
echo Scanning Games List:
echo ---------------------------------------------------

if !Pfs_Part_Option!==Hide (
    type "%~dp0BAT\__Cache\PARTITION_HDL_GAME.txt" | "%~dp0BAT\busybox" sed "/|__\./d" > "%~dp0TMP\PARTITION_PS2_GAMES_!Pfs_Part_Option!.txt"
	) else (
	type "%~dp0BAT\__Cache\PARTITION_HDL_GAME.txt" | "%~dp0BAT\busybox" sed "/|PP\./d" > "%~dp0TMP\PARTITION_PS2_GAMES_!Pfs_Part_Option!.txt"
    "%~dp0BAT\busybox" grep "0x0100" "%~dp0BAT\__Cache\PARTITION_PS2HDD.txt" | "%~dp0BAT\busybox" cut -c30-250 | "%~dp0BAT\busybox" sed "s/.\{15\}/& /" | "%~dp0BAT\busybox" sort -k2 | "%~dp0BAT\busybox" sed -e "s/\(.\{15\}\)./\1/" | "%~dp0BAT\busybox" sed "s/PP\./__\./g" > "%~dp0TMP\PARTITION_PS2_PFS.txt"

     for /f "usebackq tokens=*" %%f in ("%~dp0TMP\PARTITION_PS2_PFS.txt") do (
     findstr %%f "%~dp0TMP\PARTITION_PS2_GAMES_!Pfs_Part_Option!.txt" >nul
	 if errorlevel 1 (echo >nul) else ("%~dp0BAT\busybox" sed -i "/%%f/d" "%~dp0TMP\PARTITION_PS2_GAMES_!Pfs_Part_Option!.txt")
	  )
	 )

type "%~dp0TMP\PARTITION_PS2_GAMES_!Pfs_Part_Option!.txt" | "%~dp0BAT\busybox" sed "s/|.*//" | "%~dp0BAT\busybox" sort -k2 > "%~dp0TMP\GameListPS2.txt" & type "%~dp0TMP\GameListPS2.txt"
echo ---------------------------------------------------

    if !@pfs_part!==Manually (
    "%~dp0BAT\Diagbox" gd 06
    echo\
    echo If you don't see your partitions, it means they are already converted for PSBBN, XMB or !Pfs_Part_Option!n
    echo\
	"%~dp0BAT\Diagbox" gd 0e
	echo Please type the gameid ^+ GameName as shown in the Games List.
	"%~dp0BAT\Diagbox" gd 07
	set "gname="
    set /p "gname="
    if "!gname!"=="" (goto HDDOSDPartManagement)
    if "!gname!"=="!gname:~0,11!" set "gname=!gname:~0,11! "

	"%~dp0BAT\busybox" grep -Fx "!gname!" "%~dp0TMP\GameListPS2.txt" >nul
	if errorlevel 1 (
    "%~dp0BAT\Diagbox" gd 0c
	echo       !gname! NOT Detected
	echo\
	echo\
	"%~dp0BAT\Diagbox" gd 07
	rmdir /Q/S "%~dp0TMP" >nul 2>&1
	pause & (goto HDDOSDPartManagement)
	) else ("%~dp0BAT\busybox" grep -F -w -m 1 "!gname!" "%~dp0BAT\__Cache\PARTITION_HDL_GAME.txt" > "%~dp0TMP\PARTITION_PS2_GAMES_!Pfs_Part_Option!.txt")
    )

for /f "usebackq tokens=1* delims=|" %%f in ("%~dp0TMP\PARTITION_PS2_GAMES_!Pfs_Part_Option!.txt") do (

setlocal DisableDelayedExpansion
set fname=%%f
set pname=%%g
setlocal EnableDelayedExpansion

echo\
echo\
echo !Pfs_Part_Option! !pname!
echo ---------------------------------------------------
echo\
	
    echo        !fname:~12!
	"%~dp0BAT\hdl_dump" modify !@hdl_path! "!pname!" !@hdl_option!
	echo        Completed
	
 endlocal
endlocal
)

	REM Reloading HDD Cache
	call "%~dp0BAT\__ReloadHDD_cache.bat" >nul 2>&1
	
cd /d "%~dp0" & rmdir /Q/S "%~dp0TMP" >nul 2>&1

echo\
echo\
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo Completed...
echo\
echo\
"%~dp0BAT\Diagbox" gd 07

pause & (goto HDDOSDPartManagement)
REM ####################################################################################################################################################
:RenameTitleHDDOSD
cd "%~dp0"
cls
mkdir "%~dp0TMP" >nul 2>&1

IF NOT DEFINED @hdl_path ( rmdir /Q/S "%~dp0TMP" >nul 2>&1 & goto ScanningPS2HDD ) else (
"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning for Playstation 2 HDDs:
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "!@hdl_path!" | "%~dp0BAT\busybox" grep "Playstation 2 HDD" >nul
if errorlevel 1 set "@hdl_path=" & goto ScanningPS2HDD
echo       [!@hdl_path! !@TotalHDD_Size! - !@ModelePS2HDD!]
)

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Rename a title partitions:
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1^) Yes PS2 Games
"%~dp0BAT\Diagbox" gd 0c
echo         2^) No
"%~dp0BAT\Diagbox" gd 0e
echo         3^) Yes PS1 Games
echo\
"%~dp0BAT\Diagbox" gd 07
CHOICE /C 123 /M "Select Option:"

IF %ERRORLEVEL%==1 set RenameGamesOSD=HDL& (goto RenamePPTitleOSD)
IF %ERRORLEVEL%==2 if defined @GameManagementMenu (goto GamesManagement) else (goto HDDOSDPartManagement)
IF %ERRORLEVEL%==3 set RenameGamesOSD=POPS& (goto RenamePPTitleOSD)

REM ####################################################################################################################################################
:CustomPPHeader
cls
mkdir "%~dp0TMP" >nul 2>&1
IF NOT EXIST "%~dp0HDD-OSD\PP.HEADER" MD "%~dp0HDD-OSD\PP.HEADER\PFS\res\image"
cd /d "%~dp0HDD-OSD\PP.HEADER"

IF NOT DEFINED @hdl_path ( rmdir /Q/S "%~dp0TMP" >nul 2>&1 & goto ScanningPS2HDD ) else (
"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning for Playstation 2 HDDs:
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "!@hdl_path!" | "%~dp0BAT\busybox" grep "Playstation 2 HDD" >nul
if errorlevel 1 set "@hdl_path=" & goto ScanningPS2HDD
echo       [!@hdl_path! !@TotalHDD_Size! - !@ModelePS2HDD!]
)
	
"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Dump or Inject Header:
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1^) Yes Dump header
"%~dp0BAT\Diagbox" gd 0c
echo         2^) No
"%~dp0BAT\Diagbox" gd 0e
echo         3^) Yes Inject header
"%~dp0BAT\Diagbox" gd 07
echo\
CHOICE /C 123 /M "Select Option:"

IF %ERRORLEVEL%==1 set PPHeader=Dump
IF %ERRORLEVEL%==2 (goto HDDOSDPartManagement)
IF %ERRORLEVEL%==3 set PPHeader=Inject

echo\
echo\
echo Choose the partitions to display
echo ---------------------------------------------------
echo         1^) Partition PS1 Games
echo         2^) Partition PS2 Games
echo         3^) Partition APP Homebrew
echo         4^) Partition System
echo\
CHOICE /C 1234 /M "Select Option:"
IF !ERRORLEVEL!==1 set "ShowPartitionList=PS1 Games"
IF !ERRORLEVEL!==2 set "ShowPartitionList=PS2 Games"
IF !ERRORLEVEL!==3 set "ShowPartitionList=APP System"
IF !ERRORLEVEL!==4 set "ShowPartitionList=System"

"%~dp0BAT\Diagbox" gd 0e
cls
echo\
echo\
echo Scanning Partitions !ShowPartitionList!:
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0f

if "!ShowPartitionList!"=="PS1 Games" type "%~dp0BAT\__Cache\PARTITION_POPS_GAME.txt" | "%~dp0BAT\busybox" sort -k2 > "%~dp0TMP\PARTITION_!ShowPartitionList!.txt"
if "!ShowPartitionList!"=="PS2 Games" type "%~dp0BAT\__Cache\PARTITION_HDL_GAME.txt" | "%~dp0BAT\busybox" sort -k2 > "%~dp0TMP\PARTITION_!ShowPartitionList!.txt"
if "!ShowPartitionList!"=="APP System" type "%~dp0BAT\__Cache\PARTITION_APPS.txt" | "%~dp0BAT\busybox" sort -k2 > "%~dp0TMP\PARTITION_!ShowPartitionList!.txt"
if "!ShowPartitionList!"=="System" (

type "%~dp0BAT\__Cache\PARTITION_HDL_GAME.txt" | "%~dp0BAT\busybox" sed "s/^[^|]*|//g; s/__\./PP\./g" > "%~dp0TMP\PARTITION_HDL_GAME.txt"
"%~dp0BAT\busybox" grep -e "0x0001\|0x0100" "%~dp0BAT\__Cache\PARTITION_PS2HDD.txt" | "%~dp0BAT\busybox" sed "/\.POPS\./d; /PP.APPS-/d" | "%~dp0BAT\busybox" cut -c30-250 > "%~dp0TMP\PARTITION_!ShowPartitionList!.txt"
 
 for /f "usebackq" %%A in ("%~dp0TMP\PARTITION_!ShowPartitionList!.txt") do (
 "%~dp0BAT\busybox" grep "%%A" "%~dp0TMP\PARTITION_HDL_GAME.txt" >nul
	if errorlevel 1 (echo >nul) else ("%~dp0BAT\busybox" sed -i "/%%A/d" "%~dp0TMP\PARTITION_!ShowPartitionList!.txt")
	)
)
"%~dp0BAT\busybox" sed "s/|.*//" "%~dp0TMP\PARTITION_!ShowPartitionList!.txt" > "%~dp0TMP\PARTITION_TMP.txt" & type "%~dp0TMP\PARTITION_TMP.txt"

"%~dp0BAT\Diagbox" gd 0e
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0f

    if "!ShowPartitionList!"=="PS2 Games" echo NOTE: PFS partitions header with prefix PP. will be linked to the __. HDL partition automatically
    echo\
	"%~dp0BAT\Diagbox" gd 0e
	echo Please type the gameid ^+ GameName as shown in the Games List.
	"%~dp0BAT\Diagbox" gd 07
    set /p PartName=
    IF "!PartName!"=="" rmdir /Q/S "%~dp0TMP" >nul 2>&1 & (goto HDDOSDPartManagement)
	"%~dp0BAT\busybox" grep -Fx "!PartName!" "%~dp0TMP\PARTITION_TMP.txt" >nul
	if errorlevel 1 (set "PartName=!PartName!") else ("%~dp0BAT\busybox" grep -F -w -m 1 "!PartName!" "%~dp0TMP\PARTITION_!ShowPartitionList!.txt" | "%~dp0BAT\busybox" sed "s/^[^|]*|//" > "%~dp0TMP\PartName.txt" & set /P PartName=<"%~dp0TMP\PartName.txt")

"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Detecting !PartName!
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 07

    "%~dp0BAT\busybox" grep -w "!PartName!" "%~dp0TMP\PARTITION_!ShowPartitionList!.txt" | "%~dp0BAT\busybox" sed "s/^[^|]*|//" > "%~dp0TMP\PPSelected.txt" & set /P PPSELECTED=<"%~dp0TMP\PPSelected.txt"
	if "!PPSELECTED!"=="!PartName!" (
    "%~dp0BAT\Diagbox" gd 0a
	echo         Partition Detected
	"%~dp0BAT\Diagbox" gd 07
	) else (
	"%~dp0BAT\Diagbox" gd 0c
	echo         Partition NOT Detected
	echo\
	echo\
	"%~dp0BAT\Diagbox" gd 07
	rmdir /Q/S "%~dp0TMP" >nul 2>&1
	pause & (goto HDDOSDPartManagement)
	)
	
echo\
echo\
pause

REM Check if PFS Part exist
"%~dp0BAT\busybox" grep "0x0100" "%~dp0BAT\__Cache\PARTITION_PS2HDD.txt" | "%~dp0BAT\busybox" grep -o "PP.!PartName:~3!" > "%~dp0TMP\PartPFS.txt" & set /P PartPFS=<"%~dp0TMP\PartPFS.txt"
if defined PartPFS set PartName=PP.!PartName:~3!

if !PPHeader!==Dump (
set size=0
for /f "tokens=*" %%x in ('dir /s /a /b %1') do set /a size+=%%~zx

    if !size! GTR 1 set noempty=yes
	if defined noempty (
	echo\
	echo\
	"%~dp0BAT\Diagbox" gd 06
    echo Warning Files exist, they will be overwritten
	"%~dp0BAT\Diagbox" gd 0f
	choice /c YN /M "Do you want to continue?:"
	if !errorlevel!==1 (rmdir /Q/S "%~dp0HDD-OSD\PP.HEADER" >nul 2>&1) else (goto HDDOSDPartManagement)
	)

cls
echo\
echo\
echo Dump !PartName! Header:
echo ---------------------------------------------------
echo\

	echo         Extraction Header...
	REM HDL Header
	"%~dp0BAT\hdl_dump_fix_header" dump_header !@hdl_path! "!PartName!" >nul 2>&1
	
	REM PFS Header
    cd "%~dp0TMP"
	echo         Extraction PFS Resources...
	echo device !@pfsshell_path! > "%~dp0TMP\pfs-log.txt"
	echo mount "!PartName!" >> "%~dp0TMP\pfs-log.txt"
	echo cd res >> "%~dp0TMP\pfs-log.txt"
	echo ls -l >> "%~dp0TMP\pfs-log.txt"
	echo umount >> "%~dp0TMP\pfs-log.txt"
	echo exit >> "%~dp0TMP\pfs-log.txt"
	type "%~dp0TMP\pfs-log.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" grep -i -e "-rw-" -e "-rwx" | "%~dp0BAT\busybox" cut -c42-500 > "%~dp0TMP\pfs-tmp.log"

	echo device !@pfsshell_path! > "%~dp0TMP\pfs-log.txt"
	echo mount "!PartName!" >> "%~dp0TMP\pfs-log.txt"
	echo mkdir res >> "%~dp0TMP\pfs-log.txt"
	echo cd res >> "%~dp0TMP\pfs-log.txt"
	echo mkdir image >> "%~dp0TMP\pfs-log.txt"
	echo cd image >> "%~dp0TMP\pfs-log.txt"
	echo ls -l >> "%~dp0TMP\pfs-log.txt"
	echo umount >> "%~dp0TMP\pfs-log.txt"
	echo exit >> "%~dp0TMP\pfs-log.txt"
	type "%~dp0TMP\pfs-log.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" grep -i -e "-rw-" -e "-rwx" | "%~dp0BAT\busybox" cut -c42-500 > "%~dp0TMP\pfs-tmp2.log"

	echo device !@pfsshell_path! > "%~dp0TMP\pfs-header.txt"
	echo mount "!PartName!" >> "%~dp0TMP\pfs-header.txt"
	echo lcd "%~dp0HDD-OSD\PP.HEADER\PFS" >> "%~dp0TMP\pfs-header.txt"
	echo get BOOT.ELF >> "%~dp0TMP\pfs-header.txt"
	echo get EXECUTE.ELF >> "%~dp0TMP\pfs-header.txt"
	echo get EXECUTE.KELF >> "%~dp0TMP\pfs-header.txt"
	
	echo cd res >> "%~dp0TMP\pfs-header.txt"
	mkdir "%~dp0HDD-OSD\PP.HEADER\PFS\res" >nul 2>&1
	echo lcd "%~dp0HDD-OSD\PP.HEADER\PFS\res" >> "%~dp0TMP\pfs-header.txt"
	for /f "tokens=*" %%f in (pfs-tmp.log) do (echo get "%%f" >> "%~dp0TMP\pfs-header.txt")
	
	echo cd image >> "%~dp0TMP\pfs-header.txt"
	mkdir "%~dp0HDD-OSD\PP.HEADER\PFS\res\image" >nul 2>&1
	echo lcd "%~dp0HDD-OSD\PP.HEADER\PFS\res\image" >> "%~dp0TMP\pfs-header.txt"
	for /f "tokens=*" %%f in (pfs-tmp2.log) do (echo get "%%f" >> "%~dp0TMP\pfs-header.txt")
	
	echo umount >> "%~dp0TMP\pfs-header.txt"
	echo exit >> "%~dp0TMP\pfs-header.txt"
	type "%~dp0TMP\pfs-header.txt" | "%~dp0BAT\pfsshell" >nul 2>&1
	echo         Extracted ^> HDD-OSD\PP.HEADER\
	echo         Completed...
	)

if !PPHeader!==Inject (
cls
echo\
echo\
echo Inject !PartName! Header:
echo ---------------------------------------------------
echo\

	echo         Inject Header...
	REM HDL Header
	"%~dp0BAT\hdl_dump_fix_header" modify_header !@hdl_path! "!PartName!" >nul 2>&1
	if defined PartPFS (
	ren system.cnf system.cnf~
	"%~dp0BAT\hdl_dump_fix_header" modify_header !@hdl_path! "__.!PartName:~3!" >nul 2>&1
	ren system.cnf~ system.cnf
	)
	
	echo         Inject PFS Resources...
	cd /d "%~dp0HDD-OSD\PP.HEADER\PFS"
	echo device !@pfsshell_path! > "%~dp0TMP\pfs-headerbbn.txt"
	echo mount "!PartName!" >> "%~dp0TMP\pfs-headerbbn.txt"
	echo lcd "%~dp0HDD-OSD\PP.HEADER\PFS\" >> "%~dp0TMP\pfs-headerbbn.txt"
	echo rm BOOT.ELF >> "%~dp0TMP\pfs-headerbbn.txt"
	echo rm EXECUTE.ELF >> "%~dp0TMP\pfs-headerbbn.txt"
	echo rm EXECUTE.KELF >> "%~dp0TMP\pfs-headerbbn.txt"
    for %%0 in (*.elf *.kelf) do (echo put "%%0") >> "%~dp0TMP\pfs-headerbbn.txt"
	echo mkdir res >> "%~dp0TMP\pfs-headerbbn.txt"
	echo cd res >> "%~dp0TMP\pfs-headerbbn.txt"
	
	cd /d "%~dp0HDD-OSD\PP.HEADER\PFS\res"
	echo lcd "%~dp0HDD-OSD\PP.HEADER\PFS\res" >> "%~dp0TMP\pfs-headerbbn.txt"
	for %%0 in (*) do (echo put "%%0") >> "%~dp0TMP\pfs-headerbbn.txt"

	REM RESSOURCE DIR (PP.NAME\res\image\)
	for /D %%x in (*) do (
	echo mkdir "%%x" >> "%~dp0TMP\pfs-headerbbn.txt"
	echo lcd "%%x" >> "%~dp0TMP\pfs-headerbbn.txt"
 	echo cd "%%x" >> "%~dp0TMP\pfs-headerbbn.txt"
 	cd "%%x"

	REM RESSOURCE DIR (PP.NAME\res\image\files.xxx)
 	for %%1 in (*) do (echo put "%%1") >> "%~dp0TMP\pfs-headerbbn.txt"
	
	echo lcd .. >> "%~dp0TMP\pfs-headerbbn.txt"
	echo cd .. >> "%~dp0TMP\pfs-headerbbn.txt"
	cd ..
	)
	
	REM UNMOUNT OPL
	echo umount >> "%~dp0TMP\pfs-headerbbn.txt"
	echo exit >> "%~dp0TMP\pfs-headerbbn.txt"
	type "%~dp0TMP\pfs-headerbbn.txt" | "%~dp0BAT\pfsshell" >nul 2>&1
	echo         Completed...
	)

cd "%~dp0" & rmdir /Q/S "%~dp0TMP" >nul 2>&1

echo\
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo Completed...
echo\
echo\
"%~dp0BAT\Diagbox" gd 07

pause & (goto HDDOSDPartManagement)
REM ####################################################################################################################################################
:DownloadARTChoice
cls
mkdir "%~dp0TMP" >nul 2>&1
mkdir "%~dp0ART" >nul 2>&1
cd /d "%~dp0TMP"

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Download ARTs:
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1^) Yes ^(For PS2 Games^)
"%~dp0BAT\Diagbox" gd 0c
echo         2^) No
"%~dp0BAT\Diagbox" gd 0e
echo         3^) Yes ^(For PS1 Games^)
echo\
"%~dp0BAT\Diagbox" gd 07
CHOICE /C 123 /M "Select Option:"

IF %ERRORLEVEL%==1 set "ARTType=PS2"
IF %ERRORLEVEL%==2 (goto DownloadsMenu)
IF %ERRORLEVEL%==3 set "ARTType=PS1"

echo\
"%~dp0BAT\Diagbox" gd 0e
echo What device will you be using^?
"%~dp0BAT\Diagbox" gd 07
echo 1 = HDD ^(Internal^)
echo 2 = USB
CHOICE /C 12 /M "Select Option:"
if errorlevel 1 set "device=HDD" & set "HDDPFS=Yes"
if errorlevel 2 (

set "device=USB" & set "HDDPFS="
echo\
"%~dp0BAT\Diagbox" gd 0e
echo Do you want to change the default directory^?
"%~dp0BAT\Diagbox" gd 07
echo ^(Useful if your games are on another hard drive^)
CHOICE /C YN
echo\

if !errorlevel!==1 (
echo Example: E:\
set /p "HDDPATH=Enter the letter drive:"
if "!HDDPATH!"=="" set HDDPATH=%~dp0
  )
)
if not defined HDDPATH set HDDPATH=%~dp0

cls
if !HDDPFS!==Yes (
IF NOT DEFINED @hdl_path ( rmdir /Q/S "%~dp0TMP" >nul 2>&1 & goto ScanningPS2HDD ) else (
"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning for Playstation 2 HDDs:
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "!@hdl_path!" | "%~dp0BAT\busybox" grep "Playstation 2 HDD" >nul
if errorlevel 1 set "@hdl_path=" & goto ScanningPS2HDD
echo       [!@hdl_path! !@TotalHDD_Size! - !@ModelePS2HDD!]
 )
)

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Download ARTs for all !ARTType! installed games^?
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1^) Yes ^(Update Missing ART^)
"%~dp0BAT\Diagbox" gd 0c
echo         2^) No
"%~dp0BAT\Diagbox" gd 0e
echo         3^) Yes ^(Replace ART^)
"%~dp0BAT\Diagbox" gd 07
echo\
CHOICE /C 123 /M "Select Option:"

IF !ERRORLEVEL!==1 set UpdateOnlyMissingART=Yes
IF !ERRORLEVEL!==2 (goto DownloadsMenu)
IF !ERRORLEVEL!==3 set UpdateOnlyMissingART=No

if !ARTType!==PS1 (
echo\
"%~dp0BAT\Diagbox" gd 0e
echo Do you want to download the ARTs for PS1 shortcuts for OPL APPS TAB^?
"%~dp0BAT\Diagbox" gd 07
CHOICE /C YN
if errorlevel 1 set "OPLAPPSTAB=Yes" 
if errorlevel 2 set "OPLAPPSTAB=No" 
)

if !HDDPFS!==Yes (
echo\
"%~dp0BAT\Diagbox" gd 0e
echo Do you want to transfer the ARTs to the OPL Resources Partition after the update^?
"%~dp0BAT\Diagbox" gd 0f
CHOICE /C yn /M "Select Option:"
IF !ERRORLEVEL!==1 set "TransferART=Yes"
IF !ERRORLEVEL!==2 set "TransferART=No"
)

rem echo\
rem "%~dp0BAT\Diagbox" gd 0e
rem echo Do you want to delete unused ART^?
rem "%~dp0BAT\Diagbox" gd 07
rem CHOICE /C YN
rem if errorlevel 1 set "CleanUnusedART=Yes" 
rem if errorlevel 2 set "CleanUnusedART=No" 

if /i exist "%~dp0ART.zip" (
echo\
"%~dp0BAT\Diagbox" gd 0e
echo ART.zip detected do you want use it^?
"%~dp0BAT\Diagbox" gd 0f
CHOICE /C YN /M "Select Option:"
IF ERRORLEVEL 1 set uselocalART=yes
IF ERRORLEVEL 2 set uselocalART=no
) else (set uselocalART=no)

if !uselocalART!==no (
    echo\
	echo Checking internet Or Website connection... For ART
	ping -n 1 -w 2000 archive.org >nul
	if errorlevel 1 (
			"%~dp0BAT\Diagbox" gd 0c
			echo Unable to PING^^!
			if /i exist "%~dp0ART.zip" set uselocalART=yes
			"%~dp0BAT\Diagbox" gd 07
			) else (

	"%~dp0BAT\wget" -q --show-progress "https://archive.org/download/OPLM_ART_2024_09/OPLM_ART_2024_09.zip/PS1%%2FSCES_000.01%%2FSCES_000.01_COV.png" -O "%~dp0TMP\SCES_000.01_COV.png" >nul 2>&1
	for %%F in (SCES_000.01_COV.png) do if %%~zF==0 del "%%F"

if not exist SCES_000.01_COV.png (
"%~dp0BAT\Diagbox" gd 0c
    echo\
	echo Unable to connect to internet Or Website
	if /i exist "%~dp0ART.zip" (set uselocalART=yes) else (echo\ & echo\ & "%~dp0BAT\Diagbox" gd 0f & pause & goto DownloadsMenu)
	echo You will switch to offline mode
	echo\
	echo\
"%~dp0BAT\Diagbox" gd 0f
	pause
		) else (set DownloadART=yes)
	)
)

if !HDDPFS!==Yes (
"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Detecting OPL Resources Partition:
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0f

    "%~dp0BAT\busybox" grep -ow "!OPLPART!" "%~dp0BAT\__Cache\PARTITION_PS2HDD.txt" > "%~dp0TMP\hdd-prt.txt" & set /P @hdd_avl=<"%~dp0TMP\hdd-prt.txt"
	
	IF "!@hdd_avl!"=="!OPLPART!" (
	"%~dp0BAT\Diagbox" gd 0a
		echo            !OPLPART! - Partition Detected
	"%~dp0BAT\Diagbox" gd 0f
		) else (
		"%~dp0BAT\Diagbox" gd 0c
		echo         !OPLPART! - Partition NOT Detected
		echo             Partition Must Be Created
		echo\
		echo\
		"%~dp0BAT\Diagbox" gd 0f
		rmdir /Q/S "%~dp0TMP" >nul 2>&1
		pause & (goto DownloadARTChoice)
		)

if !ARTType!==PS1 (
"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Detecting POPS Partition:
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0f

    "%~dp0BAT\busybox" grep -o "__.POPS\|__.POPS[0-9]" "%~dp0BAT\__Cache\PARTITION_PS2HDD.txt" > "%~dp0TMP\POPSPART.txt" & set /P @POPSPART=<"%~dp0TMP\POPSPART.txt"

    if defined @POPSPART (
    "%~dp0BAT\Diagbox" gd 0a
    echo        	    Partition - Detected
	"%~dp0BAT\Diagbox" gd 07
	) else (
	"%~dp0BAT\Diagbox" gd 0c
	echo              No POPS partition detected
	echo               Partition Must Be Created
	echo\
	echo\
	"%~dp0BAT\Diagbox" gd 07
	rmdir /Q/S "%~dp0TMP" >nul 2>&1
	pause & (goto DownloadARTChoice)
	)
  
echo\
echo\
pause
	)
)

"%~dp0BAT\Diagbox" gd 0e
cls
echo\
echo\
echo Scanning Games List:
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 03

if !ARTType!==PS1 (
	
	if !device!==HDD (
	
	for /f "usebackq tokens=*" %%p in ("%~dp0TMP\POPSPART.txt") do (
	set POPSPART=%%p
	echo device !@pfsshell_path! > "%~dp0TMP\pfs-pops.txt"
	echo mount !POPSPART! >> "%~dp0TMP\pfs-pops.txt"
	echo ls >> "%~dp0TMP\pfs-pops.txt"
	echo umount >> "%~dp0TMP\pfs-pops.txt"
    echo exit >> "%~dp0TMP\pfs-pops.txt"
	type "%~dp0TMP\pfs-pops.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" grep -ie ".*\.VCD$" | "%~dp0BAT\busybox" grep -ie "[A-Z][A-Z][A-Z][A-Z]_[0-9][0-9][0-9]\.[0-9][0-9]" | "%~dp0BAT\busybox" sed -E "s/\.[^.]*$//g; s/([A-Z]+_[0-9]+\.[0-9]+)\./\1 /" >> "%~dp0TMP\!ARTType!Games.txt"
	 )
	)
	
	if !device!==USB (
	cd /d "!HDDPATH!\POPS"
	for %%P in (*.VCD) do (
     
	setlocal DisableDelayedExpansion
	set Gamename=%%~nP
	set filename=%%~nP.VCD
    set "gameid="
	setlocal EnableDelayedExpansion
	
    REM Get gameid
    "%~dp0BAT\UPSX_SID" "!filename!" -1 > "%~dp0TMP\gameid.txt" & set /p gameid=<"%~dp0TMP\gameid.txt"
	echo !gameid! !Gamename!>> "%~dp0TMP\!ARTType!Games.txt"
		endlocal
	endlocal
		)
	)
)

if !ARTType!==PS2 (
if !device!==HDD "%~dp0BAT\busybox" sed "s/|.*//" "%~dp0BAT\__Cache\PARTITION_HDL_GAME.txt" > "%~dp0TMP\!ARTType!Games.txt"
if !device!==USB (

if defined HDDPATH (
    set filepath="!HDDPATH!\DVD\*.iso" "!HDDPATH!\DVD\*.cue" "!HDDPATH!\CD\*.iso" "!HDDPATH!\CD\*.cue"
) else (
    set filepath="%~dp0DVD\*.iso" "%~dp0DVD\*.cue" "%~dp0CD\*.iso" "%~dp0CD\*.cue"
)
for %%f in (!filepath!) do (
    
	setlocal DisableDelayedExpansion
	set Gamename=%%~nf
	set filename=%%f
	setlocal EnableDelayedExpansion
	
    "%~dp0BAT\hdl_dump" cdvd_info2 "!filename!" > "%~dp0TMP\cdvd_info.txt"
	for /f "usebackq tokens=1,2,3,4,5*" %%i in ("%~dp0TMP\cdvd_info.txt") do (
	REM Get gameid
	"%~dp0BAT\busybox" grep -o -m 1 "[A-Z][A-Z][A-Z][A-Z][_][0-9][0-9][0-9]\.[0-9][0-9]" "%~dp0TMP\cdvd_info.txt" > "%~dp0TMP\game_serial_id.txt" & set /P gameid=<"%~dp0TMP\game_serial_id.txt"
	echo !gameid! !Gamename!>> "%~dp0TMP\!ARTType!Games.txt"
	)
	endlocal
endlocal
)
REM ULE Format
if exist "!HDDPATH!\ul.cfg" "%~dp0BAT\busybox" grep "[[:print:]]" "!HDDPATH!\ul.cfg" | "%~dp0BAT\busybox" sed "N;s/\n/ /g; s/\(.*\) \(.*\) \(.*\)/\3 \1 \2/" | "%~dp0BAT\busybox" cut -c4-150 >> "%~dp0TMP\!ARTType!Games.txt"
	)
)

type "%~dp0TMP\!ARTType!Games.txt" | "%~dp0BAT\busybox" sort -k2 & "%~dp0BAT\busybox" sed -i "s/ *$//g" "%~dp0TMP\!ARTType!Games.txt"
"%~dp0BAT\Diagbox" gd 0e
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0f

IF NOT EXIST "!HDDPATH!\ART"  MD "!HDDPATH!\ART"
dir "!HDDPATH!\ART" /b /a-d 2>&1| "%~dp0BAT\busybox" grep -ie ".png" -ie ".jpg" > "%~dp0TMP\ARTFiles.txt"

if !HDDPFS!==Yes (
if !UpdateOnlyMissingART!==Yes (
"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Scanning Artwork Files:
"%~dp0BAT\Diagbox" gd 0e
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0f

    echo         Scanning ARTs Files... !OPLPART!
    echo device !@pfsshell_path! > "%~dp0TMP\pfs-log.txt"
    echo mount !OPLPART! >> "%~dp0TMP\pfs-log.txt"
	if defined CUSTOM_OPLPART echo mkdir OPL >> "%~dp0TMP\pfs-log.txt"
    if defined CUSTOM_OPLPART echo cd OPL >> "%~dp0TMP\pfs-log.txt"
    echo cd ART >> "%~dp0TMP\pfs-log.txt"
    echo ls >> "%~dp0TMP\pfs-log.txt"
    echo cd .. >> "%~dp0TMP\pfs-log.txt"
    echo umount >> "%~dp0TMP\pfs-log.txt"
    echo exit >> "%~dp0TMP\pfs-log.txt"
    type "%~dp0TMP\pfs-log.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" grep -ie ".png" -ie ".jpg" > "%~dp0TMP\ARTFiles.txt"
    echo         Completed...

"%~dp0BAT\Diagbox" gd 0e
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0f
 )
)

for /f "usebackq tokens=1*" %%A in ("%~dp0TMP\!ARTType!Games.txt") do (
    
	setlocal DisableDelayedExpansion
	set Gamename=%%B
    set Gameid=%%A
	setlocal EnableDelayedExpansion

	echo\
    echo !Gamename!
	echo !Gameid!
    
	md "%~dp0TMP\!ARTType!\!Gameid!" >nul 2>&1
	echo !Gameid!_COV.png> "%~dp0TMP\art-tmp.txt"
	echo !Gameid!_COV2.png>> "%~dp0TMP\art-tmp.txt"
	echo !Gameid!_ICO.png>> "%~dp0TMP\art-tmp.txt"
	echo !Gameid!_LAB.png>> "%~dp0TMP\art-tmp.txt"
	echo !Gameid!_LGO.png>> "%~dp0TMP\art-tmp.txt"
	echo !Gameid!_BG_00.png>> "%~dp0TMP\art-tmp.txt"
	echo !Gameid!_SCR_00.png>> "%~dp0TMP\art-tmp.txt"
	echo !Gameid!_SCR_01.png>> "%~dp0TMP\art-tmp.txt"
	
	for /f "usebackq tokens=*" %%C in ("%~dp0TMP\art-tmp.txt") do (
	set ART_NAME=%%C
	set ART_NAME2=%%~nC
	
	if !ART_NAME2!==!Gameid!_BG_00 set ART_NAME2=!Gameid!_BG
    if !ART_NAME2!==!Gameid!_SCR_00 set ART_NAME2=!Gameid!_SCR
	if !ART_NAME2!==!Gameid!_SCR_01 set ART_NAME2=!Gameid!_SCR2
	
	REM FOR OPL APPS
	if !OPLAPPSTAB!==Yes (if !device!==USB (set ART_NAME2=XX.!Gamename!.ELF!ART_NAME2:~11!) else (set ART_NAME2=!Gameid!.!Gamename!.ELF!ART_NAME2:~11!))
	
	REM Replace with new ART
    if !UpdateOnlyMissingART!==No type nul> "%~dp0TMP\ARTFiles.txt" & del "!HDDPATH!\ART\!ART_NAME2!.png" >nul 2>&1
	
	"%~dp0BAT\busybox" grep -ow "!ART_NAME2!.png" "%~dp0TMP\ARTFiles.txt" >nul
	if errorlevel 1 (
	
	REM Custom gameid ART
	"%~dp0BAT\7-Zip\7z" e -bso0 "%~dp0BAT\ART_CUSTOM_GAMEID.zip" -o"%~dp0TMP\!ARTType!\!Gameid!" !ARTType!\!ART_NAME! -r -y >nul 2>&1
	
	if !uselocalART!==no (
	"%~dp0BAT\wget" -q --show-progress "https://archive.org/download/OPLM_ART_2024_09/OPLM_ART_2024_09.zip/!ARTType!%%2F!Gameid!%%2F!ART_NAME!" -O "%~dp0TMP\!ARTType!\!Gameid!\!ART_NAME!"
	) else (
	"%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0ART.zip" -o"%~dp0TMP" !ARTType!\!Gameid!\!ART_NAME! -r -y
	)
	
	for %%F in ("%~dp0TMP\!ARTType!\!Gameid!\!ART_NAME!") do if %%~zF==0 (
	del "%~dp0TMP\!ARTType!\!Gameid!\!ART_NAME!" >nul 2>&1
	) else (
	move "%~dp0TMP\!ARTType!\!Gameid!\!ART_NAME!" "!HDDPATH!\ART\!ART_NAME2!.png" >nul 2>&1
	"%~dp0BAT\Diagbox" gd 06
	if not exist "!HDDPATH!\ART\!ART_NAME2!.png" echo !ART_NAME! Not found in database
	"%~dp0BAT\Diagbox" gd 0f
		)
	)
)
rmdir /Q/S "%~dp0TMP\!ARTType!\!Gameid!" >nul 2>&1
 
 endlocal
endlocal
)

if !HDDPFS!==Yes (
if !TransferART!==Yes (
echo\
"%~dp0BAT\Diagbox" gd 0e
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0f

	cd "%~dp0ART"
	echo         Creating Que
	echo device !@pfsshell_path! > "%~dp0TMP\pfs-art.txt"
	echo mount !OPLPART! >> "%~dp0TMP\pfs-art.txt"
    if defined CUSTOM_OPLPART echo mkdir OPL >> "%~dp0TMP\pfs-art.txt"
    if defined CUSTOM_OPLPART echo cd OPL >> "%~dp0TMP\pfs-art.txt"
	echo mkdir ART >> "%~dp0TMP\pfs-art.txt"
	echo cd ART >> "%~dp0TMP\pfs-art.txt"
	
	for %%f in (*) do (
	setlocal DisableDelayedExpansion
	set ARTName=%%f
	setlocal EnableDelayedExpansion
	echo put "!ARTName!">> "%~dp0TMP\pfs-art.txt"
		endlocal
	endlocal
	)
	
	echo ls -l >> "%~dp0TMP\pfs-art.txt"
	echo umount >> "%~dp0TMP\pfs-art.txt"
	echo exit >> "%~dp0TMP\pfs-art.txt"

	echo         Installing Que
	type "%~dp0TMP\pfs-art.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" grep -ie ".png" -ie ".jpg" > "%~dp0LOG\PFS-ART.log"
	
"%~dp0BAT\Diagbox" gd 0e
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0f
 )
)

cd /d "%~dp0" & rmdir /Q/S "%~dp0TMP" >nul 2>&1

echo\
echo\
"%~dp0BAT\Diagbox" gd 0f
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo Downloading completed...
echo\
echo\
"%~dp0BAT\Diagbox" gd 07

pause & (goto DownloadsMenu)
REM ##########################################################################################################################################################################
:DownloadCFG
cls
mkdir "%~dp0CFG" >nul 2>&1
mkdir "%~dp0TMP" >nul 2>&1
cd /d "%~dp0TMP"

echo\
echo\
echo What device will you be using^?
echo 1 = HDD ^(Internal^)
echo 2 = USB
CHOICE /C 12 /M "Select Option:"
IF !ERRORLEVEL!==1 set "device=HDD"
IF !ERRORLEVEL!==2 (

set device=USB
echo\
"%~dp0BAT\Diagbox" gd 0e
echo Do you want to change the default directory^?
"%~dp0BAT\Diagbox" gd 07
echo ^(Useful if your games are on another hard drive^)
CHOICE /C YN
echo\

if !errorlevel!==1 (
echo Example: E:\
set /p "HDDPATH=Enter the letter drive:"
if "!HDDPATH!"=="" set HDDPATH=%~dp0) else (set HDDPATH=%~dp0)
)
if not defined HDDPATH set HDDPATH=%~dp0

cls
if !device!==HDD (
IF NOT DEFINED @hdl_path ( rmdir /Q/S "%~dp0TMP" >nul 2>&1 & goto ScanningPS2HDD ) else (
"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning for Playstation 2 HDDs:
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "!@hdl_path!" | "%~dp0BAT\busybox" grep "Playstation 2 HDD" >nul
if errorlevel 1 set "@hdl_path=" & goto ScanningPS2HDD
echo       [!@hdl_path! !@TotalHDD_Size! - !@ModelePS2HDD!]
	)
)

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Download/Update CFG for All games installed^?
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1^) Yes
"%~dp0BAT\Diagbox" gd 0c
echo         2^) No
"%~dp0BAT\Diagbox" gd 07
echo\
CHOICE /C 12 /M "Select Option:"
IF !ERRORLEVEL!==1 set @Downloadcfg=Yes
IF !ERRORLEVEL!==2 (goto DownloadsMenu)

if not exist "%~dp0BAT\TitlesDB\TitlesDB_PS2_!TitlesLang!.txt" set "TitlesLang=English"

echo\
echo\
"%~dp0BAT\Diagbox" gd 0e
echo Do you want to apply compatibility modes^? [Yes recommended]
"%~dp0BAT\Diagbox" gd 0f
echo This will improve compatibility with games that need certain modes to work properly
echo\
echo NOTE: That if a game is found in the database, the current compatibility settings will be overridden 
echo put no if you only want to update game infos
CHOICE /C yn /M "Select Option:"
IF !ERRORLEVEL!==1 set "Compatibility_mode=Yes"
IF !ERRORLEVEL!==2 set "Compatibility_mode=No"

echo\
"%~dp0BAT\Diagbox" gd 0e
echo Do you want to keep your game settings^?
"%~dp0BAT\Diagbox" gd 0f
echo Like: VMC, CHT
CHOICE /C yn /M "Select Option:"
IF !ERRORLEVEL!==1 set "KeepUserSettings=Yes"
IF !ERRORLEVEL!==2 set "KeepUserSettings=No"

if !device!==HDD (
echo\
"%~dp0BAT\Diagbox" gd 0e
echo Do you want to transfer the CFGs to the OPL Resources Partition after the update^?
"%~dp0BAT\Diagbox" gd 0f
CHOICE /C yn /M "Select Option:"
IF !ERRORLEVEL!==1 set "TransferCFG=Yes"
IF !ERRORLEVEL!==2 set "TransferCFG=No"

if !TransferCFG!==Yes (
"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Detecting OPL Resources Partition:
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0f

    "%~dp0BAT\busybox" grep -ow "!OPLPART!" "%~dp0BAT\__Cache\PARTITION_PS2HDD.txt" > "%~dp0TMP\hdd-prt.txt" & set /P @hdd_avl=<"%~dp0TMP\hdd-prt.txt"
	
	IF "!@hdd_avl!"=="!OPLPART!" (
	"%~dp0BAT\Diagbox" gd 0a
		echo            !OPLPART! - Partition Detected
	"%~dp0BAT\Diagbox" gd 0f
		) else (
		"%~dp0BAT\Diagbox" gd 0c
		echo         !OPLPART! - Partition NOT Detected
		echo             Partition Must Be Created
		echo\
		echo\
		"%~dp0BAT\Diagbox" gd 0f
		rmdir /Q/S "%~dp0TMP" >nul 2>&1
		pause & (goto DownloadCFG)
		)
	)
)
echo\
echo\
pause

REM Download Compatibility Database
"%~dp0BAT\wget" -q --show-progress "https://github.com/GDX-X/PS2-OPL-CFG-Compatibility-Database/releases/download/Latest/PS2-OPL-CFG-Compatibility-Database.7z" >nul 2>&1 -O "%~dp0TMP\PS2-OPL-CFG-Compatibility-Database.7z"
for %%F in ("%~dp0TMP\PS2-OPL-CFG-Compatibility-Database.7z") do if %%~zF==0 (del %%F >nul 2>&1) else (move "%~dp0TMP\PS2-OPL-CFG-Compatibility-Database.7z" "%~dp0BAT" >nul 2>&1)

REM Some parameter to avoid conflicts with busybox
md "%~dp0TMP\!DBLang!" >nul 2>&1
md "%~dp0TMP\UserSetting" >nul 2>&1
IF NOT EXIST "%~dp0CFG" MD "%~dp0CFG"

copy "%~dp0BAT\TitlesDB\TitlesDB_PS2_!TitlesLang!.txt" "%~dp0TMP\TitlesDB_PS2_!TitlesLang!.txt" >nul 2>&1
"%~dp0BAT\busybox" sed -i "s/\&/\\\&/g" "%~dp0TMP\TitlesDB_PS2_!TitlesLang!.txt"
"%~dp0BAT\busybox" sed -i "s/\^!/\!/g" "%~dp0TMP\TitlesDB_PS2_!TitlesLang!.txt" >nul 2>&1
"%~dp0BAT\busybox" sed -i "s./.\\\/.g" "%~dp0TMP\TitlesDB_PS2_!TitlesLang!.txt"

"%~dp0BAT\Diagbox" gd 0e
cls
echo\
echo\
echo Scanning Games List
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 03

if !device!==HDD type "%~dp0BAT\__Cache\PARTITION_HDL_GAME.txt" | "%~dp0BAT\busybox" sed "s/|.*//" | "%~dp0BAT\busybox" sort -k2 > "%~dp0TMP\GameListPS2.txt"

if !device!==USB (
for %%f in ("!HDDPATH!\DVD\*.iso" "!HDDPATH!\CD\*.cue" "!HDDPATH!\CD\*.iso") do (
    
	setlocal DisableDelayedExpansion
	set Gamename=%%~nf
	set filename=%%f
	setlocal EnableDelayedExpansion
	
    "%~dp0BAT\hdl_dump" cdvd_info2 "!filename!" > "%~dp0TMP\cdvd_info.txt"
	for /f "usebackq tokens=1,2,3,4,5*" %%i in ("%~dp0TMP\cdvd_info.txt") do (
	REM Get gameid
	"%~dp0BAT\busybox" grep -o -m 1 "[A-Z][A-Z][A-Z][A-Z][_][0-9][0-9][0-9]\.[0-9][0-9]" "%~dp0TMP\cdvd_info.txt" > "%~dp0TMP\game_serial_id.txt" & set /P gameid=<"%~dp0TMP\game_serial_id.txt"
	echo !gameid!  !Gamename!>>"%~dp0TMP\PS2GamesTMP.txt" & "%~dp0BAT\busybox" sort -k2 "%~dp0TMP\PS2GamesTMP.txt" > "%~dp0TMP\GameListPS2.txt"
		)
		endlocal
	endlocal
	)
REM ULE Format
if exist "!HDDPATH!\ul.cfg" "%~dp0BAT\busybox" grep "[[:print:]]" "!HDDPATH!\ul.cfg" | "%~dp0BAT\busybox" sed "N;s/\n/ /g; s/\(.*\) \(.*\) \(.*\)/\3 \1 \2/" | "%~dp0BAT\busybox" cut -c4-150 >> "%~dp0TMP\GameListPS2.txt"
)

type "%~dp0TMP\GameListPS2.txt"

"%~dp0BAT\Diagbox" gd 0e
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0f

if !device!==HDD (
echo\
echo\
echo Extraction Configs Files:
echo ---------------------------------------------------
	 echo         Extraction CFGs Files... %OPLPART%
	 echo device !@pfsshell_path! > "%~dp0TMP\pfs-log.txt"
	 echo mount !OPLPART! >> "%~dp0TMP\pfs-log.txt"
	 if defined CUSTOM_OPLPART echo cd OPL >> "%~dp0TMP\pfs-log.txt"
	 echo mkdir CFG >> "%~dp0TMP\pfs-log.txt"
	 echo cd CFG >> "%~dp0TMP\pfs-log.txt"
	 echo ls >> "%~dp0TMP\pfs-log.txt"
	 echo cd .. >> "%~dp0TMP\pfs-log.txt"
     echo umount >> "%~dp0TMP\pfs-log.txt"
	 echo exit >> "%~dp0TMP\pfs-log.txt"
	 type "%~dp0TMP\pfs-log.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" grep -ie ".*\.cfg$" > "%~dp0TMP\pfs-tmp.log"

	 echo device !@pfsshell_path! > "%~dp0TMP\pfs-cfg.txt"
	 echo mount !OPLPART! >> "%~dp0TMP\pfs-cfg.txt"
	 if defined CUSTOM_OPLPART echo cd OPL >> "%~dp0TMP\pfs-cfg.txt"
	 echo cd CFG >> "%~dp0TMP\pfs-cfg.txt"
	 echo lcd "%~dp0CFG" >> "%~dp0TMP\pfs-cfg.txt"
	 for /f "tokens=*" %%f in (pfs-tmp.log) do (echo get "%%f" >> "%~dp0TMP\pfs-cfg.txt")
	 echo umount >> "%~dp0TMP\pfs-cfg.txt"
	 echo exit >> "%~dp0TMP\pfs-cfg.txt"
	 type "%~dp0TMP\pfs-cfg.txt" | "%~dp0BAT\pfsshell" >nul 2>&1
	 echo         Completed...
echo ---------------------------------------------------
)

    REM echo SLES_510.61 > GameListPS2.txt
    for /f "tokens=1*" %%i in (GameListPS2.txt) do (
	
	setlocal DisableDelayedExpansion
	set gameid=%%i
	set GameName=%%j
	set "dbtitle="
	set "Settings="
	setlocal EnableDelayedExpansion
	
	echo\
	echo\
	echo !GameName!
	echo !gameid!
	md "!HDDPATH!\CFG" >nul 2>&1
	
	"%~dp0BAT\Diagbox" gd 03
	REM Get Gameinfos in XML
	"%~dp0BAT\busybox" sed -n "/<game serial=\"!gameid:~0,4!-!gameid:~5,3!!gameid:~9,2!\">/{:a;N;/<\/game>/^!ba;s/.*<game serial=\"!gameid:~0,4!-!gameid:~5,3!!gameid:~9,2!\">\(.*\)<\/game>.*/\1/p}" "%~dp0BAT\PS2DB.xml" | "%~dp0BAT\busybox" sed -e "s/<\([^>]*\)>\([^<]*\)<\/\1>/\1=\2/g; s/<\([^>]*\) \/>/\1=/g; s/^[ \t]*//; s/[ \t]*$//; /^$/d" > "%~dp0TMP\!DBLang!\!gameid!.cfg"
	for %%F in ("%~dp0TMP\!DBLang!\!gameid!.cfg") do if %%~zF==0 del "%~dp0TMP\!DBLang!\!gameid!.cfg" >nul 2>&1 & "%~dp0BAT\7-Zip\7z" e -bso0 "%~dp0BAT\OPL-Games-Infos-Database-Project.7z" -o"%~dp0TMP\!DBLang!" EXAMPLE.cfg -r -y & ren "%~dp0TMP\!DBLang!\EXAMPLE.cfg" "!gameid!.cfg"

	if exist "%~dp0TMP\!DBLang!\!gameid!.cfg" echo 100%%%
	"%~dp0BAT\Diagbox" gd 0f
	
	REM Compatibility
	if !Compatibility_mode!==Yes "%~dp0BAT\7-Zip\7z" e -bso0 "%~dp0BAT\PS2-OPL-CFG-Compatibility-Database.7z" -o"%~dp0TMP\Compatibility" HDD\!gameid!.cfg -r -y >nul 2>&1
    
	del "%~dp0TMP\Settings.txt" >nul 2>&1
	if exist "!HDDPATH!\CFG\!gameid!.cfg" (
	REM "%~dp0BAT\busybox" grep -ie "^[$]" -ie "Modes=" "%~dp0CFG\!gameid!.cfg" | "%~dp0BAT\busybox" sed "s/=.*/=/" > "%~dp0TMP\Settings.txt" & set /P Settings=<"%~dp0TMP\Settings.txt"
	"%~dp0BAT\busybox" grep -ie "^[$]" -ie "Modes=" "!HDDPATH!\CFG\!gameid!.cfg" > "%~dp0TMP\Settings.txt" & set /P Settings=<"%~dp0TMP\Settings.txt"
	"%~dp0BAT\busybox" grep -v "!Settings!" "!HDDPATH!\CFG\!gameid!.cfg" > "%~dp0TMP\UserSetting\!gameid!.cfg"
	"%~dp0BAT\busybox" sed -i "/^^\$\|Modes=/d" "!HDDPATH!\CFG\!gameid!.cfg"
	)

	move "%~dp0TMP\!DBLang!\!gameid!.cfg" "!HDDPATH!\CFG\!gameid!.cfg" >nul 2>&1
	
	REM Game Title
    for /f "tokens=1*" %%A in ( 'findstr !gameid! "%~dp0TMP\TitlesDB_PS2_!TitlesLang!.txt"' ) do if not defined dbtitle set dbtitle=%%B
    if not defined dbtitle (
	
	echo "!GameName!"| "%~dp0BAT\busybox" sed -e "s/\&/\\\&/g; s./.\\\/.g" > "%~dp0TMP\dbtitle.txt"
    "%~dp0BAT\busybox" sed -i "s/\"//g" "%~dp0TMP\dbtitle.txt"
    set /P dbtitle=<"%~dp0TMP\dbtitle.txt"
	)
	REM if not defined dbtitle if exist "%~dp0CFG\!gameid!.cfg" "%~dp0BAT\busybox" grep "Title=" "%~dp0CFG\!gameid!.cfg" | "%~dp0BAT\busybox" sed "s/^.*=//" | "%~dp0BAT\busybox" iconv -f windows-1252 -t utf-8 > "%~dp0TMP\Title.txt" & set /P dbtitle=<"%~dp0TMP\Title.txt"
	
	if !gameid!==SLUG_202.73 set "dbtitle=Namco Museum 50th Anniversary"
	if !gameid!==SLUD_206.43 set "dbtitle=Namco Transmission v1.03"
	
	if defined dbtitle "%~dp0BAT\busybox" sed -i -e "s/\Title=.*/Title=/g; s/Title=/Title=!dbtitle!/g" "!HDDPATH!\CFG\!gameid!.cfg"
	
	REM Fix OPL Freeze cut the description to 255 characters max
	"%~dp0BAT\busybox" sed -i "s/Description=\(.\{1,254\}\).*/Description=\1/" "!HDDPATH!\CFG\!gameid!.cfg"
	
	REM Keep User Settings if no detect compatibility modes
	if !KeepUserSettings!==Yes (
	if not exist "%~dp0TMP\Compatibility\!gameid!.cfg" (
	if exist "%~dp0TMP\Settings.txt" "%~dp0BAT\busybox" grep -ie "^[$]" -ie "Modes=" "%~dp0TMP\Settings.txt" >> "!HDDPATH!\CFG\!gameid!.cfg"
	 )
	)
    
	if exist "%~dp0TMP\Compatibility\!gameid!.cfg" (
	"%~dp0BAT\busybox" grep -ie "^[$]" -ie "Modes=" "%~dp0TMP\Compatibility\!gameid!.cfg" >> "!HDDPATH!\CFG\!gameid!.cfg"
	)
 endlocal
endlocal
)

    if !TransferCFG!==Yes (
    echo\
    echo ---------------------------------------------------
	cd "%~dp0CFG"
	echo         Creating Que
	echo device !@pfsshell_path! > "%~dp0TMP\pfs-cfg.txt"
	echo mount !OPLPART! >> "%~dp0TMP\pfs-cfg.txt"
    if defined CUSTOM_OPLPART echo mkdir OPL >> "%~dp0TMP\pfs-cfg.txt"
    if defined CUSTOM_OPLPART echo cd OPL >> "%~dp0TMP\pfs-cfg.txt"
	echo mkdir CFG >> "%~dp0TMP\pfs-cfg.txt"
	echo cd CFG >> "%~dp0TMP\pfs-cfg.txt"
	for %%f in (*.cfg) do (
	echo rm %%f >> "%~dp0TMP\pfs-cfg.txt"  
	echo put %%f >> "%~dp0TMP\pfs-cfg.txt"
	)
	echo ls -l >> "%~dp0TMP\pfs-cfg.txt"
	echo umount >> "%~dp0TMP\pfs-cfg.txt"
	echo exit >> "%~dp0TMP\pfs-cfg.txt"

	echo         Installing Que
	type "%~dp0TMP\pfs-cfg.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" grep -ie ".*\.cfg$" > "%~dp0LOG\PFS-CFG.log"
	echo ---------------------------------------------------
    )

cd /d "%~dp0" & rmdir /Q/S "%~dp0TMP" >nul 2>&1

echo\
echo\
"%~dp0BAT\Diagbox" gd 0f
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo Updating completed...
echo\
echo\
"%~dp0BAT\Diagbox" gd 07

pause & (goto DownloadsMenu) 
REM ####################################################################################################################################################
:DumpCDDVD
cls
cd /d "%~dp0"
IF EXIST "%~dp0TMP" rmdir /Q/S "%~dp0TMP" >nul 2>&1
mkdir "%~dp0TMP" >nul 2>&1
cd /d "%~dp0TMP"
copy "%~dp0BAT\hdl_dump.exe" "%~dp0TMP" >nul 2>&1

"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning Optical Drives:
echo ---------------------------------------------------
    "%~dp0BAT\Diagbox" gd 03
    powershell -NoProfile -Command "Get-CimInstance -ClassName Win32_CDROMDrive | Select-Object Name, Drive, VolumeName"
    "%~dp0BAT\Diagbox" gd 07
    echo ---------------------------------------------------
    "%~dp0BAT\Diagbox" gd 06
	echo Prepare your DISC for DUMP
	echo\
	echo Please see Optical Disc Drive Compatibility to see which drives are compatible.
	echo Compatibility mainly concerns CD-ROMs containing several tracks Mainly PS1 games.
	echo\
	echo\
	"%~dp0BAT\Diagbox" gd 0e
	echo 	1. Enable Force Dump modes 1 (Use this option only if you cannot dump your PS1 Or PS2 CD-ROM)
	echo 	2. Enable Force Dump modes 2 (Use this option only if you cannot dump your PS2 DVD-ROM)
	"%~dp0BAT\Diagbox" gd 0f
	echo 	3. Check the compatibility of your optical drive
	echo 	4. More infos about Dumping Guides
	echo 	5. Refresh Optical Drive List
	echo\
	echo 	9. Back to main menu
	echo\
	echo\
	if not defined forcemodes set forcemodes=mode0
	
	if defined forcemodes (
	if %forcemodes%==mode1 (
	"%~dp0BAT\Diagbox" gd 0a
	echo Force modes 1 Enabled
    "%~dp0BAT\Diagbox" gd 06
	echo NOTE: With this option enabled If your game has multiple tracks, the md5 hash will not match the redump database. 
	echo Because it will be directly dumped in single .BIN Mainly for PS1 games
	"%~dp0BAT\Diagbox" gd 0f
	)
	"%~dp0BAT\Diagbox" gd 0a
	if %forcemodes%==mode2 ( echo Foce modes 2 Enabled )
	"%~dp0BAT\Diagbox" gd 07
	)
    
	set "choice="
	echo\
	echo Type Number or the letter of your Optical Drives. Example: D
    set /p choice="Select Option:"
	IF "!choice!"==""  (goto DumpCDDVD)
	IF "!choice!"=="1" set forcemodes=mode1 & (goto DumpCDDVD)
	IF "!choice!"=="2" set forcemodes=mode2 & (goto DumpCDDVD)
	IF "!choice!"=="3" start http://wiki.redump.org/index.php?title=DiscImageCreator:_Optical_Disc_Drive_Compatibility & goto DumpCDDVD
	IF "!choice!"=="4" start http://wiki.redump.org/index.php?title=Dumping_Guides & goto DumpCDDVD
	IF "!choice!"=="5" (goto DumpCDDVD)
    IF "!choice!"=="9" set "forcemodes=" & (goto GamesManagement)
    echo\
	echo\
	
    if !forcemodes!==mode0 (
	"%~dp0BAT\Diagbox" gd 0e
	echo Change max read speed^?
	echo By default, the max read speed will be 8
	"%~dp0BAT\Diagbox" gd 07
	CHOICE /C YN /M "Select Option:"
	if !errorlevel!==1 echo\ & set /p readspeed=Read Speed:
	if !errorlevel!==2 set readspeed=8
	IF "!readspeed!"=="" set "readspeed=" & (goto DumpCDDVD)
	)

powershell -NoProfile -Command "Get-CimInstance -ClassName Win32_CDROMDrive | Select-Object Name, Drive, VolumeName" | "%~dp0BAT\busybox" sed "/Caption/d" | "%~dp0BAT\busybox" grep -o [A-Z]: > "%~dp0TMP\DriveSelected.txt" & set /P @DriveSelected=<"%~dp0TMP\DriveSelected.txt"

"%~dp0BAT\DiscImageCreator\cdrdao.exe" scanbus 2> "%~dp0TMP\DriveIDTMP.txt"
"%~dp0BAT\busybox" cat "%~dp0TMP\DriveIDTMP.txt" | "%~dp0BAT\busybox" sed -e "1,2d" > "%~dp0TMP\DriveIDTMP2.txt"
"%~dp0BAT\busybox" paste -d " " "%~dp0TMP\DriveIDTMP2.txt" "%~dp0TMP\DriveSelected.txt" > "%~dp0TMP\DriveSelectedIDTMP.txt"

"%~dp0BAT\busybox" cat "%~dp0TMP\DriveSelectedIDTMP.txt" | "%~dp0BAT\busybox" grep -e "%choice%:" | "%~dp0BAT\busybox" cut -c0-6 | "%~dp0BAT\busybox" cut -c0-36 | "%~dp0BAT\busybox" sed -e "s/\s*$//g" > "%~dp0TMP\DriveSelectedID.txt" & set /P @DriveSelectedID=<"%~dp0TMP\DriveSelectedID.txt"

REM DETECT PS1 OR PS2 DISC
"%~dp0BAT\busybox" grep -o "BOOT" "%choice%:\SYSTEM.CNF" > "%~dp0TMP\MediaType.txt" & set /P MediaType1=<"%~dp0TMP\MediaType.txt"
"%~dp0BAT\busybox" grep -o "BOOT2" "%choice%:\SYSTEM.CNF" > "%~dp0TMP\MediaType.txt" & set /P MediaType2=<"%~dp0TMP\MediaType.txt"

if "%MediaType1%"=="BOOT"  (set Dump=PS1)
if "%MediaType2%"=="BOOT2" (set Dump=PS2)

if not defined Dump (
"%~dp0BAT\Diagbox" gd 06
cls
echo.
echo No CD or DVD detected into your optical drive
echo.
"%~dp0BAT\Diagbox" gd 0f
pause & (goto GamesManagement)
)

REM PS1 DISC
if %Dump%==PS1 (
cls
echo\
echo\
"%~dp0BAT\Diagbox" gd 03
echo Playstation 1 Disc Detected!
"%~dp0BAT\Diagbox" gd 07

if %forcemodes%==mode0 ("%~dp0BAT\DiscImageCreator\DiscImageCreator.exe" cd !choice! DUMPED_DATA.bin !readspeed! /c2 /nl )
if %forcemodes%==mode1 (
"%~dp0BAT\DiscImageCreator\cdrdao.exe" read-cd --read-raw --datafile DUMPED_DATA.bin --device %@DriveSelectedID% --driver generic-mmc-raw audiodata.toc
"%~dp0BAT\DiscImageCreator\toc2cue.exe" audiodata.toc DUMPED_DATA.cue >nul 2>&1
)

for %%x in (*.bin) do if %%~zx==0 del %%x
)

REM PS2 DISC
if %Dump%==PS2 (
cls
echo\
echo\
"%~dp0BAT\Diagbox" gd 03
echo Playstation 2 Disc Detected!
"%~dp0BAT\Diagbox" gd 07
echo -----------------------------------------------------------

echo list volume > "%~dp0TMP\Drive-log.txt"
type "%~dp0TMP\Drive-log.txt" | "diskpart" | "%~dp0BAT\busybox" grep -e "DVD-ROM" -e "CD-ROM" | "%~dp0BAT\busybox" cut -c0-16 | "%~dp0BAT\busybox" sed -e "s/$/:/" | "%~dp0BAT\busybox" grep -e "%choice%:" | "%~dp0BAT\busybox" grep -o "[0-9]" > "%~dp0TMP\DriveVolume.txt" & set /P @DriveVolume=<"%~dp0TMP\DriveVolume.txt"

for /f "tokens=1,2,3,4,5*" %%i in ('hdl_dump cdvd_info2 cd!@DriveVolume!:') do (
 
        set disctype=unknown
		if "%%i"=="CD" (set disctype=cd)
		if "%%i"=="DVD" (set disctype=dvd)
		if "%%i"=="dual-layer" (if "%%j"=="DVD" ( set disctype=dvd))
		if "!disctype!"=="unknown" (
		"%~dp0BAT\Diagbox" gd 0c
		echo	WARNING: Unable to determine disc type^!
	    "%~dp0BAT\Diagbox" gd 07
		)
      )

REM PS2 CD
if "!disctype!"=="cd" (

if %forcemodes%==mode0 ("%~dp0BAT\DiscImageCreator\DiscImageCreator.exe" cd !choice! DUMPED_DATA.bin !readspeed! /c2 /nl )
if %forcemodes%==mode1 (
"%~dp0BAT\DiscImageCreator\cdrdao.exe" read-cd --read-raw --datafile DUMPED_DATA.bin --device %@DriveSelectedID% --driver generic-mmc-raw audiodata.toc
"%~dp0BAT\DiscImageCreator\toc2cue.exe" audiodata.toc DUMPED_DATA.cue >nul 2>&1
)
if %forcemodes%==mode2 ("%~dp0TMP\hdl_dump" dump cd!@DriveVolume!: "DUMPED_DATA.iso")

for %%x in ( "DUMPED_DATA.bin" ) do if %%~zx==0 del %%x
)

REM PS2 DVD5, DVD9
if "!disctype!"=="dvd" (

if %forcemodes%==mode0 ("%~dp0BAT\DiscImageCreator\DiscImageCreator.exe" dvd !choice!: DUMPED_DATA.iso !readspeed!)
if %forcemodes%==mode2 ("%~dp0TMP\hdl_dump" dump cd!@DriveVolume!: "DUMPED_DATA.iso")

for %%x in (*.iso) do if %%~zx==0 del %%x
 )
)

if errorlevel 1 (
echo\
echo\
"%~dp0BAT\Diagbox" gd 0c
echo An error has occurred that may be due to the incompatibility of your optical drive.
echo Please try force mode 1 or mode 2 
echo\
pause & goto DumpCDDVD
)

IF EXIST "%~dp0LOG\DumpLOG" rmdir /Q/S "%~dp0LOG\DumpLOG" >nul 2>&1
md "%~dp0LOG\DumpLOG" >nul 2>&1
move "%~dp0TMP\DUMPED_DATA_DMI.bin" "%~dp0LOG\DumpLOG" >nul 2>&1
move "%~dp0TMP\DUMPED_DATA_PFI.bin" "%~dp0LOG\DumpLOG" >nul 2>&1
move "%~dp0TMP\*.txt" "%~dp0LOG\DumpLOG" >nul 2>&1

echo -----------------------------------------------------------
if %Dump%==PS2 (
"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Do you want to verify the MD5 hash of your dump with the redump database?
choice /c YN
)

IF %ERRORLEVEL%==1 (
REM if %Dump%==PS1 set gametype=PS1
if %Dump%==PS2 set gametype=PS2
set checkmd5dump=yes
goto checkMD5Hash) else (

if %Dump%==PS1 (set "DumpPS1=*.bin" & move "!DumpPS1!" "%~dp0POPS" >nul 2>&1 & move *.cue "%~dp0POPS"  >nul 2>&1 & echo Dumped.. ^>^> "\POPS\DUMPED_DATA.bin")
if %Dump%==PS2 (
if "!disctype!"=="cd" (set "DumpPS2=*.bin" & move "!DumpPS2!" "%~dp0CD" >nul 2>&1 & move *.cue "%~dp0CD"  >nul 2>&1 & echo Dumped.. ^>^> "\CD\DUMPED_DATA.bin")
if "!disctype!"=="dvd" (set "DumpPS2=*.iso" & move "!DumpPS2!" "%~dp0DVD" >nul 2>&1 & echo Dumped.. ^>^> "\DVD\DUMPED_DATA.iso")
 )
)

echo\
echo\
"%~dp0BAT\Diagbox" gd 0f
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo Dump Completed...
echo\
echo\
"%~dp0BAT\Diagbox" gd 07

pause & (goto GamesManagement)

REM ####################################################################################################################################################
:checkMD5Hash
cd /d "%~dp0"
cls

REM if not defined gametype (
REM "%~dp0BAT\Diagbox" gd 0e
REM echo\
REM echo\
REM echo What type of game do you want to check with the redump database?
REM 
REM echo 1. Playstation 1
REM echo 2. Playstation 2
REM 
REM choice /c 12
REM IF ERRORLEVEL 1 set gametype=PS1
REM IF ERRORLEVEL 2 set gametype=PS2
REM )

set gametype=PS2

echo\
"%~dp0BAT\Diagbox" gd 0e
echo Download Latest Redump Database^?
"%~dp0BAT\Diagbox" gd 07
echo NOTE: if you choose No, it will do an offline check.
choice /c YN 

IF ERRORLEVEL 1 set DownloadRedump=yes
IF ERRORLEVEL 2 set DownloadRedump=no

IF "!DownloadRedump!"=="no" (
if %gametype%==PS1 ( "%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0BAT\Dats\RedumpPS1.zip" -so > "%~dp0BAT\Dats\PS1\RedumpPS1.dat" )
if %gametype%==PS2 ( "%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0BAT\Dats\RedumpPS2.zip" -so > "%~dp0BAT\Dats\PS2\RedumpPS2.dat" )
)

IF "!DownloadRedump!"=="yes" (
	echo\
    echo Checking internet connection...
	Ping www.redump.org -n 1 -w 1000 >nul
	
	if errorlevel 1 (
    "%~dp0BAT\Diagbox" gd 0c
    echo.
	echo Unable to connect to internet Or Website
	echo\
	echo You will switch to offline mode
	echo\
	set DownloadRedump=no
	"%~dp0BAT\Diagbox" gd 0f
	pause
	)

"%~dp0BAT\Diagbox" gd 0d
if %gametype%==PS1 (
"%~dp0BAT\wget" -q --show-progress http://redump.org/datfile/psx/ -O "%~dp0BAT\Dats\RedumpPS1.zip" 
"%~dp0BAT\wget" -q --show-progress http://redump.org/cues/psx/ -O "%~dp0BAT\Dats\RedumpCUEPS1.zip"
timeout 2 >nul
"%~dp0BAT\Diagbox" gd 0f
"%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0BAT\Dats\RedumpPS1.zip" -so > "%~dp0BAT\Dats\PS1\RedumpPS1.dat"
)

"%~dp0BAT\Diagbox" gd 0d
if %gametype%==PS2 (
"%~dp0BAT\wget" -q --show-progress http://redump.org/datfile/ps2/ -O "%~dp0BAT\Dats\RedumpPS2.zip"
"%~dp0BAT\wget" -q --show-progress http://redump.org/cues/ps2/ -O "%~dp0BAT\Dats\RedumpCUEPS2.zip"
timeout 2 >nul
"%~dp0BAT\Diagbox" gd 0f
"%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0BAT\Dats\RedumpPS2.zip" -so > "%~dp0BAT\Dats\PS2\RedumpPS2.dat"
 )
)

"%~dp0BAT\Diagbox" gd 0f
echo\
echo PROCESSING...
echo\

if not exist "%~dp0TMP" mkdir "%~dp0TMP" >nul 2>&1
if not exist "%~dp0CD-DVD" mkdir "%~dp0CD-DVD" >nul 2>&1

if %gametype%==PS1 (
if exist "%~dp0TMP\*.bin" (cd /d "%~dp0TMP" ) else (cd /d "%~dp0POPS" )
)

if %gametype%==PS2 (
if defined checkmd5dump (cd /d "%~dp0TMP"
) else (
cd /d "%~dp0CD-DVD"
move "%~dp0CD\*.bin" "%~dp0CD-DVD" >nul 2>&1
move "%~dp0DVD\*.iso" "%~dp0CD-DVD" >nul 2>&1
 )
)

dir /b /a-d| "%~dp0BAT\busybox" grep -ie ".*\.iso$" -ie ".*\.bin$" > "%~dp0TMP\gamelistTMP.txt"
set /a gamecount=0
for /f "usebackq tokens=*" %%a in ("%~dp0TMP\gamelistTMP.txt") do (
set /a gamecount+=1

	setlocal DisableDelayedExpansion
	set filename=%%a
	set fname=%%~na
	set "ErrorHash="
	setlocal EnableDelayedExpansion
	
	echo\
	echo\
	echo !gamecount! - !filename!

REM CRC32
"%~dp0BAT\busybox" crc32 "!filename!" | "%~dp0BAT\busybox" grep -o "[0-9a-z]\{8\}" > "%~dp0TMP\CRC32.TXT" & set /p CRC32=<"%~dp0TMP\CRC32.txt"
REM MD5
"%~dp0BAT\busybox" md5sum "!filename!" | "%~dp0BAT\busybox" grep -o "[0-9a-z]\{32\}" > "%~dp0TMP\MD5.TXT" & set /p MD5=<"%~dp0TMP\MD5.txt"
REM SHA1
"%~dp0BAT\busybox" sha1sum "!filename!" | "%~dp0BAT\busybox" grep -o "[0-9a-z]\{40\}" > "%~dp0TMP\SHA1.TXT" & set /p SHA1=<"%~dp0TMP\SHA1.txt"

for %%f in (!CRC32! !MD5! !SHA1!) do (
"%~dp0BAT\busybox" grep -e %%f "%~dp0BAT\Dats\!gametype!\Redump!gametype!.dat" > "%~dp0TMP\RedumpDB.txt"
if errorlevel 1 (set ErrorHash=%%f) else (echo found %%f) >nul
)

if defined ErrorHash (
"%~dp0BAT\Diagbox" gd 0c
echo.
echo WARNING: MD5 or others Hash NO MATCH WITH Redump Database : !md5!
echo ^|!date! !time!>> "%~dp0LOG\MD5-Fail.log"
echo ^|File: !filename!>> "%~dp0LOG\MD5-Fail.log"
echo ^|CRC: !CRC32!>> "%~dp0LOG\MD5-Fail.log"
echo ^|MD5: !MD5!>> "%~dp0LOG\MD5-Fail.log"
echo ^|SHA: !SHA1!>> "%~dp0LOG\MD5-Fail.log"
echo. >> "%~dp0LOG\MD5-Fail.log"
echo.
"%~dp0BAT\Diagbox" gd 06
echo There can be several reasons
echo.
echo This could be due to a bad dump or to a CD-ROM Converted to .ISO
echo How to differentiate a DVD-ROM from a CD-ROM In general, the CD-ROM is only 750MB 
echo and CD-ROMs For PS2 are often colored blue under the disc.
echo.
echo Or you have a copy of a game that has never been dumped for more info visit redump.org
echo.
"%~dp0BAT\Diagbox" gd 0f

) else (
"%~dp0BAT\Diagbox" gd 0a
echo MD5 Match With Redump Database : !md5!
echo\ 
echo http://redump.org/discs/quicksearch/!md5!/
"%~dp0BAT\Diagbox" gd 0f

REM set /P RedumpName2=<"%~dp0TMP\RedumpName2.txt"
REM echo !RedumpName2!
REM if defined RedumpName2 ("%~dp0BAT\busybox" grep -o "!RedumpName2! (Disc [0-1]) (Track [0-9][0-9]).bin" "%~dp0TMP\RedumpDB.txt" > "%~dp0TMP\RedumpNameDB.txt")

REM Get Redump Name
setlocal DisableDelayedExpansion
"%~dp0BAT\busybox" sed "s/size=/\n/g" "%~dp0TMP\RedumpDB.txt" > "%~dp0TMP\RedumpNameDB.txt"
"%~dp0BAT\busybox" sed -i "2,100d" "%~dp0TMP\RedumpNameDB.txt"
"%~dp0BAT\busybox" cut -c13-1000 "%~dp0TMP\RedumpNameDB.txt" > "%~dp0TMP\RedumpNameDBClean.txt"
"%~dp0BAT\busybox" sed -i "s/\"//g; s/amp;//g; s/\s*$//" "%~dp0TMP\RedumpNameDBClean.txt"
set /P redump=<"%~dp0TMP\RedumpNameDBClean.txt"
setlocal EnableDelayedExpansion

ren "!filename!" "!redump!"

REM if not defined RedumpName2 echo "!redump!"| "%~dp0BAT\busybox" grep -e "(Track 01).bin" |"%~dp0BAT\busybox" sed -e "s/ (Track 01).bin//g" | "%~dp0BAT\busybox" sed -e "s/\""//g" > "%~dp0TMP\RedumpName2.txt"

"%~dp0BAT\Diagbox" gd 0f
echo\
echo DETAIL
echo **********************************************
"%~dp0BAT\Diagbox" gd 0a
echo "!redump!"
echo\
echo ^|CRC: !CRC32!
echo ^|MD5: !MD5!
echo ^|SHA: !SHA1!
REM echo ^|SIZE: %SIZE%
"%~dp0BAT\Diagbox" gd 0f
echo **********************************************

echo ^|!date! !time!>> "%~dp0LOG\MD5-Match.log"
echo ^|File: !filename!>> "%~dp0LOG\MD5-Match.log" 
echo ^|Redump: !redump!>> "%~dp0LOG\MD5-Match.log" 
echo ^|CRC: !CRC32!>> "%~dp0LOG\MD5-Match.log"  
echo ^|MD5: !MD5!>> "%~dp0LOG\MD5-Match.log"
echo ^|SHA: !SHA1!>> "%~dp0LOG\MD5-Match.log"
echo http://redump.org/discs/quicksearch/!md5!/ >> "%~dp0LOG\MD5-Match.log"
echo. >> "%~dp0LOG\MD5-Match.log"

set "CueName="
echo "!redump!"| "%~dp0BAT\busybox" sed -e "s/ (Track [0-9][0-9])//g; s/ (Track [0-9])//g" | "%~dp0BAT\busybox" sed -e "s/.bin//"  | "%~dp0BAT\busybox" sed -e "s/\""//g" > "%~dp0TMP\CueName.txt" & set /P CueName=<"%~dp0TMP\CueName.txt"
if %gametype%==PS1 (del "%~dp0POPS\!fname!.cue" >nul 2>&1 & "%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0BAT\Dats\RedumpCUEPS1.zip" -o"%~dp0POPS" "!CueName!.cue" -r -y >nul 2>&1)
if %gametype%==PS2 (del "%~dp0CD\!fname!.cue" >nul 2>&1 & "%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0BAT\Dats\RedumpCUEPS2.zip" -o"%~dp0CD" "!CueName!.cue" -r -y >nul 2>&1)
   endlocal
  endlocal
 )
 endlocal
endlocal
)

if !gametype!==PS1 (
if exist "%~dp0TMP\*.bin" move "%~dp0TMP\*.bin" "%~dp0POPS" >nul 2>&1
)
if !gametype!==PS2 (
move "%~dp0TMP\*.bin" "%~dp0CD" >nul 2>&1
move "%~dp0TMP\*.iso" "%~dp0DVD" >nul 2>&1
move "%~dp0CD-DVD\*.bin" "%~dp0CD" >nul 2>&1
move "%~dp0CD-DVD\*.iso" "%~dp0DVD" >nul 2>&1
)

cd /d "%~dp0" & rmdir /Q/S "%~dp0TMP" >nul 2>&1

echo\
echo\
"%~dp0BAT\Diagbox" gd 0f
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo Completed...
echo\
echo\
"%~dp0BAT\Diagbox" gd 07

pause & (goto GamesManagement)
REM ###################################################################################################################################################
:ExportChoiceGamesListHDD
cls
mkdir "%~dp0TMP" >nul 2>&1
cd "%~dp0"

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Choose what type of games you want to export game list:
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1^) Yes PS2 Games
"%~dp0BAT\Diagbox" gd 0c
echo         2^) No
"%~dp0BAT\Diagbox" gd 0e
echo         3^) Yes PS1 Games
echo\
"%~dp0BAT\Diagbox" gd 07
CHOICE /C 123 /M "Select Option:"

IF %ERRORLEVEL%==1 (goto ExportPS2GamesList)
IF %ERRORLEVEL%==2 (goto GamesManagement) 
IF %ERRORLEVEL%==3 (goto ExportPS1GamesList)

REM #######################################################################################################################################################################
:ExportPS1GamesList
cls
mkdir "%~dp0TMP" >nul 2>&1
cd /d "%~dp0TMP"

IF NOT DEFINED @hdl_path ( rmdir /Q/S "%~dp0TMP" >nul 2>&1 & goto ScanningPS2HDD ) else (
"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning for Playstation 2 HDDs:
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "!@hdl_path!" | "%~dp0BAT\busybox" grep "Playstation 2 HDD" >nul
if errorlevel 1 set "@hdl_path=" & goto ScanningPS2HDD
echo       [!@hdl_path! !@TotalHDD_Size! - !@ModelePS2HDD!]
)

echo\
echo\
"%~dp0BAT\Diagbox" gd 0f
echo Export PS1 Game List ^?
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1^) Yes (Export All Partition Games list)
"%~dp0BAT\Diagbox" gd 0c
echo         2^) No
"%~dp0BAT\Diagbox" gd 0e
echo         3^) Yes (Export only the chosen partition)
"%~dp0BAT\Diagbox" gd 0f
echo\
CHOICE /C 123 /M "Select Option:"

IF %ERRORLEVEL%==1 set ExportPS1GamesListPartAll=yes
IF %ERRORLEVEL%==2 (goto GamesManagement)
IF %ERRORLEVEL%==3 set ExportPS1GamesOnlyPart=yes

IF !ExportPS1GamesOnlyPart!==yes (
"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Detecting POPS Partition:
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0f

    "%~dp0BAT\busybox" grep -o "__.POPS\|__.POPS[0-9]" "%~dp0BAT\__Cache\PARTITION_PS2HDD.txt" | "%~dp0BAT\busybox" sed "s/__.POPS\([0-9]\)/\1.  __.POPS\1/g; s/\__.POPS\b/10. __.POPS/" | "%~dp0BAT\busybox" sort -k2 > "%~dp0TMP\hdd-prt.txt"
    "%~dp0BAT\busybox" sed -e "/^$/d" "%~dp0TMP\hdd-prt.txt" | "%~dp0BAT\busybox" wc -l > "%~dp0TMP\TotalPOPSPart.txt" & set /P @TotalPOPSPart=<"%~dp0TMP\TotalPOPSPart.txt"
    
    if !@TotalPOPSPart! gtr 1 (
	echo.
    echo Multiple POPS partitions detected. Please choose one.
    echo In general, the default partition is __.POPS
    echo.
    type "%~dp0TMP\hdd-prt.txt"
    echo.
	
    set choice=
    set /p choice="Select Option:"
    IF "!choice!"=="" (goto GamesManagement)
    
    set POPSPART=__.POPS!choice!
    IF "!choice!"=="10" set "choice=" & set POPSPART=__.POPS
	
	"%~dp0BAT\busybox" grep -ow "!POPSPART!" "%~dp0TMP\hdd-prt.txt" > "%~dp0TMP\hdd-prt2.txt" & set /p POPSPARTSELECTED=<"%~dp0TMP\hdd-prt2.txt"
    ) else (
    "%~dp0BAT\busybox" grep -o "__.POPS\|__.POPS[0-9]" "%~dp0TMP\hdd-prt.txt" > "%~dp0TMP\hdd-prt2.txt" & set /p POPSPARTSELECTED=<"%~dp0TMP\hdd-prt2.txt"
    )
	
	if not defined POPSPARTSELECTED set "POPSPARTSELECTED=NOT_DETECTED"
	set /P POPSPART=<"%~dp0TMP\hdd-prt2.txt"
    IF "!POPSPART!"=="!POPSPARTSELECTED!" (
    "%~dp0BAT\Diagbox" gd 0a
    echo        !POPSPART! - Partition Detected
	"%~dp0BAT\Diagbox" gd 07
	) else (
	"%~dp0BAT\Diagbox" gd 0c
	echo              No POPS partition detected
	echo              Partition Must Be Created
	echo\
	echo\
	"%~dp0BAT\Diagbox" gd 07
	rmdir /Q/S "%~dp0TMP" >nul 2>&1
	pause & (goto mainmenu)
	)

echo\
echo\
pause
cls
)

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Export...
echo\
	
	if defined ExportPS1GamesListPartAll "%~dp0BAT\busybox" grep -ie "__\.POPS" "%~dp0BAT\__Cache\PARTITION_PS2HDD.txt" | "%~dp0BAT\busybox" cut -c30-500 > "%~dp0TMP\POPSPartTMP.txt"
	if defined ExportPS1GamesOnlyPart echo !POPSPART!> "%~dp0TMP\POPSPartTMP.txt"
	for /f "tokens=*" %%P in (POPSPartTMP.txt) do (
	
	set POPSPART=%%P
	echo device !@pfsshell_path! > "%~dp0TMP\pfs-log.txt"
	echo mount !POPSPART! >> "%~dp0TMP\pfs-log.txt"
	echo ls >> "%~dp0TMP\pfs-log.txt"
	echo umount >> "%~dp0TMP\pfs-log.txt"
	echo exit >> "%~dp0TMP\pfs-log.txt"
	type "%~dp0TMP\pfs-log.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" grep -ie ".*\.VCD$" > "%~dp0GamelistPS1!POPSPART!.txt"
	echo Output ^> "%~dp0GamelistPS1!POPSPART!.txt"
	)
	
cd /d "%~dp0" & rmdir /Q/S "%~dp0TMP" >nul 2>&1
echo/
pause & (goto GamesManagement) 
REM ###################################################################################################################################################
:ExportPS2GamesList
cls
mkdir "%~dp0TMP" >nul 2>&1

IF NOT DEFINED @hdl_path ( rmdir /Q/S "%~dp0TMP" >nul 2>&1 & goto ScanningPS2HDD ) else (
"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning for Playstation 2 HDDs:
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "!@hdl_path!" | "%~dp0BAT\busybox" grep "Playstation 2 HDD" >nul
if errorlevel 1 set "@hdl_path=" & goto ScanningPS2HDD
echo       [!@hdl_path! !@TotalHDD_Size! - !@ModelePS2HDD!]
)

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Export PS2 Game List ?
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1^) Yes (Export All Games list)
"%~dp0BAT\Diagbox" gd 0c
echo         2^) No
"%~dp0BAT\Diagbox" gd 0e
echo         3^) Yes (Export Only CD)
echo         4^) Yes (Export Only DVD)
"%~dp0BAT\Diagbox" gd 0f
echo\
CHOICE /C 1234 /M "Select Option:"

IF %ERRORLEVEL%==1 set "list="
IF %ERRORLEVEL%==2 (goto GamesManagement)
IF %ERRORLEVEL%==3 set list=CD
IF %ERRORLEVEL%==4 set list=DVD
		
"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Export...
echo\

if not defined list (type "%~dp0BAT\__Cache\PS2_GAMES_HDD.txt" | "%~dp0BAT\busybox" sed "s/.\{31\}/&;/" | "%~dp0BAT\busybox" sort -k6 | "%~dp0BAT\busybox" sed -e "s/;//g" > "%~dp0\GamelistPS2.txt")
if "%list%"=="CD" (type "%~dp0BAT\__Cache\PS2_GAMES_HDD.txt" | "%~dp0BAT\busybox" grep -i -e "CD" | "%~dp0BAT\busybox" sed "s/.\{31\}/&;/" | "%~dp0BAT\busybox" sort -k6 | "%~dp0BAT\busybox" sed -e "s/;//g" > "%~dp0\GamelistPS2CD.txt")
if "%list%"=="DVD" (type "%~dp0BAT\__Cache\PS2_GAMES_HDD.txt" | "%~dp0BAT\busybox" grep -i -e "DVD" | "%~dp0BAT\busybox" sed "s/.\{31\}/&;/" | "%~dp0BAT\busybox" sort -k6 | "%~dp0BAT\busybox" sed -e "s/;//g" > "%~dp0\GamelistPS2DVD.txt")

echo Output ^> "%~dp0GamelistPS2!list!.txt"

rmdir /Q/S "%~dp0TMP" >nul 2>&1
echo\
pause & (goto GamesManagement) 

REM ####################################################################################################################################################
:RenameChoiceGames
cls
cd /d"%~dp0"
mkdir "%~dp0TMP" >nul 2>&1

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Rename your Games:
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1^) Yes PS2 Games
"%~dp0BAT\Diagbox" gd 0c
echo         2^) No
"%~dp0BAT\Diagbox" gd 0e
echo         3^) Yes PS1 Games
echo\
"%~dp0BAT\Diagbox" gd 07
CHOICE /C 123 /M "Select Option:"

IF %ERRORLEVEL%==1 set @GameManagementMenu=yes & (goto RenamePS2GamesHDD)
IF %ERRORLEVEL%==2 (goto GamesManagement)
IF %ERRORLEVEL%==3 set @GameManagementMenu=yes & (goto RenamePS1GamesHDD)

REM ###################################################################
:RenamePS2GamesHDD
cls
mkdir "%~dp0TMP" >nul 2>&1
cd /d "%~dp0TMP"

IF NOT DEFINED @hdl_path ( rmdir /Q/S "%~dp0TMP" >nul 2>&1 & goto ScanningPS2HDD ) else (
"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning for Playstation 2 HDDs:
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "!@hdl_path!" | "%~dp0BAT\busybox" grep "Playstation 2 HDD" >nul
if errorlevel 1 set "@hdl_path=" & goto ScanningPS2HDD
echo       [!@hdl_path! !@TotalHDD_Size! - !@ModelePS2HDD!]
)

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Rename a PS2 game:
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1^) Yes
"%~dp0BAT\Diagbox" gd 0c
echo         2^) No
"%~dp0BAT\Diagbox" gd 0e
echo         3^) Yes (Automatically rename all game titles on hard drive with database)
"%~dp0BAT\Diagbox" gd 0e
echo         4^) Yes (Rename Displayed name in HDD-OSD, PSBBN, XMB Menu)
"%~dp0BAT\Diagbox" gd 0f
echo\
CHOICE /C 1234 /M "Select Option:"

IF %ERRORLEVEL%==1 set @RenamePS2Games=Manually
IF %ERRORLEVEL%==2 (goto GamesManagement)
IF %ERRORLEVEL%==3 set @RenamePS2Games=DBTitle
IF %ERRORLEVEL%==4 set RenameGamesOSD=HDL& (goto RenamePPTitleOSD)

if not exist "%~dp0TMP\TitlesDB_PS2_!TitlesLang!.txt" set "TitlesLang=English"
"%~dp0BAT\busybox" iconv -f utf8 -t ascii//TRANSLIT//IGNORE "%~dp0BAT\TitlesDB\TitlesDB_PS2_!TitlesLang!.txt" > "%~dp0TMP\TitlesDB_PS2_!TitlesLang!.txt"

"%~dp0BAT\Diagbox" gd 0e
cls
echo\
echo\
echo Scanning Games List:
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
type "%~dp0BAT\__Cache\PARTITION_HDL_GAME.txt" | "%~dp0BAT\busybox" sed "s/|.*//" | "%~dp0BAT\busybox" sort -k2 > "%~dp0TMP\GameListPS2.txt" & type "%~dp0TMP\GameListPS2.txt"
"%~dp0BAT\Diagbox" gd 0e
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0f

    if !@RenamePS2Games!==Manually (
    echo\
	"%~dp0BAT\Diagbox" gd 0e
	echo Please type the gameid ^+ GameName as shown in the Games List.
	"%~dp0BAT\Diagbox" gd 07
	set "gname="
    set /p gname=
    if "!gname!"=="" (goto RenamePS2GamesHDD)
	if "!gname!"=="!gname:~0,11!" set "gname=!gname:~0,11! "
	
	"%~dp0BAT\busybox" grep -Fx "!gname!" "%~dp0TMP\GameListPS2.txt" >nul
	if errorlevel 1 (
    "%~dp0BAT\Diagbox" gd 0c
	echo       !gname! NOT Detected
	echo\
	echo\
	"%~dp0BAT\Diagbox" gd 07
	rmdir /Q/S "%~dp0TMP" >nul 2>&1
	pause & (goto RenamePS2GamesHDD)
	) else ("%~dp0BAT\busybox" grep -F -w -m 1 "!gname!" "%~dp0BAT\__Cache\PARTITION_HDL_GAME.txt" > "%~dp0TMP\PARTITION_HDL_GAME.txt")

    echo\
	echo Enter ONLY the new name of your game, do not include the gameid.
    set /p "newfname="
    IF "!newfname!"=="" (goto RenamePS2GamesHDD)
    ) else (type "%~dp0BAT\__Cache\PARTITION_HDL_GAME.txt" > "%~dp0TMP\PARTITION_HDL_GAME.txt")

	echo\

    for /f "usebackq tokens=1* delims=|" %%f in ("%~dp0TMP\PARTITION_HDL_GAME.txt") do (
    setlocal DisableDelayedExpansion
    set fname=%%f
    set pname=%%g
    setlocal EnableDelayedExpansion

    if !@RenamePS2Games!==DBTitle (
	set "newfname="
	for /f "tokens=1*" %%A in (' findstr "!fname:~0,11!" "%~dp0TMP\TitlesDB_PS2_!TitlesLang!.txt" ') do set newfname=%%B
	)

	if defined newfname (
	echo\
    echo !fname:~12!
	echo !fname:~0,12!
	"%~dp0BAT\Diagbox" gd 03
	echo Rename to... [!newfname!]
	"%~dp0BAT\Diagbox" gd 0f

	"%~dp0BAT\hdl_dump" modify !@hdl_path! "!pname!" "!newfname!"
	)
  endlocal
endlocal
)
    REM Delete games cache OPL
	echo device %@pfsshell_path% > "%~dp0TMP\pfs-OPLconfig.txt"
    echo mount %OPLPART% >> "%~dp0TMP\pfs-OPLconfig.txt"
    if defined CUSTOM_OPLPART echo cd OPL >> "%~dp0TMP\pfs-OPLconfig.txt"
	echo rm games.bin >> "%~dp0TMP\pfs-OPLconfig.txt"	  
	echo umount >> "%~dp0TMP\pfs-OPLconfig.txt"
    echo exit >> "%~dp0TMP\pfs-OPLconfig.txt"
    type "%~dp0TMP\pfs-OPLconfig.txt" | "%~dp0BAT\pfsshell" >nul 2>&1
	
	REM Reloading HDD Cache
	call "%~dp0BAT\__ReloadHDD_cache.bat" >nul 2>&1
	
cd /d "%~dp0" & rmdir /Q/S "%~dp0TMP" >nul 2>&1

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo Renaming Completed...
echo\
echo\
"%~dp0BAT\Diagbox" gd 0f

pause & (goto GamesManagement)
REM ###############################################################################
:RenamePPTitleOSD
cls
cd /d "%~dp0TMP"

"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning Games List:
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 03

if !RenameGamesOSD!==HDL (
type "%~dp0BAT\__Cache\PARTITION_HDL_GAME.txt" | "%~dp0BAT\busybox" sed "s/|.*//" | "%~dp0BAT\busybox" sort -k2 > "%~dp0TMP\GameList!RenameGamesOSD!.txt"
) else (
type "%~dp0BAT\__Cache\PARTITION_POPS_GAME.txt" | "%~dp0BAT\busybox" sed "s/|.*//" | "%~dp0BAT\busybox" sort -k2 > "%~dp0TMP\GameList!RenameGamesOSD!.txt"
)

type "%~dp0TMP\GameList!RenameGamesOSD!.txt"
"%~dp0BAT\Diagbox" gd 0e
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0f

    echo\
	"%~dp0BAT\Diagbox" gd 0e
	echo Please type the gameid ^+ GameName as shown in the Games List.
	"%~dp0BAT\Diagbox" gd 07
	set "gname="
    set /p gname=
    if "!gname!"=="" if defined @GameManagementMenu (goto GamesManagement) else (goto HDDOSDPartManagement)
    if "!gname!"=="!gname:~0,11!" set "gname=!gname:~0,11! "

	"%~dp0BAT\busybox" grep -Fx "!gname!" "%~dp0TMP\GameList!RenameGamesOSD!.txt" >nul
	if errorlevel 1 (
    "%~dp0BAT\Diagbox" gd 0c
	echo       !gname! NOT Detected
	echo\
	echo\
	"%~dp0BAT\Diagbox" gd 07
	rmdir /Q/S "%~dp0TMP" >nul 2>&1
	pause & if defined @GameManagementMenu (goto GamesManagement) else (goto HDDOSDPartManagement)
	) else ("%~dp0BAT\busybox" grep -F -w -m 1 "!gname!" "%~dp0BAT\__Cache\PARTITION_!RenameGamesOSD!_GAME.txt" | "%~dp0BAT\busybox" sed "s/^[^|]*|//" > "%~dp0TMP\PARTITION_!RenameGamesOSD!_GAME.txt" & set /P pname=<"%~dp0TMP\PARTITION_!RenameGamesOSD!_GAME.txt")

	REM Check if PFS Part exist
	"%~dp0BAT\busybox" grep "0x0100" "%~dp0BAT\__Cache\PARTITION_PS2HDD.txt" | "%~dp0BAT\busybox" grep -o "PP.!pname:~3!" > "%~dp0TMP\PartPFS.txt" & set /P PartPFS=<"%~dp0TMP\PartPFS.txt"
	if defined PartPFS set pname=PP.!pname:~3!
	
	"%~dp0BAT\hdl_dump_fix_header" dump_header !@hdl_path! "!pname!" >nul 2>&1
	del system.cnf >nul 2>&1

    echo device !@pfsshell_path! > "%~dp0TMP\pfs-log.txt"
    echo mount "!pname!" >> "%~dp0TMP\pfs-log.txt"
	echo cd res >> "%~dp0TMP\pfs-log.txt"
    echo get info.sys >> "%~dp0TMP\pfs-log.txt"
    echo get man.xml >> "%~dp0TMP\pfs-log.txt"
	echo umount >> "%~dp0TMP\pfs-log.txt"
   	echo exit >> "%~dp0TMP\pfs-log.txt"
 	type "%~dp0TMP\pfs-log.txt" | "%~dp0BAT\pfsshell" >nul 2>&1

    chcp 65001 >nul 2>&1
    echo\
    echo\
	"%~dp0BAT\Diagbox" gd 0e
	echo Titles displayed in PSBBN, XMB menu 
	"%~dp0BAT\Diagbox" gd 0f
	type info.sys | "%~dp0BAT\busybox" grep -w "title ="
	echo\
	
	"%~dp0BAT\Diagbox" gd 0e
	echo Titles displayed in HDD-OSD
	"%~dp0BAT\Diagbox" gd 0f
	type icon.sys | "%~dp0BAT\busybox" grep -e "title0" -e "title1"
	echo.----------------------------------------------------------
	chcp 1252 >nul 2>&1
	echo\
	echo What title do you want to edit?
    echo Option: 1 = PSBBN, XMB menu
    echo Option: 2 = HDD-OSD
    CHOICE /C 12 /M "Select Option:"
	
    IF !ERRORLEVEL!==1 set Titletype=PSBBNXMB
    IF !ERRORLEVEL!==2 set Titletype=HDDOSD
	
	if !Titletype!==HDDOSD (
    echo\
    echo What title line do you want to edit?
    echo Option: 1 = title0
    echo Option: 2 = title1
    CHOICE /C 12 /M "Select Option:"
    
    IF !ERRORLEVEL!==1 set title=0
    IF !ERRORLEVEL!==2 set title=1
	)
	
	echo\
    echo\
    if !Titletype!==HDDOSD echo 47 Characters max
    set /p newgnametmp=Enter the New Game Name:
	if "!newgnametmp!"=="" cd /d "%~dp0" & rmdir /Q/S "%~dp0TMP" >nul 2>&1
	if "!newgnametmp!"=="" if defined @GameManagementMenu (goto GamesManagement) else (goto HDDOSDPartManagement)
	"%~dp0BAT\Diagbox" gd 03
    
	REM Fix illegal character
    echo "!newgnametmp!"| "%~dp0BAT\busybox" sed -e "s/\&/\\\&/g; s./.\\\/.g" | "%~dp0BAT\busybox" iconv -f windows-1252 -t utf-8 > "%~dp0TMP\newgnametmp.txt"
    "%~dp0BAT\busybox" sed -i "s/\"//g" "%~dp0TMP\newgnametmp.txt"
    set /P newgname=<"%~dp0TMP\newgnametmp.txt"
	
	if !Titletype!==PSBBNXMB (
	"%~dp0BAT\busybox" sed -i -e "s/title =.*/title =/g; s/title =/title = !newgname!/g" "%~dp0TMP\info.sys"
	"%~dp0BAT\busybox" sed -i -e "s/\"TOP-TITLE\" label=.*/\"TOP-TITLE\" label=/g; s/\"TOP-TITLE\" label=/\"TOP-TITLE\" label=\"!newgname!\"/g; s/\&/\&amp;/g" "%~dp0TMP\man.xml"
    echo device !@pfsshell_path! > "%~dp0TMP\pfs-log.txt"
    echo mount "!pname!" >> "%~dp0TMP\pfs-log.txt"
	echo cd res >> "%~dp0TMP\pfs-log.txt"
    echo put info.sys >> "%~dp0TMP\pfs-log.txt"
	echo put man.xml >> "%~dp0TMP\pfs-log.txt"
	echo umount >> "%~dp0TMP\pfs-log.txt"
   	echo exit >> "%~dp0TMP\pfs-log.txt"
 	type "%~dp0TMP\pfs-log.txt" | "%~dp0BAT\pfsshell" >nul 2>&1
	)
	
	if !Titletype!==HDDOSD (
    if !title!==0 ("%~dp0BAT\busybox" sed -i -e "s|title0 = .*|title0 = |g; s|title0 = |title0 = !newgname!|g" "%~dp0TMP\icon.sys")
    if !title!==1 ("%~dp0BAT\busybox" sed -i -e "s|title1 = .*|title1 = |g; s|title1 = |title1 = !newgname!|g" "%~dp0TMP\icon.sys")
	"%~dp0BAT\hdl_dump" modify_header !@hdl_path! "!pname!" >nul 2>&1
	if defined PartPFS "%~dp0BAT\hdl_dump_fix_header" modify_header !@hdl_path! "__.!pname:~3!" >nul 2>&1
    )

cd /d "%~dp0" & rmdir /Q/S "%~dp0TMP" >nul 2>&1

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo Renaming Completed...
echo\
echo\
"%~dp0BAT\Diagbox" gd 0f

if defined @GameManagementMenu (pause & goto GamesManagement) else (pause & goto HDDOSDPartManagement)
REM #######################################################################################################################################################################
:RenamePS1GamesHDD
cls
rmdir /Q/S "%~dp0TMP" >nul 2>&1
mkdir "%~dp0TMP" >nul 2>&1
cd /d "%~dp0TMP"

IF NOT DEFINED @hdl_path ( rmdir /Q/S "%~dp0TMP" >nul 2>&1 & goto ScanningPS2HDD ) else (
"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning for Playstation 2 HDDs:
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "!@hdl_path!" | "%~dp0BAT\busybox" grep "Playstation 2 HDD" >nul
if errorlevel 1 set "@hdl_path=" & goto ScanningPS2HDD
echo       [!@hdl_path! !@TotalHDD_Size! - !@ModelePS2HDD!]
)

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Rename a PS1 game:
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1^) Yes
"%~dp0BAT\Diagbox" gd 0c
echo         2^) No
"%~dp0BAT\Diagbox" gd 0e
echo         3^) Yes (Rename Displayed name in HDD-OSD, PSBBN, XMB Menu)
echo\
"%~dp0BAT\Diagbox" gd 07
CHOICE /C 123 /M "Select Option:"

IF %ERRORLEVEL%==2 (goto GamesManagement)
IF %ERRORLEVEL%==3 set "RenameGamesOSD=POPS" & (goto RenamePPTitleOSD)

"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Detecting POPS Partition:
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0f
	
	"%~dp0BAT\busybox" grep -w "__.POPS\|__.POPS[0-9]" "%~dp0BAT\__Cache\PARTITION_PS2HDD.txt" | "%~dp0BAT\busybox" sort -k5 > "%~dp0TMP\hdd-prt.txt"
	"%~dp0BAT\busybox" sed -e "/^$/d" "%~dp0TMP\hdd-prt.txt" | "%~dp0BAT\busybox" wc -l > "%~dp0TMP\TotalPOPSPart.txt" & set /P @TotalPOPSPart=<"%~dp0TMP\TotalPOPSPart.txt"
	
	for /f "usebackq tokens=1,2,3,4,5" %%f in ("%~dp0TMP\hdd-prt.txt") do (
	set PartSize=%%i
	set POPSPART=%%j
	set TotalUsed=0
	set Remaining=
	 
	echo device !@pfsshell_path! > "%~dp0TMP\pfs-pops.txt"
	echo mount !POPSPART! >> "%~dp0TMP\pfs-pops.txt"
	echo ls -l >> "%~dp0TMP\pfs-pops.txt"
	echo umount >> "%~dp0TMP\pfs-pops.txt"
	type "%~dp0TMP\pfs-pops.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" grep -ie ".*\.VCD$" > "%~dp0TMP\PFS-POPS.log"
	
	for /f "usebackq tokens=1,2,3,4*" %%f in ("%~dp0TMP\PFS-POPS.log") do (
	set /a "TotalUsed+=%%g / 1048576"
	setlocal DisableDelayedExpansion
	set filename=%%j
	set fname=%%~nj
	set game_size=%%g
	setlocal EnableDelayedExpansion
	if "!POPSPART!"=="__.POPS" set "POPSPART=__.POPS "
	echo !POPSPART! - !game_size! - !fname!>>"%~dp0TMP\Games_Installed_tmp.txt"
		endlocal
	endlocal
	)
	
	set /a Remaining=!PartSize:~0,-2! - !TotalUsed!
	echo Name: [!POPSPART!] - Size: [!PartSize!] - Used: [!TotalUsed!MB] - Free: [!Remaining!MB]
	)

	if "!POPSPART!"=="" (
	"%~dp0BAT\Diagbox" gd 0c
	echo            No POPS partition detected
	echo            Partition Must Be Created
	echo\
	echo\
	"%~dp0BAT\Diagbox" gd 07
	rmdir /Q/S "%~dp0TMP" >nul 2>&1
	pause & (goto mainmenu)
	)

echo\
echo\
pause
cls

"%~dp0BAT\Diagbox" gd 07
echo\
echo\
echo Scanning Games List
echo ---------------------------------------------------
echo [Parts]:   [Size]:     [Name]:
"%~dp0BAT\Diagbox" gd 0e
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 07
"%~dp0BAT\busybox" sed -n "/[A-Z][A-Z][A-Z][A-Z]_[0-9][0-9][0-9]\.[0-9][0-9]/p" "%~dp0TMP\Games_Installed_tmp.txt" | "%~dp0BAT\busybox" sort -k5.14 > "%~dp0TMP\Games_Installed.txt"
"%~dp0BAT\busybox" sed -n "/[A-Z][A-Z][A-Z][A-Z]_[0-9][0-9][0-9]\.[0-9][0-9]/^!p" "%~dp0TMP\Games_Installed_tmp.txt" | "%~dp0BAT\busybox" sort -k5 >> "%~dp0TMP\Games_Installed.txt"
type "%~dp0TMP\Games_Installed.txt"
"%~dp0BAT\Diagbox" gd 0e
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 07

echo\
echo Enter the full name. Example: MyGameName
"%~dp0BAT\Diagbox" gd 06
echo Respect upper and lower case
"%~dp0BAT\Diagbox" gd 07
echo.
set /p "RenamePS1Games=Enter the name of the game you want to rename:"
IF "!RenamePS1Games!"=="" rmdir /Q/S "%~dp0TMP" >nul 2>&1 & (goto GamesManagement)
"%~dp0BAT\busybox" grep "!RenamePS1Games!" "%~dp0TMP\Games_Installed_tmp.txt" > "%~dp0TMP\Games_Installed_Selected.txt"

echo\
echo\
echo Enter the new name. Example: MyNewGameName
echo\
set /p "RenamePS1GamesNEW=Enter the new name of your game:"
IF "!RenamePS1GamesNEW!"=="" rmdir /Q/S "%~dp0TMP" >nul 2>&1 & (goto GamesManagement)

"%~dp0BAT\Diagbox" gd 0e
cls
echo\
echo\
echo Game Selected "!RenamePS1Games!"
"%~dp0BAT\Diagbox" gd 0f
echo ---------------------------------------------------
echo\
"%~dp0BAT\Diagbox" gd 03
	
	for /f "usebackq tokens=1,2,3,4*" %%f in ("%~dp0TMP\Games_Installed_Selected.txt") do (
	echo        Renaming...
	echo        "!RenamePS1Games!"
	echo device !@pfsshell_path! > "%~dp0TMP\pfs-pops.txt"
	echo mount %%f >> "%~dp0TMP\pfs-pops.txt"
	echo rename "!RenamePS1Games!.vcd" "!RenamePS1Games!.VCD" >> "%~dp0TMP\pfs-pops.txt"
	echo rename "!RenamePS1Games!.VCD" "!RenamePS1GamesNEW!.VCD" >> "%~dp0TMP\pfs-pops.txt"
	echo umount >> "%~dp0TMP\pfs-pops.txt"
	echo mount __common >> "%~dp0TMP\pfs-pops.txt"
	echo cd POPS >> "%~dp0TMP\pfs-pops.txt"
	echo rename "!RenamePS1Games!" "!RenamePS1GamesNEW!" >> "%~dp0TMP\pfs-pops.txt"
	echo cd .. >> "%~dp0TMP\pfs-pops.txt"
	echo umount >> "%~dp0TMP\pfs-pops.txt"

	echo mount !OPLPART! >> "%~dp0TMP\pfs-pops.txt"
	if defined CUSTOM_OPLPART echo cd OPL >> "%~dp0TMP\pfs-pops.txt"
	echo cd APPS >> "%~dp0TMP\pfs-pops.txt"
	echo rename "!RenamePS1Games!" "!RenamePS1GamesNEW!" >> "%~dp0TMP\pfs-pops.txt"
	echo cd "!RenamePS1GamesNEW!" >> "%~dp0TMP\pfs-pops.txt"
	echo rename "!RenamePS1Games!.ELF" "!RenamePS1GamesNEW!.ELF" >> "%~dp0TMP\pfs-pops.txt"
	echo get "title.cfg" >> "%~dp0TMP\pfs-pops.txt"
	echo rm "title.cfg" >> "%~dp0TMP\pfs-pops.txt"
	echo cd .. >> "%~dp0TMP\pfs-pops.txt"
	echo umount >> "%~dp0TMP\pfs-pops.txt"
	echo exit >> "%~dp0TMP\pfs-pops.txt"
	type "%~dp0TMP\pfs-pops.txt" | "%~dp0BAT\pfsshell" >nul 2>&1
	
	if exist "%~dp0TMP\title.cfg" (
	"%~dp0BAT\busybox" sed -i "2s/boot=!RenamePS1Games!.ELF/boot=!RenamePS1GamesNEW!.ELF/" "%~dp0TMP\title.cfg"
	echo device !@pfsshell_path! > "%~dp0TMP\pfs-pops.txt"
	echo mount !OPLPART! >> "%~dp0TMP\pfs-pops.txt"
	if defined CUSTOM_OPLPART echo cd OPL >> "%~dp0TMP\pfs-pops.txt"
	echo cd APPS >> "%~dp0TMP\pfs-pops.txt"
	echo cd "!RenamePS1GamesNEW!" >> "%~dp0TMP\pfs-pops.txt"
	echo lcd "%~dp0TMP" >> "%~dp0TMP\pfs-pops.txt"
	echo put "title.cfg" >> "%~dp0TMP\pfs-pops.txt"
	echo cd .. >> "%~dp0TMP\pfs-pops.txt"
	echo umount >> "%~dp0TMP\pfs-pops.txt"
	echo exit >> "%~dp0TMP\pfs-pops.txt"
	type "%~dp0TMP\pfs-pops.txt" | "%~dp0BAT\pfsshell" >nul 2>&1
		)
	echo        "!RenamePS1GamesNEW!"
	echo         Completed...
	)
	
cd /d "%~dp0" & rmdir /Q/S "%~dp0TMP" >nul 2>&1

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo Renaming Completed...
echo\
echo\
"%~dp0BAT\Diagbox" gd 0f

pause & (goto GamesManagement)
REM #######################################################################################################################################################################
:DeleteChoiceGamesHDD
cls
cd "%~dp0"
mkdir "%~dp0TMP" >nul 2>&1

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Choose what type of games you want to delete:
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1^) Yes PS2 Games
REM PS2 Games Not yet available, I recommend you to delete the game directly from OPL
"%~dp0BAT\Diagbox" gd 0c
echo         2^) No
"%~dp0BAT\Diagbox" gd 0e
echo         3^) Yes PS1 Games (Delete .VCD)
echo\
"%~dp0BAT\Diagbox" gd 07
CHOICE /C 123 /M "Select Option:"

IF %ERRORLEVEL%==1 (goto DeletePS2GamesHDD)
IF %ERRORLEVEL%==2 (goto GamesManagement)
IF %ERRORLEVEL%==3 (goto DeletePS1GamesHDD)

REM #######################################################################################################################################################################
:DeletePS2GamesHDD
cls
mkdir "%~dp0TMP" >nul 2>&1
cd /d "%~dp0TMP"

IF NOT DEFINED @hdl_path ( rmdir /Q/S "%~dp0TMP" >nul 2>&1 & goto ScanningPS2HDD ) else (
"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning for Playstation 2 HDDs:
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "!@hdl_path!" | "%~dp0BAT\busybox" grep "Playstation 2 HDD" >nul
if errorlevel 1 set "@hdl_path=" & goto ScanningPS2HDD
echo       [!@hdl_path! !@TotalHDD_Size! - !@ModelePS2HDD!]
)

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Delete a PS2 game
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1^) Yes
"%~dp0BAT\Diagbox" gd 0c
echo         2^) No
echo\
"%~dp0BAT\Diagbox" gd 07
CHOICE /C 12 /M "Select Option:"

IF !ERRORLEVEL!==2 (goto GamesManagement)

"%~dp0BAT\Diagbox" gd 0e
cls
echo\
echo\
echo Scanning Games List:
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
type "%~dp0BAT\__Cache\PARTITION_HDL_GAME.txt" | "%~dp0BAT\busybox" sed "s/|.*//" | "%~dp0BAT\busybox" sort -k2 > "%~dp0TMP\GameListPS2.txt" & type "%~dp0TMP\GameListPS2.txt"
"%~dp0BAT\Diagbox" gd 0e
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0f

	"%~dp0BAT\Diagbox" gd 06
	echo\
	echo I recommend that you delete your games directly with OPL or wLaunchELF.
	echo After deletion, I recommend cleaning the hard drive with the PS2 application ^(HDD Checker^)
	echo\
	echo\
	"%~dp0BAT\Diagbox" gd 0e
	echo Please type the gameid ^+ GameName as shown in the Games List.
	"%~dp0BAT\Diagbox" gd 07
	set "gname="
    set /p gname=
    if "!gname!"=="" (goto DeletePS2GamesHDD)
	if "!gname!"=="!gname:~0,11!" set "gname=!gname:~0,11! "

	"%~dp0BAT\busybox" grep -Fx "!gname!" "%~dp0TMP\GameListPS2.txt" >nul
	if errorlevel 1 (
    "%~dp0BAT\Diagbox" gd 0c
	echo         NOT Detected
	echo\
	echo\
	"%~dp0BAT\Diagbox" gd 07
	rmdir /Q/S "%~dp0TMP" >nul 2>&1
	pause & (goto DeletePS2GamesHDD)
	) else ("%~dp0BAT\busybox" grep -F -w -m 1 "!gname!" "%~dp0BAT\__Cache\PARTITION_HDL_GAME.txt" > "%~dp0TMP\PARTITION_HDL_GAME.txt")

cls
echo\
echo\
echo !gname!
echo ---------------------------------------------------
echo\

    for /f "usebackq tokens=1* delims=|" %%f in ("%~dp0TMP\PARTITION_HDL_GAME.txt") do (

   	setlocal DisableDelayedExpansion
	set fname=%%f
	set pname=%%g
	setlocal EnableDelayedExpansion
	
	echo        Deleting..
  	echo device !@pfsshell_path!> "%~dp0TMP\pfs-log.txt"
	echo rmpart "!pname!">> "%~dp0TMP\pfs-log.txt"
  	echo exit>> "%~dp0TMP\pfs-log.txt"
	type "%~dp0TMP\pfs-log.txt" | "%~dp0BAT\pfsshell" >nul 2>&1
	echo        Completed...
	
	 endlocal
	endlocal
	)

REM Reloading HDD Cache
call "%~dp0BAT\__ReloadHDD_cache.bat" >nul 2>&1
	
cd /d "%~dp0" & rmdir /Q/S "%~dp0TMP" >nul 2>&1

echo\
echo\
"%~dp0BAT\Diagbox" gd 0f
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo Completed...
echo\
echo\
"%~dp0BAT\Diagbox" gd 07

pause & (goto GamesManagement)
REM #######################################################################################################################################################################
:DeletePS1GamesHDD
cls
cd "%~dp0"
mkdir "%~dp0TMP" >nul 2>&1
cd /d "%~dp0TMP"

IF NOT DEFINED @hdl_path ( rmdir /Q/S "%~dp0TMP" >nul 2>&1 & goto ScanningPS2HDD ) else (
"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning for Playstation 2 HDDs:
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "!@hdl_path!" | "%~dp0BAT\busybox" grep "Playstation 2 HDD" >nul
if errorlevel 1 set "@hdl_path=" & goto ScanningPS2HDD
echo       [!@hdl_path! !@TotalHDD_Size! - !@ModelePS2HDD!]
)

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Delete a PS1 game in a POPS partition:
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1^) Yes
"%~dp0BAT\Diagbox" gd 0c
echo         2^) No
echo\
"%~dp0BAT\Diagbox" gd 07
CHOICE /C 12 /M "Select Option:"

IF %ERRORLEVEL%==2 (goto GamesManagement)

"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Detecting POPS Partition:
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0f
	
	"%~dp0BAT\busybox" grep -w "__.POPS\|__.POPS[0-9]" "%~dp0BAT\__Cache\PARTITION_PS2HDD.txt" | "%~dp0BAT\busybox" sort -k5 > "%~dp0TMP\hdd-prt.txt"
	"%~dp0BAT\busybox" sed -e "/^$/d" "%~dp0TMP\hdd-prt.txt" | "%~dp0BAT\busybox" wc -l > "%~dp0TMP\TotalPOPSPart.txt" & set /P @TotalPOPSPart=<"%~dp0TMP\TotalPOPSPart.txt"
	
	for /f "usebackq tokens=1,2,3,4,5" %%f in ("%~dp0TMP\hdd-prt.txt") do (
	set PartSize=%%i
	set POPSPART=%%j
	set TotalUsed=0
	set Remaining=
	 
	echo device !@pfsshell_path! > "%~dp0TMP\pfs-pops.txt"
	echo mount !POPSPART! >> "%~dp0TMP\pfs-pops.txt"
	echo ls -l >> "%~dp0TMP\pfs-pops.txt"
	echo umount >> "%~dp0TMP\pfs-pops.txt"
	type "%~dp0TMP\pfs-pops.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" grep -ie ".*\.VCD$" > "%~dp0TMP\PFS-POPS.log"
	
	for /f "usebackq tokens=1,2,3,4*" %%f in ("%~dp0TMP\PFS-POPS.log") do (
	set /a "TotalUsed+=%%g / 1048576"
	setlocal DisableDelayedExpansion
	set filename=%%j
	set fname=%%~nj
	set game_size=%%g
	setlocal EnableDelayedExpansion
	if "!POPSPART!"=="__.POPS" set "POPSPART=__.POPS "
	echo !POPSPART! - !game_size! - !fname!>>"%~dp0TMP\Games_Installed_tmp.txt"
		endlocal
	endlocal
	)
	
	set /a Remaining=!PartSize:~0,-2! - !TotalUsed!
	echo Name: [!POPSPART!] - Size: [!PartSize!] - Used: [!TotalUsed!MB] - Free: [!Remaining!MB]
	)

	if "!POPSPART!"=="" (
	"%~dp0BAT\Diagbox" gd 0c
	echo            No POPS partition detected
	echo            Partition Must Be Created
	echo\
	echo\
	"%~dp0BAT\Diagbox" gd 07
	rmdir /Q/S "%~dp0TMP" >nul 2>&1
	pause & (goto mainmenu)
	)

echo\
echo\
pause
cls

"%~dp0BAT\Diagbox" gd 07
echo\
echo\
echo Scanning Games List
echo ---------------------------------------------------
echo [Parts]:   [Size]:     [Name]:
"%~dp0BAT\Diagbox" gd 0e
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 07
"%~dp0BAT\busybox" sed -n "/[A-Z][A-Z][A-Z][A-Z]_[0-9][0-9][0-9]\.[0-9][0-9]/p" "%~dp0TMP\Games_Installed_tmp.txt" | "%~dp0BAT\busybox" sort -k5.14 > "%~dp0TMP\Games_Installed.txt"
"%~dp0BAT\busybox" sed -n "/[A-Z][A-Z][A-Z][A-Z]_[0-9][0-9][0-9]\.[0-9][0-9]/^!p" "%~dp0TMP\Games_Installed_tmp.txt" | "%~dp0BAT\busybox" sort -k5 >> "%~dp0TMP\Games_Installed.txt"
type "%~dp0TMP\Games_Installed.txt"
"%~dp0BAT\Diagbox" gd 0e
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 07

echo\
echo Example: MyGameToDelete
"%~dp0BAT\Diagbox" gd 06
echo Respect upper and lower case
"%~dp0BAT\Diagbox" gd 07
echo.
set /p "DeletePS1Games=Enter the name of the game you want to Delete:"
IF "!DeletePS1Games!"=="" rmdir /Q/S "%~dp0TMP" >nul 2>&1 & (goto GamesManagement)
"%~dp0BAT\busybox" grep "!DeletePS1Games!" "%~dp0TMP\Games_Installed_tmp.txt" > "%~dp0TMP\Games_Installed_Selected.txt"

"%~dp0BAT\Diagbox" gd 0e
cls
echo\
echo\
echo "!DeletePS1Games!"
"%~dp0BAT\Diagbox" gd 0f
echo ---------------------------------------------------
echo\
	
	for /f "usebackq tokens=1,2,3,4*" %%f in ("%~dp0TMP\Games_Installed_Selected.txt") do (
	echo          Removing...
	echo device !@pfsshell_path! > "%~dp0TMP\pfs-pops.txt"
	echo mount %%f >> "%~dp0TMP\pfs-pops.txt"
	echo rename "!DeletePS1Games!.vcd" "!DeletePS1Games!.VCD" >> "%~dp0TMP\pfs-pops.txt"
	echo rm "!DeletePS1Games!.VCD" >> "%~dp0TMP\pfs-pops.txt"
	echo umount >> "%~dp0TMP\pfs-pops.txt"
	)
	
	REM Del PS1 Shortcut APPS
	echo mount !OPLPART! >> "%~dp0TMP\pfs-pops.txt"
	if defined CUSTOM_OPLPART echo mkdir OPL>> "%~dp0TMP\pfs-pops.txt"
	if defined CUSTOM_OPLPART echo cd OPL >> "%~dp0TMP\pfs-pops.txt"
	echo cd APPS >> "%~dp0TMP\pfs-pops.txt"
	echo cd "!DeletePS1Games!" >> "%~dp0TMP\pfs-pops.txt"
	echo rm "!DeletePS1Games!.ELF" >> "%~dp0TMP\pfs-pops.txt"
	echo rm "title.cfg" >> "%~dp0TMP\pfs-pops.txt"
	echo cd .. >> "%~dp0TMP\pfs-pops.txt"
	echo rmdir "!DeletePS1Games!" >> "%~dp0TMP\pfs-pops.txt"
	echo umount >> "%~dp0TMP\pfs-pops.txt"
	echo exit >> "%~dp0TMP\pfs-pops.txt"
	type "%~dp0TMP\pfs-pops.txt" | "%~dp0BAT\pfsshell" >nul 2>&1
    echo          Completed...
	
cd /d "%~dp0" & rmdir /Q/S "%~dp0TMP" >nul 2>&1

echo\
echo\
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo Removing Completed...
echo\
echo\
"%~dp0BAT\Diagbox" gd 0f

pause & (goto GamesManagement)
REM ####################################################################################################################
:ChangeOPLResources
cls
mkdir "%~dp0TMP" >nul 2>&1
cd /d "%~dp0TMP"

IF NOT DEFINED @hdl_path ( rmdir /Q/S "%~dp0TMP" >nul 2>&1 & goto ScanningPS2HDD ) else (
"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning for Playstation 2 HDDs:
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "!@hdl_path!" | "%~dp0BAT\busybox" grep "Playstation 2 HDD" >nul
if errorlevel 1 set "@hdl_path=" & goto ScanningPS2HDD
echo       [!@hdl_path! !@TotalHDD_Size! - !@ModelePS2HDD!]
)

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Change OPL Resources partition^?
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1^) Yes
"%~dp0BAT\Diagbox" gd 0c
echo         2^) No
echo\
"%~dp0BAT\Diagbox" gd 0f
CHOICE /C 12 /M "Select Option:"

IF %ERRORLEVEL%==2 (goto OPLManagement)

cls
echo\
echo\
echo Your currently used resource partition is: [!OPLPART!]
"%~dp0BAT\Diagbox" gd 0e
echo It is recommended to use the ^+OPL partition by default
echo The ^+OPL partition allows you to use recent and old versions of OPL
echo\
echo If you choose a partition other than ^+OPL, only versions from v1.1.0 will be compatible.
"%~dp0BAT\Diagbox" gd 0f
echo\
echo 1. [+OPL]
echo 2. [__common]
echo 3. Custom Partition
echo\
CHOICE /C 123 /M "Select Option:"

IF !ERRORLEVEL!==1 set OPLPART_NEW=+OPL
IF !ERRORLEVEL!==2 set "CUSTOM_OPLPART=Yes" & set OPLPART_NEW=__common
IF !ERRORLEVEL!==3 set "CUSTOM_OPLPART=Yes" & set CUSTOM_OPLUSER=Yes

echo\
echo\
"%~dp0BAT\Diagbox" gd 0e
echo Do you want to add OPNPS2LD.ELF at the root of the new OPL resource partition^?
"%~dp0BAT\Diagbox" gd 07
echo this allows you to launch games from HDD-OSD, PSBBN, XMB
CHOICE /C YN /M "Select Option:"
IF !ERRORLEVEL!==1 set OPLELFROOT=Yes

if !CUSTOM_OPLUSER!==Yes (
echo\
echo\
"%~dp0BAT\Diagbox" gd 0f
echo Scanning Partitions:
echo ---------------------------------------------------
"%~dp0BAT\busybox" sed "/0x1337/d; /\.POPS\./d" "%~dp0BAT\__Cache\PARTITION_PS2HDD.txt" | "%~dp0BAT\busybox" sed "$d" > "%~dp0TMP\PARTITION_SYSTEM.txt" & type "%~dp0TMP\PARTITION_SYSTEM.txt"
echo ---------------------------------------------------
echo\
echo\
set /p OPLPART_NEW="Enter the partition name:"
IF "!OPLPART_NEW!"=="" (goto OPLManagement)
)

"%~dp0BAT\Diagbox" gd 0e
cls
echo\
echo\
echo Change the partition path
"%~dp0BAT\Diagbox" gd 0f
echo ---------------------------------------------------
echo\

	 echo            Change in progress...
	 echo device !@pfsshell_path! > "%~dp0TMP\pfs-OPLconfig.txt"
     echo mount __common >> "%~dp0TMP\pfs-OPLconfig.txt"
     echo mkdir OPL >> "%~dp0TMP\pfs-OPLconfig.txt"
	 echo cd OPL >> "%~dp0TMP\pfs-OPLconfig.txt"
	 echo lcd "%~dp0HDD-OSD\__common\OPL" >> "%~dp0TMP\pfs-OPLconfig.txt"
	 echo hdd_partition=!OPLPART_NEW!> "%~dp0HDD-OSD\__common\OPL\conf_hdd.cfg"
	 echo rm conf_hdd.cfg >> "%~dp0TMP\pfs-OPLconfig.txt"
     echo put conf_hdd.cfg >> "%~dp0TMP\pfs-OPLconfig.txt"
	 echo cd .. >> "%~dp0TMP\pfs-OPLconfig.txt"
	 echo umount >> "%~dp0TMP\pfs-OPLconfig.txt"
	 
	 if !OPLELFROOT!==Yes (
	 "%~dp0BAT\7-Zip\7z" e -bso0 "%~dp0BAT\APPS.zip" -o"%~dp0TMP\OPL_STABLE" "APPS\Open PS2 Loader Stable\*.ELF" -r -y >nul 2>&1 & move "%~dp0TMP\OPL_STABLE\*.ELF" "%~dp0TMP\OPNPS2LD.ELF" >nul 2>&1
	 echo mount !OPLPART! >> "%~dp0TMP\pfs-OPLconfig.txt"
	 if defined CUSTOM_OPLPART echo mkdir OPL >> "%~dp0TMP\pfs-OPLconfig.txt"
	 if defined CUSTOM_OPLPART echo cd OPL >> "%~dp0TMP\pfs-OPLconfig.txt"
	 echo lcd "%~dp0TMP" >> "%~dp0TMP\pfs-OPLconfig.txt"
	 echo rm OPNPS2LD.ELF >> "%~dp0TMP\pfs-OPLconfig.txt"
	 echo put OPNPS2LD.ELF >> "%~dp0TMP\pfs-OPLconfig.txt"
	 echo cd .. >> "%~dp0TMP\pfs-OPLconfig.txt"
	 echo umount >> "%~dp0TMP\pfs-OPLconfig.txt"
	 )
	 
	 echo exit >> "%~dp0TMP\pfs-OPLconfig.txt"
	 type "%~dp0TMP\pfs-OPLconfig.txt" | "%~dp0BAT\pfsshell" >nul 2>&1
	 
	 if !OPLPART_NEW!==+OPL (
	 "%~dp0BAT\busybox" sed -i "/^set OPLPART=/s/.*/set OPLPART=!OPLPART_NEW!/g; /^set CUSTOM_OPLPART=/s/.*/set CUSTOM_OPLPART=/g" "%~dp0\BAT\__Cache\HDD.BAT"
	 ) else (
	 "%~dp0BAT\busybox" sed -i "/^set OPLPART=/s/.*/set OPLPART=!OPLPART_NEW!/g; /^set CUSTOM_OPLPART=/s/.*/set CUSTOM_OPLPART=Yes/g" "%~dp0\BAT\__Cache\HDD.BAT"
	 )
	 echo            [!OPLPART!] To [!OPLPART_NEW!]

cd /d "%~dp0" & rmdir /Q/S "%~dp0TMP" >nul 2>&1

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo Completed...
echo\
echo\
"%~dp0BAT\Diagbox" gd 07

pause & (goto OPLManagement)
REM ####################################################################################################################
:CreateShortcutsOPL
cls
mkdir "%~dp0TMP" >nul 2>&1
cd /d "%~dp0TMP"

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Create shortcuts for OPL APPS tab
echo ---------------------------------------------------
 "%~dp0BAT\Diagbox" gd 0a
echo         1^) Yes ^(APPS^)
 "%~dp0BAT\Diagbox" gd 0c
echo         2^) No
"%~dp0BAT\Diagbox" gd 0e
echo         3^) Yes ^(PS1 Games^)
echo\
"%~dp0BAT\Diagbox" gd 07
CHOICE /C 123 /M "Select Option:"

IF !ERRORLEVEL!==1 cls & call "%~dp0BAT\make_title_cfg.bat" & echo\ & echo\ & rmdir /Q/S "%~dp0TMP" >nul 2>&1 & pause & (goto OPLManagement)
IF !ERRORLEVEL!==2 (goto OPLManagement)

echo\
echo\
echo What device will you be using^?
echo 1 = HDD ^(Internal^)
echo 2 = USB
CHOICE /C 12 /M "Select Option:"
IF !ERRORLEVEL!==1 set "device=HDD" & set dfolder=TMP\ShortCut
IF !ERRORLEVEL!==2 set "device=USB" & set "USBCONF=XX." & set dfolder=APPS

cls
if !device!==HDD (
IF NOT DEFINED @hdl_path ( rmdir /Q/S  "%~dp0TMP" >nul 2>&1 & goto ScanningPS2HDD ) else (
"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning for Playstation 2 HDDs:
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
 "%~dp0BAT\hdl_dump" query |  "%~dp0BAT\busybox" grep "!@hdl_path!" |  "%~dp0BAT\busybox" grep "Playstation 2 HDD" >nul
if errorlevel 1 set "@hdl_path=" & goto ScanningPS2HDD
echo       [!@hdl_path! !@TotalHDD_Size! - !@ModelePS2HDD!]
	)
)

echo\
echo\
if !device!==USB (
"%~dp0BAT\Diagbox" gd 0e
echo Do you want to change the default directory^?
"%~dp0BAT\Diagbox" gd 07
echo ^(Useful if your POPS folder are on another HDD^)
CHOICE /C YN
echo\
if !errorlevel!==1 (
echo Example: E:\
set /p "HDDPATH=Enter the root path where yours APPS folder:"
	)
)
if not defined HDDPATH set HDDPATH=%rootpath%

echo\
"%~dp0BAT\Diagbox" gd 0e
echo Do you want to add a prefix^? in front of shortcut names
"%~dp0BAT\Diagbox" gd 07
CHOICE /C YN
IF !ERRORLEVEL!==1 (
echo\
echo Select Prefix option
echo 1 = [PS1]
echo 2 = CUSTOM
echo 3 = Nothing
CHOICE /C 123
IF !ERRORLEVEL!==1 set prefix=[PS1]
IF !ERRORLEVEL!==2 echo\& set /p "prefix=Enter your prefix:"
IF !ERRORLEVEL!==3 set "prefix="

echo\
echo As it will be displayed Example: !Prefix!MyGameName
echo Confirm^?
CHOICE /C YN
IF !ERRORLEVEL!==2 goto CreateShortcutsOPL
)

if !device!==HDD (
"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Detecting OPL Resources Partition:
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0f

    "%~dp0BAT\busybox" grep -ow "!OPLPART!" "%~dp0BAT\__Cache\PARTITION_PS2HDD.txt" > "%~dp0TMP\hdd-prt.txt" & set /P @hdd_avl=<"%~dp0TMP\hdd-prt.txt"
	
	IF "!@hdd_avl!"=="!OPLPART!" (
	"%~dp0BAT\Diagbox" gd 0a
		echo            !OPLPART! - Partition Detected
	"%~dp0BAT\Diagbox" gd 0f
		) else (
		"%~dp0BAT\Diagbox" gd 0c
		echo         !OPLPART! - Partition NOT Detected
		echo             Partition Must Be Created
		echo\
		echo\
		"%~dp0BAT\Diagbox" gd 0f
		rmdir /Q/S "%~dp0TMP" >nul 2>&1
		pause & (goto DownloadARTChoice)
		)

"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Detecting POPS Partition:
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0f

    "%~dp0BAT\busybox" grep -o "__.POPS\|__.POPS[0-9]" "%~dp0BAT\__Cache\PARTITION_PS2HDD.txt" > "%~dp0TMP\POPSPART.txt" & set /P @POPSPART=<"%~dp0TMP\POPSPART.txt"

    if defined @POPSPART (
    "%~dp0BAT\Diagbox" gd 0a
    echo        	    Partition - Detected
	"%~dp0BAT\Diagbox" gd 07
	) else (
	"%~dp0BAT\Diagbox" gd 0c
	echo              No POPS partition detected
	echo               Partition Must Be Created
	echo\
	echo\
	"%~dp0BAT\Diagbox" gd 07
	rmdir /Q/S "%~dp0TMP" >nul 2>&1
	pause & (goto DownloadARTChoice)
	)
  
echo\
echo\
pause
)

"%~dp0BAT\Diagbox" gd 0e
cls
echo\
echo\
echo Scanning Games List:
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 03

if !device!==HDD (
	for /f "usebackq tokens=*" %%p in ("%~dp0TMP\POPSPART.txt") do (
	set POPSPART=%%p
	echo device !@pfsshell_path! > "%~dp0TMP\pfs-pops.txt"
	echo mount !POPSPART! >> "%~dp0TMP\pfs-pops.txt"
	echo ls >> "%~dp0TMP\pfs-pops.txt"
	echo umount >> "%~dp0TMP\pfs-pops.txt"
	echo exit >> "%~dp0TMP\pfs-pops.txt"
	type "%~dp0TMP\pfs-pops.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" grep -ie ".*\.VCD$" >> "%~dp0TMP\PS1GamesTMP.txt"
	)
) else (cd /d "!HDDPATH!\POPS" & dir /b /a-d > "%~dp0TMP\PS1GamesTMP.txt")

"%~dp0BAT\busybox" grep -iE "([A-Z]{4}_[0-9]{3}\.[0-9]{2}|[A-Z]{3}[0-9]{5}\.[0-9]{3})" "%~dp0TMP\PS1GamesTMP.txt" > "%~dp0TMP\PS1Games.txt" & type "%~dp0TMP\PS1Games.txt"

"%~dp0BAT\Diagbox" gd 0e
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0f

set /a gamecount=0
for /f "usebackq delims=" %%f in ("%~dp0TMP\PS1Games.txt") do (
set /a gamecount+=1

	setlocal DisableDelayedExpansion
	set filename=%%f
	set APPFolder=%%~nf
	setlocal EnableDelayedExpansion

	echo\
	echo\
	echo !gamecount! - !filename!

	REM Create Game Folder + POPStarter ELF
	md "!HDDPATH!\!dfolder!\!APPFolder!" >nul 2>&1
	copy "%~dp0POPS-Binaries\POPSTARTER.ELF" "!HDDPATH!\!dfolder!\!APPFolder!\!USBCONF!!APPFolder!.ELF" >nul 2>&1
	
	REM GET Serial ID
	if "!APPFolder:~0,3!"=="LSP" (
	set "gameid=!APPFolder:~0,8!!APPFolder:~9,1!" & set APPTitle=!APPFolder:~16!
	) else (
	set "gameid=!APPFolder:~0,4!-!APPFolder:~5,3!!APPFolder:~9,2!" & set APPTitle=!APPFolder:~12!
	)

	REM Create ShortCut
	echo title=!Prefix!!APPTitle!>"!HDDPATH!\!dfolder!\!APPfolder!\title.cfg"
	echo boot=!USBCONF!!APPfolder!.ELF>>"!HDDPATH!\!dfolder!\!APPfolder!\title.cfg"

	REM Added Infos
	if exist "%~dp0BAT\PS1DB.xml" "%~dp0BAT\busybox" sed -n "/<game serial=\"!gameid!\">/{:a;N;/<\/game>/^!ba;s/.*<game serial=\"!gameid!\">\(.*\)<\/game>.*/\1/p}" "%~dp0BAT\PS1DB.xml" | "%~dp0BAT\busybox" sed -e "s/<\([^>]*\)>\([^<]*\)<\/\1>/\1=\2/g; s/<\([^>]*\) \/>/\1=/g; s/^[ \t]*//; s/[ \t]*$//; /^$/d" >> "!HDDPATH!\!dfolder!\!APPfolder!\title.cfg"

	if !device!==HDD (
	echo device !@pfsshell_path! > "%~dp0TMP\pfs-log.txt"
	echo mount !OPLPART! >> "%~dp0TMP\pfs-log.txt"
	if defined CUSTOM_OPLPART echo mkdir OPL >> "%~dp0TMP\pfs-log.txt"
	if defined CUSTOM_OPLPART echo cd OPL >> "%~dp0TMP\pfs-log.txt"
	echo mkdir APPS >> "%~dp0TMP\pfs-log.txt"
	echo cd APPS >> "%~dp0TMP\pfs-log.txt"
	echo mkdir "!APPFolder!" >> "%~dp0TMP\pfs-log.txt"
	
	cd /d "!HDDPATH!\!dfolder!\!APPFolder!"
	echo cd "!APPFolder!" >> "%~dp0TMP\pfs-log.txt"
	echo put title.cfg >> "%~dp0TMP\pfs-log.txt"
	echo put "!APPFolder!.ELF" >> "%~dp0TMP\pfs-log.txt"
	echo cd .. >> "%~dp0TMP\pfs-log.txt"
	
	echo umount >> "%~dp0TMP\pfs-log.txt"
	echo exit >> "%~dp0TMP\pfs-log.txt"
	type "%~dp0TMP\pfs-log.txt" | "%~dp0BAT\pfsshell" >nul 2>&1
	)
	
	echo        Completed...
	
	endlocal
endlocal
)

cd /d "%~dp0" & rmdir /Q/S "%~dp0TMP" >nul 2>&1

echo\
echo\
pause & (goto OPLManagement)
REM ####################################################################################################################
:CreateVMC
cls
mkdir "%~dp0TMP" >nul 2>&1
cd /d "%~dp0TMP"

IF NOT DEFINED @hdl_path ( rmdir /Q/S "%~dp0TMP" >nul 2>&1 & goto ScanningPS2HDD ) else (
"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning for Playstation 2 HDDs:
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "!@hdl_path!" | "%~dp0BAT\busybox" grep "Playstation 2 HDD" >nul
if errorlevel 1 set "@hdl_path=" & goto ScanningPS2HDD
echo       [!@hdl_path! !@TotalHDD_Size! - !@ModelePS2HDD!]
)

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Create Virtual Memory Card^? [VMC]
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1^) Yes
"%~dp0BAT\Diagbox" gd 0c
echo         2^) No
echo\
"%~dp0BAT\Diagbox" gd 0f
CHOICE /C 12 /M "Select Option:"

IF ERRORLEVEL 2 (goto OPLManagement)

"%~dp0BAT\Diagbox" gd 0e
cls
echo\
echo\
echo Create Virtual Memory Card
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
type "%~dp0BAT\__Cache\PARTITION_HDL_GAME.txt" | "%~dp0BAT\busybox" sed "s/|.*//" | "%~dp0BAT\busybox" sort -k2 > "%~dp0TMP\GameListPS2.txt" & type "%~dp0TMP\GameListPS2.txt"
"%~dp0BAT\Diagbox" gd 0e
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0f

echo\
echo Choose the Type of Virtual Memory Card you want
echo\
"%~dp0BAT\Diagbox" gd 0e
echo 1. Individual (It will create a memory card for each games)
echo 2. Multi (It will create a single memory card called GENERIC_0.BIN)
echo\
echo NOTE: Option Multi Lets you save multiple games on the same memory card file
"%~dp0BAT\Diagbox" gd 06
echo NOTE: Some games may not be compatible with virtual memory cards
"%~dp0BAT\Diagbox" gd 0f
echo\
CHOICE /C 12 /M "Select Option:"
IF ERRORLEVEL 1 set "VMC_TYPE=INDIVIDUAL"
IF ERRORLEVEL 2 set "VMC_TYPE=GENERIC" & echo GENERIC>"%~dp0TMP\GameListPS2.txt"

"%~dp0BAT\Diagbox" gd 0f
echo\
echo Choose size of your Virtual Memory Card
"%~dp0BAT\Diagbox" gd 0e
echo 1.  8 MB [Recommended]
echo 2. 16 MB
echo 3. 32 MB
echo\
CHOICE /C 123 /M "Select Option:"

IF %ERRORLEVEL%==1 set VMC_SIZE=8
IF %ERRORLEVEL%==2 set VMC_SIZE=16
IF %ERRORLEVEL%==3 set VMC_SIZE=32

"%~dp0BAT\Diagbox" gd 0f
echo ---------------------------------------------------

    for /f "tokens=1*" %%f in (GameListPS2.txt) do (
    if !VMC_TYPE!==INDIVIDUAL (
	set VMC_NAME=%%f
	echo\
    echo %%g
    echo %%f
	) else (
	set VMC_NAME=GENERIC
	echo Individual !VMC_TYPE!_0
	)
    echo !VMC_SIZE!MB
    cd /d "%~dp0VMC" & "%~dp0BAT\genvmc.exe" !VMC_SIZE! !VMC_NAME!_0.bin | findstr "created"
    )

cd /d "%~dp0" & rmdir /Q/S "%~dp0TMP" >nul 2>&1

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo Completed...
echo\
echo\
"%~dp0BAT\Diagbox" gd 07

pause & (goto OPLManagement)
REM ####################################################################################################################
:TransferPS1GamesHDDOSD
cls
mkdir "%~dp0TMP" >nul 2>&1
cd /d "%~dp0TMP"
set PartitionType=PS1

IF NOT DEFINED @hdl_path ( rmdir /Q/S "%~dp0TMP" >nul 2>&1 & goto ScanningPS2HDD ) else (
"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning for Playstation 2 HDDs:
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "!@hdl_path!" | "%~dp0BAT\busybox" grep "Playstation 2 HDD" >nul
if errorlevel 1 set "@hdl_path=" & goto ScanningPS2HDD
echo       [!@hdl_path! !@TotalHDD_Size! - !@ModelePS2HDD!]
)

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Make sure your Multi-Discs have the (Disc #) ^in the name. Example:
echo\
echo Gran Turismo 2 (Disc 1) (Arcade Mode).VCD
echo Gran Turismo 2 (Disc 2) (Gran Turismo Mode).VCD
echo\
echo Install PS1 Games as partition for HDD-OSD
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1^) Yes ^(Install each Multi-Disc as a single partition^)
"%~dp0BAT\Diagbox" gd 0c
echo         2^) No
"%~dp0BAT\Diagbox" gd 0e
echo         3^) Yes ^(Install each Multi-Disc in the same partition as Disc 1^)
"%~dp0BAT\Diagbox" gd 0f
echo\
CHOICE /C 123 /M "Select Option:"

IF %ERRORLEVEL%==1 set @pfs_POPS_HDDOSD=OnlyOneDisc
IF %ERRORLEVEL%==2 if defined @pfs_popHDDOSDMAIN (goto mainmenu) else (goto HDDOSDPartManagement)
IF %ERRORLEVEL%==3 set @pfs_POPS_HDDOSD=MultiDisc

if not exist "%~dp0BAT\TitlesDB\TitlesDB_PS1_!TitlesLang!.txt" set "TitlesLang=English"
copy "%~dp0BAT\TitlesDB\TitlesDB_PS1_!TitlesLang!.txt" "%~dp0TMP\TitlesDB_PS1_!TitlesLang!.txt" >nul 2>&1

if /i exist "%~dp0ART.zip" (
echo\
"%~dp0BAT\Diagbox" gd 0e
echo ART.zip detected do you want use it^?
"%~dp0BAT\Diagbox" gd 0f
CHOICE /C YN /M "Select Option:"
IF ERRORLEVEL 1 set uselocalART=yes
IF ERRORLEVEL 2 set uselocalART=no
) else (set uselocalART=no)

if !uselocalART!==no (
    echo\
	echo Checking internet Or Website connection... For ART
	ping -n 1 -w 2000 archive.org >nul
	if errorlevel 1 (
			"%~dp0BAT\Diagbox" gd 0c
			echo Unable to PING^^!
			if /i exist "%~dp0ART.zip" set uselocalART=yes
			"%~dp0BAT\Diagbox" gd 07
			) else (

	"%~dp0BAT\wget" -q --show-progress "https://archive.org/download/OPLM_ART_2024_09/OPLM_ART_2024_09.zip/PS1%%2FSCES_000.01%%2FSCES_000.01_COV.png" -O "%~dp0TMP\SCES_000.01_COV.png" >nul 2>&1
	for %%F in (SCES_000.01_COV.png) do if %%~zF==0 del "%%F"

if not exist SCES_000.01_COV.png (
"%~dp0BAT\Diagbox" gd 0c
    echo\
	echo Unable to connect to internet Or Website
	if /i exist "%~dp0ART.zip" set uselocalART=yes
	echo You will switch to offline mode
	echo\
	echo\
"%~dp0BAT\Diagbox" gd 0f
	pause
		) else (set DownloadART=yes)
	)
)

if exist "%~dp0HDD-OSD-Icons-Pack.zip" (
echo\
"%~dp0BAT\Diagbox" gd 0e
echo HDD-OSD-Icons-Pack.zip detected do you want use it^?
"%~dp0BAT\Diagbox" gd 0f
CHOICE /C YN /M "Select Option:"
IF ERRORLEVEL 1 set uselocalARTHDDOSD=yes
IF ERRORLEVEL 2 set uselocalARTHDDOSD=no
) else (set uselocalARTHDDOSD=no)

if !uselocalARTHDDOSD!==no (
    echo\
	echo Checking internet Or Website connection... For HDD-OSD ART
	ping -n 1 -w 2000 archive.org >nul
	if errorlevel 1 (
			"%~dp0BAT\Diagbox" gd 0c
			echo Unable to PING^^!
			if exist "%~dp0HDD-OSD-Icons-Pack.zip" set uselocalARTHDDOSD=yes
			"%~dp0BAT\Diagbox" gd 07
			) else (
			
	"%~dp0BAT\wget" -q --show-progress "https://archive.org/download/hdd-osd-icons-pack/HDD-OSD-Icons-Pack.zip/PS1%%2FSCES_000.01%%2FPreview.png" -O "%~dp0TMP\Preview.png" >nul 2>&1
	for %%F in (Preview.png) do if %%~zF==0 del "%%F"

if not exist Preview.png (
"%~dp0BAT\Diagbox" gd 0c
    echo\
	echo Unable to connect to internet Or Website
	if exist "%~dp0HDD-OSD-Icons-Pack.zip" set uselocalARTHDDOSD=yes
	echo You will switch to offline mode
	echo\
	echo\
"%~dp0BAT\Diagbox" gd 0f
	pause
		) else (set DownloadARTHDDOSD=yes)
	)
)

if exist "%~dp0POPS-Binaries\Hugopocked_POPStarter_Fixes.zip" "%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0POPS-Binaries\Hugopocked_POPStarter_Fixes.zip" -o"%~dp0TMP" id.txt -r -y >nul 2>&1

REM Delete (Disc #) In Title name if you install MultiDiscs in the same partition as disc 1
if !@pfs_POPS_HDDOSD!==MultiDisc "%~dp0BAT\busybox" sed "s/ (Disc [1-6]).*//g" "%~dp0BAT\TitlesDB\TitlesDB_PS1_!TitlesLang!.txt" > "%~dp0TMP\TitlesDB_PS1_!TitlesLang!.txt"

cls
IF /I EXIST "%~dp0POPS\*.VCD" (
	REM Scan Disc 0,1,2,3,4
    dir "%~dp0POPS" /b /a-d 2>&1| "%~dp0BAT\busybox" grep -ie ".*\.VCD$" > "%~dp0TMP\DiscX.txt"
    for /f "usebackq tokens=*" %%f in ("%~dp0TMP\DiscX.txt") do (
	
	setlocal DisableDelayedExpansion
	set filename=%%f
	set fname=%%~nf
	set "DiscMain="
	set "Disc2="
	set "Disc3="
	set "Disc4="
	setlocal EnableDelayedExpansion
	
	if !@pfs_POPS_HDDOSD!==OnlyOneDisc (
	echo "!fname!"> "%~dp0TMP\DiscMain.txt" & set /P DiscMain=<"%~dp0TMP\DiscMain.txt"
	) else (
	echo "!fname!"| "%~dp0BAT\busybox" sed -e "/(Disc [1-6])/d" > "%~dp0TMP\DiscMain.txt" & set /P DiscMain=<"%~dp0TMP\DiscMain.txt"
	echo "!fname!"| "%~dp0BAT\busybox" grep -ie "(Disc 1)" > "%~dp0TMP\DiscMain.txt" & set /P DiscMain=<"%~dp0TMP\DiscMain.txt"
	echo "!fname!"| "%~dp0BAT\busybox" grep -ie "(Disc 2)" > "%~dp0TMP\Disc2.txt" & set /P Disc2=<"%~dp0TMP\Disc2.txt"
	echo "!fname!"| "%~dp0BAT\busybox" grep -ie "(Disc 3)" > "%~dp0TMP\Disc3.txt" & set /P Disc3=<"%~dp0TMP\Disc3.txt"
	echo "!fname!"| "%~dp0BAT\busybox" grep -ie "(Disc 4)" > "%~dp0TMP\Disc4.txt" & set /P Disc4=<"%~dp0TMP\Disc4.txt"
	)
	if defined DiscMain echo !fname!> "%~dp0TMP\fnameMain.txt"
	
	if exist "%~dp0TMP\fnameMain.txt" set /P fnameMain=<"%~dp0TMP\fnameMain.txt"
	md "%~dp0POPS\Temp\!fnameMain!\res\image" >nul 2>&1
	if defined DiscMain move "%~dp0POPS\!filename!" "%~dp0POPS\Temp\!fnameMain!" >nul 2>&1
    if defined Disc2 move "%~dp0POPS\!filename!" "%~dp0POPS\Temp\!fnameMain!" >nul 2>&1
	if defined Disc3 move "%~dp0POPS\!filename!" "%~dp0POPS\Temp\!fnameMain!" >nul 2>&1
	if defined Disc4 move "%~dp0POPS\!filename!" "%~dp0POPS\Temp\!fnameMain!" >nul 2>&1
 endlocal
endlocal
)

cd /d "%~dp0POPS\Temp"
set /a gamecount=0
for /f "delims=" %%a in ('dir /ad /b') do (
set /a gamecount+=1

	setlocal DisableDelayedExpansion
	set filename=%%a.VCD
	set Gamefolder=%%a
	set "gameid="
	set "dbtitle="
	set "dbtitleTMP="
	set "region="
	set "DiscMain="
	set "DiscCount=0"
	set /a "PartSize=0"
	set "HugoPatchFix="
	setlocal EnableDelayedExpansion

	cd /d "%~dp0POPS\Temp\!Gamefolder!" & dir /b /a-d 2>&1 > "%~dp0TMP\DiscX.txt"
	
	REM Get gameid
    "%~dp0BAT\UPSX_SID" "!filename!" -1 > "%~dp0TMP\gameid.txt" & set /p gameid=<"%~dp0TMP\gameid.txt"
	if not defined gameid echo "!filename!"| "%~dp0BAT\busybox" grep -oE "([A-Z]{4}_[0-9]{3}\.[0-9]{2}" > "%~dp0TMP\gameid.txt" & set /p gameid=<"%~dp0TMP\gameid.txt"
	echo !gameid!| "%~dp0BAT\busybox" sed -e "s|\.||g; s|_|-|g" > "%~dp0TMP\gameid.txt" & set /p gameid2=<"%~dp0TMP\gameid.txt"
	
	REM Lightspan Educational ID
	if "!gameid:~0,3!"=="LSP" set gameid2=!gameid2:~0,-2!
	if "!gameid!"=="LSP90513.002" set gameid2=LSP905132
	if "!gameid!"=="LSP05010.101" set gameid2=LSP050101
	if "!gameid!"=="907127.001" set "gameid2=LSP907127" & set gameid=LSP90712.700

	REM if "!usedb!"=="yes" (
	REM Get Gamename Title Database 
	for /f "tokens=1*" %%A in ( 'findstr !gameid! "%~dp0TMP\TitlesDB_PS1_!TitlesLang!.txt"' ) do if not defined dbtitle set dbtitle=%%B
	
	REM Fix Conflict Games. Rare games that have the same ID
	findstr !gameid! "%~dp0BAT\Fix_Conflict_Gameid_Title.bat" >nul 2>&1
    if errorlevel 1 (echo >NUL) else (set "FixGameInstall=PS1" & call "%~dp0BAT\Fix_Conflict_Gameid_Title.bat")
	
	if not defined dbtitleTMP set dbtitleTMP=!dbtitle!
	REM ) else (set "dbtitle=!Gamefolder!" & if not defined dbtitleTMP set dbtitleTMP=!Gamefolder!)

	if not defined dbtitle set "dbtitle=!Gamefolder!" & if not defined dbtitleTMP set dbtitleTMP=!Gamefolder!
	
	REM Get Number of Disc
	"%~dp0BAT\busybox" grep -ie ".*\.VCD$" "%~dp0TMP\DiscX.txt" | "%~dp0BAT\busybox" sed -e "/(Disc [1-6])/d" > "%~dp0TMP\DiscMain.txt" & set /P DiscMain=<"%~dp0TMP\DiscMain.txt"
	"%~dp0BAT\busybox" grep -ie ".*\.VCD$" "%~dp0TMP\DiscX.txt" | "%~dp0BAT\busybox" grep -ie "(Disc 1)" > "%~dp0TMP\DiscMain.txt" & set /P DiscMain=<"%~dp0TMP\DiscMain.txt"
	"%~dp0BAT\busybox" grep -ie ".*\.VCD$" "%~dp0TMP\DiscX.txt" | "%~dp0BAT\busybox" grep -ie "(Disc 2)" > "%~dp0TMP\Disc2.txt" & set /P Disc2=<"%~dp0TMP\Disc2.txt"
	"%~dp0BAT\busybox" grep -ie ".*\.VCD$" "%~dp0TMP\DiscX.txt" | "%~dp0BAT\busybox" grep -ie "(Disc 3)" > "%~dp0TMP\Disc3.txt" & set /P Disc3=<"%~dp0TMP\Disc3.txt"
	"%~dp0BAT\busybox" grep -ie ".*\.VCD$" "%~dp0TMP\DiscX.txt" | "%~dp0BAT\busybox" grep -ie "(Disc 4)" > "%~dp0TMP\Disc4.txt" & set /P Disc4=<"%~dp0TMP\Disc4.txt"
	REM for /f %%a in ('dir /b "*.VCD" 2^>nul ^| find /c /v ""') do set /a DiscCount+=%%a

	REM Get Partition Total Size 1Go maxium Generally a PS1 game does not exceed 896MB
	for /f "usebackq tokens=*" %%s in ("%~dp0TMP\DiscX.txt") do (
	if %%~zs GTR 1000000 set VCDSIZE=128
	if %%~zs GTR 128000000 set VCDSIZE=256
	if %%~zs GTR 256000000 set VCDSIZE=384
	if %%~zs GTR 384000000 set VCDSIZE=512
	if %%~zs GTR 512000000 set VCDSIZE=640
	if %%~zs GTR 640000000 set VCDSIZE=768
	if %%~zs GTR 768000000 set VCDSIZE=896
	if %%~zs GTR 896000000 set VCDSIZE=1024
	set /a "PartSize+=!VCDSIZE!"
	)
      
    REM Creating Partition Name
	if "!gameid:~0,3!"=="LSP" (
	REM This is only for compatibility partition scheme for PSX2 DESR V1
	echo "PP.!gameid2!.POPS.!dbtitle!"| "%~dp0BAT\busybox" sed "s/\""//g" | "%~dp0BAT\busybox" sed "s/\s*$//g; s/[^A-Za-z0-9.]/_/g; y/abcdefghijklmnopqrstuvwxyz/ABCDEFGHIJKLMNOPQRSTUVWXYZ/" | "%~dp0BAT\busybox" sed "s/^\(.\{8\}\)./\1/" | "%~dp0BAT\busybox" sed "s/.\{6\}/&E-/" | "%~dp0BAT\busybox" cut -c0-31 > "%~dp0TMP\LSPPartName.txt" & set /p PartName=<"%~dp0TMP\LSPPartName.txt"
	) else (
	REM General partition scheme
	echo "PP.!gameid2!.POPS.!dbtitle!"| "%~dp0BAT\busybox" sed "s/\""//g" | "%~dp0BAT\busybox" sed "s/\s*$//g; s/[^A-Za-z0-9.]/_/g; y/abcdefghijklmnopqrstuvwxyz/ABCDEFGHIJKLMNOPQRSTUVWXYZ/" | "%~dp0BAT\busybox" sed "s/^\(.\{7\}\)./\1-/" | "%~dp0BAT\busybox" cut -c0-31 > "%~dp0TMP\PartName.txt" & set /P PartName=<"%~dp0TMP\PartName.txt"
	)

echo\
echo\
echo !gamecount! - !filename!
echo ----------------------------------------------------
echo             Getting game information...
	 
	 md "%~dp0TMP\!gameid2!" >nul 2>&1
	 "%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0BAT\HDD-PSBBN_XMB_SAMPLE_HEADER.zip" -o"%~dp0POPS\Temp\!Gamefolder!" -r -y >nul 2>&1
	 "%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0BAT\HDD-OSD_SAMPLE_HEADER.zip" -o"%~dp0POPS\Temp\!Gamefolder!"  PS1\* -r -y & move "%~dp0POPS\Temp\!Gamefolder!\PS1\*" "%~dp0POPS\Temp\!Gamefolder!" >nul 2>&1
	 
	 REM Get game infos
	 "%~dp0BAT\busybox" sed -n "/<game serial=\"!gameid2!\">/,/<\/game>/ {s/.*<Release>\(.*\)<\/Release>.*/\1/p}" "%~dp0BAT\PS1DB.xml" > "%~dp0TMP\!gameid2!\RELEASE.txt"
	 "%~dp0BAT\busybox" sed -n "/<game serial=\"!gameid2!\">/,/<\/game>/ {s/.*<Developer>\(.*\)<\/Developer>.*/\1/p}" "%~dp0BAT\PS1DB.xml" > "%~dp0TMP\!gameid2!\DEVELOPER.txt"
	 "%~dp0BAT\busybox" sed -n "/<game serial=\"!gameid2!\">/,/<\/game>/ {s/.*<Publisher>\(.*\)<\/Publisher>.*/\1/p}" "%~dp0BAT\PS1DB.xml" > "%~dp0TMP\!gameid2!\PUBLISHER.txt"
	 "%~dp0BAT\busybox" sed -n "/<game serial=\"!gameid2!\">/,/<\/game>/ {s/.*<Genre>\(.*\)<\/Genre>.*/\1/p}" "%~dp0BAT\PS1DB.xml"> "%~dp0TMP\!gameid2!\GENRE.txt"

     REM Game ID with PBPX other region than JAP
	 findstr !gameid! "%~dp0BAT\Fix_Conflict_Gameid_Title.bat" >nul 2>&1
	 if errorlevel 1 (echo >NUL) else (set "FixGameRegion=Yes" & set "PSBBN=Yes" & call "%~dp0BAT\Fix_Conflict_Gameid_Title.bat")
	 
	 REM Lightspan Educational ID
 	 if "!gameid:~0,3!"=="LSP" set region=U
	 
	if not defined region (
		 REM A = Asia
		 if "!gameid:~2,1!"=="A" set region=A
		 REM C = China          
       	 if "!gameid:~2,1!"=="C" set region=C
		 REM E = Europe         
		 if "!gameid:~2,1!"=="E" set region=E
		 REM K = Korean         
		 if "!gameid:~2,1!"=="K" set region=K
		 REM P = Japan          
		 if "!gameid:~2,1!"=="P" set region=J
		 REM UC = North America 
		 if "!gameid:~2,1!"=="U" set region=U
    )
	
	 REM Unknown region
	 if not defined region set region=X

echo 	[!PartName!] - [!PartSize!MB]
"%~dp0BAT\Diagbox" gd 0e
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
call "%~dp0BAT\fix_UTF8.bat"
"%~dp0BAT\Diagbox" gd 0e
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0f

	 echo            Downloading resources...
	 md "%~dp0POPS\Temp\!Gamefolder!\PS1\!gameid!" >nul 2>&1 & cd /d "%~dp0POPS\Temp\!Gamefolder!\PS1\!gameid!"
	 
	 REM Downloads 3D Icon
	 if !DownloadARTHDDOSD!==yes for %%f in (icon.sys list.ico del.ico) do "%~dp0BAT\wget" -q "https://archive.org/download/hdd-osd-icons-pack/HDD-OSD-Icons-Pack.zip/PS1%%2F!gameid!%%2F%%f" -O "%~dp0POPS\Temp\!Gamefolder!\PS1\!gameid!\%%f" >nul
	 if !uselocalARTHDDOSD!==yes if exist "%~dp0HDD-OSD-Icons-Pack.zip" "%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0HDD-OSD-Icons-Pack.zip" -o"%~dp0POPS\Temp\!Gamefolder!" PS1\!gameid!\ -r -y >nul 2>&1
	 
	 for %%x in (*) do if %%~zx==0 (del "%%x" >nul 2>&1) else (move "%%x" "%~dp0POPS\Temp\!Gamefolder!" >nul 2>&1)
	 if not exist "%~dp0POPS\Temp\!Gamefolder!\del.ico" copy "%~dp0POPS\Temp\!Gamefolder!\list.ico" "%~dp0POPS\Temp\!Gamefolder!\del.ico" >nul 2>&1
	 
	set "COV.png=jkt_001"
	set "BG_00.png=BG"
	set "LGO.png=jkt_cp"
	set "SCR_00.png=SCR0"
	set "SCR_01.png=SCR1"
	
	if /i not "!DownloadART!"=="yes" (
		if /i exist "%~dp0ART.zip" (
		
			for %%f in (COV.png BG_00.png LGO.png SCR_00.png SCR_01.png) do (
				set "ART_NAME2=!%%f!"
				"%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0ART.zip" -o"%~dp0TMP" PS1\!gameid!\!gameid!_%%f -r -y >nul 2>&1
				move "%~dp0TMP\PS1\!gameid!\!gameid!_%%f" "%~dp0TMP\!ART_NAME2!.png" >nul 2>&1
				)
			)
		) else (
		for %%f in (COV.png BG_00.png LGO.png SCR_00.png SCR_01.png) do (
			set "ART_NAME2=!%%f!"
			"%~dp0BAT\wget" -q --show-progress "https://archive.org/download/OPLM_ART_2024_09/OPLM_ART_2024_09.zip/PS1%%2F!gameid!%%2F!gameid!_%%f" -O "%~dp0TMP\!ART_NAME2!.png" >nul 2>&1
		)
	)
	 REM ART CUSTOM GAMEID
	 "%~dp0BAT\7-Zip\7z" e -bso0 "%~dp0BAT\ART_CUSTOM_GAMEID.zip" -o"%~dp0TMP\PS1\!gameid!" PS1\!gameid!_COV.png -r -y >nul 2>&1
	 for /r "%~dp0TMP\PS1\!gameid!" %%x in (*.png) do if %%~zx==0 (del "%%x") else (move "%~dp0TMP\PS1\!gameid!\!gameid!_COV.png" "%~dp0TMP\jkt_001.png" >nul 2>&1)
	 
	 REM Covers
	 if exist "%~dp0TMP\jkt_001.png" "%~dp0BAT\nconvert" -overwrite -out png -resize 256 256 -rtype lanczos -efocus -colors 256 -o "%~dp0TMP\res\jkt_001.png" "%~dp0TMP\jkt_001.png" >nul 2>&1
	 if exist "%~dp0TMP\jkt_001.png" "%~dp0BAT\nconvert" -overwrite -out png -resize 76 108 -rtype lanczos -efocus -colors 256 -o "%~dp0TMP\res\jkt_002.png" "%~dp0TMP\jkt_001.png" >nul 2>&1
	 if exist "%~dp0TMP\jkt_cp.png" move "%~dp0TMP\jkt_cp.png" "%~dp0TMP\res" >nul 2>&1

	 REM Screenshot
	 if exist "%~dp0TMP\BG.png" "%~dp0BAT\nconvert" -overwrite -out png -resize 640 350 -rtype lanczos -efocus -colors 256 -o "%~dp0TMP\res\image\0.png" "%~dp0TMP\BG.png" >nul 2>&1
     if exist "%~dp0TMP\SCR0.png" "%~dp0BAT\nconvert" -overwrite -out png -resize 640 350 -rtype lanczos -efocus -colors 256 -o "%~dp0TMP\res\image\1.png" "%~dp0TMP\SCR0.png" >nul 2>&1
	 if exist "%~dp0TMP\SCR1.png" "%~dp0BAT\nconvert" -overwrite -out png -resize 640 350 -rtype lanczos -efocus -colors 256 -o "%~dp0TMP\res\image\2.png" "%~dp0TMP\SCR1.png" >nul 2>&1

	 ROBOCOPY /E /MOVE "%~dp0TMP\res" "%~dp0POPS\Temp\!Gamefolder!\res" >nul 2>&1
     for /r "%~dp0TMP" %%x in (*.png) do (del "%%x")
	
	 REM Fix Busybox illegal chars
     echo "!dbtitle!"| "%~dp0BAT\busybox" sed -e "s/\&/\\\&/g; s./.\\\/.g" | "%~dp0BAT\busybox" sed "s/\""//g" | "%~dp0BAT\busybox" iconv -f windows-1252 -t utf-8 > "%~dp0TMP\dbtitle.txt" & set /P dbtitle=<"%~dp0TMP\dbtitle.txt"
     echo "!DEVELOPERTMP!"| "%~dp0BAT\busybox" sed -e "s/\&/\\\&/g; s./.\\\/.g" | "%~dp0BAT\busybox" sed "s/\""//g" | "%~dp0BAT\busybox" iconv -f windows-1252 -t utf-8 > "%~dp0TMP\DEVELOPER.txt" & set /P DEVELOPER=<"%~dp0TMP\DEVELOPER.txt"
     echo "!PUBLISHERTMP!"| "%~dp0BAT\busybox" sed -e "s/\&/\\\&/g; s./.\\\/.g" | "%~dp0BAT\busybox" sed "s/\""//g" | "%~dp0BAT\busybox" iconv -f windows-1252 -t utf-8 > "%~dp0TMP\PUBLISHER.txt" & set /P PUBLISHER=<"%~dp0TMP\PUBLISHER.txt"
     echo "!GENRETMP!"| "%~dp0BAT\busybox" sed -e "s/\&/\\\&/g; s./.\\\/.g" | "%~dp0BAT\busybox" sed "s/\""//g" | "%~dp0BAT\busybox" iconv -f windows-1252 -t utf-8 > "%~dp0TMP\GENRE.txt" & set /P GENRE=<"%~dp0TMP\GENRE.txt"
	
	 REM REM HDD-OSD Infos
	 "%~dp0BAT\busybox" sed -i -e "s/ = /=/g; s/=/ = /g; s/  =/ = /g" "%~dp0POPS\Temp\!Gamefolder!\icon.sys"
	 "%~dp0BAT\busybox" sed -i -e "s/title0 =.*/title0 =/g; s/title0 =/title0 = !dbtitle!/g" "%~dp0POPS\Temp\!Gamefolder!\icon.sys"
	 "%~dp0BAT\busybox" sed -i -e "s/title1 =.*/title1 =/g; s/title1 =/title1 = !gameid2!/g" "%~dp0POPS\Temp\!Gamefolder!\icon.sys"
	 "%~dp0BAT\busybox" sed -i -e "s/\s*$//" "%~dp0POPS\Temp\!Gamefolder!\icon.sys"
	 
	 REM PS.BBN Infos
	 "%~dp0BAT\busybox" sed -i -e "s/title =.*/title =/g; s/title =/title = !dbtitle!/g" "%~dp0POPS\Temp\!Gamefolder!\res\info.sys"
	 "%~dp0BAT\busybox" sed -i -e "s/title_id =.*/title_id =/g; s/title_id =/title_id = !gameid2!/g" "%~dp0POPS\Temp\!Gamefolder!\res\info.sys"
	 "%~dp0BAT\busybox" sed -i -e "s/release_date =.*/release_date =/g; s/release_date =/release_date = !RELEASEBBN!/g" "%~dp0POPS\Temp\!Gamefolder!\res\info.sys"
	 "%~dp0BAT\busybox" sed -i -e "s/area =.*/area =/g; s/area =/area = !REGION!/g" "%~dp0POPS\Temp\!Gamefolder!\res\info.sys"
	 "%~dp0BAT\busybox" sed -i -e "s/developer_id =.*/developer_id =/g; s/developer_id =/developer_id = !DEVELOPER!/g" "%~dp0POPS\Temp\!Gamefolder!\res\info.sys"
	 "%~dp0BAT\busybox" sed -i -e "s/publisher_id =.*/publisher_id =/g; s/publisher_id =/publisher_id = !PUBLISHER!/g" "%~dp0POPS\Temp\!Gamefolder!\res\info.sys"
	 "%~dp0BAT\busybox" sed -i -e "s/genre =.*/genre =/g; s/genre =/genre = !GENRE!/g" "%~dp0POPS\Temp\!Gamefolder!\res\info.sys"
	
	 REM Manual
	 "%~dp0BAT\busybox" sed -i -e "s/label=\"APPNAME\"/label=\"!dbtitle!\"/g; s/\&/\&amp;/g" "%~dp0POPS\Temp\!Gamefolder!\res\man.xml"
	 
	 echo            Creating partitions...
     echo device !@pfsshell_path! > "%~dp0TMP\pfs-log.txt"
	 echo rmpart "!PartName!" >> "%~dp0TMP\pfs-log.txt"
 	 echo mkpart "!PartName!" !PartSize!M PFS >> "%~dp0TMP\pfs-log.txt"
	 
 	 echo mount "!PartName!" >> "%~dp0TMP\pfs-log.txt"
	 if defined DiscMain echo put "!DiscMain!" >> "%~dp0TMP\pfs-log.txt"
     if defined Disc2 echo put "!Disc2!" >> "%~dp0TMP\pfs-log.txt"
     if defined Disc3 echo put "!Disc3!" >> "%~dp0TMP\pfs-log.txt"
     if defined Disc4 echo put "!Disc4!" >> "%~dp0TMP\pfs-log.txt"
     if defined DiscMain echo rename "!DiscMain!" IMAGE0.VCD >> "%~dp0TMP\pfs-log.txt"
     if defined Disc2 echo rename "!Disc2!" IMAGE1.VCD>> "%~dp0TMP\pfs-log.txt"
     if defined Disc3 echo rename "!Disc3!" IMAGE2.VCD>> "%~dp0TMP\pfs-log.txt"
     if defined Disc4 echo rename "!Disc4!" IMAGE3.VCD>> "%~dp0TMP\pfs-log.txt"
	 copy "%~dp0POPS-Binaries\POPSTARTER.KELF" "%~dp0POPS\Temp\!Gamefolder!\EXECUTE.KELF" >nul 2>&1
	 echo put "EXECUTE.KELF" >> "%~dp0TMP\pfs-log.txt"
	 echo lcd "%~dp0POPS\Temp\!Gamefolder!\res" >> "%~dp0TMP\pfs-log.txt"
	 echo mkdir res >> "%~dp0TMP\pfs-log.txt"
	 echo cd res >> "%~dp0TMP\pfs-log.txt"
	 
	 cd /d "%~dp0POPS\temp\!Gamefolder!\res"
	 for %%0 in (*) do (echo put "%%0") >> "%~dp0TMP\pfs-log.txt"
	 
	 REM RESSOURCE DIR (PP.NAME\res\image)
	 for /D %%x in (*) do (
	 echo mkdir "%%x" >> "%~dp0TMP\pfs-log.txt"
	 echo lcd "%%x" >> "%~dp0TMP\pfs-log.txt"
 	 echo cd "%%x" >> "%~dp0TMP\pfs-log.txt"
 	 cd "%%x"
	 
	 REM RESSOURCE DIR (PP.NAME\res\image\files.xxx)
 	 for %%1 in (*) do (echo put "%%1") >> "%~dp0TMP\pfs-log.txt"
	 
	 echo lcd .. >> "%~dp0TMP\pfs-log.txt"
	 echo cd .. >> "%~dp0TMP\pfs-log.txt"
	 cd ..
	 )
	 
	 cd /d "%~dp0POPS\Temp\!Gamefolder!"
	 if exist "%~dp0POPS-Binaries\Hugopocked_POPStarter_Fixes.zip" (
	 findstr !gameid! "%~dp0TMP\id.txt" >nul 2>&1
	 if errorlevel 1 (
     REM echo         No need patch
     ) else (
	 echo            Patches Applied...
	 set HugoPatchFix=yes
	 "%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0POPS-Binaries\Hugopocked_POPStarter_Fixes.zip" -o"%~dp0TMP" !gameid!\* -r -y & move "%~dp0TMP\!gameid!\*" "%~dp0POPS\Temp\!Gamefolder!" >nul 2>&1
	 if not exist *.BIN (
	 "%~dp0BAT\busybox" md5sum "!DiscMain!" | "%~dp0BAT\busybox" grep -o "[0-9a-z]\{32\}" > "%~dp0TMP\MD5.txt" & set /p MD5=<"%~dp0TMP\MD5.txt"
	 "%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0POPS-Binaries\Hugopocked_POPStarter_Fixes.zip" -o"%~dp0TMP" !gameid!\!MD5!\* -r -y & move "%~dp0TMP\!gameid!\!MD5!\*" "%~dp0POPS\Temp\!Gamefolder!" >nul 2>&1 & del "%~dp0POPS\Temp\!appfolder!\*.xdelta" >nul 2>&1
	    )
       )
      )
	 
	 REM Create VMC Folder
	 echo cd .. >> "%~dp0TMP\pfs-log.txt"
	 echo lcd "%~dp0POPS\Temp\!Gamefolder!" >> "%~dp0TMP\pfs-log.txt"
	 echo umount >> "%~dp0TMP\pfs-log.txt"
	 echo mount __common >> "%~dp0TMP\pfs-log.txt"
	 echo mkdir POPS >> "%~dp0TMP\pfs-log.txt"
	 echo cd POPS >> "%~dp0TMP\pfs-log.txt"
	 echo mkdir "!PartName:~3!" >> "%~dp0TMP\pfs-log.txt"
	 echo cd "!PartName:~3!" >> "%~dp0TMP\pfs-log.txt"
     if defined HugoPatchFix for %%x in (TROJAN_?.BIN PATCH_?.BIN CHEATS.TXT Readme.txt) do echo put "%%x" >> "%~dp0TMP\pfs-log.txt"
	 
	 if defined Disc2 (
	 echo IMAGE0.VCD> "%~dp0POPS\Temp\!Gamefolder!\DISCS.TXT"
	 echo IMAGE1.VCD>> "%~dp0POPS\Temp\!Gamefolder!\DISCS.TXT"
	 if defined Disc3 echo IMAGE2.VCD>> "%~dp0POPS\Temp\!Gamefolder!\DISCS.TXT"
	 if defined Disc4 echo IMAGE3.VCD>> "%~dp0POPS\Temp\!Gamefolder!\DISCS.TXT"
	 echo put DISCS.TXT>> "%~dp0TMP\pfs-log.txt"
	 )

	 echo umount >> "%~dp0TMP\pfs-log.txt"
   	 echo exit >> "%~dp0TMP\pfs-log.txt"
	 
 	 echo            Installing...
	 type "%~dp0TMP\pfs-log.txt" | "%~dp0BAT\pfsshell" >nul 2>&1
	 "%~dp0BAT\hdl_dump" modify_header !@hdl_path! "!PartName!" >nul 2>&1
	 
     move "%~dp0POPS\Temp\!Gamefolder!\*.VCD" "%~dp0POPS" >nul 2>&1
	 rmdir /Q/S "%~dp0TMP\!gameid2!" >nul 2>&1
	 echo            Completed...
	 echo ---------------------------------------------------
 endlocal
endlocal
)

REM Reloading HDD Cache
call "%~dp0BAT\__ReloadHDD_cache.bat" >nul 2>&1

) else ( echo        .VCD NOT DETECTED! )

cd /d "%~dp0" & rmdir /Q/S "%~dp0POPS\Temp" >nul 2>&1 & rmdir /Q/S "%~dp0TMP" >nul 2>&1

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo Completed...
echo\
echo\
"%~dp0BAT\Diagbox" gd 07

if defined @pfs_popHDDOSDMAIN (pause & goto mainmenu) else (pause & goto HDDOSDPartManagement)
REM ####################################################################################################################
:TransferAPPSPart
cls
mkdir "%~dp0APPS" >nul 2>&1
mkdir "%~dp0TMP" >nul 2>&1
cd /d "%~dp0APPS"

IF NOT DEFINED @hdl_path ( rmdir /Q/S "%~dp0TMP" >nul 2>&1 & goto ScanningPS2HDD ) else (
"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning for Playstation 2 HDDs:
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "!@hdl_path!" | "%~dp0BAT\busybox" grep "Playstation 2 HDD" >nul
if errorlevel 1 set "@hdl_path=" & goto ScanningPS2HDD
echo       [!@hdl_path! !@TotalHDD_Size! - !@ModelePS2HDD!]
)

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Install an application ELF as a partition
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1^) Yes
"%~dp0BAT\Diagbox" gd 0c
echo         2^) No
"%~dp0BAT\Diagbox" gd 0e
echo         3^) Yes ^(Update your app ELF^)
"%~dp0BAT\Diagbox" gd 0f
echo\
CHOICE /C 123 /M "Select Option:"

IF %ERRORLEVEL%==1 set @pfs_APP=yes
IF %ERRORLEVEL%==2 (goto HDDOSDPartManagement)
IF %ERRORLEVEL%==3 set @pfs_APP=yesUP

"%~dp0BAT\Diagbox" gd 0f
cls

echo\
echo\
echo Applications List
echo ---------------------------------------------------
   dir /B /AD > "%~dp0TMP\applist.txt"
   for /r "%~dp0TMP" %%F in (applist.txt) do if %%~zF==0 del "%%F"
   if exist "%~dp0TMP\applist.txt" (type "%~dp0TMP\applist.txt"
   ) else (
   "%~dp0BAT\Diagbox" gd 06
   echo\
   echo APP NOT DETECTED: Please drop your APP IN APPS FOLDER.
   echo Example: APPS\My APP\BOOT.ELF
   echo\
   "%~dp0BAT\Diagbox" gd 07
   set "@pfs_APP=" & pause & goto TransferAPPSPart
   )
   echo ---------------------------------------------------
   echo\
   echo\
   echo Enter the name of the APP you want to install or update
   set /p "appfolder="
   IF "!appfolder!"=="" set "@pfs_APP=" & (goto TransferAPPSPart)

"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Detecting ELF:
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 07

if exist "%~dp0APPS\!appfolder!" (

cd /d "%~dp0APPS\!appfolder!"

setlocal DisableDelayedExpansion
set /a ELFcount=0
for %%f in (*.elf) do (
set /a ELFcount+=1
set ELFBOOT=%%f
)

      setlocal EnableDelayedExpansion
      if !ELFcount!==1 (
	  echo ok >nul 2>&1
      ) else (
      "%~dp0BAT\Diagbox" gd 06
      echo         Multiple ELF Detected
      echo         Please select one ELF
      echo\
      "%~dp0BAT\Diagbox" gd 0f
      "%~dp0BAT\busybox" ls "%~dp0APPS\!appfolder!" | "%~dp0BAT\busybox" grep -ie ".*\.ELF$" > "%~dp0TMP\ELFList.txt"
      type "%~dp0TMP\ELFList.txt
	  echo\
	  echo Enter the name of the ELF boot
      set /p "ELFBOOT="
      echo\
	  echo ---------------------------------------------------
      "%~dp0BAT\Diagbox" gd 07
	  )
	  
      if exist "!ELFBOOT!" (
	  "%~dp0BAT\Diagbox" gd 0a
	  echo         !ELFBOOT! Detected
	  "%~dp0BAT\Diagbox" gd 07
	  ) else (
	  "%~dp0BAT\Diagbox" gd 0c
	  echo         !ELFBOOT! NOT DETECTED
	  "%~dp0BAT\Diagbox" gd 07
	  )
	  
	  ) else (
	  "%~dp0BAT\Diagbox" gd 0c
	  echo Application NOT DETECTED
	  "%~dp0BAT\Diagbox" gd 07
	  echo\
	  echo\
	  endlocal
	  endlocal
      rmdir /Q/S "%~dp0TMP" >nul 2>&1
      pause & (goto HDDOSDPartManagement)
	  )	
	    
echo\
echo\
pause
cls

if exist "!ELFBOOT!" (
if !@pfs_APP!==yes (
"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Configure your App: !ELFBOOT!
echo ---------------------------------------------------
echo\
"%~dp0BAT\Diagbox" gd 0f
     
	 type "%~dp0BAT\__Cache\PARTITION_PS2HDD.txt" > "%~dp0TMP\hdd-prt.txt"

      echo Enter the Title of your App
	  echo Example: My APP
      set /p "PPTitle="
	  IF "!PPTitle!"=="" (goto TransferAPPSPart)
	  echo\
	  
	  echo Enter Application Genre ^(Optional^)
	  echo Example: File Browser
      set /p "Genre="
	  echo\

	  echo Enter the size of your partition
	  echo The size must be multiplied by 128
      echo Example: 128 x 5 = 640MB
      echo Max size per partition 128GB
      echo\
      echo Example:
      echo If you want a 10GB partition Type: 10G
      echo If you want a 512MB partition Type: 512M
      echo If you want a 1.5GB partition 1024 + 512 = 1536 Type: 1536M
	  echo\
	  echo If you don't know what to choose, put 128M
      set /p "partsize="
      IF "!partsize!"=="" set partsize=128M
      echo\
	 
      echo Do you want to choose a custom partition name^? [Recommend only for advanced users]
      choice /c YN
	  echo\
	  if !errorlevel!==1 (
	  echo Enter the name of your partition
      echo Example: PP.MYAP-00001..YOURAPPNAME
	  "%~dp0BAT\Diagbox" gd 06
	  echo It is strongly recommended to respect the sheme as in the example.
	  echo Unless you know what you're doing
	  "%~dp0BAT\Diagbox" gd 07
      set /p "PPName="
	  echo "!PPName!"| "%~dp0BAT\busybox" sed -e "s/\""//g" | "%~dp0BAT\busybox" iconv -f utf8 -t ascii//TRANSLIT//IGNORE | "%~dp0BAT\busybox" cut -c0-31 > "%~dp0TMP\PPName.txt"
      ) else (
	  cd /d "%~dp0TMP"
	  
	  echo Assigning an ID
	  "%~dp0BAT\busybox" grep -ow "PP.UAPP-[0-9][0-9][0-9][0-9][0-9]" "%~dp0TMP\hdd-prt.txt" | "%~dp0BAT\busybox" cut -c9-13 > "%~dp0TMP\PPIDChecking.txt"
	  for /l %%n in (1,1,9) do echo 0000%%n>> "%~dp0TMP\ids.txt"
      for /l %%n in (10,1,99) do echo 000%%n>> "%~dp0TMP\ids.txt"
      for /l %%n in (100,1,200) do echo 00%%n>> "%~dp0TMP\ids.txt"
	  
      for /f %%p in (PPIDChecking.txt) do "%~dp0BAT\busybox" sed -i "/%%p/d" "%~dp0TMP\ids.txt"
	  "%~dp0BAT\busybox" head -1 "%~dp0TMP\ids.txt" > "%~dp0TMP\selectedID.txt" & set /P PPID=<"%~dp0TMP\selectedID.txt"
	  echo UAPP-!PPID!
	  
	  echo "!PPTitle!"| "%~dp0BAT\busybox" sed -e "s/\""//g" | "%~dp0BAT\busybox" iconv -f utf8 -t ascii//TRANSLIT//IGNORE | "%~dp0BAT\busybox" cut -c0-16 > "%~dp0TMP\PPName.txt"
      echo "!PPID!"| "%~dp0BAT\busybox" grep -ow "[0-9][0-9][0-9][0-9][0-9]" > "%~dp0TMP\IDCHECK.txt" & set /P IDCHECK=<"%~dp0TMP\IDCHECK.txt"
      )

REM Remove illegal character Partition name
REM "%~dp0BAT\busybox" sed -i "s/\s*$//" "%~dp0TMP\PPName.txt"
"%~dp0BAT\busybox" sed -i "s/[^A-Za-z0-9.]/_/g; y/abcdefghijklmnopqrstuvwxyz/ABCDEFGHIJKLMNOPQRSTUVWXYZ/" "%~dp0TMP\PPName.txt"

if defined PPID "%~dp0BAT\busybox" sed -i "s/^^/PP.UAPP-!PPID!../" "%~dp0TMP\PPName.txt"
set /P PPName=<"%~dp0TMP\PPName.txt"

"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Checking !PPName!
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 07

    if not defined PPID (
	"%~dp0BAT\busybox" grep -ow "!PPName!" "%~dp0TMP\hdd-prt.txt" > "%~dp0TMP\PPIDChecking.txt" & set /P PPIDCheck=<"%~dp0TMP\PPIDChecking.txt"
	if "!PPIDCheck!"=="!PPName!" (
	"%~dp0BAT\Diagbox" gd 0c
	echo     A partition with the same name exists
	echo               Choose another
	echo\
	echo\
	"%~dp0BAT\Diagbox" gd 07
	rmdir /Q/S "%~dp0TMP" >nul 2>&1
	pause & (goto HDDOSDPartManagement)
	) else (
	"%~dp0BAT\Diagbox" gd 0a
	echo         Partition name available
	"%~dp0BAT\Diagbox" gd 07
	REM echo !PPName!| "%~dp0BAT\busybox" grep -ow "[A-Z][A-Z][A-Z][A-Z]-[0-9][0-9][0-9][0-9][0-9]" > "%~dp0TMP\PPID.txt" & set /P PPID=<"%~dp0TMP\PPID.txt"
	)
	
    ) else (
	"%~dp0BAT\Diagbox" gd 0a
	echo         Verification successfully
	"%~dp0BAT\Diagbox" gd 07
	)
)

if !@pfs_APP!==yesUP (

"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning Partitions System:
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
    "%~dp0BAT\busybox" grep -e "0x0100" "%~dp0BAT\__Cache\PARTITION_PS2HDD.txt" | "%~dp0BAT\busybox" grep -e "PP\." | "%~dp0BAT\busybox" sed "/\.POPS\./d" | "%~dp0BAT\busybox" cut -c30-250
"%~dp0BAT\Diagbox" gd 0e
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0f
     echo\
	 echo\
     set /p "PPName=Enter the partition name:"
     IF "!PPName!"=="" (goto TransferAPPSPart)

"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Detecting !PPName! Partition:
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 07

    "%~dp0BAT\busybox" grep -ow "!PPName!" "%~dp0BAT\__Cache\PARTITION_PS2HDD.txt" > "%~dp0TMP\PPSelected.txt" & set /P PPSELECTED=<"%~dp0TMP\PPSelected.txt"
	if "!PPSELECTED!"=="!PPName!" (
    "%~dp0BAT\Diagbox" gd 0a
	echo         Partition Detected
	"%~dp0BAT\Diagbox" gd 07
	) else (
	"%~dp0BAT\Diagbox" gd 0c
	echo         Partition NOT Detected
	echo\
	echo\
	"%~dp0BAT\Diagbox" gd 07
	rmdir /Q/S "%~dp0TMP" >nul 2>&1
	pause & (goto HDDOSDPartManagement)
	)
)

echo\
echo\
pause
cls

if !@pfs_APP!==yes (
"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Installing !appfolder!:
"%~dp0BAT\Diagbox" gd 0e
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
cd /d "%~dp0APPS\!appfolder!"

	"%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0BAT\HDD-PSBBN_XMB_SAMPLE_HEADER.zip" res\* -o"%~dp0APPS\!appfolder!" -r- -y >nul 2>&1
	"%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0BAT\HDD-OSD_SAMPLE_HEADER.zip" -o"%~dp0TMP" APP\* -r -y >nul 2>&1
	
	echo !PPName!| "%~dp0BAT\busybox" grep -ow "[A-Z][A-Z][A-Z][A-Z]-[0-9][0-9][0-9][0-9][0-9]" > "%~dp0TMP\PPID.txt" & set /P PPID=<"%~dp0TMP\PPID.txt"

	echo Title:     [!PPTitle!]
	if defined PPID echo Appid:     [!PPID!]
	REM echo Release:   [!Release!]
	echo Genre:     [!Genre!]
    echo Size:      [!partsize!]
	
"%~dp0BAT\Diagbox" gd 0e
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0f

	echo            Creating Partition
	echo device !@pfsshell_path! > "%~dp0TMP\pfs-apps.txt"
	echo mkpart !PPName! !partsize! PFS >> "%~dp0TMP\pfs-apps.txt"
	echo mount !PPName! >> "%~dp0TMP\pfs-apps.txt"
	echo rm BOOT.ELF >> "%~dp0TMP\pfs-apps.txt"
	echo rm EXECUTE.KELF >> "%~dp0TMP\pfs-apps.txt"

	REM HDD-OSD Infos
	"%~dp0BAT\busybox" sed -ie "s/ = /=/g; s/=/ = /g; s/  =/ = /g" "%~dp0TMP\APP\icon.sys"
	"%~dp0BAT\busybox" sed -ie "s/title0 =.*/title0 =/g; s/title0 =/title0 = !PPTitle!/g" "%~dp0TMP\APP\icon.sys"
 	"%~dp0BAT\busybox" sed -ie "s/title1 =.*/title1 =/g; s/title1 =/title1 = !Genre!/g" "%~dp0TMP\APP\icon.sys"
	"%~dp0BAT\busybox" sed -ie "s/\s*$//" "%~dp0TMP\APP\icon.sys"

	REM PSBBN, XMB Infos 
	"%~dp0BAT\busybox" sed -i -e "s/title =.*/title =/g; s/title =/title = !PPTitle!/g" "%~dp0APPS\!appfolder!\res\info.sys"
 	"%~dp0BAT\busybox" sed -i -e "s/title_id =.*/title_id =/g; s/title_id =/title_id = !PPID!/g" "%~dp0APPS\!appfolder!\res\info.sys"
	REM "%~dp0BAT\busybox" sed -i -e "s/release_date =.*/release_date =/g; s/release_date =/release_date = !date!/g" "%~dp0APPS\!appfolder!\res\info.sys"
	"%~dp0BAT\busybox" sed -i -e "s/genre =.*/genre =/g; s/genre =/genre = !Genre!/g" "%~dp0APPS\!appfolder!\res\info.sys"
	
	REM Disable jkt_cp.png
	REM "%~dp0BAT\busybox" sed -i -e "s/copyright_imgcount =.*/copyright_imgcount =/g; s/copyright_imgcount =/copyright_imgcount = 0/g" "%~dp0APPS\!appfolder!\res\info.sys"
	REM Manual
	"%~dp0BAT\busybox" sed -i -e "s/label=\"APPNAME\"/label=\"!PPTitle!\"/g; s/\&/\&amp;/g" "%~dp0APPS\!appfolder!\res\man.xml"
	)
	
if !@pfs_APP!==yesUP (
"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Updating !appfolder!:
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0f

	echo            Updating...
	echo device !@pfsshell_path! > "%~dp0TMP\pfs-apps.txt"
	echo mount !PPName! >> "%~dp0TMP\pfs-apps.txt"
	echo rm BOOT.ELF >> "%~dp0TMP\pfs-apps.txt"
	echo rm EXECUTE.KELF >> "%~dp0TMP\pfs-apps.txt"
	)
	
	echo            Sign KELF...
	del "%~dp0APPS\!appfolder!\EXECUTE.KELF" >nul 2>&1
	ren "%~dp0APPS\!appfolder!\!ELFBOOT!" BOOT.ELF >nul 2>&1
	
	REM if exist "%USERPROFILE%\PS2KEYS.DAT" copy "%USERPROFILE%\PS2KEYS.DAT" "%rootpath%\BAT" >nul 2>&1
	
	if exist "%~dp0BAT\PS2KEYS.DAT" (
	copy "%rootpath%\BAT\PS2KEYS.DAT" "%USERPROFILE%\PS2KEYS.DAT" >nul 2>&1
	"%~dp0BAT\kelftool.exe" encrypt mbr "%~dp0APPS\!appfolder!\BOOT.ELF" "%~dp0APPS\!appfolder!\EXECUTE.KELF" >nul 2>&1
	) else (
	"%~dp0BAT\SCEDoormat_NoME.exe" "%~dp0APPS\!appfolder!\BOOT.ELF" "%~dp0APPS\!appfolder!\EXECUTE.KELF" >nul 2>&1
	)
	
	REM !!!!!! SUPPORT 10 SUBFOLDER ONLY !!!!!! 
	
    REM APPS FILES (APPS\files.xxx)
 	for %%0 in (*) do (echo put "%%0") >> "%~dp0TMP\pfs-apps.txt"

	REM APPS 1 DIR (APPS\APP)
	for /D %%a in (*) do (
	echo mkdir "%%a" >> "%~dp0TMP\pfs-apps.txt"
	echo lcd "%%a" >> "%~dp0TMP\pfs-apps.txt"
 	echo cd "%%a" >> "%~dp0TMP\pfs-apps.txt"
 	cd "%%a"

	REM APPS FILES (APPS\APP\files.xxx)
 	for %%1 in (*) do (echo put "%%1") >> "%~dp0TMP\pfs-apps.txt"

	REM APPS 2 SUBDIR (APPS\APP\SUBDIR)
	for /D %%b in (*) do (
	echo mkdir "%%b" >> "%~dp0TMP\pfs-apps.txt"
	echo lcd "%%b" >> "%~dp0TMP\pfs-apps.txt"
	echo cd "%%b" >> "%~dp0TMP\pfs-apps.txt"
	cd "%%b"

	REM APPS SUBDIR FILES (APPS\APP\SUBDIR\files.xxx)
	for %%2 in (*) do (echo put "%%2") >> "%~dp0TMP\pfs-apps.txt"
	
	REM APPS 3 SUBDIR (APPS\APP\SUBDIR\SUBDIR)
	for /D %%c in (*) do (
	echo mkdir "%%c" >> "%~dp0TMP\pfs-apps.txt"
	echo lcd "%%c" >> "%~dp0TMP\pfs-apps.txt"
	echo cd "%%c" >> "%~dp0TMP\pfs-apps.txt"
	cd "%%c"
	
	REM APPS SUBDIR FILES (APPS\APP\SUBDIR\SUBDIR\files.xxx)
	for %%3 in (*) do (echo put "%%3") >> "%~dp0TMP\pfs-apps.txt"
	
    REM APPS 4 SUBDIR (APPS\APP\SUBDIR\SUBDIR\SUBDIR\SUBDIR)
	for /D %%e in (*) do (
	echo mkdir "%%e" >> "%~dp0TMP\pfs-apps.txt"
	echo lcd "%%e" >> "%~dp0TMP\pfs-apps.txt"
	echo cd "%%e" >> "%~dp0TMP\pfs-apps.txt"
	cd "%%e"
	
	REM APPS SUBDIR FILES (APPS\APP\SUBDIR\SUBDIR\SUBDIR\files.xxx)
	for %%4 in (*) do (echo put "%%4") >> "%~dp0TMP\pfs-apps.txt"
	
	REM APPS 5 SUBDIR (APPS\APP\SUBDIR\SUBDIR\SUBDIR\SUBDIR\)
	for /D %%f in (*) do (
	echo mkdir "%%f" >> "%~dp0TMP\pfs-apps.txt"
	echo lcd "%%f" >> "%~dp0TMP\pfs-apps.txt"
	echo cd "%%f" >> "%~dp0TMP\pfs-apps.txt"
	cd "%%f"
	
	REM APPS SUBDIR FILES (APPS\APP\SUBDIR\SUBDIR\SUBDIR\SUBDIR\files.xxx)
	for %%5 in (*) do (echo put "%%5") >> "%~dp0TMP\pfs-apps.txt"
	
	REM APPS 6 SUBDIR (APPS\APP\SUBDIR\SUBDIR\SUBDIR\SUBDIR\)
	for /D %%g in (*) do (
	echo mkdir "%%g" >> "%~dp0TMP\pfs-apps.txt"
	echo lcd "%%g" >> "%~dp0TMP\pfs-apps.txt"
	echo cd "%%g" >> "%~dp0TMP\pfs-apps.txt"
	cd "%%g"
	
	REM APPS SUBDIR FILES (APPS\APP\SUBDIR\SUBDIR\SUBDIR\SUBDIR\SUBDIR\files.xxx)
	for %%6 in (*) do (echo put "%%6") >> "%~dp0TMP\pfs-apps.txt"
	
	REM APPS 7 SUBDIR (APPS\APP\SUBDIR\SUBDIR\SUBDIR\SUBDIR\SUBDIR\SUBDIR\)
	for /D %%h in (*) do (
	echo mkdir "%%h" >> "%~dp0TMP\pfs-apps.txt"
	echo lcd "%%h" >> "%~dp0TMP\pfs-apps.txt"
	echo cd "%%h" >> "%~dp0TMP\pfs-apps.txt"
	cd "%%h"
	
	REM APPS SUBDIR FILES (APPS\APP\SUBDIR\SUBDIR\SUBDIR\SUBDIR\SUBDIR\SUBDIR\files.xxx)
	for %%7 in (*) do (echo put "%%7") >> "%~dp0TMP\pfs-apps.txt"
	
	REM APPS 8 SUBDIR (APPS\APP\SUBDIR\SUBDIR\SUBDIR\SUBDIR\SUBDIR\SUBDIR\SUBDIR\)
	for /D %%i in (*) do (
	echo mkdir "%%i" >> "%~dp0TMP\pfs-apps.txt"
	echo lcd "%%i" >> "%~dp0TMP\pfs-apps.txt"
	echo cd "%%i" >> "%~dp0TMP\pfs-apps.txt"
	cd "%%i"
	
	REM APPS SUBDIR FILES (APPS\APP\SUBDIR\SUBDIR\SUBDIR\SUBDIR\SUBDIR\SUBDIR\SUBDIR\files.xxx)
	for %%8 in (*) do (echo put "%%8") >> "%~dp0TMP\pfs-apps.txt"
	
	REM APPS 9 SUBDIR (APPS\APP\SUBDIR\SUBDIR\SUBDIR\SUBDIR\SUBDIR\SUBDIR\SUBDIR\SUBDIR\)
	for /D %%j in (*) do (
	echo mkdir "%%j" >> "%~dp0TMP\pfs-apps.txt"
	echo lcd "%%j" >> "%~dp0TMP\pfs-apps.txt"
	echo cd "%%j" >> "%~dp0TMP\pfs-apps.txt"
	cd "%%j"
	
	REM APPS SUBDIR FILES (APPS\APP\SUBDIR\SUBDIR\SUBDIR\SUBDIR\SUBDIR\SUBDIR\SUBDIR\SUBDIR\files.xxx)
	for %%9 in (*) do (echo put "%%9") >> "%~dp0TMP\pfs-apps.txt"
	
	REM EXIT SUBDIR

	echo lcd .. >> "%~dp0TMP\pfs-apps.txt"
	echo cd .. >> "%~dp0TMP\pfs-apps.txt"
	cd ..
	)
	
	echo lcd .. >> "%~dp0TMP\pfs-apps.txt"
	echo cd .. >> "%~dp0TMP\pfs-apps.txt"
 	cd ..
	)
	
	echo lcd .. >> "%~dp0TMP\pfs-apps.txt"
	echo cd .. >> "%~dp0TMP\pfs-apps.txt"
 	cd ..
	)
	
	echo lcd .. >> "%~dp0TMP\pfs-apps.txt"
	echo cd .. >> "%~dp0TMP\pfs-apps.txt"
 	cd ..
    )
	
	echo lcd .. >> "%~dp0TMP\pfs-apps.txt"
	echo cd .. >> "%~dp0TMP\pfs-apps.txt"
 	cd ..
	)
	
	echo lcd .. >> "%~dp0TMP\pfs-apps.txt"
	echo cd .. >> "%~dp0TMP\pfs-apps.txt"
 	cd ..
	)
	
	echo lcd .. >> "%~dp0TMP\pfs-apps.txt"
	echo cd .. >> "%~dp0TMP\pfs-apps.txt"
 	cd ..
	)
	
	echo lcd .. >> "%~dp0TMP\pfs-apps.txt"
	echo cd .. >> "%~dp0TMP\pfs-apps.txt"
 	cd ..
	)
	
	echo lcd .. >> "%~dp0TMP\pfs-apps.txt"
	echo cd .. >> "%~dp0TMP\pfs-apps.txt"
 	cd ..
	)
	
	echo ls -l >> "%~dp0TMP\pfs-apps.txt"
	echo umount >> "%~dp0TMP\pfs-apps.txt"
	echo exit >> "%~dp0TMP\pfs-apps.txt"
	
	echo            Installing...
	type "%~dp0TMP\pfs-apps.txt" | "%~dp0BAT\pfsshell" >nul 2>&1
	
	ren "%~dp0APPS\!appfolder!\BOOT.ELF" !ELFBOOT! >nul 2>&1
	del "%~dp0APPS\!appfolder!\EXECUTE.KELF" >nul 2>&1
	rmdir /Q/S "%~dp0APPS\!appfolder!\res" >nul 2>&1
	
	if !@pfs_APP!==yes cd /d "%~dp0TMP\APP" & "%~dp0BAT\hdl_dump" modify_header !@hdl_path! "!PPName!" >nul 2>&1
	echo            Completed...
	)
    
	REM Reloading HDD Cache
	call "%~dp0BAT\__ReloadHDD_cache.bat" >nul 2>&1
	
cd /d "%~dp0" & rmdir /Q/S "%~dp0TMP" >nul 2>&1
echo\
"%~dp0BAT\Diagbox" gd 0f
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo Completed...
echo\
echo\
"%~dp0BAT\Diagbox" gd 0f

endlocal
endlocal
pause & (goto HDDOSDPartManagement)
REM ####################################################################################################################
:UpdatePPHeader
cls
mkdir "%~dp0TMP" >nul 2>&1
cd /d "%~dp0TMP"

IF NOT DEFINED @hdl_path ( rmdir /Q/S "%~dp0TMP" >nul 2>&1 & goto ScanningPS2HDD ) else (
"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning for Playstation 2 HDDs:
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "!@hdl_path!" | "%~dp0BAT\busybox" grep "Playstation 2 HDD" >nul
if errorlevel 1 set "@hdl_path=" & goto ScanningPS2HDD
echo       [!@hdl_path! !@TotalHDD_Size! - !@ModelePS2HDD!]
)

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Update Partition Resources Header:
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1^) Yes
"%~dp0BAT\Diagbox" gd 0c
echo         2^) No
"%~dp0BAT\Diagbox" gd 0e
echo         3^) Yes ^(Updates all partitions^)
"%~dp0BAT\Diagbox" gd 07
echo\
CHOICE /C 123 /M "Select Option:"

IF !ERRORLEVEL!==1 set "UPDATEPPHeader=Manually"
IF !ERRORLEVEL!==2 (goto HDDOSDPartManagement)
IF !ERRORLEVEL!==3 set "UPDATEPPHeader=All"

echo\
echo\
echo Choose the partitions 
echo ---------------------------------------------------
echo         1^) Update partition resources PS1 Games
echo         2^) Update partition resources PS2 Games
echo         3^) Update partition resources APP System
echo\
CHOICE /C 123 /M "Select Option:"
IF !ERRORLEVEL!==1 set "PartitionType=PS1" & set "showtype=Game"
IF !ERRORLEVEL!==2 set "PartitionType=PS2" & set "showtype=Game"
IF !ERRORLEVEL!==3 set "PartitionType=APP" & set "showtype=Application" & set UseTitleDB=TitlesDB_APP

if !@PSBBN_Installed!==Yes (
if "!PartitionType!"=="PS2" (
echo\
"%~dp0BAT\Diagbox" gd 0e
echo Do you want to create a PFS resources partition, to launch your PS2 games from PSBBN Or XMB^?
"%~dp0BAT\Diagbox" gd 06
echo Keep in mind that will create a 128MB partition^^!
"%~dp0BAT\Diagbox" gd 07

CHOICE /C YN /M "Select Option:"

IF !ERRORLEVEL!==1 (
set "CreatePFSRes=Yes" & set UpdateLauncher=Yes
if !UPDATEPPHeader!==All (
echo\
"%~dp0BAT\Diagbox" gd 06
echo Be Careful^^!
echo This will create 128Mb partitions for each PS2 game detected
echo\
"%~dp0BAT\Diagbox" gd 0e
echo Are you sure you want to continue^?
"%~dp0BAT\Diagbox" gd 07
CHOICE /C YN /M "Select Option:"
IF !ERRORLEVEL!==2 (goto UpdatePPHeader)
			)
		) else (set "CreatePFSRes=")
	)
)

if !showtype!==Game (
if not exist "%~dp0BAT\TitlesDB\TitlesDB_!PartitionType!_!TitlesLang!.txt" set "TitlesLang=English"
copy "%~dp0BAT\TitlesDB\TitlesDB_!PartitionType!_!TitlesLang!.txt" "%~dp0TMP\TitlesDB_!PartitionType!_!TitlesLang!.txt" >nul 2>&1
set UseTitleDB=TitlesDB_!PartitionType!_!TitlesLang!
)

if /i exist "%~dp0ART.zip" (
echo\
"%~dp0BAT\Diagbox" gd 0e
echo ART.zip detected do you want use it^?
"%~dp0BAT\Diagbox" gd 0f
CHOICE /C YN /M "Select Option:"
IF ERRORLEVEL 1 set uselocalART=yes
IF ERRORLEVEL 2 set uselocalART=no
) else (set uselocalART=no)

if !uselocalART!==no (
    echo\
	echo Checking internet Or Website connection... For ART
	ping -n 1 -w 2000 archive.org >nul
	if errorlevel 1 (
			"%~dp0BAT\Diagbox" gd 0c
			echo Unable to PING^^!
			if /i exist "%~dp0ART.zip" set uselocalART=yes
			"%~dp0BAT\Diagbox" gd 07
			) else (
	
	"%~dp0BAT\wget" -q --show-progress "https://archive.org/download/OPLM_ART_2024_09/OPLM_ART_2024_09.zip/PS1%%2FSCES_000.01%%2FSCES_000.01_COV.png" -O "%~dp0TMP\SCES_000.01_COV.png" >nul 2>&1
	for %%F in (SCES_000.01_COV.png) do if %%~zF==0 del "%%F"

if not exist SCES_000.01_COV.png (
"%~dp0BAT\Diagbox" gd 0c
    echo\
	echo Unable to connect to internet Or Website
	if /i exist "%~dp0ART.zip" set uselocalART=yes
	echo You will switch to offline mode
	echo\
	echo\
"%~dp0BAT\Diagbox" gd 0f
	pause
		) else (set DownloadART=yes)
	)
)


if exist "%~dp0HDD-OSD-Icons-Pack.zip" (
echo\
"%~dp0BAT\Diagbox" gd 0e
echo HDD-OSD-Icons-Pack.zip detected do you want use it^?
"%~dp0BAT\Diagbox" gd 0f
CHOICE /C YN /M "Select Option:"
IF ERRORLEVEL 1 set uselocalARTHDDOSD=yes
IF ERRORLEVEL 2 set uselocalARTHDDOSD=no
) else (set uselocalARTHDDOSD=no)

if !uselocalARTHDDOSD!==no (
	echo\
	echo Checking internet Or Website connection... For HDD-OSD ART
	ping -n 1 -w 2000 archive.org >nul
	if errorlevel 1 (
			"%~dp0BAT\Diagbox" gd 0c
			echo Unable to PING^^!
			if exist "%~dp0HDD-OSD-Icons-Pack.zip" set uselocalARTHDDOSD=yes
			"%~dp0BAT\Diagbox" gd 07
			) else (
			
	"%~dp0BAT\wget" -q --show-progress "https://archive.org/download/hdd-osd-icons-pack/HDD-OSD-Icons-Pack.zip/PS1%%2FSCES_000.01%%2FPreview.png" -O "%~dp0TMP\Preview.png" >nul 2>&1
	for %%F in (Preview.png) do if %%~zF==0 del "%%F"

if not exist Preview.png (
"%~dp0BAT\Diagbox" gd 0c
    echo\
	echo Unable to connect to internet Or Website
	if exist "%~dp0HDD-OSD-Icons-Pack.zip" set uselocalARTHDDOSD=yes
	echo You will switch to offline mode
	echo\
	echo\
"%~dp0BAT\Diagbox" gd 0f
	pause
		) else (set DownloadARTHDDOSD=yes)
	)
)

"%~dp0BAT\Diagbox" gd 0e
cls
echo\
echo\
echo Scanning Partition !PartitionType!:
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 03

if "!PartitionType!"=="PS1" type "%~dp0BAT\__Cache\PARTITION_POPS_GAME.txt" | "%~dp0BAT\busybox" sort -k2 > "%~dp0TMP\PARTITION_!PartitionType!.txt"
if "!PartitionType!"=="PS2" type "%~dp0BAT\__Cache\PARTITION_HDL_GAME.txt" | "%~dp0BAT\busybox" sort -k2 > "%~dp0TMP\PARTITION_!PartitionType!.txt"
if "!PartitionType!"=="APP" type "%~dp0BAT\__Cache\PARTITION_APPS.txt" | "%~dp0BAT\busybox" sort -k2 > "%~dp0TMP\PARTITION_!PartitionType!.txt"

"%~dp0BAT\busybox" sed "s/|.*//" "%~dp0TMP\PARTITION_!PartitionType!.txt" > "%~dp0TMP\PARTITION_TMP.txt" & type "%~dp0TMP\PARTITION_TMP.txt"
"%~dp0BAT\Diagbox" gd 0e
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0f

if !UPDATEPPHeader!==Manually (
	echo\
	"%~dp0BAT\Diagbox" gd 0e
	echo Please type the gameid ^+ GameName as shown in the Games List.
	"%~dp0BAT\Diagbox" gd 07
    set /p PartName=
    IF "!PartName!"=="" (goto HDDOSDPartManagement)
	"%~dp0BAT\busybox" grep -Fx "!PartName!" "%~dp0TMP\PARTITION_TMP.txt" >nul
	if errorlevel 1 (set "PartName=!PartName!") else ("%~dp0BAT\busybox" grep -F -w -m 1 "!PartName!" "%~dp0TMP\PARTITION_!PartitionType!.txt" | "%~dp0BAT\busybox" sed "s/^[^|]*|//" > "%~dp0TMP\PartNameHeader.txt" & set /P PartName=<"%~dp0TMP\PartNameHeader.txt")

"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Detecting !PartName! Partition:
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 07

   "%~dp0BAT\busybox" grep -w "!PartName!" "%~dp0TMP\PARTITION_!PartitionType!.txt" | "%~dp0BAT\busybox" sed "s/^[^|]*|//" > "%~dp0TMP\PPSelected.txt" & set /P PPSELECTED=<"%~dp0TMP\PPSelected.txt"
	
	if "!PPSELECTED!"=="!PartName!" (
	echo !PartName!> "%~dp0TMP\PARTITION_!PartitionType!.txt"
    "%~dp0BAT\Diagbox" gd 0a
	echo         Partition Detected
	"%~dp0BAT\Diagbox" gd 07
	) else (
	"%~dp0BAT\Diagbox" gd 0c
	echo         Partition NOT Detected
	echo\
	echo\
	"%~dp0BAT\Diagbox" gd 07
	rmdir /Q/S "%~dp0TMP" >nul 2>&1
	pause & (goto HDDOSDPartManagement)
	)
)

REM "%~dp0BAT\Diagbox" gd 0e
REM echo\
REM echo\
REM echo Choose what you want to update:
REM echo ---------------------------------------------------
REM echo\
"%~dp0BAT\Diagbox" gd 0f

	  echo\
	  echo\
      "%~dp0BAT\Diagbox" gd 0e
      echo Do you want to update the titles displayed in HDD-OSD, PSBBN, XMB^?
      "%~dp0BAT\Diagbox" gd 0f
      CHOICE /C YN /M "Select Option:"
	  IF !ERRORLEVEL!==1 (echo Yes & set UpdateTitle=Yes) else (echo No & set UpdateTitle=No)
	  echo\
	  
	 "%~dp0BAT\Diagbox" gd 0e
      echo Do you want to update the 3D icons displayed in HDD-OSD^?
      "%~dp0BAT\Diagbox" gd 0f
      CHOICE /C YN /M "Select Option:"
	  IF !ERRORLEVEL!==1 (echo Yes & set Update3DIcon=Yes) else (echo No & set Update3DIcon=No)
	  echo\
	  
	  "%~dp0BAT\Diagbox" gd 0e
      echo Do you want to update the Game infos displayed in PSBBN, XMB^?
      "%~dp0BAT\Diagbox" gd 0f
      CHOICE /C YN /M "Select Option:"
	  IF !ERRORLEVEL!==1 (echo Yes & set UpdateGameInfos=Yes) else (echo No & set UpdateGameInfos=No)
	  echo\
	  
      "%~dp0BAT\Diagbox" gd 0e
      echo Do you want to update the ART resources displayed in PSBBN, XMB^?
      "%~dp0BAT\Diagbox" gd 0f
      CHOICE /C YN /M "Select Option:"
	  IF !ERRORLEVEL!==1 (echo Yes & set UpdateART=Yes) else (echo No & set UpdateART=No)
	  echo\
	  
	  if !PartitionType!==PS2 (
	  if not defined UpdateLauncher (
	  "%~dp0BAT\Diagbox" gd 0e
      echo Do you want to update/inject OPL-Launcher^?
      "%~dp0BAT\Diagbox" gd 0f
      CHOICE /C YN /M "Select Option:"
	  IF !ERRORLEVEL!==1 (echo Yes & set UpdateLauncher=Yes) else (echo No & set "UpdateLauncher=")
	  echo\
		)
	  )
	  
	  if !PartitionType!==PS1 (
	  if exist "%~dp0POPS-Binaries\Hugopocked_POPStarter_Fixes.zip" (
	  "%~dp0BAT\Diagbox" gd 0e
	  echo Do you want to update Hugopocked patches^?
	  "%~dp0BAT\Diagbox" gd 0f
	  CHOICE /C YN /M "Select Option:"
	  IF !ERRORLEVEL!==1 (echo Yes & set "HugoPatchesFix=Yes" & "%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0POPS-Binaries\Hugopocked_POPStarter_Fixes.zip" -o"%~dp0TMP" id.txt -r -y) else (echo No & set HugoPatchesFix=No)
	  )
	  
	  REM "%~dp0BAT\Diagbox" gd 0e
      REM echo Do you want to update POPStarter?
      REM "%~dp0BAT\Diagbox" gd 0f
      REM CHOICE /C YN /M "Select Option:"
	  REM IF !ERRORLEVEL!==1 (echo Yes & set UpdateLauncher=Yes) else (echo No & set UpdateLauncher=No)
	  REM echo\
      )
	  
echo\
echo\
PAUSE
cls
if !PartitionType!==PS2 chcp 65001 >nul 2>&1
for /f "usebackq tokens=1* delims=|" %%p in ("%~dp0TMP\PARTITION_!PartitionType!.txt") do (
set "PartName="
set PartName=%%q
if not defined PartName set PartName=%%p

set "PartPFS="
set "dbtitleTMP="
set "gameid="
set "gameid2="
set "region="
set "RELEASETMP="
set "DEVELOPERTMP="
set "PUBLISHERTMP="
set "GENRETMP="
set "Contentweb="

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo !PartName!
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0f

	echo !PartName!| "%~dp0BAT\busybox" grep -o "[A-Z][A-Z][A-Z][A-Z]-[0-9][0-9][0-9][0-9][0-9]" > "%~dp0TMP\DetectID.txt" & set /P gameid2=<"%~dp0TMP\DetectID.txt"
	if not defined gameid2 (
	"%~dp0BAT\Diagbox" gd 0c
	echo ERROR: Invalid partition name. Please reinstall the game.
	echo\
	"%~dp0BAT\Diagbox" gd 06
	echo Your partition name should look like this: PP.SLES-12345..GAME_NAME
	) else (
	
	REM Lightspan Educational ID
	if "!gameid2:~0,3!"=="LSP" (
	
	echo device !@pfsshell_path! > "%~dp0TMP\pfs-updateheader.txt"
	echo mount "!PartName!" >> "%~dp0TMP\pfs-updateheader.txt"
	echo cd res >> "%~dp0TMP\pfs-updateheader.txt"
	echo get info.sys >> "%~dp0TMP\pfs-updateheader.txt"
	echo umount >> "%~dp0TMP\pfs-updateheader.txt"
	echo exit >> "%~dp0TMP\pfs-updateheader.txt"
	type "%~dp0TMP\pfs-updateheader.txt" | "%~dp0BAT\pfsshell" >nul 2>&1
    
	"%~dp0BAT\busybox" grep "title_id =" "%~dp0TMP\info.sys" | "%~dp0BAT\busybox" cut -c12-50 | "%~dp0BAT\busybox" sed "s/$/01/" | "%~dp0BAT\busybox" sed "s/.\{8\}/&./" > "%~dp0TMP\DetectID.txt" & set /P gameid=<"%~dp0TMP\DetectID.txt"

	REM Rebuild original LSP gameid for get title
	if "!gameid!"=="LSP90513.002" set gameid2=LSP905132
	if "!gameid!"=="LSP05010.101" set gameid2=LSP050101
	
	if !gameid2!==LSP09110 set gameid=LSP09011.002
	if !gameid2!==LSP90130 set gameid=LSP90513.002
	if !gameid2!==LSP05101 set gameid=LSP05010.102
	if !gameid2!==LSP90352 set gameid=LSP90535.200
	if !gameid2!==LSP90127 set gameid=LSP90712.700
	if !gameid2!==LSP90363 set gameid=LSP90736.300
	
	"%~dp0BAT\busybox" grep "title_id =" "%~dp0TMP\info.sys" | "%~dp0BAT\busybox" cut -c12-50 > "%~dp0TMP\DetectID.txt" & set /P gameid2=<"%~dp0TMP\DetectID.txt"
	) else (
	echo !gameid2!| "%~dp0BAT\busybox" sed "s/-/_/g" | "%~dp0BAT\busybox" sed "s/.\{8\}/&./" > "%~dp0TMP\DetectID.txt" & set /P gameid=<"%~dp0TMP\DetectID.txt"
	)

MD "%~dp0TMP\!gameid2!\PP.HEADER\PFS\res\image"
cd /d "%~dp0TMP\!gameid2!\PP.HEADER"

	 if defined CreatePFSRes (
	 "%~dp0BAT\busybox" grep "0x0100" "%~dp0BAT\__Cache\PARTITION_PS2HDD.txt" | "%~dp0BAT\busybox" grep -o "PP.!PartName:~3!" > "%~dp0TMP\PartPFS.txt" & set /P PartPFS=<"%~dp0TMP\PartPFS.txt"
	 if defined PartPFS (set "PartName=PP.!PartName:~3!" & set "CreatePFS=") else ("%~dp0BAT\hdl_dump" modify !@hdl_path! "!PartName!" -hide & set "PartName=__.!PartName:~3!" & set "CreatePFS=Yes")
	 )

	 REM Dump Header
	 "%~dp0BAT\hdl_dump_fix_header" dump_header !@hdl_path! "!PartName!" >nul 2>&1

     REM Get DBTitle
 	 for /f "tokens=1*" %%A in ( 'findstr !gameid! "%~dp0BAT\TitlesDB\!UseTitleDB!.txt"' ) do if not defined dbtitleTMP set dbtitleTMP=%%B
	 
	 REM PS2 Games
	 if "!PartName:~3!"=="SLUS-20273..NAMCO_MUSEUM__" set "dbtitleTMP=Namco Museum"
	 if "!PartName:~3!"=="SLUG-20273..NAMCO_MUSEUM_50T" set "dbtitleTMP=Namco Museum 50th Anniversary"
	 if "!PartName:~3!"=="SLUS-20643..SOULCALIBUR_II" set "dbtitleTMP=Soulcalibur II"
	 if "!PartName:~3!"=="SLUD-20643..NAMCO_TRANSMISSI" set "dbtitleTMP=Namco Transmission v1.03"
	 
	 REM PS1 Games avoid title conflict
	 if "!PartName:~3!"=="SLPS-01528.POPS.ALIVE__DISC" set "dbtitleTMP=Alive (Disc 2)"
     if "!PartName:~3!"=="SLPS-01529.POPS.ALIVE__DISC" set "dbtitleTMP=Alive (Disc 3)"
     if "!PartName:~3!"=="SCUG-94503.POPS.1XTREME" set "dbtitleTMP=1Xtreme"
     if "!PartName:~3!"=="SLPD-02728.POPS.BREATH_OF_FI" set "dbtitleTMP=Breath of Fire IV (E3 Demo)"
     if "!PartName:~3!"=="SLPS-02728.POPS.BREATH_OF_FI" set "dbtitleTMP=Breath of Fire IV: Utsurowazaru Mono"
     if "!PartName:~3!"=="SLPG-01232.POPS.BUST_A_MOVE" set "dbtitleTMP=Bust A Move (Disc 1) (Genteiban)"
     if "!PartName:~3!"=="SCUS-94503.POPS.ESPN_EXTREME" set "dbtitleTMP=ESPN Extreme Games"
     if "!PartName:~3!"=="SCUG-94167.POPS.JET_MOTO_2_" set "dbtitleTMP=Jet Moto 2: Championship Edition"
	 if "!PartName:~3!"=="SLPS-01975.POPS.KAGAYAKU_KIS" set "dbtitleTMP=Kagayaku Kisetsu e"
	 if "!PartName:~3!"=="SLPS-01629.POPS.KASEI_MONOGA" set "dbtitleTMP=Kasei Monogatari (Genteiban)"
	 if "!PartName:~3!"=="SLPS-02458.POPS.MOMOTAROU_DE" set "dbtitleTMP=Momotarou Dentetsu V"
	 if "!PartName:~3!"=="SLPS-02456.POPS.MOMOTAROU_DE" set "dbtitleTMP=Momotarou Dentetsu V (Shokai Genteiban)"
     if "!PartName:~3!"=="SLUD-00594.POPS.METAL_GEAR_S" set "dbtitleTMP=Metal Gear Solid (Disc 1) (Demo)"
	 if "!PartName:~3!"=="SCUS-94581.POPS.NBA_SHOOTOUT" set "dbtitleTMP=NBA ShootOut 2001 (Demo)"
	 if "!PartName:~3!"=="SLPS-91163.POPS.NAMCO_MUSEUM" set "dbtitleTMP=Namco Museum Encore"
	 if "!PartName:~3!"=="SLPS-00765.POPS.NAMCO_MUSEUM" set "dbtitleTMP=Namco Museum Encore (Shokai Gentei)"
	 if "!PartName:~3!"=="SLPM-80301.POPS.NANIWA_WANGA" set "dbtitleTMP=Naniwa Wangan Battle: Tarzan Yamada & AutoSelect Sawa Kyoudai (Taikenban)"
	 if "!PartName:~3!"=="SLUD-00190.POPS.ODDWORLD__AB" set "dbtitleTMP=Oddworld: Abe's Oddysee (Trade Demo)"
     if "!PartName:~3!"=="SCUX-94161.POPS.PLAYSTATION" set "dbtitleTMP=PlayStation Underground Number 1 (Disc 2)"
	 if "!PartName:~3!"=="SLPM-80085.POPS.SANGOKU_MUSO" set "dbtitleTMP=Sangoku Musou (Taikenban)"
	 if "!PartName:~3!"=="SLPM-84004.POPS.GUNDAM__GGEN" set "dbtitleTMP=Gundam: GGeneration-F (Disc 1) (Tokubetsu-ban)"
	 if "!PartName:~3!"=="SLPM-84005.POPS.GUNDAM__GGEN" set "dbtitleTMP=Gundam: GGeneration-F (Disc 2) (Tokubetsu-ban)"
	 if "!PartName:~3!"=="SLPM-84006.POPS.GUNDAM__GGEN" set "dbtitleTMP=Gundam: GGeneration-F (Disc 3) (Tokubetsu-ban)"
	 if "!PartName:~3!"=="SLPM-84007.POPS.GUNDAM__GGEN" set "dbtitleTMP=Gundam: GGeneration-F (Disc 4) (Premium Disc) (Tokubetsu-ban)"
     if "!PartName:~3!"=="SLPS-01723.POPS.SOUGAKU_TOSH" set "dbtitleTMP=Sougaku Toshi Osaka (Disc 2) (Object)"
	 if "!PartName:~3!"=="SLPS-02313.POPS.SOUKOU_KIHEI" set "dbtitleTMP=Soukou Kihei Votoms: Koutetsu no Gunzei (Shokai Seisan Genteiban)"
     if "!PartName:~3!"=="SLUG-00515.POPS.THE_LOST_WOR" set "dbtitleTMP=The Lost World: Jurassic Park: Special Edition"

	 "%~dp0BAT\busybox" grep "title0" "%~dp0TMP\!gameid2!\PP.HEADER\icon.sys" | "%~dp0BAT\busybox" sed "s/^.* = //" | "%~dp0BAT\busybox" iconv -f windows-1252 -t utf-8 > "%~dp0TMP\NodbtitleTMP.txt"

	 REM Get infos
	 "%~dp0BAT\busybox" sed -n "/<game serial=\"!gameid2!\">/,/<\/game>/ {s/.*<Release>\(.*\)<\/Release>.*/\1/p}" "%~dp0BAT\!PartitionType!DB.xml" > "%~dp0TMP\!gameid2!\RELEASE.txt"
	 "%~dp0BAT\busybox" sed -n "/<game serial=\"!gameid2!\">/,/<\/game>/ {s/.*<Developer>\(.*\)<\/Developer>.*/\1/p}" "%~dp0BAT\!PartitionType!DB.xml" > "%~dp0TMP\!gameid2!\DEVELOPER.txt"
	 "%~dp0BAT\busybox" sed -n "/<game serial=\"!gameid2!\">/,/<\/game>/ {s/.*<Publisher>\(.*\)<\/Publisher>.*/\1/p}" "%~dp0BAT\!PartitionType!DB.xml" > "%~dp0TMP\!gameid2!\PUBLISHER.txt"
	 "%~dp0BAT\busybox" sed -n "/<game serial=\"!gameid2!\">/,/<\/game>/ {s/.*<Genre>\(.*\)<\/Genre>.*/\1/p}" "%~dp0BAT\!PartitionType!DB.xml" > "%~dp0TMP\!gameid2!\GENRE.txt"
	 "%~dp0BAT\busybox" sed -n "/<game serial=\"!gameid2!\">/,/<\/game>/ {s/.*<Contentweb>\(.*\)<\/Contentweb>.*/\1/p}" "%~dp0BAT\!PartitionType!DB.xml" > "%~dp0TMP\!gameid2!\Contentweb.txt"
	 
	 REM Game ID with PBPX other region than JAP
	 findstr !gameid! "%~dp0BAT\Fix_Conflict_Gameid_Title.bat" >nul 2>&1
	 if errorlevel 1 (echo >NUL) else (set "FixGameRegion=Yes" & set "PSBBN=Yes" & call "%~dp0BAT\Fix_Conflict_Gameid_Title.bat")
	 
	 REM Lightspan Educational ID
 	 if "!gameid:~0,3!"=="LSP" set region=U
	 
	 if not defined region (
		 REM A = Asia
		 if "!gameid:~2,1!"=="A" set region=A
		 REM C = China          
       	 if "!gameid:~2,1!"=="C" set region=C
		 REM E = Europe         
		 if "!gameid:~2,1!"=="E" set region=E
		 REM K = Korean         
		 if "!gameid:~2,1!"=="K" set region=K
		 REM P = Japan          
		 if "!gameid:~2,1!"=="P" set region=J
		 REM UC = North America 
		 if "!gameid:~2,1!"=="U" set region=U
         )
	
		if !PartitionType!==APP set region=X
	 REM Unknown region
	 if not defined region set region=X
	 
echo 	   Getting game information...
echo 	 [!PartName!]
"%~dp0BAT\Diagbox" gd 0e
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
call "%~dp0BAT\fix_UTF8.bat"
"%~dp0BAT\Diagbox" gd 0e
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0f
cd /d "%~dp0TMP"

	 if defined CreatePFS (
	 echo            Creating PFS Resources Partition...
	 set PartName=PP.!PartName:~3!
	 "%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0BAT\HDD-PSBBN_XMB_SAMPLE_HEADER.zip" res\* -o"%~dp0TMP\!gameid2!\PP.HEADER\PFS" -r- -y >nul 2>&1
	 ) else (
	 echo            Extraction Resources Header...
	 echo device !@pfsshell_path! > "%~dp0TMP\pfs-log.txt"
	 echo mount "PP.!PartName:~3!" >> "%~dp0TMP\pfs-log.txt"
	 echo cd res >> "%~dp0TMP\pfs-log.txt"
	 echo ls -l >> "%~dp0TMP\pfs-log.txt"
	 echo umount >> "%~dp0TMP\pfs-log.txt"
	 echo exit >> "%~dp0TMP\pfs-log.txt"
	 type "%~dp0TMP\pfs-log.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" grep -i -e "-rw-" -e "-rwx" | "%~dp0BAT\busybox" cut -c42-500 > "%~dp0TMP\pfs-tmp.log"
	 
	 echo device !@pfsshell_path! > "%~dp0TMP\pfs-log.txt"
	 echo mount "PP.!PartName:~3!" >> "%~dp0TMP\pfs-log.txt"
	 echo mkdir res >> "%~dp0TMP\pfs-log.txt"
	 echo cd res >> "%~dp0TMP\pfs-log.txt"
	 echo mkdir image >> "%~dp0TMP\pfs-log.txt"
	 echo cd image >> "%~dp0TMP\pfs-log.txt"
	 echo ls -l >> "%~dp0TMP\pfs-log.txt"
	 echo umount >> "%~dp0TMP\pfs-log.txt"
	 echo exit >> "%~dp0TMP\pfs-log.txt"
	 type "%~dp0TMP\pfs-log.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" grep -i -e "-rw-" -e "-rwx" | "%~dp0BAT\busybox" cut -c42-500 > "%~dp0TMP\pfs-tmp2.log"
	 
	 echo device !@pfsshell_path! > "%~dp0TMP\pfs-header.txt"
	 echo mount "PP.!PartName:~3!!" >> "%~dp0TMP\pfs-header.txt"
	 echo lcd "%~dp0TMP\!gameid2!\PP.HEADER\PFS" >> "%~dp0TMP\pfs-header.txt"
	 
	 echo cd res >> "%~dp0TMP\pfs-header.txt"
	 mkdir "%~dp0TMP\!gameid2!\PP.HEADER\PFS\res" >nul 2>&1
	 echo lcd "%~dp0TMP\!gameid2!\PP.HEADER\PFS\res" >> "%~dp0TMP\pfs-header.txt"
	 for /f "tokens=*" %%f in (pfs-tmp.log) do (echo get "%%f" >> "%~dp0TMP\pfs-header.txt")
	 
	 echo cd image >> "%~dp0TMP\pfs-header.txt"
	 mkdir "%~dp0TMP\!gameid2!\PP.HEADER\PFS\res\image" >nul 2>&1
	 echo lcd "%~dp0TMP\!gameid2!\PP.HEADER\PFS\res\image" >> "%~dp0TMP\pfs-header.txt"
	 for /f "tokens=*" %%f in (pfs-tmp2.log) do (echo get "%%f" >> "%~dp0TMP\pfs-header.txt")
	 
	 echo umount >> "%~dp0TMP\pfs-header.txt"
	 echo exit >> "%~dp0TMP\pfs-header.txt"
	 type "%~dp0TMP\pfs-header.txt" | "%~dp0BAT\pfsshell" >nul 2>&1
	 )
	 
     REM Fix Busybox illegal chars
     echo "!dbtitleTMP!"| "%~dp0BAT\busybox" sed -e "s/\&/\\\&/g; s./.\\\/.g" | "%~dp0BAT\busybox" sed "s/\""//g" | "%~dp0BAT\busybox" iconv -f windows-1252 -t utf-8 > "%~dp0TMP\dbtitle.txt" & set /P dbtitle=<"%~dp0TMP\dbtitle.txt"
     echo "!DEVELOPERTMP!"| "%~dp0BAT\busybox" sed -e "s/\&/\\\&/g; s./.\\\/.g" | "%~dp0BAT\busybox" sed "s/\""//g" | "%~dp0BAT\busybox" iconv -f windows-1252 -t utf-8 > "%~dp0TMP\DEVELOPER.txt" & set /P DEVELOPER=<"%~dp0TMP\DEVELOPER.txt"
     echo "!PUBLISHERTMP!"| "%~dp0BAT\busybox" sed -e "s/\&/\\\&/g; s./.\\\/.g" | "%~dp0BAT\busybox" sed "s/\""//g" | "%~dp0BAT\busybox" iconv -f windows-1252 -t utf-8 > "%~dp0TMP\PUBLISHER.txt" & set /P PUBLISHER=<"%~dp0TMP\PUBLISHER.txt"
     echo "!GENRETMP!"| "%~dp0BAT\busybox" sed -e "s/\&/\\\&/g; s./.\\\/.g" | "%~dp0BAT\busybox" sed "s/\""//g" | "%~dp0BAT\busybox" iconv -f windows-1252 -t utf-8 > "%~dp0TMP\GENRE.txt" & set /P GENRE=<"%~dp0TMP\GENRE.txt"
	 
     if !UpdateTitle!==Yes (
	 echo            Updating Title...
	 
	 REM HDD-OSD Infos
	 "%~dp0BAT\busybox" sed -i -e "s/ = /=/g; s/=/ = /g; s/  =/ = /g" "%~dp0TMP\!gameid2!\PP.HEADER\icon.sys"
	 if defined dbtitle "%~dp0BAT\busybox" sed -i -e "s/title0 =.*/title0 =/g; s/title0 =/title0 = !dbtitle!/g" "%~dp0TMP\!gameid2!\PP.HEADER\icon.sys"
 	 if defined dbtitle "%~dp0BAT\busybox" sed -i -e "s/title1 =.*/title1 =/g; s/title1 =/title1 = !gameid2!/g" "%~dp0TMP\!gameid2!\PP.HEADER\icon.sys"
	 if !showtype!==Game if !DBLang!==Fr "%~dp0BAT\busybox" sed -i -e "s/uninstallmes0 =.*/uninstallmes0 =/g; s/uninstallmes0 =/uninstallmes0 = Cela supprimera le jeu\./g" "%~dp0TMP\!gameid2!\PP.HEADER\icon.sys"
	 
	 if !PartitionType!==APP "%~dp0BAT\busybox" sed -ie "s/title1 =.*/title1 =/g; s/title1 =/title1 = !GENRE!/g" "%~dp0TMP\!gameid2!\PP.HEADER\icon.sys"
	 "%~dp0BAT\busybox" sed -i -e "s/\s*$//" "%~dp0TMP\!gameid2!\PP.HEADER\icon.sys"
	 
	 if exist "%~dp0TMP\!gameid2!\PP.HEADER\PFS\res\info.sys" (
	 REM PSBBN, XMB Menu Infos
	 if defined dbtitle "%~dp0BAT\busybox" sed -i -e "s/title =.*/title =/g; s/title =/title = !dbtitle!/g" "%~dp0TMP\!gameid2!\PP.HEADER\PFS\res\info.sys"
	 if defined dbtitle "%~dp0BAT\busybox" sed -i -e "s/\"TOP-TITLE\" label=\".*\"/\"TOP-TITLE\" label=\"!dbtitle!\"/g; s/\&/\&amp;/g" "%~dp0TMP\!gameid2!\PP.HEADER\PFS\res\man.xml"
	 )
	)

     if !Update3DIcon!==Yes (
	 echo            Updating 3D Icon...
	
	 if !DownloadARTHDDOSD!==yes for %%f in (icon.sys list.ico del.ico) do "%~dp0BAT\wget" -q "https://archive.org/download/hdd-osd-icons-pack/HDD-OSD-Icons-Pack.zip/!PartitionType!%%2F!gameid!%%2F%%f" -O "%~dp0TMP\%%f" >nul 2>&1
	 if !uselocalARTHDDOSD!==yes if exist "%~dp0HDD-OSD-Icons-Pack.zip" "%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0HDD-OSD-Icons-Pack.zip" -o"%~dp0TMP" !PartitionType!\!gameid!\ -r -y & move "%~dp0TMP\!PartitionType!\!gameid!\*" "%~dp0TMP" >nul 2>&1
	 
	 for %%F in (*.ico) do if %%~zF==0 (del "%%F")
	 if not exist "%~dp0TMP\del.ico" copy "%~dp0TMP\list.ico" "%~dp0TMP\del.ico" >nul 2>&1
	 
	 REM Update Background Color for HDD-OSD icon
	 for %%F in (icon.sys) do if %%~zF==0 del "%%F"
	 
	 if exist "%~dp0TMP\icon.sys" (
	 "%~dp0BAT\busybox" grep -A 11 "bgcola" "%~dp0TMP\icon.sys" | "%~dp0BAT\busybox" sed "s/ = /=/g; s/=/ = /g" > "%~dp0TMP\!gameid2!\BGCOLOR.txt"
	 "%~dp0BAT\busybox" sed -i "4,15d" "%~dp0TMP\!gameid2!\PP.HEADER\icon.sys"
	 "%~dp0BAT\busybox" sed -i "/^title1 =/r %~dp0TMP\!gameid2!\BGCOLOR.txt" "%~dp0TMP\!gameid2!\PP.HEADER\icon.sys"
	 )
	 for %%F in (*.ico) do (move %%F "%~dp0TMP\!gameid2!\PP.HEADER" >nul) & if not exist "%~dp0TMP\!gameid2!\PP.HEADER\icon.sys" move "%~dp0TMP\icon.sys" "%~dp0TMP\!gameid2!\PP.HEADER" >nul
	)

     if !UpdateGameInfos!==Yes (
	 echo            Updating Game Infos...
	 
	 if exist "%~dp0TMP\!gameid2!\PP.HEADER\PFS\res\info.sys" (
	 "%~dp0BAT\busybox" sed -i -e "s/title_id =.*/title_id =/g; s/title_id =/title_id = !gameid2!/g" "%~dp0TMP\!gameid2!\PP.HEADER\PFS\res\info.sys"
     "%~dp0BAT\busybox" sed -i -e "s/area =.*/area =/g; s/area =/area = !REGION!/g" "%~dp0TMP\!gameid2!\PP.HEADER\PFS\res\info.sys"
     if defined RELEASETMP "%~dp0BAT\busybox" sed -i -e "s/release_date =.*/release_date =/g; s/release_date =/release_date = !RELEASEBBN!/g" "%~dp0TMP\!gameid2!\PP.HEADER\PFS\res\info.sys"
     if defined DEVELOPER "%~dp0BAT\busybox" sed -i -e "s/developer_id =.*/developer_id =/g; s/developer_id =/developer_id = !DEVELOPER!/g" "%~dp0TMP\!gameid2!\PP.HEADER\PFS\res\info.sys"
     if defined PUBLISHER "%~dp0BAT\busybox" sed -i -e "s/publisher_id =.*/publisher_id =/g; s/publisher_id =/publisher_id = !PUBLISHER!/g" "%~dp0TMP\!gameid2!\PP.HEADER\PFS\res\info.sys"
     if defined GENRE "%~dp0BAT\busybox" sed -i -e "s/genre =.*/genre =/g; s/genre =/genre = !GENRE!/g" "%~dp0TMP\!gameid2!\PP.HEADER\PFS\res\info.sys"

	 REM Fix shity illegal chars for busybox like: /.&
     if defined Contentweb (
	 "%~dp0BAT\busybox" sed -i "s/\&/\\\&/g; s./.\\\/.g" "%~dp0TMP\!gameid2!\Contentweb.txt" & set /P Contentweb=<"%~dp0TMP\!gameid2!\Contentweb.txt"
	 "%~dp0BAT\busybox" sed -i -e "s/content_web =.*/content_web =/g; s/content_web =/content_web = !Contentweb!/g" "%~dp0TMP\!gameid2!\PP.HEADER\PFS\res\info.sys"
	  )
	 )
	)

     if !UpdateART!==Yes (
	 echo            Updating Resources ART...
	 
	 if !PartitionType!==APP (
	 
	 if /i not "!DownloadARTHDDOSD!"=="yes" (
		if /i exist "%~dp0HDD-OSD-Icons-Pack.zip" (
				"%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0HDD-OSD-Icons-Pack.zip" -o"%~dp0TMP" !PartitionType!\!gameid!\res -r -y >nul 2>&1
				cd /d "%~dp0TMP\!PartitionType!\!gameid!\res" & for /r %%i in (*.png) do copy "%%i" "%~dp0TMP" >nul 2>&1
				)
			) else (
		for %%f in (jkt_001.png jkt_cp.png 0.png 1.png 2.png) do (
			set "ART_NAME2=!%%f!"
			"%~dp0BAT\wget" -q --show-progress "https://archive.org/download/hdd-osd-icons-pack/HDD-OSD-Icons-Pack.zip/!PartitionType!%%2F!gameid!%%2Fres%%2F%%f" -O "%~dp0TMP\!ART_NAME2!" >nul 2>&1
			)
		)
		if exist "%~dp0TMP\0.png" ren "%~dp0TMP\0.png" "BG.png"
		if exist "%~dp0TMP\1.png" ren "%~dp0TMP\1.png" "SCR0.png"
		if exist "%~dp0TMP\2.png" ren "%~dp0TMP\2.png" "SCR1.png"
	 ) else (

	 set "COV.png=jkt_001"
	 set "BG_00.png=BG"
	 set "LGO.png=jkt_cp"
	 set "SCR_00.png=SCR0"
	 set "SCR_01.png=SCR1"
	 
	 if /i not "!DownloadART!"=="yes" (
		if /i exist "%~dp0ART.zip" (
		
			for %%f in (COV.png BG_00.png LGO.png SCR_00.png SCR_01.png) do (
				set "ART_NAME2=!%%f!"
				"%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0ART.zip" -o"%~dp0TMP" !PartitionType!\!gameid!\!gameid!_%%f -r -y >nul 2>&1
				move "%~dp0TMP\!PartitionType!\!gameid!\!gameid!_%%f" "%~dp0TMP\!ART_NAME2!.png" >nul 2>&1
				)
			)
		) else (
		for %%f in (COV.png BG_00.png LGO.png SCR_00.png SCR_01.png) do (
			set "ART_NAME2=!%%f!"
			"%~dp0BAT\wget" -q --show-progress "https://archive.org/download/OPLM_ART_2024_09/OPLM_ART_2024_09.zip/PS1%%2F!gameid!%%2F!gameid!_%%f" -O "%~dp0TMP\!ART_NAME2!.png" >nul 2>&1
			)
		)
	)

	 cd /d "%~dp0TMP"
	 REM ART CUSTOM GAMEID
	 "%~dp0BAT\7-Zip\7z" e -bso0 "%~dp0BAT\ART_CUSTOM_GAMEID.zip" -o"%~dp0TMP\!PartitionType!\!gameid!" !PartitionType!\!gameid!_COV.png -r -y >nul 2>&1 & move "%~dp0TMP\!PartitionType!\!gameid!\!gameid!_COV.png" "%~dp0TMP\jkt_001.png" >nul 2>&1
	 for %%F in (*.png) do if %%~zF==0 del "%%F"

	 REM Covers
	 if exist "%~dp0TMP\jkt_001.png" "%~dp0BAT\nconvert" -overwrite -out png -resize 256 256 -rtype lanczos -efocus -colors 256 -o "%~dp0TMP\res\jkt_001.png" "%~dp0TMP\jkt_001.png" >nul 2>&1
	 if exist "%~dp0TMP\jkt_001.png" "%~dp0BAT\nconvert" -overwrite -out png -resize 76 108 -rtype lanczos -efocus -colors 256 -o "%~dp0TMP\res\jkt_002.png" "%~dp0TMP\jkt_001.png" >nul 2>&1
	 if exist "%~dp0TMP\jkt_cp.png" move "%~dp0TMP\jkt_cp.png" "%~dp0TMP\res" >nul 2>&1

	 REM Screenshot
	 if exist "%~dp0TMP\BG.png" "%~dp0BAT\nconvert" -overwrite -out png -resize 640 350 -rtype lanczos -efocus -colors 256 -o "%~dp0TMP\res\image\0.png" "%~dp0TMP\BG.png" >nul 2>&1
     if exist "%~dp0TMP\SCR0.png" "%~dp0BAT\nconvert" -overwrite -out png -resize 640 350 -rtype lanczos -efocus -colors 256 -o "%~dp0TMP\res\image\1.png" "%~dp0TMP\SCR0.png" >nul 2>&1
	 if exist "%~dp0TMP\SCR1.png" "%~dp0BAT\nconvert" -overwrite -out png -resize 640 350 -rtype lanczos -efocus -colors 256 -o "%~dp0TMP\res\image\2.png" "%~dp0TMP\SCR1.png" >nul 2>&1

	 ROBOCOPY /E /MOVE "%~dp0TMP\res" "%~dp0TMP\!gameid2!\PP.HEADER\PFS\res" >nul 2>&1
     for %%f in (*.png) do del "%%f"
     )
	 
	 if !UpdateLauncher!==Yes (
	 
	 if !PartitionType!==PS1 (
	 echo            Updating POPStarter...
	 copy "%~dp0POPS-Binaries\POPSTARTER.KELF" "%~dp0TMP\!gameid2!\PP.HEADER\PFS\EXECUTE.KELF" >nul 2>&1
	 )
	 if !PartitionType!==PS2 (
	 echo            Updating OPL Launcher...
	 copy "%~dp0BAT\boot.kelf" "%~dp0TMP\!gameid2!\PP.HEADER" >nul 2>&1
	 copy "%~dp0BAT\boot.kelf" "%~dp0TMP\!gameid2!\PP.HEADER\PFS\EXECUTE.KELF" >nul 2>&1
	  )
	 )

     REM echo            Finishing Updating...
     cd /d "%~dp0TMP\!gameid2!\PP.HEADER\PFS"

	 echo device !@pfsshell_path! > "%~dp0TMP\pfs-updateheader.txt"
	 if defined CreatePFS echo mkpart "!PartName!" 128M PFS >> "%~dp0TMP\pfs-updateheader.txt"
	 echo mount "PP.!PartName:~3!" >> "%~dp0TMP\pfs-updateheader.txt"
	 echo lcd "%~dp0TMP\!gameid2!\PP.HEADER\PFS" >> "%~dp0TMP\pfs-updateheader.txt"
	 if defined UpdateLauncher echo rm EXECUTE.KELF >> "%~dp0TMP\pfs-updateheader.txt"
	 if defined UpdateLauncher echo put EXECUTE.KELF >> "%~dp0TMP\pfs-updateheader.txt"
	 echo lcd "%~dp0TMP\!gameid2!\PP.HEADER\PFS\res" >> "%~dp0TMP\pfs-updateheader.txt"
	 echo mkdir res >> "%~dp0TMP\pfs-updateheader.txt"
	 echo cd res >> "%~dp0TMP\pfs-updateheader.txt"
	 echo rm info.sys >> "%~dp0TMP\pfs-updateheader.txt"
	 echo rm man.xml >> "%~dp0TMP\pfs-updateheader.txt"
	 
	 cd /d "%~dp0TMP\!gameid2!\PP.HEADER\PFS\res"
	 for %%0 in (*) do (echo put "%%0") >> "%~dp0TMP\pfs-updateheader.txt"
	 
	 REM RESSOURCE DIR (PP.NAME\res\image)
	 for /D %%x in (*) do (
	 echo mkdir "%%x" >> "%~dp0TMP\pfs-updateheader.txt"
	 echo lcd "%%x" >> "%~dp0TMP\pfs-updateheader.txt"
 	 echo cd "%%x" >> "%~dp0TMP\pfs-updateheader.txt"
 	 cd "%%x"
	 
	 REM RESSOURCE DIR (PP.NAME\res\image\files.xxx)
 	 for %%1 in (*) do (echo put "%%1") >> "%~dp0TMP\pfs-updateheader.txt"
	 
	 echo lcd .. >> "%~dp0TMP\pfs-updateheader.txt"
	 echo cd .. >> "%~dp0TMP\pfs-updateheader.txt"
	 cd ..
	 )
	 
	 echo lcd .. >> "%~dp0TMP\pfs-updateheader.txt"
	 echo cd .. >> "%~dp0TMP\pfs-updateheader.txt"
	 echo umount >> "%~dp0TMP\pfs-updateheader.txt"
	 
	 if !HugoPatchesFix!==Yes (
	 REM echo         Checking if the game has a need patch GameShark...
	 findstr !gameid! "%~dp0TMP\id.txt" >nul 2>&1
	 if errorlevel 1 (
	 REM echo             No need patch
	 ) else (
	 echo            Updating Hugo's Patches...
	 "%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0POPS-Binaries\Hugopocked_POPStarter_Fixes.zip" -o"%~dp0TMP" !gameid!\* -r -y >nul 2>&1
	 
	 if not exist "%~dp0TMP\!gameid!\*.BIN" (
	 echo device !@pfsshell_path! > "%~dp0TMP\pfs-updatehugofix.txt"
	 echo mount "!PartName!" >> "%~dp0TMP\pfs-updatehugofix.txt"
	 echo lcd "%~dp0TMP" >> "%~dp0TMP\pfs-updatehugofix.txt"
	 echo get "IMAGE0.VCD" >> "%~dp0TMP\pfs-updatehugofix.txt"
	 echo umount >> "%~dp0TMP\pfs-updatehugofix.txt"
	 echo exit >> "%~dp0TMP\pfs-updatehugofix.txt"
	 type "%~dp0TMP\pfs-updatehugofix.txt" | "%~dp0BAT\pfsshell" >nul 2>&1
	 
	 "%~dp0BAT\busybox" md5sum "%~dp0TMP\IMAGE0.VCD" | "%~dp0BAT\busybox" grep -o "[0-9a-z]\{32\}" > "%~dp0TMP\MD5.txt" & set /p MD5=<"%~dp0TMP\MD5.txt"
	 "%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0POPS-Binaries\Hugopocked_POPStarter_Fixes.zip" -o"%~dp0TMP" !gameid!\!MD5!\* -r -y & move "%~dp0TMP\!gameid!\!MD5!\*" "%~dp0TMP\!gameid!" >nul 2>&1
	)
	
	 echo mount __common >> "%~dp0TMP\pfs-updateheader.txt"
	 echo mkdir POPS >> "%~dp0TMP\pfs-updateheader.txt"
	 echo cd POPS >> "%~dp0TMP\pfs-updateheader.txt"
	 echo mkdir "!PartName:~3!" >> "%~dp0TMP\pfs-updateheader.txt"
	 echo cd "!PartName:~3!" >> "%~dp0TMP\pfs-updateheader.txt"
	 echo lcd "%~dp0TMP\!gameid!" >> "%~dp0TMP\pfs-updateheader.txt"
	 for /l %%i in (0, 1, 9) do echo rm PATCH_%%i.BIN >> "%~dp0TMP\pfs-updateheader.txt"
	 for /l %%i in (0, 1, 9) do echo rm TROJAN_%%i.BIN >> "%~dp0TMP\pfs-updateheader.txt"
	 cd /d "%~dp0TMP\!gameid!" & for %%x in (TROJAN_?.BIN PATCH_?.BIN CHEATS.TXT Readme.txt) do echo put "%%x" >> "%~dp0TMP\pfs-updateheader.txt"
		)
	 )
	 
	 echo umount >> "%~dp0TMP\pfs-updateheader.txt"
	 echo exit >> "%~dp0TMP\pfs-updateheader.txt"
	 type "%~dp0TMP\pfs-updateheader.txt" | "%~dp0BAT\pfsshell" >nul 2>&1

	 if defined CreatePFS "%~dp0BAT\busybox" sed -i "1s/^.*$/BOOT2 = pfs:\/EXECUTE.KELF/" "%~dp0TMP\!gameid2!\PP.HEADER\system.cnf"
	 cd /d "%~dp0TMP\!gameid2!\PP.HEADER" & "%~dp0BAT\hdl_dump" modify_header !@hdl_path! "PP.!PartName:~3!" >nul 2>&1
	 
	 REM Inject Header for hidden partition,
	 "%~dp0BAT\busybox" sed -i "1s/^.*$/BOOT2 = PATINFO/" "%~dp0TMP\!gameid2!\PP.HEADER\system.cnf"
	 "%~dp0BAT\hdl_dump_fix_header" modify_header !@hdl_path! "__.!PartName:~3!" >nul 2>&1

	 rmdir /Q/S "%~dp0TMP\!gameid2!" >nul 2>&1
	 for %%z in ("%~dp0TMP\RELEASE.txt" "%~dp0TMP\REGION.txt" "%~dp0TMP\DEVELOPER.txt" "%~dp0TMP\PUBLISHER.txt" "%~dp0TMP\GENRE.txt" "%~dp0TMP\icon.sys" "%~dp0TMP\!gameid2!.html") do del %%z >nul 2>&1
	 
	 echo            Completed...
	 echo ---------------------------------------------------
     )
)
	 
	 if defined CreatePFS (
	 md "%~dp0TMP\PP.HEADER" >nul 2>&1 & cd /d "%~dp0TMP\PP.HEADER"
	 
	 REM echo            Checking OPL Files... 
     echo device !@pfsshell_path! > "%~dp0TMP\pfs-OPLconfig.txt"
	 echo mount !OPLPART! >> "%~dp0TMP\pfs-OPLconfig.txt"
	 if defined CUSTOM_OPLPART echo cd OPL >> "%~dp0TMP\pfs-OPLconfig.txt"
	 echo ls >> "%~dp0TMP\pfs-OPLconfig.txt"
	 echo cd .. >> "%~dp0TMP\pfs-OPLconfig.txt"
	 echo umount >> "%~dp0TMP\pfs-OPLconfig.txt"
	 echo exit >> "%~dp0TMP\pfs-OPLconfig.txt"
     type "%~dp0TMP\pfs-OPLconfig.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" grep -ie "OPNPS2LD.ELF" > "%~dp0TMP\OPLELF.txt" 2>&1 & set /P OPLELF=<"%~dp0TMP\OPLELF.txt"

	 echo device !@pfsshell_path! > "%~dp0TMP\pfs-OPLconfig.txt"
     echo mount __common >> "%~dp0TMP\pfs-OPLconfig.txt"
     echo cd OPL >> "%~dp0TMP\pfs-OPLconfig.txt"
	 echo hdd_partition=!OPLPART!> "%~dp0TMP\PP.HEADER\conf_hdd.cfg" >nul 2>&1
     echo put conf_hdd.cfg >> "%~dp0TMP\pfs-OPLconfig.txt"
	 echo cd .. >> "%~dp0TMP\pfs-OPLconfig.txt"
	 echo umount >> "%~dp0TMP\pfs-OPLconfig.txt"
	 
	 if not defined OPLELF (
	 "%~dp0BAT\7-Zip\7z" e -bso0 "%~dp0BAT\APPS.zip" -o"%~dp0TMP\OPL_STABLE" "APPS\Open PS2 Loader Stable\*.ELF" -r -y >nul 2>&1 & move "%~dp0TMP\OPL_STABLE\*.ELF" "%~dp0TMP\PP.HEADER\OPNPS2LD.ELF" >nul 2>&1
     echo mount !OPLPART! >> "%~dp0TMP\pfs-OPLconfig.txt"
	 if defined CUSTOM_OPLPART echo mkdir OPL >> "%~dp0TMP\pfs-OPLconfig.txt"
	 if defined CUSTOM_OPLPART echo cd OPL >> "%~dp0TMP\pfs-OPLconfig.txt"
	 echo put OPNPS2LD.ELF >> "%~dp0TMP\pfs-OPLconfig.txt"
	 echo cd .. >> "%~dp0TMP\pfs-OPLconfig.txt"
	 echo umount >> "%~dp0TMP\pfs-OPLconfig.txt"
	 )
	 
     echo exit >> "%~dp0TMP\pfs-OPLconfig.txt"
     type "%~dp0TMP\pfs-OPLconfig.txt" | "%~dp0BAT\pfsshell" >nul 2>&1
	 
	 REM Reloading HDD Cache
	 echo\
	 echo Reloading HDD Cache...
     call "%~dp0BAT\__ReloadHDD_cache.bat" >nul 2>&1
	 )

cd /d "%~dp0" & rmdir /Q/S "%~dp0TMP" >nul 2>&1

chcp 1252 >nul 2>&1
echo\
"%~dp0BAT\Diagbox" gd 0f
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo Completed...
echo\
echo\
"%~dp0BAT\Diagbox" gd 0f

pause & (goto HDDOSDPartManagement)
REM ####################################################################################################################
:UpdatePartAPPS
cls
mkdir "%~dp0TMP" >nul 2>&1

IF NOT DEFINED @hdl_path ( rmdir /Q/S "%~dp0TMP" >nul 2>&1 & goto ScanningPS2HDD ) else (
"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning for Playstation 2 HDDs:
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "!@hdl_path!" | "%~dp0BAT\busybox" grep "Playstation 2 HDD" >nul
if errorlevel 1 set "@hdl_path=" & goto ScanningPS2HDD
echo       [!@hdl_path! !@TotalHDD_Size! - !@ModelePS2HDD!]
)

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Update APPS:
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1^) Yes
"%~dp0BAT\Diagbox" gd 0c
echo         2^) No
"%~dp0BAT\Diagbox" gd 0e
echo         3^) Yes (Update Only OPL which is present in OPL Resources Partition for HDD-OSD, PSBBN, XMB)
echo\
"%~dp0BAT\Diagbox" gd 07
CHOICE /C 123 /M "Select Option:"

IF %ERRORLEVEL%==1 set "UpdateAPPS=Yes" & set "Download=Yes" & set "@APPHDDOSD=Yes"
IF %ERRORLEVEL%==2 (goto DownloadAPPSMenu)
IF %ERRORLEVEL%==3 set "UpdateAPPS=YesOPLROOT"

if !UpdateAPPS!==Yes (
"%~dp0BAT\Diagbox" gd 0f
   cls
   echo\
   echo\
   echo Scanning Partitions:
   echo ---------------------------------------------------
   "%~dp0BAT\busybox" grep -e "APPS-" "%~dp0BAT\__Cache\PARTITION_PS2HDD.txt" | "%~dp0BAT\busybox" cut -c30-250 > "%~dp0TMP\hdd-prt.txt"
   "%~dp0BAT\busybox" grep -o "APPS-[0-9][0-9][0-9][0-9][0-9]" "%~dp0TMP\hdd-prt.txt" | "%~dp0BAT\busybox" sed "s/-/_/g; s/.\{8\}/&./g" > "%~dp0TMP\APPIDTMP.txt"
   type "%~dp0TMP\hdd-prt.txt"
   echo ---------------------------------------------------
   )
   
   echo\
   echo\
   echo Do you want to update OPL which is present in OPL Resources Partition
   echo This will be used to run your games from HDD-OSD, PSBBN, XMB
   CHOICE /C YN
   IF !ERRORLEVEL!==1 (
   echo\
   echo Which version do you want to use
   echo 1. Open PS2 Loader Latest
   echo 2. Open PS2 Loader Stable
   echo 3. Do not change
   CHOICE /C 123 /M "Select Option:"
   IF !ERRORLEVEL!==1 set USEOPL=LATEST
   IF !ERRORLEVEL!==2 set USEOPL=STABLE
   IF !ERRORLEVEL!==3 echo >nul
   )
   
   call "%~dp0BAT\APPS.bat"

goto DownloadAPPSMenu
REM ####################################################################################################################
:FreeHDBootFixOSDCorruption
cls
mkdir "%~dp0TMP" >nul 2>&1
cd /d "%~dp0TMP"

IF NOT DEFINED @hdl_path ( rmdir /Q/S "%~dp0TMP" >nul 2>&1 & goto ScanningPS2HDD ) else (
"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning for Playstation 2 HDDs:
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "!@hdl_path!" | "%~dp0BAT\busybox" grep "Playstation 2 HDD" >nul
if errorlevel 1 set "@hdl_path=" & goto ScanningPS2HDD
echo       [!@hdl_path! !@TotalHDD_Size! - !@ModelePS2HDD!]
)

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Fix FreeHDBoot OSD Graphical Corruption
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1^) Yes
"%~dp0BAT\Diagbox" gd 0c
echo         2^) No
"%~dp0BAT\Diagbox" gd 0e
echo         3^) See Example
echo\
"%~dp0BAT\Diagbox" gd 07
CHOICE /C 123 /M "Select Option:"

if %ERRORLEVEL%==2 (goto FreeHDBootManagement)
if %ERRORLEVEL%==3 "%~dp0BAT\7-Zip\7z" e -bso0 "%~dp0BAT\FreeHDBootCFG.zip" OSD.png -o"%~dp0TMP" -r -y & "%~dp0TMP\OSD.PNG" & goto FreeHDBootFixOSDCorruption

"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Detecting FreeHDBoot:
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0f

	echo device !@pfsshell_path! > "%~dp0TMP\pfs-prt.txt"
	echo mount __system >> "%~dp0TMP\pfs-prt.txt"
	echo cd osd >> "%~dp0TMP\pfs-prt.txt"
	echo ls >> "%~dp0TMP\pfs-prt.txt"
	echo exit >> "%~dp0TMP\pfs-prt.txt"
	type "%~dp0TMP\pfs-prt.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" grep -o "osdmain.elf" > "%~dp0TMP\hdd-prt.txt"
	
	set /P @hdd_avl=<"%~dp0TMP\hdd-prt.txt"
	IF "!@hdd_avl!"=="osdmain.elf" (
	"%~dp0BAT\Diagbox" gd 0a
		echo         FreeHDBoot - Detected
	"%~dp0BAT\Diagbox" gd 0f
		) else (
		"%~dp0BAT\Diagbox" gd 0c
		echo         FreeHDBoot - Not Detected
		echo              No patch needed
		echo\
		"%~dp0BAT\Diagbox" gd 06
		rmdir /Q/S "%~dp0TMP" >nul 2>&1
		pause & (goto mainmenu)
		)

echo\
echo\
pause 
cls

    "%~dp0BAT\Diagbox" gd 0e
    echo\
    echo\
    echo FreeHDBoot OSD FIX:
    echo ---------------------------------------------------
    "%~dp0BAT\Diagbox" gd 0f
	
	echo        Checking...
	echo device !@pfsshell_path! > "%~dp0TMP\pfs-prt.txt"
	echo mount __system >> "%~dp0TMP\pfs-prt.txt"
	echo cd osd100 >> "%~dp0TMP\pfs-prt.txt"
	echo ls >> "%~dp0TMP\pfs-prt.txt"
	echo exit >> "%~dp0TMP\pfs-prt.txt"
	type "%~dp0TMP\pfs-prt.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" grep -o "hosdsys.elf" > "%~dp0TMP\hdd-prt.txt" & set /P @hdd-osd=<"%~dp0TMP\hdd-prt.txt"
    
	echo        Progress...
    echo device !@pfsshell_path! > "%~dp0TMP\pfs-fhdb-fix.txt"
    echo mount __sysconf >> "%~dp0TMP\pfs-fhdb-fix.txt"
	echo cd FMCB >> "%~dp0TMP\pfs-fhdb-fix.txt"
	echo get FREEHDB.CNF >> "%~dp0TMP\pfs-fhdb-fix.txt"
	echo rm FREEHDB.CNF >> "%~dp0TMP\pfs-fhdb-fix.txt"
    echo umount >> "%~dp0TMP\pfs-fhdb-fix.txt"
	echo exit >> "%~dp0TMP\pfs-fhdb-fix.txt"
	type "%~dp0TMP\pfs-fhdb-fix.txt" | "%~dp0BAT\pfsshell" >nul 2>&1

	IF "!@hdd-osd!"=="hosdsys.elf" (
	"%~dp0BAT\busybox" sed -i "/OSDSYS_left_cursor/s/009/006/g; /OSDSYS_right_cursor/s/008/005/g; /OSDSYS_menu_bottom_delimiter/s/006/009/g; /OSDSYS_menu_bottom_delimiter/s/007/010/g" "%~dp0TMP\FREEHDB.CNF"
	) else (
	"%~dp0BAT\busybox" sed -i "/OSDSYS_left_cursor/s/006/009/g; /OSDSYS_right_cursor/s/005/008/g; /OSDSYS_menu_bottom_delimiter/s/009/006/g; /OSDSYS_menu_bottom_delimiter/s/010/007/g" "%~dp0TMP\FREEHDB.CNF"
	)
	
	echo device !@pfsshell_path! > "%~dp0TMP\pfs-fhdb-fix.txt"
	echo mount __sysconf >> "%~dp0TMP\pfs-fhdb-fix.txt"
	echo cd FMCB >> "%~dp0TMP\pfs-fhdb-fix.txt"
	echo put FREEHDB.CNF >> "%~dp0TMP\pfs-fhdb-fix.txt"
	echo umount >> "%~dp0TMP\pfs-fhdb-fix.txt"
	echo exit >> "%~dp0TMP\pfs-fhdb-fix.txt"
	type "%~dp0TMP\pfs-fhdb-fix.txt" | "%~dp0BAT\pfsshell" >nul 2>&1
    echo        Completed...

cd /d "%~dp0" & rmdir /Q/S "%~dp0TMP" >nul 2>&1

"%~dp0BAT\Diagbox" gd 0f
echo\
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo Completed...
echo\
echo\
"%~dp0BAT\Diagbox" gd 07

pause & (goto FreeHDBootManagement)
REM ####################################################################################################################
:InstallNBDDriver
cls
cd /d "%~dp0"
mkdir "%~dp0TMP" >nul 2>&1

echo\
bcdedit.exe | "%~dp0BAT\busybox" grep testsigning | "%~dp0BAT\busybox" grep -o Yes > "%~dp0TMP\checkmodetest.txt" & set /P checkmodetest=<"%~dp0TMP\checkmodetest.txt"
set modetest=!checkmodetest!

    if !modetest!==Yes (
	echo\
    "%~dp0BAT\Diagbox" gd 0a
    echo Windows test mode detected!
    "%~dp0BAT\Diagbox" gd 0f
	
   "%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0BAT\Driver_WNBD.zip" -o"%~dp0__DriverWNBD" -r -y
   "%~dp0__DriverWNBD\wnbd-client.exe" uninstall-driver
   "%~dp0__DriverWNBD\wnbd-client.exe" install-driver "%~dp0__DriverWNBD\wnbd.inf"
   
   echo\
   echo\
   echo When you restart your computer, test mode will be disabled.
   bcdedit -set TESTSIGNING OFF >nul 2>&1

echo\
echo\
rmdir /Q/S "%~dp0__DriverWNBD" >nul 2>&1

echo\
"%~dp0BAT\Diagbox" gd 0f
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo Completed...
echo\
echo\
"%~dp0BAT\Diagbox" gd 0f

pause & (goto NBDServer)

) else (
echo\
"%~dp0BAT\Diagbox" gd 0c
echo Windows test mode NOT DETECTED!
"%~dp0BAT\Diagbox" gd 06
echo YOU NEED to enable test mode to install the drivers
echo\
echo Please note that test signed drivers cannot be used when Secure Boot is enabled
echo You must disable Secure Boot UEFI in your computer's bios
"%~dp0BAT\Diagbox" gd 0f
echo\
echo Reboot your computeur now for enable Windows test mode?
echo\
choice /c YN
echo\
if errorlevel 1 set rebootnow=yes
if errorlevel 2 (goto NBDServer)

if !rebootnow!==yes (
bcdedit -set TESTSIGNING ON >nul 2>&1
shutdown.exe /r /t 05

echo Reboot...
echo.
echo 5
ping -n 2 127.0.0.1>nul
echo 4
ping -n 2 127.0.0.1>nul
echo 3
ping -n 2 127.0.0.1>nul
echo 2
ping -n 2 127.0.0.1>nul
echo 1
ping -n 2 127.0.0.1>nul
 )
)

pause & (goto NBDServer)
REM ####################################################################################################################
:POPSHugoPatch
cls
IF NOT EXIST "%~dp0TMP" MD "%~dp0TMP"

if exist "%~dp0POPS-Binaries\Hugopocked_POPStarter_Fixes.zip" (
echo\
echo\
echo Apply HugoPocked's patches If available?
"%~dp0BAT\Diagbox" gd 0e
echo Patches are intended to fix games that don't work with POPStarter [Yes recommended]
CHOICE /C YN /M "Select Option:"
if errorlevel 1 set patchVCD=yes
if errorlevel 2 (goto POPSManagement)

echo\
echo\
"%~dp0BAT\Diagbox" gd 0e
echo Do you want to change the default directory^?
"%~dp0BAT\Diagbox" gd 07
echo ^(Useful if your POPS folder are on another HDD^)
CHOICE /C YN
echo\
if !errorlevel!==1 (
echo VCD Games must be in a POPS folder to be detected
echo\
echo Example: E:\
set /p "HDDPATH=Enter the root path where yours APPS folder:"
)
if not defined HDDPATH set HDDPATH=%rootpath%

"%~dp0BAT\Diagbox" gd 0e
cls
echo\
echo\
echo Scanning Games List:
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
cd /d "!HDDPATH!\POPS" & dir /b /a-d| "%~dp0BAT\busybox" grep -ie ".*\.VCD$" > "%~dp0TMP\GameslistTMP.txt"
type "%~dp0TMP\GameslistTMP.txt"
"%~dp0BAT\Diagbox" gd 0e
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0f

"%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0POPS-Binaries\Hugopocked_POPStarter_Fixes.zip" -o"%~dp0TMP" id.txt -r -y
set /a gamecount=0
for /f "usebackq delims=" %%f in ("%~dp0TMP\GameslistTMP.txt") do (
set /a gamecount+=1
	
	setlocal DisableDelayedExpansion
	set filename=%%f
	set fname=%%~nf
	set "gameid="
	setlocal EnableDelayedExpansion
    
	echo\
	echo\
	echo !gamecount! - !filename!
	
	REM Get gameid
	"%~dp0BAT\UPSX_SID" "!filename!" -1 > "%~dp0TMP\gameid.txt" & set /p gameid=<"%~dp0TMP\gameid.txt"
	
	REM echo         Checking if the game has a need patch GameShark...
	findstr !gameid! "%~dp0TMP\id.txt" >nul 2>&1
    if errorlevel 1 (
    echo             No need patch
    ) else (
	echo             Patches Applied...
	md "!HDDPATH!\POPS\!fname!" >nul 2>&1
	for %%d in ("!HDDPATH!\POPS\!fname!\*.BIN") do del "%%d" >nul 2>&1
	
	"%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0POPS-Binaries\Hugopocked_POPStarter_Fixes.zip" -o"%~dp0TMP" !gameid!\* -r -y >nul 2>&1
	if not exist "%~dp0TMP\!gameid!\*.BIN" (
	"%~dp0BAT\busybox" md5sum "!filename!" | "%~dp0BAT\busybox" grep -o "[0-9a-z]\{32\}" > "%~dp0TMP\MD5.txt" & set /p MD5=<"%~dp0TMP\MD5.txt"
	"%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0POPS-Binaries\Hugopocked_POPStarter_Fixes.zip" -o"%~dp0TMP" !gameid!\!MD5!\* -r -y & move "%~dp0TMP\!gameid!\!MD5!\*" "%~dp0TMP\!gameid!" >nul 2>&1
	  )
	  cd /d "%~dp0TMP\!gameid!" & for %%x in (*) do move "%%x" "!HDDPATH!\POPS\!fname!" >nul 2>&1
	)
 endlocal
endlocal
  )
) else (echo\ & echo\ & echo HugoPocked's patches NOT Detected^!)

cd /d "%~dp0" & rmdir /s /q "%~dp0TMP" >nul 2>&1

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo Completed...
echo\
echo\
"%~dp0BAT\Diagbox" gd 07

pause & (goto POPSManagement)
REM ####################################################################################################################
:RenameVCDDB
if not defined fromVCDconv cls
mkdir "%~dp0TMP" >nul 2>&1
cd /d "%~dp0POPS"

echo\ 
echo\
"%~dp0BAT\Diagbox" gd 0e
echo Do you want rename your .VCDs from database^?
"%~dp0BAT\Diagbox" gd 0f
choice /c YN /m "Use titles from database?"
echo\
if errorlevel 2 if defined fromVCDconv (goto ConversionMenu) else (goto POPSManagement)

if defined HDDPATHOUTPUT set HDDPATH=!HDDPATHOUTPUT!
if not defined HDDPATH (
  "%~dp0BAT\Diagbox" gd 0e
  echo Do you want to change the default directory^?
  "%~dp0BAT\Diagbox" gd 07
  echo ^(Useful if your games are on another hard drive or path^)
  CHOICE /C YN
  echo\
  if !errorlevel!==1 (
  echo Example: E:\POPS
  set /p "HDDPATH=Enter the path where yours VCD Games located:"
  if "!HDDPATH!"=="" set "HDDPATH=%~dp0POPS"
  echo\
  ) else (set HDDPATH=%~dp0POPS)
)

"%~dp0BAT\busybox" iconv -t ascii//TRANSLIT//IGNORE "%~dp0BAT\TitlesDB\TitlesDB_PS1_English.txt" > "%~dp0TMP\TitlesDB_PS1_English.txt"
"%~dp0BAT\busybox" sed -i "2,$s/ :/:/g; 2,$s/:/ -/g; 2,$s/\//-/g; 2,$s/?//g; 2,$s/*//g" "%~dp0TMP\TitlesDB_PS1_English.txt"

"%~dp0BAT\Diagbox" gd 0e
echo Do you want to use a gameid prefix^?
"%~dp0BAT\Diagbox" gd 0f
echo With prefix:    [SCES_009.84.Gran Turismo.VCD]
echo Without prefix: [Gran Turismo.VCD]
choice /c YN /m "Use Prefix ?"
echo\
if errorlevel 1 set prefixgameid=yes
if errorlevel 2 set prefixgameid=

"%~dp0BAT\Diagbox" gd 0e
echo Do you want to truncate yours games titles to 47 characters max^?
"%~dp0BAT\Diagbox" gd 06
echo ^(Recommended Only if you plan to launch your games from OPL^)
"%~dp0BAT\Diagbox" gd 0f
choice /c YN /m "Truncate ?"
echo\
if errorlevel 1 set Truncate=yes
if errorlevel 2 set Truncate=
"%~dp0BAT\Diagbox" gd 0f

echo ---------------------------------------------------
IF /I EXIST "!HDDPATH!\*.VCD" (

cd /d "!HDDPATH!" & dir /b /a-d| "%~dp0BAT\busybox" grep -ie ".*\.VCD$" > "%~dp0TMP\GameslistTMP.txt"
set /a gamecount=0
for /f "usebackq delims=" %%f in ("%~dp0TMP\GameslistTMP.txt") do (
set /a gamecount+=1
	
	setlocal DisableDelayedExpansion
	set filename=%%f
	set fname=%%~nf
	set "gameid="
	set "dbtitle="
	setlocal EnableDelayedExpansion
    
	echo\
	echo !gamecount! - !filename!
	
	REM Avoid some gameid probleme
	"%~dp0BAT\UPSX_SID" "!filename!" -1 > "%~dp0TMP\gameid.txt" & set /p gameid=<"%~dp0TMP\gameid.txt"
	 if "!gameid!"=="907127.001" set gameid=LSP90712.700
	
     for /f "tokens=1*" %%A in ( 'findstr !gameid! "%~dp0TMP\TitlesDB_PS1_English.txt"' ) do if not defined dbtitle set dbtitle=%%B
	 
	 REM Fix Conflict Games. Rare games that have the same ID
	 findstr !gameid! "%~dp0BAT\Fix_Conflict_Gameid_Title.bat" >nul 2>&1
     if errorlevel 1 (echo >NUL) else (set "FixGameInstall=PS1" & call "%~dp0BAT\Fix_Conflict_Gameid_Title.bat")
	
	 REM Avoid some probleme with title
	 if !MD5!==f83e1fe73253a860301c5b67f7e67c48 set "dbtitle=Breath of Fire IV - Utsurowazaru Mono" & set gameid=SLPS_027.28
     if !MD5!==e727685a14959bc599e290befa511351 set "dbtitle=Breath of Fire IV (E3 Demo)" & set gameid=SLPS_027.28
     if !MD5!==e84810d0f4db6e6658ee4208eb9f5415 set "dbtitle=Bust A Move (Disc 1) (Genteiban)" & set gameid=SLPS_012.32
     if !MD5!==29c642b78b68cfff9a47fac51dd6d3c2 set "dbtitle=1Xtreme" & set gameid=SCUS_945.03
     if !MD5!==c9395ccb9bb59e9cea9170bf44bd5578 set "dbtitle=ESPN Extreme Games" & set gameid=SCUS_945.03
     if !MD5!==ee9fc1cd31d1e2adf6230ffb8db64e0e set "dbtitle=Jet Moto 2 - Championship Edition" & set gameid=SCUS_941.67
	 if !MD5!==8c0cce8b5742deddf7092c5a13152170 set "dbtitle=Kagayaku Kisetsu e" & set gameid=SLPS_019.72
	 if !MD5!==497273e71e0dcc7da728fe46bb920386 set "dbtitle=Kasei Monogatari (Genteiban)" & set gameid=SLPS_016.30
	 if !MD5!==29a392aae9b274e11198af10fead4709 set "dbtitle=Momotarou Dentetsu V" & set gameid=SLPS_024.56
	 if !MD5!==58060b99f160b4f992550cce44541faf set "dbtitle=Momotarou Dentetsu V (Shokai Genteiban)" & set gameid=SLPS_024.56
	 if !MD5!==6c88d7b7f085257caba543c99cc37d1c set "dbtitle=Metal Gear Solid (Disc 1) (Demo)" & set gameid=SLUS_005.94
	 if !MD5!==af1ab5022b2cad063b692953cc4cfebf set "dbtitle=NBA ShootOut 2001 (Demo)" & set gameid=SCUS_945.81
	 if !MD5!==3dace84a20e9ff6cd03644e6146bdbef set "dbtitle=Namco Museum Encore" & set gameid=SLPS_007.65
	 if !MD5!==ed216e8f219c0bebb9dc1b860eb8f880 set "dbtitle=Namco Museum Encore (Shokai Gentei)" & set gameid=SLPS_007.65
	 if !MD5!==b5175999b9fb7b2202e2e7b970efd5dd set "dbtitle=Naniwa Wangan Battle - Tarzan Yamada & AutoSelect Sawa Kyoudai (Taikenban)" & set gameid=SLPS_012.06
	 if !MD5!==1ed0d19fbd5471947d445d276f34bf0c set "dbtitle=Oddworld - Abe's Oddysee (Trade Demo)" & set gameid=SLUS_001.90
     if !MD5!==5b84b0ea98bd78f20c42d84dfde10fe8 set "dbtitle=SD Gundam - GGeneration-F (Disc 1) (Tokubetsu-ban)" & set gameid=SLPS_029.00
     if !MD5!==2d67bee7fc9ec69f73f43bbc9c778b4a set "dbtitle=SD Gundam - GGeneration-F (Disc 2) (Tokubetsu-ban)" & set gameid=SLPS_029.01
     if !MD5!==4858a5769c656b3d5de1ec486a194faa set "dbtitle=SD Gundam - GGeneration-F (Disc 3) (Tokubetsu-ban)" & set gameid=SLPS_029.02
     if !MD5!==98b11d483d537c9b441efc440d40534c set "dbtitle=SD Gundam - GGeneration-F (Disc 4) (Tokubetsu-ban)" & set gameid=SLPS_029.03
	 if !MD5!==deaabe0baa857ad7fda000cf4535087f set "dbtitle=Sangoku Musou (Taikenban)" & set gameid=SLPS_007.31
	 if !MD5!==ec51a74b08aee3f8e3656833f8e71cb8 set "dbtitle=Soukou Kihei Votoms - Koutetsu no Gunzei (Shokai Seisan Genteiban)" & set gameid=SLPS_023.15
	 if !MD5!==a86a49cd948c4f9c5063fbc360459764 set "dbtitle=PlayStation Underground Number 1 (Disc 2)" & set gameid=SCUS_941.61
     if !MD5!==31f7e4d4fd01718e0602cf2d795ca797 set "dbtitle=The Lost World - Jurassic Park - Special Edition" & set gameid=SLUS_005.15

	 if not defined dbtitle set dbtitle=!fname!
	 if defined prefixgameid set dbtitle=!gameid!.!dbtitle!
	 
	 REM Truncate filename for OPL to 45 chars max
	 if defined Truncate (
	 if "!dbtitle!"=="!gameid!.!dbtitle!" set dbtitle=!dbtitle~0,44!
	 if "!dbtitle!"=="!dbtitle!" set dbtitle=!dbtitle:~0,44!
	 if "!dbtitle:~-1!"==" " set dbtitle=!dbtitle:~0,-1!
	 )
	 
	 echo Title:  [!dbtitle!]
	 echo Gameid: [!gameid!]
	 
	 if exist "!dbtitle!.VCD" (
     "%~dp0BAT\Diagbox" gd 06
     echo Has the same name as another: will not be renamed
     "%~dp0BAT\Diagbox" gd 07
	 ) else (
	 ren "!filename!" "!dbtitle!.VCD" >nul 2>&1
	 ren "!fname!" "!dbtitle!" >nul 2>&1
     )
	 
	 echo ---------------------------------------------------
 endlocal	
endlocal
)
 
) else ( 
"%~dp0BAT\Diagbox" gd 06
cls
echo.
echo .VCD NOT DETECTED: Please drop .VCD IN POPS FOLDER.
echo.
"%~dp0BAT\Diagbox" gd 0f
)

cd /d "%~dp0" & rmdir /s /q "%~dp0TMP" >nul 2>&1

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo Completed...
echo\
echo\
"%~dp0BAT\Diagbox" gd 07

pause & if defined fromVCDconv (goto ConversionMenu) else (goto POPSManagement)
REM ####################################################################################################################################################
:ConvertTools
cls
mkdir "%~dp0TMP" >nul 2>&1
cd /d "%~dp0TMP"

if !Convert!==ISO2ZSO (
"%~dp0BAT\Diagbox" gd 0f
echo\
echo 1. Compress ISO TO ZSO
echo 2. Decompress ZSO TO ISO
echo 3. Back
echo\
CHOICE /C 123 /M "Select Option:"
if !errorlevel!==1 set "Compress=Yes" & set "type=.iso" & set "type2=.zso"
if !errorlevel!==2 set "Decompress=Yes" & set "type=.zso" & set "type2=.iso"
if !errorlevel!==3 (goto ConversionMenu)

if !type2!==.zso (
echo\
echo 1. Normal Compression
echo 2. Max Compression LZ4 HC
echo\
CHOICE /C 12 /M "Select Option:"
if !errorlevel!==1 set "LZ4HC="
if !errorlevel!==2 set "LZ4HC=--lz4hc"
	)
)

echo\
"%~dp0BAT\Diagbox" gd 0e
echo Do you want to change the default directory^?
"%~dp0BAT\Diagbox" gd 07
echo ^(Useful if your games are on another hard drive or path^)
CHOICE /C YN
echo\
if !errorlevel!==1 (
echo Example: E:\
set /p "HDDPATH=Enter the path where yours Games located:"
) else (
	if !GameType!==PS1 set HDDPATH=%~dp0POPS
	
	if !GameType!==PS2 (
	if !Convert!==BIN2ISO set HDDPATH=%~dp0CD
	if !Convert!==ISO2ZSO set HDDPATH=%~dp0DVD
	)
)

echo\
"%~dp0BAT\Diagbox" gd 0e
echo Do you want to change the default output directory^?
"%~dp0BAT\Diagbox" gd 07
echo Output files will be in the same folder where the files are located
CHOICE /C YN
echo\
if !errorlevel!==1 (
set CustomPath=Y
echo Example: E:\
set /p "HDDPATHOUTPUT=Enter the path:"
if "!HDDPATHOUTPUT!"=="" set "CustomPath="
) else (
	if !GameType!==PS1 set HDDPATHOUTPUT=%~dp0POPS
	
	if !GameType!==PS2 (
	if !Convert!==BIN2ISO set HDDPATHOUTPUT=%~dp0CD
	if !Convert!==ISO2ZSO set HDDPATHOUTPUT=%~dp0DVD
	)
)
if not defined CustomPath set HDDPATHOUTPUT=!HDDPATH!

echo\
"%~dp0BAT\Diagbox" gd 0e
echo Do you want to keep original files after converting^?
"%~dp0BAT\Diagbox" gd 07
echo ^(Files compressed zip, 7z, rar, will not be affected^)
CHOICE /C YN
if !errorlevel!==1 set keepOriginal=yes
if !errorlevel!==2 set keepOriginal=no


if !Convert!==BIN2VCD (
if exist "%~dp0POPS-Binaries\Hugopocked_POPStarter_Fixes.zip" (
echo ----------------------------------------------------
echo\
"%~dp0BAT\Diagbox" gd 0e
echo Apply HugoPocked's patches If available^?
"%~dp0BAT\Diagbox" gd 07
echo Patches are intended to fix games that don't work with POPStarter [Yes recommended]
CHOICE /C YN /M "Select Option:"
if !errorlevel!==1 set "patchVCD=yes" & "%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0POPS-Binaries\Hugopocked_POPStarter_Fixes.zip" -o"%~dp0TMP" id.txt -r -y
if !errorlevel!==2 set "patchVCD=no"

	if !patchVCD!==yes (
    echo\
	echo\
    echo What device will you be using^?
	echo 1 = HDD ^(Internal^)
	echo 2 = USB
    CHOICE /C 12 /M "Select Option:"
    if errorlevel 1 set device=HDD
    if errorlevel 2 set device=USB
		)
	)
)

dir /b /a-d "!HDDPATH!" 2>&1 | "%~dp0BAT\busybox" grep -ie ".*\.iso$" -ie ".*\.cue$" -ie ".*\.VCD$" -ie ".*\.zso$" -ie ".*\.zip$" -ie ".*\.7z$" -ie ".*\.rar$" > "%~dp0TMP\GameslistTMP.txt"
if defined Convert (
"%~dp0BAT\busybox" sed -i "/\.VCD$/d" "%~dp0TMP\GameslistTMP.txt"
if !Convert!==ISO2ZSO "%~dp0BAT\busybox" sed -i "/\!type2!$/d" "%~dp0TMP\GameslistTMP.txt"
) else (
"%~dp0BAT\busybox" sed -i "/\.cue$/d; /\.zip$/d; /\.7z$/d; /\.rar$/d;" "%~dp0TMP\GameslistTMP.txt"
)

for %%F in (GameslistTMP.txt) do if %%~zF==0 del "%%F"

if exist "%~dp0TMP\GameslistTMP.txt" (
set /a gamecount=0
for /f "usebackq delims=" %%f in ("%~dp0TMP\GameslistTMP.txt") do (
set /a gamecount+=1

	setlocal DisableDelayedExpansion
	set filename=%%f
	set filenameOriginal=%%f
	set fname=%%~nf
	setlocal EnableDelayedExpansion
	
	if "!filename!"=="!fname!.zip" set compressed=zip
	if "!filename!"=="!fname!.ZIP" set compressed=ZIP
	if "!filename!"=="!fname!.7z" set compressed=7z
	if "!filename!"=="!fname!.7Z" set compressed=7Z
	if "!filename!"=="!fname!.rar" set compressed=rar
	if "!filename!"=="!fname!.RAR" set compressed=RAR
	
    echo\
	echo\
	echo !gamecount! - !filename!

	if "!filename!"=="!fname!.!compressed!" (
	"%~dp0BAT\7-Zip\7z" x -bso0 "!HDDPATH!\!fname!.!compressed!" -o"!HDDPATH!\Temp\!fname!" -r -y
	dir /b /a-d "!HDDPATH!\Temp\!fname!" | "%~dp0BAT\busybox" grep -ie ".*\.cue$" > "%~dp0TMP\GamesUnzip.txt" & set /P filename=<"%~dp0TMP\GamesUnzip.txt" 
    dir /b /a-d "!HDDPATH!\Temp\!fname!" | "%~dp0BAT\busybox" grep -ie ".*\.cue$" | "%~dp0BAT\busybox" sed -e "s/\.[^.]*$//" > "%~dp0TMP\GamesUnzip.txt" & set /P fname=<"%~dp0TMP\GamesUnzip.txt"
	dir /b /a-d "!HDDPATH!\Temp\!fname!" | "%~dp0BAT\busybox" grep -ie ".*\.cue$" | "%~dp0BAT\busybox" sed -e "s/.*\.//g" > "%~dp0TMP\GamesUnzip.txt"  & set /P ext=<"%~dp0TMP\GamesUnzip.txt"
	set DelExtracted=yes
	)
	
	REM Create Temp Folder
	md "!HDDPATH!\Temp\!fname!" >nul 2>&1
	if !keepOriginal!==yes md "!HDDPATH!\Original\!fname!" >nul 2>&1
	move "!HDDPATH!\!fname!.bin" "!HDDPATH!\Temp\!fname!" >nul 2>&1 & move "!HDDPATH!\!fname! (Track *).bin" "!HDDPATH!\Temp\!fname!" >nul 2>&1 & move "!HDDPATH!\!fname!.cue" "!HDDPATH!\Temp\!fname!" >nul 2>&1
	
	REM Merge Multi-Tracks
	if not defined UnConvert (
	"%~dp0BAT\binmerge" !split! "!HDDPATH!\Temp\!fname!\!filename!" "!fname!" -o "!HDDPATHOUTPUT!" | findstr "Merging ERROR"
	
		if not exist "!HDDPATHOUTPUT!\!fname!.cue" (
		move "!HDDPATH!\Temp\!fname!\*" "!HDDPATH!" >nul 2>&1
		set "Convert="
		) else (
		if defined split md "!HDDPATHOUTPUT!\!fname!" >nul 2>&1 & move "!HDDPATHOUTPUT!\!fname!.bin" "!HDDPATHOUTPUT!\!fname!" >nul 2>&1 & move "!HDDPATHOUTPUT!\!fname! (Track *).bin" "!HDDPATHOUTPUT!\!fname!" >nul 2>&1 & move "!HDDPATHOUTPUT!\!fname!.cue" "!HDDPATHOUTPUT!\!fname!" >nul 2>&1
		)
		if !keepOriginal!==yes (move "!HDDPATH!\Temp\!fname!\*" "!HDDPATH!\Original\!fname!" >nul 2>&1)
	)
	
	if !Convert!==BIN2VCD (
		echo Convert to VCD... 

				if !patchVCD!==yes (
				
				"%~dp0BAT\UPSX_SID" "!HDDPATHOUTPUT!\!fname!.bin" -1 > "%~dp0TMP\BINID.txt" & set /p BINID=<"%~dp0TMP\BINID.txt"
				findstr !BINID! "%~dp0TMP\id.txt" >nul 2>&1
				if errorlevel 1 (
				echo No patch available for this game >nul
				) else (
				
				"%~dp0BAT\busybox" md5sum "!HDDPATHOUTPUT!\!fname!.bin" | "%~dp0BAT\busybox" grep -o "[0-9a-z]\{32\}" > "%~dp0TMP\MD5.txt" & set /p MD5=<"%~dp0TMP\MD5.txt"
				"%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0POPS-Binaries\Hugopocked_POPStarter_Fixes.zip" -o"%~dp0TMP" "!BINID!\!MD5!\*" -r -y & move "%~dp0TMP\!BINID!\!MD5!\*.xdelta" "%~dp0TMP\!BINID!\!MD5!\Patch.xdelta" >nul 2>&1
				
				if exist "%~dp0TMP\!BINID!\!MD5!\Patch.xdelta" (
				echo Applying the patch.. 
				"%~dp0BAT\xdelta3-3.1.0-x86_64" -d -s "!HDDPATHOUTPUT!\!fname!.bin" "%~dp0TMP\!BINID!\!MD5!\Patch.xdelta" "!HDDPATHOUTPUT!\!fname!.PATCHED"

				if exist "!HDDPATHOUTPUT!\!fname!.PATCHED" (
				"%~dp0BAT\Diagbox" gd 0a
				echo Done
				del "!HDDPATHOUTPUT!\!fname!.bin" >nul 2>&1 & move "!HDDPATHOUTPUT!\!fname!.PATCHED" "!HDDPATHOUTPUT!\!fname!.bin" >nul 2>&1
				"%~dp0BAT\Diagbox" gd 0f
				) else (
				"%~dp0BAT\Diagbox" gd 0c
				echo An error has occurred
				"%~dp0BAT\Diagbox" gd 0f
								)
							)
						)
					)

				REM Convert to VCD
				"%~dp0BAT\CUE2POPS_2_3" "!HDDPATHOUTPUT!\!filename!" >nul 2>&1
				move "!HDDPATH!\!fname!.VCD" "!HDDPATHOUTPUT!" >nul 2>&1
				
				if !device!==USB (
				md "!HDDPATHOUTPUT!\!fname!"
				"%~dp0BAT\UPSX_SID" "!HDDPATHOUTPUT!\!fname!.VCD" -1 > "%~dp0TMP\gameid.txt" & set /p gameid=<"%~dp0TMP\gameid.txt"
				
				REM echo         Checking if the game has a need patch GameShark...
				findstr !gameid! "%~dp0TMP\id.txt" >nul 2>&1
				if errorlevel 1 (
				REM echo         No need patch
				) else (
				REM echo         Patch GameShark...
				"%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0POPS-Binaries\Hugopocked_POPStarter_Fixes.zip" -o"%~dp0TMP" !gameid!\* -r -y >nul 2>&1
				if not exist "%~dp0TMP\!gameid!\*.BIN" (
				"%~dp0BAT\busybox" md5sum "!HDDPATHOUTPUT!\!fname!.VCD" | "%~dp0BAT\busybox" grep -o "[0-9a-z]\{32\}" > "%~dp0TMP\MD5.txt" & set /p MD5=<"%~dp0TMP\MD5.txt"
				"%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0POPS-Binaries\Hugopocked_POPStarter_Fixes.zip" -o"%~dp0TMP" !gameid!\!MD5!\* -r -y & move "%~dp0TMP\!gameid!\!MD5!\*" "%~dp0TMP\!gameid!" >nul 2>&1
							)
				cd /d "%~dp0TMP\!gameid!" & for %%x in (TROJAN_?.BIN PATCH_?.BIN CHEATS.TXT Readme.txt) do move "%%x" "!HDDPATHOUTPUT!\!fname!" >nul 2>&1
						)
					)
				if !keepOriginal!==yes (move "!HDDPATH!\Temp\!fname!\*" "!HDDPATH!\Original\!fname!" >nul 2>&1 & del "!HDDPATHOUTPUT!\!fname!.bin" >nul 2>&1 & del "!HDDPATHOUTPUT!\!fname!.cue" >nul 2>&1) else (del "!HDDPATHOUTPUT!\!fname!.bin" >nul 2>&1 & del "!HDDPATHOUTPUT!\!fname!.cue" >nul 2>&1)
				if !DelExtracted!==yes del "!HDDPATHOUTPUT!\!fname!.bin" >nul 2>&1 & del "!HDDPATHOUTPUT!\!fname!.cue" >nul 2>&1
				)
	
	if !UnConvert!==VCD2BIN (
		"%~dp0BAT\POPS2CUE" "!HDDPATH!\!filename!" | findstr "Done Error"
			move "!HDDPATH!\!fname!.bin" "!HDDPATHOUTPUT!" >nul 2>&1 & move "!HDDPATH!\!fname!.cue" "!HDDPATHOUTPUT!" >nul 2>&1
				if !keepOriginal!==yes (move "!HDDPATH!\!filename!" "!HDDPATH!\Original\!fname!" >nul 2>&1) else (del "!HDDPATHOUTPUT!\!fname!.VCD" >nul 2>&1)
				)
				
	if !Convert!==BIN2ISO (
		"%~dp0BAT\bchunk" "!HDDPATHOUTPUT!\!fname!.bin" "!HDDPATHOUTPUT!\!fname!.cue" "!HDDPATHOUTPUT!\!fname!" >nul 2>&1
			move "!HDDPATHOUTPUT!\!fname!01.iso" "!HDDPATHOUTPUT!\!fname!.iso" >nul 2>&1
				if !keepOriginal!==yes (move "!HDDPATH!\Temp\!fname!\*" "!HDDPATH!\Original\!fname!" >nul 2>&1) else (del "!HDDPATHOUTPUT!\!fname!.bin" >nul 2>&1 & del "!HDDPATHOUTPUT!\!fname!.cue" >nul 2>&1)
					del "!HDDPATHOUTPUT!\!fname!.bin" >nul 2>&1 & del "!HDDPATHOUTPUT!\!fname!.cue" >nul 2>&1
					)
					
	if !Convert!==ISO2ZSO (
	"%~dp0BAT\hdl_dump" cdvd_info2 "!HDDPATH!\!filename!" > "%~dp0TMP\cdvd_info.txt"
	
	"%~dp0BAT\ziso" --cache-size 4 --replace !LZ4HC! --hdl-fix -i "!HDDPATH!\!fname!!type!" -o "!HDDPATHOUTPUT!\!fname!!type2!"
		if !keepOriginal!==yes (move "!HDDPATH!\!fname!!type!" "!HDDPATH!\Original\!fname!" >nul 2>&1) else (del "!HDDPATHOUTPUT!\!fname!!type!" >nul 2>&1)
		)

	rmdir /s /q "!HDDPATH!\Temp\!fname!" >nul 2>&1
	
	endlocal
endlocal
)
rmdir /s /q "!HDDPATH!\Temp" >nul 2>&1

REM cd /d "%~dp0" & rmdir /s /q "%~dp0POPS\Temp" >nul 2>&1

if !Convert!==BIN2VCD (set "fromVCDconv=Yes" & goto RenameVCDDB) else (echo\ & echo\ & pause & goto ConversionMenu)
) else (
cls
echo\
echo\
for %%I in ("!HDDPATH!") do set "HDDPATH=%%~nxI"
"%~dp0BAT\Diagbox" gd 06
echo No file found^^! Please drop your file in "!HDDPATH!\"
"%~dp0BAT\Diagbox" gd 07
echo\
echo\
pause & goto ConversionMenu)
REM ####################################################################################################################################################
:PS2HDD2WinExplorer
cls
mkdir "%~dp0TMP" >nul 2>&1
mkdir "%~dp0LOG" >nul 2>&1
cd /d "%~dp0TMP"

if not exist "%HOMEDRIVE%\Windows\System32\drivers\dokan2.sys" goto DokanDriverError

REM Check Dokan Version
if defined CheckDokanVersion ( cls & if exist "C:\Program Files\Dokan\" "C:\Program Files\Dokan\!DokanFolder!\dokanctl.exe" /v) & echo\ & echo\ & pause & (goto PS2HDDExplore)

IF NOT DEFINED @hdl_path ( rmdir /Q/S "%~dp0TMP" >nul 2>&1 & goto ScanningPS2HDD ) else (
"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning for Playstation 2 HDDs:
echo ---------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "!@hdl_path!" | "%~dp0BAT\busybox" grep "Playstation 2 HDD" >nul
if errorlevel 1 set "@hdl_path=" & goto ScanningPS2HDD
echo       [!@hdl_path! !@TotalHDD_Size! - !@ModelePS2HDD!]
)

   "%~dp0BAT\Diagbox" gd 0f
   echo\
   echo\
   echo Scanning Partitions:
   echo ---------------------------------------------------
   "%~dp0BAT\busybox" grep -e "0x0100" -e "0x0001" "%~dp0BAT\__Cache\PARTITION_PS2HDD.txt"
   echo ---------------------------------------------------
   :DokanMountIMG
   if !mount!==IMG (
   echo\
   echo\
   echo Enter the path where your image.img is located
   echo Example c:\PS2\Myimage.img
   set /p @pfsshell_path=Enter the FullPath:
   )
   echo\
   echo\
   echo Enter the partition name do you want mount
   set /p PartName=Partition name:
   if "!PartName!"=="" goto PS2HDDExplore
   echo\
   echo\
   
   if !mount!==HDD (
    "%~dp0BAT\busybox" grep -ow "!PartName!" "%~dp0BAT\__Cache\PARTITION_PS2HDD.txt" > "%~dp0TMP\PPSelected.txt" & set /P PPSELECTED=<"%~dp0TMP\PPSelected.txt"
	if "!PPSELECTED!"=="!PartName!" (
	echo >nul
	) else (
	"%~dp0BAT\Diagbox" gd 0c
	echo             Partition NOT Detected
	echo      Please verify that you have not made any mistakes.
	echo\
	echo\
	"%~dp0BAT\Diagbox" gd 07
	rmdir /Q/S "%~dp0TMP" >nul 2>&1
	pause & (goto PS2HDDExplore)
	)
   )
   
   if !mount!==IMG echo If after a minute nothing appears, close batch and check that you have not made an error in the paths
   REM Assign Drive Letter
   powershell -Command "Get-Volume | Select-Object -ExpandProperty DriveLetter" | "%~dp0BAT\busybox" grep -o "[A-Z]" > "%~dp0TMP\LTR.txt"
   "C:\Program Files\Dokan\!DokanFolder!\dokanctl.exe" /l a >nul 2>&1 | "%~dp0BAT\busybox" grep -o "DosDevices\\[A-Z]" | "%~dp0BAT\busybox" cut -c12-12 >> "%~dp0TMP\LTR.txt"
   
   echo ABCDEFGHIJKLMNOPQRSTUVWXYZ> "%~dp0TMP\LTRFree.txt"
   for /f "usebackq tokens=*" %%a in ("%~dp0TMP\LTR.txt") do "%~dp0BAT\busybox" sed -i "s/%%a//g; s/A//g; s/B//g" "%~dp0TMP\LTRFree.txt"
   "%~dp0BAT\busybox" cut -c0-1 "%~dp0TMP\LTRFree.txt" > "%~dp0TMP\LTRSelected.txt" & set /P DeviceLTR=<"%~dp0TMP\LTRSelected.txt"
   
   START /MIN CMD.EXE /C ""%~dp0BAT\pfsfuse" "--partition=!PartName!" !@pfsshell_path! !DeviceLTR! -o "volname=!PartName!""
   
   :loopdrive
   powershell -Command "Get-WmiObject -Class Win32_LogicalDisk | Where-Object { $_.DeviceID } | ForEach-Object { $_.DeviceID }" | "%~dp0BAT\busybox" grep -o "!DeviceLTR!:"> "%~dp0TMP\WINDOWLTR.TXT" & set /P WINDOWLTR=<"%~dp0TMP\WINDOWLTR.txt"
   if "!WINDOWLTR!"=="!DeviceLTR!:" start !DeviceLTR!:\ & goto exitloopdrive
   goto loopdrive
   :exitloopdrive
   
   "%~dp0BAT\Diagbox" gd 0e
   echo Umount Partition^?
   choice /c YN

   if !errorlevel!==1 (
   goto DokanUmountDoManuallyPartition
   ) else (
   "%~dp0BAT\Diagbox" gd 06
   echo\
   echo IMPORTANT: Don't forget to umount partition before disconnecting your HDD
   echo\
   "%~dp0BAT\Diagbox" gd 0f
   pause & goto PS2HDDExplore
   )

:DokanUmountDoManuallyPartition

   if exist "C:\Program Files\Dokan" (
   if defined PartName (
   "%~dp0BAT\Diagbox" gd 0f
   echo\
   "C:\Program Files\Dokan\!DokanFolder!\dokanctl.exe" /u !DeviceLTR! | "%~dp0BAT\busybox" grep -o "Unmount status = 0" > "%~dp0TMP\UnmountPart.txt" & set /P UnmountPart=<"%~dp0TMP\UnmountPart.txt"
   ) else (
   "C:\Program Files\Dokan\!DokanFolder!\dokanctl.exe" /l a | "%~dp0BAT\busybox" grep -o "DosDevices\\[A-Z]:" | "%~dp0BAT\busybox" cut -c12-12 > "%~dp0TMP\Listmount.txt"
   for /f "usebackq tokens=*" %%m in ("%~dp0TMP\Listmount.txt") do (
   echo\ & "C:\Program Files\Dokan\!DokanFolder!\dokanctl.exe" /u %%m | "%~dp0BAT\busybox" grep -o "Unmount status = 0" > "%~dp0TMP\UnmountPart.txt" & set /P UnmountPart=<"%~dp0TMP\UnmountPart.txt"
   "%~dp0BAT\Diagbox" gd 0f
		)
	)
	if "!UnmountPart!"=="Unmount status = 0" echo Unmount success
	
	REM Check if conf_hdd.cfg was changed while mounting __common partition
	if "!PartName!"=="__common" (
	echo device !@pfsshell_path! > "%~dp0TMP\PFS-OPLPART.txt"
	echo mount __common >> "%~dp0TMP\PFS-OPLPART.txt"
	echo cd OPL >> "%~dp0TMP\PFS-OPLPART.txt"
	echo get conf_hdd.cfg >> "%~dp0TMP\PFS-OPLPART.txt"
	echo umount >> "%~dp0TMP\PFS-OPLPART.txt"
	echo exit >> "%~dp0TMP\PFS-OPLPART.txt"
	type "%~dp0TMP\PFS-OPLPART.txt" | "%~dp0BAT\pfsshell" >nul 2>&1
	
	if not exist "%~dp0TMP\conf_hdd.cfg" (set OPLPART=__common) else ("%~dp0BAT\busybox" grep "hdd_partition=" "%~dp0TMP\conf_hdd.cfg" | "%~dp0BAT\busybox" sed "s/^.*=//" > "%~dp0TMP\OPLPART.txt" & set /P OPLPART=<"%~dp0TMP\OPLPART.txt")
	echo hdd_partition=!OPLPART!> "%~dp0HDD-OSD\__common\OPL\conf_hdd.cfg"
	if !OPLPART!==+OPL (set "CUSTOM_OPLPART=") else (set "CUSTOM_OPLPART=Yes")
	
	if !OPLPART!==+OPL (
		"%~dp0BAT\busybox" sed -i "/^set OPLPART=/s/.*/set OPLPART=!OPLPART!/g; /^set CUSTOM_OPLPART=/s/.*/set CUSTOM_OPLPART=/g" "%~dp0\BAT\__Cache\HDD.BAT"
		) else (
		"%~dp0BAT\busybox" sed -i "/^set OPLPART=/s/.*/set OPLPART=!OPLPART!/g; /^set CUSTOM_OPLPART=/s/.*/set CUSTOM_OPLPART=Yes/g" "%~dp0\BAT\__Cache\HDD.BAT"
		)
	)
	
) else (goto InstallDokanDriver)

echo\
echo\
pause & (goto PS2HDDExplore)
REM #########################################################################################################
:InstallDokanDriver

   if defined InstallDokanDriver if exist "C:\Program Files\Dokan\!DokanFolder!\dokanctl.exe" (
   "%~dp0BAT\Diagbox" gd 06 
   echo\
   echo Dokan Driver is already installed if you want to update it. Uninstall the driver first
   echo Or install it manually by downloading it from https://github.com/dokan-dev/dokany/releases
   "%~dp0BAT\Diagbox" gd 0f
   echo\
   echo\
   pause & (goto PS2HDDExplore)
   )

   if !InstallDokanDriver!==yes (
   echo Installation...
   msiexec.exe /i "%~dp0BAT\Dokan_x64.msi" /QN /L*V "%~dp0LOG\DokanDriverlog.log"
   
   if exist "%HOMEDRIVE%\Windows\System32\drivers\dokan2.sys" (
   "%~dp0BAT\Diagbox" gd 0a
   echo Installation Successfully
   "%~dp0BAT\Diagbox" gd 06
   echo\
   echo You may need to restart your computer if you cannot mount partitions
   "%~dp0BAT\Diagbox" gd 0f
   ) else (
   "%~dp0BAT\Diagbox" gd 0c
   echo An error has occurred Please check logs.
   "%~dp0BAT\Diagbox" gd 0f
     )
   )
pause & (goto PS2HDDExplore)
REM ###################################################
:UninstallDokanDriver

if defined UninstallDokanDriver (
   cls
   echo Are you sure you want to uninstall Dokan drivers?
   choice /c YN
   if errorlevel 2 (goto PS2HDDExplore)
   
   echo\
   echo Uninstall...
   powershell -Command "Get-WmiObject -Class Win32_Product | Select-Object Name, IdentifyingNumber" | "%~dp0BAT\busybox" grep "Dokan Library" | "%~dp0BAT\busybox" grep -o "[A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9]-[A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9]-[A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9]-[A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9]-[A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9]" > "%~dp0TMP\DokanProgUID.txt"
   set /p DokanProgUID=<"%~dp0TMP\DokanProgUID.txt"
   msiexec.exe /x {!DokanProgUID!} /QN /norestart
   
   echo Reboot your computeur now for complete uninstall?
   echo\
   choice /c YN
   echo\
   if errorlevel 1 set rebootnow=yes
   if errorlevel 2 (goto PS2HDDExplore)

   if !rebootnow!==yes (shutdown.exe /r /t 03)
   )

cd "%~dp0" & rmdir /Q/S "%~dp0TMP" >nul 2>&1
echo\
echo\
pause & (goto PS2HDDExplore)
REM ###################################################
:DokanDriverError
"%~dp0BAT\Diagbox" gd 06
if not defined InstallDriver echo Dokan Driver not detected
"%~dp0BAT\Diagbox" gd 0f

echo\
echo Do you want Install Dokan Driver^?
"%~dp0BAT\Diagbox" gd 0f
CHOICE /C YN /M "Select Option:"
if !errorlevel!==1 set "InstallDokanDriver=yes" & goto InstallDokanDriver
if !errorlevel!==2 cd "%~dp0" & rmdir /Q/S "%~dp0TMP" >nul 2>&1 & (goto PS2HDDExplore)

cd "%~dp0" & rmdir /Q/S "%~dp0TMP" >nul 2>&1
echo\
echo\
pause & (goto PS2HDDExplore)
REM ###########################################################################################################################################################
:GDX-X
cls
echo\
echo\
echo\
echo\
echo\
ECHO   ,ad8888ba,  88888888ba, 8b        d8
ECHO  d8"'    `"8b 88      `"8b Y8,    ,8P 
ECHO d8'           88        `8b `8b  d8'  
ECHO 88            88         88   Y88P    
ECHO 88      88888 88         88   d88b    
ECHO Y8,        88 88         8P ,8P  Y8,  
ECHO  Y8a.    .a88 88      .a8P d8'    `8b 
ECHO   `"Y88888P"  88888888Y"' 8P        Y8  
echo\
echo\
echo\
echo\
echo\
pause & cls & (goto mainmenu)
REM ###########################################################################################################################################################
:poop
cls
echo\
echo @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@/@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
echo @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@////@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
echo @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@////////@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
echo @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@///////////@@@@@@@@@@@@@@@@@@@@@@@@@@@
echo @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@////////////////@@@@@@@@@@@@@@@@@@@@@@@@@
echo @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@//////////////////////@@@@@@@@@@@@@@@@@@@@@@@@
echo @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@///////////////////////////@@@@@@@@@@@@@@@@@@@@@@@
echo @@@@@@@@@@@@@@@@@@@@@@@@//////////////////////////////////@@@@@@@@@@@@@@@@@@@@@@
echo @@@@@@@@@@@@@@@@@@@@///////////////////////////////////////@@@@@@@@@@@@@@@@@@@@@
echo @@@@@@@@@@@@@@@@@//////////////////////////////////////////////@@@@@@@@@@@@@@@@@
echo @@@@@@@@@@@@@@@///////////////////////////////////////////////////@@@@@@@@@@@@@@
echo @@@@@@@@@@@@@///////////////////////////////////////////////////////@@@@@@@@@@@@
echo @@@@@@@@@@@@/////////////////////////////////////////////////////////@@@@@@@@@@@
echo @@@@@@@@@@@@//////////////////////////////////////////////////////////@@@@@@@@@@
echo @@@@@@@@@@@@//////////////////////////////////////////////////////////@@@@@@@@@@
echo @@@@@@@@@@@@//////////////////////////////////////////////////////////@@@@@@@@@@
echo @@@@@@@@@@@@@/////////////////////////////////////////////////////////@@@@@@@@@@
echo @@@@@@@@@@@////////////////////////FUCK-PS2-HOME/////////////////////@@@@@@@@@@@
echo @@@@@@@@/////////////////////////////////////////////////////////////////@@@@@@@
echo @@@@@@/////////////////////////////////////////////////////////////////////@@@@@
echo @@@@////////////////////////////////////////////////////////////////////////@@@@
echo @@@@/////////////////////////////////////////////////////////////////////////@@@
echo @@@///////////////////////////////////////////////////////////////////////////@@
echo @@@///////////////////////////////////////////////////////////////////////////@@
echo @@@@/////////////////////////////////////////////////////////////////////////@@@
echo @@@@/////////////////////////////////////////////////////////////////////////@@@
echo @@@@@///////////////////////////////////////////////////////////////////////@@@@
echo @@@@@@@///////////////////////////////////////////////////////////////////@@@@@@
echo @@@@@@@@@///////////////////////////////////////////////////////////////@@@@@@@@
echo @@@@@@@@@@@@/////////////////////////////////////////////////////////@@@@@@@@@@@
echo @@@@@@@@@@@@@@@@/////////////////////////////////////////////////@@@@@@@@@@@@@@@
echo @@@@@@@@@@@@@@@@@@@@@@/////////////////////////////////////@@@@@@@@@@@@@@@@@@@@@
pause & cls & (goto mainmenu)
REM ###########################################################################################################################################################
REM 
REM			     a8888b.
REM             d888888b.
REM             8P"YP"Y88
REM             8|o||o|88
REM             8'    .88
REM             8`._.' Y8.
REM            d/      `8b.
REM           dP   .    Y8b.
REM          d8:'  "  `::88b
REM         d8"         'Y88b
REM        :8P    '      :888
REM         8a.   :     _a88P
REM       ._/"Yaa_:   .| 88P|
REM       \    YP"    `| 8P  `.
REM       /     \.___.d|    .'
REM       `--..__)8888P`._.'
REM