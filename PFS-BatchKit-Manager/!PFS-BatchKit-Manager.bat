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
IF NOT EXIST "%~dp0HDD-OSD\PP.HEADER\res" MD "%~dp0HDD-OSD\PP.HEADER\PFS\res\image" >nul 2>&1

IF NOT EXIST "%~dp0BAT\__Cache" MD "%~dp0BAT\__Cache"
IF NOT EXIST "%~dp0TMP" MD "%~dp0TMP"

REM Move VCD If Batch Crash
IF EXIST "%~dp0POPS\Temp" for /r "%~dp0POPS\Temp" %%i in (*.VCD) do move "%%i" "%~dp0POPS" >nul 2>&1
cd /d "%~dp0POPS" & for %%x in (TROJAN_?.BIN PATCH_?.BIN CHEATS.TXT Readme.txt) do del "%%x" >nul 2>&1

if not defined GithubUPDATE (
echo Checking for updates...
cd /d "%~dp0TMP"
"%~dp0BAT\wget" -q "https://raw.githubusercontent.com/GDX-X/PFS-BatchKit-Manager/main/PFS-BatchKit-Manager/!PFS-BatchKit-Manager.bat" -O "%~dp0TMP\!PFS-BatchKit-Manager2.bat" >nul 2>&1
for %%F in ( "!PFS-BatchKit-Manager2.bat" ) do if %%~zF==0 del "%%F"

"%~dp0BAT\busybox" md5sum "%~dp0TMP\!PFS-BatchKit-Manager2.bat" 2>&1 | "%~dp0BAT\busybox" grep -o "[0-9a-f]\{32\}" > "%~dp0TMP\CheckUPDATE.txt" & set /p CheckUPDATE=<"%~dp0TMP\CheckUPDATE.txt"
"%~dp0BAT\busybox" md5sum "%~dp0!PFS-BatchKit-Manager.bat" 2>&1 | "%~dp0BAT\busybox" grep -o "[0-9a-f]\{32\}" > "%~dp0TMP\CheckOriginal.txt" & set /p CheckOriginal=<"%~dp0TMP\CheckOriginal.txt"
)
set "GithubUPDATE="
if exist "!PFS-BatchKit-Manager2.bat" if "%CheckUPDATE%"=="%CheckOriginal%" (set "update=") else (set update=UPDATE AVAILABLE)

setlocal EnableDelayedExpansion
setlocal EnableExtensions
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
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "Playstation 2 HDD" | "%~dp0BAT\busybox" sed -e "/^$/d" | "%~dp0BAT\busybox" wc -l > "%~dp0TMP\TotalPS2HDD.txt" & set /P @TotalPS2HDD=<"%~dp0TMP\TotalPS2HDD.txt"

if !@TotalPS2HDD! gtr 1 (
   "%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "Playstation 2 HDD" | "%~dp0BAT\busybox" grep -o "hdd[0-9]:\|hdd[0-9][0-9]:" | "%~dp0BAT\busybox" sed "s/hdd//g; s/://g" > "%~dp0TMP\hdl-hdd.txt" 
   
   wmic diskdrive get name,model | "%~dp0BAT\busybox" sed "s/[[:space:]]*$//" > "%~dp0TMP\hdd-type.txt"
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

        "%~dp0BAT\busybox" grep -ow "\\\\.\\\PHYSICALDRIVE!NumberPS2HDD!" "%~dp0TMP\hdd-typetmp.txt" | "%~dp0BAT\busybox" head -1 > "%~dp0TMP\SelectedPS2HDD.txt" & set /P SelectedPS2HDD=<"%~dp0TMP\SelectedPS2HDD.txt"
	    if "!SelectedPS2HDD!"=="\\.\PHYSICALDRIVE!NumberPS2HDD!" (
        "%~dp0BAT\Diagbox" gd 03
	    echo\
		REM echo         !SelectedPS2HDD! Selected
		echo hdd!NumberPS2HDD!:> "%~dp0TMP\hdl-hdd.txt"
	    "%~dp0BAT\Diagbox" gd 07
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
	
	) else (
    "%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "Playstation 2 HDD" | "%~dp0BAT\busybox" grep -o "hdd[0-9]:\|hdd[0-9][0-9]:" > "%~dp0TMP\hdl-hdd.txt"
	)
	
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
	 
	 echo !@hdl_path!| "%~dp0BAT\busybox" sed "s/hdd/\\\\.\\\PhysicalDrive/g; s/://g" > "%~dp0TMP\hdl-hdd2.txt" & set /P @pfsshell_path=<"%~dp0TMP\hdl-hdd2.txt"
	 echo !@hdl_path!| "%~dp0BAT\busybox" sed "s/hdd//g; s/://g" > "%~dp0TMP\NumberPS2HDD.txt" & set /P @NumberPS2HDD=<"%~dp0TMP\NumberPS2HDD.txt"
     wmic diskdrive get name,model | "%~dp0BAT\busybox" sed "s/[[:space:]]*$//" | "%~dp0BAT\busybox" grep -i "PhysicalDrive!@NumberPS2HDD!" | "%~dp0BAT\busybox" sed "s/\\\\.\\PHYSICALDRIVE!@NumberPS2HDD!//g; s/USB Device//g; s/[[:space:]]*$//g" > "%~dp0TMP\ModelePS2HDD.txt" & set /P @ModelePS2HDD=<"%~dp0TMP\ModelePS2HDD.txt"
     wmic diskdrive get model,status | "%~dp0BAT\busybox" sed "s/[[:space:]]*$//" | "%~dp0BAT\busybox" grep -i "!@ModelePS2HDD!" | "%~dp0BAT\busybox" sed "s/!@ModelePS2HDD!//g; s/USB Device//g; s/ //g" > "%~dp0TMP\StatusPS2HDD.txt" & set /P @StatusPS2HDD=<"%~dp0TMP\StatusPS2HDD.txt" & if not defined @StatusPS2HDD set @StatusPS2HDD=UNKNOWN
	 
     REM HDD Total Size
	 "%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "!@hdl_path!" > "%~dp0TMP\TotalHDD_Size.txt"
	 for /f "usebackq tokens=2" %%s in ("%~dp0TMP\TotalHDD_Size.txt") do set TotalHDD_Size=%%s
     if !TotalHDD_Size! GTR 10 set "HDDMB=MB" & echo !TotalHDD_Size!| "%~dp0BAT\busybox" sed -e "s/ //g" > "%~dp0TMP\TotalHDD_Size.txt" & set /P @TotalHDD_Size=<"%~dp0TMP\TotalHDD_Size.txt"
     if !TotalHDD_Size! GTR 100 set "HDDMB=MB" & echo !TotalHDD_Size!| "%~dp0BAT\busybox" sed -e "s/ //g" > "%~dp0TMP\TotalHDD_Size.txt" & set /P @TotalHDD_Size=<"%~dp0TMP\TotalHDD_Size.txt"
     if !TotalHDD_Size! GTR 1000 set "HDDMB=GB" & echo !TotalHDD_Size!| "%~dp0BAT\busybox" sed -e "s/.\{1\}/&\./" > "%~dp0TMP\TotalHDD_Size.txt" & set /P @TotalHDD_Size=<"%~dp0TMP\TotalHDD_Size.txt"
     if !TotalHDD_Size! GTR 10000 set "HDDMB=GB" & echo !TotalHDD_Size!| "%~dp0BAT\busybox" sed -e "s/.\{2\}/&\./" > "%~dp0TMP\TotalHDD_Size.txt" & set /P @TotalHDD_Size=<"%~dp0TMP\TotalHDD_Size.txt"
     if !TotalHDD_Size! GTR 100000 set "HDDMB=GB" & echo !TotalHDD_Size!| "%~dp0BAT\busybox" sed -e "s/.\{3\}/&\./" > "%~dp0TMP\TotalHDD_Size.txt" & set /P @TotalHDD_Size=<"%~dp0TMP\TotalHDD_Size.txt"
     if !TotalHDD_Size! GTR 1000000 set "HDDMB=GB" & echo !TotalHDD_Size!| "%~dp0BAT\busybox" sed -e "s/.\{4\}/&\./" > "%~dp0TMP\TotalHDD_Size.txt" & set /P @TotalHDD_Size=<"%~dp0TMP\TotalHDD_Size.txt"
     if !TotalHDD_Size! GTR 10000000 set "HDDMB=GB" & echo !TotalHDD_Size!| "%~dp0BAT\busybox" sed -e "s/.\{5\}/&\./" > "%~dp0TMP\TotalHDD_Size.txt" & set /P @TotalHDD_Size=<"%~dp0TMP\TotalHDD_Size.txt"
	 
	 echo set @hdl_path=!@hdl_path!> "%~dp0BAT\__Cache\HDD.BAT"
	 echo set @pfsshell_path=!@pfsshell_path!>> "%~dp0BAT\__Cache\HDD.BAT"
	 echo set @NumberPS2HDD=!@NumberPS2HDD!>> "%~dp0BAT\__Cache\HDD.BAT"
	 echo set @ModelePS2HDD=!@ModelePS2HDD!>> "%~dp0BAT\__Cache\HDD.BAT"
	 echo set @TotalHDD_Size=!@TotalHDD_Size! !HDDMB!>> "%~dp0BAT\__Cache\HDD.BAT"
	
	"%~dp0BAT\Diagbox" gd 0f
	 echo Model: [!@ModelePS2HDD!]
	 echo Drive: [!@pfsshell_path!]
	 echo Size:  [!@TotalHDD_Size! !HDDMB!]
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
title PFS BatchKit Manager v1.1.8 By GDX
echo.PFS BatchKit Manager v1.1.8 By GDX
endlocal
endlocal
setlocal EnableDelayedExpansion
setlocal EnableExtensions
call "%~dp0BAT\__Cache\HDD.BAT" >nul 2>&1
if defined @hdl_path (
 "%~dp0BAT\Diagbox" gd 03
echo [!@hdl_path! !@TotalHDD_Size! - !@ModelePS2HDD!]
) else (
"%~dp0BAT\Diagbox" gd 0c
echo [NO DEVICE] PLEASE RELOAD HDD
)
"%~dp0BAT\Diagbox" gd 0f
echo.------------------------------------------
echo.
ECHO  [=====^| Main Menu ^|=====]
echo.
ECHO  [1] Install PS1 Games
ECHO  [2] Install PS2 Games
ECHO  [3] Transfer OPL Resource Files
ECHO  [4] Transfer POPS Binaries
ECHO.
ECHO.
ECHO  [7] Extract PS1 Games
ECHO  [8] Extract PS2 Games
ECHO  [9] Extract OPL Resource Files
ECHO.
"%~dp0BAT\Diagbox" gd 0e
ECHO  [10] Advanced Menu
"%~dp0BAT\Diagbox" gd 0f
ECHO.
ECHO  [11] Exit
ECHO  [12] About
ECHO  [13] Change/Reload HDD
ECHO.
ECHO  [14] Donate
if defined update ("%~dp0BAT\Diagbox" gd 0a & ECHO  [15] !update!)
if not defined update ECHO  [15] Check for Updates
"%~dp0BAT\Diagbox" gd 0f
echo.------------------------------------------
set "choice="
set /p choice="Select Option:"

if "%choice%"=="1" (goto TransferPS1Games)
if "%choice%"=="2" (goto TransferPS2Games)
if "%choice%"=="3" (goto TransferAPPSARTCFGCHTTHMVMC)
if "%choice%"=="4" (goto TransferPOPSBinaries)

if "%choice%"=="7" (goto BackupPS1Games)
if "%choice%"=="8" (goto BackupPS2Games)
if "%choice%"=="9" (goto BackupARTCFGCHTVMC)
if "%choice%"=="10" (goto AdvancedMenu)
if "%choice%"=="11" exit
if "%choice%"=="12" (goto About)
if "%choice%"=="13" (goto ScanningPS2HDD)
if "%choice%"=="14" (start https://ko-fi.com/J3J6PIQ9O)
if "%choice%"=="15" (start https://github.com/GDX-X/PFS-BatchKit-Manager)

(goto mainmenu)

:About
"%~dp0BAT\Diagbox" gd 0f
cd /d "%~dp0"
cls
title PFS BatchKit Manager v1.1.8 By GDX
echo.PFS BatchKit Manager v1.1.8 By GDX
endlocal
endlocal
setlocal DisableDelayedExpansion
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
ECHO  [6]                                                  !     !      ! = !
ECHO  [7] Special Thanks                                   !     !      ! = !
ECHO  [8] Official PS2 Forum                               !     ! !! !!! = !
ECHO  [9] Official PS2 Discord                             !     ! !! !!! = !
ECHO.                                                      !     ! !! !!! = !
ECHO  [10] Back to main menu                               !     !      ! = !
ECHO  [11] Exit                                            !_____! !! !!! _ ! 
echo.------------------------------------------           /     /! !! !!!! !!\ 
echo                                                     /     / ! !! !!!! !! \ 
echo                                                    /_____/__!______!!_!!__\ 
set "choice="                
set /p choice="Select Option:"                                                                 
if "%choice%"=="1" (start https://twitter.com/GDX_SM)
if "%choice%"=="3" (start https://www.youtube.com/user/GDXTV/videos)
if "%choice%"=="4" (start https://github.com/GDX-X/PFS-BatchKit-Manager)
if "%choice%"=="5" (start https://ko-fi.com/J3J6PIQ9O)

if "%choice%"=="7" cls & type "%~dp0\Credits.txt" & echo\ & echo\ & echo\ & pause
if "%choice%"=="8" (start https://www.psx-place.com/forums/#playstation-2-forums.6)
if "%choice%"=="9" (start https://discord.gg/PWGvKXjRgy)

if "%choice%"=="10" (goto mainmenu)
if "%choice%"=="11" exit

if "%choice%"=="99" (goto poop)
if "%choice%"=="100" (goto GDX-X)

(goto About)

:AdvancedMenu
"%~dp0BAT\Diagbox" gd 0f
cd /d "%~dp0"
cls
title PFS BatchKit Manager v1.1.8 By GDX
echo.PFS BatchKit Manager v1.1.8 By GDX
endlocal
endlocal
setlocal EnableDelayedExpansion
setlocal EnableExtensions
call "%~dp0BAT\__Cache\HDD.BAT" >nul 2>&1
if defined @hdl_path (
 "%~dp0BAT\Diagbox" gd 03
echo [!@hdl_path! !@TotalHDD_Size! - !@ModelePS2HDD!]
) else (
"%~dp0BAT\Diagbox" gd 0c
echo [NO DEVICE] PLEASE RELOAD HDD
)
"%~dp0BAT\Diagbox" gd 0f
echo.------------------------------------------
echo.
ECHO  [=====^| Advanced Menu ^|=====]
ECHO.
ECHO  [1] Conversion
ECHO  [2] Games Management
ECHO  [3] Downloads/Updates
ECHO  [4] Other PC Tools
ECHO  [5] 
ECHO  [6]
ECHO  [7] FHDB/HDD-OSD/PSBBN/XMB
ECHO  [8] PS2 Online
ECHO  [9] HDD Management
ECHO.
ECHO  [10] Back to main menu
ECHO  [11] Exit
ECHO.
echo.------------------------------------------
set "choice="
set /p choice="Select Option:"

if "%choice%"=="1" (goto ConversionMenu)
if "%choice%"=="2" (goto GamesManagement)
if "%choice%"=="3" (goto DownloadsMenu)
if "%choice%"=="4" (goto PC-UtilityMenu)


if "%choice%"=="7" (goto HDDOSDMenu)
if "%choice%"=="8" (goto PS2OnlineMenu)
if "%choice%"=="9" (goto HDDManagementMenu)
if "%choice%"=="10" (goto mainmenu)
if "%choice%"=="11" exit

(goto AdvancedMenu)

:ConversionMenu
"%~dp0BAT\Diagbox" gd 0f
cd /d "%~dp0"
cls
title PFS BatchKit Manager v1.1.8 By GDX
echo.PFS BatchKit Manager v1.1.8 By GDX
endlocal
endlocal
setlocal EnableDelayedExpansion
setlocal EnableExtensions
call "%~dp0BAT\__Cache\HDD.BAT" >nul 2>&1
if defined @hdl_path (
 "%~dp0BAT\Diagbox" gd 03
echo [!@hdl_path! !@TotalHDD_Size! - !@ModelePS2HDD!]
) else (
"%~dp0BAT\Diagbox" gd 0c
echo [NO DEVICE] PLEASE RELOAD HDD
)
"%~dp0BAT\Diagbox" gd 0f
echo.------------------------------------------
echo.
ECHO  [=====^| Conversion Menu ^|=====]
ECHO.
ECHO  [1] Convert .BIN to .VCD (Multi-Tracks Compatible)
ECHO  [2] Convert .VCD to .BIN
ECHO  [3] Convert Multi-Tracks .BIN to Single .BIN
ECHO  [4] 
ECHO  [5] Convert .BIN to .ISO (Only for PS2 Games Usefull for PCSX2)
ECHO  [6] Compress/Decompress .ECM
ECHO  [7] Compress/Decompress .CHD (Multi-Tracks Compatible)
ECHO  [8] Compress/Decompress .ZSO (Only for PS2 Games)
ECHO  [9] Restore Single .BIN to Multi-Tracks (If compatible, it will rebuild the original .bin with the Multi-Track)
ECHO.
ECHO  [10] Back
ECHO  [11] Back to main menu
ECHO  [12] Exit
ECHO.
echo.------------------------------------------
set "choice="
set /p choice="Select Option:"

if "%choice%"=="1" (goto BIN2VCD)
if "%choice%"=="2" (goto VCD2BIN)
if "%choice%"=="3" (goto multibin2bin)

if "%choice%"=="5" (goto BIN2ISO)
if "%choice%"=="6" (goto ECMConv)
if "%choice%"=="7" (goto CHDConv)
if "%choice%"=="8" (goto ZSOConv)
if "%choice%"=="9" (goto bin2split)

if "%choice%"=="10" (goto AdvancedMenu)
if "%choice%"=="11" (goto mainmenu)
if "%choice%"=="12" exit

(goto ConversionMenu)

:GamesManagement
"%~dp0BAT\Diagbox" gd 0f
cd /d "%~dp0"
cls
title PFS BatchKit Manager v1.1.8 By GDX
echo.PFS BatchKit Manager v1.1.8 By GDX
endlocal
endlocal
setlocal EnableDelayedExpansion
setlocal EnableExtensions
call "%~dp0BAT\__Cache\HDD.BAT" >nul 2>&1
if defined @hdl_path (
 "%~dp0BAT\Diagbox" gd 03
echo [!@hdl_path! !@TotalHDD_Size! - !@ModelePS2HDD!]
) else (
"%~dp0BAT\Diagbox" gd 0c
echo [NO DEVICE] PLEASE RELOAD HDD
)
"%~dp0BAT\Diagbox" gd 0f
echo.------------------------------------------
echo.
ECHO  [=====^| Games Management ^|=====]
ECHO.
ECHO  [1] Dump your CD-ROM, DVD-ROM PS1 ^& PS2
ECHO  [2] Check MD5 Hash of your PS2 .ISO/.BIN with the redump database
ECHO  [3] Assign titles database for your .VCDs
ECHO  [4] Create PS1 Games Shortcuts for OPL APPS TAB
ECHO  [5] Create Cheat file with mastercode
ECHO  [6] Create Virtual Memory Card
ECHO  [7] Delete a game
ECHO  [8] Rename a game
ECHO  [9] Export game list
ECHO.
ECHO  [10] Back
ECHO  [11] Back to main menu
ECHO  [12] Exit
ECHO.
echo.------------------------------------------
set "choice="
set /p choice="Select Option:"

if "%choice%"=="1" (goto DumpCDDVD)
if "%choice%"=="2" (goto checkMD5Hash)
if "%choice%"=="3" (goto RenameVCDDB)
if "%choice%"=="4" (goto CreatePS1ShortcutsAPPTAB)
if "%choice%"=="5" (copy "%~dp0BAT\make_cheat_mastercode.bat" >nul "%~dp0" & cls & call make_cheat_mastercode.bat & del make_cheat_mastercode.bat & pause)
if "%choice%"=="6" (goto CreateVMC)
if "%choice%"=="7" (goto DeleteChoiceGamesHDD)
if "%choice%"=="8" set "@GameManagementMenu=" & (goto RenameChoiceGames)
if "%choice%"=="9" (goto ExportChoiceGamesListHDD)

if "%choice%"=="10" (goto AdvancedMenu)
if "%choice%"=="11" (goto mainmenu)
if "%choice%"=="12" exit

(goto GamesManagement)

:DownloadsMenu
"%~dp0BAT\Diagbox" gd 0f
cd /d "%~dp0"
cls
title PFS BatchKit Manager v1.1.8 By GDX
echo.PFS BatchKit Manager v1.1.8 By GDX
endlocal
endlocal
setlocal EnableDelayedExpansion
setlocal EnableExtensions
call "%~dp0BAT\__Cache\HDD.BAT" >nul 2>&1
if defined @hdl_path (
 "%~dp0BAT\Diagbox" gd 03
echo [!@hdl_path! !@TotalHDD_Size! - !@ModelePS2HDD!]
) else (
"%~dp0BAT\Diagbox" gd 0c
echo [NO DEVICE] PLEASE RELOAD HDD
)
"%~dp0BAT\Diagbox" gd 0f
echo.------------------------------------------
echo.
ECHO  [=====^| Downloads Menu ^|=====]
ECHO.
ECHO  [1] Applications
ECHO  [2] Artworks
ECHO  [3] Configs
ECHO  [4] Cheats
ECHO  [5]
ECHO  [6]
ECHO  [7]
ECHO  [8]
ECHO  [9]
REM ECHO 9. Update your APPS,ART,CFG,CHT (Automatically updates files found in your +OPL partition
ECHO.
ECHO  [10] Back
ECHO  [11] Back to main menu
ECHO  [12] Exit
ECHO.
echo.------------------------------------------
set "choice="
set /p choice="Select Option:"
if "%choice%"=="1" set checkappsupdate=yes& (goto DownloadAPPSMenu)
if "%choice%"=="2" (goto DownloadARTChoice)
if "%choice%"=="3" (goto DownloadCFG)
if "%choice%"=="4" (goto DownloadCheatsMenu)

if "%choice%"=="10" (goto AdvancedMenu)
if "%choice%"=="11" (goto mainmenu)
if "%choice%"=="12" exit

(goto DownloadsMenu)

:DownloadAPPSMenu
"%~dp0BAT\Diagbox" gd 0f

if defined checkappsupdate (
cd /d "%~dp0TMP"
cls
echo\
echo Checking for APPS Database updates...
"%~dp0BAT\wget" -q "https://raw.githubusercontent.com/GDX-X/PFS-BatchKit-Manager/main/PFS-BatchKit-Manager/BAT/APPS.BAT" -O "%~dp0TMP\APPS.BAT" >nul 2>&1
for %%F in ( "APPS.BAT" ) do if %%~zF==0 (del "%%F")

if exist "APPS.BAT" (
"%~dp0BAT\busybox" md5sum "%~dp0TMP\APPS.BAT" 2>&1 | "%~dp0BAT\busybox" grep -o "[0-9a-f]\{32\}" > "%~dp0TMP\CheckUPDATE.txt" & set /p CheckUPDATE=<"%~dp0TMP\CheckUPDATE.txt"
"%~dp0BAT\busybox" md5sum "%~dp0\BAT\APPS.BAT" 2>&1 | "%~dp0BAT\busybox" grep -o "[0-9a-f]\{32\}" > "%~dp0TMP\CheckOriginal.txt" & set /p CheckOriginal=<"%~dp0TMP\CheckOriginal.txt"

if "!CheckUPDATE!"=="!CheckOriginal!" (echo ) else (
echo\
echo\
echo Updating...
move "APPS.BAT" "%~dp0BAT" >nul 2>&1
"%~dp0BAT\wget" -q "https://raw.githubusercontent.com/GDX-X/PFS-BatchKit-Manager/main/PFS-BatchKit-Manager/BAT/APPS.zip" -O "%~dp0TMP\APPS.zip" >nul 2>&1
for %%F in ( "APPS.zip" ) do if %%~zF==0 (del "%%F" ) else (move "APPS.zip" "%~dp0BAT" >nul 2>&1)
"%~dp0BAT\wget" -q "https://raw.githubusercontent.com/GDX-X/PFS-BatchKit-Manager/main/PFS-BatchKit-Manager/BAT/PSBBN_XMB_APPSINFOS_Database.zip" -O "%~dp0TMP\PSBBN_XMB_APPSINFOS_Database.zip" >nul 2>&1
for %%F in ( "PSBBN_XMB_APPSINFOS_Database.zip" ) do if %%~zF==0 (del "%%F" ) else (move "PSBBN_XMB_APPSINFOS_Database.zip" "%~dp0BAT" >nul 2>&1)
  )
 ) else (set "checkappsupdate=")
)

rmdir /Q/S "%~dp0TMP" >nul 2>&1
cd /d "%~dp0"
cls
title PFS BatchKit Manager v1.1.8 By GDX
echo.PFS BatchKit Manager v1.1.8 By GDX
endlocal
endlocal
setlocal EnableDelayedExpansion
setlocal EnableExtensions
call "%~dp0BAT\__Cache\HDD.BAT" >nul 2>&1
if defined @hdl_path (
 "%~dp0BAT\Diagbox" gd 03
echo [!@hdl_path! !@TotalHDD_Size! - !@ModelePS2HDD!]
) else (
"%~dp0BAT\Diagbox" gd 0c
echo [NO DEVICE] PLEASE RELOAD HDD
)
"%~dp0BAT\Diagbox" gd 0f
echo.------------------------------------------
echo.
ECHO  [=====^| Download APPS Menu ^|=====]
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
set "choice="
set /p choice="Select Option:"

if "%choice%"=="1" set "@DownloadOPL=yes" & (call "%~dp0BAT\APPS.BAT")
if "%choice%"=="2" set "@DownloadwLaunchELF=yes" & (call "%~dp0BAT\APPS.BAT")
if "%choice%"=="3" set "@DownloadUtilities=yes" & (call "%~dp0BAT\APPS.BAT")
if "%choice%"=="4" set "@DownloadEmulators=yes" & (call "%~dp0BAT\APPS.BAT")
if "%choice%"=="5" set "@DownloadMultiMedia=yes" & (call "%~dp0BAT\APPS.BAT")
if "%choice%"=="6" set "@DownloadHardware=yes" & (call "%~dp0BAT\APPS.BAT")

if "%choice%"=="9" (goto UpdatePartAPPS)

if "%choice%"=="10" (goto DownloadsMenu)
if "%choice%"=="11" (goto mainmenu)
if "%choice%"=="12" exit

(goto DownloadAPPSMenu)

:DownloadCheatsMenu
"%~dp0BAT\Diagbox" gd 0f
cd /d "%~dp0"
cls
title PFS BatchKit Manager v1.1.8 By GDX
echo.PFS BatchKit Manager v1.1.8 By GDX
endlocal
endlocal
setlocal EnableDelayedExpansion
setlocal EnableExtensions
call "%~dp0BAT\__Cache\HDD.BAT" >nul 2>&1
if defined @hdl_path (
 "%~dp0BAT\Diagbox" gd 03
echo [!@hdl_path! !@TotalHDD_Size! - !@ModelePS2HDD!]
) else (
"%~dp0BAT\Diagbox" gd 0c
echo [NO DEVICE] PLEASE RELOAD HDD
)
"%~dp0BAT\Diagbox" gd 0f
echo.------------------------------------------
echo.
ECHO  [=====^| Download Cheats Menu ^|=====]
ECHO.
ECHO  [1] Rockstar Games Uncensored Cheats
ECHO  [2] Widescreen Cheats (4/3 to 16/9)

ECHO.
ECHO  [10] Back
ECHO  [11] Back to main menu
ECHO  [12] Exit
ECHO.
echo.------------------------------------------
set "choice="
set /p choice="Select Option:"

if "%choice%"=="1" (start https://github.com/GDX-X/Rockstar-Games-Uncensored-PS2)
if "%choice%"=="2" (goto DownloadWideScreenCheat)

if "%choice%"=="10" (goto DownloadsMenu)
if "%choice%"=="11" (goto mainmenu)
if "%choice%"=="12" exit

(goto DownloadCheatsMenu)

:PC-UtilityMenu
"%~dp0BAT\Diagbox" gd 0f
cd /d "%~dp0"
cls
title PFS BatchKit Manager v1.1.8 By GDX
echo.PFS BatchKit Manager v1.1.8 By GDX
endlocal
endlocal
setlocal EnableDelayedExpansion
setlocal EnableExtensions
call "%~dp0BAT\__Cache\HDD.BAT" >nul 2>&1
if defined @hdl_path (
 "%~dp0BAT\Diagbox" gd 03
echo [!@hdl_path! !@TotalHDD_Size! - !@ModelePS2HDD!]
) else (
"%~dp0BAT\Diagbox" gd 0c
echo [NO DEVICE] PLEASE RELOAD HDD
)
"%~dp0BAT\Diagbox" gd 0f
echo.------------------------------------------
echo.
ECHO  [=====^| PC Utility Menu ^|=====]
ECHO.
ECHO  [1] PS1 Memory card Management
ECHO  [2] PS2 Memory card Management
ECHO  [3] PS2 Controller Remapper
ECHO  [4] OPL Manager
ECHO.
ECHO  [10] Back
ECHO  [11] Back to main menu
ECHO  [12] Exit
ECHO.
echo.------------------------------------------
set "choice="
set /p choice="Select Option:"

if "%choice%"=="1" start https://github.com/ShendoXT/memcardrex/releases
if "%choice%"=="2" start https://www.psx-place.com/resources/mymc-dual-by-joack.675
if "%choice%"=="3" start https://www.psx-place.com/resources/ps2-controller-remapper-by-pelvicthrustman.692/
if "%choice%"=="4" start https://oplmanager.com/site

if "%choice%"=="10" (goto AdvancedMenu)
if "%choice%"=="11" (goto mainmenu)
if "%choice%"=="12" exit

(goto PC-UtilityMenu)

:HDDOSDMenu
"%~dp0BAT\Diagbox" gd 0f
cd /d "%~dp0"
cls
title PFS BatchKit Manager v1.1.8 By GDX
echo.PFS BatchKit Manager v1.1.8 By GDX
endlocal
endlocal
setlocal EnableDelayedExpansion
setlocal EnableExtensions
call "%~dp0BAT\__Cache\HDD.BAT" >nul 2>&1
if defined @hdl_path (
 "%~dp0BAT\Diagbox" gd 03
echo [!@hdl_path! !@TotalHDD_Size! - !@ModelePS2HDD!]
) else (
"%~dp0BAT\Diagbox" gd 0c
echo [NO DEVICE] PLEASE RELOAD HDD
)
"%~dp0BAT\Diagbox" gd 0f
echo.------------------------------------------
echo.
ECHO  [=====^| FHDB/HDD-OSD/PSBBN/XMB Menu ^|=====]
ECHO.
ECHO  [1] Install HDD-OSD (Browser 2.0)
ECHO  [2] Uninstall HDD-OSD
ECHO  [3] Partitions Management
ECHO  [4] FreeHDBoot Management
REM ECHO 4. Install Playstation Broadband Navigator
REM ECHO 4. Install Linux Kernel
ECHO.
ECHO  [10] Back
ECHO  [11] Back to main menu
ECHO  [12] Exit
ECHO.
echo.------------------------------------------
set "choice="
set /p choice="Select Option:"

if "%choice%"=="1" (goto InstallHDDOSD)
if "%choice%"=="2" (goto UnInstallHDDOSD)
if "%choice%"=="3" (goto HDDOSDPartManagement)
if "%choice%"=="4" (goto FreeHDBootManagement)

if "%choice%"=="10" (goto AdvancedMenu)
if "%choice%"=="11" (goto mainmenu)
if "%choice%"=="12" exit

(goto HDDOSDMenu)

:HDDOSDPartManagement
"%~dp0BAT\Diagbox" gd 0f
cd /d "%~dp0"
cls
title PFS BatchKit Manager v1.1.8 By GDX
echo.PFS BatchKit Manager v1.1.8 By GDX
endlocal
endlocal
setlocal EnableDelayedExpansion
setlocal EnableExtensions
call "%~dp0BAT\__Cache\HDD.BAT" >nul 2>&1
if defined @hdl_path (
 "%~dp0BAT\Diagbox" gd 03
echo [!@hdl_path! !@TotalHDD_Size! - !@ModelePS2HDD!]
) else (
"%~dp0BAT\Diagbox" gd 0c
echo [NO DEVICE] PLEASE RELOAD HDD
)
"%~dp0BAT\Diagbox" gd 0f
echo.------------------------------------------
echo.
ECHO  [=====^| HDD-OSD/PSBBN/XMB Partitions Management ^|=====]
ECHO.
ECHO  [1] Transfer PS1 Games (Install as Partition Launch PS1 games from HDD-OSD, PSBBN, XMB Menu)
ECHO  [2] Transfer Or Update APP (Install as Partition Launch your APP from HDD-OSD, PSBBN, XMB Menu)
ECHO  [3] Inject OPL-Launcher (Launch PS2 games from HDD-OSD)
ECHO  [4] Hide Partition (Hide partitions in HDD-OSD)
ECHO  [5] Unhide Partition (Show partitions in HDD-OSD)
ECHO  [6] Rename a title (Displayed in HDD-OSD, PSBBN, XMB Menu)
ECHO  [7] Convert HDL Partition for PSBBN ^& XMB Menu (Launch PS2 games from PSBBN, XMB Menu)
ECHO  [8] Modify Partition Header (Customize your partition header)
ECHO  [9] Update Partition Resources Header (Updates Title, Icons, Gameinfo, ART, KELF)
ECHO.
ECHO  [10] Back
ECHO  [11] Back to main menu
ECHO  [12] Exit
ECHO.
echo.------------------------------------------
set "choice="
set /p choice="Select Option:"
if "%choice%"=="1" set "@pfs_popHDDOSDMAIN=" & (goto TransferPS1GamesHDDOSD)
if "%choice%"=="2" (goto TransferAPPSPart)
if "%choice%"=="3" (goto InjectOPL-Launcher)
if "%choice%"=="4" set "@pfs_PartHidePS2Games=yes" & set "Pfs_Part_Option=Hide" & set "@hdl_option=-hide" & (goto pphide_unhide)
if "%choice%"=="5" set "@pfs_PartUnHidePS2Games=yes" & set "Pfs_Part_Option=Unhide" & set "@hdl_option=-unhide" & (goto pphide_unhide)
if "%choice%"=="6" (goto RenameTitleHDDOSD)
if "%choice%"=="7" (goto ConvertGamesBBNXMB)
if "%choice%"=="8" (goto CustomPPHeader)
if "%choice%"=="9" (goto UpdatePPHeader)

if "%choice%"=="10" (goto HDDOSDMenu)
if "%choice%"=="11" (goto mainmenu)
if "%choice%"=="12" exit

(goto HDDOSDPartManagement)

:FreeHDBootManagement
"%~dp0BAT\Diagbox" gd 0f
cd /d "%~dp0"
cls
title PFS BatchKit Manager v1.1.8 By GDX
echo.PFS BatchKit Manager v1.1.8 By GDX
endlocal
endlocal
setlocal EnableDelayedExpansion
setlocal EnableExtensions
call "%~dp0BAT\__Cache\HDD.BAT" >nul 2>&1
if defined @hdl_path (
 "%~dp0BAT\Diagbox" gd 03
echo [!@hdl_path! !@TotalHDD_Size! - !@ModelePS2HDD!]
) else (
"%~dp0BAT\Diagbox" gd 0c
echo [NO DEVICE] PLEASE RELOAD HDD
)
"%~dp0BAT\Diagbox" gd 0f
echo.------------------------------------------
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
set "choice="
set /p choice="Select Option:"

if "%choice%"=="1" (goto FreeHDBootFixOSDCorruption)

if "%choice%"=="10" (goto HDDOSDMenu)
if "%choice%"=="11" (goto mainmenu)
if "%choice%"=="12" exit

(goto FreeHDBootManagement)

:PS2OnlineMenu
"%~dp0BAT\Diagbox" gd 0f
cd /d "%~dp0"
cls
title PFS BatchKit Manager v1.1.8 By GDX
echo.PFS BatchKit Manager v1.1.8 By GDX
endlocal
endlocal
setlocal EnableDelayedExpansion
setlocal EnableExtensions
call "%~dp0BAT\__Cache\HDD.BAT" >nul 2>&1
if defined @hdl_path (
 "%~dp0BAT\Diagbox" gd 03
echo [!@hdl_path! !@TotalHDD_Size! - !@ModelePS2HDD!]
) else (
"%~dp0BAT\Diagbox" gd 0c
echo [NO DEVICE] PLEASE RELOAD HDD
)
"%~dp0BAT\Diagbox" gd 0f
echo.------------------------------------------
echo.
ECHO  [=====^| PS2 Online Menu ^|=====]
ECHO.
ECHO  [1] Discord Retro-Online
ECHO  [2] Discord PS2 Online Gaming
ECHO  [3] Show PS2 Games Compatibles (Show only games that don't need a patch)
ECHO.
ECHO  [10] Back
ECHO  [11] Back to main menu
ECHO  [12] Exit
ECHO.
echo.------------------------------------------
set "choice="
set /p choice="Select Option:"

if "%choice%"=="1" start https://discord.gg/kxXJjrZaSP
if "%choice%"=="2" start https://discord.gg/t2JY9awkwD
if "%choice%"=="3" start https://docs.google.com/spreadsheets/d/1bbxOGm4dPxZ4Vbzyu3XxBnZmuPx3Ue-cPqBeTxtnvkQ
if "%choice%"=="10" (goto AdvancedMenu)
if "%choice%"=="11" (goto mainmenu)
if "%choice%"=="12" exit

(goto PS2OnlineMenu)

:HDDManagementMenu
"%~dp0BAT\Diagbox" gd 0f
cd /d "%~dp0"
cls
title PFS BatchKit Manager v1.1.8 By GDX
echo.PFS BatchKit Manager v1.1.8 By GDX
endlocal
endlocal
setlocal EnableDelayedExpansion
setlocal EnableExtensions
call "%~dp0BAT\__Cache\HDD.BAT" >nul 2>&1
if defined @hdl_path (
 "%~dp0BAT\Diagbox" gd 03
echo [!@hdl_path! !@TotalHDD_Size! - !@ModelePS2HDD!]
) else (
"%~dp0BAT\Diagbox" gd 0c
echo [NO DEVICE] PLEASE RELOAD HDD
)
"%~dp0BAT\Diagbox" gd 0f
echo.------------------------------------------
echo.
ECHO  [=====^| HDD Management ^|=====]
ECHO.
ECHO  [1] Create a Partition
ECHO  [2] Delete a Partition
ECHO  [3]
ECHO  [4] Show Partition Informations
ECHO  [5] Backup or Inject PS2 MBR Program
ECHO  [6] Explore PS2 HDD (Mount PFS partition from Windows Explorer)
ECHO  [7] NBD Server (Only to access PS2 HDD from network)
"%~dp0BAT\Diagbox" gd 06
ECHO  [8] Hack your HDD To PS2 Format (Only intended to be used as a boot entry point on wLaunchELF)
"%~dp0BAT\Diagbox" gd 0c
ECHO  [9] Format HDD To PS2 Format
"%~dp0BAT\Diagbox" gd 0f
ECHO.
ECHO  [10] Back
ECHO  [11] Back to main menu
ECHO  [12] Exit
ECHO.
echo.------------------------------------------
set "choice="
set /p choice="Select Option:"

if "%choice%"=="1" set "Part_Option=Create" & set "PFS_Option=mkpart" & set "Part_Option2=Creating" & (goto CreateDelPART)
if "%choice%"=="2" set "Part_Option=Delete" & set "PFS_Option=rmpart" & set "Part_Option2=Deleting" & (goto CreateDelPART)

if "%choice%"=="4" (goto ShowPartitionInfos) 
if "%choice%"=="5" (goto MBRProgram)
if "%choice%"=="6" (goto PS2HDDExplore)
if "%choice%"=="7" (goto NBDServer)
if "%choice%"=="8" (goto hackHDDtoPS2)
if "%choice%"=="9" (goto formatHDDtoPS2)
if "%choice%"=="10" (goto AdvancedMenu)
if "%choice%"=="11" (goto mainmenu)
if "%choice%"=="12" exit

(goto HDDManagementMenu)

:ShowPartitionInfos
"%~dp0BAT\Diagbox" gd 0f
cd /d "%~dp0"
cls
title PFS BatchKit Manager v1.1.8 By GDX
echo.PFS BatchKit Manager v1.1.8 By GDX
endlocal
endlocal
setlocal EnableDelayedExpansion
setlocal EnableExtensions
call "%~dp0BAT\__Cache\HDD.BAT" >nul 2>&1
if defined @hdl_path (
 "%~dp0BAT\Diagbox" gd 03
echo [!@hdl_path! !@TotalHDD_Size! - !@ModelePS2HDD!]
) else (
"%~dp0BAT\Diagbox" gd 0c
echo [NO DEVICE] PLEASE RELOAD HDD
)
"%~dp0BAT\Diagbox" gd 0f
echo.------------------------------------------
echo.
ECHO  [=====^| Partition Informations ^|=====]
ECHO.
ECHO  [1] Show PS1 Games Partitions Table
ECHO  [2] Show PS2 Games Partitions Table
ECHO  [3] Show APP System Partitions Table  
ECHO  [4] Show PFS System Partitions Table
ECHO  [5] Show Total Partitions Size
ECHO  [6]
ECHO  [7]
ECHO  [8]
ECHO  [9]
REM ECHO 9. Scan Partitions Error
ECHO.
ECHO  [10] Back
ECHO  [11] Back to main menu
ECHO  [12] Exit
ECHO.
echo.------------------------------------------
set "choice="
set /p choice="Select Option:"

if "%choice%"=="1" set "ShowPartitionList=PS1 Games" & (goto PartitionInfoList)
if "%choice%"=="2" set "ShowPartitionList=PS2 Games" & (goto PartitionInfoList)
if "%choice%"=="3" set "ShowPartitionList=APP" & (goto PartitionInfoList)
if "%choice%"=="4" set "ShowPartitionList=System" & (goto PartitionInfoList)
if "%choice%"=="5" set "ShowPartitionList=Total Size" & (goto PartitionInfoList)
REM if "%choice%"=="9" set DiagPartitionError=yes & (goto PartitionInfoList)

if "%choice%"=="10" (goto HDDManagementMenu)
if "%choice%"=="11" (goto mainmenu)
if "%choice%"=="12" exit

(goto ShowPartitionInfos)

:PS2HDDExplore
"%~dp0BAT\Diagbox" gd 0f
cd /d "%~dp0"
cls
IF NOT EXIST "%~dp0TMP" MD "%~dp0TMP" 
title PFS BatchKit Manager v1.1.8 By GDX
echo.PFS BatchKit Manager v1.1.8 By GDX
endlocal
endlocal
setlocal EnableDelayedExpansion
setlocal EnableExtensions
call "%~dp0BAT\__Cache\HDD.BAT" >nul 2>&1
if defined @hdl_path (
 "%~dp0BAT\Diagbox" gd 03
echo [!@hdl_path! !@TotalHDD_Size! - !@ModelePS2HDD!]
) else (
"%~dp0BAT\Diagbox" gd 0c
echo [NO DEVICE] PLEASE RELOAD HDD
)
"%~dp0BAT\Diagbox" gd 0f
echo.------------------------------------------
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
set "choice="
set /p choice="Select Option:"

"%~dp0BAT\busybox" ls "C:\Program Files\Dokan" > "%~dp0TMP\DokanFolder.txt" & set /P DokanFolder=<"%~dp0TMP\DokanFolder.txt"

if "%choice%"=="1" set "mount=HDD" & (goto PS2HDD2WinExplorer)
if "%choice%"=="2" cls & set "mount=IMG" & (goto DokanMountIMG)
if "%choice%"=="3" cls & set "DokanUmountDoManuallyPartition=yes" & (goto DokanUmountDoManuallyPartition)

if "%choice%"=="7" set CheckDokanVersion=yes & (goto PS2HDD2WinExplorer)
if "%choice%"=="8" cls & set "InstallDokanDriver=yes" & (goto InstallDokanDriver)
if "%choice%"=="9" cls & set "UninstallDokanDriver=yes" & (goto UninstallDokanDriver)

if "%choice%"=="10" (goto HDDManagementMenu)
if "%choice%"=="11" (goto mainmenu)
if "%choice%"=="12" exit

(goto PS2HDDExplore)

:NBDServer
"%~dp0BAT\Diagbox" gd 0f
cd /d "%~dp0"
cls
title PFS BatchKit Manager v1.1.8 By GDX
echo.PFS BatchKit Manager v1.1.8 By GDX
endlocal
endlocal
setlocal EnableDelayedExpansion
setlocal EnableExtensions
call "%~dp0BAT\__Cache\HDD.BAT" >nul 2>&1
if defined @hdl_path (
 "%~dp0BAT\Diagbox" gd 03
echo [!@hdl_path! !@TotalHDD_Size! - !@ModelePS2HDD!]
) else (
"%~dp0BAT\Diagbox" gd 0c
echo [NO DEVICE] PLEASE RELOAD HDD
)
"%~dp0BAT\Diagbox" gd 0f
echo.------------------------------------------
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
set "choice="
set /p choice="Select Option:"

if "%choice%"=="1" (
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

if "%choice%"=="2" cls & "%~dp0BAT\wnbd-client.exe" unmap PS2HDD & echo\ & echo\ & pause
if "%choice%"=="3" cls & "%~dp0BAT\wnbd-client.exe" list & echo\ & echo\ & pause
if "%choice%"=="8"  (goto InstallNBDDriver)
if "%choice%"=="9" ( 
cls
echo\
echo Are you sure you want to uninstall NBD-Server drivers^?
choice /c YN 
if errorlevel 2 (goto NBDServer)

"%~dp0BAT\wnbd-client.exe" uninstall-driver
echo\ 
pause
)

if "%choice%"=="10" (goto HDDManagementMenu)
if "%choice%"=="11" (goto mainmenu)
if "%choice%"=="12" exit

(goto NBDServer)

REM ############################################################################################################################################################
:TransferPS2Games
cls
mkdir "%~dp0CD-DVD" >nul 2>&1
mkdir "%~dp0TMP" >nul 2>&1
cd /d "%~dp0CD-DVD"

IF NOT DEFINED @hdl_path ( rmdir /Q/S "%~dp0TMP" >nul 2>&1 & goto ScanningPS2HDD ) else (
"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning for Playstation 2 HDDs:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "!@hdl_path!" | "%~dp0BAT\busybox" grep "Playstation 2 HDD" >nul
if errorlevel 1 set "@hdl_path=" & goto ScanningPS2HDD
echo       [!@hdl_path! !@TotalHDD_Size! - !@ModelePS2HDD!]
)

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Install PS2 Games:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1^) Yes
"%~dp0BAT\Diagbox" gd 0c
echo         2^) No
"%~dp0BAT\Diagbox" gd 0e
echo         3^) Yes (Copy PS2 games from one HDD to another in PS2 format)
echo\
"%~dp0BAT\Diagbox" gd 07
CHOICE /C 123 /M "Select Option:"

if %ERRORLEVEL%==2 (goto mainmenu)
if %ERRORLEVEL%==3 (goto CopyPS2GamesHDD)

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
  
  if not defined HDDPATH (
  set "HDDPATH=%~dp0CD-DVD"
  for /r "%~dp0CD" %%f in (*.bin *.cue *.iso *.zso *.zip *.7z *.rar) do move "%%f" "%~dp0CD-DVD" >nul 2>&1
  for /r "%~dp0DVD" %%f in (*.bin *.cue *.iso *.zso *.zip *.7z *.rar) do move "%%f" "%~dp0CD-DVD" >nul 2>&1
  )
  cd /d "!HDDPATH!"
  
  echo\
  "%~dp0BAT\Diagbox" gd 0e
  echo Do you want to use the title database for your games^? ^(Recommended^)
  "%~dp0BAT\Diagbox" gd 07
  echo If you choose NO the file names will be used as titles.
  choice /c YN
  if errorlevel 2 (set usedb=no) else (set usedb=yes)

IF %usedb%==yes (
echo ----------------------------------------------------
echo\
echo Choose the titles language of the games list
echo Some games have their own title in several languages for example:
echo\
echo English = The Simpsons Game
echo French  = Les Simpson le jeu
"%~dp0BAT\Diagbox" gd 0e
echo NOTE: Some titles may not be translated
"%~dp0BAT\Diagbox" gd 07
echo\
echo 1. English
echo 2. French
echo\
CHOICE /C 12 /M "Select Option:"
if errorlevel 1 set language=english
if errorlevel 2 set language=french

IF !language!==english ("%~dp0BAT\busybox" iconv -f utf8 -t ascii//TRANSLIT//IGNORE "%~dp0BAT\TitlesDB\TitlesDB_PS2_English.txt" > "%~dp0TMP\gameid.txt") & set CFG_lang=CFG_en
IF !language!==french ("%~dp0BAT\busybox" iconv -f utf8 -t ascii//TRANSLIT//IGNORE "%~dp0BAT\TitlesDB\TitlesDB_PS2_French.txt" > "%~dp0TMP\gameid.txt") & set CFG_lang=CFG_fr
) else (set CFG_lang=CFG_en)


echo\
echo\
echo\
"%~dp0BAT\Diagbox" gd 0e
echo Do you want to use recommended installation settings^?
"%~dp0BAT\Diagbox" gd 07
echo If you don't know, put yes.
CHOICE /C YN /M "Select Option:"
if errorlevel 1 set RecommendedSettings=yes
if errorlevel 2 set RecommendedSettings=no

if !RecommendedSettings!==yes (
set InfoGameConfig=Yes
) else (
echo ----------------------------------------------------
echo\
"%~dp0BAT\Diagbox" gd 0e
echo Do you want inject OPL-Launcher ^(Optional^)
"%~dp0BAT\Diagbox" gd 07
echo Allows you to launch your game from HDD-OSD ^(Browser 2.0^)
CHOICE /C YN /M "Select Option:"
if errorlevel 1 set InjectKELF=yes
if errorlevel 2 set InjectKELF=no

IF !InjectKELF!==yes (
copy "%~dp0BAT\boot.kelf" "%~dp0CD-DVD" >nul 2>&1
echo\
"%~dp0BAT\Diagbox" gd 0e
echo Do you want to download game icons for HDD-OSD?
"%~dp0BAT\Diagbox" gd 07
CHOICE /C YN /M "Select Option:"
if errorlevel 1 set DownloadICO=yes
if errorlevel 2 set DownloadICO=no

if !DownloadICO!==yes (
if exist "%~dp0HDD-OSD-Icons-Pack.zip" (
echo\
"%~dp0BAT\Diagbox" gd 0e
echo HDD-OSD-Icons-Pack.zip detected do you want use it?
"%~dp0BAT\Diagbox" gd 0f
CHOICE /C YN /M "Select Option:"
IF ERRORLEVEL 1 set uselocalARTHDDOSD=yes
IF ERRORLEVEL 2 set uselocalARTHDDOSD=no
) else (set uselocalARTHDDOSD=no)

if !uselocalARTHDDOSD!==no (
    cd /d "%~dp0TMP"
    echo.
	echo Checking internet Or Website connection... For HDD-OSD ART
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
if errorlevel 2 set InfoGameConfig=No

REM echo ----------------------------------------------------
REM echo\
REM echo Create cheats.CHT For your games with Mastercode? (Optional)
REM "%~dp0BAT\Diagbox" gd 0e
REM echo It is recommended to create the cheat files now
REM "%~dp0BAT\Diagbox" gd 07
REM echo\
REM CHOICE /C YN /M "Select Option:"
REM if errorlevel 1 set CreateCHT=yes
REM if errorlevel 2 set CreateCHT=no
REM 
REM IF !CreateCHT!==yes (
REM echo Creating .CHT Please wait...
REM cd /d "%~dp0" & copy "%~dp0BAT\make_cheat_mastercode.bat" "%~dp0" >nul & "%~dp0BAT\busybox" sed -i "$aexit" "make_cheat_mastercode.bat" | START /wait /MIN CMD.EXE /C make_cheat_mastercode.bat & del make_cheat_mastercode.bat
REM echo Don't forget to transfer your .CHTs to the HDD
REM )
echo\
"%~dp0BAT\Diagbox" gd 0e
echo Compress your games in .ZSO? ^(EXPERIMENTAL^)
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
if errorlevel 2 set "LZ4HC=--use-lz4brute"

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
if !ConvZSO!==yes type "%~dp0BAT\__Cache\PS2_GAMES_HDD.txt" > "%~dp0TMP\GameslistHDD.txt"

REM Download Infos Database
"%~dp0BAT\wget" -q --show-progress "https://github.com/GDX-X/PS2-OPL-CFG-Database/releases/download/Latest/PS2-OPL-CFG-Database.7z" >nul 2>&1 -O "%~dp0TMP\PS2-OPL-CFG-Database.7z"
for %%F in ("%~dp0TMP\PS2-OPL-CFG-Database.7z") do if %%~zF==0 (del %%F >nul 2>&1) else (move "%~dp0TMP\PS2-OPL-CFG-Database.7z" "%~dp0BAT" >nul 2>&1)

REM Download Compatibility Database
"%~dp0BAT\wget" -q --show-progress "https://github.com/GDX-X/PS2-OPL-CFG-Compatibility-Database/releases/download/Latest/PS2-OPL-CFG-Compatibility-Database.7z" >nul 2>&1 -O "%~dp0TMP\PS2-OPL-CFG-Compatibility-Database.7z"
for %%F in ("%~dp0TMP\PS2-OPL-CFG-Compatibility-Database.7z") do if %%~zF==0 (del %%F >nul 2>&1) else (move "%~dp0TMP\PS2-OPL-CFG-Compatibility-Database.7z" "%~dp0BAT" >nul 2>&1)

echo ----------------------------------------------------
cd /d "!HDDPATH!" & dir /b /a-d| "%~dp0BAT\busybox" grep -ie ".*\.iso$" -ie ".*\.cue$" -ie ".*\.zso$" -ie ".*\.zip$" -ie ".*\.7z$" -ie ".*\.rar$" > "%~dp0TMP\GameslistTMP.txt" & if not exist "%~dp0TMP\GameslistTMP.txt" type nul>"%~dp0TMP\GameslistTMP.txt"
set /a gamecount=0
for /f "usebackq delims=" %%f in ("%~dp0TMP\GameslistTMP.txt") do (
set /a gamecount+=1
	
	setlocal DisableDelayedExpansion
	set filename=%%f
	set fname=%%~nf
	set disctype=unknown
	set "dbtitle="
	set "ZSO_Installed="
	set "CheckTitle="
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
	echo !gamecount! - !filename!
	
	if "!filename!"=="!fname!.!compressed!" (
	"%~dp0BAT\7-Zip\7z" x -bso0 "!HDDPATH!\!fname!.!compressed!" -o"!HDDPATH!\~TMP~"
	"%~dp0BAT\busybox" ls "!HDDPATH!\~TMP~" | "%~dp0BAT\busybox" grep -ie ".*\.iso$" -ie ".*\.cue$" -ie ".*\.zso$" > "%~dp0TMP\GamesUnzip.txt" & set /P filename=<"%~dp0TMP\GamesUnzip.txt" 
    "%~dp0BAT\busybox" ls "!HDDPATH!\~TMP~" | "%~dp0BAT\busybox" grep -ie ".*\.iso$" -ie ".*\.cue$" -ie ".*\.zso$" | "%~dp0BAT\busybox" sed -e "s/\.[^.]*$//" > "%~dp0TMP\GamesUnzip.txt" & set /P fname=<"%~dp0TMP\GamesUnzip.txt"
	"%~dp0BAT\busybox" ls "!HDDPATH!\~TMP~" | "%~dp0BAT\busybox" grep -ie ".*\.iso$" -ie ".*\.cue$" -ie ".*\.zso$" | "%~dp0BAT\busybox" sed -e "s/.*\.//g" > "%~dp0TMP\GamesUnzip.txt"  & set /P ext=<"%~dp0TMP\GamesUnzip.txt" 
	move "!HDDPATH!\~TMP~\*" "!HDDPATH!" >nul 2>&1
	set DelExtracted=yes
	)
	
	if "!filename!"=="!fname!.cue" set ext=CUE
	if "!filename!"=="!fname!.CUE" set ext=CUE
	if "!filename!"=="!fname!.iso" set ext=ISO
	if "!filename!"=="!fname!.ISO" set ext=ISO
	
	if !ext!==zso set filename=!fname!.zso
	if "!filename!"=="!fname!.zso" "%~dp0BAT\maxcso" --decompress "!fname!.zso" -o "!fname!.iso" & set ext=ISO

	if defined ext ( "%~dp0BAT\hdl_dump" cdvd_info2 ".\!fname!.!ext!" > "%~dp0TMP\cdvd_info.txt"
	for /f "usebackq tokens=1,2,3,4,5*" %%i in ("%~dp0TMP\cdvd_info.txt") do (
	
	if "%%i"=="CD" ( set disctype=CD&& set gameid=%%~l)
	if "%%i"=="DVD" ( set disctype=DVD&& set gameid=%%~l)
	if "%%i"=="dual-layer" ( if "%%j"=="DVD" ( set disctype=DVD&& set gameid=%%~m))
     )
	)
	
    REM else (
	REM "%~dp0BAT\busybox" grep -o -m 1 "[A-Z][A-Z][A-Z][A-Z][_-][0-9][0-9][0-9].[0-9][0-9]" "!filename!" | "%~dp0BAT\busybox" sed "s/-/_/g" | "%~dp0BAT\busybox" head -1 > cdvd_info.txt
	REM set ext=ZSO
	REM set disctype=DVD
	REM set /P gameid=<cdvd_info.txt
	REM )
	
	set fnheader=!fname:~0,11!
	if "!fnheader!"==%%l (
		  set title=!fname:~12!
		) else (
	      if "!fnheader!"==%%m ( set title=!fname:~12!) else ( set title=!fname!)
		)

    if "!disctype!"=="unknown" (
    "%~dp0BAT\Diagbox" gd 0c
    echo	WARNING: Unable to determine disc type^! File ignored.
    "%~dp0BAT\Diagbox" gd 07
		
		) else (
		 REM Game ID with PBPX other region than JAP
		 set "region="
         if "!gameid!"=="PBPX_952.10" set region=NTSC-U/C
         if "!gameid!"=="PBPX_952.16" set region=NTSC-U/C
         if "!gameid!"=="PBPX_952.18" set region=NTSC-U/C
         if "!gameid!"=="PBPX_952.19" set region=PAL
         if "!gameid!"=="PBPX_952.23" set region=NTSC-U/C
         if "!gameid!"=="PBPX_952.47" set region=NTSC-U/C
         if "!gameid!"=="PBPX_952.48" set region=NTSC-U/C
         if "!gameid!"=="PBPX_955.17" set region=NTSC-U/C
         if "!gameid!"=="PBPX_952.04" set region=PAL
         if "!gameid!"=="PBPX_952.05" set region=PAL
         if "!gameid!"=="PBPX_952.08" set region=PAL
         if "!gameid!"=="PBPX_952.09" set region=PAL
         if "!gameid!"=="PBPX_952.20" set region=PAL
         if "!gameid!"=="PBPX_952.39" set region=NTSC-U/C
         if "!gameid!"=="PBPX_952.42" set region=NTSC-U/C
         if "!gameid!"=="PBPX_952.46" set region=NTSC-U/C
         if "!gameid!"=="PBPX_955.03" set region=NTSC-U/C
         if "!gameid!"=="PBPX_955.06" set region=PAL
         if "!gameid!"=="PBPX_955.14" set region=PAL
         if "!gameid!"=="PBPX_955.19" set region=NTSC-U/C
         if "!gameid!"=="PBPX_955.20" set region=PAL
	  
		 if not defined region (
		 echo !gameid!| "%~dp0BAT\busybox" cut -c3-3 > "%~dp0TMP\RegionID.txt" & set /P regionID=<"%~dp0TMP\RegionID.txt"
		 REM A = Asia
		 if "!regionID!"=="A" "%~dp0BAT\busybox" sed -ie "s/A/NTSC-A/g" "%~dp0TMP\RegionID.txt" & set /P region=<"%~dp0TMP\RegionID.txt"
		 REM C = China
       	 if "!regionID!"=="C" "%~dp0BAT\busybox" sed -ie "s/C/NTSC-C/g" "%~dp0TMP\RegionID.txt" & set /P region=<"%~dp0TMP\RegionID.txt"
		 REM E = Europe
		 if "!regionID!"=="E" "%~dp0BAT\busybox" sed -ie "s/E/PAL/g" "%~dp0TMP\RegionID.txt" & set /P region=<"%~dp0TMP\RegionID.txt"
		 REM K = Korean
		 if "!regionID!"=="K" "%~dp0BAT\busybox" sed -ie "s/K/NTSC-K/g" "%~dp0TMP\RegionID.txt" & set /P region=<"%~dp0TMP\RegionID.txt"
		 REM P = Japan
		 if "!regionID!"=="P" "%~dp0BAT\busybox" sed -ie "s/P/NTSC-J/g" "%~dp0TMP\RegionID.txt" & set /P region=<"%~dp0TMP\RegionID.txt"
		 REM UC = North America
		 if "!regionID!"=="U" "%~dp0BAT\busybox" sed -ie "s/U/NTSC-U\/C/g" "%~dp0TMP\RegionID.txt" & set /P region=<"%~dp0TMP\RegionID.txt"
         )
		 REM Unknown region
		 if not defined region set region=X

       REM Fix Conflict Games. Rare games that have the same ID
	   set rootpath=%~dp0
	   set GameInstall=PS2
	   findstr !gameid! "%~dp0BAT\Fix_Conflict_Gameid_Title.bat" >nul 2>&1
       if errorlevel 1 (echo >NUL) else (call "%~dp0BAT\Fix_Conflict_Gameid_Title.bat") 
	
		 	if "!usedb!"=="yes" (
			
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
		
		 if "!ConvZSO!"=="yes" (
		 IF EXIST "!HDDPATH!\!fname!.zso" ( set DelConvZSO=no ) else (
		 
		 REM Check if the game is already installed
		 "%~dp0BAT\busybox" grep -o -m 1 "!title!" "%~dp0TMP\GameslistHDD.txt" > "%~dp0TMP\CheckTitle.txt" & set /P CheckTitle=<"%~dp0TMP\CheckTitle.txt"
		 
		 if "!CheckTitle!"=="" (
		 echo !title!>> "%~dp0TMP\GameslistHDD.txt"
		 
		 echo Convert to ZSO... Please wait
         if "!disctype!"=="CD" (
		 if exist "!fname!.iso" ( "%~dp0BAT\maxcso" !LZ4HC! --block=2048 --format=zso "!fname!.iso" >nul 2>&1
		 ) else (
		 "%~dp0BAT\bchunk" "!fname!.bin" "!fname!.cue" "!fname!" >nul 2>&1 & ren "!fname!01.iso" "!fname!.iso" >nul 2>&1
		 "%~dp0BAT\maxcso" --block=2048 --format=zso "!fname!.iso" >nul 2>&1
		 set filename=!fname!.zso
		 REM del "!fname!.iso" >nul 2>&1
		     )
            )
		 if "!disctype!"=="DVD" "%~dp0BAT\maxcso" !LZ4HC! --block=2048 --format=zso "!fname!.iso" >nul 2>&1
           ) else (set ZSO_Installed=Yes)
		  )
		 )
		 
	   REM GET FILE SIZE 
	   if "!filename!"=="!fname!.iso" "%~dp0BAT\busybox" du -csh "!fname!.iso" 2>&1 | "%~dp0BAT\busybox" grep -e "total" | "%~dp0BAT\busybox" sed -e "s/total//g; s/K/KB/g; s/M/MB/g; s/G/GB/g" > "%~dp0TMP\isosize.txt" & set /P size=<"%~dp0TMP\isosize.txt"
	   if "!filename!"=="!fname!.cue" "%~dp0BAT\busybox" du -csh "!fname!.bin" 2>&1 | "%~dp0BAT\busybox" grep -e "total" | "%~dp0BAT\busybox" sed -e "s/total//g; s/K/KB/g; s/M/MB/g; s/G/GB/g" > "%~dp0TMP\binsize.txt" & set /P size=<"%~dp0TMP\binsize.txt"
	   if "!filename!"=="!fname!.zso" set ext=ZSO& "%~dp0BAT\busybox" du -csh "!fname!.zso" 2>&1 | "%~dp0BAT\busybox" grep -e "total" | "%~dp0BAT\busybox" sed -e "s/total//g; s/K/KB/g; s/M/MB/g; s/G/GB/g" > "%~dp0TMP\zsosize.txt" & set /P size=<"%~dp0TMP\zsosize.txt"
       if "!ConvZSO!"=="yes" set ext=ZSO& "%~dp0BAT\busybox" du -csh "!fname!.zso" 2>&1 | "%~dp0BAT\busybox" grep -e "total" | "%~dp0BAT\busybox" sed -e "s/total//g; s/K/KB/g; s/M/MB/g; s/G/GB/g" > "%~dp0TMP\zsosize.txt" & set /P size=<"%~dp0TMP\zsosize.txt"  
            
			echo ----------------------------------------------------
			echo Title:    [!title!]
			echo Gameid:   [!gameid!]
			echo Region:   [!region!]
			echo DiscType: [!disctype!]
			echo Format:   [!ext!]
			echo Size:     [!size!]
			echo ----------------------------------------------------
			
	   "%~dp0BAT\7-Zip\7z" e -bso0 "%~dp0BAT\HDD-OSD_SAMPLE_HEADER.zip" -o"%~dp0CD-DVD" PS2\icon.sys -r -y >nul 2>&1
	   
	   if !DownloadICO!==yes (
	   echo            Downloading Resources...
	   if !DownloadARTHDDOSD!==yes "%~dp0BAT\wget" -q "https://archive.org/download/hdd-osd-icons-pack/HDD-OSD-Icons-Pack.zip/PS2%%2F!gameid!%%2Ficon.sys" -O "%~dp0TMP\icon.sys" >nul
	   if !DownloadARTHDDOSD!==yes "%~dp0BAT\wget" -q "https://archive.org/download/hdd-osd-icons-pack/HDD-OSD-Icons-Pack.zip/PS2%%2F!gameid!%%2Flist.ico" -O "%~dp0TMP\list.ico" >nul
	   if !DownloadARTHDDOSD!==yes "%~dp0BAT\wget" -q "https://archive.org/download/hdd-osd-icons-pack/HDD-OSD-Icons-Pack.zip/PS2%%2F!gameid!%%2Fdel.ico"  -O "%~dp0TMP\del.ico" >nul
	   if !uselocalARTHDDOSD!==yes if exist "%~dp0HDD-OSD-Icons-Pack.zip" "%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0HDD-OSD-Icons-Pack.zip" -o"%~dp0TMP" PS2\!gameid!\ -r -y >nul 2>&1 & move "%~dp0TMP\PS2\!gameid!\*" "%~dp0TMP" >nul 2>&1
	   for /r "%~dp0TMP" %%F in (*.ico *.sys) do if %%~zF==0 (del "%%F" >nul 2>&1) else (move "%%F" "%~dp0CD-DVD" >nul 2>&1 & if not exist "%~dp0CD-DVD\del.ico" copy "%~dp0CD-DVD\list.ico" "%~dp0CD-DVD\del.ico" >nul 2>&1)
       )

	   REM HDD-OSD Infos
	   if exist "%~dp0CD-DVD\icon.sys" (
	   
	   if "!usedb!"=="yes" (
	   if not defined dbtitleosd (
	   set "dbtitleosd="
	   IF !language!==english copy "%~dp0BAT\TitlesDB\TitlesDB_PS2_English.txt" "%~dp0TMP\gameid_HDD-OSD.txt" >nul 2>&1
       IF !language!==french copy "%~dp0BAT\TitlesDB\TitlesDB_PS2_French.txt" "%~dp0TMP\gameid_HDD-OSD.txt" >nul 2>&1
 	   for /f "tokens=1*" %%A in ( 'findstr !gameid! "%~dp0TMP\gameid_HDD-OSD.txt"' ) do set dbtitleosd=%%B
	    )
	   )
	   	
	   if not defined dbtitleosd set dbtitleosd=!title!
       echo "!dbtitleosd!"| "%~dp0BAT\busybox" sed -e "s/\&/\\\&/g; s./.\\\/.g; s/\""//g" > "%~dp0TMP\dbtitle.txt" & set /P dbtitleosd=<"%~dp0TMP\dbtitle.txt"
	   echo !gameid!| "%~dp0BAT\busybox" sed "s/_/-/g" | "%~dp0BAT\busybox" sed "s/\.//" > "%~dp0TMP\DetectID.txt" & set /P gameid2=<"%~dp0TMP\DetectID.txt"
	   "%~dp0BAT\busybox" sed -i -e "s/ = /=/g; s/=/ = /g; s/  =/ = /g" "%~dp0CD-DVD\icon.sys"
	   "%~dp0BAT\busybox" sed -i -e "s/title0 =.*/title0 =/g; s/title0 =/title0 = !dbtitleosd!/g" "%~dp0CD-DVD\icon.sys"
 	   "%~dp0BAT\busybox" sed -i -e "s/title1 =.*/title1 =/g; s/title1 =/title1 = !gameid2!/g" "%~dp0CD-DVD\icon.sys"
	   
	   IF !language!==french "%~dp0BAT\busybox" sed -i -e "s/uninstallmes0 =.*/uninstallmes0 =/g; s/uninstallmes0 =/uninstallmes0 = Cela supprimera le jeu\./g" "%~dp0CD-DVD\icon.sys"
	   "%~dp0BAT\busybox" sed -i -e "s/\s*$//" "%~dp0CD-DVD\icon.sys"
	   )
			
			echo            Installing...
			if "!filename!"=="!fname!.zso" set "ext=ISO"
			if not defined ZSO_Installed (
			"%~dp0BAT\Diagbox" gd 0d
			REM Since hdl_dump update DVD9 doesn't seem to work properly anymore 
			REM so a stable version will be used for the installation of games in iso/bin
			if exist !fname!.zso (
			"%~dp0BAT\hdl_dump" inject_!disctype! !@hdl_path! "!title!" "!fname!.!ext!" !gameid! *u4 !GameHide!
			) else (
			"%~dp0BAT\hdl_dump_stable" inject_!disctype! !@hdl_path! "!title!" "!fname!.!ext!" !gameid! *u4 !GameHide!
			)
			) else ("%~dp0BAT\Diagbox" gd 0d & echo !@hdl_path! partition with such name already exists: "!title!")
			
			REM Avoid some probleme
			 echo "!title!"| "%~dp0BAT\busybox" sed "s/^.//g; s/\s*$//g; s/[^A-Za-z0-9.]/_/g; s/\./_/g; y/abcdefghijklmnopqrstuvwxyz/ABCDEFGHIJKLMNOPQRSTUVWXYZ/" | "%~dp0BAT\busybox" sed -e "s/^^/PP.!gameid2!../g; s/[[:space:]]*$//g;" | "%~dp0BAT\busybox" cut -c0-31 > "%~dp0TMP\GPartName.txt" & set /P GPartName=<"%~dp0TMP\GPartName.txt"
			 cd /d "%~dp0CD-DVD" & "%~dp0BAT\hdl_dump" modify_header !@hdl_path! "!GPartName!" >nul 2>&1 & cd /d "!HDDPATH!"
	         echo !GPartName!| "%~dp0BAT\busybox" sed -e "s/PP\./__\./g" > "%~dp0TMP\GPartName.txt" & set /P GPartName=<"%~dp0TMP\GPartName.txt"
			 cd /d "%~dp0CD-DVD" & "%~dp0BAT\hdl_dump" modify_header !@hdl_path! "!GPartName!" >nul 2>&1 & cd /d "!HDDPATH!"
			
			REM Infos + Compatibility Modes CFG
		    if exist "%~dp0CFG\!gameid!.cfg" del "%~dp0CFG\!gameid!.cfg" >nul 2>&1
			echo Title=> "%~dp0CFG\!gameid!.cfg"
			
			if !InfoGameConfig!==Yes "%~dp0BAT\7-Zip\7z" e -bso0 "%~dp0BAT\PS2-OPL-CFG-Database.7z" -o"%~dp0CFG" !CFG_lang!\!gameid!.cfg -r -y >nul 2>&1
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

			if "!DelConvZSO!"=="yes" del "!fname!.zso" >nul 2>&1
			if "!filename!"=="!fname!.zso" del "!fname!.iso" >nul 2>&1
			if "!DelExtracted!"=="yes" del "!fname!.cue" >nul 2>&1 & del "!fname!.bin" >nul 2>&1 & del "!fname!.iso" >nul 2>&1 & del "!fname!.zso" >nul 2>&1
			for /r "%~dp0CD-DVD" %%o in (*.ico *.sys) do del "%%o" >nul 2>&1
			"%~dp0BAT\Diagbox" gd 07
			echo ----------------------------------------------------
		)
	endlocal
endlocal
)

echo\
cd /d "%~dp0CD-DVD"
for %%f in (*.bin *.cue) do move "%%f" "%~dp0CD" >nul 2>&1
for %%f in (*.iso *.zso *.zip *.7z *.rar) do move "%%f" "%~dp0DVD" >nul 2>&1
     
	 cd /d "%~dp0TMP"
	 REM echo            Checking OPL Files... 
     echo device %@pfsshell_path% > "%~dp0TMP\pfs-OPLconfig.txt"
     echo mount __common >> "%~dp0TMP\pfs-OPLconfig.txt"
	 echo cd OPL >> "%~dp0TMP\pfs-OPLconfig.txt"
     echo get conf_hdd.cfg >> "%~dp0TMP\pfs-OPLconfig.txt"
	 echo cd .. >> "%~dp0TMP\pfs-OPLconfig.txt"
     echo umount >> "%~dp0TMP\pfs-OPLconfig.txt"
	 echo exit >> "%~dp0TMP\pfs-OPLconfig.txt"
     type "%~dp0TMP\pfs-OPLconfig.txt" | "%~dp0BAT\pfsshell" >nul 2>&1
	 
	 if not exist conf_hdd.cfg (set OPLPATH=+OPL) else ("%~dp0BAT\busybox" grep "hdd_partition=" "%~dp0TMP\conf_hdd.cfg" | "%~dp0BAT\busybox" sed "s/^.*=//" > "%~dp0TMP\OPLPATH.txt" & set /P OPLPATH=<"%~dp0TMP\OPLPATH.txt"& set CUSTOM_PATH=Yes)
	 if %OPLPATH%==+OPL set "CUSTOM_PATH="
	 
	 cd /d "%~dp0CFG"
	 echo device %@pfsshell_path% > "%~dp0TMP\pfs-OPLconfig.txt"
     echo mount %OPLPATH% >> "%~dp0TMP\pfs-OPLconfig.txt"
	 if defined CUSTOM_PATH echo mkdir OPL >> "%~dp0TMP\pfs-OPLconfig.txt"
     if defined CUSTOM_PATH echo cd OPL >> "%~dp0TMP\pfs-OPLconfig.txt"
	 echo mkdir CFG >> "%~dp0TMP\pfs-OPLconfig.txt"
     echo cd CFG >> "%~dp0TMP\pfs-OPLconfig.txt"
	 for %%f in (*.cfg) do (echo put %%f) >> "%~dp0TMP\pfs-OPLconfig.txt"
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
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo Completed...
echo\
echo\
"%~dp0BAT\Diagbox" gd 0f
	 
cd /d "%~dp0"
del "!HDDPATH!\info.sys" >nul 2>&1
rmdir /Q/S "!HDDPATH!\~TMP~" >nul 2>&1
rmdir /Q/S "%~dp0TMP" >nul 2>&1
rmdir /Q/S "%~dp0CD-DVD" >nul 2>&1

echo\
pause & (goto mainmenu)
REM ########################################################################################################################################################################
:CopyPS2GamesHDD
cls
cd /d "%~dp0" & rmdir /Q/S "%~dp0TMP" >nul 2>&1
mkdir "%~dp0TMP" >nul 2>&1
set hdlhdd=%@hdl_path%
set PhysicDrive1=\\.\PHYSICALDRIVE%@NumberPS2HDD%
type nul>"%~dp0TMP\hdd-typetmp.txt"

"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning for second HDD:
echo ----------------------------------------------------
    "%~dp0BAT\Diagbox" gd 03

	"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "Playstation 2 HDD" | "%~dp0BAT\busybox" sed "/!hdlhdd!/d" | "%~dp0BAT\busybox" grep -o "hdd[0-9]:\|hdd[0-9][0-9]:" | "%~dp0BAT\busybox" sed "s/hdd//g; s/://g" > "%~dp0TMP\hdl-hdd.txt"
    wmic diskdrive get name,model | "%~dp0BAT\busybox" sed "s/[[:space:]]*$//" > "%~dp0TMP\hdd-type.txt"
	for /f "usebackq tokens=*" %%f in ("%~dp0TMP\hdl-hdd.txt") do "%~dp0BAT\busybox" grep "PHYSICALDRIVE%%f" "%~dp0TMP\hdd-type.txt" >> "%~dp0TMP\hdd-typetmp.txt"
	
	type "%~dp0TMP\hdd-typetmp.txt"
	"%~dp0BAT\Diagbox" gd 07
    echo.
    echo ----------------------------------------------------
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
    IF "!choice!"=="Q" set "hdlhdd=" & set "hdlhdd2=" & (goto mainmenu)
	IF "!choice!"=="q" set "hdlhdd=" & set "hdlhdd2=" & (goto mainmenu)

cls
"%~dp0BAT\Diagbox" gd 0e
echo HDD 1 Selected: Hard drive that contains your games
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "!hdlhdd!"
"%~dp0BAT\Diagbox" gd 0f
wmic diskdrive get name,model | findstr "Model !PhysicDrive1!"
"%~dp0BAT\Diagbox" gd 0e
echo ----------------------------------------------------
echo\

echo HDD 2 Selected: Copy to
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "!hdlhdd2!"
"%~dp0BAT\Diagbox" gd 0f
wmic diskdrive get name,model | findstr "Model !PhysicDrive2!"
"%~dp0BAT\Diagbox" gd 0e
echo ----------------------------------------------------
echo\
CHOICE /C YN /m "Confirm"
if ERRORLEVEL 1 set CopyHDD=All
if ERRORLEVEL 2 set "hdlhdd=" & set "hdlhdd2=" & (goto CopyPS2GamesHDD)
echo\

echo\
echo Do you want to copy the All games to HDD or just some games?
"%~dp0BAT\Diagbox" gd 0f
echo 1 = Yes All Games
echo 2 = Select Games Manually

CHOICE /C 12
if errorlevel 1 set CopyHDD=All
if errorlevel 2 set "CopyHDD=Manually" & set AnalyseGameName=Yes
echo\

"%~dp0BAT\Diagbox" gd 03
cd /d "%~dp0TMP" & "%~dp0BAT\hdl_dump" toc %hdlhdd% | "%~dp0BAT\busybox" grep -e "0x1337" | "%~dp0BAT\busybox" cut -c30-500 > "%~dp0TMP\PPGamelistPS2HDD1.txt"

if !CopyHDD!==All (

"%~dp0BAT\Diagbox" gd 0e
echo Do you want to copy your custom game icons displayed on HDD-OSD?
"%~dp0BAT\Diagbox" gd 0f
CHOICE /C YN
if errorlevel 1 set copyiconHDDOSD=yes
if errorlevel 2 set copyiconHDDOSD=no
echo\

echo\
"%~dp0BAT\hdl_dump_stable" copy_hdd %hdlhdd% %hdlhdd2%
if errorlevel 1 (set copyiconHDDOSD=no)

echo\
if !copyiconHDDOSD!==yes (
cd /d "%~dp0TMP" & "%~dp0BAT\hdl_dump" toc %hdlhdd2% | "%~dp0BAT\busybox" grep -e "0x1337" | "%~dp0BAT\busybox" cut -c30-500 > "%~dp0TMP\PPGamelistPS2HDD2.txt"
"%~dp0BAT\busybox" paste -d " " "%~dp0TMP\PPGamelistPS2HDD1.txt" "%~dp0TMP\PPGamelistPS2HDD2.txt" | "%~dp0BAT\busybox" sed -e "s/ * PP/|PP/g; s/ * __\./|__\./g" > "%~dp0TMP\PPGamelistPS2NEW.txt"

echo\
for /f "tokens=1* delims=|" %%f in (PPGamelistPS2NEW.txt) do (

echo Backup "%%f" partition header... from %hdlhdd%
set "PPHEADER=%%f" & mkdir "%~dp0TMP\!PPHEADER!" >nul 2>&1
cd /d "%~dp0TMP\!PPHEADER!" & "%~dp0BAT\hdl_dump_fix_header" dump_header %hdlhdd% "%%f" >nul 2>&1 & cd ..

echo Inject "%%g" partition header... to %hdlhdd2%
cd /d "%~dp0TMP\!PPHEADER!" & "%~dp0BAT\hdl_dump" modify_header %hdlhdd2% "%%g" >nul 2>&1 & cd ..
echo\
  )
 )
)

if !CopyHDD!==Manually (
:RefreshGamelistHDD
cls
"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Scanning Games List:
"%~dp0BAT\Diagbox" gd e
echo ----------------------------------------------------
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

if exist "%~dp0TMP\GameListTMPX.TXT" (
if defined GameNameDeselect (
type "%~dp0TMP\GameListTMPX.TXT" >> "%~dp0TMP\GamelistPS2HDD1.txt"
	) else (
	echo >nul
	)
   )


if defined DeselectGame (type "%~dp0TMP\GameSelectedList.txt" | "%~dp0BAT\busybox" sort -k2) else (type "%~dp0TMP\GamelistPS2HDD1.txt" | "%~dp0BAT\busybox" sort -k2)
"%~dp0BAT\Diagbox" gd 0e
echo ----------------------------------------------------
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
	echo 	3. Open Text Editor ^(Add games directly with a text editor^)
    echo.
	echo 	9. Back to main menu
    echo\
    echo\
	if not exist "%~dp0TMP\GameSelectedList.txt" type nul>"%~dp0TMP\GameSelectedList.txt"
	type nul>"%~dp0TMP\Size.txt"
	set "GameName="
	set "@Total_Game="
	REM set "Total_Size="
	set "MB="
	echo Example: SLES_510.61 Grand Theft Auto : Vice City
    set /p GameName="Enter Gameid + GameName:"
	
	IF "!GameName!"=="" (goto RefreshGamelistHDD)
	IF "!GameName!"=="1" set "GameName=" & goto COPYSELECTEDGAME
	IF "!GameName!"=="2" set "DeselectGame=Yes" & set "GameName=" & (goto RefreshGamelistHDD)
	IF "!GameName!"=="3" set "chcp65=Yes" & "%~dp0TMP\GameSelectedList.txt"
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
for /f %%s in (Size.txt) do (set /a "Total_Size+=%%s/1024")
if !Total_Size! GTR 10 set "MB=MB" & echo !Total_Size!| "%~dp0BAT\busybox" sed -e "s/ //g" > "%~dp0TMP\Total_Size.txt" & set /P @Total_Size=<"%~dp0TMP\Total_Size.txt"
if !Total_Size! GTR 100 set "MB=MB" & echo !Total_Size!| "%~dp0BAT\busybox" sed -e "s/ //g" > "%~dp0TMP\Total_Size.txt" & set /P @Total_Size=<"%~dp0TMP\Total_Size.txt"
if !Total_Size! GTR 1000 set "MB=GB" & echo !Total_Size!| "%~dp0BAT\busybox" sed -e "s/.\{1\}/&\./" > "%~dp0TMP\Total_Size.txt" & set /P @Total_Size=<"%~dp0TMP\Total_Size.txt"
if !Total_Size! GTR 10000 set "MB=GB" & echo !Total_Size!| "%~dp0BAT\busybox" sed -e "s/.\{2\}/&\./" > "%~dp0TMP\Total_Size.txt" & set /P @Total_Size=<"%~dp0TMP\Total_Size.txt"
if !Total_Size! GTR 100000 set "MB=GB" & echo !Total_Size!| "%~dp0BAT\busybox" sed -e "s/.\{3\}/&\./" > "%~dp0TMP\Total_Size.txt" & set /P @Total_Size=<"%~dp0TMP\Total_Size.txt"
if !Total_Size! GTR 1000000 set "MB=GB" & echo !Total_Size!| "%~dp0BAT\busybox" sed -e "s/.\{4\}/&\./" > "%~dp0TMP\Total_Size.txt" & set /P @Total_Size=<"%~dp0TMP\Total_Size.txt"
if !Total_Size! GTR 10000000 set "MB=GB" & echo !Total_Size!| "%~dp0BAT\busybox" sed -e "s/.\{5\}/&\./" > "%~dp0TMP\Total_Size.txt" & set /P @Total_Size=<"%~dp0TMP\Total_Size.txt"

"%~dp0BAT\Diagbox" gd 0e
echo HDD 1 Selected: Hard drive that contains your games
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "!hdlhdd!"
wmic diskdrive get name,model | findstr "Model !PhysicDrive1!"
"%~dp0BAT\Diagbox" gd 0e
echo ----------------------------------------------------
echo\

echo HDD 2 Selected: Copy to
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "!hdlhdd2!"
wmic diskdrive get name,model | findstr "Model !PhysicDrive2!"
"%~dp0BAT\Diagbox" gd 0e
echo ----------------------------------------------------

echo\
echo\
echo Selected games:
type "%~dp0TMP\GameSelectedList.txt" | "%~dp0BAT\busybox" sed -e "$aENDLINEPFSBM" | "%~dp0BAT\busybox" sed -e "/ENDLINEPFSBM/d" | "%~dp0BAT\busybox" sed -e "/^$/d" | "%~dp0BAT\busybox" wc -l > "%~dp0TMP\Total_Game.txt" & set /P @Total_Game=<"%~dp0TMP\Total_Game.txt"
"%~dp0BAT\Diagbox" gd 0e
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
type "%~dp0TMP\GameSelectedList.txt" | "%~dp0BAT\busybox" sort
"%~dp0BAT\Diagbox" gd 0e
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0f

"%~dp0BAT\hdl_dump" hdl_toc %hdlhdd2% | "%~dp0BAT\busybox" tail -1 > "%~dp0TMP\HDDSPACEFREE.txt"
REM "%~dp0BAT\busybox" cat "%~dp0TMP\HDDSPACEFREE.txt" | "%~dp0BAT\busybox" tail -1 | "%~dp0BAT\busybox" sed "s/used/used: /" | "%~dp0BAT\busybox" grep "used:" | "%~dp0BAT\busybox" sed "s/^.*://" | "%~dp0BAT\busybox" sed "s/\MB.*/MB/g; s/ //g" > "%~dp0TMP\test.txt
"%~dp0BAT\busybox" cat "%~dp0TMP\HDDSPACEFREE.txt" | "%~dp0BAT\busybox" tail -1 | "%~dp0BAT\busybox" sed "s/available/available: /" | "%~dp0BAT\busybox" grep "available:" | "%~dp0BAT\busybox" sed "s/^.*://" | "%~dp0BAT\busybox" sed "s/\MB.*/MB/g; s/ //g; s/MB//g" > "%~dp0TMP\HDD2FREESIZE.txt" & set /P Total_HDDFree=<"%~dp0TMP\HDD2FREESIZE.txt"

if !Total_HDDFree! GTR 10 set "MBHDD=MB" & echo !Total_HDDFree!| "%~dp0BAT\busybox" sed -e "s/ //g" > "%~dp0TMP\Total_Size.txt" & set /P @Total_HDDFree=<"%~dp0TMP\Total_Size.txt"
if !Total_HDDFree! GTR 100 set "MBHDD=MB" & echo !Total_HDDFree!| "%~dp0BAT\busybox" sed -e "s/ //g" > "%~dp0TMP\Total_Size.txt" & set /P @Total_HDDFree=<"%~dp0TMP\Total_Size.txt"
if !Total_HDDFree! GTR 1000 set "MBHDD=GB" & echo !Total_HDDFree!| "%~dp0BAT\busybox" sed -e "s/.\{1\}/&\./" > "%~dp0TMP\Total_Size.txt" & set /P @Total_HDDFree=<"%~dp0TMP\Total_Size.txt"
if !Total_HDDFree! GTR 10000 set "MBHDD=GB" & echo !Total_HDDFree!| "%~dp0BAT\busybox" sed -e "s/.\{2\}/&\./" > "%~dp0TMP\Total_Size.txt" & set /P @Total_HDDFree=<"%~dp0TMP\Total_Size.txt"
if !Total_HDDFree! GTR 100000 set "MBHDD=GB" & echo !Total_HDDFree!| "%~dp0BAT\busybox" sed -e "s/.\{3\}/&\./" > "%~dp0TMP\Total_Size.txt" & set /P @Total_HDDFree=<"%~dp0TMP\Total_Size.txt"
if !Total_HDDFree! GTR 1000000 set "MBHDD=GB" & echo !Total_HDDFree!| "%~dp0BAT\busybox" sed -e "s/.\{4\}/&\./" > "%~dp0TMP\Total_Size.txt" & set /P @Total_HDDFree=<"%~dp0TMP\Total_Size.txt"
if !Total_HDDFree! GTR 10000000 set "MBHDD=GB" & echo !Total_HDDFree!| "%~dp0BAT\busybox" sed -e "s/.\{5\}/&\./" > "%~dp0TMP\Total_Size.txt" & set /P @Total_HDDFree=<"%~dp0TMP\Total_Size.txt"

echo\
echo\
echo         TOTAL - Selected:  [!@Total_Game!]
echo         TOTAL - Size:      [!@Total_Size! !MB!]
echo         !hdlhdd2! - FreeSpace: [!@Total_HDDFree! !MBHDD!]

echo\
echo\
CHOICE /C YN /m "Confirm"
IF %ERRORLEVEL%==2 set "Total_Size=" & set "@Total_Size=" & set "MB=" & (goto RefreshGamelistHDD)

if /i !Total_Size! gtr !Total_HDDFree! (
"%~dp0BAT\Diagbox" gd 06
echo\
echo\
echo The HDD does not have enough free space to copy the selected games.

echo\
"%~dp0BAT\Diagbox" gd 0f
PAUSE & set "Total_Size=" & set "@Total_Size=" & set "MB=" & (goto RefreshGamelistHDD)
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
IF %ERRORLEVEL%==1 "%~dp0BAT\busybox" sort -o "%~dp0TMP\GameSelectedList.txt" "%~dp0TMP\GameSelectedList.txt"

REM I'm using this unoptimized Spaghetti method because hdl dump has a bug that prevents copying the next game after copying the first.
REM I will optimize the code later if the bug is solved
REM see https://github.com/ps2homebrew/hdl-dump/issues/73

"%~dp0BAT\busybox" sed -i "s/&/\\\&/g" "%~dp0TMP\GameSelectedList.txt"
for /f "tokens=*" %%f in (GameSelectedList.txt) do (

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

echo --------------------------------------------
REM Why am I using this logic? To increase the compatibility of old format HDL partitions

"%~dp0BAT\busybox" sed -i "s/\&/&/g" "%~dp0TMP\GameSelectedList.txt"
mkdir "%~dp0TMP\PPHEADER" >nul 2>&1

cd /d "%~dp0TMP" & "%~dp0BAT\hdl_dump" toc !hdlhdd2! | "%~dp0BAT\busybox" grep -e "0x1337" | "%~dp0BAT\busybox" cut -c30-500 > "%~dp0TMP\PPGamelistPS2HDD2.txt"
"%~dp0BAT\hdl_dump" hdl_toc !hdlhdd2! | "%~dp0BAT\busybox" sed -e "1d" | "%~dp0BAT\busybox" sed -e "$ d" | "%~dp0BAT\busybox" sed "s/\(.\{46\}\)./\1/" | "%~dp0BAT\busybox" cut -c35-500 > "%~dp0TMP\GamelistPS2HDD2TMP.txt"

"%~dp0BAT\busybox" paste -d " " "%~dp0TMP\GamelistPS2HDD1TMP.txt" "%~dp0TMP\PPGamelistPS2HDD1.txt" | "%~dp0BAT\busybox" sed -e "s/ * PP/|PP/g; s/ * __\./|__\./g" > "%~dp0TMP\PPGamelistPS2NEW1.txt
"%~dp0BAT\busybox" paste -d " " "%~dp0TMP\GamelistPS2HDD2TMP.txt" "%~dp0TMP\PPGamelistPS2HDD2.txt" | "%~dp0BAT\busybox" sed -e "s/ * PP/|PP/g; s/ * __\./|__\./g" > "%~dp0TMP\PPGamelistPS2NEW2.txt

   for /f "tokens=*" %%f in (GameSelectedList.txt) do (
   
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
   
   endlocal
 endlocal
   )
  )
 )
)

cd /d "%~dp0" & rmdir /Q/S "%~dp0TMP" >nul 2>&1

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo Copy Completed...
echo\
echo\
"%~dp0BAT\Diagbox" gd 07

pause & (goto mainmenu)

REM ########################################################################################################################################################################
:TransferAPPSARTCFGCHTTHMVMC

cd /d "%~dp0"
cls
mkdir "%~dp0TMP" >nul 2>&1

IF NOT DEFINED @hdl_path ( rmdir /Q/S "%~dp0TMP" >nul 2>&1 & goto ScanningPS2HDD ) else (
"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning for Playstation 2 HDDs:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "!@hdl_path!" | "%~dp0BAT\busybox" grep "Playstation 2 HDD" >nul
if errorlevel 1 set "@hdl_path=" & goto ScanningPS2HDD
echo       [!@hdl_path! !@TotalHDD_Size! - !@ModelePS2HDD!]
)

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Transfer Applications: [APPS]
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1^) Yes
"%~dp0BAT\Diagbox" gd 0c
echo         2^) No
"%~dp0BAT\Diagbox" gd 0e
echo		3^) Yes Create title.cfg for each ELF To launch APPS from OPL APPS TAB
"%~dp0BAT\Diagbox" gd 07
echo\
CHOICE /C 123 /M "Select Option:"

IF %ERRORLEVEL%==1 set @pfs_apps=yes
IF %ERRORLEVEL%==2 set @pfs_apps=no
IF %ERRORLEVEL%==3 set @pfs_apps=yes & copy "%~dp0BAT\make_title_cfg.bat" "%~dp0" >nul & call make_title_cfg.bat & del make_title_cfg.bat

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Transfer Artworks: [ART]
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1^) Yes
"%~dp0BAT\Diagbox" gd 0c
echo         2^) No
echo\
"%~dp0BAT\Diagbox" gd 07
CHOICE /C 12 /M "Select Option:"

IF %ERRORLEVEL%==1 set @pfs_art=yes
IF %ERRORLEVEL%==2 set @pfs_art=no


"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Transfer Configs: [CFG]
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1^) Yes
"%~dp0BAT\Diagbox" gd 0c
echo         2^) No
"%~dp0BAT\Diagbox" gd 07
echo\
CHOICE /C 12 /M "Select Option:"

IF %ERRORLEVEL%==1 set @pfs_cfg=yes
IF %ERRORLEVEL%==2 set @pfs_cfg=no


"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Transfer Cheats: [CHT]
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1^) Yes
"%~dp0BAT\Diagbox" gd 0c
echo         2^) No
"%~dp0BAT\Diagbox" gd 07
echo\
CHOICE /C 12 /M "Select Option:"

IF %ERRORLEVEL%==1 set @pfs_cht=yes
IF %ERRORLEVEL%==2 set @pfs_cht=no

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Transfer Languages: [LNG]
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1^) Yes
"%~dp0BAT\Diagbox" gd 0c
echo         2^) No
"%~dp0BAT\Diagbox" gd 07
echo\
CHOICE /C 12 /M "Select Option:"

IF %ERRORLEVEL%==1 set @pfs_LNG=yes
IF %ERRORLEVEL%==2 set @pfs_LNG=no

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Transfer Themes: [THM]
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1^) Yes
"%~dp0BAT\Diagbox" gd 0c
echo         2^) No
"%~dp0BAT\Diagbox" gd 07
echo\
CHOICE /C 12 /M "Select Option:"

IF %ERRORLEVEL%==1 set @pfs_thm=yes
IF %ERRORLEVEL%==2 set @pfs_thm=no

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Transfer OPL Virtual Memory Cards: [VMC]
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1^) Yes
"%~dp0BAT\Diagbox" gd 0c
echo         2^) No
"%~dp0BAT\Diagbox" gd 07
echo\
CHOICE /C 123 /M "Select Option:"

IF %ERRORLEVEL%==1 set @pfs_vmc=yes
IF %ERRORLEVEL%==2 set @pfs_vmc=no

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Transfer POPS Virtual Memory Cards:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1^) Yes
"%~dp0BAT\Diagbox" gd 0c
echo         2^) No
"%~dp0BAT\Diagbox" gd 07
echo\
CHOICE /C 12 /M "Select Option:"

IF %ERRORLEVEL%==1 set @pfs_popvmc=yes
IF %ERRORLEVEL%==2 set @pfs_popvmc=no

"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Estimating File Size:
echo ----------------------------------------------------
echo\
"%~dp0BAT\Diagbox" gd 07

REM APPS INFO SIZE
IF %@pfs_apps%==yes (
IF /I EXIST "%~dp0APPS\*" (
"%~dp0BAT\busybox" ls -1 "%~dp0APPS" | "%~dp0BAT\busybox" wc -l > "%~dp0TMP\APPSFiles.txt" & set /P @APP_Files=<"%~dp0TMP\APPSFiles.txt"
"%~dp0BAT\busybox" du -csh "%~dp0APPS" | "%~dp0BAT\busybox" grep -e "total" | "%~dp0BAT\busybox" sed -e "s/total//g; s/K/KB/g; s/M/MB/g; s/G/GB/g" > "%~dp0TMP\APPSSize.txt" & set /P @APP_Size=<"%~dp0TMP\APPSSize.txt"
set APP_Path="%~dp0APPS"
 )
)

REM ART INFO SIZE
IF %@pfs_art%==yes (
IF /I EXIST "%~dp0ART\*" (
"%~dp0BAT\busybox" ls -1 "%~dp0ART" | "%~dp0BAT\busybox" wc -l > "%~dp0TMP\ARTFiles.txt" & set /P @ART_Files=<"%~dp0TMP\ARTFiles.txt"
"%~dp0BAT\busybox" du -csh "%~dp0ART" | "%~dp0BAT\busybox" grep -e "total" | "%~dp0BAT\busybox" sed -e "s/total//g; s/K/KB/g; s/M/MB/g; s/G/GB/g" > "%~dp0TMP\ARTSize.txt" & set /P @ART_Size=<"%~dp0TMP\ARTSize.txt"
set ART_Path="%~dp0ART"
 )
)

REM CFG INFO SIZE
IF %@pfs_cfg%==yes (
IF /I EXIST "%~dp0CFG\*" (
"%~dp0BAT\busybox" ls -1 "%~dp0CFG" | "%~dp0BAT\busybox" wc -l > "%~dp0TMP\CFGFiles.txt" & set /P @CFG_Files=<"%~dp0TMP\CFGFiles.txt"
"%~dp0BAT\busybox" du -csh "%~dp0CFG" | "%~dp0BAT\busybox" grep -e "total" | "%~dp0BAT\busybox" sed -e "s/total//g; s/K/KB/g; s/M/MB/g; s/G/GB/g" > "%~dp0TMP\CFGSize.txt" & set /P @CFG_Size=<"%~dp0TMP\CFGSize.txt"
set CFG_Path="%~dp0CFG"
 )
)

REM CHT INFO SIZE
IF %@pfs_cht%==yes (
IF /I EXIST "%~dp0CHT\*" (
"%~dp0BAT\busybox" ls -1 "%~dp0CHT" | "%~dp0BAT\busybox" wc -l > "%~dp0TMP\CHTFiles.txt" & set /P @CHT_Files=<"%~dp0TMP\CHTFiles.txt"
"%~dp0BAT\busybox" du -csh "%~dp0CHT" | "%~dp0BAT\busybox" grep -e "total" | "%~dp0BAT\busybox" sed -e "s/total//g; s/K/KB/g; s/M/MB/g; s/G/GB/g" > "%~dp0TMP\CHTSize.txt" & set /P @CHT_Size=<"%~dp0TMP\CHTSize.txt"
set CHT_Path="%~dp0CHT"
 )
)

REM LNG INFO SIZE
IF %@pfs_LNG%==yes (
IF /I EXIST "%~dp0LNG\*" (
"%~dp0BAT\busybox" ls -1 "%~dp0LNG" | "%~dp0BAT\busybox" wc -l > "%~dp0TMP\LNGFiles.txt" & set /P @LNG_Files=<"%~dp0TMP\LNGFiles.txt"
"%~dp0BAT\busybox" du -csh "%~dp0LNG" | "%~dp0BAT\busybox" grep -e "total" | "%~dp0BAT\busybox" sed -e "s/total//g; s/K/KB/g; s/M/MB/g; s/G/GB/g" > "%~dp0TMP\LNGSize.txt" & set /P @LNG_Size=<"%~dp0TMP\LNGSize.txt"
set LNG_Path="%~dp0LNG"
 )
)

REM THM INFO SIZE
IF %@pfs_thm%==yes (
IF /I EXIST "%~dp0THM\*" (
"%~dp0BAT\busybox" ls -1 "%~dp0THM" | "%~dp0BAT\busybox" wc -l > "%~dp0TMP\THMFiles.txt" & set /P @THM_Files=<"%~dp0TMP\THMFiles.txt"
"%~dp0BAT\busybox" du -csh "%~dp0THM" | "%~dp0BAT\busybox" grep -e "total" | "%~dp0BAT\busybox" sed -e "s/total//g; s/K/KB/g; s/M/MB/g; s/G/GB/g" > "%~dp0TMP\THMSize.txt" & set /P @THM_Size=<"%~dp0TMP\THMSize.txt"
set THM_Path="%~dp0THM"
 )
)

REM VMC INFO SIZE
IF %@pfs_vmc%==yes (
IF /I EXIST "%~dp0VMC\*" (
"%~dp0BAT\busybox" ls -1 "%~dp0VMC" | "%~dp0BAT\busybox" wc -l > "%~dp0TMP\VMCFiles.txt" & set /P @VMC_Files=<"%~dp0TMP\VMCFiles.txt"
"%~dp0BAT\busybox" du -csh "%~dp0VMC" | "%~dp0BAT\busybox" grep -e "total" | "%~dp0BAT\busybox" sed -e "s/total//g; s/K/KB/g; s/M/MB/g; s/G/GB/g" > "%~dp0TMP\VMCSize.txt" & set /P @VMC_Size=<"%~dp0TMP\VMCSize.txt"
set VMC_Path="%~dp0VMC"
 )
)

REM POPS-VMC INFO SIZE
REM IF %@pfs_popvmc%==yes (
REM IF /I EXIST %~dp0POPS\VMC\* (
REM "%~dp0BAT\busybox" ls -1 "%~dp0POPS\VMC" | "%~dp0BAT\busybox" wc -l > "%~dp0TMP\POPSVMCFiles.txt" & set /P @POPSVMC_Files=<"%~dp0TMP\POPSVMCFiles.txt"
REM "%~dp0BAT\busybox" du -bch "%~dp0POPS\VMC" | "%~dp0BAT\busybox" grep -e "total" | "%~dp0BAT\busybox" sed -e "s/total//g; s/K/KB/g; s/M/MB/g; s/G/GB/g" > "%~dp0TMP\POPSVMCSize.txt" & set /P @POPSVMC_Size=<"%~dp0TMP\POPSVMCSize.txt"
REM set POPSVMC_Path="%~dp0POPS\VMC"
REM  )
REM )

REM TOTAL INFO
"%~dp0BAT\busybox" du -bch !APP_Path! !ART_Path! !CFG_Path! !CHT_Path! !THM_Path! !VMC_Path! !POPSVMC_Path! : 2>&1 | "%~dp0BAT\busybox" grep -e "total" | "%~dp0BAT\busybox" sed -e "s/total//g; s/K/KB/g; s/M/MB/g; s/G/GB/g" > "%~dp0TMP\TotalSIZE.txt" & set /P @Total_Size=<"%~dp0TMP\TotalSIZE.txt"
set /a "@Total_Files=%@APP_Files%+%@ART_Files%+%@CFG_Files%+%@CHT_Files%+%@LNG_Files%+%@THM_Files%+%@VMC_Files%+%@POPSVMC_Files%+0"

if defined APP_Path echo         APP - Files: %@APP_Files% - Size: %@APP_Size%
if defined ART_Path echo         ART - Files: %@ART_Files% - Size: %@ART_Size%
if defined CFG_Path echo         CFG - Files: %@CFG_Files% - Size: %@CFG_Size%
if defined CHT_Path echo         CHT - Files: %@CHT_Files% - Size: %@CHT_Size%
if defined LNG_Path echo         LNG - Files: %@LNG_Files% - Size: %@LNG_Size%
if defined THM_Path echo         THM - Files: %@THM_Files% - Size: %@THM_Size%
if defined VMC_Path echo         VMC - Files: %@VMC_Files% - Size: %@VMC_Size%
REM if defined POPSVMC_Path echo POPS-VMC - Files: %@POPSVMC_Files% POPS-VMC - Size: %@POPSVMC_Size%
echo\
echo\
echo         TOTAL - Files: !@Total_Files! 
echo         TOTAL - Size: !@Total_Size!

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Change default +OPL partition?
echo ----------------------------------------------------
echo\
echo Choose the partition where you want to transfer the files
echo By default it will be the partition: +OPL
echo\
CHOICE /C YN /M "Change the default partition?:"

IF %ERRORLEVEL%==1 set CHOICEPP=yes
IF %ERRORLEVEL%==2 set OPLPART=+OPL

if defined CHOICEPP (
echo\
echo 1. [+OPL]
echo 2. [__common]
echo 3. Custom Partition
echo\
CHOICE /C 123 /M "Select Option:"

IF ERRORLEVEL 1 set OPLPART=+OPL
IF ERRORLEVEL 2 set CUSTOM_OPLPART=yes & set OPLPART=__common
IF ERRORLEVEL 3 ( set CUSTOM_OPLPART=yes
echo\
set "OPLPART="
set /p OPLPART="Enter the partition name:"
IF "!OPLPART!"=="" set OPLPART=+OPL
 )
)

"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Detecting Partition: %OPLPART%
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0f

	"%~dp0BAT\busybox" grep -ow "%OPLPART%" "%~dp0BAT\__Cache\PARTITION_PS2HDD.txt" > "%~dp0TMP\hdd-prt.txt"
	
	set /P @hdd_avl=<"%~dp0TMP\hdd-prt.txt"
	IF "!@hdd_avl!"=="%OPLPART%" (
	"%~dp0BAT\Diagbox" gd 0a
	echo         %OPLPART% - Partition Detected
	"%~dp0BAT\Diagbox" gd 07
	) else (
	"%~dp0BAT\Diagbox" gd 0c
	echo         %OPLPART% - Partition NOT Detected
	echo         Partition Must Be Formatted Or Created
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
setlocal DisableDelayedExpansion

REM OPL APPS
IF %@pfs_apps%==yes (
echo\
echo\
echo Installing Applications [APPS]
echo ----------------------------------------------------
echo\

IF /I EXIST "%~dp0APPS\*" (
	cd "%~dp0APPS"
	echo         Creating Que

	REM MOUNT OPL
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
	
	REM UNMOUNT +OPL
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
echo ----------------------------------------------------
echo\

IF /I EXIST "%~dp0ART\*.*" (

	cd /d "%~dp0ART" & for %%F in ( "*.*" ) do if %%~zF==0 del "%%F"
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
echo ----------------------------------------------------
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
echo ----------------------------------------------------
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
echo ----------------------------------------------------
echo\

IF /I EXIST "%~dp0LNG\*.*" (

	cd "%~dp0LNG"
	echo         Creating Que
	echo device %@pfsshell_path% > "%~dp0TMP\pfs-LNG.txt"
	echo mount %OPLPART% >> "%~dp0TMP\pfs-LNG.txt"
    if defined CUSTOM_OPLPART echo mkdir OPL >> "%~dp0TMP\pfs-LNG.txt"
    if defined CUSTOM_OPLPART echo cd OPL >> "%~dp0TMP\pfs-LNG.txt"
	echo mkdir LNG >> "%~dp0TMP\pfs-LNG.txt"
	echo cd LNG >> "%~dp0TMP\pfs-LNG.txt"
	for %%f in (*.LNG *.TTF) do (echo put "%%f") >> "%~dp0TMP\pfs-LNG.txt"
	echo ls -l >> "%~dp0TMP\pfs-LNG.txt"
	echo umount >> "%~dp0TMP\pfs-LNG.txt"
	echo exit >> "%~dp0TMP\pfs-LNG.txt"
	
	echo         Installing Que
	type "%~dp0TMP\pfs-LNG.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" grep -ie ".*\.LNG$" > "%~dp0LOG\PFS-LNG.log"
	echo         LNG Completed...
	) else ( echo         LNG - Source Not Detected... )
)

REM OPL VMC
IF %@pfs_vmc%==yes (
echo\
echo\
echo Installing Virtual Memory Card: [VMC]
echo ----------------------------------------------------
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
echo ----------------------------------------------------
echo\

IF /I EXIST "%~dp0THM\*" (

	cd "%~dp0THM"
	echo         Creating Que

	REM MOUNT OPL

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
	
	REM UNMOUNT OPL
	echo ls -l >> "%~dp0TMP\pfs-thm.txt"
	echo umount >> "%~dp0TMP\pfs-thm.txt"
	echo exit >> "%~dp0TMP\pfs-thm.txt"

	echo         Installing Que
	type "%~dp0TMP\pfs-thm.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" grep -i -e "drwx" | "%~dp0BAT\busybox" sed -e "1,2d" > "%~dp0LOG\PFS-THM.log"
	echo         THM Completed...	
	) else ( echo         THM - Source Not Detected... )
)

IF %@pfs_popvmc%==yes (
echo\
echo\
echo Installing POPS-VMC:
echo ----------------------------------------------------
echo\

IF /I EXIST "%~dp0POPS\VMC\*" (

	cd "%~dp0POPS\VMC"
	echo         Creating Que

	REM MOUNT __common

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
	echo         POPS-VMC Completed...	
	) else ( echo         POPS-VMC - Source Not Detected... )
)

if defined CUSTOM_OPLPART (

    "%~dp0BAT\busybox" sed -i -e "s/\hdd_partition=.*/hdd_partition=/g; s/hdd_partition=/hdd_partition=%OPLPART%/g" "%~dp0HDD-OSD\__common\OPL\conf_hdd.cfg"
	cd "%~dp0HDD-OSD\__common\OPL"
    echo device %@pfsshell_path% > "%~dp0TMP\pfs-OPLCONFIG.txt"
	echo mount __common >> "%~dp0TMP\pfs-OPLCONFIG.txt"
	echo mkdir OPL >> "%~dp0TMP\pfs-OPLCONFIG.txt"
	echo cd OPL >> "%~dp0TMP\pfs-OPLCONFIG.txt"
	echo rm conf_hdd.cfg >> "%~dp0TMP\pfs-OPLCONFIG.txt"
 	echo put conf_hdd.cfg >> "%~dp0TMP\pfs-OPLCONFIG.txt"
    echo umount >> "%~dp0TMP\pfs-OPLCONFIG.txt"
	echo exit >> "%~dp0TMP\pfs-OPLCONFIG.txt"
	type "%~dp0TMP\pfs-OPLCONFIG.txt" | "%~dp0BAT\pfsshell" >nul 2>&1
	"%~dp0BAT\busybox" sed -i -e "s/\hdd_partition=.*/hdd_partition=/g; s/hdd_partition=/hdd_partition=+OPL/g" "%~dp0HDD-OSD\__common\OPL\conf_hdd.cfg"
)

cd "%~dp0" & rmdir /Q/S "%~dp0TMP" >nul 2>&1

echo\
echo\
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo Installations Completed...
echo\
echo\
"%~dp0BAT\Diagbox" gd 07

endlocal
pause & (goto mainmenu)

REM ########################################################################################################################################################################
:TransferPS1Games

cd "%~dp0"
cls
mkdir "%~dp0TMP" >nul 2>&1

IF NOT DEFINED @hdl_path ( rmdir /Q/S "%~dp0TMP" >nul 2>&1 & goto ScanningPS2HDD ) else (
"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning for Playstation 2 HDDs:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "!@hdl_path!" | "%~dp0BAT\busybox" grep "Playstation 2 HDD" >nul
if errorlevel 1 set "@hdl_path=" & goto ScanningPS2HDD
echo       [!@hdl_path! !@TotalHDD_Size! - !@ModelePS2HDD!]
)

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Install PS1 Games:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1^) Yes
"%~dp0BAT\Diagbox" gd 0c
echo         2^) No
"%~dp0BAT\Diagbox" gd 0e
echo         3^) Yes (Install .VCD as partition for HDD-OSD, PSBBN, XMB Menu)
echo\
"%~dp0BAT\Diagbox" gd 07
CHOICE /C 123 /M "Select Option:"

IF %ERRORLEVEL%==1 set @pfs_pop=yes & set "choice=" & set popspartinstall=__.POPS
IF %ERRORLEVEL%==2 (goto mainmenu)
IF %ERRORLEVEL%==3 set @pfs_popHDDOSDMAIN=yes & (goto TransferPS1GamesHDDOSD)

"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Estimating File Size:
echo ----------------------------------------------------
echo\
"%~dp0BAT\Diagbox" gd 07

IF /I EXIST "%~dp0POPS\*.VCD" (

"%~dp0BAT\busybox" ls -1 "%~dp0POPS\*.VCD" | "%~dp0BAT\busybox" wc -l > "%~dp0TMP\POPSFiles.txt" & set /P @POPS_Files=<"%~dp0TMP\POPSFiles.txt"
"%~dp0BAT\busybox" du -bch "%~dp0POPS\*.VCD" | "%~dp0BAT\busybox" grep -e "total" | "%~dp0BAT\busybox" sed -e "s/total//g; s/K/KB/g; s/M/MB/g; s/G/GB/g" > "%~dp0TMP\POPSSize.txt" & set /P @POPS_Size=<"%~dp0TMP\POPSSize.txt"

echo         VCD - Files: !@POPS_Files! - Size: !@POPS_Size!
echo\

echo         TOTAL - Files: !@POPS_Files!
echo         TOTAL - Size: !@POPS_Size!

) else ( echo          .VCD - NOT DETECTED IN POPS FOLDER & echo\ & echo\ & pause & goto mainmenu )

"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Detecting POPS Partition:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0f

    "%~dp0BAT\busybox" grep -o "__.POPS\|__.POPS[0-9]" "%~dp0BAT\__Cache\PARTITION_PS2HDD.txt" | "%~dp0BAT\busybox" sed "s/__.POPS\([0-9]\)/\1.  __.POPS\1/g; s/\__.POPS\b/10. __.POPS/" | "%~dp0BAT\busybox" sort -k2 > "%~dp0TMP\hdd-prt.txt"
    "%~dp0BAT\busybox" sed -e "/^$/d" "%~dp0TMP\hdd-prt.txt" | "%~dp0BAT\busybox" wc -l > "%~dp0TMP\TotalPOPSPart.txt" & set /P @TotalPOPSPart=<"%~dp0TMP\TotalPOPSPart.txt"
    
    if !@TotalPOPSPart! gtr 1 (
	echo.
    echo Multiple POPS partitions were detected. Please choose one.
	echo Choose the partition on which you want to install your .VCDs
    echo In general, the default partition is __.POPS
    echo.
    type "%~dp0TMP\hdd-prt.txt"
    echo.
	
    set choice=
    set /p choice="Select Option:"
    IF "!choice!"=="" (goto TransferPS1Games)
    
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
	echo        Partition Must Be Formatted Or Created
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

    if exist "%~dp0POPS-Binaries\Hugopocked_POPStarter_Fixes.zip" "%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0POPS-Binaries\Hugopocked_POPStarter_Fixes.zip" -o"%~dp0TMP" id.txt -r -y
    setlocal DisableDelayedExpansion
	cd "%~dp0POPS" & rename "*.vcd" "*.VCD"
	for %%f in (*.VCD) do (
	
	set "cheats="
	set fname=%%~nf
	for %%x in (TROJAN_?.BIN PATCH_?.BIN CHEATS.TXT Readme.txt) do del "%%x" >nul 2>&1 
	
echo\
echo\
echo Installing "%%f":
echo ----------------------------------------------------
echo\

	REM echo         Creating Que
	echo device %@pfsshell_path% > "%~dp0TMP\pfs-pops.txt"
	echo mount %POPSPART% >> "%~dp0TMP\pfs-pops.txt"
	
	setlocal EnableDelayedExpansion
	"%~dp0BAT\POPS-VCD-ID-Extractor" "!fname!.VCD" 2>&1 | "%~dp0BAT\busybox" sed -e "s/-/_/g" > "%~dp0TMP\VCDID.txt" & set /p VCDID=<"%~dp0TMP\VCDID.txt"
	
	set "ELFNOTFOUND="
    "%~dp0BAT\busybox" grep -o -m 1 "regex couldn't find" "%~dp0TMP\VCDID.txt" > "%~dp0TMP\ELFNOTFOUND.TXT" & set /p ELFNOTFOUND=<"%~dp0TMP\ELFNOTFOUND.TXT"
    if defined ELFNOTFOUND (
	"%~dp0BAT\busybox" grep -o -m 1 "SLPS-02414" "!fname!.VCD" | "%~dp0BAT\busybox" sed "s/-/_/g" | "%~dp0BAT\busybox" sed "s/.\{8\}/&./" | "%~dp0BAT\busybox" head -1 >> "%~dp0TMP\VCDID.txt" & "%~dp0BAT\busybox" sed -i "/regex couldn't find/d" "%~dp0TMP\VCDID.txt" & set /p VCDID=<"%~dp0TMP\VCDID.txt"
	"%~dp0BAT\busybox" grep -o -m 1 "SLUSP013.46" "!fname!.VCD" | "%~dp0BAT\busybox" sed "s/-/_/g; s/SLUSP013\.46/SLUS_01346/g" | "%~dp0BAT\busybox" sed "s/.\{8\}/&./" | "%~dp0BAT\busybox" head -1 >> VCDID.txt & "%~dp0BAT\busybox" sed -i "/regex couldn't find/d" VCDID.txt & set /p VCDID=<"%~dp0TMP\VCDID.txt"
	)
	
	REM echo         Checking if the game has a need patch GameShark...
	findstr !VCDID! "%~dp0TMP\id.txt" >nul 2>&1
    if errorlevel 1 (
    REM echo         No need patch
    ) else (
	REM echo         Patch GameShark...
	set cheats=yes
	"%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0POPS-Binaries\Hugopocked_POPStarter_Fixes.zip" -o"%~dp0TMP" !VCDID!\* -r -y >nul 2>&1
	"%~dp0BAT\busybox" md5sum "!fname!.VCD" | "%~dp0BAT\busybox" grep -o "[0-9a-f]\{32\}" > "%~dp0TMP\MD5.txt" & set /p MD5=<"%~dp0TMP\MD5.txt"
	"%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0POPS-Binaries\Hugopocked_POPStarter_Fixes.zip" -o"%~dp0TMP" !VCDID!\!MD5!\* -r -y & move "%~dp0TMP\!VCDID!\!MD5!\*" "%~dp0TMP\!VCDID!" >nul 2>&1
	cd /d "%~dp0TMP\!VCDID!" & for %%x in (TROJAN_?.BIN PATCH_?.BIN CHEATS.TXT Readme.txt) do move "%%x" "%~dp0POPS" >nul 2>&1
	)

	echo         Installing...
	cd /d "%~dp0POPS"
	echo put "!fname!.VCD" >> "%~dp0TMP\pfs-pops.txt"
	echo ls -l >> "%~dp0TMP\pfs-pops.txt"
	echo umount >> "%~dp0TMP\pfs-pops.txt"

	if defined cheats echo         Patch GameShark...
	echo mount __common >> "%~dp0TMP\pfs-pops.txt"
	echo mkdir POPS >> "%~dp0TMP\pfs-pops.txt"
	echo cd POPS >> "%~dp0TMP\pfs-pops.txt"
	echo mkdir "!fname!" >> "%~dp0TMP\pfs-pops.txt"
	echo cd "!fname!" >> "%~dp0TMP\pfs-pops.txt"
	if defined cheats for %%x in (TROJAN_?.BIN PATCH_?.BIN CHEATS.TXT Readme.txt) do echo put "%%x" >> "%~dp0TMP\pfs-pops.txt"

	echo umount >> "%~dp0TMP\pfs-pops.txt"
	echo exit >> "%~dp0TMP\pfs-pops.txt"
	type "%~dp0TMP\pfs-pops.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" grep -ie ".*\.VCD$" > "%~dp0LOG\PFS-POPS%choice%.log"
	
	echo         Completed...
    cd "%~dp0"
    endlocal
    )
	
cd "%~dp0POPS" & for %%x in (TROJAN_?.BIN PATCH_?.BIN CHEATS.TXT Readme.txt) do del "%%x" >nul 2>&1
cd "%~dp0" & rmdir /Q/S "%~dp0TMP" >nul 2>&1

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo Installation Completed...
echo\
echo\
"%~dp0BAT\Diagbox" gd 07

endlocal
pause & (goto mainmenu)
REM ########################################################################################################################################################################
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
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "!@hdl_path!" | "%~dp0BAT\busybox" grep "Playstation 2 HDD" >nul
if errorlevel 1 set "@hdl_path=" & goto ScanningPS2HDD
echo       [!@hdl_path! !@TotalHDD_Size! - !@ModelePS2HDD!]
)

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Extract Artwork: [ART]
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1^) Yes
"%~dp0BAT\Diagbox" gd 0c
echo         2^) No
"%~dp0BAT\Diagbox" gd 07
echo\
CHOICE /C 12 /M "Select Option:"

IF %ERRORLEVEL%==1 set "@pfs_art=yes" & set "EType=ART" & echo ART>"%~dp0TMP\pfs-choice.log"
IF %ERRORLEVEL%==2 set "@pfs_art=no"

echo\
echo\
echo Extract Configs: [CFG]
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1^) Yes
"%~dp0BAT\Diagbox" gd 0c
echo         2^) No
"%~dp0BAT\Diagbox" gd 07
echo\
CHOICE /C 12 /M "Select Option:"

IF %ERRORLEVEL%==1 set "@pfs_cfg=yes" & set "EType=CFG" & echo CFG>>"%~dp0TMP\pfs-choice.log"
IF %ERRORLEVEL%==2 set @pfs_cfg=no

echo\
echo\
echo Extract Cheats: [CFG]
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1^) Yes
"%~dp0BAT\Diagbox" gd 0c
echo         2^) No
"%~dp0BAT\Diagbox" gd 07
echo\
CHOICE /C 12 /M "Select Option:"

IF %ERRORLEVEL%==1 set "@pfs_cht=yes" & set "EType=CHT" & echo CHT>>"%~dp0TMP\pfs-choice.log"
IF %ERRORLEVEL%==2 set @pfs_cht=no

echo\
echo\
echo Extract OPL VMCs: [VMC]
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1^) Yes
"%~dp0BAT\Diagbox" gd 0c
echo         2^) No
"%~dp0BAT\Diagbox" gd 07
echo\
CHOICE /C 12 /M "Select Option:"

IF %ERRORLEVEL%==1 set "pfs_vmc=yes" & set "EType=VMC" & echo VMC>>"%~dp0TMP\pfs-choice.log"
IF %ERRORLEVEL%==2 set @pfs_vmc=no

echo\
echo\
echo Extract POPS VMCs:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1^) Yes
"%~dp0BAT\Diagbox" gd 0c
echo         2^) No
echo\
"%~dp0BAT\Diagbox" gd 07
CHOICE /C 12 /M "Select Option:"

IF %ERRORLEVEL%==1 set @pfs_popvmc=yes
IF %ERRORLEVEL%==2 set @pfs_popvmc=no

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Change default +OPL partition?
echo ----------------------------------------------------
echo\
echo Choose the partition where your OPL files are located
echo By default it will be the partition: +OPL
echo\
CHOICE /C YN /M "Change the default partition?:"

IF %ERRORLEVEL%==1 set CHOICEPP=yes
IF %ERRORLEVEL%==2 set OPLPART=+OPL

if defined CHOICEPP (
echo\
echo 1. [+OPL]
echo 2. [__common]
echo 3. Select partition manually
echo\
CHOICE /C 123 /M "Select Option:"

IF ERRORLEVEL 1 set OPLPART=+OPL
IF ERRORLEVEL 2 set CUSTOM_OPLPART=yes & set OPLPART=__common
IF ERRORLEVEL 3 ( set CUSTOM_OPLPART=yes
echo\
set "OPLPART="
set /p OPLPART="Enter the partition name:"
IF "!OPLPART!"=="" set OPLPART=+OPL
 )
)

"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Detecting %OPLPART% Partition:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0f

	"%~dp0BAT\busybox" grep -ow "%OPLPART%" "%~dp0BAT\__Cache\PARTITION_PS2HDD.txt" > "%~dp0TMP\hdd-prt.txt"
	
	set /P @hdd_avl=<"%~dp0TMP\hdd-prt.txt"
	IF "!@hdd_avl!"=="%OPLPART%" (
	"%~dp0BAT\Diagbox" gd 0a
		echo         %OPLPART% - Partition Detected
		"%~dp0BAT\Diagbox" gd 07
		) else (
		"%~dp0BAT\Diagbox" gd 0c
		echo         %OPLPART% - Partition NOT Detected
		echo         Partition Must Be Formatted Or Created
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
cd /d "%~dp0TMP"

if not exist "%~dp0TMP\pfs-choice.log" type nul>"%~dp0TMP\pfs-choice.log"
for /f "usebackq tokens=*" %%f in ("%~dp0TMP\pfs-choice.log") do (

	setlocal DisableDelayedExpansion
	set EType=%%f
	setlocal EnableDelayedExpansion

echo\
echo\
echo Extraction !EType!:
echo ----------------------------------------------------
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

setlocal DisableDelayedExpansion
IF %@pfs_popvmc%==yes (
echo\
echo\
echo Extraction POPS Virtual Memory Card Files:
echo ----------------------------------------------------
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
	echo         Completed...
    )

cd /d "%~dp0" & rmdir /Q/S "%~dp0TMP" >nul 2>&1

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo Extraction Completed...
echo\
echo\
"%~dp0BAT\Diagbox" gd 07

endlocal
pause & (goto mainmenu)
REM ########################################################################################################################################################################
:BackupPS1Games
cls
mkdir "%~dp0TMP" >nul 2>&1
cd /d "%~dp0TMP"
set "POPSPART="

IF NOT DEFINED @hdl_path ( rmdir /Q/S "%~dp0TMP" >nul 2>&1 & goto ScanningPS2HDD ) else (
"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning for Playstation 2 HDDs:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "!@hdl_path!" | "%~dp0BAT\busybox" grep "Playstation 2 HDD" >nul
if errorlevel 1 set "@hdl_path=" & goto ScanningPS2HDD
echo       [!@hdl_path! !@TotalHDD_Size! - !@ModelePS2HDD!]
)

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Extract a PS1 game to VCD^?
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1^) Yes
"%~dp0BAT\Diagbox" gd 0c
echo         2^) No
"%~dp0BAT\Diagbox" gd 0e
echo         3^) Yes ^(Extract All Games from Partition^)
echo         4^) Yes ^(Extract All Games from PFS Partition^)
echo\
"%~dp0BAT\Diagbox" gd 07
CHOICE /C 12345 /M "Select Option:"

IF %ERRORLEVEL%==1 set "@pfs_popmanuallyVCD=yes"
IF %ERRORLEVEL%==2 (goto mainmenu)
IF %ERRORLEVEL%==3 set "@pfs_pop=yes"
IF %ERRORLEVEL%==4 (goto BackupPS1GamesPFSPart)


"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Detecting POPS Partition:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0f

    "%~dp0BAT\busybox" grep -o "__.POPS\|__.POPS[0-9]" "%~dp0BAT\__Cache\PARTITION_PS2HDD.txt" | "%~dp0BAT\busybox" sed "s/__.POPS\([0-9]\)/\1.  __.POPS\1/g; s/\__.POPS\b/10. __.POPS/" | "%~dp0BAT\busybox" sort -k2 > "%~dp0TMP\hdd-prt.txt"
    "%~dp0BAT\busybox" sed -e "/^$/d" "%~dp0TMP\hdd-prt.txt" | "%~dp0BAT\busybox" wc -l > "%~dp0TMP\TotalPOPSPart.txt" & set /P @TotalPOPSPart=<"%~dp0TMP\TotalPOPSPart.txt"
    
    if !@TotalPOPSPart! gtr 1 (
	echo.
    echo Multiple POPS partitions were detected. Please choose one.
    echo In general, the default partition is __.POPS
    echo.
    type "%~dp0TMP\hdd-prt.txt"
    echo.
	
    set choice=
    set /p choice="Select Option:"
    IF "!choice!"=="" (goto BackupPS1Games)
    
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
	echo        Partition Must Be Formatted Or Created
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

"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning Games List in !POPSPART!:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 07

    echo device !@pfsshell_path! > "%~dp0TMP\pfs-prt.txt"
	echo mount !POPSPART! >> "%~dp0TMP\pfs-prt.txt"
    echo ls >> "%~dp0TMP\pfs-prt.txt"
    echo exit >> "%~dp0TMP\pfs-prt.txt"
    type "%~dp0TMP\pfs-prt.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" grep -ie ".*\.VCD$" | "%~dp0BAT\busybox" sed -e "s/\.[^.]*$//" > "%~dp0TMP\!POPSPART!.txt" & type "%~dp0TMP\!POPSPART!.txt"
	
"%~dp0BAT\Diagbox" gd 0e
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 07

if !@pfs_popmanuallyVCD!==yes (
echo\
"%~dp0BAT\Diagbox" gd 06
echo Respect upper and lower case
"%~dp0BAT\Diagbox" gd 07
set /p NameVCD=Enter The Game Name:
IF "!NameVCD!"=="" set "@pfs_popmanuallyVCD=" & (goto BackupPS1Games)
"%~dp0BAT\busybox" sed -i -n "/!NameVCD!/p" "%~dp0TMP\!POPSPART!.txt"
)

setlocal DisableDelayedExpansion
for /f "tokens=*" %%f in (%POPSPART%.txt) do (
echo\
echo\
echo Extraction %%f
echo ----------------------------------------------------
echo\
    
	echo         Extraction...
	echo device %@pfsshell_path% > "%~dp0TMP\pfs-pops.txt"
	echo mount %POPSPART% >> "%~dp0TMP\pfs-pops.txt"
	echo lcd "%~dp0POPS" >> "%~dp0TMP\pfs-pops.txt"
	echo rename "%%f.vcd" "%%f.VCD" >> "%~dp0TMP\pfs-pops.txt"
	echo get "%%f.VCD" >> "%~dp0TMP\pfs-pops.txt"
	echo umount >> "%~dp0TMP\pfs-pops.txt"
	echo exit >> "%~dp0TMP\pfs-pops.txt"
	type "%~dp0TMP\pfs-pops.txt" | "%~dp0BAT\pfsshell" >nul 2>&1
    echo         Completed...
    )
	
cd /d "%~dp0" & rmdir /Q/S "%~dp0TMP" >nul 2>&1

echo\
echo\
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo Completed...
echo\
echo\
"%~dp0BAT\Diagbox" gd 07

endlocal
pause & (goto mainmenu)
REM ########################################################################################################################################################################
:BackupPS1GamesPFSPart

cls
mkdir "%~dp0TMP" >nul 2>&1
cd /d "%~dp0TMP"

copy "%~dp0BAT\TitlesDB\TitlesDB_PS1_English.txt" "%~dp0TMP\gameid.txt" >nul 2>&1
"%~dp0BAT\busybox" sed -i "s/\^!/\!/g" "%~dp0TMP\gameid.txt" >nul 2>&1

IF NOT DEFINED @hdl_path ( rmdir /Q/S "%~dp0TMP" >nul 2>&1 & goto ScanningPS2HDD ) else (
"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning for Playstation 2 HDDs:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "!@hdl_path!" | "%~dp0BAT\busybox" grep "Playstation 2 HDD" >nul
if errorlevel 1 set "@hdl_path=" & goto ScanningPS2HDD
echo       [!@hdl_path! !@TotalHDD_Size! - !@ModelePS2HDD!]
)

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Scanning Partitions PS1 Games:
echo ----------------------------------------------------
	"%~dp0BAT\busybox" grep -e "\.POPS\." "%~dp0BAT\__Cache\PARTITION_PS2HDD.txt" | "%~dp0BAT\busybox" sed "s/.\{48\}/& /" | "%~dp0BAT\busybox" sort -k6 | "%~dp0BAT\busybox" sed -e "s/\(.\{48\}\)./\1/" | "%~dp0BAT\busybox" cut -c30-100 > "%~dp0TMP\PARTITION_PS1_GAMES.txt"
	type "%~dp0TMP\PARTITION_PS1_GAMES.txt"
echo ----------------------------------------------------

for /f "tokens=*" %%p in (PARTITION_PS1_GAMES.txt) do (
echo\
echo\
echo Extraction of VCD from %%p
echo ----------------------------------------------------
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
	type "%~dp0TMP\pfs-log.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" grep -ie ".*\.VCD$" > "%~dp0TMP\pfs-tmp.log"
    
	For %%V in ( "%~dp0TMP\*.VCD" ) do ("%~dp0BAT\POPS-VCD-ID-Extractor" "%%V" 2>&1 > "%~dp0TMP\VCDID.txt" & set /P gameid=<"%~dp0TMP\VCDID.txt"
	
	set "ELFNOTFOUND="
    "%~dp0BAT\busybox" grep -o -m 1 "regex couldn't find" "%~dp0TMP\VCDID.txt" >"%~dp0TMP\ELFNOTFOUND.TXT" & set /p ELFNOTFOUND=<"%~dp0TMP\ELFNOTFOUND.TXT"
    if defined ELFNOTFOUND (
	"%~dp0BAT\busybox" grep -o -m 1 "SLPS-02414" "%%V" | "%~dp0BAT\busybox" sed "s/-/_/g" | "%~dp0BAT\busybox" sed "s/.\{8\}/&./" | "%~dp0BAT\busybox" head -1 >> "%~dp0TMP\VCDID.txt" & "%~dp0BAT\busybox" sed -i "/regex couldn't find/d" "%~dp0TMP\VCDID.txt" & set /p gameid=<"%~dp0TMP\VCDID.txt"
	"%~dp0BAT\busybox" grep -o -m 1 "SLUSP013.46" "%%V" | "%~dp0BAT\busybox" sed "s/-/_/g; s/SLUSP013\.46/SLUS_01346/g" | "%~dp0BAT\busybox" sed "s/.\{8\}/&./" | "%~dp0BAT\busybox" head -1 >> VCDID.txt & "%~dp0BAT\busybox" sed -i "/regex couldn't find/d" VCDID.txt & set /p gameid=<"%~dp0TMP\VCDID.txt"
	)
	
	findstr !gameid! "%~dp0TMP\gameid.txt" >nul
    if errorlevel 1 (move "%%V" "%~dp0POPS\!gameid!.VCD" >nul 2>&1) else (
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
echo ----------------------------------------------------
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
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "!@hdl_path!" | "%~dp0BAT\busybox" grep "Playstation 2 HDD" >nul
if errorlevel 1 set "@hdl_path=" & goto ScanningPS2HDD
echo       [!@hdl_path! !@TotalHDD_Size! - !@ModelePS2HDD!]
)

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Transfer POPS Binaries:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1^) Yes
"%~dp0BAT\Diagbox" gd 0c
echo         2^) No
"%~dp0BAT\Diagbox" gd 07
echo\
CHOICE /C 12 /M "Select Option:"

IF %ERRORLEVEL%==1 set @pfs_pops=yes
IF %ERRORLEVEL%==2 (goto mainmenu)

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo\
echo POPS Binaries MD5 CHECKING:
echo ----------------------------------------------------

ren "%~dp0POPS-Binaries\POPS.ELF.ELF" POPS.ELF >nul 2>&1
ren "%~dp0POPS-Binaries\IOPRP252.IMG.IMG" IOPRP252.IMG >nul 2>&1

IF /I EXIST "%~dp0POPS-Binaries\POPS.ELF" (

    "%~dp0BAT\busybox" md5sum "%~dp0POPS-Binaries\POPS.ELF" | "%~dp0BAT\busybox" grep -o "[0-9a-f]\{32\}" > "%~dp0TMP\MD5.txt" & set /p MD5=<"%~dp0TMP\MD5.txt"
    if !MD5! equ 355a892a8ce4e4a105469d4ef6f39a42 (
      "%~dp0BAT\Diagbox" gd 0a
       echo POPS.ELF     - MD5 Match : !md5!
       ) else ( "%~dp0BAT\Diagbox" gd 0c & echo POPS.ELF     MD5 NOT MATCH : !md5! & set POPSNotFound=yes)
       "%~dp0BAT\Diagbox" gd 0c
    ) else ("%~dp0BAT\Diagbox" gd 06 & echo POPS.ELF : Not detected & set POPSNotFound=yes)
    
IF /I EXIST "%~dp0POPS-Binaries\IOPRP252.IMG" (

    "%~dp0BAT\busybox" md5sum "%~dp0POPS-Binaries\IOPRP252.IMG" | "%~dp0BAT\busybox" grep -o "[0-9a-f]\{32\}" > "%~dp0TMP\MD5.txt" & set /p MD5=<"%~dp0TMP\MD5.txt"
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
    pause & (goto mainmenu)
    )

"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Detecting __common Partition:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0f

    "%~dp0BAT\busybox" grep -ow "__common" "%~dp0BAT\__Cache\PARTITION_PS2HDD.txt" > "%~dp0TMP\hdd-prt.txt"

	set /P @hdd_avl=<"%~dp0TMP\hdd-prt.txt"
    IF "!@hdd_avl!"=="__common" (
    "%~dp0BAT\Diagbox" gd 0a
	echo         __common - Partition Detected
	"%~dp0BAT\Diagbox" gd 07
	) else (
	"%~dp0BAT\Diagbox" gd 0c
	echo         __common - Partition NOT Detected
	echo         Partition Must Be Formatted Or Created
	echo\
	echo\
	"%~dp0BAT\Diagbox" gd 07
	rmdir /Q/S "%~dp0TMP" >nul 2>&1
	pause & (goto mainmenu)
	)

echo\
echo\
pause

IF %@pfs_pops%==yes (
"%~dp0BAT\Diagbox" gd 0f
cls
echo\
echo\
echo Installing POPS Binaries:
echo ----------------------------------------------------
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
echo ----------------------------------------------------
 "%~dp0BAT\Diagbox" gd 0a
echo Installation Completed...
echo\
echo\
"%~dp0BAT\Diagbox" gd 07

pause & (goto mainmenu)
REM ########################################################################################################################################################################
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
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "!@hdl_path!" | "%~dp0BAT\busybox" grep "Playstation 2 HDD" >nul
if errorlevel 1 set "@hdl_path=" & goto ScanningPS2HDD
echo       [!@hdl_path! !@TotalHDD_Size! - !@ModelePS2HDD!]
)

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Extract a PS2 game to iso^?
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1^) Yes
"%~dp0BAT\Diagbox" gd 0c
echo         2^) No
"%~dp0BAT\Diagbox" gd 0e
echo         3^) Yes ^(Extract all games^)
echo\
"%~dp0BAT\Diagbox" gd 07
echo\
CHOICE /C 123 /M "Select Option:"

IF %ERRORLEVEL%==1 set BackupPS2GamesManually=yes
IF %ERRORLEVEL%==2 (goto Mainmenu)
IF %ERRORLEVEL%==3 set BackupPS2AllGames=yes


"%~dp0BAT\Diagbox" gd 0e
cls
echo\
echo\
echo Scanning Games List:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
type "%~dp0BAT\__Cache\PARTITION_HDL_GAME.txt" | "%~dp0BAT\busybox" sed "s/|.*//" | "%~dp0BAT\busybox" sort -k2 > "%~dp0TMP\GameListPS2.txt" & type "%~dp0TMP\GameListPS2.txt"
"%~dp0BAT\Diagbox" gd 0e
echo ----------------------------------------------------
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
	) else ("%~dp0BAT\busybox" grep -F -m 1 "!gname!" "%~dp0BAT\__Cache\PARTITION_HDL_GAME.txt" > "%~dp0TMP\PARTITION_HDL_GAME.txt")
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

    "%~dp0BAT\hdl_dump.exe" extract %@hdl_path% "!pname!" "%~dp0CD-DVD\!GameName! - [!fname:~0,11!].iso"
	 endlocal
	endlocal
    )
	echo\
    echo\
    cd /d "%~dp0CD-DVD" & ren *. *.iso >nul 2>&1
	echo Extracted.. to CD-DVD\

REM    cd /d "%~dp0CD-DVD" 
REM    echo\
REM    echo\
REM    echo Checking zso...
REM    for %%z in (*.iso) do (
REM    
REM    setlocal DisableDelayedExpansion
REM 	set filename=%%z
REM    set fname=%%~nz
REM    setlocal EnableDelayedExpansion
REM 
REM    set "CheckZSO="
REM    "%~dp0BAT\busybox" grep -o -m 1 "ZISO" "!filename!" | "%~dp0BAT\busybox" head -n1 > "%~dp0TMP\CheckZSO.txt" & set /P CheckZSO=<"%~dp0TMP\CheckZSO.txt"
REM 
REM    if defined CheckZSO (
REM    echo\
REM    echo ZSO Detected!
REM    ren "!fname!.iso" "!fname!.zso" >nul 2>&1
REM    "%~dp0BAT\maxcso" --decompress "!fname!.zso" -o "!fname!.iso"
REM    del "!fname!.zso" >nul 2>&1
REM    )
REM 	endlocal
REM endlocal
REM   )

cd /d "%~dp0" & rmdir /Q/S "%~dp0TMP" >nul 2>&1

echo\
echo\
"%~dp0BAT\Diagbox" gd 0f
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo Extraction Completed...
echo\
echo\
"%~dp0BAT\Diagbox" gd 07

pause & (goto mainmenu)
REM ####################################################################################################################################################
:CreateDelPART
cls
mkdir "%~dp0TMP" >nul 2>&1

IF NOT DEFINED @hdl_path ( rmdir /Q/S "%~dp0TMP" >nul 2>&1 & goto ScanningPS2HDD ) else (
"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning for Playstation 2 HDDs:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "!@hdl_path!" | "%~dp0BAT\busybox" grep "Playstation 2 HDD" >nul
if errorlevel 1 set "@hdl_path=" & goto ScanningPS2HDD
echo       [!@hdl_path! !@TotalHDD_Size! - !@ModelePS2HDD!]
)

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo !Part_Option! a Partition:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1^) Yes
"%~dp0BAT\Diagbox" gd 0c
echo         2^) No
"%~dp0BAT\Diagbox" gd 0e
if !Part_Option!==Create echo         3^) POPS Example& set 3=3
"%~dp0BAT\Diagbox" gd 07
echo\
CHOICE /C 12!3! /M "Select Option:"

IF %ERRORLEVEL%==2 (goto HDDManagementMenu)
IF %ERRORLEVEL%==3 set POPSExample=Yes

if !Part_Option!==Delete (
cls
echo\
echo\
echo Scanning Partitions:
echo ----------------------------------------------------
type "%~dp0BAT\__Cache\PARTITION_PS2HDD.txt" | "%~dp0BAT\busybox" sed "/0x1337/d" | "%~dp0BAT\busybox" sed "$d"
echo ---------------------------------------------------
)

echo\
echo\
if !POPSExample!==Yes (
echo You can create up to 10 POPS partitions.
echo By default it will be the partition __.POPS
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
) else (echo Example: +OPL)

set /p "partname=Enter partition Name:" 
if "!partname!"=="" (goto HDDManagementMenu)

echo ----------------------------------------------------
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
IF "!partsize!"=="" (goto HDDManagementMenu)
set fstype=PFS
)

cls
echo\
echo\
echo !Part_Option2! !PartName! Partition:
echo ----------------------------------------------------
echo\

    echo        !Part_Option2! !PartName!
  	echo device %@pfsshell_path% > "%~dp0TMP\pfs-log.txt"
	echo !PFS_Option! "!PartName!" !partsize! !fstype! >> "%~dp0TMP\pfs-log.txt"
  	echo exit >> "%~dp0TMP\pfs-log.txt"
	type "%~dp0TMP\pfs-log.txt" | "%~dp0BAT\pfsshell" >nul 2>&1
	echo        Completed...

    REM Reloading HDD Cache
    call "%~dp0BAT\__ReloadHDD_cache.bat" >nul 2>&1

cd /d "%~dp0" & rmdir /Q/S "%~dp0TMP" >nul 2>&1

echo\
echo\
echo ----------------------------------------------------
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
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "!@hdl_path!" | "%~dp0BAT\busybox" grep "Playstation 2 HDD" >nul
if errorlevel 1 set "@hdl_path=" & goto ScanningPS2HDD
echo       [!@hdl_path! !@TotalHDD_Size! - !@ModelePS2HDD!]
)

echo\
echo\
"%~dp0BAT\Diagbox" gd 0f
echo Scanning Partitions !ShowPartitionList!:
echo ----------------------------------------------------

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

if "!ShowPartitionList!"=="Total Size" (

	 REM PS1 Calculs
	 "%~dp0BAT\busybox" grep -e "\.POPS\." "%~dp0BAT\__Cache\PARTITION_PS2HDD.txt" | "%~dp0BAT\busybox" cut -c23-26 > "%~dp0TMP\PS1GamesSize.txt"
	 type "%~dp0TMP\PS1GamesSize.txt" | "%~dp0BAT\busybox" sed -e "/^$/d" | "%~dp0BAT\busybox" wc -l > "%~dp0TMP\TotalPS1Games.txt" & set /P @TotalPS1Games=<"%~dp0TMP\TotalPS1Games.txt"
	
     for /f "usebackq" %%s in ("%~dp0TMP\PS1GamesSize.txt") do (set /a "TotalPS1Games_Size+=%%s")
     if !TotalPS1Games_Size! GTR 10 set "PS1MB=MB" & echo !TotalPS1Games_Size!| "%~dp0BAT\busybox" sed -e "s/ //g" > "%~dp0TMP\TotalPS1Games_Size.txt" & set /P @TotalPS1Games_Size=<"%~dp0TMP\TotalPS1Games_Size.txt"
     if !TotalPS1Games_Size! GTR 100 set "PS1MB=MB" & echo !TotalPS1Games_Size!| "%~dp0BAT\busybox" sed -e "s/ //g" > "%~dp0TMP\TotalPS1Games_Size.txt" & set /P @TotalPS1Games_Size=<"%~dp0TMP\TotalPS1Games_Size.txt"
     if !TotalPS1Games_Size! GTR 1000 set "PS1MB=GB" & echo !TotalPS1Games_Size!| "%~dp0BAT\busybox" sed -e "s/.\{1\}/&\./" > "%~dp0TMP\TotalPS1Games_Size.txt" & set /P @TotalPS1Games_Size=<"%~dp0TMP\TotalPS1Games_Size.txt"
     if !TotalPS1Games_Size! GTR 10000 set "PS1MB=GB" & echo !TotalPS1Games_Size!| "%~dp0BAT\busybox" sed -e "s/.\{2\}/&\./" > "%~dp0TMP\TotalPS1Games_Size.txt" & set /P @TotalPS1Games_Size=<"%~dp0TMP\TotalPS1Games_Size.txt"
     if !TotalPS1Games_Size! GTR 100000 set "PS1MB=GB" & echo !TotalPS1Games_Size!| "%~dp0BAT\busybox" sed -e "s/.\{3\}/&\./" > "%~dp0TMP\TotalPS1Games_Size.txt" & set /P @TotalPS1Games_Size=<"%~dp0TMP\TotalPS1Games_Size.txt"
     if !TotalPS1Games_Size! GTR 1000000 set "PS1MB=GB" & echo !TotalPS1Games_Size!| "%~dp0BAT\busybox" sed -e "s/.\{4\}/&\./" > "%~dp0TMP\TotalPS1Games_Size.txt" & set /P @TotalPS1Games_Size=<"%~dp0TMP\TotalPS1Games_Size.txt"
     if !TotalPS1Games_Size! GTR 10000000 set "PS1MB=GB" & echo !TotalPS1Games_Size!| "%~dp0BAT\busybox" sed -e "s/.\{5\}/&\./" > "%~dp0TMP\TotalPS1Games_Size.txt" & set /P @TotalPS1Games_Size=<"%~dp0TMP\TotalPS1Games_Size.txt"
	 if "!@TotalPS1Games_Size!"=="" set @TotalPS1Games_Size=0
	 if "!PS1MB!"=="" set "PS1MB=MB"
	 
	 REM PS2 Calculs
	 "%~dp0BAT\busybox" grep -e "0x1337" "%~dp0BAT\__Cache\PARTITION_PS2HDD.txt" | "%~dp0BAT\busybox" cut -c23-26 > "%~dp0TMP\PS2GamesSize.txt"
	 type "%~dp0TMP\PS2GamesSize.txt" | "%~dp0BAT\busybox" sed -e "/^$/d" | "%~dp0BAT\busybox" wc -l > "%~dp0TMP\TotalPS2Games.txt" & set /P @TotalPS2Games=<"%~dp0TMP\TotalPS2Games.txt"
	 
     for /f "usebackq" %%s in ("%~dp0TMP\PS2GamesSize.txt") do (set /a "TotalPS2Games_Size+=%%s")
     if !TotalPS2Games_Size! GTR 10 set "PS2MB=MB" & echo !TotalPS2Games_Size!| "%~dp0BAT\busybox" sed -e "s/ //g" > "%~dp0TMP\TotalPS2Games_Size.txt" & set /P @TotalPS2Games_Size=<"%~dp0TMP\TotalPS2Games_Size.txt"
     if !TotalPS2Games_Size! GTR 100 set "PS2MB=MB" & echo !TotalPS2Games_Size!| "%~dp0BAT\busybox" sed -e "s/ //g" > "%~dp0TMP\TotalPS2Games_Size.txt" & set /P @TotalPS2Games_Size=<"%~dp0TMP\TotalPS2Games_Size.txt"
     if !TotalPS2Games_Size! GTR 1000 set "PS2MB=GB" & echo !TotalPS2Games_Size!| "%~dp0BAT\busybox" sed -e "s/.\{1\}/&\./" > "%~dp0TMP\TotalPS2Games_Size.txt" & set /P @TotalPS2Games_Size=<"%~dp0TMP\TotalPS2Games_Size.txt"
     if !TotalPS2Games_Size! GTR 10000 set "PS2MB=GB" & echo !TotalPS2Games_Size!| "%~dp0BAT\busybox" sed -e "s/.\{2\}/&\./" > "%~dp0TMP\TotalPS2Games_Size.txt" & set /P @TotalPS2Games_Size=<"%~dp0TMP\TotalPS2Games_Size.txt"
     if !TotalPS2Games_Size! GTR 100000 set "PS2MB=GB" & echo !TotalPS2Games_Size!| "%~dp0BAT\busybox" sed -e "s/.\{3\}/&\./" > "%~dp0TMP\TotalPS2Games_Size.txt" & set /P @TotalPS2Games_Size=<"%~dp0TMP\TotalPS2Games_Size.txt"
     if !TotalPS2Games_Size! GTR 1000000 set "PS2MB=GB" & echo !TotalPS2Games_Size!| "%~dp0BAT\busybox" sed -e "s/.\{4\}/&\./" > "%~dp0TMP\TotalPS2Games_Size.txt" & set /P @TotalPS2Games_Size=<"%~dp0TMP\TotalPS2Games_Size.txt"
     if !TotalPS2Games_Size! GTR 10000000 set "PS2MB=GB" & echo !TotalPS2Games_Size!| "%~dp0BAT\busybox" sed -e "s/.\{5\}/&\./" > "%~dp0TMP\TotalPS2Games_Size.txt" & set /P @TotalPS2Games_Size=<"%~dp0TMP\TotalPS2Games_Size.txt"
	 if "!@TotalPS2Games_Size!"=="" set @TotalPS2Games_Size=0
	 if "!PS2MB!"=="" set "PS2MB=MB"
	
	 REM APP Calculs
     "%~dp0BAT\busybox" sed "/0x1337/d; /\.POPS\./d" "%~dp0BAT\__Cache\PARTITION_PS2HDD.txt" | "%~dp0BAT\busybox" sed "$d" | "%~dp0BAT\busybox" sed "1d" | "%~dp0BAT\busybox" grep "PP.APPS-" | "%~dp0BAT\busybox" cut -c23-26 > "%~dp0TMP\APPSize.txt"
	 type "%~dp0TMP\APPSize.txt" | "%~dp0BAT\busybox" sed -e "/^$/d" | "%~dp0BAT\busybox" wc -l > "%~dp0TMP\TotalAPP.txt" & set /P @TotalAPP=<"%~dp0TMP\TotalAPP.txt"

	 for /f "usebackq" %%s in ("%~dp0TMP\APPSize.txt") do (set /a "TotalAPP_Size+=%%s")
     if !TotalAPP_Size! GTR 10 set "APPMB=MB" & echo !TotalAPP_Size!| "%~dp0BAT\busybox" sed -e "s/ //g" > "%~dp0TMP\TotalAPP_Size.txt" & set /P @TotalAPP_Size=<"%~dp0TMP\TotalAPP_Size.txt"
     if !TotalAPP_Size! GTR 100 set "APPMB=MB" & echo !TotalAPP_Size!| "%~dp0BAT\busybox" sed -e "s/ //g" > "%~dp0TMP\TotalAPP_Size.txt" & set /P @TotalAPP_Size=<"%~dp0TMP\TotalAPP_Size.txt"
     if !TotalAPP_Size! GTR 1000 set "APPMB=GB" & echo !TotalAPP_Size!| "%~dp0BAT\busybox" sed -e "s/.\{1\}/&\./" > "%~dp0TMP\TotalAPP_Size.txt" & set /P @TotalAPP_Size=<"%~dp0TMP\TotalAPP_Size.txt"
     if !TotalAPP_Size! GTR 10000 set "APPMB=GB" & echo !TotalAPP_Size!| "%~dp0BAT\busybox" sed -e "s/.\{2\}/&\./" > "%~dp0TMP\TotalAPP_Size.txt" & set /P @TotalAPP_Size=<"%~dp0TMP\TotalAPP_Size.txt"
     if !TotalAPP_Size! GTR 100000 set "APPMB=GB" & echo !TotalAPP_Size!| "%~dp0BAT\busybox" sed -e "s/.\{3\}/&\./" > "%~dp0TMP\TotalAPP_Size.txt" & set /P @TotalAPP_Size=<"%~dp0TMP\TotalAPP_Size.txt"
     if !TotalAPP_Size! GTR 1000000 set "APPMB=GB" & echo !TotalAPP_Size!| "%~dp0BAT\busybox" sed -e "s/.\{4\}/&\./" > "%~dp0TMP\TotalAPP_Size.txt" & set /P @TotalAPP_Size=<"%~dp0TMP\TotalAPP_Size.txt"
     if !TotalAPP_Size! GTR 10000000 set "APPMB=GB" & echo !TotalAPP_Size!| "%~dp0BAT\busybox" sed -e "s/.\{5\}/&\./" > "%~dp0TMP\TotalAPP_Size.txt" & set /P @TotalAPP_Size=<"%~dp0TMP\TotalAPP_Size.txt"
     if "!@TotalAPP_Size!"=="" set @TotalAPP_Size=0
	 if "!APPMB!"=="" set "APPMB=MB"

	 REM PFS Calculs
     "%~dp0BAT\busybox" sed "/0x1337/d; /\.POPS\./d; /PP.APPS-/d" "%~dp0BAT\__Cache\PARTITION_PS2HDD.txt" | "%~dp0BAT\busybox" sed "$d" | "%~dp0BAT\busybox" sed "1d" | "%~dp0BAT\busybox" cut -c23-26 > "%~dp0TMP\PFSSize.txt"
	 type "%~dp0TMP\PFSSize.txt" | "%~dp0BAT\busybox" sed -e "/^$/d" | "%~dp0BAT\busybox" wc -l > "%~dp0TMP\TotalPFS.txt" & set /P @TotalPFS=<"%~dp0TMP\TotalPFS.txt"

	 for /f "usebackq" %%s in ("%~dp0TMP\PFSSize.txt") do (set /a "TotalPFS_Size+=%%s")
     if !TotalPFS_Size! GTR 10 set "PFSMB=MB" & echo !TotalPFS_Size!| "%~dp0BAT\busybox" sed -e "s/ //g" > "%~dp0TMP\TotalPFS_Size.txt" & set /P @TotalPFS_Size=<"%~dp0TMP\TotalPFS_Size.txt"
     if !TotalPFS_Size! GTR 100 set "PFSMB=MB" & echo !TotalPFS_Size!| "%~dp0BAT\busybox" sed -e "s/ //g" > "%~dp0TMP\TotalPFS_Size.txt" & set /P @TotalPFS_Size=<"%~dp0TMP\TotalPFS_Size.txt"
     if !TotalPFS_Size! GTR 1000 set "PFSMB=GB" & echo !TotalPFS_Size!| "%~dp0BAT\busybox" sed -e "s/.\{1\}/&\./" > "%~dp0TMP\TotalPFS_Size.txt" & set /P @TotalPFS_Size=<"%~dp0TMP\TotalPFS_Size.txt"
     if !TotalPFS_Size! GTR 10000 set "PFSMB=GB" & echo !TotalPFS_Size!| "%~dp0BAT\busybox" sed -e "s/.\{2\}/&\./" > "%~dp0TMP\TotalPFS_Size.txt" & set /P @TotalPFS_Size=<"%~dp0TMP\TotalPFS_Size.txt"
     if !TotalPFS_Size! GTR 100000 set "PFSMB=GB" & echo !TotalPFS_Size!| "%~dp0BAT\busybox" sed -e "s/.\{3\}/&\./" > "%~dp0TMP\TotalPFS_Size.txt" & set /P @TotalPFS_Size=<"%~dp0TMP\TotalPFS_Size.txt"
     if !TotalPFS_Size! GTR 1000000 set "PFSMB=GB" & echo !TotalPFS_Size!| "%~dp0BAT\busybox" sed -e "s/.\{4\}/&\./" > "%~dp0TMP\TotalPFS_Size.txt" & set /P @TotalPFS_Size=<"%~dp0TMP\TotalPFS_Size.txt"
     if !TotalPFS_Size! GTR 10000000 set "PFSMB=GB" & echo !TotalPFS_Size!| "%~dp0BAT\busybox" sed -e "s/.\{5\}/&\./" > "%~dp0TMP\TotalPFS_Size.txt" & set /P @TotalPFS_Size=<"%~dp0TMP\TotalPFS_Size.txt"
     if "!@TotalPFS_Size!"=="" set @TotalPFS_Size=0
	 if "!PFSMB!"=="" set "PFSMB=MB"
	 
     REM HDD Total Size
     "%~dp0BAT\busybox" tail -n 1 "%~dp0BAT\__Cache\PARTITION_PS2HDD.txt" | "%~dp0BAT\busybox" sed "s/MB,//g" > "%~dp0TMP\TotalUsed_Size.txt"
	 for /f "usebackq tokens=6" %%s in ("%~dp0TMP\TotalUsed_Size.txt") do set TotalUsed_Size=%%s
     if !TotalUsed_Size! GTR 10 set "HDDMB=MB" & echo !TotalUsed_Size!| "%~dp0BAT\busybox" sed -e "s/ //g" > "%~dp0TMP\TotalUsed_Size.txt" & set /P @TotalUsed_Size=<"%~dp0TMP\TotalUsed_Size.txt"
     if !TotalUsed_Size! GTR 100 set "HDDMB=MB" & echo !TotalUsed_Size!| "%~dp0BAT\busybox" sed -e "s/ //g" > "%~dp0TMP\TotalUsed_Size.txt" & set /P @TotalUsed_Size=<"%~dp0TMP\TotalUsed_Size.txt"
     if !TotalUsed_Size! GTR 1000 set "HDDMB=GB" & echo !TotalUsed_Size!| "%~dp0BAT\busybox" sed -e "s/.\{1\}/&\./" > "%~dp0TMP\TotalUsed_Size.txt" & set /P @TotalUsed_Size=<"%~dp0TMP\TotalUsed_Size.txt"
     if !TotalUsed_Size! GTR 10000 set "HDDMB=GB" & echo !TotalUsed_Size!| "%~dp0BAT\busybox" sed -e "s/.\{2\}/&\./" > "%~dp0TMP\TotalUsed_Size.txt" & set /P @TotalUsed_Size=<"%~dp0TMP\TotalUsed_Size.txt"
     if !TotalUsed_Size! GTR 100000 set "HDDMB=GB" & echo !TotalUsed_Size!| "%~dp0BAT\busybox" sed -e "s/.\{3\}/&\./" > "%~dp0TMP\TotalUsed_Size.txt" & set /P @TotalUsed_Size=<"%~dp0TMP\TotalUsed_Size.txt"
     if !TotalUsed_Size! GTR 1000000 set "HDDMB=GB" & echo !TotalUsed_Size!| "%~dp0BAT\busybox" sed -e "s/.\{4\}/&\./" > "%~dp0TMP\TotalUsed_Size.txt" & set /P @TotalUsed_Size=<"%~dp0TMP\TotalUsed_Size.txt"
     if !TotalUsed_Size! GTR 10000000 set "HDDMB=GB" & echo !TotalUsed_Size!| "%~dp0BAT\busybox" sed -e "s/.\{5\}/&\./" > "%~dp0TMP\TotalUsed_Size.txt" & set /P @TotalUsed_Size=<"%~dp0TMP\TotalUsed_Size.txt"
	 
	 REM HDD FreeSpace
     "%~dp0BAT\busybox" tail -n 1 "%~dp0BAT\__Cache\PARTITION_PS2HDD.txt" |  "%~dp0BAT\busybox" sed "s/.*available/available/" | "%~dp0BAT\busybox" sed "s/MB//g" > "%~dp0TMP\TotalHDDFree_Space.txt"
	 for /f "usebackq tokens=2" %%s in ("%~dp0TMP\TotalHDDFree_Space.txt") do set TotalHDDFree_Space=%%s
     if !TotalHDDFree_Space! GTR 10 set "FREEMB=MB" & echo !TotalHDDFree_Space!| "%~dp0BAT\busybox" sed -e "s/ //g" > "%~dp0TMP\TotalHDDFree_Space.txt" & set /P @TotalHDDFree_Space=<"%~dp0TMP\TotalHDDFree_Space.txt"
     if !TotalHDDFree_Space! GTR 100 set "FREEMB=MB" & echo !TotalHDDFree_Space!| "%~dp0BAT\busybox" sed -e "s/ //g" > "%~dp0TMP\TotalHDDFree_Space.txt" & set /P @TotalHDDFree_Space=<"%~dp0TMP\TotalHDDFree_Space.txt"
     if !TotalHDDFree_Space! GTR 1000 set "FREEMB=GB" & echo !TotalHDDFree_Space!| "%~dp0BAT\busybox" sed -e "s/.\{1\}/&\./" > "%~dp0TMP\TotalHDDFree_Space.txt" & set /P @TotalHDDFree_Space=<"%~dp0TMP\TotalHDDFree_Space.txt"
     if !TotalHDDFree_Space! GTR 10000 set "FREEMB=GB" & echo !TotalHDDFree_Space!| "%~dp0BAT\busybox" sed -e "s/.\{2\}/&\./" > "%~dp0TMP\TotalHDDFree_Space.txt" & set /P @TotalHDDFree_Space=<"%~dp0TMP\TotalHDDFree_Space.txt"
     if !TotalHDDFree_Space! GTR 100000 set "FREEMB=GB" & echo !TotalHDDFree_Space!| "%~dp0BAT\busybox" sed -e "s/.\{3\}/&\./" > "%~dp0TMP\TotalHDDFree_Space.txt" & set /P @TotalHDDFree_Space=<"%~dp0TMP\TotalHDDFree_Space.txt"
     if !TotalHDDFree_Space! GTR 1000000 set "FREEMB=GB" & echo !TotalHDDFree_Space!| "%~dp0BAT\busybox" sed -e "s/.\{4\}/&\./" > "%~dp0TMP\TotalHDDFree_Space.txt" & set /P @TotalHDDFree_Space=<"%~dp0TMP\TotalHDDFree_Space.txt"
     if !TotalHDDFree_Space! GTR 10000000 set "FREEMB=GB" & echo !TotalHDDFree_Space!| "%~dp0BAT\busybox" sed -e "s/.\{5\}/&\./" > "%~dp0TMP\TotalHDDFree_Space.txt" & set /P @TotalHDDFree_Space=<"%~dp0TMP\TotalHDDFree_Space.txt"
	 
echo TOTAL - PS1 Games:  [!@TotalPS1Games!]    TOTAL - Size: [!@TotalPS1Games_Size! !PS1MB!]
echo TOTAL - PS2 Games:  [!@TotalPS2Games!]    TOTAL - Size: [!@TotalPS2Games_Size! !PS2MB!]
echo TOTAL - APP System: [!@TotalAPP!]    TOTAL - Size: [!@TotalAPP_Size! !APPMB!]
echo TOTAL - PFS System: [!@TotalPFS!]    TOTAL - Size: [!@TotalPFS_Size! !PFSMB!]
echo\
echo             TOTAL - Size used: [!@TotalUsed_Size! !HDDMB!]
echo             TOTAL - FreeSpace: [!@TotalHDDFree_Space! !FREEMB!]
)

if defined DiagPartitionError (
echo Scanning Partitions Error:
"%~dp0BAT\Diagbox" gd 06
echo.
echo NOTE: If nothing appears there is no error in the partitions
echo.
"%~dp0BAT\Diagbox" gd 0f
echo ----------------------------------------------------
"%~dp0BAT\hdl_dump" diag %@hdl_path% > "%~dp0LOG\PARTITION_SCAN_ERROR.log" & type "%~dp0LOG\PARTITION_SCAN_ERROR.log")
echo ----------------------------------------------------

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
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "!@hdl_path!" | "%~dp0BAT\busybox" grep "Playstation 2 HDD" >nul
if errorlevel 1 set "@hdl_path=" & goto ScanningPS2HDD
echo       [!@hdl_path! !@TotalHDD_Size! - !@ModelePS2HDD!]
)

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Backup or Inject MBR Program:
echo ----------------------------------------------------
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
call "%~dp0BAT\__ReloadHDD_cache.bat" >nul 2>&1

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
echo ----------------------------------------------------
    "%~dp0BAT\Diagbox" gd 03
	wmic diskdrive get index,name,model | "%~dp0BAT\busybox" sort | "%~dp0BAT\busybox" sed "s/[[:space:]]*$//g" | "%~dp0BAT\busybox" sed "1d; $d" | "%~dp0BAT\busybox" cut -c8-500 | "%~dp0BAT\busybox" sed "/\\\\.\\\PHYSICALDRIVE0/d"
	"%~dp0BAT\Diagbox" gd 07
    echo ----------------------------------------------------
	"%~dp0BAT\Diagbox" gd 0c
	echo WARNING: MAKE SURE YOU CHOOSE THE RIGHT HARD DRIVE YOU WANT TO FORMAT
	"%~dp0BAT\Diagbox" gd 06
	echo.
	echo NOTE: If no PS2 HDDs are found, quit and retry after disconnecting
	echo all disk drives EXCEPT for your PC boot drive and the PS2 HDDs.
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

"%~dp0BAT\hdl_dump" query | findstr "%hdlhdd%" | "%~dp0BAT\busybox" grep -o "hdd[0-9]:\|hdd[0-9][0-9]:" > "%~dp0TMP\hdl-hdd.txt"
"%~dp0BAT\busybox" sed -i "s/hdd/\\\\.\\\PhysicalDrive/g; s/://g" "%~dp0TMP\hdl-hdd.txt"
set /P @pfsshell_path=<"%~dp0TMP\hdl-hdd.txt"

"%~dp0BAT\busybox" sed -e "s/\\\\.\\\PhysicalDrive/PHYSICALDRIVE/g; s/://g" "%~dp0TMP\hdl-hdd.txt" > "%~dp0TMP\hdl-hddinfo.txt"
set /P @hdl_pathinfo=<"%~dp0TMP\hdl-hddinfo.txt"

"%~dp0BAT\Diagbox" gd 0e
cls
echo\
echo\
echo HDD Selected:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "%hdlhdd%"
"%~dp0BAT\Diagbox" gd 0f

    echo\
    wmic diskdrive get name,model,status > "%~dp0TMP\hdl-hddinfolog.txt"
    type "%~dp0TMP\hdl-hddinfolog.txt" | findstr "Model %@hdl_pathinfo%" | "%~dp0BAT\busybox" sed -e "3,100d" > "%~dp0TMP\hdl-hddinfotmp.txt"
	"%~dp0BAT\busybox" cat "%~dp0TMP\hdl-hddinfotmp.txt"
	
"%~dp0BAT\Diagbox" gd 0c	
echo\
echo\
echo Are you sure you want to format this hard drive to PS2 format ?:
"%~dp0BAT\Diagbox" gd 0f
echo ----------------------------------------------------
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

    REM Checking for PSX HDD
	echo device !@pfsshell_path! > "%~dp0TMP\pfs-psx.txt"
	echo mount __system >> "%~dp0TMP\pfs-psx.txt"
	echo ls >> "%~dp0TMP\pfs-psx.txt"
	echo exit >> "%~dp0TMP\pfs-psx.txt"
	type "%~dp0TMP\pfs-psx.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" grep -m1 -o "main.xml" > "%~dp0TMP\hdd-psx.txt"
	
	set /P @hdd_avl=<"%~dp0TMP\hdd-psx.txt"
	IF "!@hdd_avl!"=="main.xml" (
	"%~dp0BAT\Diagbox" gd 0c
	    cls
		echo          PSX DESR HDD - Detected
		echo      You should not format your PSX HDD^!
		echo\
		echo              ABORTED OPERATION
		echo\
		echo\
		"%~dp0BAT\Diagbox" gd 0f
		pause & (goto HDDManagementMenu)
		)

IF %@pfs_formathdd%==yes (
"%~dp0BAT\Diagbox" gd 0f
cls
echo\
echo\
echo Formatting HDD:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "%hdlhdd%"
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
echo ----------------------------------------------------
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
echo ----------------------------------------------------
    "%~dp0BAT\Diagbox" gd 03
	wmic diskdrive get index,name,model | "%~dp0BAT\busybox" sort | "%~dp0BAT\busybox" sed "s/[[:space:]]*$//g" | "%~dp0BAT\busybox" sed "1d; $d" | "%~dp0BAT\busybox" cut -c8-500 | "%~dp0BAT\busybox" sed "/\\\\.\\\PHYSICALDRIVE0/d"
	"%~dp0BAT\Diagbox" gd 07
    echo ----------------------------------------------------
	"%~dp0BAT\Diagbox" gd 0c
	echo WARNING: MAKE SURE YOU CHOOSE THE RIGHT HARD DRIVE YOU WANT TO HACK
	"%~dp0BAT\Diagbox" gd 06
	echo.
	echo NOTE: If no PS2 HDDs are found, quit and retry after disconnecting
	echo all disk drives EXCEPT for your PC boot drive and the PS2 HDDs.
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
    set /p choice=Enter the number of the hard drive you want to Hack:
    echo\
    IF "!choice!"=="" set "hdlhddm=" & set "hdlhdd=" & set "@pfsshell_path=" & set "@hdl_pathinfo=" & (goto hackHDDtoPS2)
    IF "!choice!"=="!choice!" set hdlhdd=hdd!choice!:
    IF "!choice!"=="Q" (goto  HDDManagementMenu)
    )

"%~dp0BAT\hdl_dump" query | findstr "%hdlhdd%" | "%~dp0BAT\busybox" grep -o "hdd[0-9]:\|hdd[0-9][0-9]:" > "%~dp0TMP\hdl-hdd.txt"
"%~dp0BAT\busybox" sed -i "s/hdd/\\\\.\\\PhysicalDrive/g; s/://g" "%~dp0TMP\hdl-hdd.txt"
set /P @pfsshell_path=<"%~dp0TMP\hdl-hdd.txt"

"%~dp0BAT\busybox" sed -e "s/\\\\.\\\PhysicalDrive/PHYSICALDRIVE/g; s/://g" "%~dp0TMP\hdl-hdd.txt" > "%~dp0TMP\hdl-hddinfo.txt"
set /P @hdl_pathinfo=<"%~dp0TMP\hdl-hddinfo.txt"

"%~dp0BAT\Diagbox" gd 0e
cls
echo\
echo HDD Selected:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | findstr "%hdlhdd%"
"%~dp0BAT\Diagbox" gd 0f
     
	echo\
    wmic diskdrive get name,model,status > "%~dp0TMP\hdl-hddinfolog.txt"
    type "%~dp0TMP\hdl-hddinfolog.txt" | findstr "Model %@hdl_pathinfo%" | "%~dp0BAT\busybox" sed -e "3,100d" > "%~dp0TMP\hdl-hddinfotmp.txt"
	"%~dp0BAT\busybox" cat "%~dp0TMP\hdl-hddinfotmp.txt"

    rmdir /Q/S "%~dp0\^!COPY_TO_USB_ROOT" >nul 2>&1
    "%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0BAT\^!COPY_TO_USB_ROOT.7z" -o"%~dp0\^!COPY_TO_USB_ROOT" >nul 2>&1
    REM xcopy "%~dp0BAT\^!COPY_TO_USB_ROOT" "%~dp0\^!COPY_TO_USB_ROOT" /e >nul 2>&1

"%~dp0BAT\Diagbox" gd 0c 
echo\
echo ARE YOU SURE you want to HACK this hard drive ? this is irreversible:
echo.
"%~dp0BAT\Diagbox" gd 0e
echo If you have already installed FreeHDBoot ^(From HDD^), you don't need to do this
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
echo.
echo ^(5^) Have Fun
echo.
"%~dp0BAT\Diagbox" gd 0f
echo ----------------------------------------------------
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

    REM Checking for PSX HDD
	echo device !@pfsshell_path! > "%~dp0TMP\pfs-psx.txt"
	echo mount __system >> "%~dp0TMP\pfs-psx.txt"
	echo ls >> "%~dp0TMP\pfs-psx.txt"
	echo exit >> "%~dp0TMP\pfs-psx.txt"
	type "%~dp0TMP\pfs-psx.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" grep -m1 -o "main.xml" > "%~dp0TMP\hdd-psx.txt"
	
	set /P @hdd_avl=<"%~dp0TMP\hdd-psx.txt"
	IF "!@hdd_avl!"=="main.xml" (
	"%~dp0BAT\Diagbox" gd 0c
	    cls
		echo             PSX DESR HDD - Detected
		echo      You should not modify the MBR of your PSX HDD^!
		echo\
		echo                ABORTED OPERATION
		echo\
		echo\
		"%~dp0BAT\Diagbox" gd 0f
		pause & (goto HDDManagementMenu)
		)

IF %@pfs_hackhdd%==yes (
cls
echo\
echo\
echo Install HACK PS2 HDD:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | findstr "%hdlhdd%"
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
echo ----------------------------------------------------
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
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "!@hdl_path!" | "%~dp0BAT\busybox" grep "Playstation 2 HDD" >nul
if errorlevel 1 set "@hdl_path=" & goto ScanningPS2HDD
echo       [!@hdl_path! !@TotalHDD_Size! - !@ModelePS2HDD!]
)

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Install HDD-OSD: (Browser 2.0)
"%~dp0BAT\Diagbox" gd 0f
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1^) Yes
"%~dp0BAT\Diagbox" gd 0c
echo         2^) No
"%~dp0BAT\Diagbox" gd 0f
echo\
CHOICE /C 12 /M "Select Option:"

IF %ERRORLEVEL%==1 set @pfs_installhddosd=yes
IF %ERRORLEVEL%==2 set @pfs_installhddosd=no & (goto HDDOSDMenu)

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Change default +OPL partition?
echo ----------------------------------------------------
echo\
echo Choose the partition where your OPL files are located
echo By default this will be the partition: +OPL
echo\
CHOICE /C YN /M "Change the default partition?:"

IF %ERRORLEVEL%==1 set CHOICEPP=yes
IF %ERRORLEVEL%==2 set OPLPART=+OPL

if defined CHOICEPP (
echo\
echo 1. [+OPL]
echo 2. [__common]
echo 3. Custom Partition
echo\
CHOICE /C 123 /M "Select Option:"

IF ERRORLEVEL 1 set OPLPART=+OPL
IF ERRORLEVEL 2 set CUSTOM_OPLPART=yes & set OPLPART=__common
IF ERRORLEVEL 3 ( set CUSTOM_OPLPART=yes
echo\
set "OPLPART="
set /p OPLPART="Enter the partition name:"
IF "!OPLPART!"=="" set OPLPART=+OPL
 )
)
echo\
echo\
echo Checking Files For HDD-OSD
echo ----------------------------------------------------

if not exist "%~dp0HDD-OSD\__system\osd100\hosdsys.elf" (
    "%~dp0BAT\Diagbox" gd 0c
    echo         No files found
    echo\
    echo\
    rmdir /Q/S "%~dp0TMP" >nul 2>&1
	"%~dp0BAT\Diagbox" gd 0f
    pause & (goto HDDOSDMenu)
) else (
"%~dp0BAT\busybox" md5sum "%~dp0HDD-OSD\__system\osd100\hosdsys.elf" | "%~dp0BAT\busybox" grep -o "[0-9a-f]\{32\}" > "%~dp0TMP\MD5.txt" & set /p MD5=<"%~dp0TMP\MD5.txt"
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
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0f

	"%~dp0BAT\busybox" grep -ow "__sysconf" "%~dp0BAT\__Cache\PARTITION_PS2HDD.txt" > "%~dp0TMP\hdd-prt.txt"
	
	set /P @hdd_avl=<"%~dp0TMP\hdd-prt.txt"
	IF "!@hdd_avl!"=="__sysconf" (
	"%~dp0BAT\Diagbox" gd 0a
		echo         __sysconf - Partition Detected
		) else (
		"%~dp0BAT\Diagbox" gd 0c
		echo         __sysconf - Partition NOT Detected
		echo         Partition Must Be Formatted Or Created
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
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0f

	"%~dp0BAT\busybox" grep -ow "__system" "%~dp0BAT\__Cache\PARTITION_PS2HDD.txt" > "%~dp0TMP\hdd-prt.txt"
	
	set /P @hdd_avl=<"%~dp0TMP\hdd-prt.txt"
	IF "!@hdd_avl!"=="__system" (
	"%~dp0BAT\Diagbox" gd 0a
		echo         __system - Partition Detected
		) else (
		"%~dp0BAT\Diagbox" gd 0c
		echo         __system - Partition NOT Detected
		echo         Partition Must Be Formatted Or Created
		echo\
		echo\
		"%~dp0BAT\Diagbox" gd 07
		rmdir /Q/S "%~dp0TMP" >nul 2>&1
	    pause & (goto HDDOSDMenu)
		)

"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Detecting %OPLPART% Partition:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0f

    "%~dp0BAT\busybox" grep -ow "%OPLPART%" "%~dp0BAT\__Cache\PARTITION_PS2HDD.txt" > "%~dp0TMP\hdd-prt.txt"

	set /P @hdd_avl=<"%~dp0TMP\hdd-prt.txt"
	IF "!@hdd_avl!"=="%OPLPART%" (
	"%~dp0BAT\Diagbox" gd 0a
		echo         %OPLPART% - Partition Detected
		) else (
		"%~dp0BAT\Diagbox" gd 0c
		echo           %OPLPART% - Partition NOT Detected
		echo         Partition Must Be Formatted Or Created
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
echo ----------------------------------------------------
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
		) else (
		"%~dp0BAT\Diagbox" gd 0c
		echo         FreeHDBoot - Installation NOT Detected
		echo         You need to install FreeHDBoot to use HDD-OSD.
		echo\
		"%~dp0BAT\Diagbox" gd 06
		echo Do you want to continue? You can install FreeHDBoot later
		choice /c YN
	    if errorlevel 2 ( set @pfs_installhddosd=no) else ( set @pfs_installhddosd=yes)
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
echo ----------------------------------------------------
echo\

REM __sysconf
	cd /d "%~dp0HDD-OSD\__sysconf"
    REM if defined HDDOSD cd /d "%~dp0TMP\!HDDOSDVER!\__sysconf"

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
 	echo put conf_hdd.cfg >> "%~dp0TMP\pfs-hddosd.txt"
    echo umount >> "%~dp0TMP\pfs-hddosd.txt"
	echo exit >> "%~dp0TMP\pfs-hddosd.txt"
	type "%~dp0TMP\pfs-hddosd.txt" | "%~dp0BAT\pfsshell" >nul 2>&1

    cd /d "%~dp0HDD-OSD"
	REM "%~dp0BAT\7-Zip\7z" e -bso0 "%~dp0BAT\APPS.zip" -o"%~dp0TMP" "APPS\Open PS2 Loader Latest\*.ELF" -r -y >nul 2>&1
	REM move "%~dp0TMP\*.ELF" "%~dp0HDD-OSD\OPNPS2LD.ELF" >nul 2>&1
    echo device !@pfsshell_path! > "%~dp0TMP\pfs-hddosd.txt"
	echo mount %OPLPART% >> "%~dp0TMP\pfs-hddosd.txt"
	if defined CUSTOM_OPLPART echo mkdir OPL >> "%~dp0TMP\pfs-hddosd.txt"
    if defined CUSTOM_OPLPART echo cd OPL >> "%~dp0TMP\pfs-hddosd.txt"
	echo rm OPNPS2LD.ELF >> "%~dp0TMP\pfs-hddosd.txt"
 	echo put OPNPS2LD.ELF >> "%~dp0TMP\pfs-hddosd.txt"
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
	"%~dp0BAT\busybox" sed -i "/OSDSYS_left_cursor/s/009/006/g; /OSDSYS_right_cursor/s/008/005/g; /OSDSYS_menu_bottom_delimiter/s/006/009/g; /OSDSYS_menu_bottom_delimiter/s/007/010/g" "%~dp0TMP\FREEHDB.CNF"
	echo device !@pfsshell_path! > "%~dp0TMP\pfs-hddosd.txt"
	echo mount __sysconf >> "%~dp0TMP\pfs-hddosd.txt"
	echo cd FMCB >> "%~dp0TMP\pfs-hddosd.txt"
	echo lcd "%~dp0TMP" >> "%~dp0TMP\pfs-hddosd.txt"
	echo put FREEHDB.CNF >> "%~dp0TMP\pfs-hddosd.txt"
	echo umount >> "%~dp0TMP\pfs-hddosd.txt"
	echo exit >> "%~dp0TMP\pfs-hddosd.txt"
	type "%~dp0TMP\pfs-hddosd.txt" | "%~dp0BAT\pfsshell" >nul 2>&1
	)
	
	echo         HDD-OSD Completed...

if defined CHOICEPP (
    "%~dp0BAT\busybox" sed -i -e "s/\hdd_partition=.*/hdd_partition=/g; s/hdd_partition=/hdd_partition=%OPLPART%/g" "%~dp0HDD-OSD\__common\OPL\conf_hdd.cfg"
	cd "%~dp0HDD-OSD\__common\OPL"
    echo device %@pfsshell_path% > "%~dp0TMP\pfs-OPLCONFIG.txt"
	echo mount __common >> "%~dp0TMP\pfs-OPLCONFIG.txt"
	echo mkdir OPL >> "%~dp0TMP\pfs-OPLCONFIG.txt"
	echo cd OPL >> "%~dp0TMP\pfs-OPLCONFIG.txt"
	echo rm conf_hdd.cfg >> "%~dp0TMP\pfs-OPLCONFIG.txt"
 	echo put conf_hdd.cfg >> "%~dp0TMP\pfs-OPLCONFIG.txt"
    echo umount >> "%~dp0TMP\pfs-OPLCONFIG.txt"
	echo exit >> "%~dp0TMP\pfs-OPLCONFIG.txt"
	type "%~dp0TMP\pfs-OPLCONFIG.txt" | "%~dp0BAT\pfsshell" >nul 2>&1
	"%~dp0BAT\busybox" sed -i -e "s/\hdd_partition=.*/hdd_partition=/g; s/hdd_partition=/hdd_partition=+OPL/g" "%~dp0HDD-OSD\__common\OPL\conf_hdd.cfg"
    )
 ) else ( echo         HDDOSD - Installation Canceled... )

cd /d "%~dp0" & rmdir /Q/S "%~dp0TMP" >nul 2>&1

echo\
echo\
echo ----------------------------------------------------
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
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "!@hdl_path!" | "%~dp0BAT\busybox" grep "Playstation 2 HDD" >nul
if errorlevel 1 set "@hdl_path=" & goto ScanningPS2HDD
echo       [!@hdl_path! !@TotalHDD_Size! - !@ModelePS2HDD!]
)

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Uninstall HDD-OSD:
echo ----------------------------------------------------
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
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0f

	"%~dp0BAT\busybox" grep -ow "__sysconf" "%~dp0BAT\__Cache\PARTITION_PS2HDD.txt" > "%~dp0TMP\hdd-prt.txt"
	
	set /P @hdd_avl=<"%~dp0TMP\hdd-prt.txt"
	IF "!@hdd_avl!"=="__sysconf" (
	"%~dp0BAT\Diagbox" gd 0a
		echo         __sysconf - Partition Detected
		) else (
		"%~dp0BAT\Diagbox" gd 0c
		echo         __sysconf - Partition NOT Detected
		echo         Partition Must Be Formatted Or Created
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
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0f

	"%~dp0BAT\busybox" grep -ow "__system" "%~dp0BAT\__Cache\PARTITION_PS2HDD.txt" > "%~dp0TMP\hdd-prt.txt"
	
	set /P @hdd_avl=<"%~dp0TMP\hdd-prt.txt"
	IF "!@hdd_avl!"=="__system" (
	"%~dp0BAT\Diagbox" gd 0a
		echo         __system - Partition Detected
		"%~dp0BAT\Diagbox" gd 0c
		) else (
		echo         __system - Partition NOT Detected
		echo         Partition Must Be Formatted Or Created
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
echo ----------------------------------------------------
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
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo Uninstall Completed...
echo\
echo\
"%~dp0BAT\Diagbox" gd 07

pause & (goto HDDOSDMenu)

REM ####################################################################################################################################################
:InjectOPL-Launcher
cls
mkdir "%~dp0TMP" >nul 2>&1
cd /d "%~dp0TMP"

copy "%~dp0BAT\boot.kelf" "%~dp0TMP" >nul 2>&1
REM copy "%~dp0BAT\system.cnf" "%~dp0TMP" >nul 2>&1
copy "%~dp0BAT\hdl_dump.exe" "%~dp0TMP" >nul 2>&1

IF NOT DEFINED @hdl_path ( rmdir /Q/S "%~dp0TMP" >nul 2>&1 & goto ScanningPS2HDD ) else (
"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning for Playstation 2 HDDs:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "!@hdl_path!" | "%~dp0BAT\busybox" grep "Playstation 2 HDD" >nul
if errorlevel 1 set "@hdl_path=" & goto ScanningPS2HDD
echo       [!@hdl_path! !@TotalHDD_Size! - !@ModelePS2HDD!]
)

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Inject OPL-Launcher (boot.kelf) ?
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1^) Yes
"%~dp0BAT\Diagbox" gd 0c
echo         2^) No
"%~dp0BAT\Diagbox" gd 0e
echo         3^) Yes (For every installed game) 
"%~dp0BAT\Diagbox" gd 07
echo\
CHOICE /C 123 /M "Select Option:"

IF %ERRORLEVEL%==1 set @pfs_ppinjectkelf=Manually
IF %ERRORLEVEL%==2 (goto HDDOSDPartManagement)
IF %ERRORLEVEL%==3 set @pfs_ppinjectkelf=yes

"%~dp0BAT\Diagbox" gd 0e
cls
echo\
echo\
echo Scanning Games List:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
type "%~dp0BAT\__Cache\PARTITION_HDL_GAME.txt" | "%~dp0BAT\busybox" sed "s/|.*//" | "%~dp0BAT\busybox" sort -k2 > "%~dp0TMP\GameListPS2.txt" & type "%~dp0TMP\GameListPS2.txt"
"%~dp0BAT\Diagbox" gd 0e
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0f

    if !@pfs_ppinjectkelf!==Manually (
    echo\
	"%~dp0BAT\Diagbox" gd 0e
	echo Please type the gameid ^+ GameName as shown in the Games List.
	"%~dp0BAT\Diagbox" gd 07
	set "gname="
    set /p gname=
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
	) else ("%~dp0BAT\busybox" grep -F -w -m 1 "!gname!" "%~dp0BAT\__Cache\PARTITION_HDL_GAME.txt" > "%~dp0TMP\PARTITION_HDL_GAME.txt")
    ) else (type "%~dp0BAT\__Cache\PARTITION_HDL_GAME.txt" > "%~dp0TMP\PARTITION_HDL_GAME.txt")

cls
for /f "usebackq tokens=1* delims=|" %%f in ("%~dp0TMP\PARTITION_HDL_GAME.txt") do (

setlocal DisableDelayedExpansion
set fname=%%f
set pname=%%g
setlocal EnableDelayedExpansion

echo\
echo\
echo !pname!
echo ----------------------------------------------------
echo\

    echo        Inject boot.kelf...
	"%~dp0BAT\Diagbox" gd 03
	"%~dp0BAT\hdl_dump" modify_header !@hdl_path! "!pname!" | findstr "Successfully"
	"%~dp0BAT\Diagbox" gd 0f
	echo        Completed...
	echo\
	
 endlocal
endlocal
)
	
cd "%~dp0" & rmdir /Q/S "%~dp0TMP" >nul 2>&1
	
echo\
echo\
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo Injection Completed...
echo\
echo\
"%~dp0BAT\Diagbox" gd 07

pause & (goto HDDOSDPartManagement)
REM ##################################################################################################################################################
:ConvertGamesBBNXMB
cls
set rootpath=%cd%
chcp 65001 >nul 2>&1

mkdir "%~dp0TMP" >nul 2>&1
mkdir "%~dp0TMP\PP.HEADER" >nul 2>&1
cd /d "%~dp0TMP"

copy "%~dp0BAT\boot.kelf" "%~dp0TMP\PP.HEADER\EXECUTE.KELF" >nul 2>&1
copy "%~dp0BAT\system.cnf" "%~dp0TMP\PP.HEADER" >nul 2>&1
copy "%~dp0BAT\hdl_dump.exe" "%~dp0TMP\PP.HEADER" >nul 2>&1

IF NOT DEFINED @hdl_path ( rmdir /Q/S "%~dp0TMP" >nul 2>&1 & goto ScanningPS2HDD ) else (
"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning for Playstation 2 HDDs:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "!@hdl_path!" | "%~dp0BAT\busybox" grep "Playstation 2 HDD" >nul
if errorlevel 1 set "@hdl_path=" & goto ScanningPS2HDD
echo       [!@hdl_path! !@TotalHDD_Size! - !@ModelePS2HDD!]
)

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Convert a PS2 Game for PSBBN ^& XMB Menu ?
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1^) Yes
"%~dp0BAT\Diagbox" gd 0c
echo         2^) No
"%~dp0BAT\Diagbox" gd 0e
echo         3^) Undo partition conversion
"%~dp0BAT\Diagbox" gd 07
echo\
CHOICE /C 123 /M "Select Option:"

IF %ERRORLEVEL%==1 set "ShowPS2Games=Convert" & set checkOPL=yes
IF %ERRORLEVEL%==2 (goto HDDOSDPartManagement)
IF %ERRORLEVEL%==3 set "ShowPS2Games=Unconvert"

if !ShowPS2Games!==Convert (
echo\
echo\
echo Choose the titles language of the games list:
echo ----------------------------------------------------
echo Some games have their own title in several languages for example:
echo English = The Simpsons Game
echo French  = Les Simpson le jeu
"%~dp0BAT\Diagbox" gd 0e
echo NOTE: Some titles may not be translated
"%~dp0BAT\Diagbox" gd 07
echo\
echo 1. English
echo 2. French
echo\
CHOICE /C 12 /M "Select Option:"
if !errorlevel!==1 set language=english& copy "%~dp0BAT\TitlesDB\TitlesDB_PS2_English.txt" "%~dp0TMP\gameid.txt" >nul 2>&1
if !errorlevel!==2 set language=french& copy "%~dp0BAT\TitlesDB\TitlesDB_PS2_French.txt" "%~dp0TMP\gameid.txt" >nul 2>&1

REM "%~dp0BAT\busybox" iconv -f UTF-8 -t windows-1252//TRANSLIT

if exist "%~dp0ART.zip" (
echo\
"%~dp0BAT\Diagbox" gd 0e
echo ART.zip detected do you want use it?
"%~dp0BAT\Diagbox" gd 0f
CHOICE /C YN /M "Select Option:"
IF ERRORLEVEL 1 set uselocalART=yes
IF ERRORLEVEL 2 set uselocalART=no
) else (set uselocalART=no)

if !uselocalART!==no (
    echo.
	echo Checking internet Or Website connection...
	"%~dp0BAT\wget" -q --show-progress "https://archive.org/download/OPLM_ART_2023_11/OPLM_ART_2023_11.zip/PS1%%2FSCES_000.01%%2FSCES_000.01_COV.jpg" -O "%~dp0TMP\SCES_000.01_COV.jpg" >nul 2>&1
	for %%F in (SCES_000.01_COV.jpg) do if %%~zF==0 del "%%F"

if not exist SCES_000.01_COV.jpg (
"%~dp0BAT\Diagbox" gd 0c
    echo\
	echo Unable to connect to internet Or Website
	if exist "%~dp0ART.zip" set uselocalART=yes
	echo You will switch to offline mode
	echo\
	echo\
"%~dp0BAT\Diagbox" gd 0f
	pause
  ) else (set DownloadART=yes)
 )
)

cd /d "%~dp0TMP\PP.HEADER"
"%~dp0BAT\Diagbox" gd 0e
cls
echo\
echo\
echo Scanning Games List:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
    
    if !ShowPS2Games!==Convert type "%~dp0BAT\__Cache\PARTITION_HDL_GAME.txt" > "%~dp0TMP\PARTITION_PS2_GAMES_!ShowPS2Games!.txt"
	"%~dp0BAT\busybox" grep "0x0100" "%~dp0BAT\__Cache\PARTITION_PS2HDD.txt" | "%~dp0BAT\busybox" cut -c30-250 | "%~dp0BAT\busybox" sed "s/.\{15\}/& /" | "%~dp0BAT\busybox" sort -k2 | "%~dp0BAT\busybox" sed -e "s/\(.\{15\}\)./\1/" | "%~dp0BAT\busybox" sed "s/PP\./__\./g" > "%~dp0TMP\PARTITION_PS2_PFS.txt"
	
    for /f "usebackq tokens=*" %%f in ("%~dp0TMP\PARTITION_PS2_PFS.txt") do (
    findstr %%f "%~dp0BAT\__Cache\PARTITION_HDL_GAME.txt" >nul
	if errorlevel 1 (echo >nul
	) else (
	if !ShowPS2Games!==Convert (
	"%~dp0BAT\busybox" sed -i "/%%f/d" "%~dp0TMP\PARTITION_PS2_GAMES_!ShowPS2Games!.txt"
	) else (
	"%~dp0BAT\busybox" grep "%%f" "%~dp0BAT\__Cache\PARTITION_HDL_GAME.txt" >> "%~dp0TMP\PARTITION_PS2_GAMES_!ShowPS2Games!.txt"
	  )
	 )
	)

if not exist "%~dp0TMP\PARTITION_PS2_GAMES_!ShowPS2Games!.txt" ( echo No converted partition exists^! ) else (type "%~dp0TMP\PARTITION_PS2_GAMES_!ShowPS2Games!.txt" | "%~dp0BAT\busybox" sed "s/|.*//" | "%~dp0BAT\busybox" sort -k2 > "%~dp0TMP\GameListPS2.txt" & type "%~dp0TMP\GameListPS2.txt")

"%~dp0BAT\Diagbox" gd 0e
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 06
     echo\
	 if !ShowPS2Games!==Convert (
	 echo Keep in mind that each conversion will create a 128MB partition for each game
	 echo If you don't see your partitions, it means they are already converted.
	 )
	 
	echo\
	"%~dp0BAT\Diagbox" gd 0e
	echo Please type the gameid ^+ GameName as shown in the Games List.
	"%~dp0BAT\Diagbox" gd 07
     set /p "PPNameHeader="
     IF "!PPNameHeader!"=="" set "checkOPL=" & rmdir /Q/S "%~dp0TMP" >nul 2>&1 & (goto HDDOSDPartManagement)
	"%~dp0BAT\busybox" grep -Fx "!PPNameHeader!" "%~dp0TMP\GameListPS2.txt" >nul
	if errorlevel 1 (set "PPNameHeader=!PPNameHeader!") else ("%~dp0BAT\busybox" grep "!PPNameHeader!" "%~dp0TMP\PARTITION_PS2_GAMES_!ShowPS2Games!.txt" | "%~dp0BAT\busybox" sed "s/^[^|]*|//" > "%~dp0TMP\PPNameHeader.txt" & set /P PPNameHeader=<"%~dp0TMP\PPNameHeader.txt")

"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Detecting !PPNameHeader!
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 07

    "%~dp0BAT\busybox" grep -w "!PPNameHeader!" "%~dp0TMP\PARTITION_PS2_GAMES_!ShowPS2Games!.txt" | "%~dp0BAT\busybox" sed "s/^[^|]*|//" > "%~dp0TMP\PPSelected.txt" & set /P PPSELECTED=<"%~dp0TMP\PPSelected.txt"
	if "!PPSELECTED!"=="!PPNameHeader!" (
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
cls

if !ShowPS2Games!==Convert (
"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Conversion !PPNameHeader!
echo ----------------------------------------------------
echo\
"%~dp0BAT\Diagbox" gd 0f

     "%~dp0BAT\busybox" grep -o "[A-Z][A-Z][A-Z][A-Z]-[0-9][0-9][0-9][0-9][0-9]" "%~dp0TMP\PPSelected.txt" > "%~dp0TMP\DetectID.txt" & set /P gameid2=<"%~dp0TMP\DetectID.txt"
	 if not defined gameid2 (
	 "%~dp0BAT\Diagbox" gd 0c
	 echo ERROR: Bad partition name.
     echo Please reinstall the game.
	 echo\
	 "%~dp0BAT\Diagbox" gd 06
     echo Your partition name should look like this: PP.SLES-12345..GAME_NAME
     echo\
	 echo\
	 "%~dp0BAT\Diagbox" gd 0f
	 pause & goto HDDOSDPartManagement )
	 
     echo !gameid2!| "%~dp0BAT\busybox" sed "s/-/_/g" | "%~dp0BAT\busybox" sed "s/.\{8\}/&./" > "%~dp0TMP\DetectID.txt" & set /P gameid=<"%~dp0TMP\DetectID.txt"
	
	"%~dp0BAT\hdl_dump_fix_header" dump_header %@hdl_path% "!PPNameHeader!" >nul 2>&1
	"%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0BAT\HDD-PSBBN_XMB_SAMPLE_HEADER.zip" -o"%~dp0TMP\PP.HEADER" -r -y >nul 2>&1
	copy "%~dp0BAT\boot.kelf" "%~dp0TMP\PP.HEADER" >nul 2>&1

	 echo         Getting game information...
	 set "dbtitleTMP="
 	 for /f "tokens=1*" %%A in ( 'findstr !gameid! "%~dp0TMP\gameid.txt"' ) do (if not defined dbtitleTMP set dbtitleTMP=%%B
	 )

	 if "!PPNameHeader!"=="PP.SLUS-20273..NAMCO_MUSEUM__" set "dbtitleTMP=Namco Museum"
	 if "!PPNameHeader!"=="PP.SLUG-20273..NAMCO_MUSEUM_50T" set "dbtitleTMP=Namco Museum 50th Anniversary"
	 if "!PPNameHeader!"=="PP.SLUS-20643..SOULCALIBUR_II" set "dbtitleTMP=Soulcalibur II"
	 if "!PPNameHeader!"=="PP.SLUD-20643..NAMCO_TRANSMISSI" set "dbtitleTMP=Namco Transmission v1.03"
	 
	"%~dp0BAT\wget" -q --show-progress https://psxdatacenter.com/psx2/games2/!gameid2!.html 2>&1 -O "%~dp0TMP\!gameid2!.html" >nul 2>&1
	if errorlevel 1 ( "%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0BAT\PSBBN_XMB_PS2_GAMEINFO_Database.7z" -o"%~dp0TMP" !gameid2!.html -r -y)
	
    "%~dp0BAT\busybox" grep -A2 "DATE RELEASED" "%~dp0TMP\!gameid2!.html" | "%~dp0BAT\busybox" sed "/DATE RELEASED/d; /<td style=/d" | "%~dp0BAT\busybox" sed "s/^.*;//g; s/<\/td>//g; s|[\t][\t][\t]*||g; s/\s*$//" | "%~dp0BAT\busybox" sed -e "2,20d" > "%~dp0TMP\RELEASE.txt" & set /P RELEASETMP=<"%~dp0TMP\RELEASE.txt"
    REM "%~dp0BAT\busybox" grep -A2 "REGION" "%~dp0TMP\!gameid2!.html" | "%~dp0BAT\busybox" sed "/REGION/d; /<td style=/d" | "%~dp0BAT\busybox" sed "s/^.*;//g; s/<\/td>//g; s|[\t][\t][\t]*||g; s/\s*$//" | "%~dp0BAT\busybox" sed -e "2,20d" > "%~dp0TMP\REGION.txt" & set /P REGIONTMP=<"%~dp0TMP\REGION.txt"
	"%~dp0BAT\busybox" grep -A2 "DEVELOPER" "%~dp0TMP\!gameid2!.html" | "%~dp0BAT\busybox" sed "/DEVELOPER<\/td>/d; /<td style=/d" | "%~dp0BAT\busybox" sed "s/^.*;//g; s/<\/td>//g; s|[\t][\t][\t]*||g; s/\s*$//" | "%~dp0BAT\busybox" sed -e "2,20d" > "%~dp0TMP\DEVELOPER.txt" & set /P DEVELOPERTMP=<"%~dp0TMP\DEVELOPER.txt"
    "%~dp0BAT\busybox" grep -A2 "PUBLISHER" "%~dp0TMP\!gameid2!.html" | "%~dp0BAT\busybox" sed "/PUBLISHER<\/td>/d; /<td style=/d" | "%~dp0BAT\busybox" sed "s/^.*;//g; s/<\/td>//g; s|[\t][\t][\t]*||g; s/\s*$//" | "%~dp0BAT\busybox" sed -e "2,20d" > "%~dp0TMP\PUBLISHER.txt" & set /P PUBLISHERTMP=<"%~dp0TMP\PUBLISHER.txt"
	"%~dp0BAT\busybox" grep -A2 "GENRE" "%~dp0TMP\!gameid2!.html" | "%~dp0BAT\busybox" sed "/GENRE/d; /<td style=/d" | "%~dp0BAT\busybox" sed "s/^.*;//g; s/<\/td>//g; s|[\t][\t][\t]*||g; s/\s*$//" | "%~dp0BAT\busybox" sed -e "2,20d" > "%~dp0TMP\GENRE.txt" & set /P GENRETMP=<"%~dp0TMP\GENRE.txt"
	 
	 REM Game ID with PBPX other region than JAP
	 set "REGIONTMP="
     if "!gameid!"=="PBPX_952.10" set REGIONTMP=U
     if "!gameid!"=="PBPX_952.16" set REGIONTMP=U
     if "!gameid!"=="PBPX_952.18" set REGIONTMP=U
     if "!gameid!"=="PBPX_952.19" set REGIONTMP=E
     if "!gameid!"=="PBPX_952.23" set REGIONTMP=U
     if "!gameid!"=="PBPX_952.47" set REGIONTMP=U
     if "!gameid!"=="PBPX_952.48" set REGIONTMP=U
     if "!gameid!"=="PBPX_955.17" set REGIONTMP=U
     if "!gameid!"=="PBPX_952.04" set REGIONTMP=E
     if "!gameid!"=="PBPX_952.05" set REGIONTMP=E
     if "!gameid!"=="PBPX_952.08" set REGIONTMP=E
     if "!gameid!"=="PBPX_952.09" set REGIONTMP=E
     if "!gameid!"=="PBPX_952.20" set REGIONTMP=E
     if "!gameid!"=="PBPX_952.39" set REGIONTMP=U
     if "!gameid!"=="PBPX_952.42" set REGIONTMP=U
     if "!gameid!"=="PBPX_952.46" set REGIONTMP=U
     if "!gameid!"=="PBPX_955.03" set REGIONTMP=U
     if "!gameid!"=="PBPX_955.06" set REGIONTMP=E
     if "!gameid!"=="PBPX_955.14" set REGIONTMP=E
     if "!gameid!"=="PBPX_955.19" set REGIONTMP=U
     if "!gameid!"=="PBPX_955.20" set REGIONTMP=E
	 
	 if not defined REGIONTMP (
	 echo !gameid!| "%~dp0BAT\busybox" cut -c3-3 > "%~dp0TMP\RegionID.txt" & set /P regionID=<"%~dp0TMP\RegionID.txt"
	 REM A = Asia
	 if "!regionID!"=="A" "%~dp0BAT\busybox" sed -ie "s/A/A/g" "%~dp0TMP\RegionID.txt" & set /P REGIONTMP=<"%~dp0TMP\RegionID.txt"
	 REM C = China
     if "!regionID!"=="C" "%~dp0BAT\busybox" sed -ie "s/C/C/g" "%~dp0TMP\RegionID.txt" & set /P REGIONTMP=<"%~dp0TMP\RegionID.txt"
	 REM E = Europe
	 if "!regionID!"=="E" "%~dp0BAT\busybox" sed -ie "s/E/E/g" "%~dp0TMP\RegionID.txt" & set /P REGIONTMP=<"%~dp0TMP\RegionID.txt"
	 REM K = Korean
	 if "!regionID!"=="K" "%~dp0BAT\busybox" sed -ie "s/K/K/g" "%~dp0TMP\RegionID.txt" & set /P REGIONTMP=<"%~dp0TMP\RegionID.txt"
	 REM P = Japan
	 if "!regionID!"=="P" "%~dp0BAT\busybox" sed -ie "s/P/J/g" "%~dp0TMP\RegionID.txt" & set /P REGIONTMP=<"%~dp0TMP\RegionID.txt"
	 REM UC = North America
	 if "!regionID!"=="U" "%~dp0BAT\busybox" sed -ie "s/U/U/g" "%~dp0TMP\RegionID.txt" & set /P REGIONTMP=<"%~dp0TMP\RegionID.txt"
	 )
	 REM Unknown region
	 if not defined REGIONTMP set REGIONTMP=X
     
	 REM PSBBN Original Date format
	 if defined RELEASETMP echo !RELEASETMP!| "%~dp0BAT\busybox" sed -E "s/January/01/g; s/February/02/g; s/March/03/g; s/April/04/g; s/May/05/g; s/June/06/g; s/July/07/g; s/August/08/g; s/September/09/g; s/October/10/g; s/November/11/g; s/December/12/g" > "%~dp0TMP\RELEASEBBN.txt" & "%~dp0BAT\busybox" sed -i "s/^\([1-9]\) /0\1 /g; s/ //g; s/\(.\{2\}\)\(.\{2\}\)\(.\{4\}\)/\3\2\1/" "%~dp0TMP\RELEASEBBN.txt" & set /P RELEASEBBN=<"%~dp0TMP\RELEASEBBN.txt"
	
	 
	 call "%~dp0BAT\Translation_words.bat"
		 
	 if not defined dbtitleTMP (
	 echo\
	 echo Game Title not found in database, please enter a game title
	 set /p "dbtitleTMP=Enter the game title:"
	 )
     echo "!dbtitleTMP!"| "%~dp0BAT\busybox" sed -e "s/\&/\\\&/g; s./.\\\/.g" | "%~dp0BAT\busybox" iconv -f windows-1252 -t utf-8 > "%~dp0TMP\dbtitle.txt"
	 "%~dp0BAT\busybox" sed -i "s/\"//g" "%~dp0TMP\dbtitle.txt"
	 set /P dbtitle=<"%~dp0TMP\dbtitle.txt"
	 
	 if not defined REGIONTMP (
	 echo\
	 echo Region not found in the database, please enter a region letter: A/C/E/J/K/U
	 echo A = Asia
	 echo C = China
	 echo E = Europe
	 echo J = Japan
	 echo K = Korean
	 echo U = North America
	 set /p "REGIONTMP=Enter the Region:"
     )
	 echo "!REGIONTMP!"| "%~dp0BAT\busybox" sed -e "s/\&/\\\&/g; s./.\\\/.g" | "%~dp0BAT\busybox" iconv -f windows-1252 -t utf-8 > "%~dp0TMP\REGION.txt"
	 "%~dp0BAT\busybox" sed -i "s/\"//g" "%~dp0TMP\REGION.txt"
	 set /P REGION=<"%~dp0TMP\REGION.txt"
	 
	 if not defined RELEASETMP (
	 echo\
	 echo Release date not found in database, please enter a Release Date: 4 March 2000 ^(Optional^)
	 set /p "RELEASETMP=Enter the Release:"
	 )
     echo "!RELEASETMP!"| "%~dp0BAT\busybox" sed -e "s/\&/\\\&/g; s./.\\\/.g" | "%~dp0BAT\busybox" iconv -f windows-1252 -t utf-8 > "%~dp0TMP\RELEASE.txt"
	 "%~dp0BAT\busybox" sed -i "s/\"//g" "%~dp0TMP\RELEASE.txt"
	 set /P RELEASE=<"%~dp0TMP\RELEASE.txt"
	 if not defined RELEASEBBN set /P RELEASEBBN=<"%~dp0TMP\RELEASE.txt"
	 
	 if not defined DEVELOPERTMP (
	 echo\
	 echo Developer not found in database, please enter a Developer ^(Optional^)
	 set /p "DEVELOPERTMP=Enter the Developer:"
	 )
     echo "!DEVELOPERTMP!"| "%~dp0BAT\busybox" sed -e "s/\&/\\\&/g; s./.\\\/.g" | "%~dp0BAT\busybox" iconv -f windows-1252 -t utf-8 > "%~dp0TMP\DEVELOPER.txt"
	 "%~dp0BAT\busybox" sed -i "s/\"//g" "%~dp0TMP\DEVELOPER.txt"
	 set /P DEVELOPER=<"%~dp0TMP\DEVELOPER.txt"
	 
	 if not defined PUBLISHERTMP (
	 echo\
	 echo Publisher not found in database, please enter a Publisher ^(Optional^)
	 set /p "PUBLISHERTMP=Enter the Publisher:"
	 )
     echo "!PUBLISHERTMP!"| "%~dp0BAT\busybox" sed -e "s/\&/\\\&/g; s./.\\\/.g" | "%~dp0BAT\busybox" iconv -f windows-1252 -t utf-8 > "%~dp0TMP\PUBLISHER.txt"
	 "%~dp0BAT\busybox" sed -i "s/\"//g" "%~dp0TMP\PUBLISHER.txt"
	 set /P PUBLISHER=<"%~dp0TMP\PUBLISHER.txt"
	 
	 if not defined GENRETMP (
	 echo\
	 echo Genre not found in database, please enter Genre: Action, Racing, RPG ^(Optional^)
	 set /p "GENRETMP=Enter the Genre:"
	 echo\
	 )
     echo "!GENRETMP!"| "%~dp0BAT\busybox" sed -e "s/\&/\\\&/g; s./.\\\/.g" | "%~dp0BAT\busybox" iconv -f windows-1252 -t utf-8 > "%~dp0TMP\GENRE.txt"
	 "%~dp0BAT\busybox" sed -i "s/\"//g" "%~dp0TMP\GENRE.txt"
	 set /P GENRE=<"%~dp0TMP\GENRE.txt"
	 
     "%~dp0BAT\busybox" sed -i -e "s/title =.*/title =/g; s/title =/title = !dbtitle!/g" "%~dp0TMP\PP.HEADER\res\info.sys"
 	 "%~dp0BAT\busybox" sed -i -e "s/title_id =.*/title_id =/g; s/title_id =/title_id = !gameid2!/g" "%~dp0TMP\PP.HEADER\res\info.sys"
	 "%~dp0BAT\busybox" sed -i -e "s/area =.*/area =/g; s/area =/area = !REGION!/g" "%~dp0TMP\PP.HEADER\res\info.sys"
	 "%~dp0BAT\busybox" sed -i -e "s/release_date =.*/release_date =/g; s/release_date =/release_date = !RELEASEBBN!/g" "%~dp0TMP\PP.HEADER\res\info.sys"
     "%~dp0BAT\busybox" sed -i -e "s/developer_id =.*/developer_id =/g; s/developer_id =/developer_id = !DEVELOPER!/g" "%~dp0TMP\PP.HEADER\res\info.sys"
	 "%~dp0BAT\busybox" sed -i -e "s/publisher_id =.*/publisher_id =/g; s/publisher_id =/publisher_id = !PUBLISHER!/g" "%~dp0TMP\PP.HEADER\res\info.sys"
     "%~dp0BAT\busybox" sed -i -e "s/genre =.*/genre =/g; s/genre =/genre = !GENRE!/g" "%~dp0TMP\PP.HEADER\res\info.sys"
	 
	 REM Manual
	 "%~dp0BAT\busybox" sed -i -e "s/label=\"APPNAME\"/label=\"!dbtitle!\"/g" "%~dp0TMP\PP.HEADER\res\man.xml"

echo        Provided by psxdatacenter.com
"%~dp0BAT\Diagbox" gd 0e
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03

	echo Title:     [!dbtitleTMP!]
	echo Gameid:    [!gameid2!]
	echo Region:    [!REGIONTMP!]
	echo Release:   [!RELEASETMP!]
	echo Developer: [!DEVELOPERTMP!]
	echo Publisher: [!PUBLISHERTMP!]
	echo Genre:     [!GENRETMP!]

"%~dp0BAT\Diagbox" gd 0e
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0f

     echo            Downloading resources...
     IF !DownloadART!==yes "%~dp0BAT\wget" -q --show-progress "https://archive.org/download/OPLM_ART_2023_11/OPLM_ART_2023_11.zip/PS2%%2F!gameid!%%2F!gameid!_COV.jpg" -O "%~dp0TMP\jkt_001.jpg" >nul 2>&1
	 IF !uselocalART!==yes if exist "%~dp0ART.zip" "%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0ART.zip" -o"%~dp0TMP" PS2\!gameid!\!gameid!_COV.jpg -r -y & move "%~dp0TMP\PS2\!gameid!\!gameid!_COV.jpg" "%~dp0TMP\jkt_001.jpg" >nul 2>&1
	 IF !DownloadART!==yes "%~dp0BAT\wget" -q --show-progress "https://archive.org/download/OPLM_ART_2023_11/OPLM_ART_2023_11.zip/PS2%%2F!gameid!%%2F!gameid!_BG_00.jpg" -O "%~dp0TMP\BG.jpg" >nul 2>&1
	 IF !uselocalART!==yes if exist "%~dp0ART.zip" "%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0ART.zip" -o"%~dp0TMP" PS2\!gameid!\!gameid!_BG_00.jpg -r -y & move "%~dp0TMP\PS2\!gameid!\!gameid!_BG_00.jpg" "%~dp0TMP\BG.jpg" >nul 2>&1
	 IF !DownloadART!==yes "%~dp0BAT\wget" -q --show-progress "https://archive.org/download/OPLM_ART_2023_11/OPLM_ART_2023_11.zip/PS2%%2F!gameid!%%2F!gameid!_LGO.png" -O "%~dp0TMP\jkt_cp.png" >nul 2>&1
	 IF !uselocalART!==yes if exist "%~dp0ART.zip" "%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0ART.zip" -o"%~dp0TMP" PS2\!gameid!\!gameid!_LGO.png -r -y & move "%~dp0TMP\PS2\!gameid!\!gameid!_LGO.png" "%~dp0TMP\jkt_cp.png" >nul 2>&1
	 IF !DownloadART!==yes "%~dp0BAT\wget" -q --show-progress "https://archive.org/download/OPLM_ART_2023_11/OPLM_ART_2023_11.zip/PS2%%2F!gameid!%%2F!gameid!_SCR_00.jpg" -O "%~dp0TMP\SCR0.jpg" >nul 2>&1
	 IF !uselocalART!==yes if exist "%~dp0ART.zip" "%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0ART.zip" -o"%~dp0TMP" PS2\!gameid!\!gameid!_SCR_00.jpg -r -y & move "%~dp0TMP\PS2\!gameid!\!gameid!_SCR_00.jpg" "%~dp0TMP\SCR0.jpg" >nul 2>&1
	 IF !DownloadART!==yes "%~dp0BAT\wget" -q --show-progress "https://archive.org/download/OPLM_ART_2023_11/OPLM_ART_2023_11.zip/PS2%%2F!gameid!%%2F!gameid!_SCR_01.jpg" -O "%~dp0TMP\SCR1.jpg" >nul 2>&1
	 IF !uselocalART!==yes if exist "%~dp0ART.zip" "%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0ART.zip" -o"%~dp0TMP" PS2\!gameid!\!gameid!_SCR_01.jpg -r -y & move "%~dp0TMP\PS2\!gameid!\!gameid!_SCR_01.jpg" "%~dp0TMP\SCR1.jpg" >nul 2>&1
	 REM IF !uselocalART!==yes "%~dp0BAT\wget" -q --show-progress "https://archive.org/download/OPLM_ART_2023_11/OPLM_ART_2023_11.zip/PS2%%2F!gameid!%%2F!gameid!_SCR_02.jpg" -O "%~dp0TMP\SCR2.jpg" >nul 2>&1
	 REM IF !DownloadART!==yes "%~dp0BAT\wget" -q --show-progress "https://archive.org/download/OPLM_ART_2023_11/OPLM_ART_2023_11.zip/PS2%%2F!gameid!%%2F!gameid!_SCR_03.jpg" -O "%~dp0TMP\SCR3.jpg" >nul 2>&1
	 
	 REM ART CUSTOM GAMEID
	 "%~dp0BAT\7-Zip\7z" e -bso0 "%~dp0BAT\ART_CUSTOM_GAMEID.zip" -o"%~dp0TMP\PS2\!gameid!" PS2\!gameid!_COV.jpg -r -y >nul 2>&1 & move "%~dp0TMP\PS2\!gameid!\!gameid!_COV.jpg" "%~dp0TMP\jkt_001.jpg" >nul 2>&1
	 for %%F in (*.jpg *.png) do if %%~zF==0 del "%%F"
	 
	 cd "%~dp0TMP" & for %%F in (*.jpg *.png) do if %%~zF==0 del "%%F"

	 REM Covers
	 if exist "%~dp0TMP\jkt_001.jpg" "%~dp0BAT\nconvert" -overwrite -out png -resize 256 256 -rtype lanczos -efocus -o "%~dp0TMP\PP.HEADER\res\jkt_001.png" "%~dp0TMP\jkt_001.jpg" >nul 2>&1
	 if exist "%~dp0TMP\jkt_001.jpg" "%~dp0BAT\nconvert" -overwrite -out png -resize 76 108 -rtype lanczos -efocus -o "%~dp0TMP\PP.HEADER\res\jkt_002.png" "%~dp0TMP\jkt_001.jpg" >nul 2>&1
	 if exist "%~dp0TMP\jkt_cp.png" move "%~dp0TMP\jkt_cp.png" "%~dp0TMP\PP.HEADER\res\jkt_cp.png" >nul 2>&1
	 
	 REM Screenshot
	 if exist "%~dp0TMP\BG.jpg" "%~dp0BAT\nconvert" -overwrite -out png -resize 640 350 -efocus -o "%~dp0TMP\PP.HEADER\res\image\0.png" "%~dp0TMP\BG.jpg" >nul 2>&1
     if exist "%~dp0TMP\SCR0.jpg" "%~dp0BAT\nconvert" -overwrite -out png -resize 640 350 -rtype lanczos -efocus -o "%~dp0TMP\PP.HEADER\res\image\1.png" "%~dp0TMP\SCR0.jpg" >nul 2>&1
	 if exist "%~dp0TMP\SCR1.jpg" "%~dp0BAT\nconvert" -overwrite -out png -resize 640 350 -rtype lanczos -efocus -o "%~dp0TMP\PP.HEADER\res\image\2.png" "%~dp0TMP\SCR1.jpg" >nul 2>&1
	 REM if exist "%~dp0TMP\SCR2.jpg" "%~dp0BAT\nconvert" -overwrite -out png -resize 640 350 -rtype lanczos -efocus -o "%~dp0TMP\PP.HEADER\res\image\3.png" "%~dp0TMP\SCR2.jpg" >nul 2>&1
	 REM if exist "%~dp0TMP\SCR3.jpg" "%~dp0BAT\nconvert" -overwrite -out png -resize 640 350 -rtype lanczos -efocus -o "%~dp0TMP\PP.HEADER\res\image\4.png" "%~dp0TMP\SCR3.jpg" >nul 2>&1
     for %%f in (*.jpg *.png) do (del "%%f")
	 
     echo            Inject Header...
	 cd /d "%~dp0TMP\PP.HEADER"
	 
	 "%~dp0BAT\busybox" sed -i "1 s/^.*$/BOOT2 = pfs:\/EXECUTE.KELF/" "%~dp0TMP\PP.HEADER\system.cnf"
     hdl_dump modify_header %@hdl_path% "!PPNameHeader!" >nul 2>&1
	 hdl_dump modify %@hdl_path% "!PPNameHeader!" -hide
     
	 REM Only for hidden partition
	 echo !PPNameHeader!| "%~dp0BAT\busybox" sed -e "s/__\./PP\./g" > "%~dp0TMP\PPBBNXMB.txt" & set /P PPNameHeader2=<"%~dp0TMP\PPBBNXMB.txt"
	 
	 echo            Inject PFS Resources...
	 echo device %@pfsshell_path% > "%~dp0TMP\pfs-headerbbn.txt"
	 echo mkpart "!PPNameHeader2!" 128M PFS >> "%~dp0TMP\pfs-headerbbn.txt"
	 echo mount "!PPNameHeader2!" >> "%~dp0TMP\pfs-headerbbn.txt"
	 echo lcd "%~dp0TMP\PP.HEADER" >> "%~dp0TMP\pfs-headerbbn.txt"
	 echo put EXECUTE.KELF >> "%~dp0TMP\pfs-headerbbn.txt"
	 echo lcd "%~dp0TMP\PP.HEADER\res" >> "%~dp0TMP\pfs-headerbbn.txt"
	 echo mkdir res >> "%~dp0TMP\pfs-headerbbn.txt"
	 echo cd res >> "%~dp0TMP\pfs-headerbbn.txt"
	 
	 cd /d "%~dp0TMP\PP.HEADER\res"
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
	 cd /d "%~dp0TMP\PP.HEADER" & hdl_dump modify_header %@hdl_path% "!PPNameHeader2!" >nul 2>&1
	 echo            Completed...
     )
	 
if defined checkOPL (

	 REM echo            Checking OPL Files... 
     echo device !@pfsshell_path! > "%~dp0TMP\pfs-OPLconfig.txt"
     echo mount __common >> "%~dp0TMP\pfs-OPLconfig.txt"
	 echo cd OPL >> "%~dp0TMP\pfs-OPLconfig.txt"
     echo get conf_hdd.cfg >> "%~dp0TMP\pfs-OPLconfig.txt"
	 echo cd .. >> "%~dp0TMP\pfs-OPLconfig.txt"
     echo umount >> "%~dp0TMP\pfs-OPLconfig.txt"
	 echo mount +OPL >> "%~dp0TMP\pfs-OPLconfig.txt"
	 echo cd OPL >> "%~dp0TMP\pfs-OPLconfig.txt"
	 echo ls >> "%~dp0TMP\pfs-OPLconfig.txt"
	 echo cd .. >> "%~dp0TMP\pfs-OPLconfig.txt"
	 echo umount >> "%~dp0TMP\pfs-OPLconfig.txt"
	 echo exit >> "%~dp0TMP\pfs-OPLconfig.txt"
     type "%~dp0TMP\pfs-OPLconfig.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" grep -ie "OPNPS2LD.ELF" > "%~dp0TMP\OPLELF.txt" 2>&1 & set /P OPLELF=<"%~dp0TMP\OPLELF.txt"

	 if not exist conf_hdd.cfg (
	 copy "%~dp0HDD-OSD\__common\OPL\conf_hdd.cfg" "%~dp0TMP\PP.HEADER" >nul 2>&1
	 echo device !@pfsshell_path! > "%~dp0TMP\pfs-OPLconfig.txt"
     echo mount __common >> "%~dp0TMP\pfs-OPLconfig.txt"
     echo cd OPL >> "%~dp0TMP\pfs-OPLconfig.txt"
     echo put conf_hdd.cfg >> "%~dp0TMP\pfs-OPLconfig.txt"
	 echo cd .. >> "%~dp0TMP\pfs-OPLconfig.txt"
	 echo umount >> "%~dp0TMP\pfs-OPLconfig.txt"
	 
	 if not defined OPLELF (
	 copy "%~dp0HDD-OSD\OPNPS2LD.ELF" "%~dp0TMP\PP.HEADER" >nul 2>&1
     echo mount +OPL >> "%~dp0TMP\pfs-OPLconfig.txt"
	 echo put OPNPS2LD.ELF >> "%~dp0TMP\pfs-OPLconfig.txt"
	 echo cd .. >> "%~dp0TMP\pfs-OPLconfig.txt"
	 echo umount >> "%~dp0TMP\pfs-OPLconfig.txt"
	 )
	 
     echo exit >> "%~dp0TMP\pfs-OPLconfig.txt"
     type "%~dp0TMP\pfs-OPLconfig.txt" | "%~dp0BAT\pfsshell" >nul 2>&1
	 
	 ) else (
	 "%~dp0BAT\busybox" grep "hdd_partition=" "%~dp0TMP\PP.HEADER\conf_hdd.cfg" | "%~dp0BAT\busybox" sed "s/^.*=//" > "%~dp0TMP\OPLPATH.txt" & set /P OPLPATH=<"%~dp0TMP\OPLPATH.txt"
		 
	 if not defined OPLELF (
	 copy "%~dp0HDD-OSD\OPNPS2LD.ELF" "%~dp0TMP\PP.HEADER" >nul 2>&1
	 echo device !@pfsshell_path! > "%~dp0TMP\pfs-OPLconfig.txt"
     echo mount !OPLPATH! >> "%~dp0TMP\pfs-OPLconfig.txt"
     echo cd OPL >> "%~dp0TMP\pfs-OPLconfig.txt"
	 echo put OPNPS2LD.ELF >> "%~dp0TMP\pfs-OPLconfig.txt"
	 echo cd .. >> "%~dp0TMP\pfs-OPLconfig.txt"
	 echo umount >> "%~dp0TMP\pfs-OPLconfig.txt"
     echo exit >> "%~dp0TMP\pfs-OPLconfig.txt"
     type "%~dp0TMP\pfs-OPLconfig.txt" | "%~dp0BAT\pfsshell" >nul 2>&1
	  )
     )
)

if !ShowPS2Games!==Unconvert (
"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo !PPNameHeader!
echo ----------------------------------------------------
echo\
"%~dp0BAT\Diagbox" gd 0f

copy "%~dp0BAT\system.cnf" "%~dp0TMP\PP.HEADER" >nul 2>&1
copy "%~dp0BAT\hdl_dump.exe" "%~dp0TMP\PP.HEADER" >nul 2>&1

     echo !PPNameHeader!| "%~dp0BAT\busybox" sed -e "s/__\./PP\./g" > "%~dp0TMP\PPBBNXMB.txt" & set /P PPNameHeader=<"%~dp0TMP\PPBBNXMB.txt"
	 
     echo            Undo partition conversion...
	 echo device %@pfsshell_path% > "%~dp0TMP\pfs-headerbbn.txt"
	 echo rmpart "!PPNameHeader!" >> "%~dp0TMP\pfs-headerbbn.txt"
	 echo exit >> "%~dp0TMP\pfs-headerbbn.txt"
	 type "%~dp0TMP\pfs-headerbbn.txt" | "%~dp0BAT\pfsshell" >nul 2>&1

     echo !PPNameHeader!| "%~dp0BAT\busybox" sed -e "s/PP\./__\./g" > "%~dp0TMP\PPBBNXMB.txt" & set /P PPNameHeader=<"%~dp0TMP\PPBBNXMB.txt"
     cd /d "%~dp0TMP\PP.HEADER" & hdl_dump modify_header %@hdl_path% "!PPNameHeader!" >nul 2>&1
	 hdl_dump modify %@hdl_path% "!PPNameHeader!" -unhide >nul 2>&1
	 
	 echo            Completed...
     )
	
	REM Reloading HDD Cache
    call "%~dp0BAT\__ReloadHDD_cache.bat" >nul 2>&1
	REM "%~dp0BAT\busybox" sed -i "$d" "%~dp0BAT\__Cache\PS2_GAMES_HDD.txt" & "%~dp0BAT\busybox" tail -n 1 "%~dp0BAT\__Cache\PARTITION_PS2HDD.txt" | "%~dp0BAT\busybox" sed -e "$s/Total slice size:/total/g; $s/used:/used/g; $s/available:/available/g" >> "%~dp0BAT\__Cache\PS2_GAMES_HDD.txt"

cd /d "%~dp0" & rmdir /Q/S "%~dp0TMP" >nul 2>&1
chcp 1252 >nul 2>&1

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo Completed...
echo\
echo\
"%~dp0BAT\Diagbox" gd 07

pause & (goto HDDOSDPartManagement)
REM ##################################################################################################################################################
:pphide_unhide
cls
mkdir "%~dp0TMP" >nul 2>&1

IF NOT DEFINED @hdl_path ( rmdir /Q/S "%~dp0TMP" >nul 2>&1 & goto ScanningPS2HDD ) else (
"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning for Playstation 2 HDDs:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "!@hdl_path!" | "%~dp0BAT\busybox" grep "Playstation 2 HDD" >nul
if errorlevel 1 set "@hdl_path=" & goto ScanningPS2HDD
echo       [!@hdl_path! !@TotalHDD_Size! - !@ModelePS2HDD!]
)

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo !Pfs_Part_Option! PS2 Game partition in HDD-OSD:
echo ----------------------------------------------------
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
echo ----------------------------------------------------

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
echo ----------------------------------------------------

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
echo ----------------------------------------------------
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
echo ----------------------------------------------------
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
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "!@hdl_path!" | "%~dp0BAT\busybox" grep "Playstation 2 HDD" >nul
if errorlevel 1 set "@hdl_path=" & goto ScanningPS2HDD
echo       [!@hdl_path! !@TotalHDD_Size! - !@ModelePS2HDD!]
)

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Rename a title partitions:
echo ----------------------------------------------------
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
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "!@hdl_path!" | "%~dp0BAT\busybox" grep "Playstation 2 HDD" >nul
if errorlevel 1 set "@hdl_path=" & goto ScanningPS2HDD
echo       [!@hdl_path! !@TotalHDD_Size! - !@ModelePS2HDD!]
)
	
"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Dump or Inject Header:
echo ----------------------------------------------------
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
echo ----------------------------------------------------
echo         1^) Partition PS1 Games
echo         2^) Partition PS2 Games
echo         3^) Partition APP System
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
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03

if "!ShowPartitionList!"=="PS1 Games" type "%~dp0BAT\__Cache\PARTITION_POPS_GAME.txt" | "%~dp0BAT\busybox" sort -k2 > "%~dp0TMP\PARTITION_!ShowPartitionList!.txt"
if "!ShowPartitionList!"=="PS2 Games" type "%~dp0BAT\__Cache\PARTITION_HDL_GAME.txt" | "%~dp0BAT\busybox" sort -k2 > "%~dp0TMP\PARTITION_!ShowPartitionList!.txt"
if "!ShowPartitionList!"=="APP System" type "%~dp0BAT\__Cache\PARTITION_APPS.txt" | "%~dp0BAT\busybox" sort -k2 > "%~dp0TMP\PARTITION_!ShowPartitionList!.txt"
if "!ShowPartitionList!"=="System" (

type "%~dp0BAT\__Cache\PARTITION_HDL_GAME.txt" | "%~dp0BAT\busybox" sed "s/^[^|]*|//g; s/__\./PP\./g" > "%~dp0TMP\PARTITION_HDL_GAME.txt"
"%~dp0BAT\busybox" grep -e "0x0100" "%~dp0BAT\__Cache\PARTITION_PS2HDD.txt" | "%~dp0BAT\busybox" grep -e "PP\." | "%~dp0BAT\busybox" sed "/\.POPS\./d; /PP.APPS-/d" | "%~dp0BAT\busybox" cut -c30-250 > "%~dp0TMP\PARTITION_!ShowPartitionList!.txt"

 for /f "usebackq" %%A  in ("%~dp0TMP\PARTITION_!ShowPartitionList!.txt") do (
 "%~dp0BAT\busybox" grep "%%A" "%~dp0TMP\PARTITION_HDL_GAME.txt" >nul
	if errorlevel 1 (echo >nul) else ("%~dp0BAT\busybox" sed -i "/%%A/d" "%~dp0TMP\PARTITION_!ShowPartitionList!.txt")
	)
)
"%~dp0BAT\busybox" sed "s/|.*//" "%~dp0TMP\PARTITION_!ShowPartitionList!.txt" > "%~dp0TMP\PARTITION_TMP.txt" & type "%~dp0TMP\PARTITION_TMP.txt"

"%~dp0BAT\Diagbox" gd 0e
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0f

    if "!ShowPartitionList!"=="PS2 Games" echo NOTE: PFS partitions header with prefix PP. will be linked to the __. HDL partition automatically
    echo\
	"%~dp0BAT\Diagbox" gd 0e
	echo Please type the gameid ^+ GameName as shown in the Games List.
	"%~dp0BAT\Diagbox" gd 07
    set /p PPNameHeader=
    IF "!PPNameHeader!"=="" (goto HDDOSDPartManagement)
	"%~dp0BAT\busybox" grep -Fx "!PPNameHeader!" "%~dp0TMP\PARTITION_TMP.txt" >nul
	if errorlevel 1 (set "PPNameHeader=!PPNameHeader!") else ("%~dp0BAT\busybox" grep "!PPNameHeader!" "%~dp0TMP\PARTITION_!ShowPartitionList!.txt" | "%~dp0BAT\busybox" sed "s/^[^|]*|//" > "%~dp0TMP\PPNameHeader.txt" & set /P PPNameHeader=<"%~dp0TMP\PPNameHeader.txt")

"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Detecting !PPNameHeader!
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 07

    "%~dp0BAT\busybox" grep -w "!PPNameHeader!" "%~dp0TMP\PARTITION_!ShowPartitionList!.txt" | "%~dp0BAT\busybox" sed "s/^[^|]*|//" > "%~dp0TMP\PPSelected.txt" & set /P PPSELECTED=<"%~dp0TMP\PPSelected.txt"
	if "!PPSELECTED!"=="!PPNameHeader!" (
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
	if errorlevel 2 (goto HDDOSDPartManagement)
	)
	
echo\
echo\
pause

cls
echo\
echo\
echo Dump !PPNameHeader! Header:
echo ----------------------------------------------------
echo\

    rmdir /Q/S "%~dp0HDD-OSD\PP.HEADER" >nul 2>&1
	echo         Extraction Header...
	REM HDL Header
	"%~dp0BAT\hdl_dump_fix_header" dump_header %@hdl_path% "!PPNameHeader!" >nul 2>&1
	echo !PPNameHeader!| "%~dp0BAT\busybox" sed -e "s/__\./PP\./g" > "%~dp0TMP\PPBBNXMB.txt" & set /P PPNameHeader2=<"%~dp0TMP\PPBBNXMB.txt"
	"%~dp0BAT\hdl_dump_fix_header" dump_header %@hdl_path% "!PPNameHeader2!" >nul 2>&1
	
	REM PFS Header
    cd "%~dp0TMP"
	echo         Extraction PFS Resources...
	echo device %@pfsshell_path% > "%~dp0TMP\pfs-log.txt"
	echo mount "!PPNameHeader2!" >> "%~dp0TMP\pfs-log.txt"
	echo cd res >> "%~dp0TMP\pfs-log.txt"
	echo ls -l >> "%~dp0TMP\pfs-log.txt"
	echo umount >> "%~dp0TMP\pfs-log.txt"
	echo exit >> "%~dp0TMP\pfs-log.txt"
	type "%~dp0TMP\pfs-log.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" grep -i -e "-rw-" -e "-rwx" | "%~dp0BAT\busybox" cut -c42-500 > "%~dp0TMP\pfs-tmp.log"

	echo device %@pfsshell_path% > "%~dp0TMP\pfs-log.txt"
	echo mount "!PPNameHeader2!" >> "%~dp0TMP\pfs-log.txt"
	echo mkdir res >> "%~dp0TMP\pfs-log.txt"
	echo cd res >> "%~dp0TMP\pfs-log.txt"
	echo mkdir image >> "%~dp0TMP\pfs-log.txt"
	echo cd image >> "%~dp0TMP\pfs-log.txt"
	echo ls -l >> "%~dp0TMP\pfs-log.txt"
	echo umount >> "%~dp0TMP\pfs-log.txt"
	echo exit >> "%~dp0TMP\pfs-log.txt"
	type "%~dp0TMP\pfs-log.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" grep -i -e "-rw-" -e "-rwx" | "%~dp0BAT\busybox" cut -c42-500 > "%~dp0TMP\pfs-tmp2.log"

	echo device %@pfsshell_path% > "%~dp0TMP\pfs-header.txt"
	echo mount "!PPNameHeader2!" >> "%~dp0TMP\pfs-header.txt"
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
	cd "%~dp0"
	)

if !PPHeader!==Inject (
cls
echo\
echo\
echo Inject !PPNameHeader! Header:
echo ----------------------------------------------------
echo\

	echo         Inject Header...
	REM HDL Header
	"%~dp0BAT\hdl_dump_fix_header" modify_header %@hdl_path% "!PPNameHeader!" >nul 2>&1
	echo !PPNameHeader!| "%~dp0BAT\busybox" sed -e "s/__\./PP\./g" > "%~dp0TMP\PPBBNXMB.txt" & set /P PPNameHeader2=<"%~dp0TMP\PPBBNXMB.txt"
	"%~dp0BAT\hdl_dump_fix_header" modify_header %@hdl_path% "!PPNameHeader2!" >nul 2>&1
	
	cd /d "%~dp0HDD-OSD\PP.HEADER\PFS"
	echo         Inject PFS Resources...
	echo device %@pfsshell_path% > "%~dp0TMP\pfs-headerbbn.txt"
	echo mount "!PPNameHeader2!" >> "%~dp0TMP\pfs-headerbbn.txt"
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
echo ----------------------------------------------------
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
for %%F in ( "%~dp0ART\*" ) do if %%~zF==0 del "%%F"
cd /d "%~dp0TMP"

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Download ARTs:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1^) Yes ^(For PS2 Games^)
"%~dp0BAT\Diagbox" gd 0c
echo         2^) No
"%~dp0BAT\Diagbox" gd 0e
echo         3^) Yes ^(For PS1 Games^)
echo         4^) Yes ^(For PS1 Games Shortcut OPL APPS TAB^)
echo\
"%~dp0BAT\Diagbox" gd 07
CHOICE /C 1234 /M "Select Option:"

IF %ERRORLEVEL%==1 set "ARTType=PS2" & set HDDPFS=Yes
IF %ERRORLEVEL%==2 (goto DownloadsMenu)
IF %ERRORLEVEL%==3 set ARTType=PS1
IF %ERRORLEVEL%==4 (

set "ARTType=PS1OPL" & set HDDPFS=Yes
echo\
"%~dp0BAT\Diagbox" gd 0e
echo What device will you be using?
"%~dp0BAT\Diagbox" gd 07
echo 1 = HDD ^(Internal^)
echo 2 = USB
CHOICE /C 12 /M "Select Option:"
if errorlevel 1 set "device=HDD" 
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
echo Example: E:\POPS\MyGame.VCD
set /p "HDDPATH=Enter the path where yours PS1 Games located:"
if "!HDDPATH!"=="" set HDDPATH=%~dp0POPS
  ) else (set HDDPATH=%~dp0POPS)
 )
)

if not defined HDDPATH set HDDPATH=%~dp0POPS
cls
if !HDDPFS!==Yes (
IF NOT DEFINED @hdl_path ( rmdir /Q/S "%~dp0TMP" >nul 2>&1 & goto ScanningPS2HDD ) else (
"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning for Playstation 2 HDDs:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "!@hdl_path!" | "%~dp0BAT\busybox" grep "Playstation 2 HDD" >nul
if errorlevel 1 set "@hdl_path=" & goto ScanningPS2HDD
echo       [!@hdl_path! !@TotalHDD_Size! - !@ModelePS2HDD!]
 )
)

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
"%~dp0BAT\Diagbox" gd 0f
if !ARTType!==PS1 echo Downloads ARTs for .VCD In the POPS folder^?
if !ARTType!==PS1OPL echo Download ARTs for PS1 APPS TAB^?
if !ARTType!==PS2 echo Download ARTs for all installed games^?
if !device!==USB set "ARTType=PS1" & set "OPLPS1APPS=Yes"
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1^) Yes
"%~dp0BAT\Diagbox" gd 0c
echo         2^) No
"%~dp0BAT\Diagbox" gd 0e
if defined HDDPFS echo         3^) Update Only Missing ART
"%~dp0BAT\Diagbox" gd 07
echo\
CHOICE /C 123 /M "Select Option:"

IF !ERRORLEVEL!==2 (goto DownloadsMenu)
if defined HDDPFS IF !ERRORLEVEL!==3 set UpdateOnlyMissingART=Yes

if exist "%~dp0ART.zip" (
echo\
"%~dp0BAT\Diagbox" gd 0e
echo ART.zip detected do you want use it?
"%~dp0BAT\Diagbox" gd 0f
CHOICE /C YN /M "Select Option:"
IF ERRORLEVEL 1 set uselocalART=yes
IF ERRORLEVEL 2 set uselocalART=no
) else (set uselocalART=no)

if !uselocalART!==no (
    echo.
	echo Checking internet Or Website connection...
	"%~dp0BAT\wget" -q --show-progress "https://archive.org/download/OPLM_ART_2023_11/OPLM_ART_2023_11.zip/PS1%%2FSCES_000.01%%2FSCES_000.01_COV.jpg" -O "%~dp0TMP\SCES_000.01_COV.jpg" >nul 2>&1
	for %%F in (SCES_000.01_COV.jpg) do if %%~zF==0 del "%%F"

if not exist SCES_000.01_COV.jpg (
"%~dp0BAT\Diagbox" gd 0c
    echo\
	echo Unable to connect to internet Or Website
	if exist "%~dp0ART.zip" (set uselocalART=yes) else (echo\ & echo\ & "%~dp0BAT\Diagbox" gd 0f & pause & goto DownloadsMenu)
	echo You will switch to offline mode
	echo\
	echo\
"%~dp0BAT\Diagbox" gd 0f
	pause
 ) else (set DownloadART=yes)
)

if !ARTType!==PS1OPL (
"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Detecting POPS Partition:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0f

    "%~dp0BAT\busybox" grep -o "__.POPS\|__.POPS[0-9]" "%~dp0BAT\__Cache\PARTITION_PS2HDD.txt" | "%~dp0BAT\busybox" sed "s/__.POPS\([0-9]\)/\1.  __.POPS\1/g; s/\__.POPS\b/10. __.POPS/" | "%~dp0BAT\busybox" sort -k2 > "%~dp0TMP\hdd-prt.txt"
    "%~dp0BAT\busybox" sed -e "/^$/d" "%~dp0TMP\hdd-prt.txt" | "%~dp0BAT\busybox" wc -l > "%~dp0TMP\TotalPOPSPart.txt" & set /P @TotalPOPSPart=<"%~dp0TMP\TotalPOPSPart.txt"
    
    if !@TotalPOPSPart! gtr 1 (
	echo.
    echo Multiple POPS partitions were detected. Please choose one.
	echo Choose the partition on which you want to analyze your VCDs
    echo In general, the default partition is __.POPS
    echo.
    type "%~dp0TMP\hdd-prt.txt"
    echo.
	
    set choice=
    set /p choice="Select Option:"
    IF "!choice!"=="" (goto DownloadsMenu) 
    
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
	echo        Partition Must Be Formatted Or Created
	echo\
	echo\
	"%~dp0BAT\Diagbox" gd 07
	rmdir /Q/S "%~dp0TMP" >nul 2>&1
	pause & (goto DownloadsMenu) 
	)

"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Detecting Dokan Driver
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0f

if exist "%HOMEDRIVE%\Windows\System32\drivers\dokan2.sys" (
"%~dp0BAT\busybox" ls "C:\Program Files\Dokan" > "%~dp0TMP\DokanFolder.txt" & set /P DokanFolder=<"%~dp0TMP\DokanFolder.txt"
	"%~dp0BAT\Diagbox" gd 0a
		echo            Dokan Driver - Detected
	"%~dp0BAT\Diagbox" gd 0f
		) else (
		"%~dp0BAT\Diagbox" gd 0c
		echo         Dokan Driver - NOT Detected
		echo          Please Install the driver
		echo\
		echo\
		rmdir /Q/S "%~dp0TMP" >nul 2>&1
		pause & (goto DownloadsMenu) 
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
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03

 if !ARTType!==PS2 type "%~dp0BAT\__Cache\PARTITION_HDL_GAME.txt" | "%~dp0BAT\busybox" sed "s/|.*//" | "%~dp0BAT\busybox" sort -k2 > "%~dp0TMP\%ARTType%Games.txt"

 if !ARTType!==PS1 (
 if not exist "!HDDPATH!\*.VCD" (
 "%~dp0BAT\Diagbox" gd 06
 cls
 echo.
 echo .VCD NOT DETECTED: Please drop .VCD IN POPS FOLDER.
 echo.
 "%~dp0BAT\Diagbox" gd 0f
 pause & (goto DownloadsMenu)
 
  ) else (
 
 For %%P in ( "!HDDPATH!\*.VCD" ) do (
 
     "%~dp0BAT\POPS-VCD-ID-Extractor" "%%P" 2>&1 | "%~dp0BAT\busybox" sed -e "s/-/_/g" >> "%~dp0TMP\VCDID.txt"
     set "ELFNOTFOUND="
     "%~dp0BAT\busybox" grep -o -m 1 "regex couldn't find" "%~dp0TMP\VCDID.txt" > "%~dp0TMP\ELFNOTFOUND.TXT" & set /p ELFNOTFOUND=<"%~dp0TMP\ELFNOTFOUND.TXT"
     
 	if defined ELFNOTFOUND (
 	"%~dp0BAT\busybox" grep -o -m 1 "SLPS-02414" "%%P" | "%~dp0BAT\busybox" sed "s/-/_/g" | "%~dp0BAT\busybox" sed "s/.\{8\}/&./" | "%~dp0BAT\busybox" head -1 >> "%~dp0TMP\VCDID.txt" & "%~dp0BAT\busybox" sed -i "/regex couldn't find/d" "%~dp0TMP\VCDID.txt"
     "%~dp0BAT\busybox" grep -o -m 1 "SLUSP013.46" "%%P" | "%~dp0BAT\busybox" sed "s/-/_/g; s/SLUSP013\.46/SLUS_01346/g" | "%~dp0BAT\busybox" sed "s/.\{8\}/&./" | "%~dp0BAT\busybox" head -1 >> "%~dp0TMP\VCDID.txt" & "%~dp0BAT\busybox" sed -i "/regex couldn't find/d" "%~dp0TMP\VCDID.txt"
 	)
 )
 
 "%~dp0BAT\busybox" sed -i -e "s/-/_/g" "%~dp0TMP\VCDID.txt"
 "%~dp0BAT\busybox" ls "!HDDPATH!" | "%~dp0BAT\busybox" grep -ie ".*\.VCD$" > "%~dp0TMP\Name.txt"
 "%~dp0BAT\busybox" paste -d " " "%~dp0TMP\VCDID.txt" "%~dp0TMP\Name.txt" > "%~dp0TMP\VCDIDNameTMP.txt"
 "%~dp0BAT\busybox" sed "s/.\{12\}/& /" "%~dp0TMP\VCDIDNameTMP.txt" > "%~dp0TMP\%ARTType%Games.txt"
  )
 )
 
if !ARTType!==PS1OPL (

   set ARTType=PS1
   set OPLPS1APPS=Yes
   wmic logicaldisk get caption | "%~dp0BAT\busybox" grep -o "[A-Z]:" | "%~dp0BAT\busybox" grep -o "[A-Z]" > "%~dp0TMP\LTR.txt"
   "C:\Program Files\Dokan\!DokanFolder!\dokanctl.exe" /l a >nul 2>&1 | "%~dp0BAT\busybox" grep -o "DosDevices\\[A-Z]:" | "%~dp0BAT\busybox" cut -c12-12 >> "%~dp0TMP\LTR.txt"
   
   echo ABCDEFGHIJKLMNOPQRSTUVWXYZ> "%~dp0TMP\LTRFree.txt"
   for /f "usebackq tokens=*" %%a in ("%~dp0TMP\LTR.txt") do "%~dp0BAT\busybox" sed -i "s/%%a//g" "%~dp0TMP\LTRFree.txt"
   "%~dp0BAT\busybox" cut -c0-1 "%~dp0TMP\LTRFree.txt" > "%~dp0TMP\LTRSelected.txt" & set /P DeviceLTR=<"%~dp0TMP\LTRSelected.txt"
   
   START /MIN CMD.EXE /C ""%~dp0BAT\pfsfuse" "--partition=__.POPS!choice!" !@pfsshell_path! !DeviceLTR! -o "volname=!POPSPART!""
   
   :loopdrivePS1Shortcut
   wmic logicaldisk get deviceid^,drivetype | "%~dp0BAT\busybox" grep -o "!DeviceLTR!:"> "%~dp0TMP\WINDOWLTR.TXT" & set /P WINDOWLTR=<"%~dp0TMP\WINDOWLTR.txt"
   if "!WINDOWLTR!"=="!DeviceLTR!:" goto exitloopdrivePS1Shortcut
   goto loopdrivePS1Shortcut
   :exitloopdrivePS1Shortcut
  cd /d "!DeviceLTR!:"
  for %%f in (*.VCD) do (
  
  setlocal DisableDelayedExpansion
  set filename=%%f
  set fname=%%~nf
  setlocal EnableDelayedExpansion
	
  "%~dp0BAT\POPS-VCD-ID-Extractor" "!fname!.VCD" 2>&1 | "%~dp0BAT\busybox" sed -e "s/-/_/g" > "%~dp0TMP\VCDID.txt" & set /p VCDID=<"%~dp0TMP\VCDID.txt"
     set "ELFNOTFOUND="
     "%~dp0BAT\busybox" grep -o -m 1 "regex couldn't find" "%~dp0TMP\VCDID.txt" > "%~dp0TMP\ELFNOTFOUND.TXT" & set /p ELFNOTFOUND=<"%~dp0TMP\ELFNOTFOUND.TXT"
     
 	if defined ELFNOTFOUND (
 	"%~dp0BAT\busybox" grep -o -m 1 "SLPS-02414" "%%P" | "%~dp0BAT\busybox" sed "s/-/_/g" | "%~dp0BAT\busybox" sed "s/.\{8\}/&./" | "%~dp0BAT\busybox" head -1 >> "%~dp0TMP\VCDID.txt" & "%~dp0BAT\busybox" sed -i "/regex couldn't find/d" "%~dp0TMP\VCDID.txt"
     "%~dp0BAT\busybox" grep -o -m 1 "SLUSP013.46" "%%P" | "%~dp0BAT\busybox" sed "s/-/_/g; s/SLUSP013\.46/SLUS_01346/g" | "%~dp0BAT\busybox" sed "s/.\{8\}/&./" | "%~dp0BAT\busybox" head -1 >> "%~dp0TMP\VCDID.txt" & "%~dp0BAT\busybox" sed -i "/regex couldn't find/d" "%~dp0TMP\VCDID.txt"
 	)
  
  echo !VCDID!  !fname!>> "%~dp0TMP\%ARTType%Games.txt"
 endlocal
endlocal
  )
)

type "%~dp0TMP\!ARTType!Games.txt"

if !UpdateOnlyMissingART!==Yes (
cd /d "%~dp0TMP"
"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Extraction Artwork Files:
"%~dp0BAT\Diagbox" gd 0e
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0f

    REM echo            Checking OPL Files... 
    echo device %@pfsshell_path% > "%~dp0TMP\pfs-OPLconfig.txt"
    echo mount __common >> "%~dp0TMP\pfs-OPLconfig.txt"
    echo cd OPL >> "%~dp0TMP\pfs-OPLconfig.txt"
    echo get conf_hdd.cfg >> "%~dp0TMP\pfs-OPLconfig.txt"
    echo cd .. >> "%~dp0TMP\pfs-OPLconfig.txt"
    echo umount >> "%~dp0TMP\pfs-OPLconfig.txt"
    echo exit >> "%~dp0TMP\pfs-OPLconfig.txt"
    type "%~dp0TMP\pfs-OPLconfig.txt" | "%~dp0BAT\pfsshell" >nul 2>&1
    
    if not exist conf_hdd.cfg (set OPLPATH=+OPL) else ("%~dp0BAT\busybox" grep "hdd_partition=" "%~dp0TMP\conf_hdd.cfg" | "%~dp0BAT\busybox" sed "s/^.*=//" > "%~dp0TMP\OPLPATH.txt" & set /P OPLPATH=<"%~dp0TMP\OPLPATH.txt" & set CUSTOM_PATH=Yes)
    if !OPLPATH!==+OPL set "CUSTOM_PATH="
    
    echo         Extraction ARTs Files... %OPLPATH%
    echo device %@pfsshell_path% > "%~dp0TMP\pfs-log.txt"
    echo mount !OPLPATH! >> "%~dp0TMP\pfs-log.txt"
    if defined CUSTOM_PATH echo cd OPL >> "%~dp0TMP\pfs-log.txt"
    echo cd ART >> "%~dp0TMP\pfs-log.txt"
    echo ls >> "%~dp0TMP\pfs-log.txt"
    echo cd .. >> "%~dp0TMP\pfs-OPLconfig.txt"
    echo umount >> "%~dp0TMP\pfs-log.txt"
    echo exit >> "%~dp0TMP\pfs-log.txt"
    type "%~dp0TMP\pfs-log.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" grep -ie ".png" -ie ".jpg" > "%~dp0TMP\pfs-tmp.log"
    
    echo device %@pfsshell_path% > "%~dp0TMP\pfs-art.txt"
    echo mount !OPLPATH! >> "%~dp0TMP\pfs-art.txt"
    if defined CUSTOM_PATH echo cd OPL >> "%~dp0TMP\pfs-art.txt"
    echo cd ART >> "%~dp0TMP\pfs-art.txt"
    echo lcd "%~dp0ART" >> "%~dp0TMP\pfs-art.txt"
    for /f "tokens=*" %%f in (pfs-tmp.log) do (echo get "%%f" >> "%~dp0TMP\pfs-art.txt")
    echo umount >> "%~dp0TMP\pfs-art.txt"
    echo exit >> "%~dp0TMP\pfs-art.txt"
    type "%~dp0TMP\pfs-art.txt" | "%~dp0BAT\pfsshell" >nul 2>&1
    echo         Completed...
"%~dp0BAT\Diagbox" gd 0e
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0f
)

"%~dp0BAT\Diagbox" gd 0e
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0f


cd /d "%~dp0ART"
For /f "usebackq tokens=1*" %%A in ("%~dp0TMP\%ARTType%Games.txt") do (
set Gameid=%%A
set Gamename=%%B
setlocal EnableDelayedExpansion
"%~dp0BAT\Diagbox" gd 0f
echo\
echo !Gamename!
echo !Gameid!
"%~dp0BAT\Diagbox" gd 03

REM Cover
"%~dp0BAT\7-Zip\7z" e -bso0 "%~dp0BAT\ART_CUSTOM_GAMEID.zip" -o"%~dp0ART" %ARTType%\%%A_COV.jpg -r -y >nul 2>&1
IF !uselocalART!==yes if exist "%~dp0ART.zip" if not exist "%~dp0ART\%%A_COV.jpg" "%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0ART.zip" -o"%~dp0TMP" %ARTType%\%%A\%%A_COV.jpg -r -y & move "%~dp0TMP\%ARTType%\%%A\%%A_COV.jpg" "%~dp0ART" >nul 2>&1
IF !DownloadART!==yes if not exist "%~dp0ART\%%A_COV.jpg" "%~dp0BAT\wget" -q --show-progress "https://archive.org/download/OPLM_ART_2023_11/OPLM_ART_2023_11.zip/%ARTType%%%2F%%A%%2F%%A_COV.jpg" -O "%~dp0ART\%%A_COV.jpg"

for %%F in (%%A_COV.jpg) do if %%~zF==0 del "%%F"
if exist %%A_COV.jpg (
echo Found >nul
if !OPLPS1APPS!==Yes if exist "!Gamename!.ELF_COV.jpg" (del "%~dp0ART\!Gameid!_COV.jpg") else (ren "%~dp0ART\!Gameid!_COV.jpg" "!Gamename!.ELF_COV.jpg")
) else (
"%~dp0BAT\Diagbox" gd 06
if not exist %%A_COV.jpg echo %%A_COV.jpg   Not found in database 
"%~dp0BAT\Diagbox" gd 03
)

REM Back Cover
"%~dp0BAT\7-Zip\7z" e -bso0 "%~dp0BAT\ART_CUSTOM_GAMEID.zip" -o"%~dp0ART" %ARTType%\%%A_COV2.jpg -r -y >nul 2>&1
IF !uselocalART!==yes if exist "%~dp0ART.zip" if not exist "%~dp0ART\%%A_COV2.jpg" "%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0ART.zip" -o"%~dp0TMP" %ARTType%\%%A\%%A_COV2.jpg -r -y & move "%~dp0TMP\%ARTType%\%%A\%%A_COV2.jpg" "%~dp0ART" >nul 2>&1
IF !DownloadART!==yes if not exist "%~dp0ART\%%A_COV2.jpg" "%~dp0BAT\wget" -q --show-progress "https://archive.org/download/OPLM_ART_2023_11/OPLM_ART_2023_11.zip/%ARTType%%%2F%%A%%2F%%A_COV2.jpg" -O "%~dp0ART\%%A_COV2.jpg"

cd /d "%~dp0ART" & for %%F in (%%A_COV2.jpg) do if %%~zF==0 del "%%F"
if exist %%A_COV2.jpg (
echo Found >nul
if !OPLPS1APPS!==Yes if exist "!Gamename!.ELF_COV2.jpg" (del "%~dp0ART\!Gameid!_COV2.jpg") else (ren "%~dp0ART\!Gameid!_COV2.jpg" "!Gamename!.ELF_COV2.jpg")
) else (
"%~dp0BAT\Diagbox" gd 06
if not exist %%A_COV2.jpg echo %%A_COV2.jpg  Not found in database 
"%~dp0BAT\Diagbox" gd 03
)

REM ICO
"%~dp0BAT\7-Zip\7z" e -bso0 "%~dp0BAT\ART_CUSTOM_GAMEID.zip" -o"%~dp0ART" %ARTType%\%%A_ICO.png -r -y >nul 2>&1
IF !uselocalART!==yes if exist "%~dp0ART.zip" if not exist "%~dp0ART\%%A_ICO.png" "%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0ART.zip" -o"%~dp0TMP" %ARTType%\%%A\%%A_ICO.png -r -y & move "%~dp0TMP\%ARTType%\%%A\%%A_ICO.png" "%~dp0ART" >nul 2>&1
IF !DownloadART!==yes if not exist "%~dp0ART\%%A_ICO.png" "%~dp0BAT\wget" -q --show-progress "https://archive.org/download/OPLM_ART_2023_11/OPLM_ART_2023_11.zip/%ARTType%%%2F%%A%%2F%%A_ICO.png" -O "%~dp0ART\%%A_ICO.png"

cd /d "%~dp0ART" & for %%F in (%%A_ICO.png) do if %%~zF==0 del "%%F"
if exist %%A_ICO.png (
echo Found >nul
if !OPLPS1APPS!==Yes if exist "!Gamename!.ELF_ICO.png" (del "%~dp0ART\!Gameid!_ICO.png") else (ren "%~dp0ART\!Gameid!_ICO.png" "!Gamename!.ELF_ICO.png")
) else (
"%~dp0BAT\Diagbox" gd 06
if not exist %%A_ICO.png echo %%A_ICO.png   Not found in database 
"%~dp0BAT\Diagbox" gd 03
)

REM LAB
"%~dp0BAT\7-Zip\7z" e -bso0 "%~dp0BAT\ART_CUSTOM_GAMEID.zip" -o"%~dp0ART" %ARTType%\%%A_LAB.jpg -r -y >nul 2>&1
IF !uselocalART!==yes if exist "%~dp0ART.zip" if not exist "%~dp0ART\%%A_LAB.jpg" "%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0ART.zip" -o"%~dp0TMP" %ARTType%\%%A\%%A_LAB.jpg -r -y & move "%~dp0TMP\%ARTType%\%%A\%%A_LAB.jpg" "%~dp0ART" >nul 2>&1
IF !DownloadART!==yes if not exist "%~dp0ART\%%A_LAB.jpg" "%~dp0BAT\wget" -q --show-progress "https://archive.org/download/OPLM_ART_2023_11/OPLM_ART_2023_11.zip/%ARTType%%%2F%%A%%2F%%A_LAB.jpg" -O "%~dp0ART\%%A_LAB.jpg"

cd /d "%~dp0ART" & for %%F in (%%A_LAB.jpg) do if %%~zF==0 del "%%F"
if exist %%A_LAB.jpg (
echo Found >nul
if !OPLPS1APPS!==Yes if exist "!Gamename!.ELF_LAB.jpg" (del "%~dp0ART\!Gameid!_LAB.jpg") else (ren "%~dp0ART\!Gameid!_LAB.jpg" "!Gamename!.ELF_LAB.jpg")
) else (
"%~dp0BAT\Diagbox" gd 06
if not exist %%A_LAB.jpg echo %%A_LAB.jpg   Not found in database 
"%~dp0BAT\Diagbox" gd 03
)

REM LOGO
"%~dp0BAT\7-Zip\7z" e -bso0 "%~dp0BAT\ART_CUSTOM_GAMEID.zip" -o"%~dp0ART" %ARTType%\%%A_LGO.png -r -y >nul 2>&1
IF !uselocalART!==yes if exist "%~dp0ART.zip" if not exist "%~dp0ART\%%A_LGO.png" "%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0ART.zip" -o"%~dp0TMP" %ARTType%\%%A\%%A_LGO.png -r -y & move "%~dp0TMP\%ARTType%\%%A\%%A_LGO.png" "%~dp0ART" >nul 2>&1
IF !DownloadART!==yes if not exist "%~dp0ART\%%A_LGO.png" "%~dp0BAT\wget" -q --show-progress "https://archive.org/download/OPLM_ART_2023_11/OPLM_ART_2023_11.zip/%ARTType%%%2F%%A%%2F%%A_LGO.png" -O "%~dp0ART\%%A_LGO.png"

cd /d "%~dp0ART" & for %%F in (%%A_LGO.png) do if %%~zF==0 del "%%F"
if exist %%A_LGO.png (
echo Found >nul
if !OPLPS1APPS!==Yes if exist "!Gamename!.ELF_LGO.png" (del "%~dp0ART\!Gameid!_LGO.png") else (ren "%~dp0ART\!Gameid!_LGO.png" "!Gamename!.ELF_LGO.png")
) else (
"%~dp0BAT\Diagbox" gd 06
if not exist %%A_LGO.png echo %%A_LGO.png   Not found in database 
"%~dp0BAT\Diagbox" gd 03
)

REM Background
"%~dp0BAT\7-Zip\7z" e -bso0 "%~dp0BAT\ART_CUSTOM_GAMEID.zip" -o"%~dp0ART" %ARTType%\%%A_BG.jpg -r -y >nul 2>&1
IF !uselocalART!==yes if exist "%~dp0ART.zip" if not exist "%~dp0ART\%%A_BG.jpg" "%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0ART.zip" -o"%~dp0TMP" %ARTType%\%%A\%%A_BG_00.jpg -r -y & move "%~dp0TMP\%ARTType%\%%A\%%A_BG_00.jpg" "%~dp0ART\%%A_BG.jpg" >nul 2>&1
IF !DownloadART!==yes if not exist "%~dp0ART\%%A_BG.jpg" "%~dp0BAT\wget" -q --show-progress "https://archive.org/download/OPLM_ART_2023_11/OPLM_ART_2023_11.zip/%ARTType%%%2F%%A%%2F%%A_BG_00.jpg" -O "%~dp0ART\%%A_BG.jpg"

cd /d "%~dp0ART" & for %%F in (%%A_BG.jpg) do if %%~zF==0 del "%%F"
if exist %%A_BG.jpg (
echo Found >nul
if !OPLPS1APPS!==Yes if exist "!Gamename!.ELF_BG.jpg" (del "%~dp0ART\!Gameid!_BG.jpg") else (ren "%~dp0ART\!Gameid!_BG.jpg" "!Gamename!.ELF_BG.jpg")
) else (
"%~dp0BAT\Diagbox" gd 06
if not exist %%A_BG.jpg echo %%A_BG.jpg    Not found in database 
"%~dp0BAT\Diagbox" gd 03
)

REM Screenshot 0
"%~dp0BAT\7-Zip\7z" e -bso0 "%~dp0BAT\ART_CUSTOM_GAMEID.zip" -o"%~dp0ART" %ARTType%\%%A_SCR.jpg -r -y >nul 2>&1
IF !uselocalART!==yes if exist "%~dp0ART.zip" if not exist "%~dp0ART\%%A_SCR.jpg" "%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0ART.zip" -o"%~dp0TMP" %ARTType%\%%A\%%A_SCR_00.jpg -r -y & move "%~dp0TMP\%ARTType%\%%A\%%A_SCR_00.jpg" "%~dp0ART\%%A_SCR.jpg" >nul 2>&1
IF !DownloadART!==yes if not exist "%~dp0ART\%%A_SCR.jpg" "%~dp0BAT\wget" -q --show-progress "https://archive.org/download/OPLM_ART_2023_11/OPLM_ART_2023_11.zip/%ARTType%%%2F%%A%%2F%%A_SCR_00.jpg" -O "%~dp0ART\%%A_SCR.jpg"

cd /d "%~dp0ART" & for %%F in (%%A_SCR.jpg) do if %%~zF==0 del "%%F"
if exist %%A_SCR.jpg (
echo Found >nul
if !OPLPS1APPS!==Yes if exist "!Gamename!.ELF_SCR.jpg" (del "%~dp0ART\!Gameid!_SCR.jpg") else (ren "%~dp0ART\!Gameid!_SCR.jpg" "!Gamename!.ELF_SCR.jpg")
) else (
"%~dp0BAT\Diagbox" gd 06
if not exist %%A_SCR.jpg echo %%A_SCR.jpg   Not found in database 
"%~dp0BAT\Diagbox" gd 03
)

REM Screenshot 1
"%~dp0BAT\7-Zip\7z" e -bso0 "%~dp0BAT\ART_CUSTOM_GAMEID.zip" -o"%~dp0ART" %ARTType%\%%A_SCR2.jpg -r -y >nul 2>&1
IF !uselocalART!==yes if exist "%~dp0ART.zip" if not exist "%~dp0ART\%%A_SCR2.jpg" "%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0ART.zip" -o"%~dp0TMP" %ARTType%\%%A\%%A_SCR_02.jpg -r -y & move "%~dp0TMP\%ARTType%\%%A\%%A_SCR_02.jpg" "%~dp0ART\%%A_SCR2.jpg" >nul 2>&1
IF !DownloadART!==yes if not exist "%~dp0ART\%%A_SCR2.jpg" "%~dp0BAT\wget" -q --show-progress "https://archive.org/download/OPLM_ART_2023_11/OPLM_ART_2023_11.zip/%ARTType%%%2F%%A%%2F%%A_SCR_01.jpg" -O "%~dp0ART\%%A_SCR2.jpg"

cd /d "%~dp0ART" & for %%F in (%%A_SCR2.jpg) do if %%~zF==0 del "%%F"
if exist %%A_SCR2.jpg (
echo Found >nul
if !OPLPS1APPS!==Yes if exist "!Gamename!.ELF_SCR2.jpg" (del "%~dp0ART\!Gameid!_SCR2.jpg") else (ren "%~dp0ART\!Gameid!_SCR2.jpg" "!Gamename!.ELF_SCR2.jpg")
) else (
"%~dp0BAT\Diagbox" gd 06
if not exist %%A_SCR2.jpg echo %%A_SCR2.jpg  Not found in database 
"%~dp0BAT\Diagbox" gd 0f
)

endlocal
)
    REM unmount Dokan partition
	"C:\Program Files\Dokan\!DokanFolder!\dokanctl.exe" /u !DeviceLTR! >nul 2>&1
	
    if !UpdateOnlyMissingART!==Yes (
    echo\
    echo ----------------------------------------------------
	cd "%~dp0ART"
	echo         Creating Que
	echo device %@pfsshell_path% > "%~dp0TMP\pfs-art.txt"
	echo mount %OPLPATH% >> "%~dp0TMP\pfs-art.txt"
    if defined CUSTOM_PATH echo mkdir OPL >> "%~dp0TMP\pfs-art.txt"
    if defined CUSTOM_PATH echo cd OPL >> "%~dp0TMP\pfs-art.txt"
	echo mkdir ART >> "%~dp0TMP\pfs-art.txt"
	echo cd ART >> "%~dp0TMP\pfs-art.txt"
	for %%f in (*) do (echo put "%%f") >> "%~dp0TMP\pfs-art.txt"
	echo ls -l >> "%~dp0TMP\pfs-art.txt"
	echo umount >> "%~dp0TMP\pfs-art.txt"
	echo exit >> "%~dp0TMP\pfs-art.txt"

	echo         Installing Que
	type "%~dp0TMP\pfs-art.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" grep -ie ".png" -ie ".jpg" > "%~dp0LOG\PFS-ART.log"
	echo ----------------------------------------------------
    )

cd /d "%~dp0" & rmdir /Q/S "%~dp0TMP" >nul 2>&1

echo\
echo\
"%~dp0BAT\Diagbox" gd 0f
echo ----------------------------------------------------
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

IF NOT DEFINED @hdl_path ( rmdir /Q/S "%~dp0TMP" >nul 2>&1 & goto ScanningPS2HDD ) else (
"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning for Playstation 2 HDDs:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "!@hdl_path!" | "%~dp0BAT\busybox" grep "Playstation 2 HDD" >nul
if errorlevel 1 set "@hdl_path=" & goto ScanningPS2HDD
echo       [!@hdl_path! !@TotalHDD_Size! - !@ModelePS2HDD!]
)

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
"%~dp0BAT\Diagbox" gd 0f
echo Download/Update CFG for All games installed ?
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1^) Yes
"%~dp0BAT\Diagbox" gd 0c
echo         2^) No
"%~dp0BAT\Diagbox" gd 07
echo\
CHOICE /C 12 /M "Select Option:"

IF %ERRORLEVEL%==1 set @Downloadcfg=Yes
IF %ERRORLEVEL%==2 (goto DownloadsMenu)

echo\
echo\
echo Choose the language of the information that will be displayed in the CFG
echo 1 English 
echo 2 French
echo\
CHOICE /C 12 /M "Select Option:"
IF %ERRORLEVEL%==1 set "language=CFG_en" & copy "%~dp0BAT\TitlesDB\TitlesDB_PS2_English.txt" "%~dp0TMP\gameid.txt" >nul 2>&1
IF %ERRORLEVEL%==2 set "language=CFG_fr" & copy "%~dp0BAT\TitlesDB\TitlesDB_PS2_French.txt" "%~dp0TMP\gameid.txt" >nul 2>&1

echo\
echo\
"%~dp0BAT\Diagbox" gd 0e
echo Do you want to apply compatibility modes^? [RECOMMENDED]
"%~dp0BAT\Diagbox" gd 0f
echo This will improve compatibility with games that need certain modes to work properly
echo\
echo NOTE: That if a game is found in the database, the current compatibility settings will be overridden 
echo put no if you only want to update game infos
CHOICE /C yn /M "Select Option:"
IF %ERRORLEVEL%==1 set "Compatibility_mode=Yes"
IF %ERRORLEVEL%==2 set "Compatibility_mode=No"

echo\
"%~dp0BAT\Diagbox" gd 0e
echo Do you want to keep your game settings^?
echo Like: VMC, CHT
"%~dp0BAT\Diagbox" gd 0f
CHOICE /C yn /M "Select Option:"
IF %ERRORLEVEL%==1 set "KeepUserSettings=Yes"
IF %ERRORLEVEL%==2 set "KeepUserSettings=No"

echo\
"%~dp0BAT\Diagbox" gd 0e
echo Do you want to transfer the CFGs to the OPL partition after the update^?
"%~dp0BAT\Diagbox" gd 0f
CHOICE /C yn /M "Select Option:"
IF %ERRORLEVEL%==1 set "TransferCFG=Yes"
IF %ERRORLEVEL%==2 set "TransferCFG=No"

REM Download Infos Database
"%~dp0BAT\wget" -q --show-progress "https://github.com/GDX-X/PS2-OPL-CFG-Database/releases/download/Latest/PS2-OPL-CFG-Database.7z" >nul 2>&1 -O "%~dp0TMP\PS2-OPL-CFG-Database.7z"
for %%F in ("%~dp0TMP\PS2-OPL-CFG-Database.7z") do if %%~zF==0 (del %%F >nul 2>&1) else (move "%~dp0TMP\PS2-OPL-CFG-Database.7z" "%~dp0BAT" >nul 2>&1)

REM Download Compatibility Database
"%~dp0BAT\wget" -q --show-progress "https://github.com/GDX-X/PS2-OPL-CFG-Compatibility-Database/releases/download/Latest/PS2-OPL-CFG-Compatibility-Database.7z" >nul 2>&1 -O "%~dp0TMP\PS2-OPL-CFG-Compatibility-Database.7z"
for %%F in ("%~dp0TMP\PS2-OPL-CFG-Compatibility-Database.7z") do if %%~zF==0 (del %%F >nul 2>&1) else (move "%~dp0TMP\PS2-OPL-CFG-Compatibility-Database.7z" "%~dp0BAT" >nul 2>&1)

REM Some parameter to avoid conflicts with busybox
md "%~dp0TMP\PS2-OPL-CFG-Database-master\!language!" >nul 2>&1
md "%~dp0TMP\UserSetting" >nul 2>&1
IF NOT EXIST "%~dp0CFG" MD "%~dp0CFG"

"%~dp0BAT\busybox" sed -i "s/\&/\\\&/g" "%~dp0TMP\gameid.txt"
"%~dp0BAT\busybox" sed -i "s/\^!/\!/g" "%~dp0TMP\gameid.txt" >nul 2>&1
"%~dp0BAT\busybox" sed -i "s./.\\\/.g" "%~dp0TMP\gameid.txt"

"%~dp0BAT\Diagbox" gd 0e
cls
echo\
echo\
echo Scanning Games List
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
type "%~dp0BAT\__Cache\PARTITION_HDL_GAME.txt" | "%~dp0BAT\busybox" sed "s/|.*//" | "%~dp0BAT\busybox" sort -k2 > "%~dp0TMP\GameListPS2.txt" & type "%~dp0TMP\GameListPS2.txt"
"%~dp0BAT\Diagbox" gd 0e
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0f

echo\
echo\
echo Extraction Configs Files:
echo ----------------------------------------------------

	 REM echo            Checking OPL Files... 
     echo device %@pfsshell_path% > "%~dp0TMP\pfs-OPLconfig.txt"
     echo mount __common >> "%~dp0TMP\pfs-OPLconfig.txt"
	 echo cd OPL >> "%~dp0TMP\pfs-OPLconfig.txt"
     echo get conf_hdd.cfg >> "%~dp0TMP\pfs-OPLconfig.txt"
	 echo cd .. >> "%~dp0TMP\pfs-OPLconfig.txt"
     echo umount >> "%~dp0TMP\pfs-OPLconfig.txt"
	 echo exit >> "%~dp0TMP\pfs-OPLconfig.txt"
     type "%~dp0TMP\pfs-OPLconfig.txt" | "%~dp0BAT\pfsshell" >nul 2>&1
	 
	 if not exist conf_hdd.cfg (set OPLPATH=+OPL) else ("%~dp0BAT\busybox" grep "hdd_partition=" "%~dp0TMP\conf_hdd.cfg" | "%~dp0BAT\busybox" sed "s/^.*=//" > "%~dp0TMP\OPLPATH.txt" & set /P OPLPATH=<"%~dp0TMP\OPLPATH.txt" & set CUSTOM_PATH=Yes)
     if %OPLPATH%==+OPL set "CUSTOM_PATH="
	 
	 echo         Extraction CFGs Files... %OPLPATH%
	 echo device %@pfsshell_path% > "%~dp0TMP\pfs-log.txt"
	 echo mount %OPLPATH% >> "%~dp0TMP\pfs-log.txt"
	 if defined CUSTOM_PATH echo cd OPL >> "%~dp0TMP\pfs-log.txt"
	 echo cd CFG >> "%~dp0TMP\pfs-log.txt"
	 echo ls >> "%~dp0TMP\pfs-log.txt"
	 echo cd .. >> "%~dp0TMP\pfs-OPLconfig.txt"
     echo umount >> "%~dp0TMP\pfs-log.txt"
	 echo exit >> "%~dp0TMP\pfs-log.txt"
	 type "%~dp0TMP\pfs-log.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" grep -ie ".*\.cfg$" > "%~dp0TMP\pfs-tmp.log"

	 echo device %@pfsshell_path% > "%~dp0TMP\pfs-cfg.txt"
	 echo mount %OPLPATH% >> "%~dp0TMP\pfs-cfg.txt"
	 if defined CUSTOM_PATH echo cd OPL >> "%~dp0TMP\pfs-cfg.txt"
	 echo cd CFG >> "%~dp0TMP\pfs-cfg.txt"
	 echo lcd "%~dp0CFG" >> "%~dp0TMP\pfs-cfg.txt"
	 for /f "tokens=*" %%f in (pfs-tmp.log) do (echo get "%%f" >> "%~dp0TMP\pfs-cfg.txt")
	 echo umount >> "%~dp0TMP\pfs-cfg.txt"
	 echo exit >> "%~dp0TMP\pfs-cfg.txt"
	 type "%~dp0TMP\pfs-cfg.txt" | "%~dp0BAT\pfsshell" >nul 2>&1
	 echo         Completed...
echo ----------------------------------------------------

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
	
	"%~dp0BAT\Diagbox" gd 03
	"%~dp0BAT\7-Zip\7z" e -bso0 "%~dp0BAT\PS2-OPL-CFG-Database.7z" -o"%~dp0TMP\PS2-OPL-CFG-Database-master\!language!" !language!\!gameid!.cfg -r -y
	if exist "%~dp0TMP\PS2-OPL-CFG-Database-master\!language!\!gameid!.cfg" echo 100%%%
	
	REM if not exist "%~dp0CFG\!gameid!.cfg" echo Title=> "%~dp0CFG\!gameid!.cfg"
	"%~dp0BAT\Diagbox" gd 0f
    if not exist "%~dp0TMP\PS2-OPL-CFG-Database-master\!language!\!gameid!.cfg" (
	"%~dp0BAT\7-Zip\7z" e -bso0 "%~dp0BAT\PS2-OPL-CFG-Database.7z" -o"%~dp0TMP\PS2-OPL-CFG-Database-master\!language!" EXAMPLE.cfg -r -y
    ren "%~dp0TMP\PS2-OPL-CFG-Database-master\!language!\EXAMPLE.cfg" "!gameid!.cfg"
    "%~dp0BAT\Diagbox" gd 06
    REM echo Not found in database
	"%~dp0BAT\Diagbox" gd 0f
    ) else (
    "%~dp0BAT\Diagbox" gd 03
	REM "%~dp0BAT\busybox" sed -i "/^\$/d; /Modes=/d" "%~dp0TMP\PS2-OPL-CFG-Database-master\!language!\!gameid!.cfg"
    REM echo Found
    "%~dp0BAT\Diagbox" gd 0f
	)
    
	REM Grep Game Infos
	REM if exist "%~dp0TMP\PS2-OPL-CFG-Database-master\!language!\!gameid!.cfg" (
	REM "%~dp0BAT\busybox" grep "Release=" "%~dp0TMP\PS2-OPL-CFG-Database-master\!language!\!gameid!.cfg" | "%~dp0BAT\busybox" sed "s/^.*=//" > "%~dp0TMP\Release.txt" & set /P Release=<"%~dp0TMP\Release.txt"
	REM "%~dp0BAT\busybox" grep "Developer=" "%~dp0TMP\PS2-OPL-CFG-Database-master\!language!\!gameid!.cfg" | "%~dp0BAT\busybox" sed "s/^.*=//" > "%~dp0TMP\Developer.txt" & set /P Developer=<"%~dp0TMP\Developer.txt"
	REM "%~dp0BAT\busybox" grep "Genre=" "%~dp0TMP\PS2-OPL-CFG-Database-master\!language!\!gameid!.cfg" | "%~dp0BAT\busybox" sed "s/^.*=//" > "%~dp0TMP\Genre.txt" & set /P Genre=<"%~dp0TMP\Genre.txt"
	REM "%~dp0BAT\busybox" grep "Description=" "%~dp0TMP\PS2-OPL-CFG-Database-master\!language!\!gameid!.cfg" | "%~dp0BAT\busybox" sed "s/^.*=//" > "%~dp0TMP\Description.txt" & set /P Description=<"%~dp0TMP\Description.txt"
	REM 
	REM "%~dp0BAT\busybox" grep "Players=" "%~dp0TMP\PS2-OPL-CFG-Database-master\!language!\!gameid!.cfg" | "%~dp0BAT\busybox" sed "s/^.*=//" > "%~dp0TMP\Players.txt" & set /P Players=<"%~dp0TMP\Players.txt"
	REM "%~dp0BAT\busybox" grep "PlayersText=" "%~dp0TMP\PS2-OPL-CFG-Database-master\!language!\!gameid!.cfg" | "%~dp0BAT\busybox" sed "s/^.*=//" > "%~dp0TMP\PlayersText.txt" & set /P PlayersText=<"%~dp0TMP\PlayersText.txt"
	REM 
	REM "%~dp0BAT\busybox" grep "Parental=" "%~dp0TMP\PS2-OPL-CFG-Database-master\!language!\!gameid!.cfg" | "%~dp0BAT\busybox" sed "s/^.*=//" > "%~dp0TMP\Parental.txt" & set /P Parental=<"%~dp0TMP\Parental.txt"
	REM "%~dp0BAT\busybox" grep "ParentalText=" "%~dp0TMP\PS2-OPL-CFG-Database-master\!language!\!gameid!.cfg" | "%~dp0BAT\busybox" sed "s/^.*=//" > "%~dp0TMP\ParentalText.txt" & set /P ParentalText=<"%~dp0TMP\ParentalText.txt"
	REM 
	REM "%~dp0BAT\busybox" grep "Scan=" "%~dp0TMP\PS2-OPL-CFG-Database-master\!language!\!gameid!.cfg" | "%~dp0BAT\busybox" sed "s/^.*=//" > "%~dp0TMP\Scan.txt" & set /P Scan=<"%~dp0TMP\Scan.txt"
	REM "%~dp0BAT\busybox" grep "ScanText=" "%~dp0TMP\PS2-OPL-CFG-Database-master\!language!\!gameid!.cfg" | "%~dp0BAT\busybox" sed "s/^.*=//" > "%~dp0TMP\ScanText.txt" & set /P ScanText=<"%~dp0TMP\ScanText.txt"
	REM 
	REM "%~dp0BAT\busybox" grep "Vmode=" "%~dp0TMP\PS2-OPL-CFG-Database-master\!language!\!gameid!.cfg" | "%~dp0BAT\busybox" sed "s/^.*=//" > "%~dp0TMP\Vmode.txt" & set /P Vmode=<"%~dp0TMP\Vmode.txt"
	REM "%~dp0BAT\busybox" grep "VmodeText=" "%~dp0TMP\PS2-OPL-CFG-Database-master\!language!\!gameid!.cfg" | "%~dp0BAT\busybox" sed "s/^.*=//" > "%~dp0TMP\VmodeText.txt" & set /P VmodeText=<"%~dp0TMP\VmodeText.txt"
	REM 
	REM "%~dp0BAT\busybox" grep "Aspect=" "%~dp0TMP\PS2-OPL-CFG-Database-master\!language!\!gameid!.cfg" | "%~dp0BAT\busybox" sed "s/^.*=//" > "%~dp0TMP\Aspect.txt" & set /P Aspect=<"%~dp0TMP\Aspect.txt"
	REM "%~dp0BAT\busybox" grep "AspectText=" "%~dp0TMP\PS2-OPL-CFG-Database-master\!language!\!gameid!.cfg" | "%~dp0BAT\busybox" sed "s/^.*=//" > "%~dp0TMP\AspectText.txt" & set /P AspectText=<"%~dp0TMP\AspectText.txt"
	REM 
	REM "%~dp0BAT\busybox" grep "Rating=" "%~dp0TMP\PS2-OPL-CFG-Database-master\!language!\!gameid!.cfg" | "%~dp0BAT\busybox" sed "s/^.*=//" > "%~dp0TMP\Rating.txt" & set /P Rating=<"%~dp0TMP\Rating.txt"
	REM "%~dp0BAT\busybox" grep "RatingText=" "%~dp0TMP\PS2-OPL-CFG-Database-master\!language!\!gameid!.cfg" | "%~dp0BAT\busybox" sed "s/^.*=//" > "%~dp0TMP\RatingText.txt" & set /P RatingText=<"%~dp0TMP\RatingText.txt"
	REM 
	REM "%~dp0BAT\busybox" grep "Notes=" "%~dp0TMP\PS2-OPL-CFG-Database-master\!language!\!gameid!.cfg" | "%~dp0BAT\busybox" sed "s/^.*=//" > "%~dp0TMP\Notes.txt" & set /P Notes=<"%~dp0TMP\Notes.txt"
    REM )

    REM "%~dp0BAT\busybox" grep "=" "%~dp0CFG\!gameid!.cfg" > "%~dp0TMP\UserInfos.txt" & set /P Userinfos=<"%~dp0TMP\UserInfos.txt"
    REM echo !Userinfos!| "%~dp0BAT\busybox" grep "Title=" | "%~dp0BAT\busybox" sed "s/^.*=//" > test.txt

    REM echo "!Developer!"| "%~dp0BAT\busybox" sed -e "s/\&/\\\&/g; s./.\\\/.g" > "%~dp0TMP\Developer.txt"
    REM "%~dp0BAT\busybox" sed -i "s/\"//g" "%~dp0TMP\Developer.txt"
    REM set /P Developer=<"%~dp0TMP\Developer.txt"
	REM 
    REM echo "!Genre!"| "%~dp0BAT\busybox" sed -e "s/\&/\\\&/g; s./.\\\/.g" > "%~dp0TMP\Genre.txt"
    REM "%~dp0BAT\busybox" sed -i "s/\"//g" "%~dp0TMP\Genre.txt"
    REM set /P Genre=<"%~dp0TMP\Genre.txt"
	REM 
    REM echo "!Description!"| "%~dp0BAT\busybox" sed -e "s/\&/\\\&/g; s./.\\\/.g" > "%~dp0TMP\Description.txt"
    REM "%~dp0BAT\busybox" sed -i "s/\"//g" "%~dp0TMP\Description.txt"
    REM set /P Description=<"%~dp0TMP\Description.txt"
	REM 
    REM REM Create Infos if not exist
    REM "%~dp0BAT\busybox" grep -q "Title=" "%~dp0CFG\!gameid!.cfg" || echo Title=>> "%~dp0CFG\!gameid!.cfg"
    REM if defined dbtitle "%~dp0BAT\busybox" sed -i -e "s/\Title=.*/Title=/g; s/Title=/Title=!dbtitle!/g" "%~dp0CFG\!gameid!.cfg"
	REM 
	REM "%~dp0BAT\busybox" grep -q "Release=" "%~dp0CFG\!gameid!.cfg" || echo Release=>> "%~dp0CFG\!gameid!.cfg"
	REM if defined Release "%~dp0BAT\busybox" sed -i -e "s|\Release=.*|Release=|g; s|Release=|Release=!Release!|g" "%~dp0CFG\!gameid!.cfg"
	REM 
	REM "%~dp0BAT\busybox" grep -q "Developer=" "%~dp0CFG\!gameid!.cfg" || echo Developer=>> "%~dp0CFG\!gameid!.cfg"
	REM if defined Developer "%~dp0BAT\busybox" sed -i -e "s|\Developer=.*|Developer=|g; s|Developer=|Developer=!Developer!|g" "%~dp0CFG\!gameid!.cfg"
	REM 
	REM "%~dp0BAT\busybox" grep -q "Genre=" "%~dp0CFG\!gameid!.cfg" || echo Genre=>> "%~dp0CFG\!gameid!.cfg"
	REM if defined Genre "%~dp0BAT\busybox" sed -i -e "s|\Genre=.*|Genre=|g; s|Genre=|Genre=!Genre!|g" "%~dp0CFG\!gameid!.cfg"
	REM 
	REM "%~dp0BAT\busybox" grep -q "Description=" "%~dp0CFG\!gameid!.cfg" || echo Description=>> "%~dp0CFG\!gameid!.cfg"
	REM if defined Description "%~dp0BAT\busybox" sed -i -e "s|\Description=.*|Description=|g; s|Description=|Description=!Description!|g" "%~dp0CFG\!gameid!.cfg"
	REM 
    REM REM Create Infos if not exist
	REM "%~dp0BAT\busybox" grep -q "Players=" "%~dp0CFG\!gameid!.cfg" || echo Players=>> "%~dp0CFG\!gameid!.cfg"
	REM "%~dp0BAT\busybox" grep -q "PlayersText=" "%~dp0CFG\!gameid!.cfg" || echo PlayersText=>> "%~dp0CFG\!gameid!.cfg"
	REM if defined Players "%~dp0BAT\busybox" sed -i -e "s|\Players=.*|Players=|g; s|Players=|Players=!Players!|g" "%~dp0CFG\!gameid!.cfg"
	REM if defined PlayersText "%~dp0BAT\busybox" sed -i -e "s|\PlayersText=.*|PlayersText=|g; s|PlayersText=|PlayersText=!PlayersText!|g" "%~dp0CFG\!gameid!.cfg"
    REM 
	REM "%~dp0BAT\busybox" grep -q "Parental=" "%~dp0CFG\!gameid!.cfg" || echo Parental=>> "%~dp0CFG\!gameid!.cfg"
	REM "%~dp0BAT\busybox" grep -q "ParentalText=" "%~dp0CFG\!gameid!.cfg" || echo ParentalText=>> "%~dp0CFG\!gameid!.cfg"
	REM if defined Parental "%~dp0BAT\busybox" sed -i -e "s|\Parental=.*|Parental=|g; s|Parental=|Parental=!Parental!|g" "%~dp0CFG\!gameid!.cfg"
	REM if defined ParentalText "%~dp0BAT\busybox" sed -i -e "s|\ParentalText=.*|ParentalText=|g; s|ParentalText=|ParentalText=!ParentalText!|g" "%~dp0CFG\!gameid!.cfg"
	REM 
    REM "%~dp0BAT\busybox" grep -q "Scan=" "%~dp0CFG\!gameid!.cfg" || echo Scan=>> "%~dp0CFG\!gameid!.cfg"
	REM "%~dp0BAT\busybox" grep -q "ScanText=" "%~dp0CFG\!gameid!.cfg" || echo ScanText=>> "%~dp0CFG\!gameid!.cfg"
    REM if defined Scan "%~dp0BAT\busybox" sed -i -e "s|\Scan=.*|Scan=|g; s|Scan=|Scan=!Scan!|g" "%~dp0CFG\!gameid!.cfg"
	REM if defined ScanText "%~dp0BAT\busybox" sed -i -e "s|\ScanText=.*|ScanText=|g; s|ScanText=|ScanText=!ScanText!|g" "%~dp0CFG\!gameid!.cfg"
	REM 
    REM "%~dp0BAT\busybox" grep -q "Aspect=" "%~dp0CFG\!gameid!.cfg" || echo Aspect=>> "%~dp0CFG\!gameid!.cfg"
	REM "%~dp0BAT\busybox" grep -q "AspectText=" "%~dp0CFG\!gameid!.cfg" || echo AspectText=>> "%~dp0CFG\!gameid!.cfg"		
	REM if defined Aspect "%~dp0BAT\busybox" sed -i -e "s|\Aspect=.*|Aspect=|g; s|Aspect=|Aspect=!Aspect!|g" "%~dp0CFG\!gameid!.cfg"
	REM if defined AspectText "%~dp0BAT\busybox" sed -i -e "s|\AspectText=.*|AspectText=|g; s|AspectText=|AspectText=!AspectText!|g" "%~dp0CFG\!gameid!.cfg"
    REM 
	REM "%~dp0BAT\busybox" grep -q "Vmode=" "%~dp0CFG\!gameid!.cfg" || echo Vmode=>> "%~dp0CFG\!gameid!.cfg"
	REM "%~dp0BAT\busybox" grep -q "VmodeText=" "%~dp0CFG\!gameid!.cfg" || echo VmodeText=>> "%~dp0CFG\!gameid!.cfg"
	REM if defined Vmode "%~dp0BAT\busybox" sed -i -e "s|\Vmode=.*|Vmode=|g; s|Vmode=|Vmode=!Vmode!|g" "%~dp0CFG\!gameid!.cfg"
	REM if defined VmodeText "%~dp0BAT\busybox" sed -i -e "s|\VmodeText=.*|VmodeText=|g; s|VmodeText=|VmodeText=!VmodeText!|g" "%~dp0CFG\!gameid!.cfg"
	REM 
    REM "%~dp0BAT\busybox" grep -q "Rating=" "%~dp0CFG\!gameid!.cfg" || echo Rating=>> "%~dp0CFG\!gameid!.cfg"
	REM "%~dp0BAT\busybox" grep -q "RatingText=" "%~dp0CFG\!gameid!.cfg" || echo RatingText=>> "%~dp0CFG\!gameid!.cfg"
	REM if defined Rating "%~dp0BAT\busybox" sed -i -e "s|\Rating=.*|Rating=|g; s|Rating=|Rating=!Rating!|g" "%~dp0CFG\!gameid!.cfg"
	REM if defined RatingText "%~dp0BAT\busybox" sed -i -e "s|\RatingText=.*|RatingText=|g; s|RatingText=|RatingText=!RatingText!|g" "%~dp0CFG\!gameid!.cfg"
	REM 
    REM "%~dp0BAT\busybox" grep -q "Notes=" "%~dp0CFG\!gameid!.cfg" || echo Notes=>> "%~dp0CFG\!gameid!.cfg"
	REM if defined Notes "%~dp0BAT\busybox" sed -i -e "s|\Notes=.*|Notes=|g; s|Notes=|Notes=!Notes!|g" "%~dp0CFG\!gameid!.cfg"
	
	REM Just to test something
	REM busybox grep "^\$" "SLED_508.84.cfg" > Compatibility_infos.txt & set /P Compatibility_infos=<Compatibility_infos.txt
    REM for /f "tokens=*" %%i in ("!Compatibility_infos!") do (
    REM echo %%i
    REM busybox sed -i "s/%%i//g" test.txt
    REM )

	REM Compatibility
	if !Compatibility_mode!==Yes "%~dp0BAT\7-Zip\7z" e -bso0 "%~dp0BAT\PS2-OPL-CFG-Compatibility-Database.7z" -o"%~dp0TMP\Compatibility" HDD\!gameid!.cfg -r -y >nul 2>&1
    
	del "%~dp0TMP\Settings.txt" >nul 2>&1
	if exist "%~dp0CFG\!gameid!.cfg" (
	REM "%~dp0BAT\busybox" grep -ie "^[$]" -ie "Modes=" "%~dp0CFG\!gameid!.cfg" | "%~dp0BAT\busybox" sed "s/=.*/=/" > "%~dp0TMP\Settings.txt" & set /P Settings=<"%~dp0TMP\Settings.txt"
	"%~dp0BAT\busybox" grep -ie "^[$]" -ie "Modes=" "%~dp0CFG\!gameid!.cfg" > "%~dp0TMP\Settings.txt" & set /P Settings=<"%~dp0TMP\Settings.txt"
	"%~dp0BAT\busybox" grep -v "!Settings!" "%~dp0CFG\!gameid!.cfg" > "%~dp0TMP\UserSetting\!gameid!.cfg"
	"%~dp0BAT\busybox" sed -i "/^^\$\|Modes=/d" "%~dp0CFG\!gameid!.cfg"
	)

	move "%~dp0TMP\PS2-OPL-CFG-Database-master\!language!\!gameid!.cfg" "%~dp0CFG\!gameid!.cfg" >nul 2>&1
	
	REM Game Title
    for /f "tokens=1*" %%A in ( 'findstr !gameid! "%~dp0TMP\gameid.txt"' ) do if not defined dbtitle set dbtitle=%%B
    if not defined dbtitle (
	
	echo "!GameName!"| "%~dp0BAT\busybox" sed -e "s/\&/\\\&/g; s./.\\\/.g" > "%~dp0TMP\dbtitle.txt"
    "%~dp0BAT\busybox" sed -i "s/\"//g" "%~dp0TMP\dbtitle.txt"
    set /P dbtitle=<"%~dp0TMP\dbtitle.txt"
	)
	REM if not defined dbtitle if exist "%~dp0CFG\!gameid!.cfg" "%~dp0BAT\busybox" grep "Title=" "%~dp0CFG\!gameid!.cfg" | "%~dp0BAT\busybox" sed "s/^.*=//" | "%~dp0BAT\busybox" iconv -f windows-1252 -t utf-8 > "%~dp0TMP\Title.txt" & set /P dbtitle=<"%~dp0TMP\Title.txt"
	
	if !gameid!==SLUG_202.73 set "dbtitle=Namco Museum 50th Anniversary"
	if !gameid!==SLUD_206.43 set "dbtitle=Namco Transmission v1.03"
	
	if defined dbtitle "%~dp0BAT\busybox" sed -i -e "s/\Title=.*/Title=/g; s/Title=/Title=!dbtitle!/g" "%~dp0CFG\!gameid!.cfg"
	
	REM Keep User Settings if no detect compatibility modes
	if !KeepUserSettings!==Yes (
	if not exist "%~dp0TMP\Compatibility\!gameid!.cfg" (
	if exist "%~dp0TMP\Settings.txt" "%~dp0BAT\busybox" grep -ie "^[$]" -ie "Modes=" "%~dp0TMP\Settings.txt" >> "%~dp0CFG\!gameid!.cfg"
	 )
	)

	if exist "%~dp0TMP\Compatibility\!gameid!.cfg" (
	"%~dp0BAT\busybox" grep -ie "^[$]" -ie "Modes=" "%~dp0TMP\Compatibility\!gameid!.cfg" >> "%~dp0CFG\!gameid!.cfg"
	)
 endlocal
endlocal
)

    if !TransferCFG!==Yes (
    echo\
    echo ----------------------------------------------------
	cd "%~dp0CFG"
	echo         Creating Que
	echo device %@pfsshell_path% > "%~dp0TMP\pfs-cfg.txt"
	echo mount %OPLPATH% >> "%~dp0TMP\pfs-cfg.txt"
    if defined CUSTOM_PATH echo mkdir OPL >> "%~dp0TMP\pfs-cfg.txt"
    if defined CUSTOM_PATH echo cd OPL >> "%~dp0TMP\pfs-cfg.txt"
	echo mkdir CFG >> "%~dp0TMP\pfs-cfg.txt"
	echo cd CFG >> "%~dp0TMP\pfs-cfg.txt"
	for %%f in (*.cfg) do (echo put "%%f") >> "%~dp0TMP\pfs-cfg.txt"
	echo ls -l >> "%~dp0TMP\pfs-cfg.txt"
	echo umount >> "%~dp0TMP\pfs-cfg.txt"
	echo exit >> "%~dp0TMP\pfs-cfg.txt"

	echo         Installing Que
	type "%~dp0TMP\pfs-cfg.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" grep -ie ".*\.cfg$" > "%~dp0LOG\PFS-CFG.log"
	echo ----------------------------------------------------
    )

cd /d "%~dp0" & rmdir /Q/S "%~dp0TMP" >nul 2>&1

echo\
echo\
"%~dp0BAT\Diagbox" gd 0f
echo ----------------------------------------------------
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
echo ----------------------------------------------------
    "%~dp0BAT\Diagbox" gd 03
    wmic cdrom list brief
    "%~dp0BAT\Diagbox" gd 07
    echo.
    echo ----------------------------------------------------

    echo\
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
    echo Change max read speed?
    echo By default, the max read speed will be 8
	echo Value 8 should be good
    echo\
    CHOICE /C YN /M "Select Option:"
    
    if !errorlevel!==1 (
    set /p readspeed=Read Speed:
    IF "!readspeed!"=="" set "readspeed=" & (goto DumpCDDVD)
    )
    if !errorlevel!==2 set readspeed=8
    )

wmic cdrom list brief | "%~dp0BAT\busybox" sed "/Caption/d" | "%~dp0BAT\busybox" grep -o [A-Z]: > "%~dp0TMP\DriveSelected.txt" & set /P @DriveSelected=<"%~dp0TMP\DriveSelected.txt"

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
echo ------------------------------------------------------------

echo list volume > "%~dp0TMP\Drive-log.txt"
type "%~dp0TMP\Drive-log.txt" | "diskpart" | "%~dp0BAT\busybox" grep -e "DVD-ROM" -e "CD-ROM" | "%~dp0BAT\busybox" cut -c0-16 | "%~dp0BAT\busybox" sed -e "s/$/:/" | "%~dp0BAT\busybox" grep -e "%choice%:" | "%~dp0BAT\busybox" grep -o "[0-9]" > "%~dp0TMP\DriveVolume.txt" & set /P @DriveVolume=<"%~dp0TMP\DriveVolume.txt"

for /f "tokens=1,2,3,4,5*" %%i in ('hdl_dump cdvd_info2 cd!@DriveVolume!:') do (
 
        set disctype=unknown
		if "%%i"=="CD" ( set disctype=cd)
		if "%%i"=="DVD" ( set disctype=dvd)
		if "%%i"=="dual-layer" ( if "%%j"=="DVD" ( set disctype=dvd))
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

echo ------------------------------------------------------------
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
echo ----------------------------------------------------
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

"%~dp0BAT\Diagbox" gd 0e
echo\
echo Download Latest Redump Database ?
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

"%~dp0BAT\busybox" ls | "%~dp0BAT\busybox" grep -ie ".iso" -ie ".bin" > gamelistTMP.txt
set /a gamecount=0
for /f "tokens=*" %%a in (gamelistTMP.txt) do (
	set /a gamecount+=1

	setlocal DisableDelayedExpansion
	set filename=%%a
	set fname=%%~na
	setlocal EnableDelayedExpansion
	echo.
	echo.
	echo !gamecount! - !filename!

set "ErrorHash="
REM CRC32
"%~dp0BAT\busybox" crc32 "!filename!" | "%~dp0BAT\busybox" grep -o "[0-9a-f]\{8\}" > "%~dp0TMP\CRC32.TXT" & set /p CRC32=<"%~dp0TMP\CRC32.txt"
"%~dp0BAT\busybox" grep -e !CRC32! "%~dp0BAT\Dats\!gametype!\Redump!gametype!.dat" > "%~dp0TMP\RedumpDB.txt"
if errorlevel 1 (set ErrorHash=!CRC32!) else (echo found !CRC32!) >nul

REM MD5
"%~dp0BAT\busybox" md5sum "!filename!" | "%~dp0BAT\busybox" grep -o "[0-9a-f]\{32\}" > "%~dp0TMP\MD5.TXT" & set /p MD5=<"%~dp0TMP\MD5.txt"
"%~dp0BAT\busybox" grep -e !MD5! "%~dp0BAT\Dats\!gametype!\Redump!gametype!.dat" > "%~dp0TMP\RedumpDB.txt"
if errorlevel 1 (set ErrorHash=!MD5!) else (echo found !MD5!) >nul

REM SHA1
"%~dp0BAT\busybox" sha1sum "!filename!" | "%~dp0BAT\busybox" grep -o "[0-9a-f]\{40\}" > "%~dp0TMP\SHA1.TXT" & set /p SHA1=<"%~dp0TMP\SHA1.txt"
"%~dp0BAT\busybox" grep -e !SHA1! "%~dp0BAT\Dats\!gametype!\Redump!gametype!.dat" > "%~dp0TMP\RedumpDB.txt"
if errorlevel 1 (set ErrorHash=!SHA1!) else (echo found !SHA1!) >nul

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
 endlocal
endlocal
 )
)

if %gametype%==PS1 (
if exist "%~dp0TMP\*.bin" (move "%~dp0TMP\*.bin" "%~dp0POPS" >nul 2>&1)
)

if %gametype%==PS2 (
move "%~dp0TMP\*.bin" "%~dp0CD" >nul 2>&1
move "%~dp0TMP\*.iso" "%~dp0DVD" >nul 2>&1
move "%~dp0CD-DVD\*.bin" "%~dp0CD" >nul 2>&1
move "%~dp0CD-DVD\*.iso" "%~dp0DVD" >nul 2>&1
)

del gamelistTMP.txt >nul 2>&1

echo\
echo\
"%~dp0BAT\Diagbox" gd 0f
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo Completed...
echo\
echo\
"%~dp0BAT\Diagbox" gd 07

pause & (goto GamesManagement)

REM ###################################################################################################################################################
:ExportChoiceGamesListHDD

cd "%~dp0"
cls
mkdir "%~dp0TMP" >nul 2>&1

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Choose what type of games you want to export game list:
echo ----------------------------------------------------
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
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "!@hdl_path!" | "%~dp0BAT\busybox" grep "Playstation 2 HDD" >nul
if errorlevel 1 set "@hdl_path=" & goto ScanningPS2HDD
echo       [!@hdl_path! !@TotalHDD_Size! - !@ModelePS2HDD!]
)

echo\
echo\
"%~dp0BAT\Diagbox" gd 0f
echo Export PS1 Game List ^?
echo ----------------------------------------------------
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
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0f

    "%~dp0BAT\busybox" grep -o "__.POPS\|__.POPS[0-9]" "%~dp0BAT\__Cache\PARTITION_PS2HDD.txt" | "%~dp0BAT\busybox" sed "s/__.POPS\([0-9]\)/\1.  __.POPS\1/g; s/\__.POPS\b/10. __.POPS/" | "%~dp0BAT\busybox" sort -k2 > "%~dp0TMP\hdd-prt.txt"
    "%~dp0BAT\busybox" sed -e "/^$/d" "%~dp0TMP\hdd-prt.txt" | "%~dp0BAT\busybox" wc -l > "%~dp0TMP\TotalPOPSPart.txt" & set /P @TotalPOPSPart=<"%~dp0TMP\TotalPOPSPart.txt"
    
    if !@TotalPOPSPart! gtr 1 (
	echo.
    echo Multiple POPS partitions were detected. Please choose one.
    echo In general, the default partition is __.POPS
    echo.
    type "%~dp0TMP\hdd-prt.txt"
    echo.
	
    set choice=
    set /p choice="Select Option:"
    IF "!choice!"=="" (goto BackupPS1Games)
    
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
	echo        Partition Must Be Formatted Or Created
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
	
rmdir /Q/S "%~dp0TMP" >nul 2>&1
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
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "!@hdl_path!" | "%~dp0BAT\busybox" grep "Playstation 2 HDD" >nul
if errorlevel 1 set "@hdl_path=" & goto ScanningPS2HDD
echo       [!@hdl_path! !@TotalHDD_Size! - !@ModelePS2HDD!]
)

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Export PS2 Game List ?
echo ----------------------------------------------------
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
echo ----------------------------------------------------
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
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "!@hdl_path!" | "%~dp0BAT\busybox" grep "Playstation 2 HDD" >nul
if errorlevel 1 set "@hdl_path=" & goto ScanningPS2HDD
echo       [!@hdl_path! !@TotalHDD_Size! - !@ModelePS2HDD!]
)

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Rename a PS2 game:
echo ----------------------------------------------------
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

if !@RenamePS2Games!==DBTitle (
echo\
echo\
echo Choose the titles language of the games list
echo\
echo Some games have their own title in several languages for example:
echo English = The Simpsons Game
echo French  = Les Simpson le jeu
echo\
echo 1 English
echo 2 French
echo\
CHOICE /C 12 /M "Select Option:"
IF !ERRORLEVEL!==1 "%~dp0BAT\busybox" iconv -f utf8 -t ascii//TRANSLIT//IGNORE "%~dp0BAT\TitlesDB\TitlesDB_PS2_English.txt" > "%~dp0TMP\gameid.txt"
IF !ERRORLEVEL!==2 "%~dp0BAT\busybox" iconv -f utf8 -t ascii//TRANSLIT//IGNORE "%~dp0BAT\TitlesDB\TitlesDB_PS2_French.txt" > "%~dp0TMP\gameid.txt"
)

"%~dp0BAT\Diagbox" gd 0e
cls
echo\
echo\
echo Scanning Games List:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
type "%~dp0BAT\__Cache\PARTITION_HDL_GAME.txt" | "%~dp0BAT\busybox" sed "s/|.*//" | "%~dp0BAT\busybox" sort -k2 > "%~dp0TMP\GameListPS2.txt" & type "%~dp0TMP\GameListPS2.txt"
"%~dp0BAT\Diagbox" gd 0e
echo ----------------------------------------------------
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
	for /f "tokens=1*" %%A in (' findstr "!fname:~0,11!" "%~dp0TMP\gameid.txt" ') do set newfname=%%B
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

	REM echo            Checking OPL Files... 
    echo device %@pfsshell_path% > "%~dp0TMP\pfs-OPLconfig.txt"
    echo mount __common >> "%~dp0TMP\pfs-OPLconfig.txt"
	echo cd OPL >> "%~dp0TMP\pfs-OPLconfig.txt"
    echo get conf_hdd.cfg >> "%~dp0TMP\pfs-OPLconfig.txt"
	echo cd .. >> "%~dp0TMP\pfs-OPLconfig.txt"
    echo umount >> "%~dp0TMP\pfs-OPLconfig.txt"
	echo exit >> "%~dp0TMP\pfs-OPLconfig.txt"
    type "%~dp0TMP\pfs-OPLconfig.txt" | "%~dp0BAT\pfsshell" >nul 2>&1
	
	if not exist conf_hdd.cfg (set OPLPATH=+OPL) else ("%~dp0BAT\busybox" grep "hdd_partition=" "%~dp0TMP\conf_hdd.cfg" | "%~dp0BAT\busybox" sed "s/^.*=//" > "%~dp0TMP\OPLPATH.txt" & set /P OPLPATH=<"%~dp0TMP\OPLPATH.txt"& set CUSTOM_PATH=Yes)
	if %OPLPATH%==+OPL set "CUSTOM_PATH="
	
	echo device %@pfsshell_path% > "%~dp0TMP\pfs-OPLconfig.txt"
    echo mount %OPLPATH% >> "%~dp0TMP\pfs-OPLconfig.txt"
    if defined CUSTOM_PATH echo cd OPL >> "%~dp0TMP\pfs-OPLconfig.txt"
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
echo ----------------------------------------------------
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
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03

if !RenameGamesOSD!==HDL (
type "%~dp0BAT\__Cache\PARTITION_HDL_GAME.txt" | "%~dp0BAT\busybox" sed "s/|.*//" | "%~dp0BAT\busybox" sort -k2 > "%~dp0TMP\GameList!RenameGamesOSD!.txt"
) else (
type "%~dp0BAT\__Cache\PARTITION_POPS_GAME.txt" | "%~dp0BAT\busybox" sed "s/|.*//" | "%~dp0BAT\busybox" sort -k2 > "%~dp0TMP\GameList!RenameGamesOSD!.txt"
)

type "%~dp0TMP\GameList!RenameGamesOSD!.txt"
"%~dp0BAT\Diagbox" gd 0e
echo ----------------------------------------------------
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


    "%~dp0BAT\hdl_dump_fix_header" dump_header !@hdl_path! "!pname!" >nul 2>&1
	echo !pname!| "%~dp0BAT\busybox" sed -e "s/__\./PP\./g" > "%~dp0TMP\PPBBNXMB.txt" & set /P pname=<"%~dp0TMP\PPBBNXMB.txt"
	"%~dp0BAT\hdl_dump_fix_header" dump_header !@hdl_path! "!pname!" >nul 2>&1

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
	
	chcp 1252 >nul 2>&1
	echo\
	echo\
	echo What title do you want to edit?
    echo Option: 1 = PSBBN, XMB menu
    echo Option: 2 = HDD-OSD
    CHOICE /C 12 /M "Select Option:"
	
    IF !ERRORLEVEL!==1 set Titletype=PSBBNXMB
    IF !ERRORLEVEL!==2 set Titletype=HDDOSD
	
	if !Titletype!==HDDOSD (
	echo\
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
	if "!newgnametmp!"=="" if defined @GameManagementMenu (goto GamesManagement) else (goto HDDOSDPartManagement)
	"%~dp0BAT\Diagbox" gd 03
    
	REM Fix illegal character
    echo "!newgnametmp!"| "%~dp0BAT\busybox" sed -e "s/\&/\\\&/g; s./.\\\/.g" | "%~dp0BAT\busybox" iconv -f windows-1252 -t utf-8 > "%~dp0TMP\newgnametmp.txt"
    "%~dp0BAT\busybox" sed -i "s/\"//g" "%~dp0TMP\newgnametmp.txt"
    set /P newgname=<"%~dp0TMP\newgnametmp.txt"
	
	if !Titletype!==PSBBNXMB (
	"%~dp0BAT\busybox" sed -i -e "s/title =.*/title =/g; s/title =/title = !newgname!/g" "%~dp0TMP\info.sys"
	"%~dp0BAT\busybox" sed -i -e "s/\"TOP-TITLE\" label=.*/\"TOP-TITLE\" label=/g; s/\"TOP-TITLE\" label=/\"TOP-TITLE\" label=\"!newgname!\"/g" "%~dp0TMP\man.xml"
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
	REM "%~dp0BAT\busybox" sed -ie "s/ = /=/g; s/=/ = /g; s/  =/ = /g" "%~dp0TMP\icon.sys"
    if !title!==0 ("%~dp0BAT\busybox" sed -i -e "s|title0 = .*|title0 = |g; s|title0 = |title0 = !newgname!|g" "%~dp0TMP\icon.sys")
    if !title!==1 ("%~dp0BAT\busybox" sed -i -e "s|title1 = .*|title1 = |g; s|title1 = |title1 = !newgname!|g" "%~dp0TMP\icon.sys")
    REM "%~dp0BAT\busybox" sed -ie "s/\s*$//" "%~dp0TMP\icon.sys"
	
	"%~dp0BAT\hdl_dump" modify_header !@hdl_path! "!pname!" >nul 2>&1
	echo !pname!| "%~dp0BAT\busybox" sed -e "s/PP\./__\./g" > "%~dp0TMP\gameselected.txt" & set /P pname=<"%~dp0TMP\gameselected.txt"
	"%~dp0BAT\hdl_dump" modify_header !@hdl_path! "!pname!" >nul 2>&1
    )

cd /d "%~dp0" & rmdir /Q/S "%~dp0TMP" >nul 2>&1

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo Renaming Completed...
echo\
echo\
"%~dp0BAT\Diagbox" gd 0f

if defined @GameManagementMenu (pause & goto GamesManagement) else (pause & goto HDDOSDPartManagement)
REM #######################################################################################################################################################################
:RenamePS1GamesHDD
cls
cd "%~dp0"
rmdir /Q/S "%~dp0TMP" >nul 2>&1
mkdir "%~dp0TMP" >nul 2>&1

IF NOT DEFINED @hdl_path ( rmdir /Q/S "%~dp0TMP" >nul 2>&1 & goto ScanningPS2HDD ) else (
"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning for Playstation 2 HDDs:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "!@hdl_path!" | "%~dp0BAT\busybox" grep "Playstation 2 HDD" >nul
if errorlevel 1 set "@hdl_path=" & goto ScanningPS2HDD
echo       [!@hdl_path! !@TotalHDD_Size! - !@ModelePS2HDD!]
)

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Rename a PS1 game:
echo ----------------------------------------------------
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
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0f

    "%~dp0BAT\busybox" grep -o "__.POPS\|__.POPS[0-9]" "%~dp0BAT\__Cache\PARTITION_PS2HDD.txt" | "%~dp0BAT\busybox" sed "s/__.POPS\([0-9]\)/\1.  __.POPS\1/g; s/\__.POPS\b/10. __.POPS/" | "%~dp0BAT\busybox" sort -k2 > "%~dp0TMP\hdd-prt.txt"
    "%~dp0BAT\busybox" sed -e "/^$/d" "%~dp0TMP\hdd-prt.txt" | "%~dp0BAT\busybox" wc -l > "%~dp0TMP\TotalPOPSPart.txt" & set /P @TotalPOPSPart=<"%~dp0TMP\TotalPOPSPart.txt"
    
    if !@TotalPOPSPart! gtr 1 (
	echo.
    echo Multiple POPS partitions were detected. Please choose one.
	echo Choose the partition where your .VCDs to rename.
    echo In general, the default partition is __.POPS
    echo.
    type "%~dp0TMP\hdd-prt.txt"
    echo.
	
    set choice=
    set /p choice="Select Option:"
    IF "!choice!"=="" (goto RenamePS1GamesHDD)
    
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
	echo        Partition Must Be Formatted Or Created
	echo\
	echo\
	"%~dp0BAT\Diagbox" gd 07
	rmdir /Q/S "%~dp0TMP" >nul 2>&1
	pause & (goto GamesManagement)
	)

echo\
echo\
pause
cls

"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning Games List in %POPSPART%:
echo ----------------------------------------------------
echo\
"%~dp0BAT\Diagbox" gd 07

    echo device !@pfsshell_path! > "%~dp0TMP\pfs-prt.txt"
	echo mount %POPSPART% >> "%~dp0TMP\pfs-prt.txt"
    echo ls >> "%~dp0TMP\pfs-prt.txt"
    echo exit >> "%~dp0TMP\pfs-prt.txt"
    type "%~dp0TMP\pfs-prt.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" grep -ie ".*\.VCD$" | "%~dp0BAT\busybox" sed "s/\.[^.]*$//"
	
"%~dp0BAT\Diagbox" gd 0e
echo\
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 07
setlocal DisableDelayedExpansion

echo\
echo Enter the full name. Example: MyGameName
"%~dp0BAT\Diagbox" gd 06
echo Respect upper and lower case
"%~dp0BAT\Diagbox" gd 07
echo.
set /p "RenamePS1Games=Enter the name of the game you want to rename:"
IF "%RenamePS1Games%"=="" (goto GamesManagement)

echo\
echo\
echo Enter the new name. Example: MyNewGameName
echo\
set /p "RenamePS1GamesNEW=Enter the new name of your game:"
IF "%RenamePS1GamesNEW%"=="" (goto GamesManagement)

"%~dp0BAT\Diagbox" gd 0e
cls
echo\
echo\
echo Game Selected "%RenamePS1Games%"
"%~dp0BAT\Diagbox" gd 0f
echo ----------------------------------------------------
echo\
"%~dp0BAT\Diagbox" gd 03

	echo        Renaming...
	echo        "%RenamePS1Games%"
	echo device %@pfsshell_path% > "%~dp0TMP\pfs-pops.txt"
	echo mount %POPSPART% >> "%~dp0TMP\pfs-pops.txt"
	echo rename "%RenamePS1Games%.vcd" "%RenamePS1Games%.VCD" >> "%~dp0TMP\pfs-pops.txt"
	echo rename "%RenamePS1Games%.VCD" "%RenamePS1GamesNEW%.VCD" >> "%~dp0TMP\pfs-pops.txt"
	echo umount >> "%~dp0TMP\pfs-pops.txt"
	echo mount __common >> "%~dp0TMP\pfs-pops.txt"
	echo cd POPS >> "%~dp0TMP\pfs-pops.txt"
	echo rename "%RenamePS1Games%" "%RenamePS1GamesNEW%" >> "%~dp0TMP\pfs-pops.txt"
	echo exit >> "%~dp0TMP\pfs-pops.txt"
	type "%~dp0TMP\pfs-pops.txt" | "%~dp0BAT\pfsshell" >nul 2>&1
	echo        "%RenamePS1GamesNEW%"
    echo         Completed...
	cd "%~dp0"

cd /d "%~dp0" & rmdir /Q/S "%~dp0TMP" >nul 2>&1

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo Renaming Completed...
echo\
echo\
"%~dp0BAT\Diagbox" gd 0f

endlocal
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
echo ----------------------------------------------------
echo         PS2 Games Not yet available, I recommend you to delete the game directly from OPL
"%~dp0BAT\Diagbox" gd 0c
echo         2^) No
"%~dp0BAT\Diagbox" gd 0e
echo         3^) Yes PS1 Games (Delete .VCD)
echo\
"%~dp0BAT\Diagbox" gd 07
CHOICE /C 123 /M "Select Option:"

IF %ERRORLEVEL%==1 (goto DeleteChoiceGamesHDD)
IF %ERRORLEVEL%==2 (goto GamesManagement)
IF %ERRORLEVEL%==3 (goto DeletePS1GamesHDD)

REM #######################################################################################################################################################################
:DeletePS1GamesHDD
cls
cd "%~dp0"
mkdir "%~dp0TMP" >nul 2>&1

IF NOT DEFINED @hdl_path ( rmdir /Q/S "%~dp0TMP" >nul 2>&1 & goto ScanningPS2HDD ) else (
"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning for Playstation 2 HDDs:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "!@hdl_path!" | "%~dp0BAT\busybox" grep "Playstation 2 HDD" >nul
if errorlevel 1 set "@hdl_path=" & goto ScanningPS2HDD
echo       [!@hdl_path! !@TotalHDD_Size! - !@ModelePS2HDD!]
)

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Delete a PS1 game in a POPS partition:
echo ----------------------------------------------------
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
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0f

    "%~dp0BAT\busybox" grep -o "__.POPS\|__.POPS[0-9]" "%~dp0BAT\__Cache\PARTITION_PS2HDD.txt" | "%~dp0BAT\busybox" sed "s/__.POPS\([0-9]\)/\1.  __.POPS\1/g; s/\__.POPS\b/10. __.POPS/" | "%~dp0BAT\busybox" sort -k2 > "%~dp0TMP\hdd-prt.txt"
    "%~dp0BAT\busybox" sed -e "/^$/d" "%~dp0TMP\hdd-prt.txt" | "%~dp0BAT\busybox" wc -l > "%~dp0TMP\TotalPOPSPart.txt" & set /P @TotalPOPSPart=<"%~dp0TMP\TotalPOPSPart.txt"
    
    if !@TotalPOPSPart! gtr 1 (
	echo.
    echo Multiple POPS partitions were detected. Please choose one.
	echo Choose the partition where your .VCDs to remove are located.
    echo In general, the default partition is __.POPS
    echo.
    type "%~dp0TMP\hdd-prt.txt"
    echo.
	
    set choice=
    set /p choice="Select Option:"
    IF "!choice!"=="" (goto DeletePS1GamesHDD)
    
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
	echo        Partition Must Be Formatted Or Created
	echo\
	echo\
	"%~dp0BAT\Diagbox" gd 07
	rmdir /Q/S "%~dp0TMP" >nul 2>&1
	pause & (goto GamesManagement)
	)

echo\
echo\
pause
cls

"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning Games List in %POPSPART%:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 07

    echo device !@pfsshell_path! > "%~dp0TMP\pfs-prt.txt"
	echo mount %POPSPART% >> "%~dp0TMP\pfs-prt.txt"
    echo ls >> "%~dp0TMP\pfs-prt.txt"
    echo exit >> "%~dp0TMP\pfs-prt.txt"
    type "%~dp0TMP\pfs-prt.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" grep -ie ".*\.VCD$"

"%~dp0BAT\Diagbox" gd 0e
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 07
setlocal DisableDelayedExpansion

echo\
echo Enter the full name including the .VCD
echo Example: MyGameToDelete.VCD
"%~dp0BAT\Diagbox" gd 06
echo Respect upper and lower case
"%~dp0BAT\Diagbox" gd 07
echo.
set /p "DeletePS1Games=Enter the name of the game you want to Delete:"
IF "%DeletePS1Games%"=="" rmdir /Q/S "%~dp0TMP" >nul & (goto GamesManagement)

"%~dp0BAT\Diagbox" gd 0e
cls
echo\
echo\
echo Game Selected "%DeletePS1Games%"
"%~dp0BAT\Diagbox" gd 0f
echo ----------------------------------------------------
echo\
"%~dp0BAT\Diagbox" gd 03

	echo          Removing...
	echo device %@pfsshell_path% > "%~dp0TMP\pfs-pops.txt"
	echo mount %POPSPART% >> "%~dp0TMP\pfs-pops.txt"
	echo rm "%DeletePS1Games%" >> "%~dp0TMP\pfs-pops.txt"
	echo umount >> "%~dp0TMP\pfs-pops.txt"
	echo exit >> "%~dp0TMP\pfs-pops.txt"
	type "%~dp0TMP\pfs-pops.txt" | "%~dp0BAT\pfsshell" >nul 2>&1
    echo          Completed...
	cd "%~dp0"

cd /d "%~dp0" & rmdir /Q/S "%~dp0TMP" >nul 2>&1

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo Removing Completed...
echo\
echo\
"%~dp0BAT\Diagbox" gd 0f

endlocal
pause & (goto GamesManagement)
REM ####################################################################################################################
:DownloadWideScreenCheat
cls 
mkdir "%~dp0TMP" >nul 2>&1
REM for %%F in ( "%~dp0CHT\*.CHT" ) do if %%~zF==0 del "%%F"
cd /d "%~dp0CHT\"
if exist "%~dp0CHT\*.cht" (

REM Checking Mastercode...
for %%i in (*.cht) do (
REM "%~dp0BAT\busybox" grep "Mastercode" "%~dp0CHT\%%i" > "%~dp0TMP\MastercodeCheck.txt" 2>&1
"%~dp0BAT\busybox" sed -n "/Mastercode/,/ /p" "%~dp0CHT\%%i" > "%~dp0TMP\MastercodeCheck.txt" 2>&1
"%~dp0BAT\busybox" sed -i "1d" "%~dp0TMP\MastercodeCheck.txt"
"%~dp0BAT\busybox" sed -i "2,20d" "%~dp0TMP\MastercodeCheck.txt"
"%~dp0BAT\busybox" sed -i "s/\s*$//" "%~dp0TMP\MastercodeCheck.txt"
for %%F in ( "%~dp0TMP\MastercodeCheck.txt" ) do if %%~zF==0 del "%%F" >nul 2>&1

if errorlevel 1 (

echo %%i Mastercode not found: Files Ignored
ren %%i %%iIGNORED

) else (
echo %%i found > nul
    )
  )
)

cd /d "%~dp0"
if not exist "%~dp0CHT\*.cht" (
"%~dp0BAT\Diagbox" gd 06
echo\
echo NO .CHT FOUND IN CHT FOLDER 
echo\
"%~dp0BAT\Diagbox" gd 07
echo You need to Create your .CHT with the Mastercode inside.
echo Or extract the .CHT present in your partition +OPL
echo\
echo\
echo Do You want Create .CHT with Mastercode ?
choice /c YN

if errorlevel 2 (goto DownloadCheatsMenu)
if errorlevel 1 copy "%~dp0BAT\make_cheat_mastercode.bat" >nul "%~dp0" & call make_cheat_mastercode.bat & del make_cheat_mastercode.bat
 "%~dp0BAT\Diagbox" gd 0f
echo --------------------------------------------------------------------------
)
if exist "%~dp0TMP\ISONotFound.txt" (
echo not found >nul
) else (

mkdir "%~dp0TMP" >nul 2>&1

"%~dp0BAT\Diagbox" gd 0e
echo.
echo Beware, WideScreen cheats can cause a game crashes
"%~dp0BAT\Diagbox" gd 0f
echo Do you want to continue?
choice /c YN

if errorlevel 2 (goto DownloadCheatsMenu)

echo.
echo Download Latest WideScreen Cheat Database ?
echo NOTE: if you choose No, it will do an offline installation.
choice /c YN 

if errorlevel 1 set DownloadDB=yes
if errorlevel 2 set DownloadDB=no

    IF "!DownloadDB!"=="yes" (
	echo\
    echo Checking internet connection...
	echo\
	Ping www.github.com -n 1 -w 1000 >nul
	
	if errorlevel 1 (
    "%~dp0BAT\Diagbox" gd 0c
    echo.
	echo Unable to connect to internet Or Website
	echo\
	echo You will switch to offline mode
	echo\
	set DownloadDB=no
	"%~dp0BAT\Diagbox" gd 0f
	pause
	
    ) else (
	
	"%~dp0BAT\Diagbox" gd 0d
    "%~dp0BAT\wget" -q --show-progress https://github.com/PS2-Widescreen/OPL-Widescreen-Cheats/archive/refs/heads/main.zip -O BAT\PS2-OPL-CHT-Widescreen.zip
    "%~dp0BAT\Diagbox" gd 0f
	set DownloadDB=no
	)
)

IF "!DownloadDB!"=="no" (

    echo\
	cd /d "%~dp0CHT"
	for %%i in (*.cht) do (
	set gameidcht=%%~ni
	
	if not exist "%~dp0CHT\WIDE" MD "%~dp0CHT\WIDE" & if not exist "%~dp0CHT\WIDE\CHT" MD "%~dp0CHT\WIDE\CHT"
	if not exist "%~dp0CHT\WIDE2" MD "%~dp0CHT\WIDE2"
	
	"%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0BAT\PS2-OPL-CHT-Widescreen.zip" -o"%~dp0CHT\WIDE" "OPL-Widescreen-Cheats-main\CHT\!gameidcht!.cht" -r -y
	move "%~dp0CHT\WIDE\OPL-Widescreen-Cheats-main\CHT\!gameidcht!.cht" "%~dp0CHT\!gameidcht!.chtWIDE" >nul 2>&1
	
	"%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0BAT\PS2-OPL-CHT-Widescreen.zip" -o"%~dp0CHT\WIDE" "OPL-Widescreen-Cheats-main\CHT\!gameidcht!_v?.??.cht" -r -y
	cd /d "%~dp0CHT\WIDE\OPL-Widescreen-Cheats-main\CHT" >nul 2>&1 & ren !gameidcht!_v?.??.cht !gameidcht!.chtWIDE2 >nul 2>&1 & move *.chtWIDE2 "%~dp0CHT\WIDE2" >nul 2>&1

	cd /d "%~dp0CHT" & rmdir /Q/S "%~dp0CHT\WIDE\" >nul 2>&1
)

For %%C in (*.cht) do (
"%~dp0BAT\busybox" sed -n "/Mastercode/,/ /p" "%~dp0CHT\%%C" > "%~dp0TMP\Mastercode.txt"
"%~dp0BAT\busybox" sed -i "1d" "%~dp0TMP\Mastercode.txt"
"%~dp0BAT\busybox" sed -i "2,20d" "%~dp0TMP\Mastercode.txt"
"%~dp0BAT\busybox" sed -i "s/\s*$//" "%~dp0TMP\Mastercode.txt"
"%~dp0BAT\busybox" sed -i "y/abcdefghijklmnopqrstuvwxyz/ABCDEFGHIJKLMNOPQRSTUVWXYZ/" "%~dp0TMP\Mastercode.txt"
set /p Mastercode=<"%~dp0TMP\Mastercode.txt"

REM Check if widescreen is already installe
echo Widescreen-Fix-Installed-with-PFS-BatchKit-Manager > "%~dp0TMP\checkcheat.txt"
"%~dp0BAT\busybox" sed -i "s/\s*$//" "%~dp0TMP\checkcheat.txt"
set /p checkcheat=<"%~dp0TMP\checkcheat.txt"
"%~dp0BAT\busybox" sed -i "/----Widescreen-Fix-DONT-TOUCH-THIS-LINE----/{N;s/\n$//}" "%~dp0CHT\%%C"
REM "%~dp0BAT\busybox" sed -i "/----Widescreen-Fix-DONT-TOUCH-THIS-LINE----/{n;d}" "%~dp0CHT\%%C"
"%~dp0BAT\busybox" sed -i -e "/!checkcheat!/,/----Widescreen-Fix-DONT-TOUCH-THIS-LINE----/d" "%~dp0CHT\%%C"

"%~dp0BAT\busybox" sed -n "/Mastercode/,/ /p" "%~dp0CHT\%%CWIDE" > "%~dp0TMP\MastercodeCheck.txt" 2>&1
"%~dp0BAT\busybox" sed -i "1d" "%~dp0TMP\MastercodeCheck.txt"
"%~dp0BAT\busybox" sed -i "2,20d" "%~dp0TMP\MastercodeCheck.txt"
"%~dp0BAT\busybox" sed -i "s/\s*$//" "%~dp0TMP\MastercodeCheck.txt"
"%~dp0BAT\busybox" sed -i "y/abcdefghijklmnopqrstuvwxyz/ABCDEFGHIJKLMNOPQRSTUVWXYZ/" "%~dp0TMP\MastercodeCheck.txt"
set /p MastercodeCheck=<"%~dp0TMP\MastercodeCheck.txt"

findstr "!checkcheat!" %%C >nul

if errorlevel 1 (
if !Mastercode! equ !MastercodeCheck! (
 "%~dp0BAT\busybox" sed -i -e :a -e "/^\n*$/{$d;N;ba" -e "}" "%~dp0CHT\%%CWIDE"
 "%~dp0BAT\busybox" grep -s -A 9999 "//" "%~dp0CHT\%%CWIDE" > "%~dp0TMP\Cheatstmp.txt"
 "%~dp0BAT\busybox" sed -i -e "/Mastercode/,+1d" "%~dp0TMP\Cheatstmp.txt"
  REM "%~dp0BAT\busybox" sed -i "${/^$/d}" "%~dp0TMP\Cheatstmp.txt"
 "%~dp0BAT\busybox" sed -i -e "$a//----Widescreen-Fix-DONT-TOUCH-THIS-LINE----" "%~dp0TMP\Cheatstmp.txt"
 "%~dp0BAT\busybox" sed -i "1i //Widescreen-Fix-Installed-with-PFS-BatchKit-Manager" "%~dp0TMP\Cheatstmp.txt"
 "%~dp0BAT\busybox" sed -i "s/\s*$//" "%~dp0TMP\Cheatstmp.txt"
 "%~dp0BAT\busybox" sed -i "${/^$/d}" %%C
 "%~dp0BAT\busybox" sed -i -e "$a" %%C
 "%~dp0BAT\busybox" cat "%~dp0TMP\Cheatstmp.txt" >> %%C
 ) else (
move %%C "%~dp0CHT\WIDE2" >nul 2>&1
"%~dp0BAT\busybox" sed -n "/Mastercode/,/ /p" "%~dp0CHT\WIDE2\%%CWIDE2" > "%~dp0TMP\MastercodeCheck2.txt" 2>&1
"%~dp0BAT\busybox" sed -i "1d" "%~dp0TMP\MastercodeCheck2.txt"
"%~dp0BAT\busybox" sed -i "2,20d" "%~dp0TMP\MastercodeCheck2.txt"
"%~dp0BAT\busybox" sed -i "s/\s*$//" "%~dp0TMP\MastercodeCheck2.txt"
set /p MastercodeCheck2=<"%~dp0TMP\MastercodeCheck2.txt"

if !Mastercode! equ !MastercodeCheck2! (
 "%~dp0BAT\busybox" sed -i -e :a -e "/^\n*$/{$d;N;ba" -e "}" "%~dp0CHT\WIDE2\%%CWIDE2"
 "%~dp0BAT\busybox" grep -s -A 9999 "//" "%~dp0CHT\WIDE2\%%CWIDE2" > "%~dp0TMP\Cheatstmp.txt"
 "%~dp0BAT\busybox" sed -i -e "/Mastercode/,+1d" "%~dp0TMP\Cheatstmp.txt"
 REM "%~dp0BAT\busybox" sed -i "${/^$/d}" "%~dp0TMP\Cheatstmp.txt"
 "%~dp0BAT\busybox" sed -i -e "$a//----Widescreen-Fix-DONT-TOUCH-THIS-LINE----" "%~dp0TMP\Cheatstmp.txt"
 "%~dp0BAT\busybox" sed -i "1i //Widescreen-Fix-Installed-with-PFS-BatchKit-Manager" "%~dp0TMP\Cheatstmp.txt"
 "%~dp0BAT\busybox" sed -i "s/\s*$//" "%~dp0TMP\Cheatstmp.txt"
 "%~dp0BAT\busybox" sed -i "${/^$/d}" "%~dp0CHT\WIDE2\%%C"
 "%~dp0BAT\busybox" sed -i -e "$a" "%~dp0CHT\WIDE2\%%C"
 "%~dp0BAT\busybox" cat "%~dp0TMP\Cheatstmp.txt" >> "%~dp0CHT\WIDE2\%%C"
     )
   )
 )
 
 move "%~dp0CHT\WIDE2\*.cht" "%~dp0CHT" >nul 2>&1
 findstr "!checkcheat!" %%C >nul
 if errorlevel 1 (
 "%~dp0BAT\Diagbox" gd 06
 echo %%C No WideScreen cheats are available for this game.
 "%~dp0BAT\Diagbox" gd 0f
 ) else (
 echo %%C WideScreen cheats has been created.

      )
     )
    )
   )

echo\

del *.chtWIDE >nul 2>&1
ren *.chtIGNORED *.cht >nul 2>&1
rmdir /Q/S "%~dp0CHT\WIDE2" >nul 2>&1
rmdir /Q/S "%~dp0TMP" >nul 2>&1

REM To remove blank lines from the begin of a file:
REM sed -i '/./,$!d' filename

REM To remove blank lines from the end of a file:
REM sed -i -e :a -e '/^\n*$/{$d;N;ba' -e '}' file

REM To remove blank lines from begin and end of a file:
REM sed -i -e '/./,$!d' -e :a -e '/^\n*$/{$d;N;ba' -e '}' file
echo\
pause & (goto DownloadCheatsMenu)

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
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "!@hdl_path!" | "%~dp0BAT\busybox" grep "Playstation 2 HDD" >nul
if errorlevel 1 set "@hdl_path=" & goto ScanningPS2HDD
echo       [!@hdl_path! !@TotalHDD_Size! - !@ModelePS2HDD!]
)

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Create Virtual Memory Card^?
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1^) Yes
"%~dp0BAT\Diagbox" gd 0c
echo         2^) No
echo\
"%~dp0BAT\Diagbox" gd 0f
CHOICE /C 12 /M "Select Option:"

IF ERRORLEVEL 2 (goto GamesManagement)

"%~dp0BAT\Diagbox" gd 0e
cls
echo\
echo\
echo Create Virtual Memory Card...
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
type "%~dp0BAT\__Cache\PARTITION_HDL_GAME.txt" | "%~dp0BAT\busybox" sed "s/|.*//" | "%~dp0BAT\busybox" sort -k2 > "%~dp0TMP\GameListPS2.txt" & type "%~dp0TMP\GameListPS2.txt"
"%~dp0BAT\Diagbox" gd 0e
echo ----------------------------------------------------
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
echo ----------------------------------------------------

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
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo Completed...
echo\
echo\
"%~dp0BAT\Diagbox" gd 07

pause & (goto GamesManagement)
REM ####################################################################################################################
:TransferPS1GamesHDDOSD
cls
mkdir "%~dp0TMP" >nul 2>&1
cd /d "%~dp0TMP"

copy "%~dp0POPS-Binaries\POPSTARTER.KELF" "%~dp0TMP" >nul 2>&1
copy "%~dp0BAT\TitlesDB\TitlesDB_PS1_English.txt" "%~dp0TMP\gameid.txt" >nul 2>&1
if exist "%~dp0POPS-Binaries\Hugopocked_POPStarter_Fixes.zip" "%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0POPS-Binaries\Hugopocked_POPStarter_Fixes.zip" -o"%~dp0TMP" id.txt -r -y

IF NOT DEFINED @hdl_path ( rmdir /Q/S "%~dp0TMP" >nul 2>&1 & goto ScanningPS2HDD ) else (
"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning for Playstation 2 HDDs:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "!@hdl_path!" | "%~dp0BAT\busybox" grep "Playstation 2 HDD" >nul
if errorlevel 1 set "@hdl_path=" & goto ScanningPS2HDD
echo       [!@hdl_path! !@TotalHDD_Size! - !@ModelePS2HDD!]
)

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Make sure your Multi-Discs have the (Disc #) Example:
echo\
echo Gran Turismo 2 (Disc 1) (Arcade Mode).VCD
echo Gran Turismo 2 (Disc 2) (Gran Turismo Mode).VCD
echo\
echo Install .VCD as partition for HDD-OSD
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1^) Yes (Install each Multi-Disc as a single partition)
"%~dp0BAT\Diagbox" gd 0c
echo         2^) No
"%~dp0BAT\Diagbox" gd 0e
echo         3^) Yes (Install each Multi-Disc in the same partition as (Disc 1) )
"%~dp0BAT\Diagbox" gd 0f
echo\
CHOICE /C 123 /M "Select Option:"

IF %ERRORLEVEL%==1 set @pfs_POPShddosd=yes
IF %ERRORLEVEL%==2 if defined @pfs_popHDDOSDMAIN (goto mainmenu) else (goto HDDOSDPartManagement)
IF %ERRORLEVEL%==3 set @pfs_POPSMultiDischddosd=yes

if exist "%~dp0ART.zip" (
echo\
"%~dp0BAT\Diagbox" gd 0e
echo ART.zip detected do you want use it?
"%~dp0BAT\Diagbox" gd 0f
CHOICE /C YN /M "Select Option:"
IF ERRORLEVEL 1 set uselocalART=yes
IF ERRORLEVEL 2 set uselocalART=no
) else (set uselocalART=no)

if !uselocalART!==no (
    echo.
	echo Checking internet Or Website connection... For ART
	"%~dp0BAT\wget" -q --show-progress "https://archive.org/download/OPLM_ART_2023_11/OPLM_ART_2023_11.zip/PS1%%2FSCES_000.01%%2FSCES_000.01_COV.jpg" -O "%~dp0TMP\SCES_000.01_COV.jpg" >nul 2>&1
	for %%F in (SCES_000.01_COV.jpg) do if %%~zF==0 del "%%F"

if not exist SCES_000.01_COV.jpg (
"%~dp0BAT\Diagbox" gd 0c
    echo\
	echo Unable to connect to internet Or Website
	if exist "%~dp0ART.zip" set uselocalART=yes
	echo You will switch to offline mode
	echo\
	echo\
"%~dp0BAT\Diagbox" gd 0f
	pause
 ) else (set DownloadART=yes)
)

if exist "%~dp0HDD-OSD-Icons-Pack.zip" (
echo\
"%~dp0BAT\Diagbox" gd 0e
echo HDD-OSD-Icons-Pack.zip detected do you want use it?
"%~dp0BAT\Diagbox" gd 0f
CHOICE /C YN /M "Select Option:"
IF ERRORLEVEL 1 set uselocalARTHDDOSD=yes
IF ERRORLEVEL 2 set uselocalARTHDDOSD=no
) else (set uselocalARTHDDOSD=no)

if !uselocalARTHDDOSD!==no (
    echo.
	echo Checking internet Or Website connection... For HDD-OSD ART
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

	cls
    setlocal DisableDelayedExpansion
	if exist Temp cd /d "%~dp0POPS\temp" & for /f "delims=" %%a in ('dir /ad /b') do (move "%%a\*.VCD" "%~dp0POPS" >nul 2>&1)
	if exist "%~dp0POPS\*.VCD" (
    cd /d "%~dp0POPS"
	
	if not defined @pfs_POPSMultiDischddosd (
    for %%V in (*.VCD) do (
    "%~dp0BAT\busybox" ls | "%~dp0BAT\busybox" grep -ie ".*\.VCD$" | "%~dp0BAT\busybox" sed -e "s/^/\"/g; s/\r*$/\"/" > "%~dp0POPS\Disc0.txt"
	
    for /f "tokens=*" %%# in (Disc0.txt) do (
    if not exist "Temp/%%~n#" md "Temp/%%~n#"
    move %%# "Temp/%%~n#" >nul 2>&1
      )
    )
	
    ) else (
	REM Scan Disc0
    "%~dp0BAT\busybox" ls | "%~dp0BAT\busybox" grep -ie ".*\.VCD$" | "%~dp0BAT\busybox" sed -e "/(Disc [1-6])/d" | "%~dp0BAT\busybox" sed -e "s/^/\"/g; s/\r*$/\"/" > "%~dp0POPS\Disc0.txt"

    for /f "tokens=*" %%# in (Disc0.txt) do (
    if not exist "Temp/%%~n#" md "Temp/%%~n#"
    move %%# "Temp/%%~n#" >nul 2>&1
     )
	 
    REM Scan Disc 1,2,3,4
    "%~dp0BAT\busybox" ls | "%~dp0BAT\busybox" grep -ie ".*\.VCD$" | "%~dp0BAT\busybox" grep -ie "(Disc 1)" | "%~dp0BAT\busybox" sed -e "s/^/\"/g; s/\r*$/\"/" > "%~dp0POPS\Disc1.txt"
    "%~dp0BAT\busybox" ls | "%~dp0BAT\busybox" grep -ie ".*\.VCD$" | "%~dp0BAT\busybox" grep -ie "(Disc 2)" | "%~dp0BAT\busybox" sed -e "s/^/\"/g; s/\r*$/\"/" > "%~dp0POPS\Disc2.txt"
    "%~dp0BAT\busybox" ls | "%~dp0BAT\busybox" grep -ie ".*\.VCD$" | "%~dp0BAT\busybox" grep -ie "(Disc 3)" | "%~dp0BAT\busybox" sed -e "s/^/\"/g; s/\r*$/\"/" > "%~dp0POPS\Disc3.txt"
    "%~dp0BAT\busybox" ls | "%~dp0BAT\busybox" grep -ie ".*\.VCD$" | "%~dp0BAT\busybox" grep -ie "(Disc 4)" | "%~dp0BAT\busybox" sed -e "s/^/\"/g; s/\r*$/\"/" > "%~dp0POPS\Disc4.txt"
	for %%x in (Disc1.txt) do if %%~zx==0 del %%x

    if exist Disc1.txt (
    for /f "tokens=*" %%# in (Disc1.txt) do (
    if not exist "Temp/%%~n#" md "Temp/%%~n#"
    move %%# "Temp/%%~n#" >nul 2>&1
    )
    
    "%~dp0BAT\busybox" sed -i "s/\"//g" "%~dp0POPS\Disc1.txt"
    "%~dp0BAT\busybox" sed -i "s/^/temp\//g" "%~dp0POPS\Disc1.txt"
    "%~dp0BAT\busybox" sed -i "s/^/\"/g; s/\r*$/\"/" "%~dp0POPS\Disc1.txt"
    "%~dp0BAT\busybox" sed -i "s/.VCD//g" "%~dp0POPS\Disc1.txt"
    
    "%~dp0BAT\busybox" sed -i "s/^/move /g" "%~dp0POPS\Disc2.txt"
    "%~dp0BAT\busybox" paste -d " " "%~dp0POPS\Disc2.txt" "%~dp0POPS\Disc1.txt" > "%~dp0POPS\Disc2.BAT" & call Disc2.BAT >nul 2>&1
    
    "%~dp0BAT\busybox" sed -i "s/^/move /g" "%~dp0POPS\Disc3.txt"
    "%~dp0BAT\busybox" paste -d " " "%~dp0POPS\Disc3.txt" "%~dp0POPS\Disc1.txt" > "%~dp0POPS\Disc3.BAT" & call Disc3.BAT >nul 2>&1
    
    "%~dp0BAT\busybox" sed -i "s/^/move /g" "%~dp0POPS\Disc4.txt"
    "%~dp0BAT\busybox" paste -d " " "%~dp0POPS\Disc4.txt" "%~dp0POPS\Disc1.txt" > "%~dp0POPS\Disc4.BAT" & call Disc4.BAT >nul 2>&1
	
	  ) else (
	  "%~dp0BAT\Diagbox" gd 06
	  cd /d "%~dp0POPS\temp" & for /f "delims=" %%a in ('dir /ad /b') do (move "%%a\*.VCD" "%~dp0POPS" >nul 2>&1)
	  echo\
	  echo NO Disc 1 detected you need Disc 1 to install the other discs in the same partition
	  echo\
	  "%~dp0BAT\Diagbox" gd 0f
	  cd /d "%~dp0POPS" & del Disc?.???
	  if defined @pfs_popHDDOSDMAIN (pause & goto mainmenu) else (pause & goto HDDOSDPartManagement)
	  )
	 )
    ) else (
	
"%~dp0BAT\Diagbox" gd 06
echo.
echo .VCD NOT DETECTED: Please drop .VCD IN POPS FOLDER.
echo.
"%~dp0BAT\Diagbox" gd 0f
if defined @pfs_popHDDOSDMAIN (pause & goto mainmenu) else (pause & goto HDDOSDPartManagement)
)

    del Disc?.???
    cd /d "%~dp0POPS\temp" & for /f "delims=" %%a in ('dir /ad /b') do (
    set appfolder=%%a
	
	set "cheats="
    set "filename="
	set "sizelimit="
    setlocal EnableDelayedExpansion

REM echo "!appfolder!"

REM Get Size + Name (Disc 0)
set "Disc0Size="
set "Disc0="
set "SIZEMBD0="
if defined @pfs_POPSMultiDischddosd "%~dp0BAT\busybox" ls "%~dp0POPS\temp\!appfolder!" | "%~dp0BAT\busybox" grep -sie ".*\.VCD$" | "%~dp0BAT\busybox" sed -e "/(Disc [1-6])/d" > "%~dp0POPS\temp\!appfolder!\Disc0.txt" & cd /d "%~dp0POPS\temp\!appfolder!" & for %%x in (Disc0.txt) do if %%~zx==0 del %%x & cd /d "%~dp0POPS\temp\"
if not defined @pfs_POPSMultiDischddosd "%~dp0BAT\busybox" ls "%~dp0POPS\temp\!appfolder!" | "%~dp0BAT\busybox" grep -sie ".*\.VCD$" > "%~dp0POPS\temp\!appfolder!\Disc0.txt" & cd /d "%~dp0POPS\temp\!appfolder!" & for %%x in (Disc0.txt) do if %%~zx==0 del %%x & cd /d "%~dp0POPS\temp\"
if exist "%~dp0POPS\temp\!appfolder!\Disc0.txt" set /P Disc0=<"%~dp0POPS\temp\!appfolder!\Disc0.txt"
if defined Disc0 cd /d "%~dp0POPS\temp\!appfolder!" & for %%s in ("!Disc0!") do ( echo %%~zs | "%~dp0BAT\busybox" sed "s/\s*$//g" > Disc0Size.txt )
REM "%~dp0BAT\busybox" sed -i -r "/^.{,8}$/d" Disc0Size.txt >nul 2>&1
REM "%~dp0BAT\busybox" sed -i "/^.\{9\}./d" Disc0Size.txt >nul 2>&1
for %%x in ("!Disc0!") do if %%~zx GTR 1920000000 set sizelimit=2GB

if defined @pfs_POPSMultiDischddosd (

REM Get Size + Name (Disc 1)
set "Disc1Size="
set "Disc1="
set "SIZEMBD1="
"%~dp0BAT\busybox" ls "%~dp0POPS\temp\!appfolder!" | "%~dp0BAT\busybox" grep -ie "(Disc 1)" > "%~dp0POPS\temp\!appfolder!\Disc1.txt" & cd /d "%~dp0POPS\temp\!appfolder!" & for %%x in (Disc1.txt) do if %%~zx==0 del %%x & cd /d "%~dp0POPS\temp\"
if exist "%~dp0POPS\temp\!appfolder!\Disc1.txt" set /P Disc1=<"%~dp0POPS\temp\!appfolder!\Disc1.txt"
if defined Disc1 cd /d "%~dp0POPS\temp\!appfolder!" & for %%s in ("!Disc1!") do ( echo %%~zs | "%~dp0BAT\busybox" sed "s/\s*$//g" > Disc1Size.txt ) 

for %%x in ("!Disc1!") do if %%~zx GTR 1920000000 set sizelimit=2GB

REM Get Size + Name (Disc 2)
set "Disc2Size="
set "Disc2="
set "SIZEMBD2="
"%~dp0BAT\busybox" ls "%~dp0POPS\temp\!appfolder!" | "%~dp0BAT\busybox" grep -ie "(Disc 2)" > "%~dp0POPS\temp\!appfolder!\Disc2.txt" & cd /d "%~dp0POPS\temp\!appfolder!" & for %%x in (Disc2.txt) do if %%~zx==0 del %%x & cd /d "%~dp0POPS\temp\"
if exist "%~dp0POPS\temp\!appfolder!\Disc2.txt" set /P Disc2=<"%~dp0POPS\temp\!appfolder!\Disc2.txt"
if defined Disc2 cd /d "%~dp0POPS\temp\!appfolder!" & for %%s in ("!Disc2!") do ( echo %%~zs | "%~dp0BAT\busybox" sed "s/\s*$//g" > Disc2Size.txt ) & cd /d "%~dp0POPS\temp\"

REM Get Size + Name(Disc 3)
set "Disc3Size="
set "Disc3="
set "SIZEMBD3="
"%~dp0BAT\busybox" ls "%~dp0POPS\temp\!appfolder!" | "%~dp0BAT\busybox" grep -ie "(Disc 3)" > "%~dp0POPS\temp\!appfolder!\Disc3.txt" & cd /d "%~dp0POPS\temp\!appfolder!" & for %%x in (Disc3.txt) do if %%~zx==0 del %%x & cd /d "%~dp0POPS\temp\"
if exist "%~dp0POPS\temp\!appfolder!\Disc3.txt" set /P Disc3=<"%~dp0POPS\temp\!appfolder!\Disc3.txt"
if defined Disc3 cd /d "%~dp0POPS\temp\!appfolder!" & for %%s in ("!Disc3!") do ( echo %%~zs | "%~dp0BAT\busybox" sed "s/\s*$//g" > Disc3Size.txt ) & cd /d "%~dp0POPS\temp\"

REM Get Size + Name (Disc 4)
set "Disc4Size="
set "Disc4="
set "SIZEMBD4="
"%~dp0BAT\busybox" ls "%~dp0POPS\temp\!appfolder!" | "%~dp0BAT\busybox" grep -ie "(Disc 4)" > "%~dp0POPS\temp\!appfolder!\Disc4.txt" & cd /d "%~dp0POPS\temp\!appfolder!" & for %%x in (Disc4.txt) do if %%~zx==0 del %%x & cd /d "%~dp0POPS\temp\"
if exist "%~dp0POPS\temp\!appfolder!\Disc4.txt" set /P Disc4=<"%~dp0POPS\temp\!appfolder!\Disc4.txt"
if defined Disc4 cd /d "%~dp0POPS\temp\!appfolder!" & for %%s in ("!Disc4!") do ( echo %%~zs | "%~dp0BAT\busybox" sed "s/\s*$//g" > Disc4Size.txt ) & cd /d "%~dp0POPS\temp\"

)

if defined sizelimit (
"%~dp0BAT\Diagbox" gd 0c
    echo.
	echo !Disc0! Files Exceeds size limit: 2GB Maximum per Files
	echo.
	move "%~dp0POPS\Temp\!appfolder!\*.VCD" "%~dp0POPS" >nul 2>&1
	cd /d "%~dp0POPS\temp"
"%~dp0BAT\Diagbox" gd 0f
	) else (
	echo good >nul 2>&1

cd /d "%~dp0POPS\temp\!appfolder!"

REM Calculs (Disc 0)
if exist "%~dp0POPS\temp\!appfolder!\Disc0Size.txt" for /f %%0 in (Disc0Size.txt) do (
if %%0 GTR 1000000 set SIZEMBD0=128
if %%0 GTR 128000000 set SIZEMBD0=256
if %%0 GTR 256000000 set SIZEMBD0=384
if %%0 GTR 384000000 set SIZEMBD0=512
if %%0 GTR 512000000 set SIZEMBD0=640
if %%0 GTR 640000000 set SIZEMBD0=768
if %%0 GTR 768000000 set SIZEMBD0=896
)
if not exist "%~dp0POPS\temp\!appfolder!\Disc0Size.txt" set SIZEMBD0=0

REM Calculs (Disc 1)
if exist "%~dp0POPS\temp\!appfolder!\Disc1Size.txt" for /f %%1 in (Disc1Size.txt) do (
if %%1 GTR 1000000 set SIZEMBD1=128
if %%1 GTR 128000000 set SIZEMBD1=256
if %%1 GTR 256000000 set SIZEMBD1=384
if %%1 GTR 384000000 set SIZEMBD1=512
if %%1 GTR 512000000 set SIZEMBD1=640
if %%1 GTR 640000000 set SIZEMBD1=768
if %%1 GTR 768000000 set SIZEMBD1=896
)
if not exist "%~dp0POPS\temp\!appfolder!\Disc1Size.txt" set SIZEMBD1=0

REM Calculs (Disc 2)
if exist "%~dp0POPS\temp\!appfolder!\Disc2Size.txt" for /f %%2 in (Disc2Size.txt) do (
if %%2 GTR 1000000 set SIZEMBD2=128
if %%2 GTR 128000000 set SIZEMBD2=256
if %%2 GTR 256000000 set SIZEMBD2=384
if %%2 GTR 384000000 set SIZEMBD2=512
if %%2 GTR 512000000 set SIZEMBD2=640
if %%2 GTR 640000000 set SIZEMBD2=768
if %%2 GTR 768000000 set SIZEMBD2=896
)
if not exist "%~dp0POPS\temp\!appfolder!\Disc2Size.txt" set SIZEMBD2=0

REM Calculs (Disc 3)
if exist "%~dp0POPS\temp\!appfolder!\Disc3Size.txt" for /f %%3 in (Disc3Size.txt) do (
if %%3 GTR 1000000 set SIZEMBD3=128
if %%3 GTR 128000000 set SIZEMBD3=256
if %%3 GTR 256000000 set SIZEMBD3=384
if %%3 GTR 384000000 set SIZEMBD3=512
if %%3 GTR 512000000 set SIZEMBD3=640
if %%3 GTR 640000000 set SIZEMBD3=768
if %%3 GTR 768000000 set SIZEMBD3=896
)
if not exist "%~dp0POPS\temp\!appfolder!\Disc3Size.txt" set SIZEMBD3=0

REM Calculs (Disc 4)
if exist "%~dp0POPS\temp\!appfolder!\Disc4Size.txt" for /f %%4 in (Disc4Size.txt) do (
if %%4 GTR 1000000 set SIZEMBD4=128
if %%4 GTR 128000000 set SIZEMBD4=256
if %%4 GTR 256000000 set SIZEMBD4=384
if %%4 GTR 384000000 set SIZEMBD4=512
if %%4 GTR 512000000 set SIZEMBD4=640
if %%4 GTR 640000000 set SIZEMBD4=768
if %%4 GTR 768000000 set SIZEMBD4=896
)
if not exist "%~dp0POPS\temp\!appfolder!\Disc4Size.txt" set SIZEMBD4=0

SET /A Result = !SIZEMBD0!+!SIZEMBD1!+!SIZEMBD2!+!SIZEMBD3!+!SIZEMBD4!

REM echo !Result!

if defined Disc0 (
"%~dp0BAT\POPS-VCD-ID-Extractor" "%~dp0POPS\temp\!appfolder!\!Disc0!" 2>&1 | "%~dp0BAT\busybox" sed -e "s/-/_/g" > "%~dp0TMP\VCDID.txt" & set /P ID=<"%~dp0TMP\VCDID.txt"

set "ELFNOTFOUND="
    "%~dp0BAT\busybox" grep -o -m 1 "regex couldn't find" "%~dp0TMP\VCDID.txt" > ELFNOTFOUND.TXT & set /p ELFNOTFOUND=<ELFNOTFOUND.TXT
    if defined ELFNOTFOUND (
	"%~dp0BAT\busybox" grep -o -m 1 "SLPS-02414" "!Disc0!" | "%~dp0BAT\busybox" sed "s/-/_/g" | "%~dp0BAT\busybox" sed "s/.\{8\}/&./" | "%~dp0BAT\busybox" head -1 >> "%~dp0TMP\VCDID.txt" & "%~dp0BAT\busybox" sed -i "/regex couldn't find/d" "%~dp0TMP\VCDID.txt" & set /p ID=<"%~dp0TMP\VCDID.txt"
	"%~dp0BAT\busybox" grep -o -m 1 "SLUSP013.46" "!Disc0!" | "%~dp0BAT\busybox" sed "s/-/_/g; s/SLUSP013\.46/SLUS_01346/g" | "%~dp0BAT\busybox" sed "s/.\{8\}/&./" | "%~dp0BAT\busybox" head -1 >> "%~dp0TMP\VCDID.txt" & "%~dp0BAT\busybox" sed -i "/regex couldn't find/d" "%~dp0TMP\VCDID.txt" & set /p ID=<"%~dp0TMP\VCDID.txt"
	)

"%~dp0BAT\busybox" ls | "%~dp0BAT\busybox" grep -ie ".*\.VCD$" > "%~dp0TMP\Name.txt" & "%~dp0BAT\busybox" sed -i "s/!ID!.//g" "%~dp0TMP\Name.txt"
)
if defined Disc1 (
"%~dp0BAT\POPS-VCD-ID-Extractor" "%~dp0POPS\temp\!appfolder!\!Disc1!" 2>&1 | "%~dp0BAT\busybox" sed -e "s/-/_/g" > "%~dp0TMP\VCDID.txt" & set /P ID=<"%~dp0TMP\VCDID.txt"

set "ELFNOTFOUND="
    "%~dp0BAT\busybox" grep -o -m 1 "regex couldn't find" "%~dp0TMP\VCDID.txt" > ELFNOTFOUND.TXT & set /p ELFNOTFOUND=<ELFNOTFOUND.TXT
    if defined ELFNOTFOUND (
	"%~dp0BAT\busybox" grep -o -m 1 "SLPS-02414" "!Disc1!" | "%~dp0BAT\busybox" sed "s/-/_/g" | "%~dp0BAT\busybox" sed "s/.\{8\}/&./" | "%~dp0BAT\busybox" head -1 >> "%~dp0TMP\VCDID.txt" & "%~dp0BAT\busybox" sed -i "/regex couldn't find/d" "%~dp0TMP\VCDID.txt" & set /p ID=<"%~dp0TMP\VCDID.txt"
    "%~dp0BAT\busybox" grep -o -m 1 "SLUSP013.46" "!Disc1!" | "%~dp0BAT\busybox" sed "s/-/_/g; s/SLUSP013\.46/SLUS_01346/g" | "%~dp0BAT\busybox" sed "s/.\{8\}/&./" | "%~dp0BAT\busybox" head -1 >> "%~dp0TMP\VCDID.txt" & "%~dp0BAT\busybox" sed -i "/regex couldn't find/d" "%~dp0TMP\VCDID.txt" & set /p ID=<"%~dp0TMP\VCDID.txt"
	)
	
"%~dp0BAT\busybox" ls | "%~dp0BAT\busybox" grep -ie "!Disc1!" | "%~dp0BAT\busybox" sed -e "s/!ID!\.//g" | "%~dp0BAT\busybox" sed -e "2,7d" > "%~dp0TMP\Name.txt"
)
"%~dp0BAT\busybox" paste -d " " "%~dp0TMP\VCDID.txt" "%~dp0TMP\Name.txt" | "%~dp0BAT\busybox" sed "s/.\{12\}/&/" > "%~dp0POPS\Temp\!appfolder!\VCDIDName.txt"

if defined Disc1 "%~dp0BAT\busybox" sed -i -e "s/ (Disc [1-6])//g" "%~dp0TMP\gameid.txt"

setlocal DisableDelayedExpansion
for /f "tokens=1*" %%F in (VCDIDName.txt) do (
set gameid=%%F
	 set "PPtitle="
 	 for /f "tokens=1*" %%A in ( 'findstr %%F "%~dp0TMP\gameid.txt"' ) do (if not defined PPtitle set PPtitle=%%B
	 )
	 
if not defined PPtitle set PPtitle=%%~nG

setlocal EnableDelayedExpansion

	 findstr !gameid! "%~dp0BAT\Fix_Conflict_Gameid_Title.bat" >nul 2>&1
     if errorlevel 1 (echo >NUL) else (
	 "%~dp0BAT\busybox" md5sum "%~dp0POPS\temp\!appfolder!\!Disc0!" | "%~dp0BAT\busybox" grep -o "[0-9a-f]\{32\}" > "%~dp0TMP\MD5.txt" & set /p MD5=<"%~dp0TMP\MD5.txt"

REM SLPS_015.27 Alive (Japan) (Disc 2)
if !MD5!==4a1f0b0c83af1f0b86c148d7fcbbd683 set "PPtitle=Alive (Disc 2)" & set gameid=SLPS_015.28

REM SLPS_015.27 Alive (Japan) (Disc 3)
if !MD5!==f9fc75f4c8b283f068de54ec2d20da6e set "PPtitle=Alive (Disc 3)" & set gameid=SLPS_015.29

REM SLPS_027.28 Breath of Fire IV (E3 Demo)
if !MD5!==e727685a14959bc599e290befa511351 set "PPtitle=Breath of Fire IV (E3 Demo)" & set gameid=SLPD_027.28

REM SLPS_027.28 Breath of Fire IV: Utsurowazaru Mono
if !MD5!==f83e1fe73253a860301c5b67f7e67c48 set "PPtitle=Breath of Fire IV: Utsurowazaru Mono" & set gameid=SLPS_027.28

REM SLPS_012.32 Bust A Move (Disc 1)
if !MD5!==e84810d0f4db6e6658ee4208eb9f5415 set "PPtitle=Bust A Move (Disc 1) (Genteiban)" & set gameid=SLPG_012.32

REM SCUS_945.03 1Xtreme
if !MD5!==29c642b78b68cfff9a47fac51dd6d3c2 set "PPtitle=1Xtreme" & set gameid=SCUG_945.03

REM SCUS_945.03 ESPN Extreme Games
if !MD5!==c9395ccb9bb59e9cea9170bf44bd5578 set "PPtitle=ESPN Extreme Games" & set "gameid=SCUS_945.03"

REM SCUS_941.67 Jet Moto 2: Championship Edition
if !MD5!==ee9fc1cd31d1e2adf6230ffb8db64e0e set "PPtitle=Jet Moto 2: Championship Edition" & set gameid=SCUG_941.67

REM SLUS_005.94 Metal Gear Solid (Disc 1) (Demo)
if !MD5!==6c88d7b7f085257caba543c99cc37d1c set "PPtitle=Metal Gear Solid (Disc 1) (Demo)" & set gameid=SLUD_005.94

REM SCUS_941.61 PlayStation Underground Number 1 (Disc 2)
if !MD5!==a86a49cd948c4f9c5063fbc360459764 set "PPtitle=PlayStation Underground Number 1 (Disc 2)" & set gameid=SCUX_941.61

REM SLPS_017.22 Sougaku Toshi Osaka (Disc 2) (Object)
if !MD5!==7eb012b852c2b912fb02579d5b713770 set "PPtitle=Sougaku Toshi Osaka (Disc 2) (Object)" & set gameid=SLPS_017.23

REM SLUS_005.15 The Lost World: Jurassic Park: Special Edition
if !MD5!==31f7e4d4fd01718e0602cf2d795ca797 set "PPtitle=The Lost World: Jurassic Park: Special Edition" & set gameid=SLUG_005.15
)

REM Educational games with LightSpan Sofware PlayStation ID
set "LSPID="
echo !gameid!| "%~dp0BAT\busybox" grep -o "[0-9][0-9][0-9][0-9][0-9][0-9]\.[0-9][0-9][0-9]\|[0-9][0-9][0-9][0-9][0-9]\.[0-9][0-9][0-9]" | "%~dp0BAT\busybox" sed -e "s|\.||g; s|-||g" > "%~dp0TMP\EducID.txt" & set /P LSPID=<"%~dp0TMP\EducID.txt"

if defined LSPID (
echo "!PPtitle!"| "%~dp0BAT\busybox" sed -e "s|\""||g" | "%~dp0BAT\busybox" iconv -f utf8 -t ascii//TRANSLIT//IGNORE | "%~dp0BAT\busybox" sed -e "s|-||g; s|\.|_|g" | "%~dp0BAT\busybox" sed -e "s/^^/PP.LSP-!LSPID!.POPS./" | "%~dp0BAT\busybox" cut -c0-31 > "%~dp0TMP\PPName.txt"
) else (
echo "!PPtitle!"| "%~dp0BAT\busybox" sed -e "s|\""||g" | "%~dp0BAT\busybox" iconv -f utf8 -t ascii//TRANSLIT//IGNORE | "%~dp0BAT\busybox" sed -e "s|-|_|g; s|\.|_|g" | "%~dp0BAT\busybox" sed "s/^^/PP.!gameid!.POPS./" | "%~dp0BAT\busybox" cut -c0-32 > "%~dp0TMP\PPName.txt"
"%~dp0BAT\busybox" sed -r -i "s/^(.{11})(.{1})/\1/" "%~dp0TMP\PPName.txt"
)
REM Remove illegal character Partition name
"%~dp0BAT\busybox" sed -i "s/\s*$//g; s/[^A-Za-z0-9.]/_/g; y/abcdefghijklmnopqrstuvwxyz/ABCDEFGHIJKLMNOPQRSTUVWXYZ/" "%~dp0TMP\PPName.txt"


if not defined LSPID "%~dp0BAT\busybox" sed -i "s/\(.\{7\}\)./\1/" "%~dp0TMP\PPName.txt"
if not defined LSPID "%~dp0BAT\busybox" sed -i "s/.\{7\}/&-/" "%~dp0TMP\PPName.txt"

if defined LSPID "%~dp0BAT\busybox" sed -i "s/\(.\{6\}\)./\1/" "%~dp0TMP\PPName.txt"
if defined LSPID "%~dp0BAT\busybox" sed -i "s/.\{6\}/&-/" "%~dp0TMP\PPName.txt"
set /P PPName=<"%~dp0TMP\PPName.txt"

if defined LSPID "%~dp0BAT\busybox" sed -r -i "s/^(.{6})(.{1})/\1/" "%~dp0TMP\PPName.txt"
move "%~dp0TMP\POPSTARTER.KELF" "%~dp0POPS\Temp\!appfolder!\EXECUTE.KELF" >nul 2>&1

REM echo !PPName!

REM PAUSE
echo\
echo\
echo Creating !PPName!
echo ----------------------------------------------------
echo\

    echo         Getting game information...
    "%~dp0BAT\busybox" grep -o "LSP[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]\|LSP[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]\|[A-Z][A-Z][A-Z][A-Z][-][0-9][0-9][0-9][0-9][0-9]" "%~dp0TMP\PPName.txt" > "%~dp0TMP\DetectID.txt" & set /P gameid2=<"%~dp0TMP\DetectID.txt"

    "%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0BAT\HDD-PSBBN_XMB_SAMPLE_HEADER.zip" -o"%~dp0POPS\Temp\!appfolder!" -r -y >nul 2>&1
	"%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0BAT\PSBBN_XMB_PS1_GAMEINFO_Database.7z" -o"%~dp0TMP" "!gameid2!.html" -r -y >nul 2>&1

    "%~dp0BAT\busybox" awk " NF > 0 " "%~dp0TMP\!gameid2!.html" > "%~dp0POPS\Temp\!appfolder!\!gameid2!.html" 2>&1
	"%~dp0BAT\busybox" sed -i "s/Official Title/OFFICIAL TITLE/g; s/Date Released/DATE RELEASED/g; s/Region/REGION/g; s/Developer<\/td>/DEVELOPER<\/td>/g; s/Publisher<\/td>/PUBLISHER<\/td>/g; s/Genre/GENRE/g" "%~dp0POPS\Temp\!appfolder!\!gameid2!.html"
    REM "%~dp0BAT\busybox" grep -A2 "REGION" "%~dp0POPS\Temp\!appfolder!\!gameid2!.html" | "%~dp0BAT\busybox" sed "/REGION/d; /<td style=/d" | "%~dp0BAT\busybox" sed "s/&nbsp; / /g; s/^.*;//g; s/<\/td>//g; s|[\t][\t][\t]*||g; s/\s*$//" | "%~dp0BAT\busybox" sed -e "2,20d" > "%~dp0TMP\REGION.txt" & set /P REGIONTMP=<"%~dp0TMP\REGION.txt"
	"%~dp0BAT\busybox" grep -A2 "DATE RELEASED" "%~dp0POPS\Temp\!appfolder!\!gameid2!.html" | "%~dp0BAT\busybox" sed "/DATE RELEASED<\/td>/d; /<td style=/d" | "%~dp0BAT\busybox" sed "s/&nbsp; / /g; s/^.*;//g; s/<\/td>//g; s|[\t][\t][\t]*||g; s/\s*$//" | "%~dp0BAT\busybox" sed -e "2,20d" > "%~dp0TMP\RELEASE.txt" & set /P RELEASETMP=<"%~dp0TMP\RELEASE.txt"
	"%~dp0BAT\busybox" grep -A2 "DEVELOPER" "%~dp0POPS\Temp\!appfolder!\!gameid2!.html" | "%~dp0BAT\busybox" sed "/DEVELOPER<\/td>/d; /<td style=/d" | "%~dp0BAT\busybox" sed "s/&nbsp; / /g; s/^.*;//g; s/<\/td>//g; s|[\t][\t][\t]*||g; s/\s*$//" | "%~dp0BAT\busybox" sed -e "2,20d" > "%~dp0TMP\DEVELOPER.txt" & set /P DEVELOPERTMP=<"%~dp0TMP\DEVELOPER.txt"
    "%~dp0BAT\busybox" grep -A2 "PUBLISHER" "%~dp0POPS\Temp\!appfolder!\!gameid2!.html" | "%~dp0BAT\busybox" sed "/PUBLISHER<\/td>/d; /<td style=/d" | "%~dp0BAT\busybox" sed "s/&nbsp; / /g; s/^.*;//g; s/<\/td>//g; s|[\t][\t][\t]*||g; s/\s*$//" | "%~dp0BAT\busybox" sed -e "2,20d" > "%~dp0TMP\PUBLISHER.txt" & set /P PUBLISHERTMP=<"%~dp0TMP\PUBLISHER.txt"
	"%~dp0BAT\busybox" grep -A2 "GENRE " "%~dp0POPS\Temp\!appfolder!\!gameid2!.html" | "%~dp0BAT\busybox" sed "/GENRE /d; /<td style=/d" | "%~dp0BAT\busybox" sed "s/&nbsp; / /g; s/&nbsp;//g; s/^.*;//g; s/<\/td>//g; s|[\t][\t][\t]*||g; s/\s*$//" | "%~dp0BAT\busybox" sed -e "2,20d" > "%~dp0TMP\GENRE.txt" & set /P GENRETMP=<"%~dp0TMP\GENRE.txt"

     REM Game ID with PBPX other region than JAP
	 set "REGIONTMP="
     if "!gameid!"=="PAPX_900.28" set REGIONTMP=E
     if "!gameid!"=="PAPX_900.44" set REGIONTMP=A
     if "!gameid!"=="PBPX_950.02" set REGIONTMP=U
     if "!gameid!"=="PBPX_950.01" set REGIONTMP=E
     if "!gameid!"=="PBPX_950.03" set REGIONTMP=U
     if "!gameid!"=="PBPX_950.04" set REGIONTMP=U
     if "!gameid!"=="PBPX_950.06" set REGIONTMP=U
     if "!gameid!"=="PBPX_950.07" set REGIONTMP=E
     if "!gameid!"=="PBPX_950.08" set REGIONTMP=E
     if "!gameid!"=="PBPX_950.09" set REGIONTMP=U
     if "!gameid!"=="PBPX_950.10" set REGIONTMP=U
     if "!gameid!"=="PBPX_950.11" set REGIONTMP=U
	 
	 if not defined REGIONTMP (
	 echo !gameid!| "%~dp0BAT\busybox" cut -c3-3 > "%~dp0TMP\RegionID.txt" & set /P regionID=<"%~dp0TMP\RegionID.txt"
	 REM A = Asia
	 if "!regionID!"=="A" "%~dp0BAT\busybox" sed -ie "s/A/A/g" "%~dp0TMP\RegionID.txt" & set /P REGIONTMP=<"%~dp0TMP\RegionID.txt"
	 REM C = China
     if "!regionID!"=="C" "%~dp0BAT\busybox" sed -ie "s/C/C/g" "%~dp0TMP\RegionID.txt" & set /P REGIONTMP=<"%~dp0TMP\RegionID.txt"
	 REM E = Europe
	 if "!regionID!"=="E" "%~dp0BAT\busybox" sed -ie "s/E/E/g" "%~dp0TMP\RegionID.txt" & set /P REGIONTMP=<"%~dp0TMP\RegionID.txt"
	 REM K = Korean
	 if "!regionID!"=="K" "%~dp0BAT\busybox" sed -ie "s/K/K/g" "%~dp0TMP\RegionID.txt" & set /P REGIONTMP=<"%~dp0TMP\RegionID.txt"
	 REM P = Japan
	 if "!regionID!"=="P" "%~dp0BAT\busybox" sed -ie "s/P/J/g" "%~dp0TMP\RegionID.txt" & set /P REGIONTMP=<"%~dp0TMP\RegionID.txt"
	 REM UC = North America
	 if "!regionID!"=="U" "%~dp0BAT\busybox" sed -ie "s/U/U/g" "%~dp0TMP\RegionID.txt" & set /P REGIONTMP=<"%~dp0TMP\RegionID.txt"
	 )
	 if defined LSPID set REGIONTMP=U
	 
	 REM Unknown region
	 if not defined REGIONTMP set REGIONTMP=X
	 
	REM if %language%==french ("%~dp0BAT\busybox" sed -i "s/January/Janvier/g; s/February/F?r/g; s/March/Mars/g; s/April/Avril/g; s/May/Mai/g; s/June/Juin/g; s/July/Juillet/g; s/August/Aout/g; s/September/Septembre/g; s/October/Octobre/g; s/November/Novembre/g; s/December/D?re/g;" "%~dp0TMP\RELEASE.txt" & set /P RELEASETMP=<"%~dp0TMP\RELEASE.txt")
	
	 set "dbtitleTMP="
 	 for /f "tokens=1*" %%A in ( 'findstr !gameid! "%~dp0TMP\gameid.txt"' ) do (if not defined dbtitleTMP set dbtitleTMP=%%B
	 )
	 
	 if "!PPtitle!"=="ESPN Extreme Games" set dbtitleTMP=ESPN Extreme Games
	 if "!PPtitle!"=="Breath of Fire IV: Utsurowazaru Mono" set dbtitleTMP=Breath of Fire IV: Utsurowazaru Mono
	 
	 if not defined dbtitleTMP set dbtitleTMP=!PPtitle!
     echo "!dbtitleTMP!"| "%~dp0BAT\busybox" sed -e "s/\&/\\\&/g; s./.\\\/.g" | "%~dp0BAT\busybox" iconv -f windows-1252 -t utf-8 > "%~dp0TMP\dbtitle.txt"
	 "%~dp0BAT\busybox" sed -i "s/\"//g" "%~dp0TMP\dbtitle.txt"
	 set /P dbtitle=<"%~dp0TMP\dbtitle.txt"
	 
     echo "!RELEASETMP!"| "%~dp0BAT\busybox" sed -e "s/\&/\\\&/g; s./.\\\/.g" | "%~dp0BAT\busybox" iconv -f windows-1252 -t utf-8 > "%~dp0TMP\RELEASE.txt"
	 "%~dp0BAT\busybox" sed -i "s/\"//g" "%~dp0TMP\RELEASE.txt"
	 set /P RELEASE=<"%~dp0TMP\RELEASE.txt"
	 
	 echo "!REGIONTMP!"| "%~dp0BAT\busybox" sed -e "s/\&/\\\&/g; s./.\\\/.g" | "%~dp0BAT\busybox" iconv -f windows-1252 -t utf-8 > "%~dp0TMP\REGION.txt"
	 "%~dp0BAT\busybox" sed -i "s/\"//g" "%~dp0TMP\REGION.txt"
	 set /P REGION=<"%~dp0TMP\REGION.txt"
	 
     echo "!DEVELOPERTMP!"| "%~dp0BAT\busybox" sed -e "s/\&/\\\&/g; s./.\\\/.g" | "%~dp0BAT\busybox" iconv -f windows-1252 -t utf-8 > "%~dp0TMP\DEVELOPER.txt"
	 "%~dp0BAT\busybox" sed -i "s/\"//g" "%~dp0TMP\DEVELOPER.txt"
	 set /P DEVELOPER=<"%~dp0TMP\DEVELOPER.txt"
	
     echo "!PUBLISHERTMP!"| "%~dp0BAT\busybox" sed -e "s/\&/\\\&/g; s./.\\\/.g" | "%~dp0BAT\busybox" iconv -f windows-1252 -t utf-8 > "%~dp0TMP\PUBLISHER.txt"
	 "%~dp0BAT\busybox" sed -i "s/\"//g" "%~dp0TMP\PUBLISHER.txt"
	 set /P PUBLISHER=<"%~dp0TMP\PUBLISHER.txt"
	 
     echo "!GENRETMP!"| "%~dp0BAT\busybox" sed -e "s/\&/\\\&/g; s./.\\\/.g" | "%~dp0BAT\busybox" iconv -f windows-1252 -t utf-8 > "%~dp0TMP\GENRE.txt"
	 "%~dp0BAT\busybox" sed -i "s/\"//g" "%~dp0TMP\GENRE.txt"
	 set /P GENRE=<"%~dp0TMP\GENRE.txt"
     
	 REM PSBBN Original Date format
	 if defined RELEASETMP echo !RELEASETMP!| "%~dp0BAT\busybox" sed -E "s/January/01/g; s/February/02/g; s/March/03/g; s/April/04/g; s/May/05/g; s/June/06/g; s/July/07/g; s/August/08/g; s/September/09/g; s/October/10/g; s/November/11/g; s/December/12/g" > "%~dp0TMP\RELEASEBBN.txt" & "%~dp0BAT\busybox" sed -i "s/^\([1-9]\) /0\1 /g; s/ //g; s/\(.\{2\}\)\(.\{2\}\)\(.\{4\}\)/\3\2\1/" "%~dp0TMP\RELEASEBBN.txt" & set /P RELEASEBBN=<"%~dp0TMP\RELEASEBBN.txt"
	 
    "%~dp0BAT\busybox" sed -i -e "s/title =.*/title =/g; s/title =/title = !dbtitle!/g" "%~dp0POPS\Temp\!appfolder!\res\info.sys"
 	"%~dp0BAT\busybox" sed -i -e "s/title_id =.*/title_id =/g; s/title_id =/title_id = !gameid2!/g" "%~dp0POPS\Temp\!appfolder!\res\info.sys"
	"%~dp0BAT\busybox" sed -i -e "s/release_date =.*/release_date =/g; s/release_date =/release_date = !RELEASEBBN!/g" "%~dp0POPS\Temp\!appfolder!\res\info.sys"
	"%~dp0BAT\busybox" sed -i -e "s/area =.*/area =/g; s/area =/area = !REGION!/g" "%~dp0POPS\Temp\!appfolder!\res\info.sys"
    "%~dp0BAT\busybox" sed -i -e "s/developer_id =.*/developer_id =/g; s/developer_id =/developer_id = !DEVELOPER!/g" "%~dp0POPS\Temp\!appfolder!\res\info.sys"
	"%~dp0BAT\busybox" sed -i -e "s/publisher_id =.*/publisher_id =/g; s/publisher_id =/publisher_id = !PUBLISHER!/g" "%~dp0POPS\Temp\!appfolder!\res\info.sys"
    "%~dp0BAT\busybox" sed -i -e "s/genre =.*/genre =/g; s/genre =/genre = !GENRE!/g" "%~dp0POPS\Temp\!appfolder!\res\info.sys"
	
	REM Manual
	"%~dp0BAT\busybox" sed -i -e "s/label=\"APPNAME\"/label=\"!dbtitle!\"/g" "%~dp0POPS\Temp\!appfolder!\res\man.xml"

echo        Provided by psxdatacenter.com
"%~dp0BAT\Diagbox" gd 0e
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03

	echo Title:     [!dbtitleTMP!]
	echo Gameid:    [!gameid2!]
	echo Region:    [!REGIONTMP!]
	echo Release:   [!RELEASETMP!]
	echo Developer: [!DEVELOPERTMP!]
	echo Publisher: [!PUBLISHERTMP!]
	echo Genre:     [!GENRETMP!]

"%~dp0BAT\Diagbox" gd 0e
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0f

     echo            Downloading resources...
     if !DownloadART!==yes "%~dp0BAT\wget" -q --show-progress "https://archive.org/download/OPLM_ART_2023_11/OPLM_ART_2023_11.zip/PS1%%2F!gameid!%%2F!gameid!_COV.jpg" -O "%~dp0TMP\jkt_001.jpg" >nul 2>&1
     if !uselocalART!==yes if exist "%~dp0ART.zip" "%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0ART.zip" -o"%~dp0TMP" PS1\!gameid!\!gameid!_COV.jpg -r -y & move "%~dp0TMP\PS1\!gameid!\!gameid!_COV.jpg" "%~dp0TMP\jkt_001.jpg" >nul 2>&1
	 if !DownloadART!==yes "%~dp0BAT\wget" -q --show-progress "https://archive.org/download/OPLM_ART_2023_11/OPLM_ART_2023_11.zip/PS1%%2F!gameid!%%2F!gameid!_BG_00.jpg" -O "%~dp0TMP\BG.jpg" >nul 2>&1
	 if !uselocalART!==yes if exist "%~dp0ART.zip" "%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0ART.zip" -o"%~dp0TMP" PS1\!gameid!\!gameid!_BG_00.jpg -r -y & move "%~dp0TMP\PS1\!gameid!\!gameid!_BG_00.jpg" "%~dp0TMP\BG.jpg" >nul 2>&1
	 if !DownloadART!==yes "%~dp0BAT\wget" -q --show-progress "https://archive.org/download/OPLM_ART_2023_11/OPLM_ART_2023_11.zip/PS1%%2F!gameid!%%2F!gameid!_LGO.png" -O "%~dp0TMP\jkt_cp.png" >nul 2>&1
	 if !uselocalART!==yes if exist "%~dp0ART.zip" "%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0ART.zip" -o"%~dp0TMP" PS1\!gameid!\!gameid!_LGO.png -r -y & move "%~dp0TMP\PS1\!gameid!\!gameid!_LGO.png" "%~dp0TMP\jkt_cp.png" >nul 2>&1
	 if !DownloadART!==yes "%~dp0BAT\wget" -q --show-progress "https://archive.org/download/OPLM_ART_2023_11/OPLM_ART_2023_11.zip/PS1%%2F!gameid!%%2F!gameid!_SCR_00.jpg" -O "%~dp0TMP\SCR0.jpg" >nul 2>&1
	 if !uselocalART!==yes if exist "%~dp0ART.zip" "%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0ART.zip" -o"%~dp0TMP" PS1\!gameid!\!gameid!_SCR_00.jpg -r -y & move "%~dp0TMP\PS1\!gameid!\!gameid!_SCR_00.jpg" "%~dp0TMP\SCR0.jpg" >nul 2>&1
	 if !DownloadART!==yes "%~dp0BAT\wget" -q --show-progress "https://archive.org/download/OPLM_ART_2023_11/OPLM_ART_2023_11.zip/PS1%%2F!gameid!%%2F!gameid!_SCR_01.jpg" -O "%~dp0TMP\SCR1.jpg" >nul 2>&1
	 if !uselocalART!==yes if exist "%~dp0ART.zip" "%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0ART.zip" -o"%~dp0TMP" PS1\!gameid!\!gameid!_SCR_01.jpg -r -y & move "%~dp0TMP\PS1\!gameid!\!gameid!_SCR_01.jpg" "%~dp0TMP\SCR1.jpg" >nul 2>&1
	 REM "%~dp0BAT\wget" -q --show-progress "https://archive.org/download/OPLM_ART_2023_11/OPLM_ART_2023_11.zip/PS1%%2F!gameid!%%2F!gameid!_SCR_02.jpg" -O "%~dp0TMP\SCR2.jpg" >nul 2>&1
	 REM "%~dp0BAT\wget" -q --show-progress "https://archive.org/download/OPLM_ART_2023_11/OPLM_ART_2023_11.zip/PS1%%2F!gameid!%%2F!gameid!_SCR_03.jpg" -O "%~dp0TMP\SCR3.jpg" >nul 2>&1
	 
	 REM ART CUSTOM GAMEID
	 "%~dp0BAT\7-Zip\7z" e -bso0 "%~dp0BAT\ART_CUSTOM_GAMEID.zip" -o"%~dp0TMP\PS1\!gameid!" PS1\!gameid!_COV.jpg -r -y >nul 2>&1 & move "%~dp0TMP\PS1\!gameid!\!gameid!_COV.jpg" "%~dp0TMP\jkt_001.jpg" >nul 2>&1
	 cd "%~dp0TMP" & for %%F in (*.jpg *.png) do if %%~zF==0 del "%%F"
     
	 REM Covers
	 if exist "%~dp0TMP\jkt_001.jpg" "%~dp0BAT\nconvert" -overwrite -out png -resize 256 256 -rtype lanczos -efocus -o "%~dp0TMP\res\jkt_001.png" "%~dp0TMP\jkt_001.jpg" >nul 2>&1
	 if exist "%~dp0TMP\jkt_001.jpg" "%~dp0BAT\nconvert" -overwrite -out png -resize 76 108 -rtype lanczos -efocus -o "%~dp0TMP\res\jkt_002.png" "%~dp0TMP\jkt_001.jpg" >nul 2>&1
	 if exist "%~dp0TMP\jkt_cp.png" move "%~dp0TMP\jkt_cp.png" "%~dp0POPS\Temp\!appfolder!\res\jkt_cp.png" >nul 2>&1

	 REM Screenshot
	 if exist "%~dp0TMP\BG.jpg" "%~dp0BAT\nconvert" -overwrite -out png -resize 640 350 -efocus -o "%~dp0TMP\res\image\0.png" "%~dp0TMP\BG.jpg" >nul 2>&1
     if exist "%~dp0TMP\SCR0.jpg" "%~dp0BAT\nconvert" -overwrite -out png -resize 640 350 -rtype lanczos -efocus -o "%~dp0TMP\res\image\1.png" "%~dp0TMP\SCR0.jpg" >nul 2>&1
	 if exist "%~dp0TMP\SCR1.jpg" "%~dp0BAT\nconvert" -overwrite -out png -resize 640 350 -rtype lanczos -efocus -o "%~dp0TMP\res\image\2.png" "%~dp0TMP\SCR1.jpg" >nul 2>&1
	 REM if exist "%~dp0TMP\SCR2.jpg" "%~dp0BAT\nconvert" -overwrite -out png -resize 640 350 -rtype lanczos -efocus -o "%~dp0POPS\Temp\!appfolder!\res\image\3.png" "%~dp0TMP\SCR2.jpg" >nul 2>&1
	 REM if exist "%~dp0TMP\SCR3.jpg" "%~dp0BAT\nconvert" -overwrite -out png -resize 640 350 -rtype lanczos -efocus -o "%~dp0POPS\Temp\!appfolder!\res\image\4.png" "%~dp0TMP\SCR3.jpg" >nul 2>&1

	 REM Nconvert does not support long path
	 ROBOCOPY /E /MOVE "%~dp0TMP\res" "%~dp0POPS\Temp\!appfolder!\res" >nul 2>&1
     for %%f in (*.jpg *.png) do (del "%%f")

     cd /d "%~dp0POPS\temp\!appfolder!"
     echo            Creating partitions...
     echo device %@pfsshell_path% > "%~dp0TMP\pfs-log.txt"
	 echo rmpart "!PPName!" >> "%~dp0TMP\pfs-log.txt"
 	 echo mkpart "!PPName!" !Result!M PFS >> "%~dp0TMP\pfs-log.txt"
 	 echo            Installing...
 	 echo mount "!PPName!" >> "%~dp0TMP\pfs-log.txt"
	 if defined Disc0 echo put "!Disc0!" >> "%~dp0TMP\pfs-log.txt"
     if defined Disc1 echo put "!Disc1!" >> "%~dp0TMP\pfs-log.txt"
     if defined Disc2 echo put "!Disc2!" >> "%~dp0TMP\pfs-log.txt"
     if defined Disc3 echo put "!Disc3!" >> "%~dp0TMP\pfs-log.txt"
     if defined Disc4 echo put "!Disc4!" >> "%~dp0TMP\pfs-log.txt"
     if defined Disc0 echo rename "!Disc0!" IMAGE0.VCD >> "%~dp0TMP\pfs-log.txt"
     if defined Disc1 echo rename "!Disc1!" IMAGE0.VCD >> "%~dp0TMP\pfs-log.txt"
     if defined Disc2 echo rename "!Disc2!" IMAGE1.VCD >> "%~dp0TMP\pfs-log.txt"
     if defined Disc3 echo rename "!Disc3!" IMAGE2.VCD >> "%~dp0TMP\pfs-log.txt"
     if defined Disc4 echo rename "!Disc4!" IMAGE3.VCD >> "%~dp0TMP\pfs-log.txt"
	 echo put "EXECUTE.KELF" >> "%~dp0TMP\pfs-log.txt"
	 echo lcd "%~dp0POPS\Temp\!appfolder!\res" >> "%~dp0TMP\pfs-log.txt"
	 echo mkdir res >> "%~dp0TMP\pfs-log.txt"
	 echo cd res >> "%~dp0TMP\pfs-log.txt"
	 
	 cd /d "%~dp0POPS\temp\!appfolder!\res"
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
	 
	 cd /d "%~dp0POPS\Temp\!appfolder!"
	 "%~dp0BAT\busybox" sed -i -e "s/PP.//g" "%~dp0TMP\PPName.txt"
	 set /P VMCName=<"%~dp0TMP\PPName.txt"
	 
	 if exist "%~dp0POPS-Binaries\Hugopocked_POPStarter_Fixes.zip" (
	 findstr !gameid! "%~dp0TMP\id.txt" >nul 2>&1
	 if errorlevel 1 (
     REM echo         No need patch
     ) else (
	 set cheats=yes
	 
	 "%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0POPS-Binaries\Hugopocked_POPStarter_Fixes.zip" -o"%~dp0TMP" !gameid!\* -r -y & move "%~dp0TMP\!gameid!\*" "%~dp0POPS\Temp\!appfolder!" >nul 2>&1
	 if defined Disc0 "%~dp0BAT\busybox" md5sum "!Disc0!" | "%~dp0BAT\busybox" grep -o "[0-9a-f]\{32\}" > "%~dp0TMP\MD5.txt" & set /p MD5=<"%~dp0TMP\MD5.txt"
	 if defined Disc1 "%~dp0BAT\busybox" md5sum "!Disc1!" | "%~dp0BAT\busybox" grep -o "[0-9a-f]\{32\}" > "%~dp0TMP\MD5.txt" & set /p MD5=<"%~dp0TMP\MD5.txt"
	 "%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0POPS-Binaries\Hugopocked_POPStarter_Fixes.zip" -o"%~dp0TMP" !gameid!\!MD5!\* -r -y & move "%~dp0TMP\!gameid!\!MD5!\*" "%~dp0POPS\Temp\!appfolder!" >nul 2>&1 & del "%~dp0POPS\Temp\!appfolder!\*.xdelta" >nul 2>&1
	 echo            Patch GameShark...
      )
     )

	 echo cd .. >> "%~dp0TMP\pfs-log.txt"
	 echo lcd "%~dp0POPS\Temp\!appfolder!" >> "%~dp0TMP\pfs-log.txt"
	 echo umount >> "%~dp0TMP\pfs-log.txt"
	 echo mount __common >> "%~dp0TMP\pfs-log.txt"
	 echo mkdir POPS >> "%~dp0TMP\pfs-log.txt"
	 echo cd POPS >> "%~dp0TMP\pfs-log.txt"
	 echo mkdir "!VMCName!" >> "%~dp0TMP\pfs-log.txt"
	 echo cd "!VMCName!" >> "%~dp0TMP\pfs-log.txt"
     if defined cheats for %%x in (TROJAN_?.BIN PATCH_?.BIN CHEATS.TXT Readme.txt) do echo put "%%x" >> "%~dp0TMP\pfs-log.txt"

	 if defined Disc2 (
	 echo IMAGE0.VCD > "%~dp0POPS\Temp\!appfolder!\DISCS.TXT"
	 echo IMAGE1.VCD >> "%~dp0POPS\Temp\!appfolder!\DISCS.TXT"
	 if defined Disc3 echo IMAGE2.VCD >> "%~dp0POPS\Temp\!appfolder!\DISCS.TXT"
	 if defined Disc4 echo IMAGE3.VCD >> "%~dp0POPS\Temp\!appfolder!\DISCS.TXT"
	 "%~dp0BAT\busybox" sed -i "s/ *$//" "%~dp0POPS\Temp\!appfolder!\DISCS.TXT"
	 echo put DISCS.TXT >> "%~dp0TMP\pfs-log.txt"
	 )
	 
	 echo umount >> "%~dp0TMP\pfs-log.txt"
   	 echo exit >> "%~dp0TMP\pfs-log.txt"
 	 type "%~dp0TMP\pfs-log.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" tee > "%~dp0TMP\pfs-tmp.log"
 	 del "%~dp0TMP\pfs-log.txt" >nul 2>&1
	 
	 "%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0BAT\HDD-OSD_SAMPLE_HEADER.zip" -o"%~dp0POPS\Temp\!appfolder!\Default"  PS1\* -r -y & move "%~dp0POPS\Temp\!appfolder!\Default\PS1\*" "%~dp0POPS\Temp\!appfolder!" >nul 2>&1

	 md PS1\!gameid! >nul 2>&1
	 if !DownloadARTHDDOSD!==yes "%~dp0BAT\wget" -q "https://archive.org/download/hdd-osd-icons-pack/HDD-OSD-Icons-Pack.zip/PS1%%2F!gameid!%%2Ficon.sys" -O "%~dp0POPS\Temp\!appfolder!\PS1\!gameid!\icon.sys" >nul
	 if !DownloadARTHDDOSD!==yes "%~dp0BAT\wget" -q "https://archive.org/download/hdd-osd-icons-pack/HDD-OSD-Icons-Pack.zip/PS1%%2F!gameid!%%2Flist.ico" -O "%~dp0POPS\Temp\!appfolder!\PS1\!gameid!\list.ico" >nul
	 if !DownloadARTHDDOSD!==yes "%~dp0BAT\wget" -q "https://archive.org/download/hdd-osd-icons-pack/HDD-OSD-Icons-Pack.zip/PS1%%2F!gameid!%%2Fdel.ico" -O "%~dp0POPS\Temp\!appfolder!\PS1\!gameid!\del.ico" >nul
REM  "%~dp0BAT\wget" -q "https://archive.org/download/hdd-osd-icons-pack/HDD-OSD-Icons-Pack.zip/PS1%%2F%%F%%2FPreview.png" -O "%~dp0POPS\Temp\!appfolder!\PS1\Preview.png" >nul
	 if !uselocalARTHDDOSD!==yes if exist "%~dp0HDD-OSD-Icons-Pack.zip" "%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0HDD-OSD-Icons-Pack.zip" -o"%~dp0POPS\Temp\!appfolder!" PS1\!gameid!\ -r -y >nul 2>&1
     
	 cd /d "%~dp0POPS\Temp\!appfolder!\PS1\!gameid!" & for %%x in (*) do if %%~zx==0 (del %%x) else (if not exist "del.ico" copy "list.ico" "del.ico" >nul 2>&1 & move "%~dp0POPS\Temp\!appfolder!\PS1\!gameid!\*" "%~dp0POPS\Temp\!appfolder!" >nul 2>&1)

	 "%~dp0BAT\busybox" sed -ie "s/ = /=/g; s/=/ = /g; s/  =/ = /g" "%~dp0POPS\Temp\!appfolder!\icon.sys"
	 "%~dp0BAT\busybox" sed -ie "s/title0 =.*/title0 =/g; s/title0 =/title0 = !dbtitle!/g" "%~dp0POPS\Temp\!appfolder!\icon.sys"
 	 "%~dp0BAT\busybox" sed -ie "s/title1 =.*/title1 =/g; s/title1 =/title1 = !gameid2!/g" "%~dp0POPS\Temp\!appfolder!\icon.sys"
	 "%~dp0BAT\busybox" sed -ie "s/\s*$//" "%~dp0POPS\Temp\!appfolder!\icon.sys"
	 
	 cd /d "%~dp0POPS\Temp\!appfolder!" & "%~dp0BAT\hdl_dump" modify_header !@hdl_path! "!PPName!" >nul 2>&1
    
	 echo            Completed...
	 echo ----------------------------------------------------
	 move "%~dp0POPS\Temp\!appfolder!\EXECUTE.KELF" "%~dp0TMP\POPSTARTER.KELF" >nul 2>&1
     move "%~dp0POPS\Temp\!appfolder!\*.VCD" "%~dp0POPS" >nul 2>&1
     rmdir /Q/S "%~dp0POPS\Temp\!appfolder!" >nul 2>&1
     )
	)
  endlocal
 endlocal
endlocal
 )
) else ( echo        .VCD NOT DETECTED! )

     REM Reloading HDD Cache
     call "%~dp0BAT\__ReloadHDD_cache.bat" >nul 2>&1
     REM "%~dp0BAT\busybox" sed -i "$d" "%~dp0BAT\__Cache\PS2_GAMES_HDD.txt" & "%~dp0BAT\busybox" tail -n 1 "%~dp0BAT\__Cache\PARTITION_PS2HDD.txt" | "%~dp0BAT\busybox" sed -e "$s/Total slice size:/total/g; $s/used:/used/g; $s/available:/available/g" >> "%~dp0BAT\__Cache\PS2_GAMES_HDD.txt"

cd /d "%~dp0" & rmdir /Q/S "%~dp0POPS\Temp" >nul 2>&1
rmdir /Q/S "%~dp0TMP" >nul 2>&1

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo Completed...
echo\
echo\
"%~dp0BAT\Diagbox" gd 07

endlocal
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
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "!@hdl_path!" | "%~dp0BAT\busybox" grep "Playstation 2 HDD" >nul
if errorlevel 1 set "@hdl_path=" & goto ScanningPS2HDD
echo       [!@hdl_path! !@TotalHDD_Size! - !@ModelePS2HDD!]
)

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Install an application as a partition
echo ----------------------------------------------------
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
echo ----------------------------------------------------
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
   echo ----------------------------------------------------
   echo\
   echo\
   echo Enter the name of the APP you want to install or update
   set /p "appfolder="
   IF "!appfolder!"=="" set "@pfs_APP=" & (goto TransferAPPSPart)

"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Detecting ELF:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 07

if exist "%~dp0APPS\!appfolder!" (

cd /d "%~dp0APPS\!appfolder!"

set /a ELFcount=0
for %%f in (*.elf) do (
set /a ELFcount+=1
)
 
      if !ELFcount!==1 (
	  for %%f in (*.elf) do set ELFBOOT=%%f
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
	  echo ----------------------------------------------------
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
echo Configure your Application:
echo ----------------------------------------------------
echo\
"%~dp0BAT\Diagbox" gd 0f
     
	 type "%~dp0BAT\__Cache\PARTITION_PS2HDD.txt" > "%~dp0TMP\hdd-prt.txt"

      echo Enter the Title of your Application
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
	 
      echo Do you want to choose a custom partition name?
      choice /c YN
	  echo\
	  if !errorlevel!==1 (
	  echo Enter the name of your partition
      echo Example: PP.UAPP-00001..YOURAPPNAME
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
echo ----------------------------------------------------
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
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
    "%~dp0BAT\busybox" grep -e "0x0100" "%~dp0BAT\__Cache\PARTITION_PS2HDD.txt" | "%~dp0BAT\busybox" grep -e "PP\." | "%~dp0BAT\busybox" sed "/\.POPS\./d" | "%~dp0BAT\busybox" cut -c30-250
"%~dp0BAT\Diagbox" gd 0e
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0f
     echo\
	 echo\
     set /p "PPName=Enter the partition name:"
     IF "!PPName!"=="" (goto TransferAPPSPart)

"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Detecting !PPName! Partition:
echo ----------------------------------------------------
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
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
cd /d "%~dp0APPS\!appfolder!"

    "%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0BAT\HDD-PSBBN_XMB_SAMPLE_HEADER.zip" -o"%~dp0APPS\!appfolder!" -r -y >nul 2>&1
	"%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0BAT\HDD-OSD_SAMPLE_HEADER.zip" -o"%~dp0TMP" APP\* -r -y >nul 2>&1
    del ReadMe_Info.txt >nul 2>&1
    
	echo !PPName!| "%~dp0BAT\busybox" grep -ow "[A-Z][A-Z][A-Z][A-Z]-[0-9][0-9][0-9][0-9][0-9]" > "%~dp0TMP\PPID.txt" & set /P PPID=<"%~dp0TMP\PPID.txt"

	echo Title:     [!PPTitle!]
	if defined PPID echo Appid:     [!PPID!]
	REM echo Release:   [!Release!]
	echo Genre:     [!Genre!]
    echo Size:      [!partsize!]
	
"%~dp0BAT\Diagbox" gd 0e
echo ----------------------------------------------------
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
	"%~dp0BAT\busybox" sed -i -e "s/label=\"APPNAME\"/label=\"!PPTitle!\"/g" "%~dp0APPS\!appfolder!\res\man.xml"
	)
	
if !@pfs_APP!==yesUP (
"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Updating !appfolder!:
"%~dp0BAT\Diagbox" gd 0e
echo ----------------------------------------------------
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
	REM "%~dp0BAT\busybox" sed -i "$d" "%~dp0BAT\__Cache\PS2_GAMES_HDD.txt" & "%~dp0BAT\busybox" tail -n 1 "%~dp0BAT\__Cache\PARTITION_PS2HDD.txt" | "%~dp0BAT\busybox" sed -e "$s/Total slice size:/total/g; $s/used:/used/g; $s/available:/available/g" >> "%~dp0BAT\__Cache\PS2_GAMES_HDD.txt"
	
cd /d "%~dp0" & rmdir /Q/S "%~dp0TMP" >nul 2>&1
echo\
"%~dp0BAT\Diagbox" gd 0f
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo Completed...
echo\
echo\
"%~dp0BAT\Diagbox" gd 0f

pause & (goto HDDOSDPartManagement)
REM ####################################################################################################################
:UpdatePPHeader
cls
set rootpath=%cd%
chcp 65001 >nul 2>&1

mkdir "%~dp0TMP" >nul 2>&1
cd /d "%~dp0TMP"

IF NOT DEFINED @hdl_path ( rmdir /Q/S "%~dp0TMP" >nul 2>&1 & goto ScanningPS2HDD ) else (
"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning for Playstation 2 HDDs:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "!@hdl_path!" | "%~dp0BAT\busybox" grep "Playstation 2 HDD" >nul
if errorlevel 1 set "@hdl_path=" & goto ScanningPS2HDD
echo       [!@hdl_path! !@TotalHDD_Size! - !@ModelePS2HDD!]
)

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Update Partition Resources Header:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1^) Yes
"%~dp0BAT\Diagbox" gd 0c
echo         2^) No
"%~dp0BAT\Diagbox" gd 0e
echo         3^) Yes ^(All^)
"%~dp0BAT\Diagbox" gd 07
echo\
CHOICE /C 123 /M "Select Option:"

IF %ERRORLEVEL%==1 set UPDATEPPHeader=Manually
IF %ERRORLEVEL%==2 (goto HDDOSDPartManagement)
IF %ERRORLEVEL%==3 set UPDATEPPHeader=Yes 

echo\
echo\
echo Choose the partitions 
echo ----------------------------------------------------
echo         1^) Update Partition Header PS1 Games
echo         2^) Update Partition Header PS2 Games
echo         3^) Update Partition Header APP System
echo\
CHOICE /C 123 /M "Select Option:"
IF %ERRORLEVEL%==1 set "PartitionType=PS1" & set "showtype=Game" & set "selectlang=yes" & copy "%~dp0BAT\TitlesDB\TitlesDB_PS1_English.txt" "%~dp0TMP\gameid.txt" >nul 2>&1
IF %ERRORLEVEL%==2 set "PartitionType=PS2" & set "showtype=Game" & set "selectlang=yes"
IF %ERRORLEVEL%==3 set "PartitionType=APP" & set "showtype=Application" & copy "%~dp0BAT\TitlesDB\TitlesDB_APPS.txt" "%~dp0TMP\gameid.txt" >nul 2>&1

if defined selectlang (
echo\
echo\
echo Choose the titles language of the games list:
echo ----------------------------------------------------
echo Some games have their own title in several languages for example:
echo English = The Simpsons Game
echo French  = Les Simpson le jeu
"%~dp0BAT\Diagbox" gd 0e
echo NOTE: Some titles may not be translated
"%~dp0BAT\Diagbox" gd 07
echo\
echo 1. English
echo 2. French
echo\
CHOICE /C 12 /M "Select Option:"
if !errorlevel!==1 set language=english& copy "%~dp0BAT\TitlesDB\TitlesDB_PS2_English.txt" "%~dp0TMP\gameid.txt" >nul 2>&1
if !errorlevel!==2 set language=french& copy "%~dp0BAT\TitlesDB\TitlesDB_PS2_French.txt" "%~dp0TMP\gameid.txt" >nul 2>&1
)

if exist "%~dp0ART.zip" (
echo\
"%~dp0BAT\Diagbox" gd 0e
echo ART.zip detected do you want use it?
"%~dp0BAT\Diagbox" gd 0f
CHOICE /C YN /M "Select Option:"
IF ERRORLEVEL 1 set uselocalART=yes
IF ERRORLEVEL 2 set uselocalART=no
) else (set uselocalART=no)

if !uselocalART!==no (
    echo.
	echo Checking internet Or Website connection... For ART
	"%~dp0BAT\wget" -q --show-progress "https://archive.org/download/OPLM_ART_2023_11/OPLM_ART_2023_11.zip/PS1%%2FSCES_000.01%%2FSCES_000.01_COV.jpg" -O "%~dp0TMP\SCES_000.01_COV.jpg" >nul 2>&1
	for %%F in (SCES_000.01_COV.jpg) do if %%~zF==0 del "%%F"

if not exist SCES_000.01_COV.jpg (
"%~dp0BAT\Diagbox" gd 0c
    echo\
	echo Unable to connect to internet Or Website
	if exist "%~dp0ART.zip" set uselocalART=yes
	echo You will switch to offline mode
	echo\
	echo\
"%~dp0BAT\Diagbox" gd 0f
	pause
 ) else (set DownloadART=yes)
)

if exist "%~dp0HDD-OSD-Icons-Pack.zip" (
echo\
"%~dp0BAT\Diagbox" gd 0e
echo HDD-OSD-Icons-Pack.zip detected do you want use it?
"%~dp0BAT\Diagbox" gd 0f
CHOICE /C YN /M "Select Option:"
IF ERRORLEVEL 1 set uselocalARTHDDOSD=yes
IF ERRORLEVEL 2 set uselocalARTHDDOSD=no
) else (set uselocalARTHDDOSD=no)

if !uselocalARTHDDOSD!==no (
    echo.
	echo Checking internet Or Website connection... For HDD-OSD ART
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

"%~dp0BAT\Diagbox" gd 0e
cls
echo\
echo\
echo Scanning Partition !PartitionType!:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03

if "!PartitionType!"=="PS1" type "%~dp0BAT\__Cache\PARTITION_POPS_GAME.txt" | "%~dp0BAT\busybox" sort -k2 > "%~dp0TMP\PARTITION_!PartitionType!.txt"
if "!PartitionType!"=="PS2" type "%~dp0BAT\__Cache\PARTITION_HDL_GAME.txt" | "%~dp0BAT\busybox" sort -k2 > "%~dp0TMP\PARTITION_!PartitionType!.txt"
if "!PartitionType!"=="APP" type "%~dp0BAT\__Cache\PARTITION_APPS.txt" | "%~dp0BAT\busybox" sort -k2 > "%~dp0TMP\PARTITION_!PartitionType!.txt"

"%~dp0BAT\busybox" sed "s/|.*//" "%~dp0TMP\PARTITION_!PartitionType!.txt" > "%~dp0TMP\PARTITION_TMP.txt" & type "%~dp0TMP\PARTITION_TMP.txt"

"%~dp0BAT\Diagbox" gd 0e
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0f

if !UPDATEPPHeader!==Manually (
    
	echo\
	"%~dp0BAT\Diagbox" gd 0e
	echo Please type the gameid ^+ GameName as shown in the Games List.
	"%~dp0BAT\Diagbox" gd 07
    set /p PPName=
    IF "!PPName!"=="" (goto HDDOSDPartManagement)
	"%~dp0BAT\busybox" grep -Fx "!PPName!" "%~dp0TMP\PARTITION_TMP.txt" >nul
	if errorlevel 1 (set "PPName=!PPName!") else ("%~dp0BAT\busybox" grep "!PPName!" "%~dp0TMP\PARTITION_!PartitionType!.txt" | "%~dp0BAT\busybox" sed "s/^[^|]*|//" > "%~dp0TMP\PPNameHeader.txt" & set /P PPName=<"%~dp0TMP\PPNameHeader.txt")

"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Detecting !PPName! Partition:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 07

   "%~dp0BAT\busybox" grep -w "!PPName!" "%~dp0TMP\PARTITION_!PartitionType!.txt" | "%~dp0BAT\busybox" sed "s/^[^|]*|//" > "%~dp0TMP\PPSelected.txt" & set /P PPSELECTED=<"%~dp0TMP\PPSelected.txt"
	
	if "!PPSELECTED!"=="!PPName!" (
	echo !PPName!> "%~dp0TMP\PARTITION_!PartitionType!.txt"
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
REM echo ----------------------------------------------------
REM echo\
"%~dp0BAT\Diagbox" gd 0f
      
	  echo\
	  echo\
      "%~dp0BAT\Diagbox" gd 0e
      echo Do you want to update the titles displayed in HDD-OSD, PSBBN, XMB?
      "%~dp0BAT\Diagbox" gd 0f
      CHOICE /C YN /M "Select Option:"
	  IF !ERRORLEVEL!==1 (echo Yes & set UpdateTitle=Yes) else (echo No & set UpdateTitle=No)
	  echo\
	  
	 "%~dp0BAT\Diagbox" gd 0e
      echo Do you want to update 3D Icon displayed in HDD-OSD?
      "%~dp0BAT\Diagbox" gd 0f
      CHOICE /C YN /M "Select Option:"
	  IF !ERRORLEVEL!==1 (echo Yes & set Update3DIcon=Yes) else (echo No & set Update3DIcon=No)
	  echo\
	  
	  "%~dp0BAT\Diagbox" gd 0e
      echo Do you want to update Game infos displayed in PSBBN, XMB?
      "%~dp0BAT\Diagbox" gd 0f
      CHOICE /C YN /M "Select Option:"
	  IF !ERRORLEVEL!==1 (echo Yes & set UpdateGameInfos=Yes) else (echo No & set UpdateGameInfos=No)
	  echo\
	  
      "%~dp0BAT\Diagbox" gd 0e
      echo Do you want to update ART resources displayed in PSBBN, XMB?
      "%~dp0BAT\Diagbox" gd 0f
      CHOICE /C YN /M "Select Option:"
	  IF !ERRORLEVEL!==1 (echo Yes & set UpdateART=Yes) else (echo No & set UpdateART=No)
	  echo\
	  
	  if !PartitionType!==PS2 (
	  "%~dp0BAT\Diagbox" gd 0e
      echo Do you want to update OPL-Launcher?
      "%~dp0BAT\Diagbox" gd 0f
      CHOICE /C YN /M "Select Option:"
	  IF !ERRORLEVEL!==1 (echo Yes & set UpdateLauncher=Yes) else (echo No & set UpdateLauncher=No)
	  echo\
      )
	  
	  if !PartitionType!==PS1 (
	  
	  REM if exist "%~dp0POPS-Binaries\Hugopocked_POPStarter_Fixes.zip" (
	  REM "%~dp0BAT\Diagbox" gd 0e
      REM echo Do you want to update Hugopocked patches?
      REM "%~dp0BAT\Diagbox" gd 0f
      REM CHOICE /C YN /M "Select Option:"
	  REM IF !ERRORLEVEL!==1 (echo Yes & set HugoPatchesFix=Yes) else (echo No & set HugoPatchesFix=No)
	  REM )
	  
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

for /f "usebackq tokens=1* delims=|" %%p in ("%~dp0TMP\PARTITION_!PartitionType!.txt") do (
set "PPName="
set PPName=%%q
if not defined PPName set PPName=%%p

set "RELEASETMP="
set "DEVELOPERTMP="
set "PUBLISHERTMP="
set "GENRETMP="
set "Contentweb="

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo !PPName!:
echo ----------------------------------------------------
echo\
"%~dp0BAT\Diagbox" gd 0f

echo !PPName!| "%~dp0BAT\busybox" grep -o "[A-Z][A-Z][A-Z][A-Z]-[0-9][0-9][0-9][0-9][0-9]" > "%~dp0TMP\DetectID.txt" & set /P gameid2=<"%~dp0TMP\DetectID.txt"

if not defined gameid2 (
"%~dp0BAT\Diagbox" gd 0c
echo ERROR: Bad partition name, Please reinstall the game.
echo\
"%~dp0BAT\Diagbox" gd 06
echo Your partition name should look like this: PP.SLES-12345..GAME_NAME
) else (

MD "%~dp0TMP\!gameid2!\PP.HEADER\PFS\res\image"
cd /d "%~dp0TMP\!gameid2!\PP.HEADER"

     echo !gameid2!| "%~dp0BAT\busybox" sed "s/-/_/g" | "%~dp0BAT\busybox" sed "s/.\{8\}/&./" > "%~dp0TMP\DetectID.txt" & set /P gameid=<"%~dp0TMP\DetectID.txt"
	 
	 set "dbtitleTMP="
 	 for /f "tokens=1*" %%A in ( 'findstr !gameid! "%~dp0TMP\gameid.txt"' ) do if not defined dbtitleTMP set dbtitleTMP=%%B
	 
	 REM PS2 Games
	 if "!PPName!"=="PP.SLUS-20273..NAMCO_MUSEUM__" set "dbtitleTMP=Namco Museum"
	 if "!PPName!"=="__.SLUS-20273..NAMCO_MUSEUM__" set "dbtitleTMP=Namco Museum"
	 
	 if "!PPName!"=="PP.SLUG-20273..NAMCO_MUSEUM_50T" set "dbtitleTMP=Namco Museum 50th Anniversary"
	 if "!PPName!"=="__.SLUG-20273..NAMCO_MUSEUM_50T" set "dbtitleTMP=Namco Museum 50th Anniversary"
	 
	 if "!PPName!"=="PP.SLUS-20643..SOULCALIBUR_II" set "dbtitleTMP=Soulcalibur II"
	 if "!PPName!"=="__.SLUS-20643..SOULCALIBUR_II" set "dbtitleTMP=Soulcalibur II"
	 
	 if "!PPName!"=="PP.SLUD-20643..NAMCO_TRANSMISSI" set "dbtitleTMP=Namco Transmission v1.03"
	 if "!PPName!"=="__.SLUD-20643..NAMCO_TRANSMISSI" set "dbtitleTMP=Namco Transmission v1.03"
	 
	 REM PS1 Games
	 if "!PPName!"=="PP.SLPS-01528.POPS.ALIVE__DISC" set "dbtitleTMP=Alive (Disc 2)"
     if "!PPName!"=="PP.SLPS-01529.POPS.ALIVE__DISC" set "dbtitleTMP=Alive (Disc 3)"
     if "!PPName!"=="PP.SCUG-94503.POPS.1XTREME" set "dbtitleTMP=1Xtreme"
     if "!PPName!"=="PP.SLPD-02728.POPS.BREATH_OF_FI" set "dbtitleTMP=Breath of Fire IV (E3 Demo)"
     if "!PPName!"=="PP.SLPS-02728.POPS.BREATH_OF_FI" set "dbtitleTMP=Breath of Fire IV - Utsurowazaru Mono"
     if "!PPName!"=="PP.SLPG-01232.POPS.BUST_A_MOVE" set "dbtitleTMP=Bust A Move (Disc 1) (Genteiban)"
     if "!PPName!"=="PP.SCUS-94503.POPS.ESPN_EXTREME" set "dbtitleTMP=ESPN Extreme Games"
     if "!PPName!"=="PP.SCUG-94167.POPS.JET_MOTO_2_" set "dbtitleTMP=Jet Moto 2: Championship Edition"
     if "!PPName!"=="PP.SLUD-00594.POPS.METAL_GEAR_S" set "dbtitleTMP=Metal Gear Solid (Disc 1) (Demo)"
     if "!PPName!"=="PP.SCUX-94161.POPS.PLAYSTATION" set "dbtitleTMP=PlayStation Underground Number 1 (Disc 2)"
     if "!PPName!"=="PP.SLPS-01723.POPS.SOUGAKU_TOSH" set "dbtitleTMP=Sougaku Toshi Osaka (Disc 2) (Object)"
     if "!PPName!"=="PP.SLUG-00515.POPS.THE_LOST_WOR" set "dbtitleTMP=The Lost World: Jurassic Park: Special Edition"

	 if not defined dbtitleTMP (
	 "%~dp0BAT\hdl_dump_fix_header" dump_header !@hdl_path! "!PPName!" >nul 2>&1
	 "%~dp0BAT\busybox" grep "title0 = " "%~dp0TMP\!gameid2!\PP.HEADER\icon.sys" | "%~dp0BAT\busybox" sed "s/^.* = //" > "%~dp0TMP\NodbtitleTMP.txt" & set /P dbtitleTMP=<"%~dp0TMP\NodbtitleTMP.txt"
	 )

	 REM FOR PS2 GAMES
	 if !PartitionType!==PS2 (
	 
	 "%~dp0BAT\wget" -q --show-progress https://psxdatacenter.com/psx2/games2/!gameid2!.html 2>&1 -O "%~dp0TMP\!gameid2!\!gameid2!.html" >nul 2>&1
	 if errorlevel 1 ( "%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0BAT\PSBBN_XMB_PS2_GAMEINFO_Database.7z" -o"%~dp0TMP\!gameid2!" !gameid2!.html -r -y)
	 
     "%~dp0BAT\busybox" grep -A2 "DATE RELEASED" "%~dp0TMP\!gameid2!\!gameid2!.html" | "%~dp0BAT\busybox" sed "/DATE RELEASED<\/td>/d; /<td style=/d" | "%~dp0BAT\busybox" sed "s/^.*;//g; s/<\/td>//g; s|[\t][\t][\t]*||g; s/\s*$//" | "%~dp0BAT\busybox" sed -e "2,20d" > "%~dp0TMP\!gameid2!\RELEASE.txt" & set /P RELEASETMP=<"%~dp0TMP\!gameid2!\RELEASE.txt"
	 "%~dp0BAT\busybox" grep -A2 "DEVELOPER" "%~dp0TMP\!gameid2!\!gameid2!.html" | "%~dp0BAT\busybox" sed "/DEVELOPER<\/td>/d; /<td style=/d" | "%~dp0BAT\busybox" sed "s/^.*;//g; s/<\/td>//g; s|[\t][\t][\t]*||g; s/\s*$//" | "%~dp0BAT\busybox" sed -e "2,20d" > "%~dp0TMP\!gameid2!\DEVELOPER.txt" & set /P DEVELOPERTMP=<"%~dp0TMP\!gameid2!\DEVELOPER.txt"
     "%~dp0BAT\busybox" grep -A2 "PUBLISHER" "%~dp0TMP\!gameid2!\!gameid2!.html" | "%~dp0BAT\busybox" sed "/PUBLISHER<\/td>/d; /<td style=/d" | "%~dp0BAT\busybox" sed "s/^.*;//g; s/<\/td>//g; s|[\t][\t][\t]*||g; s/\s*$//" | "%~dp0BAT\busybox" sed -e "2,20d" > "%~dp0TMP\!gameid2!\PUBLISHER.txt" & set /P PUBLISHERTMP=<"%~dp0TMP\!gameid2!\PUBLISHER.txt"
	 "%~dp0BAT\busybox" grep -A2 "GENRE" "%~dp0TMP\!gameid2!\!gameid2!.html" | "%~dp0BAT\busybox" sed "/GENRE/d; /<td style=/d" | "%~dp0BAT\busybox" sed "s/^.*;//g; s/<\/td>//g; s|[\t][\t][\t]*||g; s/\s*$//" | "%~dp0BAT\busybox" sed -e "2,20d" > "%~dp0TMP\!gameid2!\GENRE.txt" & set /P GENRETMP=<"%~dp0TMP\!gameid2!\GENRE.txt"

	 REM PS2 Game ID with PBPX other region than JAP
	 set "REGIONTMP="
     if "!gameid!"=="PBPX_952.10" set REGIONTMP=U
     if "!gameid!"=="PBPX_952.16" set REGIONTMP=U
     if "!gameid!"=="PBPX_952.18" set REGIONTMP=U
     if "!gameid!"=="PBPX_952.19" set REGIONTMP=E
     if "!gameid!"=="PBPX_952.23" set REGIONTMP=U
     if "!gameid!"=="PBPX_952.47" set REGIONTMP=U
     if "!gameid!"=="PBPX_952.48" set REGIONTMP=U
     if "!gameid!"=="PBPX_955.17" set REGIONTMP=U
     if "!gameid!"=="PBPX_952.04" set REGIONTMP=E
     if "!gameid!"=="PBPX_952.05" set REGIONTMP=E
     if "!gameid!"=="PBPX_952.08" set REGIONTMP=E
     if "!gameid!"=="PBPX_952.09" set REGIONTMP=E
     if "!gameid!"=="PBPX_952.20" set REGIONTMP=E
     if "!gameid!"=="PBPX_952.39" set REGIONTMP=U
     if "!gameid!"=="PBPX_952.42" set REGIONTMP=U
     if "!gameid!"=="PBPX_952.46" set REGIONTMP=U
     if "!gameid!"=="PBPX_955.03" set REGIONTMP=U
     if "!gameid!"=="PBPX_955.06" set REGIONTMP=E
     if "!gameid!"=="PBPX_955.14" set REGIONTMP=E
     if "!gameid!"=="PBPX_955.19" set REGIONTMP=U
     if "!gameid!"=="PBPX_955.20" set REGIONTMP=E
	 )
	 
	 REM FOR PS1 GAMES
	 if !PartitionType!==PS1 (
	 
	"%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0BAT\PSBBN_XMB_PS1_GAMEINFO_Database.7z" -o"%~dp0TMP" "!gameid2!.html" -r -y >nul 2>&1
	 
	 "%~dp0BAT\busybox" awk " NF > 0 " "%~dp0TMP\!gameid2!.html" > "%~dp0TMP\!gameid2!\!gameid2!.html" 2>&1
	 "%~dp0BAT\busybox" sed -i "s/Official Title/OFFICIAL TITLE/g; s/Date Released/DATE RELEASED/g; s/Region/REGION/g; s/Developer<\/td>/DEVELOPER<\/td>/g; s/Publisher<\/td>/PUBLISHER<\/td>/g; s/Genre/GENRE/g" "%~dp0TMP\!gameid2!\!gameid2!.html"
	 "%~dp0BAT\busybox" grep -A2 "DATE RELEASED" "%~dp0TMP\!gameid2!\!gameid2!.html" | "%~dp0BAT\busybox" sed "/DATE RELEASED<\/td>/d; /<td style=/d" | "%~dp0BAT\busybox" sed "s/&nbsp; / /g; s/^.*;//g; s/<\/td>//g; s|[\t][\t][\t]*||g; s/\s*$//" | "%~dp0BAT\busybox" sed -e "2,20d" > "%~dp0TMP\!gameid2!\RELEASE.txt" & set /P RELEASETMP=<"%~dp0TMP\!gameid2!\RELEASE.txt"
	 "%~dp0BAT\busybox" grep -A2 "DEVELOPER" "%~dp0TMP\!gameid2!\!gameid2!.html" | "%~dp0BAT\busybox" sed "/DEVELOPER<\/td>/d; /<td style=/d" | "%~dp0BAT\busybox" sed "s/&nbsp; / /g; s/^.*;//g; s/<\/td>//g; s|[\t][\t][\t]*||g; s/\s*$//" | "%~dp0BAT\busybox" sed -e "2,20d" > "%~dp0TMP\!gameid2!\DEVELOPER.txt" & set /P DEVELOPERTMP=<"%~dp0TMP\!gameid2!\DEVELOPER.txt"
     "%~dp0BAT\busybox" grep -A2 "PUBLISHER" "%~dp0TMP\!gameid2!\!gameid2!.html" | "%~dp0BAT\busybox" sed "/PUBLISHER<\/td>/d; /<td style=/d" | "%~dp0BAT\busybox" sed "s/&nbsp; / /g; s/^.*;//g; s/<\/td>//g; s|[\t][\t][\t]*||g; s/\s*$//" | "%~dp0BAT\busybox" sed -e "2,20d" > "%~dp0TMP\!gameid2!\PUBLISHER.txt" & set /P PUBLISHERTMP=<"%~dp0TMP\!gameid2!\PUBLISHER.txt"
	 "%~dp0BAT\busybox" grep -A2 "GENRE " "%~dp0TMP\!gameid2!\!gameid2!.html" | "%~dp0BAT\busybox" sed "/GENRE /d; /<td style=/d" | "%~dp0BAT\busybox" sed "s/&nbsp; / /g; s/&nbsp;//g; s/^.*;//g; s/<\/td>//g; s|[\t][\t][\t]*||g; s/\s*$//" | "%~dp0BAT\busybox" sed -e "2,20d" > "%~dp0TMP\!gameid2!\GENRE.txt" & set /P GENRETMP=<"%~dp0TMP\!gameid2!\GENRE.txt"

     REM PS1 Game ID with PBPX other region than JAP
	 set "REGIONTMP="
     if "!gameid!"=="PAPX_900.28" set REGIONTMP=E
     if "!gameid!"=="PAPX_900.44" set REGIONTMP=A
     if "!gameid!"=="PBPX_950.02" set REGIONTMP=U
     if "!gameid!"=="PBPX_950.01" set REGIONTMP=E
     if "!gameid!"=="PBPX_950.03" set REGIONTMP=U
     if "!gameid!"=="PBPX_950.04" set REGIONTMP=U
     if "!gameid!"=="PBPX_950.06" set REGIONTMP=U
     if "!gameid!"=="PBPX_950.07" set REGIONTMP=E
     if "!gameid!"=="PBPX_950.08" set REGIONTMP=E
     if "!gameid!"=="PBPX_950.09" set REGIONTMP=U
     if "!gameid!"=="PBPX_950.10" set REGIONTMP=U
     if "!gameid!"=="PBPX_950.11" set REGIONTMP=U
	 )
	
	 if !PartitionType!==APP (
	 "%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0BAT\PSBBN_XMB_APPSINFOS_Database.zip" -o"%~dp0TMP" !gameid2!.txt -r -y >nul 2>&1
	 set REGIONTMP=X
	 
	 "%~dp0BAT\busybox" grep "Devloper=" "%~dp0TMP\!gameid2!.txt" | "%~dp0BAT\busybox" sed "s/^.*=//" > "%~dp0TMP\!gameid2!\DEVLOPER.txt" & set /P DEVELOPERTMP=<"%~dp0TMP\!gameid2!\DEVLOPER.txt"
	 "%~dp0BAT\busybox" grep "Publisher=" "%~dp0TMP\!gameid2!.txt" | "%~dp0BAT\busybox" sed "s/^.*=//" > "%~dp0TMP\!gameid2!\PUBLISHER.txt" & set /P PUBLISHERTMP=<"%~dp0TMP\!gameid2!\PUBLISHER.txt"
	 "%~dp0BAT\busybox" grep "Contentweb=" "%~dp0TMP\!gameid2!.txt" | "%~dp0BAT\busybox" sed "s/^.*=//" > "%~dp0TMP\!gameid2!\Contentweb.txt" & set /P Contentweb=<"%~dp0TMP\!gameid2!\Contentweb.txt"
	 "%~dp0BAT\busybox" grep "Genre=" "%~dp0TMP\!gameid2!.txt" | "%~dp0BAT\busybox" sed "s/^.*=//" > "%~dp0TMP\!gameid2!\GENRE.txt" & set /P GENRETMP=<"%~dp0TMP\!gameid2!\GENRE.txt"
	 )
	 
	 if not defined REGIONTMP (
	 echo !gameid!| "%~dp0BAT\busybox" cut -c3-3 > "%~dp0TMP\RegionID.txt" & set /P regionID=<"%~dp0TMP\RegionID.txt"
	 REM A = Asia
	 if "!regionID!"=="A" "%~dp0BAT\busybox" sed -ie "s/A/A/g" "%~dp0TMP\RegionID.txt" & set /P REGIONTMP=<"%~dp0TMP\RegionID.txt"
	 REM C = China                                                                                                  
     if "!regionID!"=="C" "%~dp0BAT\busybox" sed -ie "s/C/C/g" "%~dp0TMP\RegionID.txt" & set /P REGIONTMP=<"%~dp0TMP\RegionID.txt"
	 REM E = Europe                                                                                                 
	 if "!regionID!"=="E" "%~dp0BAT\busybox" sed -ie "s/E/E/g" "%~dp0TMP\RegionID.txt" & set /P REGIONTMP=<"%~dp0TMP\RegionID.txt"
	 REM K = Korean                                                                                                 
	 if "!regionID!"=="K" "%~dp0BAT\busybox" sed -ie "s/K/K/g" "%~dp0TMP\RegionID.txt" & set /P REGIONTMP=<"%~dp0TMP\RegionID.txt"
	 REM P = Japan                                                                                                  
	 if "!regionID!"=="P" "%~dp0BAT\busybox" sed -ie "s/P/J/g" "%~dp0TMP\RegionID.txt" & set /P REGIONTMP=<"%~dp0TMP\RegionID.txt"
	 REM UC = North America                                                                                         
	 if "!regionID!"=="U" "%~dp0BAT\busybox" sed -ie "s/U/U/g" "%~dp0TMP\RegionID.txt" & set /P REGIONTMP=<"%~dp0TMP\RegionID.txt"
	 )
	 REM Unknown region
	 if not defined REGIONTMP set REGIONTMP=X
	 if defined LSPID set REGIONTMP=U
	 
     REM This is only to fix illegal characters with busybox
     echo "!dbtitleTMP!"| "%~dp0BAT\busybox" sed -e "s/\&/\\\&/g; s./.\\\/.g" | "%~dp0BAT\busybox" iconv -f windows-1252 -t utf-8 > "%~dp0TMP\dbtitle.txt"
	 "%~dp0BAT\busybox" sed -i "s/\"//g" "%~dp0TMP\dbtitle.txt"
	 set /P dbtitle=<"%~dp0TMP\dbtitle.txt"
	 
     echo "!RELEASETMP!"| "%~dp0BAT\busybox" sed -e "s/\&/\\\&/g; s./.\\\/.g" | "%~dp0BAT\busybox" iconv -f windows-1252 -t utf-8 > "%~dp0TMP\RELEASE.txt"
	 "%~dp0BAT\busybox" sed -i "s/\"//g" "%~dp0TMP\RELEASE.txt"
	 set /P RELEASE=<"%~dp0TMP\RELEASE.txt"
	 
	 echo "!REGIONTMP!"| "%~dp0BAT\busybox" sed -e "s/\&/\\\&/g; s./.\\\/.g" | "%~dp0BAT\busybox" iconv -f windows-1252 -t utf-8 > "%~dp0TMP\REGION.txt"
	 "%~dp0BAT\busybox" sed -i "s/\"//g" "%~dp0TMP\REGION.txt"
	 set /P REGION=<"%~dp0TMP\REGION.txt"
	 
     echo "!DEVELOPERTMP!"| "%~dp0BAT\busybox" sed -e "s/\&/\\\&/g; s./.\\\/.g" | "%~dp0BAT\busybox" iconv -f windows-1252 -t utf-8 > "%~dp0TMP\DEVELOPER.txt"
	 "%~dp0BAT\busybox" sed -i "s/\"//g" "%~dp0TMP\DEVELOPER.txt"
	 set /P DEVELOPER=<"%~dp0TMP\DEVELOPER.txt"
	
     echo "!PUBLISHERTMP!"| "%~dp0BAT\busybox" sed -e "s/\&/\\\&/g; s./.\\\/.g" | "%~dp0BAT\busybox" iconv -f windows-1252 -t utf-8 > "%~dp0TMP\PUBLISHER.txt"
	 "%~dp0BAT\busybox" sed -i "s/\"//g" "%~dp0TMP\PUBLISHER.txt"
	 set /P PUBLISHER=<"%~dp0TMP\PUBLISHER.txt"
	 
     echo "!GENRETMP!"| "%~dp0BAT\busybox" sed -e "s/\&/\\\&/g; s./.\\\/.g" | "%~dp0BAT\busybox" iconv -f windows-1252 -t utf-8 > "%~dp0TMP\GENRE.txt"
	 "%~dp0BAT\busybox" sed -i "s/\"//g" "%~dp0TMP\GENRE.txt"
	 set /P GENRE=<"%~dp0TMP\GENRE.txt"
    
	if defined selectlang call "%~dp0BAT\Translation_words.bat"
	
    echo         Getting game information...
    echo        Provided by psxdatacenter.com
"%~dp0BAT\Diagbox" gd 0e
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03

	echo Title:     [!dbtitleTMP!]
	echo Gameid:    [!gameid2!]
	echo Region:    [!REGION!]
	echo Release:   [!RELEASETMP!]
	echo Developer: [!DEVELOPERTMP!]
	echo Publisher: [!PUBLISHERTMP!]
	echo Genre:     [!GENRETMP!]
if !PartitionType!==APP echo Source:    [!Contentweb!]

"%~dp0BAT\Diagbox" gd 0e
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0f

     "%~dp0BAT\hdl_dump_fix_header" dump_header !@hdl_path! "!PPName!" >nul 2>&1
	 echo !PPName!| "%~dp0BAT\busybox" sed -e "s/__\./PP\./g" > "%~dp0TMP\PPBBNXMB.txt" & set /P PPName=<"%~dp0TMP\PPBBNXMB.txt"
	 REM "%~dp0BAT\hdl_dump_fix_header" modify_header !@hdl_path! "!PPName!" >nul 2>&1
	 
	 cd /d "%~dp0TMP"
     echo            Extraction Resources Header...
	 echo device !@pfsshell_path! > "%~dp0TMP\pfs-log.txt"
	 echo mount "!PPName!" >> "%~dp0TMP\pfs-log.txt"
	 echo cd res >> "%~dp0TMP\pfs-log.txt"
	 echo ls -l >> "%~dp0TMP\pfs-log.txt"
	 echo umount >> "%~dp0TMP\pfs-log.txt"
	 echo exit >> "%~dp0TMP\pfs-log.txt"
	 type "%~dp0TMP\pfs-log.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" grep -i -e "-rw-" -e "-rwx" | "%~dp0BAT\busybox" cut -c42-500 > "%~dp0TMP\pfs-tmp.log"
	 
	 echo device !@pfsshell_path! > "%~dp0TMP\pfs-log.txt"
	 echo mount "!PPName!" >> "%~dp0TMP\pfs-log.txt"
	 echo mkdir res >> "%~dp0TMP\pfs-log.txt"
	 echo cd res >> "%~dp0TMP\pfs-log.txt"
	 echo mkdir image >> "%~dp0TMP\pfs-log.txt"
	 echo cd image >> "%~dp0TMP\pfs-log.txt"
	 echo ls -l >> "%~dp0TMP\pfs-log.txt"
	 echo umount >> "%~dp0TMP\pfs-log.txt"
	 echo exit >> "%~dp0TMP\pfs-log.txt"
	 type "%~dp0TMP\pfs-log.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" grep -i -e "-rw-" -e "-rwx" | "%~dp0BAT\busybox" cut -c42-500 > "%~dp0TMP\pfs-tmp2.log"
	 
	 echo device !@pfsshell_path! > "%~dp0TMP\pfs-header.txt"
	 echo mount "!PPName!" >> "%~dp0TMP\pfs-header.txt"
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

     if !UpdateTitle!==Yes (
	 echo            Updating Title...
	 
	 REM HDD-OSD Infos
	 "%~dp0BAT\busybox" sed -i -e "s/ = /=/g; s/=/ = /g; s/  =/ = /g" "%~dp0TMP\!gameid2!\PP.HEADER\icon.sys"
	 if defined dbtitle "%~dp0BAT\busybox" sed -i -e "s/title0 =.*/title0 =/g; s/title0 =/title0 = !dbtitle!/g" "%~dp0TMP\!gameid2!\PP.HEADER\icon.sys"
 	 if defined dbtitle "%~dp0BAT\busybox" sed -i -e "s/title1 =.*/title1 =/g; s/title1 =/title1 = !gameid2!/g" "%~dp0TMP\!gameid2!\PP.HEADER\icon.sys"
	 if !showtype!==Game if !language!==french "%~dp0BAT\busybox" sed -i -e "s/uninstallmes0 =.*/uninstallmes0 =/g; s/uninstallmes0 =/uninstallmes0 = Cela supprimera le jeu\./g" "%~dp0TMP\!gameid2!\PP.HEADER\icon.sys"
	 
	 if !PartitionType!==APP "%~dp0BAT\busybox" sed -ie "s/title1 =.*/title1 =/g; s/title1 =/title1 = !GENRE!/g" "%~dp0TMP\!gameid2!\PP.HEADER\icon.sys"
	 "%~dp0BAT\busybox" sed -i -e "s/\s*$//" "%~dp0TMP\!gameid2!\PP.HEADER\icon.sys"
	 
	 if exist "%~dp0TMP\!gameid2!\PP.HEADER\PFS\res\info.sys" (
	 REM PSBBN, XMB Menu Infos
	 if defined dbtitle "%~dp0BAT\busybox" sed -i -e "s/title =.*/title =/g; s/title =/title = !dbtitle!/g" "%~dp0TMP\!gameid2!\PP.HEADER\PFS\res\info.sys"
	 if defined dbtitle "%~dp0BAT\busybox" sed -i -e "s/\"TOP-TITLE\" label=\".*\"/\"TOP-TITLE\" label=\"!dbtitle!\"/g" "%~dp0TMP\!gameid2!\PP.HEADER\PFS\res\man.xml"
	 )
	)

     if !Update3DIcon!==Yes (
	 echo            Updating 3D Icon...
	 if !DownloadARTHDDOSD!==yes "%~dp0BAT\wget" -q "https://archive.org/download/hdd-osd-icons-pack/HDD-OSD-Icons-Pack.zip/!PartitionType!%%2F!gameid!%%2Ficon.sys" -O "%~dp0TMP\icon.sys" >nul
	 if !DownloadARTHDDOSD!==yes "%~dp0BAT\wget" -q "https://archive.org/download/hdd-osd-icons-pack/HDD-OSD-Icons-Pack.zip/!PartitionType!%%2F!gameid!%%2Flist.ico" -O "%~dp0TMP\list.ico" >nul
	 if !DownloadARTHDDOSD!==yes "%~dp0BAT\wget" -q "https://archive.org/download/hdd-osd-icons-pack/HDD-OSD-Icons-Pack.zip/!PartitionType!%%2F!gameid!%%2Fdel.ico"  -O "%~dp0TMP\del.ico" >nul
	 if !uselocalARTHDDOSD!==yes if exist "%~dp0HDD-OSD-Icons-Pack.zip" "%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0HDD-OSD-Icons-Pack.zip" -o"%~dp0TMP" !PartitionType!\!gameid!\ -r -y >nul 2>&1 & move "%~dp0TMP\!PartitionType!\!gameid!\*" "%~dp0TMP" >nul 2>&1
	 
	 if not exist "%~dp0TMP\del.ico" copy "%~dp0TMP\list.ico" "%~dp0TMP\del.ico" >nul 2>&1 
	 for %%F in (*.ico) do if %%~zF==0 (del "%%F") else (move %%F "%~dp0TMP\!gameid2!\PP.HEADER" >nul)

	 REM Update Background Color for HDD-OSD icon
	 for %%F in (*.sys) do if %%~zF==0 (del "%%F"
	 ) else (
	 "%~dp0BAT\busybox" grep -A 11 "bgcola" "%~dp0TMP\icon.sys" | "%~dp0BAT\busybox" sed "s/ = /=/g; s/=/ = /g" > "%~dp0TMP\!gameid2!\BGCOLOR.txt"
	 "%~dp0BAT\busybox" sed -i "4,15d" "%~dp0TMP\!gameid2!\PP.HEADER\icon.sys"
	 "%~dp0BAT\busybox" cat "%~dp0TMP\!gameid2!\BGCOLOR.txt" >> "%~dp0TMP\!gameid2!\PP.HEADER\icon.sys"
	 "%~dp0BAT\busybox" sed -i "4,6{H;d;}; 18{G;s/\n//;}" "%~dp0TMP\!gameid2!\PP.HEADER\icon.sys"
	 del "%~dp0TMP\icon.sys" >nul
	  )
	)

     if !UpdateGameInfos!==Yes (
	 echo            Updating Game Infos...
	 
	 REM PSBBN Original Date format
	 if defined RELEASE echo !RELEASE!| "%~dp0BAT\busybox" sed -E "s/January/01/g; s/February/02/g; s/March/03/g; s/April/04/g; s/May/05/g; s/June/06/g; s/July/07/g; s/August/08/g; s/September/09/g; s/October/10/g; s/November/11/g; s/December/12/g" > "%~dp0TMP\RELEASEBBN.txt" & "%~dp0BAT\busybox" sed -i "s/^\([1-9]\) /0\1 /g; s/ //g; s/\(.\{2\}\)\(.\{2\}\)\(.\{4\}\)/\3\2\1/" "%~dp0TMP\RELEASEBBN.txt" & set /P RELEASEBBN=<"%~dp0TMP\RELEASEBBN.txt"
	 
	 if exist "%~dp0TMP\!gameid2!\PP.HEADER\PFS\res\info.sys" (
	 "%~dp0BAT\busybox" sed -i -e "s/title_id =.*/title_id =/g; s/title_id =/title_id = !gameid2!/g" "%~dp0TMP\!gameid2!\PP.HEADER\PFS\res\info.sys"
     "%~dp0BAT\busybox" sed -i -e "s/area =.*/area =/g; s/area =/area = !REGION!/g" "%~dp0TMP\!gameid2!\PP.HEADER\PFS\res\info.sys"
     if defined RELEASE "%~dp0BAT\busybox" sed -i -e "s/release_date =.*/release_date =/g; s/release_date =/release_date = !RELEASEBBN!/g" "%~dp0TMP\!gameid2!\PP.HEADER\PFS\res\info.sys"
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
	 md "%~dp0TMP\res\image" >nul 2>&1
	 if !DownloadART!==yes "%~dp0BAT\wget" -q --show-progress "https://archive.org/download/hdd-osd-icons-pack/HDD-OSD-Icons-Pack.zip/!PartitionType!%%2F!gameid!%%2Fres%%2Fjkt_001.png" -O "%~dp0TMP\res\jkt_001.png" >nul 2>&1 & copy "%~dp0TMP\res\jkt_001.png" "%~dp0TMP\res\jkt_002.png" >nul 2>&1
	 if !uselocalART!==yes if exist "%~dp0HDD-OSD-Icons-Pack.zip" "%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0HDD-OSD-Icons-Pack.zip" -o"%~dp0TMP" !PartitionType!\!gameid!\res\jkt_001.png -r -y & move "%~dp0TMP\!PartitionType!\!gameid!\res\jkt_001.png" "%~dp0TMP\res\jkt_001.png" >nul 2>&1 & copy "%~dp0TMP\res\jkt_001.png" "%~dp0TMP\res\jkt_002.png" >nul 2>&1
	 if !DownloadART!==yes "%~dp0BAT\wget" -q --show-progress "https://archive.org/download/hdd-osd-icons-pack/HDD-OSD-Icons-Pack.zip/!PartitionType!%%2F!gameid!%%2Fres%%2Fimage%%2F0.png" -O "%~dp0TMP\res\image\0.png" >nul 2>&1
	 if !uselocalART!==yes if exist "%~dp0HDD-OSD-Icons-Pack.zip" "%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0HDD-OSD-Icons-Pack.zip" -o"%~dp0TMP" !PartitionType!\!gameid!\res\image\0.png -r -y & move "%~dp0TMP\!PartitionType!\!gameid!\res\image\0.png" "%~dp0TMP\res\image\0.png" >nul 2>&1
	 if !DownloadART!==yes "%~dp0BAT\wget" -q --show-progress "https://archive.org/download/hdd-osd-icons-pack/HDD-OSD-Icons-Pack.zip/!PartitionType!%%2F!gameid!%%2Fres%%2Fimage%%2F1.png" -O "%~dp0TMP\res\image\1.png" >nul 2>&1
	 if !uselocalART!==yes if exist "%~dp0HDD-OSD-Icons-Pack.zip" "%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0HDD-OSD-Icons-Pack.zip" -o"%~dp0TMP" !PartitionType!\!gameid!\res\image\1.png -r -y & move "%~dp0TMP\!PartitionType!\!gameid!\res\image\1.png" "%~dp0TMP\res\image\1.png" >nul 2>&1
	 if !DownloadART!==yes "%~dp0BAT\wget" -q --show-progress "https://archive.org/download/hdd-osd-icons-pack/HDD-OSD-Icons-Pack.zip/!PartitionType!%%2F!gameid!%%2Fres%%2Fimage%%2F2.png" -O "%~dp0TMP\res\image\2.png" >nul 2>&1
	 if !uselocalART!==yes if exist "%~dp0HDD-OSD-Icons-Pack.zip" "%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0HDD-OSD-Icons-Pack.zip" -o"%~dp0TMP" !PartitionType!\!gameid!\res\image\2.png -r -y & move "%~dp0TMP\!PartitionType!\!gameid!\res\image\2.png" "%~dp0TMP\res\image\2.png" >nul 2>&1
	 for /r "%~dp0TMP\res" %%F in (*.png) do if %%~zF==0 del "%%F"
	 ) else (
	 
     if !DownloadART!==yes "%~dp0BAT\wget" -q --show-progress "https://archive.org/download/OPLM_ART_2023_11/OPLM_ART_2023_11.zip/!PartitionType!%%2F!gameid!%%2F!gameid!_COV.jpg" -O "%~dp0TMP\jkt_001.jpg" >nul 2>&1
     if !uselocalART!==yes if exist "%~dp0ART.zip" "%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0ART.zip" -o"%~dp0TMP" !PartitionType!\!gameid!\!gameid!_COV.jpg -r -y & move "%~dp0TMP\!PartitionType!\!gameid!\!gameid!_COV.jpg" "%~dp0TMP\jkt_001.jpg" >nul 2>&1
	 if !DownloadART!==yes "%~dp0BAT\wget" -q --show-progress "https://archive.org/download/OPLM_ART_2023_11/OPLM_ART_2023_11.zip/!PartitionType!%%2F!gameid!%%2F!gameid!_BG_00.jpg" -O "%~dp0TMP\BG.jpg" >nul 2>&1
	 if !uselocalART!==yes if exist "%~dp0ART.zip" "%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0ART.zip" -o"%~dp0TMP" !PartitionType!\!gameid!\!gameid!_BG_00.jpg -r -y & move "%~dp0TMP\!PartitionType!\!gameid!\!gameid!_BG_00.jpg" "%~dp0TMP\BG.jpg" >nul 2>&1
	 if !DownloadART!==yes "%~dp0BAT\wget" -q --show-progress "https://archive.org/download/OPLM_ART_2023_11/OPLM_ART_2023_11.zip/!PartitionType!%%2F!gameid!%%2F!gameid!_LGO.png" -O "%~dp0TMP\jkt_cp.png" >nul 2>&1
	 if !uselocalART!==yes if exist "%~dp0ART.zip" "%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0ART.zip" -o"%~dp0TMP" !PartitionType!\!gameid!\!gameid!_LGO.png -r -y & move "%~dp0TMP\!PartitionType!\!gameid!\!gameid!_LGO.png" "%~dp0TMP\jkt_cp.png" >nul 2>&1
	 if !DownloadART!==yes "%~dp0BAT\wget" -q --show-progress "https://archive.org/download/OPLM_ART_2023_11/OPLM_ART_2023_11.zip/!PartitionType!%%2F!gameid!%%2F!gameid!_SCR_00.jpg" -O "%~dp0TMP\SCR0.jpg" >nul 2>&1
	 if !uselocalART!==yes if exist "%~dp0ART.zip" "%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0ART.zip" -o"%~dp0TMP" !PartitionType!\!gameid!\!gameid!_SCR_00.jpg -r -y & move "%~dp0TMP\!PartitionType!\!gameid!\!gameid!_SCR_00.jpg" "%~dp0TMP\SCR0.jpg" >nul 2>&1
	 if !DownloadART!==yes "%~dp0BAT\wget" -q --show-progress "https://archive.org/download/OPLM_ART_2023_11/OPLM_ART_2023_11.zip/!PartitionType!%%2F!gameid!%%2F!gameid!_SCR_01.jpg" -O "%~dp0TMP\SCR1.jpg" >nul 2>&1
	 if !uselocalART!==yes if exist "%~dp0ART.zip" "%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0ART.zip" -o"%~dp0TMP" !PartitionType!\!gameid!\!gameid!_SCR_01.jpg -r -y & move "%~dp0TMP\!PartitionType!\!gameid!\!gameid!_SCR_01.jpg" "%~dp0TMP\SCR1.jpg" >nul 2>&1
	 REM "%~dp0BAT\wget" -q --show-progress "https://archive.org/download/OPLM_ART_2023_11/OPLM_ART_2023_11.zip/PS1%%2F%%F%%2F%%F_SCR_02.jpg" -O "%~dp0TMP\SCR2.jpg" >nul 2>&1
	 REM "%~dp0BAT\wget" -q --show-progress "https://archive.org/download/OPLM_ART_2023_11/OPLM_ART_2023_11.zip/PS1%%2F%%F%%2F%%F_SCR_03.jpg" -O "%~dp0TMP\SCR3.jpg" >nul 2>&1
	 )
	 
	 REM ART CUSTOM GAMEID
	 "%~dp0BAT\7-Zip\7z" e -bso0 "%~dp0BAT\ART_CUSTOM_GAMEID.zip" -o"%~dp0TMP\!PartitionType!\!gameid!" PS1\!gameid!_COV.jpg -r -y >nul 2>&1 & move "%~dp0TMP\!PartitionType!\!gameid!\!gameid!_COV.jpg" "%~dp0TMP\jkt_001.jpg" >nul 2>&1
	 for %%F in (*.jpg *.png) do if %%~zF==0 del "%%F"

	 REM Covers
	 if exist "%~dp0TMP\jkt_001.jpg" "%~dp0BAT\nconvert" -overwrite -out png -resize 256 256 -rtype lanczos -efocus -o "%~dp0TMP\res\jkt_001.png" "%~dp0TMP\jkt_001.jpg" >nul 2>&1
	 if exist "%~dp0TMP\jkt_001.jpg" "%~dp0BAT\nconvert" -overwrite -out png -resize 76 108 -rtype lanczos -efocus -o "%~dp0TMP\res\jkt_002.png" "%~dp0TMP\jkt_001.jpg" >nul 2>&1
	 if exist "%~dp0TMP\jkt_cp.png" move "%~dp0TMP\jkt_cp.png" "%~dp0TMP\!gameid2!\PP.HEADER\PFS\res\jkt_cp.png" >nul 2>&1
	 
	 REM Screenshot
	 if exist "%~dp0TMP\BG.jpg" "%~dp0BAT\nconvert" -overwrite -out png -resize 640 350 -efocus -o "%~dp0TMP\res\image\0.png" "%~dp0TMP\BG.jpg" >nul 2>&1
     if exist "%~dp0TMP\SCR0.jpg" "%~dp0BAT\nconvert" -overwrite -out png -resize 640 350 -rtype lanczos -efocus -o "%~dp0TMP\res\image\1.png" "%~dp0TMP\SCR0.jpg" >nul 2>&1
	 if exist "%~dp0TMP\SCR1.jpg" "%~dp0BAT\nconvert" -overwrite -out png -resize 640 350 -rtype lanczos -efocus -o "%~dp0TMP\res\image\2.png" "%~dp0TMP\SCR1.jpg" >nul 2>&1
	 REM if exist "%~dp0TMP\SCR2.jpg" "%~dp0BAT\nconvert" -overwrite -out png -resize 640 350 -rtype lanczos -efocus -o "%~dp0POPS\Temp\!appfolder!\res\image\3.png" "%~dp0TMP\SCR2.jpg" >nul 2>&1
	 REM if exist "%~dp0TMP\SCR3.jpg" "%~dp0BAT\nconvert" -overwrite -out png -resize 640 350 -rtype lanczos -efocus -o "%~dp0POPS\Temp\!appfolder!\res\image\4.png" "%~dp0TMP\SCR3.jpg" >nul 2>&1

	 REM Nconvert does not support long path
	 ROBOCOPY /E /MOVE "%~dp0TMP\res" "%~dp0TMP\!gameid2!\PP.HEADER\PFS\res" >nul 2>&1
     for %%f in (*.jpg *.png) do (del "%%f")
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
	 echo mount "!PPName!" >> "%~dp0TMP\pfs-updateheader.txt"
	 echo lcd "%~dp0TMP\!gameid2!\PP.HEADER\PFS" >> "%~dp0TMP\pfs-updateheader.txt"
	 if !UpdateLauncher!==Yes echo rm EXECUTE.KELF >> "%~dp0TMP\pfs-updateheader.txt"
	 if !UpdateLauncher!==Yes echo put EXECUTE.KELF >> "%~dp0TMP\pfs-updateheader.txt"
	 echo lcd "%~dp0TMP\!gameid2!\PP.HEADER\PFS\res" >> "%~dp0TMP\pfs-updateheader.txt"
	 echo mkdir res >> "%~dp0TMP\pfs-updateheader.txt"
	 echo cd res >> "%~dp0TMP\pfs-updateheader.txt"
     
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
	 
	 REM if !HugoPatchesFix!==Yes (
	 REM echo !PPName!| "%~dp0BAT\busybox" sed "s/PP\.//g" > "%~dp0TMP\PPNameVMC.txt" & set /P PPNameVMC=<"%~dp0TMP\PPNameVMC.txt" 
	 REM "%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0POPS-Binaries\Hugopocked_POPStarter_Fixes.zip" -o"%~dp0TMP" id.txt -r -y
	 REM 
	 REM REM REM echo         Checking if the game has a need patch GameShark...
	 REM REM findstr !VCDID! "%~dp0TMP\id.txt" >nul 2>&1
     REM REM if errorlevel 1 (
     REM REM REM echo         No need patch
     REM REM ) else (
	 REM REM REM echo         Patch GameShark...
	 REM REM "%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0POPS-Binaries\Hugopocked_POPStarter_Fixes.zip" -o"%~dp0TMP" !VCDID!\* -r -y >nul 2>&1
	 REM REM "%~dp0BAT\busybox" md5sum "!fname!.VCD" | "%~dp0BAT\busybox" grep -o "[0-9a-f]\{32\}" > "%~dp0TMP\MD5.txt" & set /p MD5=<"%~dp0TMP\MD5.txt"
	 REM REM "%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0POPS-Binaries\Hugopocked_POPStarter_Fixes.zip" -o"%~dp0TMP" !VCDID!\!MD5!\* -r -y & move "%~dp0TMP\!VCDID!\!MD5!\*" "%~dp0TMP\!VCDID!" >nul 2>&1
	 REM REM cd /d "%~dp0TMP\!VCDID!" & for %%x in (TROJAN_?.BIN PATCH_?.BIN CHEATS.TXT Readme.txt) do move "%%x" "%~dp0POPS" >nul 2>&1
	 REM REM )
	 REM 
	 REM echo lcd .. >> "%~dp0TMP\pfs-updateheader.txt"
	 REM echo cd .. >> "%~dp0TMP\pfs-updateheader.txt"
	 REM echo umount >> "%~dp0TMP\pfs-updateheader.txt"
	 REM echo mount __common >> "%~dp0TMP\pfs-updateheader.txt"
	 REM echo mkdir fdp >> "%~dp0TMP\pfs-updateheader.txt"
	 REM echo cd POPS >> "%~dp0TMP\pfs-updateheader.txt"
	 REM echo cd "!PPNameVMC!" >> "%~dp0TMP\pfs-updateheader.txt"
	 REM echo mkdir fdp >> "%~dp0TMP\pfs-updateheader.txt"
	 REM 
	 REM echo !PPNameVMC!
	 REM )
	
	 REM UNMOUNT
	 echo umount >> "%~dp0TMP\pfs-updateheader.txt"
	 echo exit >> "%~dp0TMP\pfs-updateheader.txt"
	 type "%~dp0TMP\pfs-updateheader.txt" | "%~dp0BAT\pfsshell" >nul 2>&1
	 
	 cd /d "%~dp0TMP\!gameid2!\PP.HEADER" & "%~dp0BAT\hdl_dump" modify_header !@hdl_path! "!PPName!" >nul 2>&1
	 echo !PPName!| "%~dp0BAT\busybox" sed -e "s/PP\./__\./g" > "%~dp0TMP\PPBBNXMB.txt" & set /P PPName=<"%~dp0TMP\PPBBNXMB.txt"
	 cd /d "%~dp0TMP\!gameid2!\PP.HEADER" & "%~dp0BAT\hdl_dump" modify_header !@hdl_path! "!PPName!" >nul 2>&1
	 
	 cd /d "%~dp0TMP" & rmdir /Q/S "!gameid2!" >nul 2>&1
	 del "%~dp0TMP\REGION.txt" >nul 2>&1
     del "%~dp0TMP\DEVELOPER.txt" >nul 2>&1
     del "%~dp0TMP\PUBLISHER.txt" >nul 2>&1
     del "%~dp0TMP\GENRE.txt" >nul 2>&1
	 del "%~dp0TMP\icon.sys" >nul 2>&1
	 del "%~dp0TMP\!gameid2!.html" >nul 2>&1
	 
	 echo            Completed...	 
     )
    )

cd /d "%~dp0" & rmdir /Q/S "%~dp0TMP" >nul 2>&1

chcp 1252 >nul 2>&1
echo\
"%~dp0BAT\Diagbox" gd 0f
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo Completed...
echo\
echo\
"%~dp0BAT\Diagbox" gd 0f

pause & (goto HDDOSDPartManagement)
REM ####################################################################################################################
:CreatePS1ShortcutsAPPTAB
cls
mkdir "%~dp0TMP" >nul 2>&1
cd /d "%~dp0TMP"

IF NOT DEFINED @hdl_path ( rmdir /Q/S "%~dp0TMP" >nul 2>&1 & goto ScanningPS2HDD ) else (
"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning for Playstation 2 HDDs:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "!@hdl_path!" | "%~dp0BAT\busybox" grep "Playstation 2 HDD" >nul
if errorlevel 1 set "@hdl_path=" & goto ScanningPS2HDD
echo       [!@hdl_path! !@TotalHDD_Size! - !@ModelePS2HDD!]
)

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Create shortcuts PS1 Games for OPL APPS TAB:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1^) Yes
"%~dp0BAT\Diagbox" gd 0c
echo         2^) No
"%~dp0BAT\Diagbox" gd 0e
echo         3^) Yes (Manually Choose your Game)
echo\
"%~dp0BAT\Diagbox" gd 07
CHOICE /C 123 /M "Select Option:"

IF %ERRORLEVEL%==1 set @pfs_pop=yes & set "choice="
IF %ERRORLEVEL%==2 (goto GamesManagement)
IF %ERRORLEVEL%==3 set @pfs_pop=Manually & set "choice="

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Change default +OPL partition?
echo ----------------------------------------------------
echo\
echo Choose the partition where you want to transfer the files
echo By default it will be the partition: +OPL
echo\
CHOICE /C YN /M "Change the default partition?:"

IF %ERRORLEVEL%==1 set CHOICEPP=yes
IF %ERRORLEVEL%==2 set OPLPART=+OPL

if defined CHOICEPP (
echo\
echo 1. [+OPL]
echo 2. [__common]
echo 3. Select partition manually
echo\
CHOICE /C 123 /M "Select Option:"

IF ERRORLEVEL 1 set OPLPART=+OPL
IF ERRORLEVEL 2 set CHOICEPART=yes & set OPLPART=__common
IF ERRORLEVEL 3 ( set CHOICEPART=yes
echo\
set "OPLPART="
set /p OPLPART="Enter the partition name:"
IF "!OPLPART!"=="" set OPLPART=+OPL
 )
)

"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Detecting POPS Partition:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0f

    "%~dp0BAT\busybox" grep -o "__.POPS\|__.POPS[0-9]" "%~dp0BAT\__Cache\PARTITION_PS2HDD.txt" | "%~dp0BAT\busybox" sed "s/__.POPS\([0-9]\)/\1.  __.POPS\1/g; s/\__.POPS\b/10. __.POPS/" | "%~dp0BAT\busybox" sort -k2 > "%~dp0TMP\hdd-prt.txt"
    "%~dp0BAT\busybox" sed -e "/^$/d" "%~dp0TMP\hdd-prt.txt" | "%~dp0BAT\busybox" wc -l > "%~dp0TMP\TotalPOPSPart.txt" & set /P @TotalPOPSPart=<"%~dp0TMP\TotalPOPSPart.txt"
    
    if !@TotalPOPSPart! gtr 1 (
	echo.
    echo Multiple POPS partitions were detected. Please choose one.
	echo Choose the partition on which you want to analyze your VCDs
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
	echo        Partition Must Be Formatted Or Created
	echo\
	echo\
	"%~dp0BAT\Diagbox" gd 07
	rmdir /Q/S "%~dp0TMP" >nul 2>&1
	pause & (goto GamesManagement)
	)
	
"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Detecting !OPLPART! Partition:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0f

    "%~dp0BAT\busybox" grep -ow "!OPLPART!" "%~dp0BAT\__Cache\PARTITION_PS2HDD.txt" > "%~dp0TMP\hdd-prt.txt"
	
	set /P @hdd_avl=<"%~dp0TMP\hdd-prt.txt"
	IF "!@hdd_avl!"=="!OPLPART!" (
	"%~dp0BAT\Diagbox" gd 0a
		echo            !OPLPART! - Partition Detected
	"%~dp0BAT\Diagbox" gd 0f
		) else (
		"%~dp0BAT\Diagbox" gd 0c
		echo         !OPLPART! - Partition NOT Detected
		echo         Partition Must Be Formatted Or Created
		echo\
		echo\
		rmdir /Q/S "%~dp0TMP" >nul 2>&1
		pause & (goto GamesManagement)
		)

echo\
echo\
pause
cls

"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning Games List in !POPSPART!:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0f

	echo device !@pfsshell_path! > "%~dp0TMP\pfs-pops.txt"
	echo mount !POPSPART! >> "%~dp0TMP\pfs-pops.txt"
	echo ls >> "%~dp0TMP\pfs-pops.txt"
	echo umount >> "%~dp0TMP\pfs-pops.txt"
    echo exit >> "%~dp0TMP\pfs-pops.txt"
	type "%~dp0TMP\pfs-pops.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" grep -ie ".*\.VCD$" | "%~dp0BAT\busybox" sed -e "s/\.[^.]*$//" > "%~dp0TMP\!POPSPART!.txt"
    type "%~dp0TMP\!POPSPART!.txt"

"%~dp0BAT\Diagbox" gd 0e
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0f
echo\

if %@pfs_pop%==Manually (
echo\
"%~dp0BAT\Diagbox" gd 06
echo Respect upper and lower case
"%~dp0BAT\Diagbox" gd 07
set /p NameVCD=Enter The Game Name:
IF "!NameVCD!"=="" set "@pfs_pop=" & (goto GamesManagement)

"%~dp0BAT\busybox" grep -ow "!NameVCD!" "%~dp0TMP\!POPSPART!.txt" > "%~dp0TMP\PPIDChecking.txt" & set /P GameCheck=<"%~dp0TMP\PPIDChecking.txt"
if "!GameCheck!"=="!NameVCD!" (
"%~dp0BAT\Diagbox" gd 0a
echo !NameVCD!> "%~dp0TMP\!POPSPART!.txt"
"%~dp0BAT\Diagbox" gd 07
) else (
"%~dp0BAT\Diagbox" gd 0c
echo            Game with this name not exists
echo       Please verify that you have not made any mistakes.
echo\
echo\
"%~dp0BAT\Diagbox" gd 07
rmdir /Q/S "%~dp0TMP" >nul 2>&1
pause & (goto GamesManagement)
 )
)

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
IF !ERRORLEVEL!==2 (
echo\
set /p "prefix=Enter your prefix:"
)
IF !ERRORLEVEL!==3 set "prefix="

echo\
echo Example: !Prefix!Crash Bandicoot
echo Confirm^?
CHOICE /C YN
IF !ERRORLEVEL!==2 goto CreatePS1ShortcutsAPPTAB
)

setlocal DisableDelayedExpansion
"%~dp0BAT\Diagbox" gd 07
cls
echo\
echo\
if %@pfs_pop%==Manually echo Create Shortcuts "%NameVCD%":
if %@pfs_pop%==yes echo Create PS1 Games Shortcuts
echo ----------------------------------------------------
echo\
    
	echo         Creating Que
    for /f "tokens=*" %%p in (%POPSPART%.txt) do (
    set fname=%%p
    setlocal EnableDelayedExpansion

	md "%~dp0TMP\VCDShort\!fname!" >nul 2>&1
	copy "%~dp0POPS-Binaries\POPSTARTER.ELF" "%~dp0TMP\VCDShort\!fname!\!fname!.ELF" >nul 2>&1
	echo "title=!prefix!!fname!"| "%~dp0BAT\busybox" iconv -f windows-1252 -t utf-8 > "%~dp0TMP\VCDShort\!fname!\title.cfg"
    echo "boot=!fname!.ELF"| "%~dp0BAT\busybox" iconv -f windows-1252 -t utf-8 >> "%~dp0TMP\VCDShort\!fname!\title.cfg"
	"%~dp0BAT\busybox" sed -i "s/\"//g" "%~dp0TMP\VCDShort\!fname!\title.cfg"
	endlocal
	)
	
	echo         Installing...
	cd /d "%~dp0TMP\VCDShort"
	
	echo device %@pfsshell_path% > "%~dp0TMP\pfs-pops.txt"
	echo mount %OPLPART% >> "%~dp0TMP\pfs-pops.txt"
    
	REM PARENT DIR (OPL\APPS)
    if defined CHOICEPART echo mkdir OPL >> "%~dp0TMP\pfs-pops.txt"
    if defined CHOICEPART echo cd OPL >> "%~dp0TMP\pfs-pops.txt"
	echo mkdir APPS >> "%~dp0TMP\pfs-pops.txt"
	echo cd APPS >> "%~dp0TMP\pfs-pops.txt"

	REM APPS DIR (OPL\APPS\APP)
	for /D %%x in (*) do (
	echo mkdir "%%x" >> "%~dp0TMP\pfs-pops.txt"
	echo lcd "%%x" >> "%~dp0TMP\pfs-pops.txt"
 	echo cd "%%x" >> "%~dp0TMP\pfs-pops.txt"
 	cd "%%x"
	
	REM APPS DIR (OPL\APPS\APP\files.xxx)
 	for %%0 in (*) do (echo put "%%0") >> "%~dp0TMP\pfs-pops.txt"
	
	echo lcd .. >> "%~dp0TMP\pfs-pops.txt"
	echo cd .. >> "%~dp0TMP\pfs-pops.txt"
	cd ..
	)
	
	echo umount >> "%~dp0TMP\pfs-pops.txt"
	echo exit >> "%~dp0TMP\pfs-pops.txt"
	type "%~dp0TMP\pfs-pops.txt" | "%~dp0BAT\pfsshell" >nul 2>&1
	echo         Completed...
 
cd "%~dp0" & rmdir /Q/S "%~dp0TMP" >nul 2>&1

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo Installation Completed...
echo\
echo\
"%~dp0BAT\Diagbox" gd 07

endlocal
pause & (goto GamesManagement)
REM ####################################################################################################################
:UpdatePartAPPS
cls
mkdir "%~dp0TMP" >nul 2>&1

IF NOT DEFINED @hdl_path ( rmdir /Q/S "%~dp0TMP" >nul 2>&1 & goto ScanningPS2HDD ) else (
"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning for Playstation 2 HDDs:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "!@hdl_path!" | "%~dp0BAT\busybox" grep "Playstation 2 HDD" >nul
if errorlevel 1 set "@hdl_path=" & goto ScanningPS2HDD
echo       [!@hdl_path! !@TotalHDD_Size! - !@ModelePS2HDD!]
)

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Update APPS:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1^) Yes
"%~dp0BAT\Diagbox" gd 0c
echo         2^) No
"%~dp0BAT\Diagbox" gd 0e
echo         3^) Yes (Update Only OPL which is present in OPL partition for HDD-OSD, PSBBN, XMB)
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
   echo ----------------------------------------------------
   "%~dp0BAT\busybox" grep -e "APPS-" "%~dp0BAT\__Cache\PARTITION_PS2HDD.txt" | "%~dp0BAT\busybox" cut -c30-250 > "%~dp0TMP\hdd-prt.txt"
   "%~dp0BAT\busybox" grep -o "APPS-[0-9][0-9][0-9][0-9][0-9]" "%~dp0TMP\hdd-prt.txt" | "%~dp0BAT\busybox" sed "s/-/_/g; s/.\{8\}/&./g" > "%~dp0TMP\APPIDTMP.txt"
   type "%~dp0TMP\hdd-prt.txt"
   echo ----------------------------------------------------
   )
   
   echo\
   echo\
   echo Do you want to update OPL which is present in OPL partition
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
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "!@hdl_path!" | "%~dp0BAT\busybox" grep "Playstation 2 HDD" >nul
if errorlevel 1 set "@hdl_path=" & goto ScanningPS2HDD
echo       [!@hdl_path! !@TotalHDD_Size! - !@ModelePS2HDD!]
)

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Fix FreeHDBoot OSD Graphical Corruption
echo ----------------------------------------------------
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
echo ----------------------------------------------------
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
    echo ----------------------------------------------------
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
echo ----------------------------------------------------
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
echo ----------------------------------------------------
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
:RenameVCDDB

REM Sorry if you looking shity code :D

mkdir "%~dp0TMP" >nul 2>&1
copy "%~dp0BAT\TitlesDB\TitlesDB_PS1_English.txt" "%~dp0TMP\gameid.txt" >nul 2>&1

IF /I EXIST "%~dp0POPS\*.VCD" (
if not defined usedbtitleconv (
cls
echo\ 
echo\
"%~dp0BAT\Diagbox" gd 0e
echo Do you want rename your .VCDs from database?
"%~dp0BAT\Diagbox" gd 0f
choice /c YN /m "Use titles from database?"
echo\
if errorlevel 2 (goto GamesManagement)
)

"%~dp0BAT\Diagbox" gd 0e
echo Do you want use a prefix?
"%~dp0BAT\Diagbox" gd 0f
echo With prefix: SCES_009.84.Gran Turismo.VCD
echo Without prefix: Gran Turismo.VCD
echo\
choice /c YN /m "Use Prefix ?"
echo\
if errorlevel 1 set usegameiddb=yes
if errorlevel 2 set usegameiddb=no

echo -----------------------------------------------------
cd /d "%~dp0POPS"

setlocal DisableDelayedExpansion
"%~dp0BAT\busybox" sed -i "s/\^!/\!/g" "%~dp0TMP\gameid.txt" >nul 2>&1

For %%P in ( "*.VCD" ) do ( "%~dp0BAT\POPS-VCD-ID-Extractor" "%%P" > VCDID.txt 2>&1 & "%~dp0BAT\busybox" sed -i -e "s/-/_/g" VCDID.txt

set "ELFNOTFOUND="
"%~dp0BAT\busybox" grep -o -m 1 "regex couldn't find" VCDID.txt > ELFNOTFOUND.TXT & set /p ELFNOTFOUND=<ELFNOTFOUND.TXT
if defined ELFNOTFOUND (
"%~dp0BAT\busybox" grep -o -m 1 "SLPS-02414" "%%P" | "%~dp0BAT\busybox" sed "s/-/_/g" | "%~dp0BAT\busybox" sed "s/.\{8\}/&./" | "%~dp0BAT\busybox" head -1 >> VCDID.txt & "%~dp0BAT\busybox" sed -i "/regex couldn't find/d" VCDID.txt
"%~dp0BAT\busybox" grep -o -m 1 "SLUSP013.46" "%%P" | "%~dp0BAT\busybox" sed "s/-/_/g; s/SLUSP013\.46/SLUS_01346/g" | "%~dp0BAT\busybox" sed "s/.\{8\}/&./" | "%~dp0BAT\busybox" head -1 >> VCDID.txt & "%~dp0BAT\busybox" sed -i "/regex couldn't find/d" VCDID.txt
)

set "filename=%%P"
set "fname=%%~nP"

"%~dp0BAT\busybox" grep -ow "[0-9][0-9][0-9][0-9][0-9].[0-9][0-9][0-9]" VCDID.txt > LSPVCDID.txt
for /f %%x in (LSPVCDID.txt) do (set LSPID=%%x& "%~dp0BAT\busybox" sed -i -e "s/%%x/LSP%%x/g" VCDID.txt)

for /f %%i in (VCDID.txt) do (
set gameid=%%i

set "dbtitle="
for /f "tokens=1*" %%A in ( 'findstr %%i "%~dp0TMP\gameid.txt" ' ) do ( if not defined dbtitle set dbtitle=%%B

  )
 )

setlocal EnableDelayedExpansion
del "%~dp0POPS\ELFNOTFOUND.TXT"
del "%~dp0POPS\VCDID.txt" >nul 2>&1
del "%~dp0POPS\VCDID.txt" >nul 2>&1
del "%~dp0POPS\LSPVCDID.txt" >nul 2>&1

       REM Fix Conflict Games. Rare games that have the same ID
	   set rootpath=%~dp0
	   set GameInstall=PS1
	   findstr !gameid! "%~dp0BAT\Fix_Conflict_Gameid_Title.bat" >nul 2>&1
       if errorlevel 1 (echo >NUL) else (call "%~dp0BAT\Fix_Conflict_Gameid_Title.bat") 
	   
if !MD5!==e727685a14959bc599e290befa511351 set "dbtitle=Breath of Fire IV (E3 Demo)" & set gameid=SLPS_027.28
if !MD5!==e84810d0f4db6e6658ee4208eb9f5415 set "dbtitle=Bust A Move (Disc 1) (Genteiban)" & set gameid=SLPS_012.32
if !MD5!==29c642b78b68cfff9a47fac51dd6d3c2 set "dbtitle=1Xtreme" & set gameid=SCUS_945.03
if !MD5!==c9395ccb9bb59e9cea9170bf44bd5578 set "dbtitle=ESPN Extreme Games" & set gameid=SCUS_945.03
if !MD5!==ee9fc1cd31d1e2adf6230ffb8db64e0e set "dbtitle=Jet Moto 2 - Championship Edition" & set gameid=SCUS_941.67
if !MD5!==6c88d7b7f085257caba543c99cc37d1c set "dbtitle=Metal Gear Solid (Disc 1) (Demo)" & set gameid=SLUS_005.94
if !MD5!==a86a49cd948c4f9c5063fbc360459764 set "dbtitle=PlayStation Underground Number 1 (Disc 2)" & set gameid=SCUS_941.61
if !MD5!==31f7e4d4fd01718e0602cf2d795ca797 set "dbtitle=The Lost World - Jurassic Park - Special Edition" & set gameid=SLUS_005.15

if !usegameiddb!==yes (
findstr !gameid! "%~dp0TMP\gameid.txt" >nul
if errorlevel 1 (
"%~dp0BAT\Diagbox" gd 0c
echo !gameid! "!filename!" : TITLE NOT FOUND IN DATABASE
"%~dp0BAT\Diagbox" gd 07
) else (
echo !gameid!.!dbtitle!

md temp >nul 2>&1
if exist "temp\!gameid!.!dbtitle!.VCD" (

"%~dp0BAT\Diagbox" gd 06
echo "!filename!" Has the same name as another
"%~dp0BAT\Diagbox" gd 07
cd ..

 ) else (
move "!filename!" "temp\!gameid!.!dbtitle!.VCD" >nul 2>&1
if defined device ren "!fname!" "!gameid!.!dbtitle!" >nul 2>&1
   )
 )

) else (

findstr !gameid! "%~dp0TMP\gameid.txt" >nul
if errorlevel 1 (
"%~dp0BAT\Diagbox" gd 0c
echo !gameid! "!filename!" : TITLE NOT FOUND IN DATABASE
"%~dp0BAT\Diagbox" gd 07
) else (
echo !dbtitle!

md temp >nul 2>&1
if exist "temp\!dbtitle!.VCD" (

"%~dp0BAT\Diagbox" gd 06
echo "!filename!" Has the same name as another
"%~dp0BAT\Diagbox" gd 07
cd ..

 ) else (
move "!filename!" "temp\!dbtitle!.VCD" >nul 2>&1
if defined device ren "!fname!" "!dbtitle!" >nul 2>&1
   )
  )
 )
endlocal
   )
  ) else ( 
"%~dp0BAT\Diagbox" gd 06
cls
echo.
echo .VCD NOT DETECTED: Please drop .VCD IN POPS FOLDER.
echo.
"%~dp0BAT\Diagbox" gd 0f
pause & (goto GamesManagement)
)

move "%~dp0POPS\temp\*.VCD" "%~dp0POPS" >nul 2>&1

rmdir /s /q temp >nul 2>&1
echo\
endlocal
pause & if defined usedbtitleconv (goto ConversionMenu) else (goto GamesManagement)

REM ####################################################################################################################################################
:BIN2VCD

cls
mkdir "%~dp0TMP" >nul 2>&1
cd /d "%~dp0POPS"

IF /I EXIST "%~dp0POPS\*.cue" (
mkdir "%~dp0POPS\Temp" >nul 2>&1
mkdir "%~dp0POPS\Original" >nul 2>&1

for %%f in (*.cue) do (

	setlocal DisableDelayedExpansion
	set filename=%%f
    set fname=%%~nf
    setlocal EnableDelayedExpansion

echo "!filename!"
"%~dp0BAT\binmerge" "!filename!" "Temp/!fname!" | findstr "Merging ERROR"
echo\
move "!fname!.bin" "%~dp0POPS\Original" >nul 2>&1
move "!fname! (Track *).bin" "%~dp0POPS\Original" >nul 2>&1
move "!fname!.cue" "%~dp0POPS\Original" >nul 2>&1

"%~dp0BAT\busybox" sed -i "s/Temp\///g" "%~dp0POPS\temp\!fname!.cue"
move "%~dp0POPS\temp\!fname!.bin" "%~dp0POPS" >nul 2>&1
move "%~dp0POPS\!fname!.cue" "%~dp0POPS\Temp" >nul 2>&1

	endlocal
endlocal
)

if exist "%~dp0POPS-Binaries\Hugopocked_POPStarter_Fixes.zip" (

echo -----------------------------------------------------
echo\

echo Apply HugoPocked's patches If available?
"%~dp0BAT\Diagbox" gd 0e
echo Patches are intended to fix games that don't work with POPStarter [Yes recommended]
CHOICE /C YN /M "Select Option:"
if errorlevel 1 set patchVCD=yes
if errorlevel 2 set patchVCD=no & move "%~dp0POPS\*.bin" "%~dp0POPS\Temp" >nul 2>&1
"%~dp0BAT\Diagbox" gd 0f
)

if not exist "%~dp0POPS-Binaries\Hugopocked_POPStarter_Fixes.zip" set patchVCD=no

if !patchVCD!==yes (

   "%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0POPS-Binaries\Hugopocked_POPStarter_Fixes.zip" -o"%~dp0TMP" id.txt -r -y
   
   setlocal DisableDelayedExpansion
   for %%# in (*.bin) do (
   if not exist "Temp/%%~n#" md "Temp/%%~n#"
   move "%%#" "Temp/%%~n#" >nul 2>&1
   )
   
   cd /d "%~dp0POPS\temp" & for /f "delims=" %%a in ('dir /ad /b') do (
   setlocal DisableDelayedExpansion
   set appfolder=%%a
   set "filename="
   set "BINID="
   cd /d "%~dp0POPS\temp\%%a" & for %%V in (*.bin) do set filename=%%~nV
   setlocal EnableDelayedExpansion
   
   "%~dp0BAT\busybox" grep -o -m 1 "[A-Z][A-Z][A-Z][A-Z][_-][0-9][0-9][0-9].[0-9][0-9]" "!filename!.bin" | "%~dp0BAT\busybox" sed "s/-/_/g" | "%~dp0BAT\busybox" head -1 > "%~dp0POPS\Temp\!appfolder!\BINID.txt" & set /p BINID=<"%~dp0POPS\Temp\!appfolder!\BINID.txt"
   if not defined BINID ( 
   "%~dp0BAT\busybox" grep -o -m 1 "SLPS-02414" "!filename!.bin" | "%~dp0BAT\busybox" sed "s/-/_/g" | "%~dp0BAT\busybox" sed "s/.\{8\}/&./" | "%~dp0BAT\busybox" head -1 > "%~dp0POPS\Temp\!appfolder!\BINID.txt" & set /p BINID=<"%~dp0POPS\Temp\!appfolder!\BINID.txt"
   "%~dp0BAT\busybox" grep -o -m 1 "SLUSP013.46" "!filename!.bin" | "%~dp0BAT\busybox" sed "s/-/_/g; s/SLUSP013\.46/SLUS_01346/g" | "%~dp0BAT\busybox" sed "s/.\{8\}/&./" | "%~dp0BAT\busybox" head -1 >> "%~dp0POPS\Temp\!appfolder!\BINID.txt" & set /p BINID=<"%~dp0POPS\Temp\!appfolder!\BINID.txt"
   )
   
   findstr !BINID! "%~dp0TMP\id.txt" >nul 2>&1
   if errorlevel 1 (
   echo\
   echo "!filename!.bin"
   echo "!BINID!"
   "%~dp0BAT\Diagbox" gd 06
   echo No patch available for this game
   "%~dp0BAT\Diagbox" gd 0f
   move "!filename!.bin" "%~dp0POPS" >nul 2>&1
   ) else (
   
   cd /d "%~dp0POPS\temp\!appfolder!"
   echo\
   echo Search Patch...
   echo "!filename!.bin"
   echo "!BINID!"
   
   "%~dp0BAT\busybox" md5sum "!filename!.bin" | "%~dp0BAT\busybox" grep -o "[0-9a-f]\{32\}" > MD5.txt & set /p MD5=<"%~dp0POPS\Temp\!appfolder!\MD5.txt" 
   "%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0POPS-Binaries\Hugopocked_POPStarter_Fixes.zip" -o"Patch\" "!BINID!\!MD5!\*" -r -y & move "%~dp0POPS\Temp\!appfolder!\Patch\!BINID!\!MD5!\*.xdelta" "%~dp0POPS\Temp\!appfolder!\Patch.xdelta" >nul 2>&1
   
   REM echo !MD5!
   
   if exist *.xdelta (
   echo Applying the patch.. 
   "%~dp0BAT\xdelta3-3.1.0-x86_64" -d -s "!filename!.bin" "Patch.xdelta" "!filename!".PATCHED
   
   if exist "!filename!".PATCHED (
   "%~dp0BAT\Diagbox" gd 0a
   echo Done
   move "!filename!".PATCHED "%~dp0POPS\Temp\!filename!.bin" >nul 2>&1
   del "!filename!.bin" >nul 2>&1 & move "Patch" "%~dp0TMP" >nul 2>&1 & rmdir /s /q "%~dp0TMP\Patch" >nul 2>&1
   "%~dp0BAT\Diagbox" gd 0f
   
   ) else (
   "%~dp0BAT\Diagbox" gd 0c
   echo An error has occurred
   "%~dp0BAT\Diagbox" gd 0f
   )
   
   ) else (
   "%~dp0BAT\Diagbox" gd 0e
   echo No .xdelta patch found or compatible with your version of your game
   echo Maybe a GameSharks patch could be available when transferring PS1 games
   echo\
   move "!filename!.bin" "%~dp0POPS\Temp" >nul 2>&1
   "%~dp0BAT\Diagbox" gd 0f
    )	
   )
 endlocal
endlocal
  )
)

move "%~dp0POPS\*.bin" "%~dp0POPS\Temp" >nul 2>&1
setlocal DisableDelayedExpansion
echo\
echo -----------------------------------------------------
echo\
echo Convert to VCD... 
for %%f in ( "%~dp0POPS\Temp\*.cue" ) do (
    
	setlocal DisableDelayedExpansion
	set filename=%%f
    set fname=%%~nf
    setlocal EnableDelayedExpansion

"%~dp0BAT\CUE2POPS_2_3" "!filename!" | echo "!fname!.VCD"
move "%~dp0POPS\Temp\!fname!.VCD" "%~dp0POPS" >nul 2>&1
 endlocal
endlocal
)

setlocal EnableDelayedExpansion
if !patchVCD!==yes (
    echo\
	echo\
    echo What device will you be using?
	echo 1 = HDD ^(Internal^)
	echo 2 = USB
    CHOICE /C 12 /M "Select Option:"
    if errorlevel 1 set device=HDD
    if errorlevel 2 set device=USB
    "%~dp0BAT\Diagbox" gd 0f
    setlocal DisableDelayedExpansion
	
    for %%f in ( "%~dp0POPS\*.VCD" ) do (

	setlocal DisableDelayedExpansion
	set filename=%%f
    set fname=%%~nf
    setlocal EnableDelayedExpansion

	if !device!==USB (
	md "%~dp0POPS\!fname!"
	"%~dp0BAT\POPS-VCD-ID-Extractor" "!filename!" 2>&1 | "%~dp0BAT\busybox" sed -e "s/-/_/g" > "%~dp0TMP\VCDID.txt" & set /p VCDID=<"%~dp0TMP\VCDID.txt"
	
	set "ELFNOTFOUND="
    "%~dp0BAT\busybox" grep -o -m 1 "regex couldn't find" "%~dp0TMP\VCDID.txt" > ELFNOTFOUND.TXT & set /p ELFNOTFOUND=<ELFNOTFOUND.TXT
    if defined ELFNOTFOUND (
	"%~dp0BAT\busybox" grep -o -m 1 "SLPS-02414" "!filename!" | "%~dp0BAT\busybox" sed "s/-/_/g" | "%~dp0BAT\busybox" sed "s/.\{8\}/&./" | "%~dp0BAT\busybox" head -1 >> "%~dp0TMP\VCDID.txt" & "%~dp0BAT\busybox" sed -i "/regex couldn't find/d" "%~dp0TMP\VCDID.txt" & set /p VCDID=<"%~dp0TMP\VCDID.txt"
	"%~dp0BAT\busybox" grep -o -m 1 "SLUSP013.46" "!filename!" | "%~dp0BAT\busybox" sed "s/-/_/g; s/SLUSP013\.46/SLUS_01346/g" | "%~dp0BAT\busybox" sed "s/.\{8\}/&./" | "%~dp0BAT\busybox" head -1 >> "%~dp0TMP\VCDID.txt" & "%~dp0BAT\busybox" sed -i "/regex couldn't find/d" "%~dp0TMP\VCDID.txt" & set /p VCDID=<"%~dp0TMP\VCDID.txt"
	)
	
	REM echo         Checking if the game has a need patch GameShark...
	findstr !VCDID! "%~dp0TMP\id.txt" >nul 2>&1
    if errorlevel 1 (
    REM echo         No need patch
    ) else (
	REM echo         Patch GameShark...
	"%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0POPS-Binaries\Hugopocked_POPStarter_Fixes.zip" -o"%~dp0TMP" !VCDID!\* -r -y & move "%~dp0TMP\!VCDID!\*" "%~dp0POPS\!fname!" >nul 2>&1
	"%~dp0BAT\busybox" md5sum "%~dp0POPS\!fname!.VCD" | "%~dp0BAT\busybox" grep -o "[0-9a-f]\{32\}" > "%~dp0TMP\MD5.txt" & set /p MD5=<"%~dp0TMP\MD5.txt"
	"%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0POPS-Binaries\Hugopocked_POPStarter_Fixes.zip" -o"%~dp0TMP" !VCDID!\!MD5!\* -r -y & move "%~dp0TMP\!VCDID!\!MD5!\*" "%~dp0POPS\!fname!" >nul 2>&1 & del "%~dp0POPS\!fname!\*.xdelta" >nul 2>&1
	 )
	)
    endlocal
   endlocal
  )
 )
) else (
"%~dp0BAT\Diagbox" gd 06
echo.
echo .BIN/CUE NOT DETECTED: Please drop .BIN/CUE IN POPS FOLDER.
echo.
"%~dp0BAT\Diagbox" gd 0f
pause & (goto ConversionMenu)
)

cd /d "%~dp0" & rmdir /s /q "%~dp0POPS\Temp" >nul 2>&1

echo -----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0e
echo\
echo Do you want rename your .VCDs from database?
"%~dp0BAT\Diagbox" gd 0f
choice /c YN /m "Use titles from database?"
echo\
if %errorlevel%==1 set usedbtitleconv=yes & goto RenameVCDDB

endlocal
endlocal
"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo Completed...
echo\
echo\
"%~dp0BAT\Diagbox" gd 07

cd /d "%~dp0" & rmdir /s /q "%~dp0TMP" >nul 2>&1

pause & (goto ConversionMenu)

REM ####################################################################################################################################################
:VCD2BIN

cls
mkdir "%~dp0TMP" >nul 2>&1
cd /d "%~dp0POPS"

IF /I EXIST "%~dp0POPS\*.VCD" (
mkdir "%~dp0POPS\Original" >nul 2>&1

for %%f in (*.VCD) do (

	setlocal DisableDelayedExpansion
	set filename=%%f
    set fname=%%~nf
    setlocal EnableDelayedExpansion

echo\
echo "!filename!"
"%~dp0BAT\POPS2CUE" "!filename!" | findstr "Done Error"

move "!filename!" "%~dp0POPS\Original" >nul 2>&1

REM Move BIN/CUE in FOLDER
md "!fname!" >nul 2>&1
move "!fname!.bin" "!fname!" >nul 2>&1
move "!fname!.cue" "!fname!" >nul 2>&1

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
pause & (goto ConversionMenu)
)

cd /d "%~dp0" & rmdir /s /q "%~dp0POPS\Temp" >nul 2>&1

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo Completed...
echo\
echo\
"%~dp0BAT\Diagbox" gd 07

pause & (goto ConversionMenu)

REM ##########################################################################################################################################################
:multibin2bin

cls
mkdir "%~dp0TMP" >nul 2>&1
cd /d "%~dp0POPS"

IF /I EXIST "%~dp0POPS\*.cue" (
mkdir "%~dp0POPS\Temp" >nul 2>&1
mkdir "%~dp0POPS\Original" >nul 2>&1

for %%f in (*.cue) do (

	setlocal DisableDelayedExpansion
	set filename=%%f
    set fname=%%~nf
    setlocal EnableDelayedExpansion

echo "!filename!"
"%~dp0BAT\binmerge" "!filename!" "Temp/!fname!" | findstr "Merging ERROR"
echo\
move "!fname!.bin" "%~dp0POPS\Original" >nul 2>&1
move "!fname! (Track *).bin" "%~dp0POPS\Original" >nul 2>&1
move "!fname!.cue" "%~dp0POPS\Original" >nul 2>&1

"%~dp0BAT\busybox" sed -i "s/Temp\///g" "%~dp0POPS\temp\!fname!.cue"
move "%~dp0POPS\temp\!fname!.bin" "%~dp0POPS" >nul 2>&1
move "%~dp0POPS\temp\!fname!.cue" "%~dp0POPS" >nul 2>&1

	endlocal
endlocal
)

) else (
"%~dp0BAT\Diagbox" gd 06
cls
echo.
echo .BIN NOT DETECTED: Please drop .BIN IN POPS FOLDER.
echo.
"%~dp0BAT\Diagbox" gd 0f
pause & (goto ConversionMenu)
)

cd /d "%~dp0" & rmdir /s /q "%~dp0POPS\Temp" >nul 2>&1

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo Completed...
echo\
echo\
"%~dp0BAT\Diagbox" gd 07

pause & (goto ConversionMenu)

REM ##########################################################################################################################################################
:CHDConv

cls
mkdir "%~dp0TMP" >nul 2>&1
cd /d "%~dp0POPS"

"%~dp0BAT\Diagbox" gd 0f
echo\
echo 1. Compress BIN TO CHD
echo 2. Decompress CHD TO BIN
echo 3. Back
echo\
CHOICE /C 123 /M "Select Option:"

if %errorlevel%==1 set "choice=createcd" & set "type=.cue" & set type2=.chd
if %errorlevel%==2 set "choice=extractcd" & set "type=.chd" & set type2=.cue
if %errorlevel%==3 (goto ConversionMenu)

IF /I EXIST "%~dp0POPS\*!type!" (
mkdir "%~dp0POPS\Original" >nul 2>&1

for %%f in (*!type!) do (

	setlocal DisableDelayedExpansion
	set filename=%%f
    set fname=%%~nf
    setlocal EnableDelayedExpansion

"%~dp0BAT\chdman.exe" !choice! -i "!filename!" -o "!fname!!type2!"
if !choice!==createcd (
move "!fname! (Track *).bin" "%~dp0POPS\Original" >nul 2>&1
move "!fname!.bin" "%~dp0POPS\Original" >nul 2>&1
move "!fname!.cue" "%~dp0POPS\Original" >nul 2>&1
)
if !choice!==extractcd (move "!fname!.chd" "%~dp0POPS\Original" >nul 2>&1)

	endlocal
endlocal
)

) else (
"%~dp0BAT\Diagbox" gd 06
cls
echo.
echo !type! NOT DETECTED: Please drop !type! IN POPS FOLDER.
echo.
"%~dp0BAT\Diagbox" gd 0f
pause & (goto ConversionMenu)
)

cd /d "%~dp0" & rmdir /s /q "%~dp0POPS\Temp" >nul 2>&1

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo Completed...
echo\
echo\
"%~dp0BAT\Diagbox" gd 07

pause & (goto ConversionMenu)

REM #########################################################################################################################################################
:ECMConv

cls
mkdir "%~dp0TMP" >nul 2>&1
cd /d "%~dp0POPS"

"%~dp0BAT\Diagbox" gd 0f
echo\
echo 1. Compress BIN TO ECM
echo 2. Decompress ECM TO BIN
echo 3. Back
echo\
CHOICE /C 123 /M "Select Option:"

if %errorlevel%==1 set "choice=ecm" & set "type=.bin" & set type2=.ecm
if %errorlevel%==2 set "choice=unecm" & set "type=.ecm" & set type2=.bin
if %errorlevel%==3 (goto ConversionMenu)

IF /I EXIST "%~dp0POPS\*!type!" (
mkdir "%~dp0POPS\Original" >nul 2>&1
mkdir "%~dp0POPS\Temp" >nul 2>&1

for %%f in (*!type!) do (

	setlocal DisableDelayedExpansion
	set filename=%%f
    set fname=%%~nf
    setlocal EnableDelayedExpansion

move "!fname!!type!" Temp >nul 2>&1
move "!fname!.cue" Temp >nul 2>&1

cd /d "%~dp0POPS\Temp"
echo\
echo "!filename!"
"%~dp0BAT\!choice!.exe" "!filename!" "!fname!!type2!"

if !choice!==unecm (
if not exist "!fname!.cue" call "%~dp0BAT\cuemaker.bat"
move "!filename!" "%~dp0POPS\Original" >nul 2>&1
move "*.bin" "%~dp0POPS" >nul 2>&1
move "*.cue" "%~dp0POPS" >nul 2>&1
)

if !choice!==ecm (
move "*.ecm" "%~dp0POPS" >nul 2>&1
move "*.cue" "%~dp0POPS" >nul 2>&1
)

cd /d "%~dp0POPS"

	endlocal
endlocal
)

) else (
"%~dp0BAT\Diagbox" gd 06
cls
echo.
echo .ECM NOT DETECTED: Please drop .ECM IN POPS FOLDER.
echo.
"%~dp0BAT\Diagbox" gd 0f
pause & (goto ConversionMenu)
)

cd /d "%~dp0" & rmdir /s /q "%~dp0POPS\Temp" >nul 2>&1

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo Completed...
echo\
echo\
"%~dp0BAT\Diagbox" gd 07

pause & (goto ConversionMenu)

REM ##########################################################################################################################################################
:bin2split

cls
mkdir "%~dp0TMP" >nul 2>&1
cd /d "%~dp0POPS"

IF /I EXIST "%~dp0POPS\*.cue" (
mkdir "%~dp0POPS\Temp" >nul 2>&1
mkdir "%~dp0POPS\Original" >nul 2>&1

for %%f in (*.cue) do (

	setlocal DisableDelayedExpansion
	set filename=%%f
    set fname=%%~nf
    setlocal EnableDelayedExpansion

echo "!filename!"
"%~dp0BAT\binmerge" -s "!filename!" "temp\!fname!" | findstr "Merging ERROR"
echo\
move "!fname!.bin" "%~dp0POPS\Original" >nul 2>&1
move "!fname!.cue" "%~dp0POPS\Original" >nul 2>&1

"%~dp0BAT\busybox" sed -i "s/temp\\//g" "%~dp0POPS\temp\!fname!.cue"
move "%~dp0POPS\temp\!fname!.bin" "%~dp0POPS" >nul 2>&1
move "%~dp0POPS\temp\!fname! (Track *).bin" "%~dp0POPS" >nul 2>&1
move "%~dp0POPS\temp\!fname!.cue" "%~dp0POPS" >nul 2>&1

	endlocal
endlocal
)

) else (
"%~dp0BAT\Diagbox" gd 06
cls
echo.
echo .CUE NOT DETECTED: Please drop .CUE IN POPS FOLDER.
echo.
"%~dp0BAT\Diagbox" gd 0f
pause & (goto ConversionMenu)
)

cd /d "%~dp0" & rmdir /s /q "%~dp0POPS\Temp" >nul 2>&1

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo Completed...
echo\
echo\
"%~dp0BAT\Diagbox" gd 07

pause & (goto ConversionMenu)

REM ###########################################################################################################################################################
:BIN2ISO

cls
mkdir "%~dp0TMP" >nul 2>&1
cd /d "%~dp0CD"

IF /I EXIST "%~dp0CD\*.bin" (
mkdir "%~dp0CD\Original" >nul 2>&1

for %%f in (*.bin) do (

	setlocal DisableDelayedExpansion
	set filename=%%f
    set fname=%%~nf
    setlocal EnableDelayedExpansion

echo\
echo "!filename!"
echo Converting... .BIN To .ISO
"%~dp0BAT\bchunk" "!fname!.bin" "!fname!.cue" "!fname!" >nul 2>&1 
move "!fname!01.iso" "!fname!.iso" >nul 2>&1

move "!fname!.bin" "%~dp0CD\Original" >nul 2>&1
move "!fname!.cue" "%~dp0CD\Original" >nul 2>&1
 endlocal
endlocal
)

) else (
"%~dp0BAT\Diagbox" gd 06
cls
echo.
echo .BIN/CUE NOT DETECTED: Please drop .BIN/CUE IN CD FOLDER.
echo.
"%~dp0BAT\Diagbox" gd 0f
pause & (goto ConversionMenu)
)

cd /d "%~dp0"

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo Completed...
echo\
echo\
"%~dp0BAT\Diagbox" gd 07

pause & (goto ConversionMenu)
REM ###########################################################################################################################################################
:ZSOConv
cls
mkdir "%~dp0TMP" >nul 2>&1
cd /d "%~dp0DVD"

"%~dp0BAT\Diagbox" gd 0f
echo\
echo 1. Compress ISO TO ZSO
echo 2. Decompress ZSO TO ISO
echo 3. Back
echo\
CHOICE /C 123 /M "Select Option:"
if !errorlevel!==1 set "compress=yes" & set "type=.iso" & set "type2=.zso"
if !errorlevel!==2 set "decompress=yes" & set "type=.zso" & set type2=.iso
if !errorlevel!==3 (goto ConversionMenu)

if !compress!==yes (
echo\
echo 1. Normal Compression
echo 2. Max Compression LZ4 HC
echo\
CHOICE /C 12 /M "Select Option:"
if !errorlevel!==1 set "LZ4HC="
if !errorlevel!==2 set "LZ4HC=--use-lz4brute"
)

REM if %errorlevel%==1 set "choice=9" & set "type=.iso" & set type2=.zso
REM if %errorlevel%==2 set "choice=0" & set "type=.zso" & set type2=.iso

IF /I EXIST "%~dp0DVD\*!type!" (
for %%f in (*!type!) do (

	setlocal DisableDelayedExpansion
	set filename=%%f
    set fname=%%~nf
    setlocal EnableDelayedExpansion

echo\
echo\
echo %%f
REM "%~dp0BAT\ziso" -c %choice% "%%f" "%%~nf%type2%" | findstr "Error Total block index compress levelCompress"
if defined compress "%~dp0BAT\maxcso" !LZ4HC! --block=2048 --format=zso "!filename!" -o "!fname!!type2!"
if defined decompress "%~dp0BAT\maxcso" --decompress "!filename!" -o "!fname!!type2!"
cd /d "%~dp0DVD"

	endlocal
endlocal
)
 
) else (
"%~dp0BAT\Diagbox" gd 06
cls
echo.
echo !type! NOT DETECTED: Please drop !type! IN DVD FOLDER.
echo.
"%~dp0BAT\Diagbox" gd 0f
pause & (goto ConversionMenu)
)

cd /d "%~dp0" & rmdir /s /q "%~dp0POPS\Temp" >nul 2>&1

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo Completed...
echo\
echo\
"%~dp0BAT\Diagbox" gd 07

pause & (goto ConversionMenu)
REM ########################################################################################################################################
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
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "!@hdl_path!" | "%~dp0BAT\busybox" grep "Playstation 2 HDD" >nul
if errorlevel 1 set "@hdl_path=" & goto ScanningPS2HDD
echo       [!@hdl_path! !@TotalHDD_Size! - !@ModelePS2HDD!]
)

   "%~dp0BAT\Diagbox" gd 0f
   echo\
   echo\
   echo Scanning Partitions:
   echo ----------------------------------------------------
   "%~dp0BAT\busybox" grep -e "0x0100" -e "0x0001" "%~dp0BAT\__Cache\PARTITION_PS2HDD.txt"
   echo ----------------------------------------------------
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
   wmic logicaldisk get caption | "%~dp0BAT\busybox" grep -o "[A-Z]:" | "%~dp0BAT\busybox" grep -o "[A-Z]" > "%~dp0TMP\LTR.txt"
   "C:\Program Files\Dokan\!DokanFolder!\dokanctl.exe" /l a >nul 2>&1 | "%~dp0BAT\busybox" grep -o "DosDevices\\[A-Z]:" | "%~dp0BAT\busybox" cut -c12-12 >> "%~dp0TMP\LTR.txt"
   
   echo ABCDEFGHIJKLMNOPQRSTUVWXYZ> "%~dp0TMP\LTRFree.txt"
   for /f "usebackq tokens=*" %%a in ("%~dp0TMP\LTR.txt") do "%~dp0BAT\busybox" sed -i "s/%%a//g" "%~dp0TMP\LTRFree.txt"
   "%~dp0BAT\busybox" cut -c0-1 "%~dp0TMP\LTRFree.txt" > "%~dp0TMP\LTRSelected.txt" & set /P DeviceLTR=<"%~dp0TMP\LTRSelected.txt"
   
   START /MIN CMD.EXE /C ""%~dp0BAT\pfsfuse" "--partition=!PartName!" !@pfsshell_path! !DeviceLTR! -o "volname=!PartName!""

   :loopdrive
   wmic logicaldisk get deviceid^,drivetype | "%~dp0BAT\busybox" grep -o "!DeviceLTR!:"> "%~dp0TMP\WINDOWLTR.TXT" & set /P WINDOWLTR=<"%~dp0TMP\WINDOWLTR.txt"
   if "!WINDOWLTR!"=="!DeviceLTR!:" start !DeviceLTR!:\ & goto exitloopdrive
   goto loopdrive
   :exitloopdrive
   
   "%~dp0BAT\Diagbox" gd 0e
   echo Umount Partition?
   choice /c YN

   if !errorlevel!==1 (
   "%~dp0BAT\Diagbox" gd 0f
   echo\
   "C:\Program Files\Dokan\!DokanFolder!\dokanctl.exe" /u !DeviceLTR! | "%~dp0BAT\busybox" grep -o "Unmount status = 0" > "%~dp0TMP\UnmountPart.txt" & set /P UnmountPart=<"%~dp0TMP\UnmountPart.txt"
   if "!UnmountPart!"=="Unmount status = 0" echo Unmount success
   ) else (
   "%~dp0BAT\Diagbox" gd 06
   echo\
   echo IMPORTANT: Don't forget to umount partition before disconnecting your HDD
   echo\
   "%~dp0BAT\Diagbox" gd 0f
   pause & goto PS2HDDExplore
   )

echo\
echo\
pause & goto PS2HDDExplore
REM #########################################################################################################
:DokanUmountDoManuallyPartition

if defined DokanUmountDoManuallyPartition (
   if exist "C:\Program Files\Dokan" (
   
   "C:\Program Files\Dokan\!DokanFolder!\dokanctl.exe" /l a | "%~dp0BAT\busybox" grep -o "DosDevices\\[A-Z]:" | "%~dp0BAT\busybox" cut -c12-12 > "%~dp0TMP\Listmount.txt"
   for /f "usebackq tokens=*" %%m in ("%~dp0TMP\Listmount.txt") do (
   echo\ & "C:\Program Files\Dokan\!DokanFolder!\dokanctl.exe" /u %%m | "%~dp0BAT\busybox" grep -o "Unmount status = 0" > "%~dp0TMP\UnmountPart.txt" & set /P UnmountPart=<"%~dp0TMP\UnmountPart.txt"
   "%~dp0BAT\Diagbox" gd 0f
   if "!UnmountPart!"=="Unmount status = 0" echo Unmount success 
     )
    ) else (goto InstallDokanDriver)
   )

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
   wmic product get name,IdentifyingNumber | "%~dp0BAT\busybox" grep "Dokan Library" | "%~dp0BAT\busybox" grep -o "[A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9]-[A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9]-[A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9]-[A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9]-[A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9]" > "%~dp0TMP\DokanProgUID.txt"
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