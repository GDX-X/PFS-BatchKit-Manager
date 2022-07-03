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
REM * Especially for illegal characters and accents                                        *
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
IF NOT EXIST "%~dp0LOG\"  MD "%~dp0LOG"
IF NOT EXIST "%~dp0POPS\" MD "%~dp0POPS"
IF NOT EXIST "%~dp0THM\"  MD "%~dp0THM"
IF NOT EXIST "%~dp0VMC\"  MD "%~dp0VMC"

IF NOT EXIST "%~dp0POPS\VMC" MD "%~dp0POPS\VMC"
IF NOT EXIST "%~dp0POPS-Binaries\" MD "%~dp0POPS-Binaries\"
IF NOT EXIST "%~dp0HDD-OSD\__sysconf" MD "%~dp0HDD-OSD\__sysconf"
IF NOT EXIST "%~dp0HDD-OSD\__system" MD "%~dp0HDD-OSD\__system"
IF NOT EXIST "%~dp0HDD-OSD\PP.HEADER" MD "%~dp0HDD-OSD\PP.HEADER\res\image"

IF NOT EXIST "%~dp0TMP"  MD "%~dp0TMP"
cd /d "%~dp0TMP"

echo Checking for updates...
"%~dp0BAT\wget" -q "https://raw.githubusercontent.com/GDX-X/PFS-BatchKit-Manager/main/.github/workflows/CheckUPDATE.zip" -O "%~dp0TMP\CheckUPDATE.zip" >nul 2>&1
"%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0TMP\CheckUPDATE.zip" -o"%~dp0TMP" "!PFS-BatchKit-Manager.bat" -r -y
for %%F in ( "!PFS-BatchKit-Manager2.bat" ) do if %%~zF==0 del "%%F"

"%~dp0BAT\busybox" md5sum "%~dp0TMP\!PFS-BatchKit-Manager.bat" 2>&1 | "%~dp0BAT\busybox" grep -o "[0-9a-f]\{32\}" > "%~dp0TMP\CheckUPDATE.txt" & set /p CheckUPDATE=<"%~dp0TMP\CheckUPDATE.txt"
"%~dp0BAT\busybox" md5sum "%~dp0!PFS-BatchKit-Manager.bat" 2>&1 | "%~dp0BAT\busybox" grep -o "[0-9a-f]\{32\}" > "%~dp0TMP\CheckOriginal.txt" & set /p CheckOriginal=<"%~dp0TMP\CheckOriginal.txt"

if exist !PFS-BatchKit-Manager.bat (
if !CheckUPDATE! equ !CheckOriginal! (echo ) else (set update=UPDATE AVAILABLE)
)

cd /d "%~dp0" & IF EXIST "%~dp0TMP" rmdir /Q/S "%~dp0TMP" >nul 2>&1

:mainmenu
"%~dp0BAT\Diagbox" gd 0f
IF NOT EXIST "%~dp0TMP"  MD "%~dp0TMP"
cd /d "%~dp0"
cls
title PFS BatchKit Manager v1.1.1 By GDX
echo.Welcome in PFS BatchKit Manager v1.1.1 By GDX
endlocal
endlocal
setlocal EnableDelayedExpansion
setlocal EnableExtensions
echo.------------------------------------------
echo.
ECHO 1. Transfer PS1 Games
ECHO 2. Transfer PS2 Games
ECHO 3. Transfer APPS,ART,CFG,CHT,VMC,THM,POPS-VMC
ECHO 4. Transfer POPS Binaries
ECHO.
ECHO.
ECHO 7. Backup PS1 Games
ECHO 8. Backup PS2 Games
ECHO 9. Backup ART,CFG,CHT,VMC,POPS-VMC
ECHO.
"%~dp0BAT\Diagbox" gd 0e
ECHO 10. Advanced Menu
"%~dp0BAT\Diagbox" gd 0f
ECHO.
ECHO 11. Exit
ECHO.
ECHO.
ECHO 12. About
if defined update ( "%~dp0BAT\Diagbox" gd 0a & ECHO 13. !update!)
if not defined update ECHO 13. Check for Updates
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
if "%choice%"=="13" (start https://github.com/GDX-X/PFS-BatchKit-Manager/releases)

(goto mainmenu)

:About
"%~dp0BAT\Diagbox" gd 0f
cd /d "%~dp0"
cls
title PFS BatchKit Manager v1.1.1 By GDX 
echo.Welcome in PFS BatchKit Manager v1.1.1 By GDX
endlocal
endlocal
setlocal DisableDelayedExpansion
echo.------------------------------------------
ECHO ABOUT ME
echo.
ECHO I was inspired by the scripts of NeMesiS, Dekkit and Rs1n to make this script
ECHO.
ECHO This batch script is intended to help and automate operations on the PS2 hard drive!
ECHO. 
ECHO Many thanks to the PS2 community for their contribution to the program used to make this scripts!
ECHO. 
ECHO GDX
ECHO.
echo.------------------------------------------
ECHO 1. My Twitter
ECHO 2. My Discord : GDX#5466
ECHO 3. My Youtube Channel
ECHO 4. My Github
ECHO 5.
ECHO 6.
ECHO 7. Special Thanks
ECHO 8. Official PS2 Forum
ECHO 9. Official PS2 Discord
ECHO.
ECHO 10. Back to main menu
ECHO 11. Exit
echo.------------------------------------------
set "choice="
set /p choice="Select Option:"

if "%choice%"=="1" (start https://twitter.com/GDX_SM)
if "%choice%"=="3" (start https://www.youtube.com/user/GDXTV/videos)
if "%choice%"=="4" (start https://github.com/GDX-X/PFS-BatchKit-Manager)

if "%choice%"=="7" cls & type "%~dp0\Credit.txt" & echo\ & echo\ & echo\ & pause
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
title PFS BatchKit Manager v1.1.1 By GDX
echo.Welcome in PFS BatchKit Manager v1.1.1 By GDX
endlocal
endlocal
setlocal EnableDelayedExpansion
setlocal EnableExtensions
echo.------------------------------------------
ECHO Advanced Menu
ECHO.
ECHO 1. Conversion
ECHO 2. Games Management
ECHO 3. Downloads/Updates
ECHO 4. 
ECHO 5. PC Utility
ECHO 6.
ECHO 7. HDD-OSD/PSBBN/XMB
ECHO 8. PS2 Online
ECHO 9. HDD Management
ECHO.
ECHO 10. Back to main menu
ECHO 11. Exit
ECHO.
echo.------------------------------------------
set "choice="
set /p choice="Select Option:"

if "%choice%"=="1" (goto ConversionMenu)
if "%choice%"=="2" (goto GamesManagement)
if "%choice%"=="3" (goto DownloadsMenu)

if "%choice%"=="5" (goto PC-UtilityMenu)

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
title PFS BatchKit Manager v1.1.1 By GDX
echo.Welcome in PFS BatchKit Manager v1.1.1 By GDX
endlocal
endlocal
setlocal EnableDelayedExpansion
setlocal EnableExtensions
echo.------------------------------------------
ECHO Conversion Menu
ECHO.
ECHO 1. Convert .BIN to .VCD (Multi-Tracks Compatible)
ECHO 2. Convert .VCD to .BIN
ECHO 3. Convert Multi-Tracks .BIN to Single .BIN
ECHO 4. 
ECHO 5. Convert .BIN to .ISO (Only for PS2 Games Usefull for PCSX2)
ECHO 6. Compress/Decompress .ECM
ECHO 7. Compress/Decompress .CHD (Multi-Tracks Compatible)
ECHO 8. Compress/Decompress .ZSO (Only for PS2 Games)
ECHO 9. Restore Single .BIN to Multi-Tracks (If compatible, it will rebuild the original .bin with the Multi-Track)
ECHO.
ECHO 10. Back
ECHO 11. Back to main menu
ECHO 12. Exit
ECHO.
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
title PFS BatchKit Manager v1.1.1 By GDX
echo.Welcome in PFS BatchKit Manager v1.1.1 By GDX
endlocal
endlocal
setlocal EnableDelayedExpansion
setlocal EnableExtensions
echo.------------------------------------------
ECHO Games Management
ECHO.
ECHO 1. Dump your CD-ROM, DVD-ROM PS1 ^& PS2
ECHO 2. Check MD5 Hash of your PS2 .ISO/.BIN with the redump database
ECHO 3. Assign titles database for your .VCDs
ECHO 4.
ECHO 5. Create Cheat file with mastercode
ECHO 6. Create Virtual Memory Card
ECHO 7. Delete a game
ECHO 8. Rename a game
ECHO 9. Export game list
ECHO.
ECHO 10. Back
ECHO 11. Back to main menu
ECHO 12. Exit
ECHO.
ECHO.
echo.------------------------------------------
set "choice="
set /p choice="Select Option:"

if "%choice%"=="1" (goto DumpCDDVD)
if "%choice%"=="2" (goto checkMD5Hash)
if "%choice%"=="3" (goto RenameVCDDB)

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
title PFS BatchKit Manager v1.1.1 By GDX
echo.Welcome in PFS BatchKit Manager v1.1.1 By GDX
endlocal
endlocal
setlocal EnableDelayedExpansion
setlocal EnableExtensions
echo.------------------------------------------
ECHO Downloads Menu 
ECHO.
REM ECHO 1. Applications
ECHO 1.
ECHO 2. Artworks
ECHO 3. Configs
ECHO 4. Cheats
ECHO 5.
ECHO 6.
ECHO 7.
ECHO 8.
ECHO 9.
REM ECHO 9. Update your APPS,ART,CFG,CHT (Automatically updates files found in your +OPL partition
ECHO.
ECHO 10. Back
ECHO 11. Back to main menu
ECHO 12. Exit
ECHO.
echo.------------------------------------------
set "choice="
set /p choice="Select Option:"
REM if "%choice%"=="1" (goto DownloadAPPSMenu)
if "%choice%"=="2" (goto DownloadARTChoice)
if "%choice%"=="3" (goto DownloadCFG)
if "%choice%"=="4" (goto DownloadCheatsMenu)

if "%choice%"=="10" (goto AdvancedMenu)
if "%choice%"=="11" (goto mainmenu)
if "%choice%"=="12" exit

(goto DownloadsMenu)

:DownloadAPPSMenu
"%~dp0BAT\Diagbox" gd 0f
cd /d "%~dp0"
cls
title PFS BatchKit Manager v1.1.1 By GDX
echo.Welcome in PFS BatchKit Manager v1.1.1 By GDX
endlocal
endlocal
setlocal EnableDelayedExpansion
setlocal EnableExtensions
echo.------------------------------------------
ECHO Download APPS Menu 
ECHO.
ECHO 1. Open PS2 Loader
ECHO 2. wLaunchELF
ECHO 3. Utilities
ECHO 4. Emulators
ECHO 5. Simple Media System
ECHO 6.
ECHO 7.
ECHO 8. Others
ECHO 9. Download only the most useful APPS
ECHO.
ECHO 10. Back
ECHO 11. Back to main menu
ECHO 12. Exit
ECHO.
echo.------------------------------------------
set "choice="
set /p choice="Select Option:"

if "%choice%"=="9" (goto DownloadAPPSMenu)
if "%choice%"=="10" (goto DownloadsMenu)
if "%choice%"=="11" (goto mainmenu)
if "%choice%"=="12" exit

(goto DownloadAPPSMenu)

:DownloadCheatsMenu
"%~dp0BAT\Diagbox" gd 0f
cd /d "%~dp0"
cls
title PFS BatchKit Manager v1.1.1 By GDX
echo.Welcome in PFS BatchKit Manager v1.1.1 By GDX
endlocal
endlocal
setlocal EnableDelayedExpansion
setlocal EnableExtensions
echo.------------------------------------------
ECHO Download Cheats Menu 
ECHO.
ECHO 1.
ECHO 2.
ECHO 3.
ECHO 4.
ECHO 5.
REM ECHO 5. Grand Theft Auto Uncensored blood (European version)
ECHO 6.
ECHO 7.
ECHO 8.
ECHO 9. Widescreen Cheats (4/3 to 16/9)

ECHO.
ECHO 10. Back
ECHO 11. Back to main menu
ECHO 12. Exit
ECHO.
echo.------------------------------------------
set "choice="
set /p choice="Select Option:"

if "%choice%"=="9" (goto DownloadWideScreenCheat)

if "%choice%"=="10" (goto DownloadsMenu)
if "%choice%"=="11" (goto mainmenu)
if "%choice%"=="12" exit

(goto DownloadCheatsMenu)


:PC-UtilityMenu
"%~dp0BAT\Diagbox" gd 0f
cd /d "%~dp0"
cls
title PFS BatchKit Manager v1.1.1 By GDX
echo.Welcome in PFS BatchKit Manager v1.1.1 By GDX
endlocal
endlocal
setlocal EnableDelayedExpansion
setlocal EnableExtensions
echo.------------------------------------------
ECHO PC Utility
ECHO.
ECHO 1. PS1 Save Utility
ECHO 2. PS2 Save Utility
ECHO 3. OPL Manager
ECHO 4.
ECHO 5. 
ECHO 6. PS2 Controller Remapper
ECHO 7.
ECHO 8.
ECHO 9.
ECHO.
ECHO 10. Back
ECHO 11. Back to main menu
ECHO 12. Exit
ECHO.
echo.------------------------------------------
set "choice="
set /p choice="Select Option:"

if "%choice%"=="1" start https://github.com/ShendoXT/memcardrex/releases
if "%choice%"=="2" start https://www.psx-place.com/resources/mymc-dual-by-joack.675
if "%choice%"=="3" start https://oplmanager.com/site
if "%choice%"=="4" start https://github.com/israpps/HDL-Batch-installer/releases
if "%choice%"=="6" start https://www.psx-place.com/resources/ps2-controller-remapper-by-pelvicthrustman.692/


if "%choice%"=="10" (goto AdvancedMenu)
if "%choice%"=="11" (goto mainmenu)
if "%choice%"=="12" exit

(goto PC-UtilityMenu)

:HDDOSDMenu
"%~dp0BAT\Diagbox" gd 0f
cd /d "%~dp0"
cls
title PFS BatchKit Manager v1.1.1 By GDX
echo.Welcome in PFS BatchKit Manager v1.1.1 By GDX
endlocal
endlocal
setlocal EnableDelayedExpansion
setlocal EnableExtensions
echo.------------------------------------------
ECHO HDD-OSD/PSBBN/XMB
ECHO.
ECHO 1. Install HDD-OSD (Browser 2.0)
ECHO 2. Uninstall HDD-OSD
ECHO 3. Partitions Management
REM ECHO 4. Install Playstation Broadband Navigator
REM ECHO 4. Install Linux Kernel
ECHO 4. 
ECHO 5.
ECHO 7.
ECHO 8.
ECHO 9.
ECHO.
ECHO 10. Back
ECHO 11. Back to main menu
ECHO 12. Exit
ECHO.
echo.------------------------------------------
set "choice="
set /p choice="Select Option:"

if "%choice%"=="1" (goto InstallHDDOSD)
if "%choice%"=="2" (goto UnInstallHDDOSD)
if "%choice%"=="3" (goto HDDOSDPartManagement)

if "%choice%"=="10" (goto AdvancedMenu)
if "%choice%"=="11" (goto mainmenu)
if "%choice%"=="12" exit

(goto HDDOSDMenu)

:HDDOSDPartManagement
"%~dp0BAT\Diagbox" gd 0f
cd /d "%~dp0"
cls
title PFS BatchKit Manager v1.1.1 By GDX
echo.Welcome in PFS BatchKit Manager v1.1.1 By GDX
endlocal
endlocal
setlocal EnableDelayedExpansion
setlocal EnableExtensions
echo.------------------------------------------
ECHO HDD-OSD/PSBBN/XMB Partitions Management
ECHO.
ECHO 1. Transfer PS1 Games (Install as Partition Launch PS1 games from HDD-OSD, PSBBN, XMB Menu)
ECHO 2.
REM ECHO 2. Transfer APPS (Install as Partition Launch APPS from HDD-OSD, PSBBN, XMB Menu)
ECHO 3. Inject OPL-Launcher (Launch PS2 games from HDD-OSD)
ECHO 4. Hide Partition (Hide partitions in HDD-OSD)
ECHO 5. Unhide Partition (Show partitions in HDD-OSD)
ECHO 6. Rename a title (Displayed in HDD-OSD, PSBBN, XMB Menu)
ECHO 7. Convert a PS2 game for PSBBN ^& XMB Menu (Launch PS2 games from HDD-OSD, PSBBN, XMB Menu)
ECHO 8.
REM ECHO 8. Update partition header (Download Icons & more)
ECHO 9. Modify Partitions Header (Customize your partition header)
ECHO.
ECHO 10. Back
ECHO 11. Back to main menu
ECHO 12. Exit
ECHO.
echo.------------------------------------------
set "choice="
set /p choice="Select Option:"
if "%choice%"=="1" set "@pfs_popHDDOSDMAIN=" & (goto TransferPS1GamesHDDOSD)

if "%choice%"=="3" (goto InjectOPL-Launcher)
if "%choice%"=="4" (goto pphide)
if "%choice%"=="5" (goto ppunhide)
if "%choice%"=="6" (goto RenameTitleHDDOSD)
if "%choice%"=="7" (goto ConvertGamesBBNXMB)
if "%choice%"=="9" (goto CustomPPHeader)

if "%choice%"=="10" (goto HDDOSDMenu)
if "%choice%"=="11" (goto mainmenu)
if "%choice%"=="12" exit

(goto HDDOSDPartManagement)

:PS2OnlineMenu
"%~dp0BAT\Diagbox" gd 0f
cd /d "%~dp0"
cls
title PFS BatchKit Manager v1.1.1 By GDX
echo.Welcome in PFS BatchKit Manager v1.1.1 By GDX
endlocal
endlocal
setlocal EnableDelayedExpansion
setlocal EnableExtensions
echo.------------------------------------------
ECHO Online Menu
ECHO.
ECHO 1.
ECHO 2.
ECHO 3.
ECHO 4.
ECHO 5.
ECHO 6.
ECHO 7.
ECHO 8.
ECHO 9. Show PS2 Games Compatibles (Show only games that don't need a patch)
ECHO.
ECHO 10. Back
ECHO 11. Back to main menu
ECHO 12. Exit
ECHO.
echo.------------------------------------------
set "choice="
set /p choice="Select Option:"

if "%choice%"=="9" start https://docs.google.com/spreadsheets/d/1bbxOGm4dPxZ4Vbzyu3XxBnZmuPx3Ue-cPqBeTxtnvkQ
if "%choice%"=="10" (goto AdvancedMenu)
if "%choice%"=="11" (goto mainmenu)
if "%choice%"=="12" exit

(goto PS2OnlineMenu)

:HDDManagementMenu
"%~dp0BAT\Diagbox" gd 0f
cd /d "%~dp0"
cls
title PFS BatchKit Manager v1.1.1 By GDX
echo.Welcome in PFS BatchKit Manager v1.1.1 By GDX
endlocal
endlocal
setlocal EnableDelayedExpansion
setlocal EnableExtensions
echo.------------------------------------------
ECHO HDD Management 
ECHO.
ECHO 1. Create Partition
ECHO 2. Delete Partition
ECHO 3.
ECHO 4. Show Partition Informations
ECHO 5. Backup or Inject PS2 MBR Program
ECHO 6. Explore PS2 HDD (Mount Any partition from Windows Explorer)
ECHO 7. NBD Server (Only to access PS2 HDD from network)
"%~dp0BAT\Diagbox" gd 06
ECHO 8. Hack your HDD To PS2 Format (This is only intended to be used as a boot entry point on wLaunchELF)
"%~dp0BAT\Diagbox" gd 0c
ECHO 9. Format HDD To PS2 Format
"%~dp0BAT\Diagbox" gd 0f
ECHO.
ECHO 10. Back
ECHO 11. Back to main menu
ECHO 12. Exit
ECHO.
echo.------------------------------------------
set "choice="
set /p choice="Select Option:"

if "%choice%"=="1"  (goto CreatePART)
if "%choice%"=="2"  (goto DeletePART)

if "%choice%"=="4"  (goto ShowPartitionInfos) 
if "%choice%"=="5"  (goto MBRProgram)
if "%choice%"=="6"  (goto PS2HDDExplore)
if "%choice%"=="7"  (goto NBDServer)
if "%choice%"=="8"  (goto hackHDDtoPS2)
if "%choice%"=="9"  (goto formatHDDtoPS2)
if "%choice%"=="10" (goto AdvancedMenu)
if "%choice%"=="11" (goto mainmenu)
if "%choice%"=="12" exit

(goto HDDManagementMenu)

:ShowPartitionInfos
"%~dp0BAT\Diagbox" gd 0f
cd /d "%~dp0"
cls
title PFS BatchKit Manager v1.1.1 By GDX
echo.Welcome in PFS BatchKit Manager v1.1.1 By GDX
endlocal
endlocal
setlocal EnableDelayedExpansion
setlocal EnableExtensions
echo.------------------------------------------
ECHO Partition Informations
ECHO.
ECHO 1. Show PS1 Games Partitions Table
ECHO 2. Show PS2 Games Partitions Table
ECHO 3. Show System Partitions Table
ECHO 4. 
ECHO 5.
ECHO 6.
ECHO 7.
ECHO 8.
ECHO 9. Scan Partitions Error
ECHO.
ECHO 10. Back
ECHO 11. Back to main menu
ECHO 12. Exit
ECHO.
echo.------------------------------------------
set "choice="
set /p choice="Select Option:"

if "%choice%"=="1" set ShowPS1GamePartitionList=yes & (goto PartitionInfoList)
if "%choice%"=="2" set ShowPS2GamePartitionList=yes & (goto PartitionInfoList)
if "%choice%"=="3" set ShowSystemPartitionList=yes & (goto PartitionInfoList)
if "%choice%"=="9" set DiagPartitionError=yes & (goto PartitionInfoList)

if "%choice%"=="10" (goto HDDManagementMenu)
if "%choice%"=="11" (goto mainmenu)
if "%choice%"=="12" exit

(goto ShowPartitionInfos)

:PS2HDDExplore
"%~dp0BAT\Diagbox" gd 0f
cd /d "%~dp0"
cls
title PFS BatchKit Manager v1.1.1 By GDX
echo.Welcome in PFS BatchKit Manager v1.1.1 By GDX
endlocal
endlocal
setlocal EnableDelayedExpansion
setlocal EnableExtensions
echo.------------------------------------------
ECHO Explore PS2 HDD
ECHO.
ECHO 1. Mount Partition from PS2 HDD
ECHO 2. Mount Partition from IMAGE
ECHO 3. Umount All Partition
ECHO 4.
ECHO 5.
ECHO 6.
ECHO 7. Show driver version
ECHO 8. Install/Update Driver
ECHO 9. Uninstall Driver
ECHO.
ECHO 10. Back
ECHO 11. Back to main menu
ECHO 12. Exit
ECHO.
echo.------------------------------------------
set "choice="
set /p choice="Select Option:"

if "%choice%"=="1" set "mount=HDD" & (goto PS2HDD2WinExplorer)
if "%choice%"=="2" set "mount=IMG" & (goto PS2HDD2WinExplorer)
if "%choice%"=="3" set "UmountManuallyPartition=yes" & (goto PS2HDD2WinExplorer)

if "%choice%"=="7" set CheckDokanVersion=yes & (goto PS2HDD2WinExplorer)
if "%choice%"=="8" set InstallDriver=yes & (goto PS2HDD2WinExplorer)
if "%choice%"=="9" set UninstallDokanDriver=yes & (goto PS2HDD2WinExplorer)

if "%choice%"=="10" (goto HDDManagementMenu)
if "%choice%"=="11" (goto mainmenu)
if "%choice%"=="12" exit

(goto PS2HDDExplore)

:NBDServer
"%~dp0BAT\Diagbox" gd 0f
cd /d "%~dp0"
cls
title PFS BatchKit Manager v1.1.1 By GDX
echo.Welcome in PFS BatchKit Manager v1.1.1 By GDX
endlocal
endlocal
setlocal EnableDelayedExpansion
setlocal EnableExtensions
echo.------------------------------------------
ECHO Network block device Server
ECHO.
ECHO 1. Mount Device 
ECHO 2. Umount Device
ECHO 3. Show list of mounted devices
ECHO 4.
ECHO 5.
ECHO 6.
ECHO 7.
ECHO 8. Install/Update NBD Driver
ECHO 9. Uninstall NBD Driver
ECHO.
ECHO 10. Back
ECHO 11. Back to main menu
ECHO 12. Exit
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
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | findstr "hdd" | "%~dp0BAT\busybox" grep "Playstation 2 HDD"
"%~dp0BAT\Diagbox" gd 07
echo\
pause
)

if "%choice%"=="2" cls & "%~dp0BAT\wnbd-client.exe" unmap PS2HDD & echo\ & echo\ & pause
if "%choice%"=="3" cls & "%~dp0BAT\wnbd-client.exe" list & echo\ & echo\ & pause
if "%choice%"=="8"  (goto InstallNBDDriver)
if "%choice%"=="9" ( 
cls
echo\
echo Are you sure you want to uninstall NBD-Server drivers?
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

rem **********************************************************************
rem *
rem * HDLBATCH 1.15
rem *
rem **********************************************************************
rem * DATE: 02-JAN-2020
rem * 
rem * Created and tested on a Windows 10 machine
rem * Based on a batch file "HDL_HDD_Batcher" by Dekkit that calls an
rem * older version of HDL DUMP: HDL_DUMP_090.EXE
rem *
rem * Format your PS2 HDD using uLaunch and then connect it to your PC
rem * either directly or using a USB adapter. Place this batch file along
rem * with HDL_DUMP.EXE (0.9.2) in the same directory as all your games
rem * (either CUE/BIN or ISO files).
rem * 
rem * Right click on this batch file and select "Run as Administrator"
rem * since it calls HDL_DUMP.EXE (0.9.2), which requires access to
rem * hardware. Then follow the prompts.
rem *
rem * When you are truly ready to install, edit the OPTIONS section below
rem * and run the batch file as directed above.
rem *
rem * Game files may be prefixed with GAME ID as (sometimes) required by
rem * certain version of  OPL Manager. In such cases, the GAME ID will be
rem * stripped from the file name and the remaining portion (excluding
rem * file extension) will be used as the game title.
rem *
rem * If gameid.txt" is found, then the HDLBATCH will use the first-found
rem * occurrence of a matched game title, falling back on the file name
rem * if no match is found. The format of the gameid.txt" file is:
rem *
rem * SABC_XXX.YY Tile of Game
rem * 
rem * where SABC is the developer/region code, and XXX.YY is the GAME ID
rem *
rem * Thanks to Wizard 0f 0z et. al, and AKuHAK for HDLDUMP
rem * (HDL_DUMP sources at: https://www.github.com/AKuHAK/hdl-dump)
rem *
rem * Hanst3r
rem *
rem **********************************************************************
rem * EXAMPLE 
rem **********************************************************************
rem * FILE:	SCUS_973.28.Gran Turismo 4.iso
rem * TARGET:	hdd1:
rem *
rem * hdl_dump inject_dvd hdd1: "Gran Turismo 4" "SCUS_973.28.Gran Turismo 4.iso" "SCUS_973.28" *u4
rem **********************************************************************

rem **********************************************************************
rem OPTIONS:
rem **********************************************************************
rem 	set TEST=NO			(all caps) do real install
rem	set TEST=<anything else>	only print installation info

set TEST=NO

rem **********************************************************************
rem * NOTHING TO EDIT BELOW THIS LINE

cls
mkdir "%~dp0CD-DVD" >nul 2>&1
mkdir "%~dp0TMP" >nul 2>&1
cd /d "%~dp0CD-DVD"

copy "%~dp0BAT\hdl_dump.exe" "%~dp0CD-DVD" >nul 2>&1

if "%TEST%"=="NO" (

"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning for Playstation 2 HDDs:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "Playstation 2 HDD"
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "Playstation 2 HDD" | "%~dp0BAT\busybox" grep -o "hdd[0-9]:\|hdd[0-9][0-9]:" > "%~dp0TMP\hdl-hdd.txt" & "%~dp0BAT\busybox" cat "%~dp0TMP\hdl-hdd.txt" > "%~dp0TMP\hdl-hdd2.txt"
"%~dp0BAT\busybox" sed -i "s/hdd/\\\\.\\\PhysicalDrive/g; s/://g" "%~dp0TMP\hdl-hdd2.txt"

set /P @hdl_path2=<"%~dp0TMP\hdl-hdd2.txt"
set /P @hdl_path=<"%~dp0TMP\hdl-hdd.txt"
REM del "%~dp0TMP\hdl-hdd.txt" >nul 2>&1
IF "!@hdl_path!"=="" (
"%~dp0BAT\Diagbox" gd 0c
		echo         Playstation 2 HDD Not Detected
		echo         Drive Must Be Formatted First
		echo\
		echo\
"%~dp0BAT\Diagbox" gd 06
		echo Do you want to install your games over the network with hdl_svr?
		choice /c YN
		if !errorlevel!==1 (set transfernetwork=yes)
		if !errorlevel!==2 (rmdir /Q/S "%~dp0TMP" >nul 2>&1 & goto mainmenu)
	)
)

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Transfer PS2 Games:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1) Yes
"%~dp0BAT\Diagbox" gd 0c
echo         2) No
"%~dp0BAT\Diagbox" gd 0e
echo         3) Yes (Copy all PS2 games from one HDD to another in PS2 format)
echo\
"%~dp0BAT\Diagbox" gd 07
CHOICE /C 123 /M "Select Option:"

if %ERRORLEVEL%==2 (goto mainmenu)
if %ERRORLEVEL%==3 (goto CopyPS2GamesHDD)

if defined transfernetwork (
    copy "%~dp0BAT\hdl_svr_093.elf" "%~dp0" >nul 2>&1
    echo\
	echo\
    set /p "@hdl_path=Enter IP of the Playstation 2:"
	ping -n 1 -w 2000 !@hdl_path!
	if errorlevel 1 (
	"%~dp0BAT\Diagbox" gd 0c
	echo Unable to ping !@hdl_path!
	"%~dp0BAT\Diagbox" gd 0f
	pause & (goto mainmenu)
 )
)

  "%~dp0BAT\Diagbox" gd 07
  cls
  echo\
  echo Game title database found.
  choice /c YN /m "Use titles from database? "
  if errorlevel 2 ( set usedb=no & echo\ & echo Using file names as titles.) else ( set usedb=yes)

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

IF !language!==english ("%~dp0BAT\busybox" iconv -f utf8 -t ascii//TRANSLIT//IGNORE "%~dp0BAT\TitlesDB\gameidPS2ENG.txt" > "%~dp0CD-DVD\gameid.txt")
IF !language!==french ("%~dp0BAT\busybox" iconv -f utf8 -t ascii//TRANSLIT//IGNORE "%~dp0BAT\TitlesDB\gameidPS2FRA.txt" > "%~dp0CD-DVD\gameid.txt")
)

echo ----------------------------------------------------
echo\
echo Do you want inject OPL-Launcher (Optional)
"%~dp0BAT\Diagbox" gd 0e
echo Allows you to launch your game from HDD-OSD (Browser 2.0)
"%~dp0BAT\Diagbox" gd 07
echo\
CHOICE /C YN /M "Select Option:"

if errorlevel 1 set InjectKELF=yes
if errorlevel 2 set InjectKELF=no

IF !InjectKELF!==yes ( copy "%~dp0BAT\boot.kelf" "%~dp0CD-DVD" >nul 2>&1 )
echo ----------------------------------------------------
echo\
echo Create cheats.CHT For your games with Mastercode? (Optional)
"%~dp0BAT\Diagbox" gd 0e
echo It is recommended to create the cheat files now
"%~dp0BAT\Diagbox" gd 07
echo\
CHOICE /C YN /M "Select Option:"
if errorlevel 1 set CreateCHT=yes
if errorlevel 2 set CreateCHT=no

IF !CreateCHT!==yes (
echo Creating .CHT Please wait...
cd /d "%~dp0" & copy "%~dp0BAT\make_cheat_mastercode.bat" "%~dp0" >nul & "%~dp0BAT\busybox" sed -i "$aexit" "make_cheat_mastercode.bat" | START /wait /MIN CMD.EXE /C make_cheat_mastercode.bat & del make_cheat_mastercode.bat
echo Don't forget to transfer your .CHTs to the HDD
)
echo ----------------------------------------------------
echo\
echo Compress your games in .ZSO? (EXPERIMENTAL)
"%~dp0BAT\Diagbox" gd 0e
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

echo ----------------------------------------------------
REM CHECK IF .CUE IS MISSING FOR .BIN IF IT IS NOT DETECTED IT WILL BE CREATED
cd /d "%~dp0CD" & call "%~dp0BAT\cuemaker.bat"
move *.bin "%~dp0CD-DVD" >nul 2>&1
move *.cue "%~dp0CD-DVD" >nul 2>&1
move *.iso "%~dp0CD-DVD" >nul 2>&1
cd /d "%~dp0DVD"
move *.iso "%~dp0CD-DVD" >nul 2>&1
move *.zso "%~dp0CD-DVD" >nul 2>&1

cd /d "%~dp0CD-DVD" 
"%~dp0BAT\busybox" ls | "%~dp0BAT\busybox" grep -ie ".iso" -ie ".cue" -ie ".zso" > gamelistTMP.txt
set /a gamecount=0
for /f "tokens=*" %%f in (gamelistTMP.txt) do (
	set /a gamecount+=1
    echo\
	echo\
	echo !gamecount! - %%f

	setlocal DisableDelayedExpansion
	set filename=%%f
	set fname=%%~nf
	set disctype=unknown
	if "%%f"=="%%~nf.cue" set ext=CUE
	if "%%f"=="%%~nf.iso" set ext=ISO
	if "%%f"=="%%~nf.CUE" set ext=CUE
	if "%%f"=="%%~nf.ISO" set ext=ISO

	setlocal EnableDelayedExpansion
	if defined ext ( hdl_dump cdvd_info2 ".\!fname!.!ext!" > cdvd_info.txt
	for /f "tokens=1,2,3,4,5*" %%i in (cdvd_info.txt) do (
	if "%%i"=="CD" ( set disctype=CD&& set gameid=%%~l)
	if "%%i"=="DVD" ( set disctype=DVD&& set gameid=%%~l)
	if "%%i"=="dual-layer" ( if "%%j"=="DVD" ( set disctype=DVD&& set gameid=%%~m))
     )
	 
	) else ( 
	"%~dp0BAT\busybox" grep -o -m 1 "[A-Z][A-Z][A-Z][A-Z][_-][0-9][0-9][0-9].[0-9][0-9]" "!filename!" | "%~dp0BAT\busybox" sed "s/-/_/g" | "%~dp0BAT\busybox" head -1 > cdvd_info.txt
	set ext=ZSO
	set disctype=DVD
	set /P gameid=<cdvd_info.txt
	)
	
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
		 REM A = Asie
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
		 if not defined region set region=X
		 
		 if "!ConvZSO!"=="yes" (
		 IF EXIST "%~dp0CD-DVD\!fname!.zso" ( set DelConvZSO=no ) else (
		 echo Convert to ZSO... Please wait
         set ext=ZSO
		 set DelConvZSO=yes
         if "!disctype!"=="CD" (
		 if exist "!fname!.iso" ( "%~dp0BAT\maxcso" --block=2048 --format=zso "!fname!.iso" >nul 2>&1
		 ) else (
		 "%~dp0BAT\bchunk" "!fname!.bin" "!fname!.cue" "!fname!" >nul 2>&1 & ren "!fname!01.iso" "!fname!.iso" >nul 2>&1
		 "%~dp0BAT\maxcso" --block=2048 --format=zso "!fname!.iso" >nul 2>&1
		 del "!fname!.iso" >nul 2>&1
		    )
           )
		 if "!disctype!"=="DVD" "%~dp0BAT\maxcso" --block=2048 --format=zso "!fname!.iso" >nul 2>&1
          )
		 )
		  
		 REM GET FILE SIZE 
		 if not exist "!fname!.iso" "%~dp0BAT\busybox" du -csh "!fname!.bin" 2>&1 | "%~dp0BAT\busybox" grep -e "total" | "%~dp0BAT\busybox" sed -e "s/total//g; s/K/KB/g; s/M/MB/g; s/G/GB/g" > "%~dp0TMP\binsize.txt" & set /P size=<"%~dp0TMP\binsize.txt"
	     if not exist "!fname!.bin" "%~dp0BAT\busybox" du -csh "!fname!.iso" 2>&1 | "%~dp0BAT\busybox" grep -e "total" | "%~dp0BAT\busybox" sed -e "s/total//g; s/K/KB/g; s/M/MB/g; s/G/GB/g" > "%~dp0TMP\binsize.txt" & set /P size=<"%~dp0TMP\binsize.txt"
         if !ext!==ZSO "%~dp0BAT\busybox" du -csh "!fname!.zso" 2>&1 | "%~dp0BAT\busybox" grep -e "total" | "%~dp0BAT\busybox" sed -e "s/total//g; s/K/KB/g; s/M/MB/g; s/G/GB/g" > "%~dp0TMP\zsosize.txt" & set /P size=<"%~dp0TMP\zsosize.txt"
		  
			if "!usedb!"=="yes" (

				set "dbtitle="
				for /f "tokens=1*" %%A in ( 'findstr !gameid! gameid.txt' ) do (
					if not defined dbtitle set dbtitle=%%B
				)

				if defined dbtitle (

					if "!dbtitle:~-1,1!"==" " (
						set title=!dbtitle:~0,-1!
					) else (
						set title=!dbtitle!
					)

				)
			)
			
			echo Title:    [!title!]
			echo Gameid:   [!gameid!]
			echo Region:   [!region!]
			echo DiscType: [!disctype!]
			echo Format:   [!ext!]
			echo Size:     [!size!]
			
			"%~dp0BAT\Diagbox" gd 0d
			if "%TEST%"=="NO" hdl_dump inject_!disctype! !@hdl_path! "!title!" "!fname!.!ext!" !gameid! *u4
			if "!InjectKELF!"=="yes" hdl_dump modify_header !@hdl_path! "!title!" | findstr "Successfully"
			if "!DelConvZSO!"=="yes" del "!fname!.zso" >nul 2>&1
			"%~dp0BAT\Diagbox" gd 07
		)
	endlocal
endlocal
)

echo\
cd /d "%~dp0CD-DVD"
move *.bin "%~dp0CD" >nul 2>&1
move *.cue "%~dp0CD" >nul 2>&1
move *.iso "%~dp0DVD" >nul 2>&1
move *.zso "%~dp0DVD" >nul 2>&1

REM Del games cache 
echo device %@hdl_path2% > "%~dp0TMP\pfs-OPLcache.txt"
echo mount +OPL >> "%~dp0TMP\pfs-OPLcache.txt"
echo rm games.bin >> "%~dp0TMP\pfs-OPLcache.txt"
echo umount >> "%~dp0TMP\pfs-OPLcache.txt"
echo mount __common >> "%~dp0TMP\pfs-OPLcache.txt"
echo cd OPL >> "%~dp0TMP\pfs-OPLcache.txt"
echo rm games.bin >> "%~dp0TMP\pfs-OPLcache.txt"
echo exit >> "%~dp0TMP\pfs-OPLcache.txt"
echo umount >> "%~dp0TMP\pfs-OPLcache.txt"
type "%~dp0TMP\pfs-OPLcache.txt" | "%~dp0BAT\pfsshell" >nul 2>&1

cd /d "%~dp0"
rmdir /Q/S "%~dp0TMP" >nul 2>&1
rmdir /Q/S "%~dp0CD-DVD" >nul 2>&1

echo\
pause & (goto mainmenu)
REM ########################################################################################################################################################################
:CopyPS2GamesHDD

cls
mkdir "%~dp0TMP" >nul 2>&1
cd /d "%~dp0TMP"

"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning HDDs:
echo ----------------------------------------------------
    "%~dp0BAT\Diagbox" gd 03
	"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "Playstation 2 HDD"
	"%~dp0BAT\Diagbox" gd 07
    echo.
    echo ----------------------------------------------------
	"%~dp0BAT\Diagbox" gd 06
	echo Choose your Playstation 2 hard drive that contains your games
	echo\
	"%~dp0BAT\Diagbox" gd 07
	echo\
    echo What is the number of my hard drive? / The one next to the hdd#: in the scanned HDDs
    echo Example If you want select hdd7: type 7
    echo\
	echo\
	echo 	R. Refresh HDD
	echo 	Q. Back to main menu
	echo\
	echo\
    set choice=
    set /p choice=Enter the number of the hard drive contains your games:
    echo\
    IF "!choice!"=="" set "hdlhdd=" & (goto CopyPS2GamesHDD)
    IF "!choice!"=="!choice!" set hdlhdd=hdd!choice!:
	IF "!choice!"=="R" (goto CopyPS2GamesHDD)
    IF "!choice!"=="Q" set "hdlhdd=" & set "hdlhdd2=" & (goto mainmenu)

:RefreshCopyPS2HDD
cls
"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning for second HDD:
echo ----------------------------------------------------
    "%~dp0BAT\Diagbox" gd 03
	"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "Playstation 2 HDD" | "%~dp0BAT\busybox" sed "/!hdlhdd!/d"
	"%~dp0BAT\Diagbox" gd 07
    echo.
    echo ----------------------------------------------------
	"%~dp0BAT\Diagbox" gd 06
	echo Now connect your second Playstation 2 HDD
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
    IF "!choice!"=="" (goto RefreshCopyPS2HDD)
    IF "!choice!"=="!choice!" set hdlhdd2=hdd!choice!:
	IF "!choice!"=="R" (goto RefreshCopyPS2HDD)
    IF "!choice!"=="Q" set "hdlhdd=" & set "hdlhdd2=" & (goto mainmenu)

cls
"%~dp0BAT\Diagbox" gd 0e
echo HDD 1 Selected: Hard drive that contains your games
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "!hdlhdd!"
"%~dp0BAT\Diagbox" gd 0e
echo ----------------------------------------------------
echo\

echo HDD 2 Selected: Copy to
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "!hdlhdd2!"
"%~dp0BAT\Diagbox" gd 0e
echo ----------------------------------------------------

echo\
CHOICE /C YN /m "Confirm"
echo\

if ERRORLEVEL 2 set "hdlhdd=" & set "hdlhdd2=" & (goto CopyPS2GamesHDD)

echo Copy your custom game icons displayed on HDD-OSD?
CHOICE /C YN /m "Copy custom games icons?"
echo\
if errorlevel 1 set copyiconHDDOSD=yes
if errorlevel 2 set copyiconHDDOSD=no

"%~dp0BAT\Diagbox" gd 03
cd /d "%~dp0TMP" & "%~dp0BAT\hdl_dump" toc %hdlhdd% | "%~dp0BAT\busybox" grep -e "0x1337" | "%~dp0BAT\busybox" cut -c30-500 > "%~dp0TMP\PPGamelistPS2HDD1.txt"

echo\
"%~dp0BAT\hdl_dump" copy_hdd %hdlhdd% %hdlhdd2%
if errorlevel 1 (set copyiconHDDOSD=no)

echo\

if %copyiconHDDOSD%==yes (

cd /d "%~dp0TMP" & "%~dp0BAT\hdl_dump" toc %hdlhdd2% | "%~dp0BAT\busybox" grep -e "0x1337" | "%~dp0BAT\busybox" cut -c30-500 > "%~dp0TMP\PPGamelistPS2HDD2.txt"
"%~dp0BAT\busybox" paste -d " " "%~dp0TMP\PPGamelistPS2HDD1.txt" "%~dp0TMP\PPGamelistPS2HDD2.txt" | "%~dp0BAT\busybox" sed -e "s/ * PP/;PP/g" > "%~dp0TMP\PPGamelistPS2NEW.txt"

for /f "tokens=1* delims=;" %%f in (PPGamelistPS2NEW.txt) do (

echo Backup "%%f" partition header... from %hdlhdd%
set "PPHEADER=%%f" & mkdir "%~dp0TMP\!PPHEADER!" >nul 2>&1
cd /d "%~dp0TMP\!PPHEADER!" & "%~dp0BAT\hdl_dump_fix" dump_header %hdlhdd% "%%f" >nul 2>&1 & cd ..

echo Inject "%%g" partition header... to %hdlhdd2%
cd /d "%~dp0TMP\!PPHEADER!" & "%~dp0BAT\hdl_dump" modify_header %hdlhdd2% "%%g" >nul 2>&1 & cd ..
echo\
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

"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning for Playstation 2 HDDs:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "Playstation 2 HDD"
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "Playstation 2 HDD" | "%~dp0BAT\busybox" grep -o "hdd[0-9]:\|hdd[0-9][0-9]:" > "%~dp0TMP\hdl-hdd.txt"
"%~dp0BAT\busybox" sed -i "s/hdd/\\\\.\\\PhysicalDrive/g; s/://g" "%~dp0TMP\hdl-hdd.txt"

set /P @hdl_path=<"%~dp0TMP\hdl-hdd.txt"
REM del "%~dp0TMP\hdl-hdd.txt" >nul 2>&1
IF "!@hdl_path!"=="" ( 
"%~dp0BAT\Diagbox" gd 0c
		echo         Playstation 2 HDD Not Detected
		echo         Drive Must Be Formatted First
		echo\
		echo\
"%~dp0BAT\Diagbox" gd 07
		rmdir /Q/S "%~dp0TMP" >nul 2>&1
	    pause & (goto mainmenu)
	)

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Transfer Applications: [APPS]
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1) Yes
"%~dp0BAT\Diagbox" gd 0c
echo         2) No
"%~dp0BAT\Diagbox" gd 0e
echo		3) Yes Create title.cfg for each ELF To launch APPS from OPL
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
echo         1) Yes
"%~dp0BAT\Diagbox" gd 0c
echo         2) No
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
echo         1) Yes
"%~dp0BAT\Diagbox" gd 0c
echo         2) No
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
echo         1) Yes
"%~dp0BAT\Diagbox" gd 0c
echo         2) No
"%~dp0BAT\Diagbox" gd 07
echo\
CHOICE /C 12 /M "Select Option:"

IF %ERRORLEVEL%==1 set @pfs_cht=yes
IF %ERRORLEVEL%==2 set @pfs_cht=no

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Transfer Themes: [THM]
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1) Yes
"%~dp0BAT\Diagbox" gd 0c
echo         2) No
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
echo         1) Yes
"%~dp0BAT\Diagbox" gd 0c
echo         2) No
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
echo         1) Yes
"%~dp0BAT\Diagbox" gd 0c
echo         2) No
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

REM APPS INFO
IF %@pfs_apps%==yes (
IF /I EXIST "%~dp0APPS\*" (
"%~dp0BAT\busybox" ls -1 "%~dp0APPS" | "%~dp0BAT\busybox" wc -l > "%~dp0TMP\APPSFiles.txt" & set /P @APP_Files=<"%~dp0TMP\APPSFiles.txt"
"%~dp0BAT\busybox" du -csh "%~dp0APPS" | "%~dp0BAT\busybox" grep -e "total" | "%~dp0BAT\busybox" sed -e "s/total//g; s/K/KB/g; s/M/MB/g; s/G/GB/g" > "%~dp0TMP\APPSSize.txt" & set /P @APP_Size=<"%~dp0TMP\APPSSize.txt"
set APP_Path="%~dp0APPS"
 )
)

REM ART INFO
IF %@pfs_art%==yes (
IF /I EXIST "%~dp0ART\*" (
"%~dp0BAT\busybox" ls -1 "%~dp0ART" | "%~dp0BAT\busybox" wc -l > "%~dp0TMP\ARTFiles.txt" & set /P @ART_Files=<"%~dp0TMP\ARTFiles.txt"
"%~dp0BAT\busybox" du -csh "%~dp0ART" | "%~dp0BAT\busybox" grep -e "total" | "%~dp0BAT\busybox" sed -e "s/total//g; s/K/KB/g; s/M/MB/g; s/G/GB/g" > "%~dp0TMP\ARTSize.txt" & set /P @ART_Size=<"%~dp0TMP\ARTSize.txt"
set ART_Path="%~dp0ART"
 )
)

REM CFG INFO
IF %@pfs_cfg%==yes (
IF /I EXIST "%~dp0CFG\*" (
"%~dp0BAT\busybox" ls -1 "%~dp0CFG" | "%~dp0BAT\busybox" wc -l > "%~dp0TMP\CFGFiles.txt" & set /P @CFG_Files=<"%~dp0TMP\CFGFiles.txt"
"%~dp0BAT\busybox" du -csh "%~dp0CFG" | "%~dp0BAT\busybox" grep -e "total" | "%~dp0BAT\busybox" sed -e "s/total//g; s/K/KB/g; s/M/MB/g; s/G/GB/g" > "%~dp0TMP\CFGSize.txt" & set /P @CFG_Size=<"%~dp0TMP\CFGSize.txt"
set CFG_Path="%~dp0CFG"
 )
)

REM THM INFO
IF %@pfs_thm%==yes (
IF /I EXIST "%~dp0THM\*" (
"%~dp0BAT\busybox" ls -1 "%~dp0THM" | "%~dp0BAT\busybox" wc -l > "%~dp0TMP\THMFiles.txt" & set /P @THM_Files=<"%~dp0TMP\THMFiles.txt"
"%~dp0BAT\busybox" du -csh "%~dp0THM" | "%~dp0BAT\busybox" grep -e "total" | "%~dp0BAT\busybox" sed -e "s/total//g; s/K/KB/g; s/M/MB/g; s/G/GB/g" > "%~dp0TMP\THMSize.txt" & set /P @THM_Size=<"%~dp0TMP\THMSize.txt"
set THM_Path="%~dp0THM"
 )
)

REM CHT INFO
IF %@pfs_cht%==yes (
IF /I EXIST "%~dp0CHT\*" (
"%~dp0BAT\busybox" ls -1 "%~dp0CHT" | "%~dp0BAT\busybox" wc -l > "%~dp0TMP\CHTFiles.txt" & set /P @CHT_Files=<"%~dp0TMP\CHTFiles.txt"
"%~dp0BAT\busybox" du -csh "%~dp0CHT" | "%~dp0BAT\busybox" grep -e "total" | "%~dp0BAT\busybox" sed -e "s/total//g; s/K/KB/g; s/M/MB/g; s/G/GB/g" > "%~dp0TMP\CHTSize.txt" & set /P @CHT_Size=<"%~dp0TMP\CHTSize.txt"
set CHT_Path="%~dp0CHT"
 )
)

REM VMC INFO
IF %@pfs_vmc%==yes (
IF /I EXIST "%~dp0VMC\*" (
"%~dp0BAT\busybox" ls -1 "%~dp0VMC" | "%~dp0BAT\busybox" wc -l > "%~dp0TMP\VMCFiles.txt" & set /P @VMC_Files=<"%~dp0TMP\VMCFiles.txt"
"%~dp0BAT\busybox" du -csh "%~dp0VMC" | "%~dp0BAT\busybox" grep -e "total" | "%~dp0BAT\busybox" sed -e "s/total//g; s/K/KB/g; s/M/MB/g; s/G/GB/g" > "%~dp0TMP\VMCSize.txt" & set /P @VMC_Size=<"%~dp0TMP\VMCSize.txt"
set VMC_Path="%~dp0VMC"
 )
)

REM POPS-VMC INFO
REM IF %@pfs_popvmc%==yes (
REM IF /I EXIST %~dp0POPS\VMC\* (
REM "%~dp0BAT\busybox" ls -1 "%~dp0POPS\VMC" | "%~dp0BAT\busybox" wc -l > "%~dp0TMP\POPSVMCFiles.txt" & set /P @POPSVMC_Files=<"%~dp0TMP\POPSVMCFiles.txt"
REM "%~dp0BAT\busybox" du -bch "%~dp0POPS\VMC" | "%~dp0BAT\busybox" grep -e "total" | "%~dp0BAT\busybox" sed -e "s/total//g; s/K/KB/g; s/M/MB/g; s/G/GB/g" > "%~dp0TMP\POPSVMCSize.txt" & set /P @POPSVMC_Size=<"%~dp0TMP\POPSVMCSize.txt"
REM set POPSVMC_Path="%~dp0POPS\VMC"
REM  )
REM )

REM TOTAL INFO
"%~dp0BAT\busybox" du -bch !APP_Path! !ART_Path! !CFG_Path! !CHT_Path! !THM_Path! !VMC_Path! !POPSVMC_Path! : 2>&1 | "%~dp0BAT\busybox" grep -e "total" | "%~dp0BAT\busybox" sed -e "s/total//g; s/K/KB/g; s/M/MB/g; s/G/GB/g" > "%~dp0TMP\TotalSIZE.txt" & set /P @Total_Size=<"%~dp0TMP\TotalSIZE.txt"
set /a "@Total_Files=%@APP_Files%+%@ART_Files%+%@CFG_Files%+%@CHT_Files%+%@THM_Files%+%@VMC_Files%+%@POPSVMC_Files%+0"

if defined APP_Path echo APP - Files: %@APP_Files% - Size: %@APP_Size%
if defined ART_Path echo ART - Files: %@ART_Files% - Size: %@ART_Size%
if defined CFG_Path echo CFG - Files: %@CFG_Files% - Size: %@CFG_Size%
if defined CHT_Path echo CHT - Files: %@CHT_Files% - Size: %@CHT_Size%
if defined THM_Path echo THM - Files: %@THM_Files% - Size: %@THM_Size%
if defined VMC_Path echo VMC - Files: %@VMC_Files% - Size: %@VMC_Size%
REM if defined POPSVMC_Path echo POPS-VMC - Files: %@POPSVMC_Files% POPS-VMC - Size: %@POPSVMC_Size%
echo\
echo\
echo         TOTAL - Files: !@Total_Files! 
echo         TOTAL - Size: !@Total_Size!

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Change default partition?
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
echo Detecting Partition: %OPLPART%
echo ----------------------------------------------------

	echo device !@hdl_path! > "%~dp0TMP\pfs-prt.txt"
	echo ls >> "%~dp0TMP\pfs-prt.txt"
	echo exit >> "%~dp0TMP\pfs-prt.txt"
	type "%~dp0TMP\pfs-prt.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" grep -o "%OPLPART%/" | "%~dp0BAT\busybox" head -1 > "%~dp0TMP\hdd-prt.txt"
	
	set /P @hdd_avl=<"%~dp0TMP\hdd-prt.txt"
	IF "!@hdd_avl!"=="%OPLPART%/" (
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
	echo device %@hdl_path% > "%~dp0TMP\pfs-apps.txt"
	echo mount %OPLPART% >> "%~dp0TMP\pfs-apps.txt"

	REM PARENT DIR (OPL\APPS)
    if defined CHOICEPART echo mkdir OPL >> "%~dp0TMP\pfs-apps.txt"
    if defined CHOICEPART echo cd OPL >> "%~dp0TMP\pfs-apps.txt"
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
	del "%~dp0TMP\pfs-apps.txt" >nul 2>&1
	echo         APPS Completed...	
	cd "%~dp0"
	) else ( echo         APPS - NOT DETECTED )
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
	echo device %@hdl_path% > "%~dp0TMP\pfs-art.txt"
	echo mount %OPLPART% >> "%~dp0TMP\pfs-art.txt"
    if defined CHOICEPART echo mkdir OPL >> "%~dp0TMP\pfs-art.txt"
    if defined CHOICEPART echo cd OPL >> "%~dp0TMP\pfs-art.txt"
	echo mkdir ART >> "%~dp0TMP\pfs-art.txt"
	echo cd ART >> "%~dp0TMP\pfs-art.txt"
	for %%f in (*) do (echo put "%%f") >> "%~dp0TMP\pfs-art.txt"
	echo ls -l >> "%~dp0TMP\pfs-art.txt"
	echo umount >> "%~dp0TMP\pfs-art.txt"
	echo exit >> "%~dp0TMP\pfs-art.txt"
	
	echo         Installing Que
	type "%~dp0TMP\pfs-art.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" grep -ie ".png" -ie ".jpg" > "%~dp0LOG\PFS-ART.log"
	del "%~dp0TMP\pfs-art.txt" >nul 2>&1
	echo         ART Completed...	
	cd "%~dp0"
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
	echo device %@hdl_path% > "%~dp0TMP\pfs-cfg.txt"
	echo mount %OPLPART% >> "%~dp0TMP\pfs-cfg.txt"
    if defined CHOICEPART echo mkdir OPL >> "%~dp0TMP\pfs-cfg.txt"
    if defined CHOICEPART echo cd OPL >> "%~dp0TMP\pfs-cfg.txt"
	echo mkdir CFG >> "%~dp0TMP\pfs-cfg.txt"
	echo cd CFG >> "%~dp0TMP\pfs-cfg.txt"
	for %%f in (*.cfg) do (echo put "%%f") >> "%~dp0TMP\pfs-cfg.txt"
	echo ls -l >> "%~dp0TMP\pfs-cfg.txt"
	echo umount >> "%~dp0TMP\pfs-cfg.txt"
	echo exit >> "%~dp0TMP\pfs-cfg.txt"
	
	echo         Installing Que
	type "%~dp0TMP\pfs-cfg.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" grep -ie ".*\.cfg$" > "%~dp0LOG\PFS-CFG.log"
	del "%~dp0TMP\pfs-cfg.txt" >nul 2>&1
	echo         CFG Completed...	
	cd "%~dp0"
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
	echo device %@hdl_path% > "%~dp0TMP\pfs-cht.txt"
	echo mount %OPLPART% >> "%~dp0TMP\pfs-cht.txt"
    if defined CHOICEPART echo mkdir OPL >> "%~dp0TMP\pfs-cht.txt"
    if defined CHOICEPART echo cd OPL >> "%~dp0TMP\pfs-cht.txt"
	echo mkdir CHT >> "%~dp0TMP\pfs-cht.txt"
	echo cd CHT >> "%~dp0TMP\pfs-cht.txt"
	for %%f in (*.cht) do (echo put "%%f") >> "%~dp0TMP\pfs-cht.txt"
	echo ls -l >> "%~dp0TMP\pfs-cht.txt"
	echo umount >> "%~dp0TMP\pfs-cht.txt"
	echo exit >> "%~dp0TMP\pfs-cht.txt"
	
	echo         Installing Que
	type "%~dp0TMP\pfs-cht.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" grep -ie ".*\.cht$" > "%~dp0LOG\PFS-CHT.log"
	del "%~dp0TMP\pfs-cht.txt" >nul 2>&1
	echo         CHT Completed...
	cd "%~dp0"
	) else ( echo         CHT - Source Not Detected... )
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
	echo device %@hdl_path% > "%~dp0TMP\pfs-vmc.txt"
	echo mount %OPLPART% >> "%~dp0TMP\pfs-vmc.txt"
    if defined CHOICEPART echo mkdir OPL >> "%~dp0TMP\pfs-vmc.txt"
    if defined CHOICEPART echo cd OPL >> "%~dp0TMP\pfs-vmc.txt"
	echo mkdir VMC >> "%~dp0TMP\pfs-vmc.txt"
	echo cd VMC >> "%~dp0TMP\pfs-vmc.txt"
	for %%f in (*.bin) do (echo put "%%f") >> "%~dp0TMP\pfs-vmc.txt"
	echo ls -l >> "%~dp0TMP\pfs-vmc.txt"
	echo umount >> "%~dp0TMP\pfs-vmc.txt"
	echo exit >> "%~dp0TMP\pfs-vmc.txt"
	
	echo         Installing Que
	type "%~dp0TMP\pfs-vmc.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" grep -ie ".*\.bin$" > "%~dp0LOG\PFS-VMC.log"
	del "%~dp0TMP\pfs-vmc.txt" >nul 2>&1
	echo         VMC Completed...	
	cd "%~dp0"
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

	echo device %@hdl_path% > "%~dp0TMP\pfs-thm.txt"
	echo mount %OPLPART% >> "%~dp0TMP\pfs-thm.txt"
    
	REM PARENT DIR (OPL\THM)
    if defined CHOICEPART echo mkdir OPL >> "%~dp0TMP\pfs-thm.txt"
    if defined CHOICEPART echo cd OPL >> "%~dp0TMP\pfs-thm.txt"
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
	del "%~dp0TMP\pfs-thm.txt" >nul 2>&1
	echo         THM Completed...	
	cd "%~dp0"
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

	echo device %@hdl_path% > "%~dp0TMP\pfs-popsmvc.txt"
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
	del "%~dp0TMP\pfs-popsmvc.txt" >nul 2>&1
	echo         POPS-VMC Completed...	
	cd "%~dp0"
	) else ( echo         POPS-VMC - Source Not Detected... )
)

if defined CHOICEPP (

    "%~dp0BAT\busybox" sed -i -e "s/\hdd_partition=.*/hdd_partition=/g; s/hdd_partition=/hdd_partition=%OPLPART%/g" "%~dp0HDD-OSD\__common\OPL\conf_hdd.cfg"
	cd "%~dp0HDD-OSD\__common\OPL"
    echo device %@hdl_path% > "%~dp0TMP\pfs-OPLCONFIG.txt"
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

"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning for Playstation 2 HDDs:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "Playstation 2 HDD"
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "Playstation 2 HDD" | "%~dp0BAT\busybox" grep -o "hdd[0-9]:\|hdd[0-9][0-9]:" > "%~dp0TMP\hdl-hdd.txt"
"%~dp0BAT\busybox" sed -i "s/hdd/\\\\.\\\PhysicalDrive/g; s/://g" "%~dp0TMP\hdl-hdd.txt"

set /P @hdl_path=<"%~dp0TMP\hdl-hdd.txt"
del "%~dp0TMP\hdl-hdd.txt" >nul 2>&1
IF "!@hdl_path!"=="" ( 
"%~dp0BAT\Diagbox" gd 0c
		echo         Playstation 2 HDD Not Detected
		echo         Drive Must Be Formatted First
		echo\
		echo\
"%~dp0BAT\Diagbox" gd 07
		rmdir /Q/S "%~dp0TMP" >nul 2>&1
		pause & (goto mainmenu)
	)

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Transfer VCD:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1) Yes
"%~dp0BAT\Diagbox" gd 0c
echo         2) No
"%~dp0BAT\Diagbox" gd 0e
echo         3) Yes (Manually choose the partition where you want to install your .VCDs)
echo         4) Yes (Install .VCD as partition for HDD-OSD, PSBBN, XMB Menu)
echo\
"%~dp0BAT\Diagbox" gd 07
CHOICE /C 1234 /M "Select Option:"

IF %ERRORLEVEL%==1 set @pfs_pop=yes & set "choice=" & set popspartinstall=__.POPS
IF %ERRORLEVEL%==2 (goto mainmenu)
IF %ERRORLEVEL%==3 set @pfs_popmanually=yes
IF %ERRORLEVEL%==4 set @pfs_popHDDOSDMAIN=yes & (goto TransferPS1GamesHDDOSD)
 
IF !@pfs_popmanually!==yes (
echo.
echo Choose the partition on which you want to install your .VCDs
echo By default it will be the partition __.POPS
echo.
echo 0.  __.POPS0
echo 1.  __.POPS1
echo 2.  __.POPS2
echo 3.  __.POPS3
echo 4.  __.POPS4
echo 5.  __.POPS5
echo 6.  __.POPS6
echo 7.  __.POPS7
echo 8.  __.POPS8
echo 9.  __.POPS9
echo 10. __.POPS
echo.

set choice=
set /p choice="Select Option:"
IF "!choice!"=="" set "@pfs_popmanually=" & (goto TransferPS1Games)

IF "!choice!"=="!choice!" set @pfs_pop=yes & set popspartinstall=__.POPS!choice!
IF "!choice!"=="10" set @pfs_pop=yes & set "choice=" & set popspartinstall=__.POPS
)

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

echo VCD - Files: !@POPS_Files! - Size: !@POPS_Size!
echo\

echo         TOTAL - Files: !@POPS_Files!
echo         TOTAL - Size: !@POPS_Size!

) else ( echo          .VCD - NOT DETECTED IN POPS FOLDER & echo\ & echo\ & pause & goto mainmenu )

"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Detecting POPS Partition:
echo ----------------------------------------------------

    echo device !@hdl_path! > "%~dp0TMP\pfs-prt.txt"
    echo ls >> "%~dp0TMP\pfs-prt.txt"
    echo exit >> "%~dp0TMP\pfs-prt.txt"
    type "%~dp0TMP\pfs-prt.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" grep -o "!popspartinstall!/" | "%~dp0BAT\busybox" head -1 > "%~dp0TMP\hdd-prt.txt"

    set /P @hdd_avl=<"%~dp0TMP\hdd-prt.txt"
    IF "!@hdd_avl!"=="!popspartinstall!/" (
    "%~dp0BAT\Diagbox" gd 0a
	echo          __.POPS!choice! - Partition Detected
	"%~dp0BAT\Diagbox" gd 07
	) else (
	"%~dp0BAT\Diagbox" gd 0c
	echo           __.POPS!choice! - Partition NOT Detected
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
"%~dp0BAT\Diagbox" gd 07

if exist "%~dp0POPS-Binaries\Hugopocked_POPStarter_Fixes.zip" "%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0POPS-Binaries\Hugopocked_POPStarter_Fixes.zip" -o"%~dp0TMP" id.txt -r -y
IF /I EXIST "%~dp0POPS\*.VCD" (

    setlocal DisableDelayedExpansion
	cd "%~dp0POPS" & rename "*.vcd" "*.VCD"
	for %%f in (*.VCD) do (
	
	set "cheats="
	set fname=%%~nf
	if exist CHEATS.TXT del CHEATS.TXT
	if exist TROJAN_0.BIN del TROJAN_0.BIN


echo\
echo\
echo Installing "%%f":
echo ----------------------------------------------------
echo\

	REM echo         Creating Que
	echo device %@hdl_path% > "%~dp0TMP\pfs-pops.txt"
	echo mount %popspartinstall% >> "%~dp0TMP\pfs-pops.txt"
	
	setlocal EnableDelayedExpansion
	"%~dp0BAT\POPS-VCD-ID-Extractor" "!fname!.VCD" | "%~dp0BAT\busybox" sed -e "s/-/_/g" > "%~dp0TMP\VCDID.txt" & set /p VCDID=<"%~dp0TMP\VCDID.txt"
	REM echo         Checking if the game has a need patch GameShark...
	findstr !VCDID! "%~dp0TMP\id.txt" >nul 2>&1
    if errorlevel 1 (
    REM echo         No need patch
    ) else (
	set cheats=yes
	"%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0POPS-Binaries\Hugopocked_POPStarter_Fixes.zip" -o"%~dp0TMP" !VCDID!\CHEATS.TXT -r -y & move "%~dp0TMP\!VCDID!\CHEATS.TXT" "%~dp0POPS\CHEATS.TXT" >nul 2>&1
	"%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0POPS-Binaries\Hugopocked_POPStarter_Fixes.zip" -o"%~dp0TMP" !VCDID!\TROJAN_0.BIN -r -y & move "%~dp0TMP\!VCDID!\TROJAN_0.BIN" "%~dp0POPS\TROJAN_0.BIN" >nul 2>&1
	"%~dp0BAT\busybox" md5sum "!fname!.VCD" | "%~dp0BAT\busybox" grep -o "[0-9a-f]\{32\}" > "%~dp0TMP\MD5.txt" & set /p MD5=<"%~dp0TMP\MD5.txt"
	"%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0POPS-Binaries\Hugopocked_POPStarter_Fixes.zip" -o"%~dp0TMP" !VCDID!\!MD5!\CHEATS.TXT -r -y & move "%~dp0TMP\!VCDID!\!MD5!\CHEATS.TXT" "%~dp0POPS" >nul 2>&1
	"%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0POPS-Binaries\Hugopocked_POPStarter_Fixes.zip" -o"%~dp0TMP" !VCDID!\!MD5!\TROJAN_0.BIN -r -y & move "%~dp0TMP\!VCDID!\!MD5!\TROJAN_0.BIN" "%~dp0POPS" >nul 2>&1
	REM echo         Patch GameShark...
	)
	
	echo         Installing...
	echo put "!fname!.VCD" >> "%~dp0TMP\pfs-pops.txt"
	echo ls -l >> "%~dp0TMP\pfs-pops.txt"
	echo umount >> "%~dp0TMP\pfs-pops.txt"
	echo mount __common >> "%~dp0TMP\pfs-pops.txt"
	echo mkdir POPS >> "%~dp0TMP\pfs-pops.txt"
	echo cd POPS >> "%~dp0TMP\pfs-pops.txt"
	echo mkdir "!fname!" >> "%~dp0TMP\pfs-pops.txt"
	echo cd "!fname!" >> "%~dp0TMP\pfs-pops.txt"
    if defined cheats echo         Patch GameShark...
    if defined cheats echo put "CHEATS.TXT" >> "%~dp0TMP\pfs-pops.txt"
	if defined cheats echo put "TROJAN_0.BIN" >> "%~dp0TMP\pfs-pops.txt"
	echo umount >> "%~dp0TMP\pfs-pops.txt"
	echo exit >> "%~dp0TMP\pfs-pops.txt"
	type "%~dp0TMP\pfs-pops.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" grep -ie ".*\.VCD$" > "%~dp0LOG\PFS-POPS%choice%.log"
	echo         Completed...
    cd "%~dp0"
    endlocal
 )
) else ( echo         .VCD - NOT DETECTED )

endlocal
rmdir /Q/S "%~dp0TMP" >nul 2>&1
del "%~dp0POPS\CHEATS.TXT" >nul 2>&1
del "%~dp0POPS\TROJAN_0.BIN" >nul 2>&1

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
:BackupARTCFGCHTVMC

cd "%~dp0"
cls
rmdir /Q/S "%~dp0TMP" >nul 2>&1
md "%~dp0TMP" >nul 2>&1

"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning for Playstation 2 HDDs:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "Playstation 2 HDD"
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "Playstation 2 HDD" | "%~dp0BAT\busybox" grep -o "hdd[0-9]:\|hdd[0-9][0-9]:" > "%~dp0TMP\hdl-hdd.txt"
"%~dp0BAT\busybox" sed -i "s/hdd/\\\\.\\\PhysicalDrive/g; s/://g" "%~dp0TMP\hdl-hdd.txt"

set /P @hdl_path=<"%~dp0TMP\hdl-hdd.txt"
del "%~dp0TMP\hdl-hdd.txt" >nul 2>&1
IF "!@hdl_path!"=="" ( 
"%~dp0BAT\Diagbox" gd 0c
		echo         Playstation 2 HDD Not Detected
		echo         Drive Must Be Formatted First
		echo\
		echo\
"%~dp0BAT\Diagbox" gd 07
		rmdir /Q/S "%~dp0TMP" >nul 2>&1
		pause & (goto mainmenu)
	)

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Extract Artwork:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1) Yes
"%~dp0BAT\Diagbox" gd 0c
echo         2) No
"%~dp0BAT\Diagbox" gd 07
echo\
CHOICE /C 12 /M "Select Option:"

IF %ERRORLEVEL%==1 set @pfs_art=yes
IF %ERRORLEVEL%==2 set @pfs_art=no

echo\
echo\
echo Extract Configs:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1) Yes
"%~dp0BAT\Diagbox" gd 0c
echo         2) No
"%~dp0BAT\Diagbox" gd 07
echo\
CHOICE /C 12 /M "Select Option:"

IF %ERRORLEVEL%==1 set @pfs_cfg=yes
IF %ERRORLEVEL%==2 set @pfs_cfg=no

echo\
echo\
echo Extract Cheats:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1) Yes
"%~dp0BAT\Diagbox" gd 0c
echo         2) No
"%~dp0BAT\Diagbox" gd 07
echo\
CHOICE /C 12 /M "Select Option:"

IF %ERRORLEVEL%==1 set @pfs_cht=yes
IF %ERRORLEVEL%==2 set @pfs_cht=no

echo\
echo\
echo Extract OPL VMCs:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1) Yes
"%~dp0BAT\Diagbox" gd 0c
echo         2) No
"%~dp0BAT\Diagbox" gd 07
echo\
CHOICE /C 12 /M "Select Option:"

IF %ERRORLEVEL%==1 set @pfs_vmc=yes
IF %ERRORLEVEL%==2 set @pfs_vmc=no

echo\
echo\
echo Extract POPS VMCs:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1) Yes
"%~dp0BAT\Diagbox" gd 0c
echo         2) No
echo\
"%~dp0BAT\Diagbox" gd 07
CHOICE /C 12 /M "Select Option:"

IF %ERRORLEVEL%==1 set @pfs_popvmc=yes
IF %ERRORLEVEL%==2 set @pfs_popvmc=no

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Change default partition?
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
echo Detecting %OPLPART% Partition:
echo ----------------------------------------------------

	echo device !@hdl_path! > "%~dp0TMP\pfs-prt.txt"
	echo ls >> "%~dp0TMP\pfs-prt.txt"
	echo exit >> "%~dp0TMP\pfs-prt.txt"
	type "%~dp0TMP\pfs-prt.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" grep -o "%OPLPART%/" | "%~dp0BAT\busybox" head -1 > "%~dp0TMP\hdd-prt.txt"
	
	set /P @hdd_avl=<"%~dp0TMP\hdd-prt.txt"
	IF "!@hdd_avl!"=="%OPLPART%/" (
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

IF %@pfs_art%==yes (

echo\
echo\
echo Extraction Artwork:
echo ----------------------------------------------------
echo\

    IF NOT EXIST "%~dp0ART" MD "%~dp0ART"
	cd "%~dp0TMP"
    echo         Files scan...
	echo device %@hdl_path% > "%~dp0TMP\pfs-log.txt"
	echo mount %OPLPART% >> "%~dp0TMP\pfs-log.txt"
	if defined CHOICEPART echo cd OPL >> "%~dp0TMP\pfs-log.txt"
	echo cd ART >> "%~dp0TMP\pfs-log.txt"
	echo ls >> "%~dp0TMP\pfs-log.txt"
    echo umount >> "%~dp0TMP\pfs-log.txt"
	echo exit >> "%~dp0TMP\pfs-log.txt"
	type "%~dp0TMP\pfs-log.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" grep -ie ".png" -ie ".jpg" > "%~dp0TMP\pfs-tmp.log"

	echo         Extraction...
	echo device %@hdl_path% > "%~dp0TMP\pfs-art.txt"
	echo mount %OPLPART% >> "%~dp0TMP\pfs-art.txt"
	if defined CHOICEPART echo cd OPL >> "%~dp0TMP\pfs-art.txt"
	echo cd ART >> "%~dp0TMP\pfs-art.txt"
	echo lcd "%~dp0ART" >> "%~dp0TMP\pfs-art.txt"
	for /f "tokens=*" %%f in (pfs-tmp.log) do (echo get "%%f" >> "%~dp0TMP\pfs-art.txt")
	echo umount >> "%~dp0TMP\pfs-art.txt"
	echo exit >> "%~dp0TMP\pfs-art.txt"
	type "%~dp0TMP\pfs-art.txt" | "%~dp0BAT\pfsshell" >nul 2>&1
	echo         Completed...
	cd "%~dp0"
	)

IF %@pfs_cfg%==yes (

echo\
echo\
echo Extraction Configs Files:
echo ----------------------------------------------------
echo\

    IF NOT EXIST "%~dp0CFG" MD "%~dp0CFG"
	cd "%~dp0TMP"
    echo         Files scan...
	echo device %@hdl_path% > "%~dp0TMP\pfs-log.txt"
	echo mount %OPLPART% >> "%~dp0TMP\pfs-log.txt"
	if defined CHOICEPART echo cd OPL >> "%~dp0TMP\pfs-log.txt"
	echo cd CFG >> "%~dp0TMP\pfs-log.txt"
	echo ls >> "%~dp0TMP\pfs-log.txt"
    echo umount >> "%~dp0TMP\pfs-log.txt"
	echo exit >> "%~dp0TMP\pfs-log.txt"
	type "%~dp0TMP\pfs-log.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" grep -ie ".*\.cfg$" > "%~dp0TMP\pfs-tmp.log"
	
	echo         Extraction...
	echo device %@hdl_path% > "%~dp0TMP\pfs-cfg.txt"
	echo mount %OPLPART% >> "%~dp0TMP\pfs-cfg.txt"
	if defined CHOICEPART echo cd OPL >> "%~dp0TMP\pfs-cfg.txt"
	echo cd CFG >> "%~dp0TMP\pfs-cfg.txt"
	echo lcd "%~dp0CFG" >> "%~dp0TMP\pfs-cfg.txt"
	for /f "tokens=*" %%f in (pfs-tmp.log) do (echo get "%%f" >> "%~dp0TMP\pfs-cfg.txt")
	echo umount >> "%~dp0TMP\pfs-cfg.txt"
	echo exit >> "%~dp0TMP\pfs-cfg.txt"
	type "%~dp0TMP\pfs-cfg.txt" | "%~dp0BAT\pfsshell" >nul 2>&1
	echo         Completed...
	cd "%~dp0"
	)

IF %@pfs_cht%==yes (

echo\
echo\
echo Extraction Cheat Files:
echo ----------------------------------------------------
echo\
    
	IF NOT EXIST "%~dp0CHT" MD "%~dp0CHT"
	cd "%~dp0TMP"
    echo         Files scan...
	echo device %@hdl_path% > "%~dp0TMP\pfs-log.txt"
	echo mount %OPLPART% >> "%~dp0TMP\pfs-log.txt"
	if defined CHOICEPART echo cd OPL >> "%~dp0TMP\pfs-log.txt"
	echo cd CHT >> "%~dp0TMP\pfs-log.txt"
	echo ls >> "%~dp0TMP\pfs-log.txt"
    echo umount >> "%~dp0TMP\pfs-log.txt"
	echo exit >> "%~dp0TMP\pfs-log.txt"
	type "%~dp0TMP\pfs-log.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" grep -ie ".*\.cht$" > "%~dp0TMP\pfs-tmp.log"

	echo         Extraction...
	echo device %@hdl_path% > "%~dp0TMP\pfs-cht.txt"
	echo mount %OPLPART% >> "%~dp0TMP\pfs-cht.txt"
	if defined CHOICEPART echo cd OPL >> "%~dp0TMP\pfs-cht.txt"
	echo cd CHT >> "%~dp0TMP\pfs-cht.txt"
	echo lcd "%~dp0CHT" >> "%~dp0TMP\pfs-cht.txt"
	for /f "tokens=*" %%f in (pfs-tmp.log) do (echo get "%%f" >> "%~dp0TMP\pfs-cht.txt")
	echo umount >> "%~dp0TMP\pfs-cht.txt"
	echo exit >> "%~dp0TMP\pfs-cht.txt"
	type "%~dp0TMP\pfs-cht.txt" | "%~dp0BAT\pfsshell" >nul 2>&1
	echo         Completed...
	cd "%~dp0"
	)

IF %@pfs_vmc%==yes (

echo\
echo\
echo Extraction OPL Virtual Memory Card Files:
echo ----------------------------------------------------
echo\

    IF NOT EXIST "%~dp0VMC" MD "%~dp0VMC"
	cd "%~dp0TMP"
    echo         Files scan...
	echo device %@hdl_path% > "%~dp0TMP\pfs-log.txt"
	echo mount %OPLPART% >> "%~dp0TMP\pfs-log.txt"
	if defined CHOICEPART echo cd OPL >> "%~dp0TMP\pfs-log.txt"
	echo cd VMC >> "%~dp0TMP\pfs-log.txt"
	echo ls >> "%~dp0TMP\pfs-log.txt"
	echo umount >> "%~dp0TMP\pfs-log.txt"
	echo exit >> "%~dp0TMP\pfs-log.txt"
	type "%~dp0TMP\pfs-log.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" grep -ie ".*\.bin$" > "%~dp0TMP\pfs-tmp.log"
	
	echo         Extraction...
	echo device %@hdl_path% > "%~dp0TMP\pfs-vmc.txt"
	echo mount %OPLPART% >> "%~dp0TMP\pfs-vmc.txt"
	if defined CHOICEPART echo cd OPL >> "%~dp0TMP\pfs-vmc.txt"
	echo cd VMC >> "%~dp0TMP\pfs-vmc.txt"
	echo lcd "%~dp0VMC" >> "%~dp0TMP\pfs-vmc.txt"
	for /f "tokens=*" %%f in (pfs-tmp.log) do (echo get "%%f" >> "%~dp0TMP\pfs-vmc.txt")
	echo umount >> "%~dp0TMP\pfs-vmc.txt"
	echo exit >> "%~dp0TMP\pfs-vmc.txt"
	type "%~dp0TMP\pfs-vmc.txt" | "%~dp0BAT\pfsshell" >nul 2>&1
	echo         Completed...
	cd "%~dp0"
	)

IF %@pfs_popvmc%==yes (

echo\
echo\
echo Extraction POPS Virtual Memory Card Files:
echo ----------------------------------------------------
echo\

    IF NOT EXIST "%~dp0POPS\VMC" MD "%~dp0POPS\VMC"
	cd "%~dp0TMP"
	echo         Files scan...
	echo device %@hdl_path% > "%~dp0TMP\pfs-popsvmc.txt"
	echo mount __common >> "%~dp0TMP\pfs-popsvmc.txt"
	echo cd POPS >> "%~dp0TMP\pfs-popsvmc.txt"
	echo ls -l >> "%~dp0TMP\pfs-popsvmc.txt"
	echo umount >> "%~dp0TMP\pfs-popsvmc.txt"
	echo exit >> "%~dp0TMP\pfs-popsvmc.txt"
	type "%~dp0TMP\pfs-popsvmc.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" grep -i -e "drwx" | "%~dp0BAT\busybox" sed -e "1,2d" | "%~dp0BAT\busybox" cut -c42-500 | "%~dp0BAT\busybox" sed -e "s/\///g" > "%~dp0TMP\pfs-tmp.log"
	
    echo         Extraction...
	for /f "tokens=*" %%f in (pfs-tmp.log) do (
	if not exist "%~dp0POPS\VMC\%%f" mkdir "%~dp0POPS\VMC\%%f"
    echo device %@hdl_path% > "%~dp0TMP\pfs-popsvmc.txt"
    echo mount __common >> "%~dp0TMP\pfs-popsvmc.txt"
    echo cd POPS >> "%~dp0TMP\pfs-popsvmc.txt"
	echo cd "%%f" >> "%~dp0TMP\pfs-popsvmc.txt"
	echo ls -l >> "%~dp0TMP\pfs-popsvmc.txt"
	echo cd .. >> "%~dp0TMP\pfs-popsvmc.txt"
	echo umount >> "%~dp0TMP\pfs-popsvmc.txt"
    echo exit >> "%~dp0TMP\pfs-popsvmc.txt"
	type "%~dp0TMP\pfs-popsvmc.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" grep -ie "-rw-" | "%~dp0BAT\busybox" cut -c42-500 > "%~dp0TMP\pfs-popsvmcfiles.txt" 

	for /f "tokens=*" %%v in (pfs-popsvmcfiles.txt) do (
    echo device %@hdl_path% > "%~dp0TMP\pfs-popsvmc.txt"
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

cd "%~dp0" & rmdir /Q/S "%~dp0TMP" >nul 2>&1

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
cd "%~dp0"
mkdir "%~dp0TMP" >nul 2>&1

"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning for Playstation 2 HDDs:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "Playstation 2 HDD"
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "Playstation 2 HDD" | "%~dp0BAT\busybox" grep -o "hdd[0-9]:\|hdd[0-9][0-9]:" > "%~dp0TMP\hdl-hdd.txt"
"%~dp0BAT\busybox" sed -i "s/hdd/\\\\.\\\PhysicalDrive/g; s/://g" "%~dp0TMP\hdl-hdd.txt"

set /P @hdl_path=<"%~dp0TMP\hdl-hdd.txt"
del "%~dp0TMP\hdl-hdd.txt" >nul 2>&1
IF "!@hdl_path!"=="" ( 
"%~dp0BAT\Diagbox" gd 0c
		echo         Playstation 2 HDD Not Detected
		echo         Drive Must Be Formatted First
		echo\
		echo\
"%~dp0BAT\Diagbox" gd 07
		rmdir /Q/S "%~dp0TMP" >nul 2>&1
		pause & (goto mainmenu)
	)

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Extract All .VCD:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1) Yes
"%~dp0BAT\Diagbox" gd 0c
echo         2) No
"%~dp0BAT\Diagbox" gd 0e
echo         3) Yes (Manually Choose the partition where your .VCDs to extract are located.)
echo         4) Yes (Manually Choose your .VCD)
echo\
"%~dp0BAT\Diagbox" gd 07
CHOICE /C 1234 /M "Select Option:"

IF %ERRORLEVEL%==1 set "@pfs_pop=yes" & set "choice=" & set popspartextract=__.POPS
IF %ERRORLEVEL%==2 (goto mainmenu)
IF %ERRORLEVEL%==3 set "@pfs_popmanually=yes" & set @pfs_pop=yes
IF %ERRORLEVEL%==4 set "@pfs_popmanuallyVCD=yes" & set @pfs_popmanually=yes
IF %ERRORLEVEL%==5 (goto BackupPS1GamesPFSPart)

IF !@pfs_popmanually!==yes (
echo.
echo Choose the partition where your .VCDs to extract are located.
echo By default it will be the partition __.POPS
echo.
echo 0.  __.POPS0
echo 1.  __.POPS1
echo 2.  __.POPS2
echo 3.  __.POPS3
echo 4.  __.POPS4
echo 5.  __.POPS5
echo 6.  __.POPS6
echo 7.  __.POPS7
echo 8.  __.POPS8
echo 9.  __.POPS9
echo 10. __.POPS
echo.

set choice=
set /p choice="Select Option:"
IF "!choice!"=="" set "@pfs_popmanually=" & (goto BackupPS1Games)

IF "!choice!"=="!choice!" set popspartextract=__.POPS!choice!
IF "!choice!"=="10" set "choice=" & set popspartextract=__.POPS

IF "!@pfs_popmanuallyVCD!"=="yes" set "@pfs_popmanually="

)

"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Detecting POPS Partition:
echo ----------------------------------------------------

    echo device !@hdl_path! > "%~dp0TMP\pfs-prt.txt"
    echo ls >> "%~dp0TMP\pfs-prt.txt"
    echo exit >> "%~dp0TMP\pfs-prt.txt"
    type "%~dp0TMP\pfs-prt.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" grep -o "%popspartextract%/" | "%~dp0BAT\busybox" head -1 > "%~dp0TMP\hdd-prt.txt"
    
	set /P @hdd_avl=<"%~dp0TMP\hdd-prt.txt"
    IF "!@hdd_avl!"=="%popspartextract%/" (
    "%~dp0BAT\Diagbox" gd 0a
    echo       __.POPS!choice! - Partition Detected
	"%~dp0BAT\Diagbox" gd 07
	) else (
	"%~dp0BAT\Diagbox" gd 0c
	echo       __.POPS!choice! - Partition NOT Detected
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

if defined @pfs_popmanuallyVCD (
"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning Games List in %popspartextract%:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 07

    echo device !@hdl_path! > "%~dp0TMP\pfs-prt.txt"
	echo mount %popspartextract% >> "%~dp0TMP\pfs-prt.txt"
    echo ls >> "%~dp0TMP\pfs-prt.txt"
    echo exit >> "%~dp0TMP\pfs-prt.txt"
    type "%~dp0TMP\pfs-prt.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" grep -ie ".*\.VCD$" | "%~dp0BAT\busybox" sed -e "s/\.[^.]*$//" > "%~dp0TMP\%popspartextract%.txt"
    type "%~dp0TMP\%popspartextract%.txt"

"%~dp0BAT\Diagbox" gd 0e
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 07

echo\
"%~dp0BAT\Diagbox" gd 06
echo Respect upper and lower case
"%~dp0BAT\Diagbox" gd 07
set /p NameVCD=Enter The Game Name:
IF "!NameVCD!"=="" set "@pfs_popmanuallyVCD=" & (goto BackupPS1Games)
)

setlocal DisableDelayedExpansion
cls
echo\
echo\
echo Extraction of VCD..
echo ----------------------------------------------------
echo\

    cd "%~dp0TMP"
    echo         Files scan...
	echo device %@hdl_path% > "%~dp0TMP\pfs-log.txt"
	echo mount %popspartextract% >> "%~dp0TMP\pfs-log.txt"
	echo ls >> "%~dp0TMP\pfs-log.txt"
	echo umount >> "%~dp0TMP\pfs-log.txt"
	echo exit >> "%~dp0TMP\pfs-log.txt"
	type "%~dp0TMP\pfs-log.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" grep -ie ".*\.VCD$" > "%~dp0TMP\pfs-tmp.log"

	echo         Extraction...
	echo device %@hdl_path% > "%~dp0TMP\pfs-pops.txt"
	echo mount %popspartextract% >> "%~dp0TMP\pfs-pops.txt"
	echo lcd "%~dp0POPS" >> "%~dp0TMP\pfs-pops.txt"
	if defined @pfs_pop for /f "tokens=*" %%f in (pfs-tmp.log) do (echo get "%%f" >> "%~dp0TMP\pfs-pops.txt")
	if defined @pfs_popmanuallyVCD echo rename "%NameVCD%.vcd" "%NameVCD%.VCD" >> "%~dp0TMP\pfs-pops.txt"
	if defined @pfs_popmanuallyVCD echo get "%NameVCD%.VCD" >> "%~dp0TMP\pfs-pops.txt"
	echo umount >> "%~dp0TMP\pfs-pops.txt"
	echo exit >> "%~dp0TMP\pfs-pops.txt"
	type "%~dp0TMP\pfs-pops.txt" | "%~dp0BAT\pfsshell" >nul 2>&1
    echo         Completed...
	cd "%~dp0"

rmdir /Q/S "%~dp0TMP" >nul 2>&1

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
:TransferPOPSBinaries

cls
mkdir "%~dp0TMP" >nul 2>&1
cd "%~dp0"

"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning for Playstation 2 HDDs:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "Playstation 2 HDD"
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "Playstation 2 HDD" | "%~dp0BAT\busybox" grep -o "hdd[0-9]:\|hdd[0-9][0-9]:" > "%~dp0TMP\hdl-hdd.txt"
"%~dp0BAT\busybox" sed -i "s/hdd/\\\\.\\\PhysicalDrive/g; s/://g" "%~dp0TMP\hdl-hdd.txt"

set /P @hdl_path=<"%~dp0TMP\hdl-hdd.txt"
del "%~dp0TMP\hdl-hdd.txt" >nul 2>&1
IF "!@hdl_path!"=="" ( 
"%~dp0BAT\Diagbox" gd 0c
		echo         Playstation 2 HDD Not Detected
		echo         Drive Must Be Formatted First
		echo\
		echo\
"%~dp0BAT\Diagbox" gd 07
		rmdir /Q/S "%~dp0TMP" >nul 2>&1
		pause & (goto mainmenu)
	)
	
"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Transfer POPS Binaries:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1) Yes
"%~dp0BAT\Diagbox" gd 0c
echo         2) No
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

    echo device !@hdl_path! > "%~dp0TMP\pfs-prt.txt"
    echo ls >> "%~dp0TMP\pfs-prt.txt"
    echo exit >> "%~dp0TMP\pfs-prt.txt"
    type "%~dp0TMP\pfs-prt.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" grep -o "__common/" | "%~dp0BAT\busybox" head -1 > "%~dp0TMP\hdd-prt.txt"

	set /P @hdd_avl=<"%~dp0TMP\hdd-prt.txt"
    IF "!@hdd_avl!"=="__common/" (
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
	echo device !@hdl_path! > "%~dp0TMP\pfs-pops-binaries.txt"
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

REM POPS FOR OPL APPS
REM 	echo device !@hdl_path! > "%~dp0TMP\pfs-pops-binaries.txt"
REM 	echo mount +OPL >> "%~dp0TMP\pfs-pops-binaries.txt"
REM 	echo mkdir POPS >> "%~dp0TMP\pfs-pops-binaries.txt"
REM 	echo cd POPS >> "%~dp0TMP\pfs-pops-binaries.txt"
REM 	for %%g in (POPSTARTER.ELF) do (echo put "%%g") >> "%~dp0TMP\pfs-pops-binaries.txt"
REM 	echo umount >> "%~dp0TMP\pfs-pops-binaries.txt"
REM 	echo exit >> "%~dp0TMP\pfs-pops-binaries.txt"
REM REM	echo         Installing Que
REM 	type "%~dp0TMP\pfs-pops-binaries.txt" | "%~dp0BAT\pfsshell" >nul 2>&1
REM 	cd "%~dp0"
 	) else ( echo         POPS Binaries - Source Not Detected... )
)

rmdir /Q/S "%~dp0TMP" >nul 2>&1

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

"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning for Playstation 2 HDDs:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "Playstation 2 HDD"
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "Playstation 2 HDD" | "%~dp0BAT\busybox" grep -o "hdd[0-9]:\|hdd[0-9][0-9]:" > "%~dp0TMP\hdl-hdd.txt"

set /P @hdl_path=<"%~dp0TMP\hdl-hdd.txt"
del "%~dp0TMP\hdl-hdd.txt" >nul 2>&1
IF "!@hdl_path!"=="" (
"%~dp0BAT\Diagbox" gd 0c
		echo         Playstation 2 HDD Not Detected
		echo         Drive Must Be Formatted First
		echo\
		echo\
"%~dp0BAT\Diagbox" gd 07
		rmdir /Q/S "%~dp0TMP" >nul 2>&1
		pause & (goto mainmenu)
	)

echo\
echo\
"%~dp0BAT\Diagbox" gd 0f
echo Extract All .ISO ?
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1) Yes
"%~dp0BAT\Diagbox" gd 0c
echo         2) No
"%~dp0BAT\Diagbox" gd 0e
echo         3) Yes (Manually choose the game)
echo\
"%~dp0BAT\Diagbox" gd 07
echo\
CHOICE /C 123 /M "Select Option:"

IF %ERRORLEVEL%==1 set BackupPS2AllGames=yes
IF %ERRORLEVEL%==2 (goto Mainmenu)
IF %ERRORLEVEL%==3 set BackupPS2GamesManually=yes

"%~dp0BAT\Diagbox" gd 0e
cls
echo\
echo\
echo Scanning Games List:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03

"%~dp0BAT\hdl_dump" hdl_toc %@hdl_path% > "%~dp0TMP\PARTITION_GAMES.txt"

"%~dp0BAT\busybox" sed -i "1d" "%~dp0TMP\PARTITION_GAMES.txt"
"%~dp0BAT\busybox" sed -i -e "$ d" "%~dp0TMP\PARTITION_GAMES.txt"
"%~dp0BAT\busybox" cut -c35-500 "%~dp0TMP\PARTITION_GAMES.txt" | "%~dp0BAT\busybox" sort -k2 > "%~dp0TMP\PARTITION_GAMES_NEW.txt"

type "%~dp0TMP\PARTITION_GAMES_NEW.txt"
"%~dp0BAT\Diagbox" gd 0e
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03

if !BackupPS2AllGames!==yes (
    
	setlocal DisableDelayedExpansion
   "%~dp0BAT\busybox" cat "%~dp0TMP\PARTITION_GAMES_NEW.txt" | "%~dp0BAT\busybox" cut -c14-500 > "%~dp0TMP\PARTITION_GAMES_NEW2.txt"
   "%~dp0BAT\busybox" sed -i "s/\"//g" "%~dp0TMP\PARTITION_GAMES_NEW2.txt"
   "%~dp0BAT\busybox" sed -i "s/:/-/g; s/?//g; s/\\//g; s/\///g; s/\*//g; s/>//g; s/<//g" "%~dp0TMP\PARTITION_GAMES_NEW2.txt"
   "%~dp0BAT\busybox" sed -i "s/|//g" "%~dp0TMP\PARTITION_GAMES_NEW2.txt"
   
   "%~dp0BAT\busybox" sed -i "s/^/;/" "%~dp0TMP\PARTITION_GAMES_NEW2.txt"
   "%~dp0BAT\busybox" paste -d " " "%~dp0TMP\PARTITION_GAMES_NEW.txt" "%~dp0TMP\PARTITION_GAMES_NEW2.txt" > "%~dp0TMP\PARTITION_GAMES_NEW3.txt"
   "%~dp0BAT\busybox" cut -c14-500 "%~dp0TMP\PARTITION_GAMES_NEW3.txt" > "%~dp0TMP\PARTITION_GAMES_NEW4.txt"
   "%~dp0BAT\busybox" sed -i "s/ ;/;/g" "%~dp0TMP\PARTITION_GAMES_NEW4.txt"
   
   for /f "tokens=1* delims=;" %%f in (PARTITION_GAMES_NEW4.txt) do (
   echo\
   echo %%f
   "%~dp0BAT\hdl_dump.exe" extract %@hdl_path% "%%f" "%~dp0CD-DVD\%%g".iso
   echo\
   ren *. *.iso >nul 2>&1
     )
   )

if !BackupPS2GamesManually!==yes (

   echo\
   set /p gamename=Enter the Game Name:
   if "!gamename!"=="" (goto mainmenu)
   
   "%~dp0BAT\busybox" grep -m 1 -o "!gamename!" "%~dp0TMP\PARTITION_GAMES.txt" > "%~dp0TMP\gamename2.txt"
   "%~dp0BAT\busybox" sed -i "s/\"//g" "%~dp0TMP\gamename2.txt"
   "%~dp0BAT\busybox" sed -i "s/:/-/g; s/?//g; s/\\//g; s/\///g; s/\*//g; s/>//g; s/<//g" "%~dp0TMP\gamename2.txt"
   "%~dp0BAT\busybox" sed -i "s/|//g" "%~dp0TMP\gamename2.txt"
   set /P gamename2=<"%~dp0TMP\gamename2.txt"
  
  "%~dp0BAT\hdl_dump.exe" extract %@hdl_path% "!gamename!" "%~dp0CD-DVD\!gamename2!.iso"
  
   echo\
   echo\
   echo Extracted.. "\CD-DVD\!gamename!.iso"
   ren *. *.iso >nul 2>&1
   )
   
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

endlocal
pause & (goto mainmenu)

REM ####################################################################################################################################################
:CreatePART

cls
mkdir "%~dp0TMP" >nul 2>&1

"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning for Playstation 2 HDDs:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "Playstation 2 HDD"
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "Playstation 2 HDD" | "%~dp0BAT\busybox" grep -o "hdd[0-9]:\|hdd[0-9][0-9]:" > "%~dp0TMP\hdl-hdd.txt"
"%~dp0BAT\busybox" sed -i "s/hdd/\\\\.\\\PhysicalDrive/g; s/://g" "%~dp0TMP\hdl-hdd.txt"

set /P @hdl_path=<"%~dp0TMP\hdl-hdd.txt"
del "%~dp0TMP\hdl-hdd.txt" >nul 2>&1
IF "!@hdl_path!"=="" ( 
"%~dp0BAT\Diagbox" gd 0c
		echo         Playstation 2 HDD Not Detected
		echo         Drive Must Be Formatted First
		echo\
		echo\
"%~dp0BAT\Diagbox" gd 07
		rmdir /Q/S "%~dp0TMP" >nul 2>&1
        pause & (goto HDDManagementMenu)
	)

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Create Partition:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1) Yes
"%~dp0BAT\Diagbox" gd 0c
echo         2) No
"%~dp0BAT\Diagbox" gd 07
echo\
CHOICE /C 12 /M "Select Option:"

IF %ERRORLEVEL%==1 set @pfs_part=yes
IF %ERRORLEVEL%==2 set @pfs_part=no

IF %@pfs_part%==yes (
echo.
"%~dp0BAT\Diagbox" gd 06
echo I recommend that you create the partition directly on wLaunchELF If you have a problem
"%~dp0BAT\Diagbox" gd 07
echo Example: +OPL
echo.
set /p "partname=Enter partition Name:" 
IF "!partname!"=="" (goto HDDManagementMenu)
echo.
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
echo If you want a 1.5GB partition 1024 + 512 = 1536 Type: 1536M
echo\
echo\
set /p "partsize=Enter partition size:"
IF "!partsize!"=="" (goto HDDManagementMenu)
)

IF %@pfs_part%==yes (
cls
echo\
echo\
echo Creating !partname! Partition:
echo ----------------------------------------------------
echo\

    echo        Creating partitions...
  	echo device %@hdl_path% > "%~dp0TMP\pfs-log.txt"
	echo mkpart "!partname!" !partsize! PFS >> "%~dp0TMP\pfs-log.txt"
  	echo exit >> "%~dp0TMP\pfs-log.txt"
	type "%~dp0TMP\pfs-log.txt" | "%~dp0BAT\pfsshell" >nul 2>&1
	echo        partition !partname! completed...
	
	) else ( cls & echo          Canceled... )

rmdir /Q/S "%~dp0TMP" >nul 2>&1

echo\
echo\
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo Partition Completed...
echo\
echo\
"%~dp0BAT\Diagbox" gd 07

pause & (goto HDDManagementMenu)

REM ####################################################################################################################################################
:DeletePART

cls
mkdir "%~dp0TMP" >nul 2>&1

"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning for Playstation 2 HDDs:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "Playstation 2 HDD"
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "Playstation 2 HDD" | "%~dp0BAT\busybox" grep -o "hdd[0-9]:\|hdd[0-9][0-9]:" > "%~dp0TMP\hdl-hdd.txt" & "%~dp0BAT\busybox" cat "%~dp0TMP\hdl-hdd.txt" > "%~dp0TMP\hdl-hdd2.txt"
"%~dp0BAT\busybox" sed -i "s/hdd/\\\\.\\\PhysicalDrive/g; s/://g" "%~dp0TMP\hdl-hdd.txt"

set /P @hdl_path=<"%~dp0TMP\hdl-hdd.txt"
set /P @hdl_path2=<"%~dp0TMP\hdl-hdd2.txt"
del "%~dp0TMP\hdl-hdd.txt" >nul 2>&1
IF "!@hdl_path!"=="" ( 
"%~dp0BAT\Diagbox" gd 0c
		echo         Playstation 2 HDD Not Detected
		echo         Drive Must Be Formatted First
		echo\
		echo\
"%~dp0BAT\Diagbox" gd 07
		rmdir /Q/S "%~dp0TMP" >nul 2>&1
	    pause & (goto HDDManagementMenu)
	)
	
"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Delete Partition:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1) Yes
"%~dp0BAT\Diagbox" gd 0c
echo         2) No
"%~dp0BAT\Diagbox" gd 07
echo\
CHOICE /C 12 /M "Select Option:"

IF %ERRORLEVEL%==1 set @pfs_partdel=yes
IF %ERRORLEVEL%==2 set @pfs_partdel=no

IF %@pfs_partdel%==yes (
cls
echo\
echo\
echo Scanning Partitions:
echo ----------------------------------------------------
    "%~dp0BAT\hdl_dump" toc %@hdl_path2% | "%~dp0BAT\busybox" grep -e "0x0100" -e "0x0001" > "%~dp0TMP\hdd-prt.txt"
	type "%~dp0TMP\hdd-prt.txt"
echo ----------------------------------------------------
    echo\
    set /p "partnamedel=Enter the partition name you want to delete:" 
    IF "!partnamedel!"=="" (goto HDDManagementMenu)

cls
echo\
echo\
echo Deleting !partnamedel! Partition:
echo ----------------------------------------------------
echo\

    echo        Deleting partitions...
  	echo device %@hdl_path% > "%~dp0TMP\pfs-log.txt"
	echo rmpart "!partnamedel!" >> "%~dp0TMP\pfs-log.txt"
  	echo exit >> "%~dp0TMP\pfs-log.txt"
	type "%~dp0TMP\pfs-log.txt" | "%~dp0BAT\pfsshell" >nul 2>&1
	echo        Partition !partnamedel! Deleted...	
	
   ) else ( cls & echo          Canceled... )
   
rmdir /Q/S "%~dp0TMP" >nul 2>&1

echo\
echo\
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo Partition Completed...
echo\
echo\
"%~dp0BAT\Diagbox" gd 07

pause & (goto HDDManagementMenu)

REM #######################################################################################################################################
:PartitionInfoList

cls
mkdir "%~dp0TMP" >nul 2>&1
mkdir "%~dp0LOG" >nul 2>&1

"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning for Playstation 2 HDDs:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "Playstation 2 HDD"
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "Playstation 2 HDD" | "%~dp0BAT\busybox" grep -o "hdd[0-9]:\|hdd[0-9][0-9]:" > "%~dp0TMP\hdl-hdd.txt"

set /P @hdl_path=<"%~dp0TMP\hdl-hdd.txt"
::del "%~dp0TMP\hdl-hdd.txt" >nul 2>&1
IF "!@hdl_path!"=="" ( 
"%~dp0BAT\Diagbox" gd 0c
		echo         Playstation 2 HDD Not Detected
		echo         Drive Must Be Formatted First
		echo\
		echo\
"%~dp0BAT\Diagbox" gd 07
		rmdir /Q/S "%~dp0TMP" >nul 2>&1
		pause & (goto ShowPartitionInfos)
	)
	
"%~dp0BAT\Diagbox" gd 0f
echo\
echo\

if defined ShowPS1GamePartitionList (
echo Scanning Partitions PS1 Games:
echo ----------------------------------------------------
	"%~dp0BAT\hdl_dump" toc %@hdl_path% | "%~dp0BAT\busybox" grep -e "\.POPS\." | "%~dp0BAT\busybox" sed "s/.\{48\}/& /" | "%~dp0BAT\busybox" sort -k6 | "%~dp0BAT\busybox" sed -e "s/\(.\{48\}\)./\1/" > "%~dp0LOG\PARTITION_PS1_GAMES.txt"
	type "%~dp0LOG\PARTITION_PS1_GAMES.txt"
)

if defined ShowPS2GamePartitionList (
echo Scanning Partitions PS2 Games:
echo ----------------------------------------------------
    "%~dp0BAT\hdl_dump" toc %@hdl_path% | "%~dp0BAT\busybox" grep -e "0x1337" | "%~dp0BAT\busybox" sed "s/.\{44\}/& /" | "%~dp0BAT\busybox" sort -k6 | "%~dp0BAT\busybox" sed -e "s/\(.\{44\}\)./\1/" > "%~dp0LOG\PARTITION_PS2_GAMES.txt"
    type "%~dp0LOG\PARTITION_PS2_GAMES.txt"
)

if defined ShowSystemPartitionList (
echo Scanning Partitions System:
echo ----------------------------------------------------
    "%~dp0BAT\hdl_dump" toc %@hdl_path% | "%~dp0BAT\busybox" grep -e "0x0100" -e "0x0001" | "%~dp0BAT\busybox" sed "/\.POPS\./d" > "%~dp0TMP\hdd-prt.txt"
	type "%~dp0TMP\hdd-prt.txt"
)

if defined DiagPartitionError (
echo Scanning Partitions Error:
"%~dp0BAT\Diagbox" gd 06
echo.
echo NOTE: If nothing appears there is no error in the partitions
echo.
"%~dp0BAT\Diagbox" gd 0f
echo ----------------------------------------------------
    "%~dp0BAT\hdl_dump" diag %@hdl_path% > "%~dp0LOG\PARTITION_SCAN_ERROR.log"
	type "%~dp0LOG\PARTITION_SCAN_ERROR.log"
)

echo ----------------------------------------------------

rmdir /Q/S "%~dp0TMP" >nul 2>&1

echo.
pause & (goto ShowPartitionInfos)

REM #######################################################################################################################################
:MBRProgram

cls
mkdir "%~dp0TMP" >nul 2>&1

"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning for Playstation 2 HDDs:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "Playstation 2 HDD"
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "Playstation 2 HDD" | "%~dp0BAT\busybox" grep -o "hdd[0-9]:\|hdd[0-9][0-9]:" > "%~dp0TMP\hdl-hdd.txt"

set /P @hdl_path=<"%~dp0TMP\hdl-hdd.txt"
::del "%~dp0TMP\hdl-hdd.txt" >nul 2>&1
IF "!@hdl_path!"=="" ( 
"%~dp0BAT\Diagbox" gd 0c
		echo         Playstation 2 HDD Not Detected
		echo         Drive Must Be Formatted First
		echo\
		echo\
"%~dp0BAT\Diagbox" gd 07
		rmdir /Q/S "%~dp0TMP" >nul 2>&1
		pause & (goto HDDManagementMenu)
	)

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Backup or Inject MBR Program:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1) Yes Backup MBR
"%~dp0BAT\Diagbox" gd 0c
echo         2) No
"%~dp0BAT\Diagbox" gd 0e
echo         3) Yes Inject MBR
"%~dp0BAT\Diagbox" gd 07
echo\
CHOICE /C 123 /M "Select Option:"

IF %ERRORLEVEL%==1 set MBR=dump
IF %ERRORLEVEL%==2 (goto HDDManagementMenu)
IF %ERRORLEVEL%==3 set MBR=inject

echo\
echo\

"%~dp0BAT\hdl_dump" %MBR%_mbr %@hdl_path% "%~dp0\__MBR.KELF"
if not exist "%~dp0\__MBR.KELF" echo "%~dp0__MBR.KELF" Missing!
	
rmdir /Q/S "%~dp0TMP" >nul 2>&1

echo.
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
	"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep hdd[1-9]
	"%~dp0BAT\Diagbox" gd 07
    echo.
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
	echo PLAYSTATION 2 HDD
	echo 	1. hdd1:
	echo 	2. hdd2:
	echo 	3. hdd3:
	echo 	4. hdd4:
	echo 	5. hdd5:
	echo 	6. hdd6:
	echo 	7. hdd#: Manual search (More HDD)
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
    echo What is the number of my hard drive? / The one next to the hdd#: in the scanned HDDs
    echo Example If you want to format hdd7: type 7
    echo\
	
    set choice=
    set /p choice=Enter the number of the hard drive you want to format:
    echo\
    IF "!choice!"=="" set "hdlhddm=" & set "hdlhdd=" & set "@hdl_path=" & set "@hdl_pathinfo=" & (goto formatHDDtoPS2)
    IF "!choice!"=="!choice!" set hdlhdd=hdd!choice!:
    IF "!choice!"=="Q" (goto  HDDManagementMenu)
   
   )

"%~dp0BAT\hdl_dump" query | findstr "%hdlhdd%" | "%~dp0BAT\busybox" grep -o "hdd[0-9]:\|hdd[0-9][0-9]:" > "%~dp0TMP\hdl-hdd.txt"
"%~dp0BAT\busybox" sed -i "s/hdd/\\\\.\\\PhysicalDrive/g; s/://g" "%~dp0TMP\hdl-hdd.txt"
set /P @hdl_path=<"%~dp0TMP\hdl-hdd.txt"

"%~dp0BAT\busybox" sed -e "s/\\\\.\\\PhysicalDrive/PHYSICALDRIVE/g; s/://g" "%~dp0TMP\hdl-hdd.txt" > "%~dp0TMP\hdl-hddinfo.txt"
set /P @hdl_pathinfo=<"%~dp0TMP\hdl-hddinfo.txt"
REM del "%~dp0TMP\hdl-hdd.txt" >nul 2>&1

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
echo         1) Yes
"%~dp0BAT\Diagbox" gd 0c
echo         2) No
"%~dp0BAT\Diagbox" gd 07
echo\
CHOICE /C 12 /M "Select Option:"

IF %ERRORLEVEL%==1 set @pfs_formathdd=yes
IF %ERRORLEVEL%==2 set @pfs_formathdd=no & set "hdlhddm=" & set "hdlhdd=" & set "@hdl_path=" & set "@hdl_pathinfo=" & (goto formatHDDtoPS2)

echo\

CHOICE /C YN /m "Confirm"
IF %ERRORLEVEL%==2 set "hdlhdd=" & set "hdlhddm=" & set "@hdl_path=" & set "@hdl_pathinfo=" & (goto formatHDDtoPS2)

cls
IF %@pfs_formathdd%==yes (
echo\
echo\
echo Formatting HDD:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "%hdlhdd%"
"%~dp0BAT\Diagbox" gd 0f
echo\

    echo         Formatting in Progress...
	echo device %@hdl_path% > "%~dp0TMP\pfs-log.txt"
    echo initialize yes >> "%~dp0TMP\pfs-log.txt"
  	echo exit >> "%~dp0TMP\pfs-log.txt"
	type "%~dp0TMP\pfs-log.txt" | "%~dp0BAT\pfsshell" >nul 2>&1

	echo %@hdl_path% > "%~dp0TMP\disk-log.txt"
	"%~dp0BAT\busybox" sed -i "s/\\\\.\\\PhysicalDrive/select disk /g" "%~dp0TMP\disk-log.txt"
	echo offline disk >> "%~dp0TMP\disk-log.txt"
	type "%~dp0TMP\disk-log.txt" | "diskpart" >nul 2>&1

	echo %@hdl_path% > "%~dp0TMP\disk-log.txt"
	"%~dp0BAT\busybox" sed -i "s/\\\\.\\\PhysicalDrive/select disk /g" "%~dp0TMP\disk-log.txt"
	echo online disk >> "%~dp0TMP\disk-log.txt"
	type "%~dp0TMP\disk-log.txt" | "diskpart" >nul 2>&1

	REM echo         Generating PFS filesystem for system partitions...
	echo         Formatting HDD completed...
	
	) else ( echo          HDD - Not Detected... )

rmdir /Q/S "%~dp0TMP" >nul 2>&1

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
	"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep hdd[1-9]
	"%~dp0BAT\Diagbox" gd 07
    echo.
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
	echo PLAYSTATION 2 HDD
	echo 	1. hdd1:
	echo 	2. hdd2:
	echo 	3. hdd3:
	echo 	4. hdd4:
	echo 	5. hdd5:
	echo 	6. hdd6:
	echo 	7. hdd#: Manual search (More HDD)
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
    echo What is the number of my hard drive? / The one next to the hdd#: in the scanned HDDs
    echo Example If you want to hack hdd7: type 7
    echo\
	
    set choice=
    set /p choice=Enter the number of the hard drive you want to Hack:
    echo\
    IF "!choice!"=="" set "hdlhddm=" & set "hdlhdd=" & set "@hdl_path=" & set "@hdl_pathinfo=" & (goto hackHDDtoPS2)
    IF "!choice!"=="!choice!" set hdlhdd=hdd!choice!:
    IF "!choice!"=="Q" (goto  HDDManagementMenu)
   
   )

"%~dp0BAT\hdl_dump" query | findstr "%hdlhdd%" | "%~dp0BAT\busybox" grep -o "hdd[0-9]:\|hdd[0-9][0-9]:" > "%~dp0TMP\hdl-hdd.txt"
"%~dp0BAT\busybox" sed -i "s/hdd/\\\\.\\\PhysicalDrive/g; s/://g" "%~dp0TMP\hdl-hdd.txt"
set /P @hdl_path=<"%~dp0TMP\hdl-hdd.txt"

"%~dp0BAT\busybox" sed -e "s/\\\\.\\\PhysicalDrive/PHYSICALDRIVE/g; s/://g" "%~dp0TMP\hdl-hdd.txt" > "%~dp0TMP\hdl-hddinfo.txt"
set /P @hdl_pathinfo=<"%~dp0TMP\hdl-hddinfo.txt"
REM del "%~dp0TMP\hdl-hdd.txt" >nul 2>&1

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
echo If you have already installed FreeHDBoot (From HDD), you don't need to do this
echo.
echo (1) After the hacking put your HDD in your PS2 and format your hard drive with wLaunchELF
echo In wLaunchELF FileBrowser ^> MISC ^> HDDManager ^> Press R1 ^> Format and confirm.
echo.
echo (2) Copy the contents of the ^!COPY_TO_USB_ROOT folder to the root of your USB drive 
echo.
echo (3) Install FreeMcBoot (From Memory Card) or FreeHDBoot (From HDD) or both.
echo In wLaunchELF FileBrowser ^> Mass ^> APPS ^> FreeMcBoot ^> FMCBInstaller.elf Press Circle for Launch ^> Press R1 ^> Install FHDB (From HDD)
echo.
echo (4) Your hard drive will be properly formatted and hacked after that
echo.
echo (5) Have Fun
echo.
"%~dp0BAT\Diagbox" gd 0f
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1) Yes
"%~dp0BAT\Diagbox" gd 0c
echo         2) No
"%~dp0BAT\Diagbox" gd 07
echo\
CHOICE /C 12 /M "Select Option:"

IF ERRORLEVEL 1 set @pfs_hackhdd=yes
IF ERRORLEVEL 2 rmdir /Q/S "%~dp0\^!COPY_TO_USB_ROOT" >nul 2>&1 & set "hdlhddm=" & set "hdlhdd=" & set "@hdl_path=" & set "@hdl_pathinfo=" & (goto hackHDDtoPS2)
IF ERRORLEVEL 2 set @pfs_hackhdd=no

echo\

CHOICE /C YN /m "Confirm"
IF ERRORLEVEL 2 rmdir /Q/S "%~dp0\^!COPY_TO_USB_ROOT" >nul 2>&1 & set "hdlhddm=" & set "hdlhdd=" & set "@hdl_path=" & set "@hdl_pathinfo=" & (goto hackHDDtoPS2) 

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
	echo "%~dp0BAT\rawcopy" "%~dp0BAT\mbr.img" %@hdl_path% > "%~dp0TMP\disk-log.bat"
	call "%~dp0TMP\disk-log.bat"
	
	echo %@hdl_path% > "%~dp0TMP\disk-log.txt"
	"%~dp0BAT\busybox" sed -i "s/\\\\.\\\PhysicalDrive/select disk /g" "%~dp0TMP\disk-log.txt"
	echo offline disk >> "%~dp0TMP\disk-log.txt"
	type "%~dp0TMP\disk-log.txt" | "diskpart" >nul 2>&1
	
	echo %@hdl_path% > "%~dp0TMP\disk-log.txt"
	"%~dp0BAT\busybox" sed -i "s/\\\\.\\\PhysicalDrive/select disk /g" "%~dp0TMP\disk-log.txt"
	echo online disk >> "%~dp0TMP\disk-log.txt"
	type "%~dp0TMP\disk-log.txt" | "diskpart" >nul 2>&1
	echo         Hacking completed...
	
	) else ( echo        Hack HDD - Canceled... )

rmdir /Q/S "%~dp0TMP" >nul 2>&1

echo\
echo\
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo Hack Completed...
echo\
echo\
"%~dp0BAT\Diagbox" gd 07

"%~dp0\^!COPY_TO_USB_ROOT\README.txt"

pause & (goto HDDManagementMenu)

REM ##############################################################################################################################################################
:InstallHDDOSD

cls
cd "%~dp0"
mkdir "%~dp0TMP" >nul 2>&1

echo\
echo\
echo Checking Files For HDDOSD-1.10U...
echo ----------------------------------------------------
timeout 1 >nul

REM __system\osd100\FNTOSD
if not exist "%~dp0HDD-OSD\__system\osd100\FNTOSD" (
"%~dp0BAT\Diagbox" gd 0c
echo Files "HDD-OSD\__system\osd100\FNTOSD"
echo Missing
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
)

set file=%~dp0HDD-OSD\__system\osd100\FNTOSD
"%~dp0BAT\busybox" md5sum "%file%" | "%~dp0BAT\busybox" grep -o "[0-9a-f]\{32\}" > "%~dp0TMP\MD5.txt" & set /p MD5=<"%~dp0TMP\MD5.txt"

if %md5% equ 17c8ec6119192ca01e949e05f6f246e4 (
"%~dp0BAT\Diagbox" gd 0e
echo Files "HDD-OSD\__system\osd100\FNTOSD"
"%~dp0BAT\Diagbox" gd 0a                    
echo %md5% Confirmed 
echo\
   ) else (
"%~dp0BAT\Diagbox" gd 0c
echo Files "HDD-OSD\__system\osd100\FNTOSD"
echo MD5 not Match Your file is probably corrupted
echo\
pause & (goto  HDDOSDMenu)
echo\
 )

REM __system\osd100\hosdsys.elf
if not exist "%~dp0HDD-OSD\__system\osd100\hosdsys.elf" (
"%~dp0BAT\Diagbox" gd 0c
echo Files "HDD-OSD\__system\osd100\hosdsys.elf"
echo Missing
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
)

set file=%~dp0HDD-OSD\__system\osd100\hosdsys.elf
"%~dp0BAT\busybox" md5sum "%file%" | "%~dp0BAT\busybox" grep -o "[0-9a-f]\{32\}" > "%~dp0TMP\MD5.txt" & set /p MD5=<"%~dp0TMP\MD5.txt"

if %md5% equ ca9ab553e8b51259ccf1ca4ea2d1bc00 (
"%~dp0BAT\Diagbox" gd 0e
echo Files "HDD-OSD\__system\osd100\hosdsys.elf"
"%~dp0BAT\Diagbox" gd 0a                   
echo %md5% Confirmed 
echo\
   ) else (
"%~dp0BAT\Diagbox" gd 0c
echo Files "HDD-OSD\__system\osd100\hosdsys.elf"
echo MD5 not Match Your file is probably corrupted
echo\
pause & (goto  HDDOSDMenu)
 )
 
REM __system\osd100\ICOIMAGE
if not exist "%~dp0HDD-OSD\__system\osd100\ICOIMAGE" (
"%~dp0BAT\Diagbox" gd 0c
echo Files "HDD-OSD\__system\osd100\ICOIMAGE"
echo Missing
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
)

set file=%~dp0HDD-OSD\__system\osd100\ICOIMAGE
"%~dp0BAT\busybox" md5sum "%file%" | "%~dp0BAT\busybox" grep -o "[0-9a-f]\{32\}" > "%~dp0TMP\MD5.txt" & set /p MD5=<"%~dp0TMP\MD5.txt"

if %md5% equ 33a3a304d2ec3892e24d7a5aab9dbc03 (
"%~dp0BAT\Diagbox" gd 0e
echo Files "HDD-OSD\__system\osd100\ICOIMAGE"
"%~dp0BAT\Diagbox" gd 0a                     
echo %md5% Confirmed 
echo\
   ) else (
"%~dp0BAT\Diagbox" gd 0c
echo Files "HDD-OSD\__system\osd100\ICOIMAGE" 
echo MD5 not Match Your file is probably corrupted
echo\
pause & (goto  HDDOSDMenu)
 )
 
 
REM __system\osd100\JISUCS
if not exist "%~dp0HDD-OSD\__system\osd100\JISUCS" (
"%~dp0BAT\Diagbox" gd 0c
echo Files "HDD-OSD\__system\osd100\JISUCS"
echo Missing
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
)

set file=%~dp0HDD-OSD\__system\osd100\JISUCS
"%~dp0BAT\busybox" md5sum "%file%" | "%~dp0BAT\busybox" grep -o "[0-9a-f]\{32\}" > "%~dp0TMP\MD5.txt" & set /p MD5=<"%~dp0TMP\MD5.txt"

if %md5% equ 221c517ede8f1caf4ccf9bfddba1524c (
"%~dp0BAT\Diagbox" gd 0e
echo Files "HDD-OSD\__system\osd100\JISUCS"
"%~dp0BAT\Diagbox" gd 0a                     
echo %md5% Confirmed 
echo\
   ) else (
"%~dp0BAT\Diagbox" gd 0c
echo Files "HDD-OSD\__system\osd100\JISUCS" 
echo MD5 not Match Your file is probably corrupted
echo\
pause & (goto  HDDOSDMenu)
 )
 
REM __system\osd100\SKBIMAGE
if not exist "%~dp0HDD-OSD\__system\osd100\SKBIMAGE" (
"%~dp0BAT\Diagbox" gd 0c
echo Files "HDD-OSD\__system\osd100\SKBIMAGE"
echo Missing
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
)

set file=%~dp0HDD-OSD\__system\osd100\SKBIMAGE
"%~dp0BAT\busybox" md5sum "%file%" | "%~dp0BAT\busybox" grep -o "[0-9a-f]\{32\}" > "%~dp0TMP\MD5.txt" & set /p MD5=<"%~dp0TMP\MD5.txt"

if %md5% equ 99220367a205fc45e743895759e79281 (
"%~dp0BAT\Diagbox" gd 0e
echo Files "HDD-OSD\__system\osd100\SKBIMAGE"
"%~dp0BAT\Diagbox" gd 0a                     
echo %md5% Confirmed 
echo\
   ) else (
"%~dp0BAT\Diagbox" gd 0c
echo Files "HDD-OSD\__system\osd100\SKBIMAGE" 
echo MD5 not Match Your file is probably corrupted
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
 )
 
REM __system\osd100\SNDIMAGE
if not exist "%~dp0HDD-OSD\__system\osd100\SNDIMAGE" (
"%~dp0BAT\Diagbox" gd 0c
echo Files "HDD-OSD\__system\osd100\SNDIMAGE"
echo Missing
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
)

set file=%~dp0HDD-OSD\__system\osd100\SNDIMAGE
"%~dp0BAT\busybox" md5sum "%file%" | "%~dp0BAT\busybox" grep -o "[0-9a-f]\{32\}" > "%~dp0TMP\MD5.txt" & set /p MD5=<"%~dp0TMP\MD5.txt"

if %md5% equ 784bd4bb1e8327ef2907dfc8c574cda4 (
"%~dp0BAT\Diagbox" gd 0e
echo Files "HDD-OSD\__system\osd100\SNDIMAGE"
"%~dp0BAT\Diagbox" gd 0a                     
echo %md5% Confirmed 
echo\
   ) else (
"%~dp0BAT\Diagbox" gd 0c
echo Files "HDD-OSD\__system\osd100\SNDIMAGE"
echo MD5 not Match Your file is probably corrupted
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
 )
 
REM __system\osd100\TEXIMAGE
if not exist "%~dp0HDD-OSD\__system\osd100\TEXIMAGE" (
"%~dp0BAT\Diagbox" gd 0c
echo Files "HDD-OSD\__system\osd100\TEXIMAGE"
echo Missing
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
)

set file=%~dp0HDD-OSD\__system\osd100\TEXIMAGE
"%~dp0BAT\busybox" md5sum "%file%" | "%~dp0BAT\busybox" grep -o "[0-9a-f]\{32\}" > "%~dp0TMP\MD5.txt" & set /p MD5=<"%~dp0TMP\MD5.txt"

if %md5% equ 08e42817da1d2480e883851e5d88f0e5 (
"%~dp0BAT\Diagbox" gd 0e
echo Files "HDD-OSD\__system\osd100\TEXIMAGE"
"%~dp0BAT\Diagbox" gd 0a                    
echo %md5% Confirmed 
echo\
   ) else (
"%~dp0BAT\Diagbox" gd 0c
echo Files "HDD-OSD\__system\osd100\TEXIMAGE"
echo MD5 not Match Your file is probably corrupted
echo\
pause & (goto  HDDOSDMenu)
 )
 
REM __system\fsck100\FSCK_A.XLF
if not exist "%~dp0HDD-OSD\__system\fsck100\FSCK_A.XLF" (
"%~dp0BAT\Diagbox" gd 0c
echo Files "HDD-OSD\__system\osd100\FSCK_A.XLF"
echo Missing
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
)

set file=%~dp0HDD-OSD\__system\fsck100\FSCK_A.XLF
"%~dp0BAT\busybox" md5sum "%file%" | "%~dp0BAT\busybox" grep -o "[0-9a-f]\{32\}" > "%~dp0TMP\MD5.txt" & set /p MD5=<"%~dp0TMP\MD5.txt"

if %md5% equ 3618ec7d45413f12a13a63ceada96620 (
"%~dp0BAT\Diagbox" gd 0e
echo Files "HDD-OSD\__system\fsck100\FSCK_A.XLF"
"%~dp0BAT\Diagbox" gd 0a                   
echo %md5% Confirmed 
echo\
   ) else (
"%~dp0BAT\Diagbox" gd 0c
echo Files "HDD-OSD\__system\fsck100\FSCK_A.XLF"
echo MD5 not Match Your file is probably corrupted
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
 )
 
REM __system\fsck100\files\FILES_A.PAK
if not exist "%~dp0HDD-OSD\__system\fsck100\files\FILES_A.PAK" (
"%~dp0BAT\Diagbox" gd 0c
echo Files "HDD-OSD\__system\osd100\FSCK_A.XLF"
echo Missing
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
)

set file=%~dp0HDD-OSD\__system\fsck100\files\FILES_A.PAK
"%~dp0BAT\busybox" md5sum "%file%" | "%~dp0BAT\busybox" grep -o "[0-9a-f]\{32\}" > "%~dp0TMP\MD5.txt" & set /p MD5=<"%~dp0TMP\MD5.txt"

if %md5% equ c7b28caaee8c91e17ee663bdca179108 (
"%~dp0BAT\Diagbox" gd 0e
echo Files "HDD-OSD\__system\fsck100\files\FILES_A.PAK"
"%~dp0BAT\Diagbox" gd 0a          
echo %md5% Confirmed 
echo\
   ) else (
"%~dp0BAT\Diagbox" gd 0c
echo Files "HDD-OSD\__system\fsck100\files\FILES_A.PAK"
echo MD5 not Match Your file is probably corrupted
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
 )
 
REM __sysconf\CONF\FILETYPE.INI
if not exist "%~dp0HDD-OSD\__sysconf\CONF\FILETYPE.INI" (
"%~dp0BAT\Diagbox" gd 0c
echo Files "HDD-OSD\__sysconf\CONF\FILETYPE.INI"
echo Missing
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
)

set file=%~dp0HDD-OSD\__sysconf\CONF\FILETYPE.INI
"%~dp0BAT\busybox" md5sum "%file%" | "%~dp0BAT\busybox" grep -o "[0-9a-f]\{32\}" > "%~dp0TMP\MD5.txt" & set /p MD5=<"%~dp0TMP\MD5.txt"

if %md5% equ 3b0c10c058f0f630973dd07db2ea8860 (
"%~dp0BAT\Diagbox" gd 0e
echo Files "HDD-OSD\__sysconf\CONF\FILETYPE.INI"
"%~dp0BAT\Diagbox" gd 0a         
echo %md5% Confirmed 
echo\
   ) else (
"%~dp0BAT\Diagbox" gd 0c
echo Files "HDD-OSD\__sysconf\CONF\FILETYPE.INI"
echo MD5 not Match Your file is probably corrupted
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
 )
 
REM __sysconf\CONF\SYSTEM.INI
if not exist "%~dp0HDD-OSD\__sysconf\CONF\SYSTEM.INI" (
"%~dp0BAT\Diagbox" gd 0c
echo Files "HDD-OSD\__sysconf\CONF\SYSTEM.INI" 
echo Missing
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
)

set file=%~dp0HDD-OSD\__sysconf\CONF\SYSTEM.INI
"%~dp0BAT\busybox" md5sum "%file%" | "%~dp0BAT\busybox" grep -o "[0-9a-f]\{32\}" > "%~dp0TMP\MD5.txt" & set /p MD5=<"%~dp0TMP\MD5.txt"

if %md5% equ 895fad012365b59e47a3f563daadbb86 (
"%~dp0BAT\Diagbox" gd 0e
echo Files "HDD-OSD\__sysconf\CONF\SYSTEM.INI"
"%~dp0BAT\Diagbox" gd 0a         
echo %md5% Confirmed 
echo\
   ) else (
"%~dp0BAT\Diagbox" gd 0c
echo Files "HDD-OSD\__sysconf\CONF\SYSTEM.INI"
echo MD5 not Match Your file is probably corrupted
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
 )
 
REM __sysconf\CONF\SYSTEM101.INI
if not exist "%~dp0HDD-OSD\__sysconf\CONF\SYSTEM101.INI" (
"%~dp0BAT\Diagbox" gd 0c
echo Files "HDD-OSD\__sysconf\CONF\SYSTEM101.INI" 
echo Missing
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
)

set file=%~dp0HDD-OSD\__sysconf\CONF\SYSTEM101.INI
"%~dp0BAT\busybox" md5sum "%file%" | "%~dp0BAT\busybox" grep -o "[0-9a-f]\{32\}" > "%~dp0TMP\MD5.txt" & set /p MD5=<"%~dp0TMP\MD5.txt"

if %md5% equ 184207759080a81779b8e124ee340075 (
"%~dp0BAT\Diagbox" gd 0e
echo Files "HDD-OSD\__sysconf\CONF\SYSTEM101.INI"
"%~dp0BAT\Diagbox" gd 0a         
echo %md5% Confirmed 
echo\
   ) else (
"%~dp0BAT\Diagbox" gd 0c
echo Files "HDD-OSD\__sysconf\CONF\SYSTEM101.INI"
echo MD5 not Match Your file is probably corrupted
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
 )
 
REM __sysconf\CONF\SYSTEMDUT.INI
if not exist "%~dp0HDD-OSD\__sysconf\CONF\SYSTEMDUT.INI" (
"%~dp0BAT\Diagbox" gd 0c
echo Files "HDD-OSD\__sysconf\CONF\SYSTEMDUT.INI" 
echo Missing
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
)

set file=%~dp0HDD-OSD\__sysconf\CONF\SYSTEMDUT.INI
"%~dp0BAT\busybox" md5sum "%file%" | "%~dp0BAT\busybox" grep -o "[0-9a-f]\{32\}" > "%~dp0TMP\MD5.txt" & set /p MD5=<"%~dp0TMP\MD5.txt"

if %md5% equ 7fbbd9c08962866504d633e1e219872e (
"%~dp0BAT\Diagbox" gd 0e
echo Files "HDD-OSD\__sysconf\CONF\SYSTEMDUT.INI"
"%~dp0BAT\Diagbox" gd 0a         
echo %md5% Confirmed 
echo\
   ) else (
"%~dp0BAT\Diagbox" gd 0c
echo Files "HDD-OSD\__sysconf\CONF\SYSTEMDUT.INI"
echo MD5 not Match Your file is probably corrupted
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
 )
 
REM __sysconf\CONF\SYSTEMEUK.INI
if not exist "%~dp0HDD-OSD\__sysconf\CONF\SYSTEMEUK.INI" (
"%~dp0BAT\Diagbox" gd 0c
echo Files "HDD-OSD\__sysconf\CONF\SYSTEMEUK.INI" 
echo Missing
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
)

set file=%~dp0HDD-OSD\__sysconf\CONF\SYSTEMEUK.INI
"%~dp0BAT\busybox" md5sum "%file%" | "%~dp0BAT\busybox" grep -o "[0-9a-f]\{32\}" > "%~dp0TMP\MD5.txt" & set /p MD5=<"%~dp0TMP\MD5.txt"

if %md5% equ fe9a4764c855dc6fa0284efe36463680 (
"%~dp0BAT\Diagbox" gd 0e
echo Files "HDD-OSD\__sysconf\CONF\SYSTEMEUK.INI"
"%~dp0BAT\Diagbox" gd 0a          
echo %md5% Confirmed 
echo\
   ) else (
"%~dp0BAT\Diagbox" gd 0c
echo Files "HDD-OSD\__sysconf\CONF\SYSTEMEUK.INI"
echo MD5 not Match Your file is probably corrupted
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
 )
 
REM __sysconf\CONF\SYSTEMFCA.INI
if not exist "%~dp0HDD-OSD\__sysconf\CONF\SYSTEMFCA.INI" (
"%~dp0BAT\Diagbox" gd 0c
echo Files "HDD-OSD\__sysconf\CONF\SYSTEMFCA.INI" 
echo Missing
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
)

set file=%~dp0HDD-OSD\__sysconf\CONF\SYSTEMFCA.INI
"%~dp0BAT\busybox" md5sum "%file%" | "%~dp0BAT\busybox" grep -o "[0-9a-f]\{32\}" > "%~dp0TMP\MD5.txt" & set /p MD5=<"%~dp0TMP\MD5.txt"

if %md5% equ 1d1a89b210b1620c7530451ca3211cac (
"%~dp0BAT\Diagbox" gd 0e
echo Files "HDD-OSD\__sysconf\CONF\SYSTEMFCA.INI"
"%~dp0BAT\Diagbox" gd 0a           
echo %md5% Confirmed 
echo\
   ) else (
"%~dp0BAT\Diagbox" gd 0c
echo Files "HDD-OSD\__sysconf\CONF\SYSTEMFCA.INI"
echo MD5 not Match Your file is probably corrupted
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
 )
 
REM __sysconf\CONF\SYSTEMFRE.INI
if not exist "%~dp0HDD-OSD\__sysconf\CONF\SYSTEMFRE.INI" (
"%~dp0BAT\Diagbox" gd 0c
echo Files "HDD-OSD\__sysconf\CONF\SYSTEMFRE.INI" 
echo Missing
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
)

set file=%~dp0HDD-OSD\__sysconf\CONF\SYSTEMFRE.INI
"%~dp0BAT\busybox" md5sum "%file%" | "%~dp0BAT\busybox" grep -o "[0-9a-f]\{32\}" > "%~dp0TMP\MD5.txt" & set /p MD5=<"%~dp0TMP\MD5.txt"

if %md5% equ 74db7d226eba87daca9036c79928c787 (
"%~dp0BAT\Diagbox" gd 0e
echo Files "HDD-OSD\__sysconf\CONF\SYSTEMFRE.INI"   
"%~dp0BAT\Diagbox" gd 0a          
echo %md5% Confirmed 
echo\
   ) else (
"%~dp0BAT\Diagbox" gd 0c
echo Files "HDD-OSD\__sysconf\CONF\SYSTEMFRE.INI"
echo MD5 not Match Your file is probably corrupted
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
 )
 
REM __sysconf\CONF\SYSTEMGER.INI
if not exist "%~dp0HDD-OSD\__sysconf\CONF\SYSTEMGER.INI" (
"%~dp0BAT\Diagbox" gd 0c
echo Files "HDD-OSD\__sysconf\CONF\SYSTEMGER.INI" 
echo Missing
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
)

set file=%~dp0HDD-OSD\__sysconf\CONF\SYSTEMGER.INI
"%~dp0BAT\busybox" md5sum "%file%" | "%~dp0BAT\busybox" grep -o "[0-9a-f]\{32\}" > "%~dp0TMP\MD5.txt" & set /p MD5=<"%~dp0TMP\MD5.txt"

if %md5% equ a7eb2f27f3e8f5a3351fba38709e6384 (
"%~dp0BAT\Diagbox" gd 0e
echo Files "HDD-OSD\__sysconf\CONF\SYSTEMGER.INI"
"%~dp0BAT\Diagbox" gd 0a          
echo %md5% Confirmed 
echo\
   ) else (
"%~dp0BAT\Diagbox" gd 0c
echo Files "HDD-OSD\__sysconf\CONF\SYSTEMGER.INI"
echo MD5 not Match Your file is probably corrupted
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
 )

REM __sysconf\CONF\SYSTEMITA.INI
if not exist "%~dp0HDD-OSD\__sysconf\CONF\SYSTEMITA.INI" (
"%~dp0BAT\Diagbox" gd 0c
echo Files "HDD-OSD\__sysconf\CONF\SYSTEMITA.INI" 
echo Missing
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
)

set file=%~dp0HDD-OSD\__sysconf\CONF\SYSTEMITA.INI
"%~dp0BAT\busybox" md5sum "%file%" | "%~dp0BAT\busybox" grep -o "[0-9a-f]\{32\}" > "%~dp0TMP\MD5.txt" & set /p MD5=<"%~dp0TMP\MD5.txt"

if %md5% equ b0ad0dbc751369e5f4b200a62b5acbd0 (
"%~dp0BAT\Diagbox" gd 0e
echo Files "HDD-OSD\__sysconf\CONF\SYSTEMITA.INI"
"%~dp0BAT\Diagbox" gd 0a           
echo %md5% Confirmed 
echo\
   ) else (
"%~dp0BAT\Diagbox" gd 0c
echo Files "HDD-OSD\__sysconf\CONF\SYSTEMITA.INI"
echo MD5 not Match Your file is probably corrupted
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
 )
 
REM __sysconf\CONF\SYSTEMPOR.INI
if not exist "%~dp0HDD-OSD\__sysconf\CONF\SYSTEMPOR.INI" (
"%~dp0BAT\Diagbox" gd 0c
echo Files "HDD-OSD\__sysconf\CONF\SYSTEMPOR.INI" 
echo Missing
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
)

set file=%~dp0HDD-OSD\__sysconf\CONF\SYSTEMPOR.INI
"%~dp0BAT\busybox" md5sum "%file%" | "%~dp0BAT\busybox" grep -o "[0-9a-f]\{32\}" > "%~dp0TMP\MD5.txt" & set /p MD5=<"%~dp0TMP\MD5.txt"

if %md5% equ 215627b9bc74418a6982b9ea8e4ce786 (
"%~dp0BAT\Diagbox" gd 0e
echo Files "HDD-OSD\__sysconf\CONF\SYSTEMPOR.INI"
"%~dp0BAT\Diagbox" gd 0a          
echo %md5% Confirmed 
echo\
   ) else (
"%~dp0BAT\Diagbox" gd 0c
echo Files "HDD-OSD\__sysconf\CONF\SYSTEMPOR.INI"
echo MD5 not Match Your file is probably corrupted
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
 )

REM __sysconf\CONF\SYSTEMSPA.INI
if not exist "%~dp0HDD-OSD\__sysconf\CONF\SYSTEMSPA.INI" (
"%~dp0BAT\Diagbox" gd 0c
echo Files "HDD-OSD\__sysconf\CONF\SYSTEMSPA.INI" 
echo Missing
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
)

set file=%~dp0HDD-OSD\__sysconf\CONF\SYSTEMSPA.INI
"%~dp0BAT\busybox" md5sum "%file%" | "%~dp0BAT\busybox" grep -o "[0-9a-f]\{32\}" > "%~dp0TMP\MD5.txt" & set /p MD5=<"%~dp0TMP\MD5.txt"

if %md5% equ d950838548cdbe10a08a9daf3d109da8 (
"%~dp0BAT\Diagbox" gd 0e
echo Files "HDD-OSD\__sysconf\CONF\SYSTEMSPA.INI"    
"%~dp0BAT\Diagbox" gd 0a         
echo %md5% Confirmed 
echo\
   ) else (
"%~dp0BAT\Diagbox" gd 0c
echo Files "HDD-OSD\__sysconf\CONF\SYSTEMSPA.INI"
echo MD5 not Match Your file is probably corrupted
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
 )
 
REM __sysconf\FONT\S22I646.GF
if not exist "%~dp0HDD-OSD\__sysconf\FONT\S22I646.GF" (
"%~dp0BAT\Diagbox" gd 0c
echo Files "HDD-OSD\__sysconf\FONT\S22I646.GF" 
echo Missing
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
)

set file=%~dp0HDD-OSD\__sysconf\FONT\S22I646.GF
"%~dp0BAT\busybox" md5sum "%file%" | "%~dp0BAT\busybox" grep -o "[0-9a-f]\{32\}" > "%~dp0TMP\MD5.txt" & set /p MD5=<"%~dp0TMP\MD5.txt"

if %md5% equ e4eb6119e6c6aaa6e948769b1a11c825 (
"%~dp0BAT\Diagbox" gd 0e
echo Files "HDD-OSD\__sysconf\FONT\S22I646.GF"
"%~dp0BAT\Diagbox" gd 0a          
echo %md5% Confirmed 
echo\
   ) else (
"%~dp0BAT\Diagbox" gd 0c
echo Files "HDD-OSD\__sysconf\FONT\S22I646.GF"
echo MD5 not Match Your file is probably corrupted
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
 )
 
REM __sysconf\FONT\S22J201.GF
if not exist "%~dp0HDD-OSD\__sysconf\FONT\S22J201.GF" (
"%~dp0BAT\Diagbox" gd 0c
echo Files "HDD-OSD\__sysconf\FONT\S22I646.GF" 
echo Missing
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
)

set file=%~dp0HDD-OSD\__sysconf\FONT\S22J201.GF
"%~dp0BAT\busybox" md5sum "%file%" | "%~dp0BAT\busybox" grep -o "[0-9a-f]\{32\}" > "%~dp0TMP\MD5.txt" & set /p MD5=<"%~dp0TMP\MD5.txt"

if %md5% equ 13d29bcb4c7c9b1d56a415003fae0da8 (
"%~dp0BAT\Diagbox" gd 0e
echo Files "HDD-OSD\__sysconf\FONT\S22J201.GF"      
"%~dp0BAT\Diagbox" gd 0a      
echo %md5% Confirmed 
echo\
   ) else (
"%~dp0BAT\Diagbox" gd 0c
echo Files "HDD-OSD\__sysconf\FONT\S22J201.GF"
echo MD5 not Match Your file is probably corrupted
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
 )

REM __sysconf\FONT\S22J213.GF
if not exist "%~dp0HDD-OSD\__sysconf\FONT\S22J213.GF" (
"%~dp0BAT\Diagbox" gd 0c
echo Files "HDD-OSD\__sysconf\FONT\S22J213.GF" 
echo Missing
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
)

set file=%~dp0HDD-OSD\__sysconf\FONT\S22J213.GF
"%~dp0BAT\busybox" md5sum "%file%" | "%~dp0BAT\busybox" grep -o "[0-9a-f]\{32\}" > "%~dp0TMP\MD5.txt" & set /p MD5=<"%~dp0TMP\MD5.txt"

if %md5% equ 0dd5bbcc387db16eb4c954be89888fcf (
"%~dp0BAT\Diagbox" gd 0e
echo Files "HDD-OSD\__sysconf\FONT\S22J213.GF"      
"%~dp0BAT\Diagbox" gd 0a      
echo %md5% Confirmed 
echo\
   ) else (
"%~dp0BAT\Diagbox" gd 0c
echo Files "HDD-OSD\__sysconf\FONT\S22J213.GF"
echo MD5 not Match Your file is probably corrupted
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
 )
 
REM __sysconf\FONT\S22ULST.GF
if not exist "%~dp0HDD-OSD\__sysconf\FONT\S22ULST.GF" (
"%~dp0BAT\Diagbox" gd 0c
echo Files "HDD-OSD\__sysconf\FONT\S22ULST.GF" 
echo Missing
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
)

set file=%~dp0HDD-OSD\__sysconf\FONT\S22ULST.GF
"%~dp0BAT\busybox" md5sum "%file%" | "%~dp0BAT\busybox" grep -o "[0-9a-f]\{32\}" > "%~dp0TMP\MD5.txt" & set /p MD5=<"%~dp0TMP\MD5.txt"

if %md5% equ e489297f6100819b0b9b68bc1b5181aa (
"%~dp0BAT\Diagbox" gd 0e
echo Files "HDD-OSD\__sysconf\FONT\S22ULST.GF"      
"%~dp0BAT\Diagbox" gd 0a      
echo %md5% Confirmed 
echo\
   ) else (
"%~dp0BAT\Diagbox" gd 0c
echo Files "HDD-OSD\__sysconf\FONT\S22ULST.GF"
echo MD5 not Match Your file is probably corrupted
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
 )

REM __sysconf\FONT\S26I646.GF
if not exist "%~dp0HDD-OSD\__sysconf\FONT\S26I646.GF" (
"%~dp0BAT\Diagbox" gd 0c
echo Files "HDD-OSD\__sysconf\FONT\S26I646.GF" 
echo Missing
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
)

set file=%~dp0HDD-OSD\__sysconf\FONT\S26I646.GF
"%~dp0BAT\busybox" md5sum "%file%" | "%~dp0BAT\busybox" grep -o "[0-9a-f]\{32\}" > "%~dp0TMP\MD5.txt" & set /p MD5=<"%~dp0TMP\MD5.txt"

if %md5% equ 26edc62c3c9cbbc0227dba1135d2bffb (
"%~dp0BAT\Diagbox" gd 0e
echo Files "HDD-OSD\__sysconf\FONT\S26I646.GF"      
"%~dp0BAT\Diagbox" gd 0a      
echo %md5% Confirmed 
echo\
   ) else (
"%~dp0BAT\Diagbox" gd 0c
echo Files "HDD-OSD\__sysconf\FONT\S26I646.GF"
echo MD5 not Match Your file is probably corrupted
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
 )

REM __sysconf\FONT\S26J201.GF
if not exist "%~dp0HDD-OSD\__sysconf\FONT\S26J201.GF" (
"%~dp0BAT\Diagbox" gd 0c
echo Files "HDD-OSD\__sysconf\FONT\S26J201.GF" 
echo Missing
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
)

set file=%~dp0HDD-OSD\__sysconf\FONT\S26J201.GF
"%~dp0BAT\busybox" md5sum "%file%" | "%~dp0BAT\busybox" grep -o "[0-9a-f]\{32\}" > "%~dp0TMP\MD5.txt" & set /p MD5=<"%~dp0TMP\MD5.txt"

if %md5% equ 17a03c0088d2cc48d95c40d445b2afe6 (
"%~dp0BAT\Diagbox" gd 0e
echo Files "HDD-OSD\__sysconf\FONT\S26J201.GF"      
"%~dp0BAT\Diagbox" gd 0a      
echo %md5% Confirmed
echo\
   ) else (
"%~dp0BAT\Diagbox" gd 0c
echo Files "HDD-OSD\__sysconf\FONT\S26J201.GF"
echo MD5 not Match Your file is probably corrupted
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
 )
 
REM __sysconf\FONT\S26J213.GF
if not exist "%~dp0HDD-OSD\__sysconf\FONT\S26J213.GF" (
"%~dp0BAT\Diagbox" gd 0c
echo Files "HDD-OSD\__sysconf\FONT\S26J213.GF" 
echo Missing
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
)

set file=%~dp0HDD-OSD\__sysconf\FONT\S26J213.GF
"%~dp0BAT\busybox" md5sum "%file%" | "%~dp0BAT\busybox" grep -o "[0-9a-f]\{32\}" > "%~dp0TMP\MD5.txt" & set /p MD5=<"%~dp0TMP\MD5.txt"

if %md5% equ 7ccb142ed25afb8f483202a9c713636c (
"%~dp0BAT\Diagbox" gd 0e
echo Files "HDD-OSD\__sysconf\FONT\S26J213.GF"      
"%~dp0BAT\Diagbox" gd 0a      
echo %md5% Confirmed
echo\
   ) else (
"%~dp0BAT\Diagbox" gd 0c
echo Files "HDD-OSD\__sysconf\FONT\S26J213.GF"
echo MD5 not Match Your file is probably corrupted
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
 )

REM __sysconf\FONT\S26ULST.GF
if not exist "%~dp0HDD-OSD\__sysconf\FONT\S26ULST.GF" (
"%~dp0BAT\Diagbox" gd 0c
echo Files "HDD-OSD\__sysconf\FONT\S26ULST.GF" 
echo Missing
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
)

set file=%~dp0HDD-OSD\__sysconf\FONT\S26ULST.GF
"%~dp0BAT\busybox" md5sum "%file%" | "%~dp0BAT\busybox" grep -o "[0-9a-f]\{32\}" > "%~dp0TMP\MD5.txt" & set /p MD5=<"%~dp0TMP\MD5.txt"

if %md5% equ 3ae70fdd7db7cda669b6dbfbdf8a6368 (
"%~dp0BAT\Diagbox" gd 0e
echo Files "HDD-OSD\__sysconf\FONT\S26ULST.GF"      
"%~dp0BAT\Diagbox" gd 0a      
echo %md5% Confirmed
echo\
   ) else (
"%~dp0BAT\Diagbox" gd 0c
echo Files "HDD-OSD\__sysconf\FONT\S26ULST.GF"
echo MD5 not Match Your file is probably corrupted
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
 )
 
REM __sysconf\FONT\SCE20I22.GF
if not exist "%~dp0HDD-OSD\__sysconf\FONT\SCE20I22.GF" (
"%~dp0BAT\Diagbox" gd 0c
echo Files "HDD-OSD\__sysconf\FONT\SCE20I22.GF" 
echo Missing
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
)

set file=%~dp0HDD-OSD\__sysconf\FONT\SCE20I22.GF
"%~dp0BAT\busybox" md5sum "%file%" | "%~dp0BAT\busybox" grep -o "[0-9a-f]\{32\}" > "%~dp0TMP\MD5.txt" & set /p MD5=<"%~dp0TMP\MD5.txt"

if %md5% equ b7be6961ba83a8f8b411b18fe30a02cc (
"%~dp0BAT\Diagbox" gd 0e
echo Files "HDD-OSD\__sysconf\FONT\SCE20I22.GF"      
"%~dp0BAT\Diagbox" gd 0a      
echo %md5% Confirmed
echo\
   ) else (
"%~dp0BAT\Diagbox" gd 0c
echo Files "HDD-OSD\__sysconf\FONT\SCE20I22.GF"
echo MD5 not Match Your file is probably corrupted
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
 )

REM __sysconf\FONT\SCE24I26.GF
if not exist "%~dp0HDD-OSD\__sysconf\FONT\SCE24I26.GF" (
"%~dp0BAT\Diagbox" gd 0c
echo Files "HDD-OSD\__sysconf\FONT\SCE24I26.GF" 
echo Missing
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
)

set file=%~dp0HDD-OSD\__sysconf\FONT\SCE24I26.GF
"%~dp0BAT\busybox" md5sum "%file%" | "%~dp0BAT\busybox" grep -o "[0-9a-f]\{32\}" > "%~dp0TMP\MD5.txt" & set /p MD5=<"%~dp0TMP\MD5.txt"

if %md5% equ 941335d6e6f3befe4aa7b58ef228b831 (
"%~dp0BAT\Diagbox" gd 0e
echo Files "HDD-OSD\__sysconf\FONT\SCE24I26.GF"      
"%~dp0BAT\Diagbox" gd 0a      
echo %md5% Confirmed
echo\
   ) else (
"%~dp0BAT\Diagbox" gd 0c
echo Files "HDD-OSD\__sysconf\FONT\SCE24I26.GF"
echo MD5 not Match Your file is probably corrupted
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
 )
 
REM __sysconf\ICON\ICON.SYS
if not exist "%~dp0HDD-OSD\__sysconf\ICON\ICON.SYS" (
"%~dp0BAT\Diagbox" gd 0c
echo Files "HDD-OSD\__sysconf\ICON\ICON.SYS" 
echo Missing
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
)

set file=%~dp0HDD-OSD\__sysconf\ICON\ICON.SYS
"%~dp0BAT\busybox" md5sum "%file%" | "%~dp0BAT\busybox" grep -o "[0-9a-f]\{32\}" > "%~dp0TMP\MD5.txt" & set /p MD5=<"%~dp0TMP\MD5.txt"

if %md5% equ b2d4de12ed4c2c80a3594b2fb3655edb (
"%~dp0BAT\Diagbox" gd 0e
echo Files "HDD-OSD\__sysconf\ICON\ICON.SYS"      
"%~dp0BAT\Diagbox" gd 0a      
echo %md5% Confirmed
echo\
   ) else (
"%~dp0BAT\Diagbox" gd 0c
echo Files "HDD-OSD\__sysconf\ICON\ICON.SYS"
echo MD5 not Match Your file is probably corrupted
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
 )
 
REM __sysconf\ICON\OTHERS.ICO
if not exist "%~dp0HDD-OSD\__sysconf\ICON\OTHERS.ICO" (
"%~dp0BAT\Diagbox" gd 0c
echo Files "HDD-OSD\__sysconf\ICON\OTHERS.ICO" 
echo Missing
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
)

set file=%~dp0HDD-OSD\__sysconf\ICON\OTHERS.ICO
"%~dp0BAT\busybox" md5sum "%file%" | "%~dp0BAT\busybox" grep -o "[0-9a-f]\{32\}" > "%~dp0TMP\MD5.txt" & set /p MD5=<"%~dp0TMP\MD5.txt"

if %md5% equ 737c0a56b22f3d116ab6420885754335 (
"%~dp0BAT\Diagbox" gd 0e
echo Files "HDD-OSD\__sysconf\ICON\OTHERS.ICO"      
"%~dp0BAT\Diagbox" gd 0a      
echo %md5% Confirmed
echo\
   ) else (
"%~dp0BAT\Diagbox" gd 0c
echo Files "HDD-OSD\__sysconf\ICON\OTHERS.ICO"
echo MD5 not Match Your file is probably corrupted
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
 )
 
REM __sysconf\ICON\AUDIO\AUDIO.ICO
if not exist "%~dp0HDD-OSD\__sysconf\ICON\AUDIO\AUDIO.ICO" (
"%~dp0BAT\Diagbox" gd 0c
echo Files "HDD-OSD\__sysconf\ICON\AUDIO\AUDIO.ICO" 
echo Missing
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
)

set file=%~dp0HDD-OSD\__sysconf\ICON\AUDIO\AUDIO.ICO
"%~dp0BAT\busybox" md5sum "%file%" | "%~dp0BAT\busybox" grep -o "[0-9a-f]\{32\}" > "%~dp0TMP\MD5.txt" & set /p MD5=<"%~dp0TMP\MD5.txt"

if %md5% equ 8c0452693ae78eaa6d8f59c364b0e338 (
"%~dp0BAT\Diagbox" gd 0e
echo Files "HDD-OSD\__sysconf\ICON\AUDIO\AUDIO.ICO"      
"%~dp0BAT\Diagbox" gd 0a      
echo %md5% Confirmed
echo\
   ) else (
"%~dp0BAT\Diagbox" gd 0c
echo Files "HDD-OSD\__sysconf\ICON\AUDIO\AUDIO.ICO"
echo MD5 not Match Your file is probably corrupted
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
 )

REM __sysconf\ICON\AUDIO\ICON.SYS
if not exist "%~dp0HDD-OSD\__sysconf\ICON\AUDIO\ICON.SYS" (
"%~dp0BAT\Diagbox" gd 0c
echo Files "HDD-OSD\__sysconf\ICON\AUDIO\ICON.SYS" 
echo Missing
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
)

set file=%~dp0HDD-OSD\__sysconf\ICON\AUDIO\ICON.SYS
"%~dp0BAT\busybox" md5sum "%file%" | "%~dp0BAT\busybox" grep -o "[0-9a-f]\{32\}" > "%~dp0TMP\MD5.txt" & set /p MD5=<"%~dp0TMP\MD5.txt"

if %md5% equ ef7e169fb0d3f620b80399de9437f9b5 (
"%~dp0BAT\Diagbox" gd 0e
echo Files "HDD-OSD\__sysconf\ICON\AUDIO\ICON.SYS"      
"%~dp0BAT\Diagbox" gd 0a      
echo %md5% Confirmed
echo\
   ) else (
"%~dp0BAT\Diagbox" gd 0c
echo Files "HDD-OSD\__sysconf\ICON\AUDIO\ICON.SYS"
echo MD5 not Match Your file is probably corrupted
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
 ) 


REM __sysconf\ICON\HTML\HTML.ICO
if not exist "%~dp0HDD-OSD\__sysconf\ICON\HTML\HTML.ICO" (
"%~dp0BAT\Diagbox" gd 0c
echo Files "HDD-OSD\__sysconf\ICON\HTML\HTML.ICO" 
echo Missing
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
)

set file=%~dp0HDD-OSD\__sysconf\ICON\HTML\HTML.ICO
"%~dp0BAT\busybox" md5sum "%file%" | "%~dp0BAT\busybox" grep -o "[0-9a-f]\{32\}" > "%~dp0TMP\MD5.txt" & set /p MD5=<"%~dp0TMP\MD5.txt"

if %md5% equ 3cb7f0536457667b87c98dfc3a9c615f (
"%~dp0BAT\Diagbox" gd 0e
echo Files "HDD-OSD\__sysconf\ICON\HTML\HTML.ICO"      
"%~dp0BAT\Diagbox" gd 0a      
echo %md5% Confirmed
echo\
   ) else (
"%~dp0BAT\Diagbox" gd 0c
echo Files "HDD-OSD\__sysconf\ICON\HTML\HTML.ICO"
echo MD5 not Match Your file is probably corrupted
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
 )

REM __sysconf\ICON\HTML\ICON.SYS
if not exist "%~dp0HDD-OSD\__sysconf\ICON\HTML\ICON.SYS" (
"%~dp0BAT\Diagbox" gd 0c
echo Files "HDD-OSD\__sysconf\ICON\HTML\ICON.SYS" 
echo Missing
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
)

set file=%~dp0HDD-OSD\__sysconf\ICON\HTML\ICON.SYS
"%~dp0BAT\busybox" md5sum "%file%" | "%~dp0BAT\busybox" grep -o "[0-9a-f]\{32\}" > "%~dp0TMP\MD5.txt" & set /p MD5=<"%~dp0TMP\MD5.txt"

if %md5% equ b8759abc47cf4c46f7d4c3891a44faec (
"%~dp0BAT\Diagbox" gd 0e
echo Files "HDD-OSD\__sysconf\ICON\HTML\ICON.SYS"      
"%~dp0BAT\Diagbox" gd 0a      
echo %md5% Confirmed
echo\
   ) else (
"%~dp0BAT\Diagbox" gd 0c
echo Files "HDD-OSD\__sysconf\ICON\HTML\ICON.SYS"
echo MD5 not Match Your file is probably corrupted
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
 )

REM __sysconf\ICON\IMAGE\IMAGE.ICO
if not exist "%~dp0HDD-OSD\__sysconf\ICON\IMAGE\IMAGE.ICO" (
"%~dp0BAT\Diagbox" gd 0c
echo Files "HDD-OSD\__sysconf\ICON\IMAGE\IMAGE.ICO" 
echo Missing
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
)

set file=%~dp0HDD-OSD\__sysconf\ICON\IMAGE\IMAGE.ICO
"%~dp0BAT\busybox" md5sum "%file%" | "%~dp0BAT\busybox" grep -o "[0-9a-f]\{32\}" > "%~dp0TMP\MD5.txt" & set /p MD5=<"%~dp0TMP\MD5.txt"

if %md5% equ f0e2c7768b367b96ff37752a39ce9cf5 (
"%~dp0BAT\Diagbox" gd 0e
echo Files "HDD-OSD\__sysconf\ICON\IMAGE\IMAGE.ICO"      
"%~dp0BAT\Diagbox" gd 0a      
echo %md5% Confirmed
echo\
   ) else (
"%~dp0BAT\Diagbox" gd 0c
echo Files "HDD-OSD\__sysconf\ICON\IMAGE\IMAGE.ICO"
echo MD5 not Match Your file is probably corrupted
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
 )

REM __sysconf\ICON\IMAGE\ICON.SYS
if not exist "%~dp0HDD-OSD\__sysconf\ICON\IMAGE\ICON.SYS" (
"%~dp0BAT\Diagbox" gd 0c
echo Files "HDD-OSD\__sysconf\ICON\IMAGE\ICON.SYS" 
echo Missing
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
)

set file=%~dp0HDD-OSD\__sysconf\ICON\IMAGE\ICON.SYS
"%~dp0BAT\busybox" md5sum "%file%" | "%~dp0BAT\busybox" grep -o "[0-9a-f]\{32\}" > "%~dp0TMP\MD5.txt" & set /p MD5=<"%~dp0TMP\MD5.txt"

if %md5% equ 35a674261d885a875db976900b945181 (
"%~dp0BAT\Diagbox" gd 0e
echo Files "HDD-OSD\__sysconf\ICON\IMAGE\ICON.SYS"      
"%~dp0BAT\Diagbox" gd 0a      
echo %md5% Confirmed
echo\
   ) else (
"%~dp0BAT\Diagbox" gd 0c
echo Files "HDD-OSD\__sysconf\ICON\IMAGE\ICON.SYS"
echo MD5 not Match Your file is probably corrupted
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
 )
 
REM __sysconf\ICON\TEXT\TEXT.ICO
if not exist "%~dp0HDD-OSD\__sysconf\ICON\TEXT\TEXT.ICO" (
"%~dp0BAT\Diagbox" gd 0c
echo Files "HDD-OSD\__sysconf\ICON\TEXT\TEXT.ICO" 
echo Missing
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
)

set file=%~dp0HDD-OSD\__sysconf\ICON\TEXT\TEXT.ICO
"%~dp0BAT\busybox" md5sum "%file%" | "%~dp0BAT\busybox" grep -o "[0-9a-f]\{32\}" > "%~dp0TMP\MD5.txt" & set /p MD5=<"%~dp0TMP\MD5.txt"

if %md5% equ 555b113797ad185d4187e17e27df9c9e (
"%~dp0BAT\Diagbox" gd 0e
echo Files "HDD-OSD\__sysconf\ICON\TEXT\TEXT.ICO"      
"%~dp0BAT\Diagbox" gd 0a      
echo %md5% Confirmed
echo\
   ) else (
"%~dp0BAT\Diagbox" gd 0c
echo Files "HDD-OSD\__sysconf\ICON\TEXT\TEXT.ICO"
echo MD5 not Match Your file is probably corrupted
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
 )

REM __sysconf\ICON\TEXT\ICON.SYS
if not exist "%~dp0HDD-OSD\__sysconf\ICON\TEXT\ICON.SYS" (
"%~dp0BAT\Diagbox" gd 0c
echo Files "HDD-OSD\__sysconf\ICON\TEXT\ICON.SYS" 
echo Missing
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
)

set file=%~dp0HDD-OSD\__sysconf\ICON\TEXT\ICON.SYS
"%~dp0BAT\busybox" md5sum "%file%" | "%~dp0BAT\busybox" grep -o "[0-9a-f]\{32\}" > "%~dp0TMP\MD5.txt" & set /p MD5=<"%~dp0TMP\MD5.txt"

if %md5% equ 6bbe982a18e25d7d7863a741f56e0e2a (
"%~dp0BAT\Diagbox" gd 0e
echo Files "HDD-OSD\__sysconf\ICON\TEXT\ICON.SYS"      
"%~dp0BAT\Diagbox" gd 0a      
echo %md5% Confirmed
echo\
   ) else (
"%~dp0BAT\Diagbox" gd 0c
echo Files "HDD-OSD\__sysconf\ICON\TEXT\ICON.SYS"
echo MD5 not Match Your file is probably corrupted
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
 )
 
REM __sysconf\ICON\VIDEO\VIDEO.ICO
if not exist "%~dp0HDD-OSD\__sysconf\ICON\VIDEO\VIDEO.ICO" (
"%~dp0BAT\Diagbox" gd 0c
echo Files "HDD-OSD\__sysconf\ICON\VIDEO\VIDEO.ICO" 
echo Missing
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
)

set file=%~dp0HDD-OSD\__sysconf\ICON\VIDEO\VIDEO.ICO
"%~dp0BAT\busybox" md5sum "%file%" | "%~dp0BAT\busybox" grep -o "[0-9a-f]\{32\}" > "%~dp0TMP\MD5.txt" & set /p MD5=<"%~dp0TMP\MD5.txt"

if %md5% equ 1bb1f10cb944212ce602eb317a85cef0 (
"%~dp0BAT\Diagbox" gd 0e
echo Files "HDD-OSD\__sysconf\ICON\VIDEO\VIDEO.ICO"      
"%~dp0BAT\Diagbox" gd 0a      
echo %md5% Confirmed
echo\
   ) else (
"%~dp0BAT\Diagbox" gd 0c
echo Files "HDD-OSD\__sysconf\ICON\VIDEO\VIDEO.ICO"
echo MD5 not Match Your file is probably corrupted
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
 )
 
REM __sysconf\ICON\VIDEO\ICON.SYS
if not exist "%~dp0HDD-OSD\__sysconf\ICON\VIDEO\ICON.SYS" (
"%~dp0BAT\Diagbox" gd 0c
echo Files "HDD-OSD\__sysconf\ICON\VIDEO\ICON.SYS" 
echo Missing
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
)

set file=%~dp0HDD-OSD\__sysconf\ICON\VIDEO\ICON.SYS
"%~dp0BAT\busybox" md5sum "%file%" | "%~dp0BAT\busybox" grep -o "[0-9a-f]\{32\}" > "%~dp0TMP\MD5.txt" & set /p MD5=<"%~dp0TMP\MD5.txt"

if %md5% equ e99de68551b255f180ade8e64d812d2b (
"%~dp0BAT\Diagbox" gd 0e
echo Files "HDD-OSD\__sysconf\ICON\VIDEO\ICON.SYS"      
"%~dp0BAT\Diagbox" gd 0a      
echo %md5% Confirmed
echo\
   ) else (
"%~dp0BAT\Diagbox" gd 0c
echo Files "HDD-OSD\__sysconf\ICON\VIDEO\ICON.SYS"
echo MD5 not Match Your file is probably corrupted
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
 )

"%~dp0BAT\Diagbox" gd 0f
pause

"%~dp0BAT\Diagbox" gd 0e
cls
echo\
echo\
echo Scanning for Playstation 2 HDDs:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "Playstation 2 HDD"
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "Playstation 2 HDD" | "%~dp0BAT\busybox" grep -o "hdd[0-9]:\|hdd[0-9][0-9]:" > "%~dp0TMP\hdl-hdd.txt" & "%~dp0BAT\busybox" cat "%~dp0TMP\hdl-hdd.txt" > "%~dp0TMP\hdl-hdd2.txt"
"%~dp0BAT\busybox" sed -i "s/hdd/\\\\.\\\PhysicalDrive/g; s/://g" "%~dp0TMP\hdl-hdd.txt" >nul 2>&1

set /P @hdl_path2=<"%~dp0TMP\hdl-hdd2.txt"
set /P @hdl_path=<"%~dp0TMP\hdl-hdd.txt"
del "%~dp0TMP\hdl-hdd.txt" >nul 2>&1
IF "!@hdl_path!"=="" ( 
"%~dp0BAT\Diagbox" gd 0c
		echo         Playstation 2 HDD Not Detected
		echo         Drive Must Be Formatted First
		echo\
		echo\
"%~dp0BAT\Diagbox" gd 07
		rmdir /Q/S "%~dp0TMP" >nul 2>&1
        pause & (goto HDDOSDMenu)
	)

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Install HDD-OSD: (Browser 2.0)
"%~dp0BAT\Diagbox" gd 0f
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1) Yes
"%~dp0BAT\Diagbox" gd 0c
echo         2) No
"%~dp0BAT\Diagbox" gd 0f
echo\
CHOICE /C 12 /M "Select Option:"

IF %ERRORLEVEL%==1 set @pfs_installhddosd=yes
IF %ERRORLEVEL%==2 set @pfs_installhddosd=no & (goto HDDOSDMenu)

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Change default partition?
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
echo Detecting __sysconf Partition:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0f

	echo device !@hdl_path! > "%~dp0TMP\pfs-prt.txt"
	echo ls >> "%~dp0TMP\pfs-prt.txt"
	echo exit >> "%~dp0TMP\pfs-prt.txt"
	type "%~dp0TMP\pfs-prt.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" tee > "%~dp0TMP\pfs-prt.log"
	"%~dp0BAT\busybox" grep -o "__sysconf/" "%~dp0TMP\pfs-prt.log" | "%~dp0BAT\busybox" head -1 > "%~dp0TMP\hdd-prt.txt"
	
	set /P @hdd_avl=<"%~dp0TMP\hdd-prt.txt"
	IF "!@hdd_avl!"=="__sysconf/" (
	"%~dp0BAT\Diagbox" gd 0a
		echo         __sysconf - Partition Detected
		) else (
		"%~dp0BAT\Diagbox" gd 0c
		echo         __sysconf - Partition NOT Detected
		echo         Partition Must Be Formatted Or Created
		echo\
		echo\
		rmdir /Q/S "%~dp0TMP" >nul 2>&1
		pause & (goto HDDOSDMenu)
		)

"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Detecting __system Partition:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0f

	"%~dp0BAT\busybox" grep -o "__system/" "%~dp0TMP\pfs-prt.log" > "%~dp0TMP\hdd-prt.txt"
	
	set /P @hdd_avl=<"%~dp0TMP\hdd-prt.txt"
	IF "!@hdd_avl!"=="__system/" (
	"%~dp0BAT\Diagbox" gd 0a
		echo         __system - Partition Detected
		"%~dp0BAT\Diagbox" gd 0c
		) else (
		echo         __system - Partition NOT Detected
		echo         Partition Must Be Formatted Or Created
		echo\
		echo\
		rmdir /Q/S "%~dp0TMP" >nul 2>&1
	    pause & (goto HDDOSDMenu)
		)

"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Detecting %OPLPART% Partition:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0f

    "%~dp0BAT\busybox" grep -o "%OPLPART%/" "%~dp0TMP\pfs-prt.log" > "%~dp0TMP\hdd-prt.txt"

	set /P @hdd_avl=<"%~dp0TMP\hdd-prt.txt"
	IF "!@hdd_avl!"=="%OPLPART%/" (
	"%~dp0BAT\Diagbox" gd 0a
		echo         %OPLPART% - Partition Detected
		) else (
		"%~dp0BAT\Diagbox" gd 0c
		echo         %OPLPART% - Partition NOT Detected
		echo         Partition Must Be Formatted Or Created
		echo\
		echo\
		rmdir /Q/S "%~dp0TMP" >nul 2>&1
		pause & (goto HDDOSDMenu)
		)

"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Detecting FreeHDBoot:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0f

	echo device !@hdl_path! > "%~dp0TMP\pfs-prt.txt"
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
echo Installing HDD-OSD:
echo ----------------------------------------------------
echo\

REM __sysconf
IF /I EXIST "%~dp0HDD-OSD\__sysconf\*" (
	cd "%~dp0HDD-OSD\__sysconf"

	REM MOUNT __sysconf

	echo device !@hdl_path! > "%~dp0TMP\pfs-hddosd.txt"
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
	cd "%~dp0"
    )

    REM __SYSTEM 
	IF /I EXIST "%~dp0HDD-OSD\__system\*" (
	cd "%~dp0HDD-OSD\__system"

	REM MOUNT __SYSTEM

	echo device !@hdl_path! > "%~dp0TMP\pfs-hddosd.txt"
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
    cd "%~dp0HDD-OSD\__common\OPL"
    echo device !@hdl_path! > "%~dp0TMP\pfs-hddosd.txt"
	echo mount __common >> "%~dp0TMP\pfs-hddosd.txt"
	echo mkdir OPL >> "%~dp0TMP\pfs-hddosd.txt"
	echo cd OPL >> "%~dp0TMP\pfs-hddosd.txt"
 	echo put conf_hdd.cfg >> "%~dp0TMP\pfs-hddosd.txt"
    echo umount >> "%~dp0TMP\pfs-hddosd.txt"
	echo exit >> "%~dp0TMP\pfs-hddosd.txt"
	type "%~dp0TMP\pfs-hddosd.txt" | "%~dp0BAT\pfsshell" >nul 2>&1

    cd "%~dp0HDD-OSD"
    echo device !@hdl_path! > "%~dp0TMP\pfs-hddosd.txt"
	echo mount %OPLPART% >> "%~dp0TMP\pfs-hddosd.txt"
	if defined CHOICEPART echo mkdir OPL >> "%~dp0TMP\pfs-hddosd.txt"
    if defined CHOICEPART echo cd OPL >> "%~dp0TMP\pfs-hddosd.txt"
 	echo put OPNPS2LD.ELF >> "%~dp0TMP\pfs-hddosd.txt"
    echo umount >> "%~dp0TMP\pfs-hddosd.txt"
	echo exit >> "%~dp0TMP\pfs-hddosd.txt"
	type "%~dp0TMP\pfs-hddosd.txt" | "%~dp0BAT\pfsshell" >nul 2>&1
	cd "%~dp0"
	echo         HDD-OSD Completed...
	)
 
if defined CHOICEPP (

    "%~dp0BAT\busybox" sed -i -e "s/\hdd_partition=.*/hdd_partition=/g; s/hdd_partition=/hdd_partition=%OPLPART%/g" "%~dp0HDD-OSD\__common\OPL\conf_hdd.cfg"
	cd "%~dp0HDD-OSD\__common\OPL"
    echo device %@hdl_path% > "%~dp0TMP\pfs-OPLCONFIG.txt"
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

rmdir /Q/S "%~dp0TMP" >nul 2>&1

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
cd /d "%~dp0"
mkdir "%~dp0TMP" >nul 2>&1

"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning for Playstation 2 HDDs:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "Playstation 2 HDD"
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "Playstation 2 HDD" | "%~dp0BAT\busybox" grep -o "hdd[0-9]:\|hdd[0-9][0-9]:" > "%~dp0TMP\hdl-hdd.txt"
"%~dp0BAT\busybox" sed -i "s/hdd/\\\\.\\\PhysicalDrive/g; s/://g" "%~dp0TMP\hdl-hdd.txt" >nul 2>&1

set /P @hdl_path=<"%~dp0TMP\hdl-hdd.txt"
del "%~dp0TMP\hdl-hdd.txt" >nul 2>&1
IF "!@hdl_path!"=="" (
"%~dp0BAT\Diagbox" gd 0c
		echo         Playstation 2 HDD Not Detected
		echo         Drive Must Be Formatted First
		echo\
		echo\
"%~dp0BAT\Diagbox" gd 07
		rmdir /Q/S "%~dp0TMP" >nul 2>&1
        pause & (goto HDDOSDMenu)
	)
	

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Uninstall HDD-OSD:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1) Yes
"%~dp0BAT\Diagbox" gd 0c
echo         2) No
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

	echo device !@hdl_path! > "%~dp0TMP\pfs-prt.txt"
	echo ls >> "%~dp0TMP\pfs-prt.txt"
	echo exit >> "%~dp0TMP\pfs-prt.txt"
	type "%~dp0TMP\pfs-prt.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" tee > "%~dp0TMP\pfs-prt.log"
	"%~dp0BAT\busybox" grep -o "__sysconf/" "%~dp0TMP\pfs-prt.log" | "%~dp0BAT\busybox" head -1 > "%~dp0TMP\hdd-prt.txt"
	
	set /P @hdd_avl=<"%~dp0TMP\hdd-prt.txt"
	IF "!@hdd_avl!"=="__sysconf/" (
	"%~dp0BAT\Diagbox" gd 0a
		echo         __sysconf - Partition Detected
		) else (
		"%~dp0BAT\Diagbox" gd 0c
		echo         __sysconf - Partition NOT Detected
		echo         Partition Must Be Formatted Or Created
		echo\
		echo\
		rmdir /Q/S "%~dp0TMP" >nul 2>&1
		pause & (goto HDDOSDMenu)
		)

"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Detecting __system Partition:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0f

	"%~dp0BAT\busybox" grep -o "__system/" "%~dp0TMP\pfs-prt.log" > "%~dp0TMP\hdd-prt.txt"
	
	set /P @hdd_avl=<"%~dp0TMP\hdd-prt.txt"
	IF "!@hdd_avl!"=="__system/" (
	"%~dp0BAT\Diagbox" gd 0a
		echo         __system - Partition Detected
		"%~dp0BAT\Diagbox" gd 0c
		) else (
		echo         __system - Partition NOT Detected
		echo         Partition Must Be Formatted Or Created
		echo\
		echo\
		rmdir /Q/S "%~dp0TMP" >nul 2>&1
		pause & (goto HDDOSDMenu)
		)

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
pause
cls

IF %@pfs_uninhddosd%==yes (
echo\
echo\
echo Uninstall HDD-OSD:
echo ----------------------------------------------------
echo\

    REM __sysconf	
    echo        Uninstall HDD-OSD...
  	echo device %@hdl_path% > "%~dp0TMP\pfs-hddosd.txt"
	echo mount __sysconf >> "%~dp0TMP\pfs-hddosd.txt"
	
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
	cd "%~dp0"

    REM __system 
  	echo device %@hdl_path% > "%~dp0TMP\pfs-hddosd.txt"
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
	echo cd .. >> "%~dp0TMP\pfs-hddosd.txt"
	echo rmdir fsck100 >> "%~dp0TMP\pfs-hddosd.txt"
	
	echo umount >> "%~dp0TMP\pfs-hddosd.txt"
	echo exit >> "%~dp0TMP\pfs-hddosd.txt"
	type "%~dp0TMP\pfs-hddosd.txt" | "%~dp0BAT\pfsshell" >nul 2>&1
	echo        Uninstall Completed...	
	) else ( echo         HDDOSD - Uninstall Canceled... )

cd "%~dp0" & rmdir /Q/S "%~dp0TMP" >nul 2>&1

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
copy "%~dp0BAT\system.cnf" "%~dp0TMP" >nul 2>&1
copy "%~dp0BAT\hdl_dump.exe" "%~dp0TMP" >nul 2>&1

"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning for Playstation 2 HDDs:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "Playstation 2 HDD"
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "Playstation 2 HDD" | "%~dp0BAT\busybox" grep -o "hdd[0-9]:\|hdd[0-9][0-9]:" > "%~dp0TMP\hdl-hdd.txt"

set /P @hdl_path=<"%~dp0TMP\hdl-hdd.txt"
del "%~dp0TMP\hdl-hdd.txt" >nul 2>&1
IF "!@hdl_path!"=="" (
"%~dp0BAT\Diagbox" gd 0c
		echo         Playstation 2 HDD Not Detected
		echo         Drive Must Be Formatted First
		echo\
		echo\
"%~dp0BAT\Diagbox" gd 07
		rmdir /Q/S "%~dp0TMP" >nul 2>&1
        pause & (goto HDDOSDPartManagement)
	)

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Inject OPL-Launcher (boot.kelf) ?
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1) Yes (For every installed game) 
"%~dp0BAT\Diagbox" gd 0c
echo         2) No
"%~dp0BAT\Diagbox" gd 0e
echo         3) Yes (Manually)
"%~dp0BAT\Diagbox" gd 07
echo\
CHOICE /C 123 /M "Select Option:"

IF %ERRORLEVEL%==1 set @pfs_ppinjectkelf=yes
IF %ERRORLEVEL%==2 (goto HDDOSDPartManagement)
IF %ERRORLEVEL%==3 set @pfs_ppinjectkelfmanually=yes

"%~dp0BAT\Diagbox" gd 0e
cls
echo\
echo\
echo Games List:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03

"%~dp0BAT\hdl_dump" hdl_toc %@hdl_path% > "%~dp0TMP\PARTITION_GAMES.txt"

"%~dp0BAT\busybox" sed -i "1d" "%~dp0TMP\PARTITION_GAMES.txt"
"%~dp0BAT\busybox" sed -i -e "$ d" "%~dp0TMP\PARTITION_GAMES.txt"
"%~dp0BAT\busybox" cut -c35-500 "%~dp0TMP\PARTITION_GAMES.txt" | "%~dp0BAT\busybox" sort -k2 > "%~dp0TMP\PARTITION_GAMES_NEW.txt"

type "%~dp0TMP\PARTITION_GAMES_NEW.txt"
"%~dp0BAT\Diagbox" gd 0e
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03

if defined @pfs_ppinjectkelf (

for /f "tokens=1*" %%M in (PARTITION_GAMES_NEW.txt) do (
setlocal DisableDelayedExpansion
set GName=%%N
setlocal EnableDelayedExpansion

"%~dp0BAT\Diagbox" gd 0f
echo\
echo %%N
"%~dp0BAT\Diagbox" gd 03
hdl_dump modify_header %@hdl_path% "!GName!" | findstr "Successfully"
echo\
 endlocal
endlocal
"%~dp0BAT\Diagbox" gd 0f
 )
)

if defined @pfs_ppinjectkelfmanually (

echo Copy Name of the game. Example: Half-Life
echo.
"%~dp0BAT\Diagbox" gd 0f

set /p "ppinjectkelf=Enter the game name you want to Launch in HDD-OSD:"
IF "!ppinjectkelf!"=="" (goto HDDOSDPartManagement)

cls
echo\
echo\
echo Inject boot.kelf !ppinjectkelf! Partition:
echo ----------------------------------------------------
echo\

    echo        Inject boot.kelf in partitions...
	"%~dp0BAT\Diagbox" gd 03
	"%~dp0BAT\hdl_dump" modify_header !@hdl_path! "!ppinjectkelf!" | findstr "Successfully"
	"%~dp0BAT\Diagbox" gd 0f
	echo.
	)

echo\
echo\
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo Injection Completed...
echo\
echo\
"%~dp0BAT\Diagbox" gd 07

cd "%~dp0" & rmdir /Q/S "%~dp0TMP" >nul 2>&1

echo.
pause & (goto HDDOSDPartManagement)
REM ##################################################################################################################################################
:ConvertGamesBBNXMB

cls
mkdir "%~dp0TMP" >nul 2>&1
mkdir "%~dp0TMP\PP.HEADER" >nul 2>&1
cd /d "%~dp0TMP"

copy "%~dp0BAT\boot.kelf" "%~dp0TMP\PP.HEADER" >nul 2>&1
copy "%~dp0BAT\boot.kelf" "%~dp0TMP\PP.HEADER\EXECUTE.KELF" >nul 2>&1
copy "%~dp0BAT\system.cnf" "%~dp0TMP\PP.HEADER" >nul 2>&1
copy "%~dp0BAT\hdl_dump.exe" "%~dp0TMP\PP.HEADER" >nul 2>&1

"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning for Playstation 2 HDDs:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "Playstation 2 HDD"
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "Playstation 2 HDD" | "%~dp0BAT\busybox" grep -o "hdd[0-9]:\|hdd[0-9][0-9]:" > "%~dp0TMP\hdl-hdd.txt" & "%~dp0BAT\busybox" cat "%~dp0TMP\hdl-hdd.txt" > "%~dp0TMP\hdl-hdd2.txt"
"%~dp0BAT\busybox" sed -i "s/hdd/\\\\.\\\PhysicalDrive/g; s/://g" "%~dp0TMP\hdl-hdd2.txt" >nul 2>&1

set /P @hdl_path2=<"%~dp0TMP\hdl-hdd2.txt"
set /P @hdl_path=<"%~dp0TMP\hdl-hdd.txt"
del "%~dp0TMP\hdl-hdd.txt" >nul 2>&1
IF "!@hdl_path!"=="" (
"%~dp0BAT\Diagbox" gd 0c
		echo         Playstation 2 HDD Not Detected
		echo         Drive Must Be Formatted First
		echo\
		echo\
"%~dp0BAT\Diagbox" gd 07
		rmdir /Q/S "%~dp0TMP" >nul 2>&1
        pause & (goto HDDOSDPartManagement)
	    )

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Convert a PS2 Game for PSBBN ^& XMB Menu ?
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1) Yes
"%~dp0BAT\Diagbox" gd 0c
echo         2) No
"%~dp0BAT\Diagbox" gd 07
echo\
CHOICE /C 12 /M "Select Option:"

IF %ERRORLEVEL%==1 set @convPS2Games=yes
IF %ERRORLEVEL%==2 (goto HDDOSDPartManagement)

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
if %errorlevel%==1 set language=english & copy "%~dp0BAT\TitlesDB\gameidPS2ENG.txt" "%~dp0TMP\gameid.txt" >nul 2>&1
if %errorlevel%==2 set language=french & copy "%~dp0BAT\TitlesDB\gameidPS2FRA.txt" "%~dp0TMP\gameid.txt" >nul 2>&1

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
	"%~dp0BAT\wget" -q --show-progress "https://archive.org/download/OPLM_ART_2022_05/OPLM_ART_2022_05.zip/PS1%%2FSCES_000.01%%2FSCES_000.01_COV.jpg" -O "%~dp0TMP\SCES_000.01_COV.jpg" >nul 2>&1
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

cd /d "%~dp0TMP\PP.HEADER"
"%~dp0BAT\Diagbox" gd 0e
cls
echo\
echo\
echo Partition PS2 Games List:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03

   "%~dp0BAT\hdl_dump" toc %@hdl_path% | "%~dp0BAT\busybox" grep "0x1337" | "%~dp0BAT\busybox" sed "/__\./d" | "%~dp0BAT\busybox" cut -c30-250 | "%~dp0BAT\busybox" sed "s/.\{15\}/& /" | "%~dp0BAT\busybox" sort -k2 | "%~dp0BAT\busybox" sed -e "s/\(.\{15\}\)./\1/" | "%~dp0BAT\busybox" sed "/__\./d" > "%~dp0LOG\PARTITION_PS2_GAMES_NON_HIDDEN.txt"
	type "%~dp0LOG\PARTITION_PS2_GAMES_NON_HIDDEN.txt"

"%~dp0BAT\Diagbox" gd 0e
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 06
     echo\
	 echo Keep in mind that each conversion will create a 128MB partition for each game
	 echo\
"%~dp0BAT\Diagbox" gd 0f
     set /p "PPNameHeader=Enter the partition name:"
     IF "!PPNameHeader!"=="" (goto HDDOSDPartManagement)
	 
"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Detecting !PPNameHeader! Partition:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 07

    "%~dp0BAT\busybox" grep -ow "!PPNameHeader!" "%~dp0LOG\PARTITION_PS2_GAMES_NON_HIDDEN.txt" | "%~dp0BAT\busybox" head -1 > "%~dp0TMP\PPSelected.txt"
	if %errorlevel%==0 (
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

"%~dp0BAT\Diagbox" gd 0e
cls
echo\
echo\
echo Conversion !PPNameHeader! Partition:
echo ----------------------------------------------------
echo\
"%~dp0BAT\Diagbox" gd 0f

     "%~dp0BAT\busybox" grep -o "[A-Z][A-Z][A-Z][A-Z]-[0-9][0-9][0-9][0-9][0-9]" "%~dp0TMP\PPSelected.txt" > "%~dp0TMP\DetectID.txt" & set /P gameid2=<"%~dp0TMP\DetectID.txt"
	 if not defined gameid2 (
	 "%~dp0BAT\Diagbox" gd 0c
	 echo ERROR: NO GAMEID Detected^! Bad partition name
	 echo Please Reinstall game or rename partition with wLaunchELF
	 echo\
	 "%~dp0BAT\Diagbox" gd 06
     echo Your partition name should look like this: PP.SLES-12345..GAME_NAME
     echo\
	 echo\
	 "%~dp0BAT\Diagbox" gd 0f
	 pause & goto HDDOSDPartManagement )
	 
     echo !gameid2!| "%~dp0BAT\busybox" sed "s/-/_/g" | "%~dp0BAT\busybox" sed "s/.\{8\}/&./" > "%~dp0TMP\DetectID.txt" & set /P gameid=<"%~dp0TMP\DetectID.txt"
	
	"%~dp0BAT\hdl_dump_fix" dump_header %@hdl_path% "!PPNameHeader!" >nul 2>&1
	"%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0BAT\HDD-PSBBN_XMB_SAMPLE_HEADER.zip" -o"%~dp0TMP\PP.HEADER" -r -y >nul 2>&1

	 echo         Getting game information...
	 chcp 65001 >nul 2>&1
	 set "dbtitleTMP="
 	 for /f "tokens=1*" %%A in ( 'findstr !gameid! "%~dp0TMP\gameid.txt"' ) do (if not defined dbtitleTMP set dbtitleTMP=%%B
	 chcp 1252 >nul 2>&1
	 echo "!dbtitleTMP!" > "%~dp0TMP\dbtitle.txt")

	"%~dp0BAT\wget" -q --show-progress https://psxdatacenter.com/psx2/games2/!gameid2!.html 2>&1 -O "%~dp0TMP\!gameid2!.html" >nul 2>&1
	if errorlevel 1 ( "%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0BAT\PSBBN_XMB_PS2_GAMEINFO_Database.7z" -o"%~dp0TMP" !gameid2!.html -r -y)
	
    "%~dp0BAT\busybox" grep -A2 "DATE RELEASED" "%~dp0TMP\!gameid2!.html" | "%~dp0BAT\busybox" sed "/DATE RELEASED/d; /<td style=/d" | "%~dp0BAT\busybox" sed "s/^.*;//g; s/<\/td>//g; s|[\t][\t][\t]*||g; s/\s*$//" | "%~dp0BAT\busybox" sed -e "2,20d" > "%~dp0TMP\RELEASE.txt" & set /P RELEASETMP=<"%~dp0TMP\RELEASE.txt"
    REM "%~dp0BAT\busybox" grep -A2 "REGION" "%~dp0TMP\!gameid2!.html" | "%~dp0BAT\busybox" sed "/REGION/d; /<td style=/d" | "%~dp0BAT\busybox" sed "s/^.*;//g; s/<\/td>//g; s|[\t][\t][\t]*||g; s/\s*$//" | "%~dp0BAT\busybox" sed -e "2,20d" > "%~dp0TMP\REGION.txt" & set /P REGIONTMP=<"%~dp0TMP\REGION.txt"
	"%~dp0BAT\busybox" grep -A2 "DEVELOPER" "%~dp0TMP\!gameid2!.html" | "%~dp0BAT\busybox" sed "/DEVELOPER/d; /<td style=/d" | "%~dp0BAT\busybox" sed "s/^.*;//g; s/<\/td>//g; s|[\t][\t][\t]*||g; s/\s*$//" | "%~dp0BAT\busybox" sed -e "2,20d" > "%~dp0TMP\DEVELOPER.txt" & set /P DEVELOPERTMP=<"%~dp0TMP\DEVELOPER.txt"
    "%~dp0BAT\busybox" grep -A2 "PUBLISHER" "%~dp0TMP\!gameid2!.html" | "%~dp0BAT\busybox" sed "/PUBLISHER/d; /<td style=/d" | "%~dp0BAT\busybox" sed "s/^.*;//g; s/<\/td>//g; s|[\t][\t][\t]*||g; s/\s*$//" | "%~dp0BAT\busybox" sed -e "2,20d" > "%~dp0TMP\PUBLISHER.txt" & set /P PUBLISHERTMP=<"%~dp0TMP\PUBLISHER.txt"
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
	 REM A = Asie
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
	 if not defined REGIONTMP set REGIONTMP=X
	 
	 if %language%==french ("%~dp0BAT\busybox" sed -i "s/January/Janvier/g; s/February/F?ier/g; s/March/Mars/g; s/April/Avril/g; s/May/Mai/g; s/June/Juin/g; s/July/Juillet/g; s/August/Aout/g; s/September/Septembre/g; s/October/Octobre/g; s/November/Novembre/g; s/December/D?mbre/g" "%~dp0TMP\RELEASE.txt" & set /P RELEASETMP=<"%~dp0TMP\RELEASE.txt")
	 
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
	 echo Release date not found in database, please enter a Release Date: 4 March 2000
	 set /p "RELEASETMP=Enter the Release:"
	 )
     echo "!RELEASETMP!"| "%~dp0BAT\busybox" sed -e "s/\&/\\\&/g; s./.\\\/.g" | "%~dp0BAT\busybox" iconv -f windows-1252 -t utf-8 > "%~dp0TMP\RELEASE.txt"
	 "%~dp0BAT\busybox" sed -i "s/\"//g" "%~dp0TMP\RELEASE.txt"
	 set /P RELEASE=<"%~dp0TMP\RELEASE.txt"
	 
	 if not defined DEVELOPERTMP (
	 echo\
	 echo Developer not found in database, please enter a Developer
	 set /p "DEVELOPERTMP=Enter the Developer:"
	 )
     echo "!DEVELOPERTMP!"| "%~dp0BAT\busybox" sed -e "s/\&/\\\&/g; s./.\\\/.g" | "%~dp0BAT\busybox" iconv -f windows-1252 -t utf-8 > "%~dp0TMP\DEVELOPER.txt"
	 "%~dp0BAT\busybox" sed -i "s/\"//g" "%~dp0TMP\DEVELOPER.txt"
	 set /P DEVELOPER=<"%~dp0TMP\DEVELOPER.txt"
	 
	 if not defined PUBLISHERTMP (
	 echo\
	 echo Publisher not found in database, please enter a Publisher
	 set /p "PUBLISHERTMP=Enter the Publisher:"
	 )
     echo "!PUBLISHERTMP!"| "%~dp0BAT\busybox" sed -e "s/\&/\\\&/g; s./.\\\/.g" | "%~dp0BAT\busybox" iconv -f windows-1252 -t utf-8 > "%~dp0TMP\PUBLISHER.txt"
	 "%~dp0BAT\busybox" sed -i "s/\"//g" "%~dp0TMP\PUBLISHER.txt"
	 set /P PUBLISHER=<"%~dp0TMP\PUBLISHER.txt"
	 
	 if not defined GENRETMP (
	 echo\
	 echo Genre not found in database, please enter Genre: Action, Racing, RPG
	 set /p "GENRETMP=Enter the Genre:"
	 echo\
	 )
     echo "!GENRETMP!"| "%~dp0BAT\busybox" sed -e "s/\&/\\\&/g; s./.\\\/.g" | "%~dp0BAT\busybox" iconv -f windows-1252 -t utf-8 > "%~dp0TMP\GENRE.txt"
	 "%~dp0BAT\busybox" sed -i "s/\"//g" "%~dp0TMP\GENRE.txt"
	 set /P GENRE=<"%~dp0TMP\GENRE.txt"
	 
     "%~dp0BAT\busybox" sed -i -e "s/title =.*/title =/g; s/title =/title = !dbtitle!/g" "%~dp0TMP\PP.HEADER\res\info.sys"
 	 "%~dp0BAT\busybox" sed -i -e "s/title_id = .*/title_id =/g; s/title_id =/title_id = !gameid2!/g" "%~dp0TMP\PP.HEADER\res\info.sys"
	 "%~dp0BAT\busybox" sed -i -e "s/area =.*/area =/g; s/area =/area = !REGION!/g" "%~dp0TMP\PP.HEADER\res\info.sys"
	 "%~dp0BAT\busybox" sed -i -e "s/release_date =.*/release_date =/g; s/release_date =/release_date = !RELEASE!/g" "%~dp0TMP\PP.HEADER\res\info.sys"
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
echo\
"%~dp0BAT\Diagbox" gd 0f

     echo            Download covers...
	 
     IF !DownloadART!==yes "%~dp0BAT\wget" -q --show-progress "https://archive.org/download/OPLM_ART_2022_05/OPLM_ART_2022_05.zip/PS2%%2F!gameid!%%2F!gameid!_COV.jpg" -O "%~dp0TMP\jkt_001.jpg" >nul 2>&1
	 IF !uselocalART!==yes if exist "%~dp0ART.zip" "%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0ART.zip" -o"%~dp0TMP" PS2\!gameid!\!gameid!_COV.jpg -r -y & move "%~dp0TMP\PS2\!gameid!\!gameid!_COV.jpg" "%~dp0TMP\jkt_001.jpg" >nul 2>&1
	 IF !DownloadART!==yes "%~dp0BAT\wget" -q --show-progress "https://archive.org/download/OPLM_ART_2022_05/OPLM_ART_2022_05.zip/PS2%%2F!gameid!%%2F!gameid!_BG_00.jpg" -O "%~dp0TMP\BG.jpg" >nul 2>&1
	 IF !uselocalART!==yes if exist "%~dp0ART.zip" "%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0ART.zip" -o"%~dp0TMP" PS2\!gameid!\!gameid!_BG_00.jpg -r -y & move "%~dp0TMP\PS2\!gameid!\!gameid!_BG_00.jpg" "%~dp0TMP\BG.jpg" >nul 2>&1
	 IF !DownloadART!==yes "%~dp0BAT\wget" -q --show-progress "https://archive.org/download/OPLM_ART_2022_05/OPLM_ART_2022_05.zip/PS2%%2F!gameid!%%2F!gameid!_LGO.png" -O "%~dp0TMP\jkt_cp.png" >nul 2>&1
	 IF !uselocalART!==yes if exist "%~dp0ART.zip" "%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0ART.zip" -o"%~dp0TMP" PS2\!gameid!\!gameid!_LGO.png -r -y & move "%~dp0TMP\PS2\!gameid!\!gameid!_LGO.png" "%~dp0TMP\jkt_cp.png" >nul 2>&1
	 IF !DownloadART!==yes "%~dp0BAT\wget" -q --show-progress "https://archive.org/download/OPLM_ART_2022_05/OPLM_ART_2022_05.zip/PS2%%2F!gameid!%%2F!gameid!_SCR_00.jpg" -O "%~dp0TMP\SCR0.jpg" >nul 2>&1
	 IF !uselocalART!==yes if exist "%~dp0ART.zip" "%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0ART.zip" -o"%~dp0TMP" PS2\!gameid!\!gameid!_SCR_00.jpg -r -y & move "%~dp0TMP\PS2\!gameid!\!gameid!_SCR_00.jpg" "%~dp0TMP\SCR0.jpg" >nul 2>&1
	 IF !DownloadART!==yes "%~dp0BAT\wget" -q --show-progress "https://archive.org/download/OPLM_ART_2022_05/OPLM_ART_2022_05.zip/PS2%%2F!gameid!%%2F!gameid!_SCR_01.jpg" -O "%~dp0TMP\SCR1.jpg" >nul 2>&1
	 IF !uselocalART!==yes if exist "%~dp0ART.zip" "%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0ART.zip" -o"%~dp0TMP" PS2\!gameid!\!gameid!_SCR_01.jpg -r -y & move "%~dp0TMP\PS2\!gameid!\!gameid!_SCR_01.jpg" "%~dp0TMP\SCR1.jpg" >nul 2>&1
	 REM IF !uselocalART!==yes "%~dp0BAT\wget" -q --show-progress "https://archive.org/download/OPLM_ART_2022_05/OPLM_ART_2022_05.zip/PS2%%2F!gameid!%%2F!gameid!_SCR_02.jpg" -O "%~dp0TMP\SCR2.jpg" >nul 2>&1
	 REM IF !DownloadART!==yes "%~dp0BAT\wget" -q --show-progress "https://archive.org/download/OPLM_ART_2022_05/OPLM_ART_2022_05.zip/PS2%%2F!gameid!%%2F!gameid!_SCR_03.jpg" -O "%~dp0TMP\SCR3.jpg" >nul 2>&1
	 cd "%~dp0TMP" & for %%F in (*.jpg *.png) do if %%~zF==0 del "%%F"

	 REM Covers
	 if exist "%~dp0TMP\jkt_001.jpg" "%~dp0BAT\nconvert" -overwrite -out png -rtype lanczos -efocus -o "%~dp0TMP\PP.HEADER\res\jkt_001.png" "%~dp0TMP\jkt_001.jpg" >nul 2>&1
	 if exist "%~dp0TMP\jkt_001.jpg" "%~dp0BAT\nconvert" -overwrite -out png -rtype lanczos -efocus -o "%~dp0TMP\PP.HEADER\res\jkt_002.png" "%~dp0TMP\jkt_001.jpg" >nul 2>&1
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
	 
	 echo            Inject Resources Header...
	 echo device %@hdl_path2% > "%~dp0TMP\pfs-headerbbn.txt"
	 echo mkpart "!PPNameHeader!" 128M PFS >> "%~dp0TMP\pfs-headerbbn.txt"
	 echo mount "!PPNameHeader!" >> "%~dp0TMP\pfs-headerbbn.txt"
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
	 )
	 
	 cd /d "%~dp0TMP\PP.HEADER" & hdl_dump modify_header %@hdl_path% "!PPNameHeader!" >nul 2>&1
	 echo            Completed...

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

pause & (goto HDDOSDPartManagement)

REM ##################################################################################################################################################
:pphide

cls
mkdir "%~dp0TMP" >nul 2>&1

"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning for Playstation 2 HDDs:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "Playstation 2 HDD"
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "Playstation 2 HDD" | "%~dp0BAT\busybox" grep -o "hdd[0-9]:\|hdd[0-9][0-9]:" > "%~dp0TMP\hdl-hdd.txt"

set /P @hdl_path=<"%~dp0TMP\hdl-hdd.txt"
REM del "%~dp0TMP\hdl-hdd.txt" >nul 2>&1
IF "!@hdl_path!"=="" ( 
"%~dp0BAT\Diagbox" gd 0c
		echo         Playstation 2 HDD Not Detected
		echo         Drive Must Be Formatted First
		echo\
		echo\
"%~dp0BAT\Diagbox" gd 07
		rmdir /Q/S "%~dp0TMP" >nul 2>&1
        pause & (goto HDDOSDPartManagement)
	)

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\

echo Scan for non-hidden partitions:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1) Yes
"%~dp0BAT\Diagbox" gd 0c
echo         2) No
"%~dp0BAT\Diagbox" gd 0e
REM echo         3) Yes PS1 Games
"%~dp0BAT\Diagbox" gd 07
echo\
CHOICE /C 12 /M "Select Option:"

IF %ERRORLEVEL%==1 set @pfs_pphidePS2Games=yes & set @pfs_pphide=yes
IF %ERRORLEVEL%==2 (goto HDDOSDPartManagement)
IF %ERRORLEVEL%==3 set @pfs_pphidePS1Games=yes & set @pfs_pphide=yes

cls
echo\
echo\
echo Scanning Partitions games non-hidden:
echo ----------------------------------------------------

IF defined @pfs_pphidePS2Games (
    "%~dp0BAT\hdl_dump" toc %@hdl_path% | "%~dp0BAT\busybox" grep "0x1337" | "%~dp0BAT\busybox" cut -c30-250 | "%~dp0BAT\busybox" sed "s/.\{15\}/& /" | "%~dp0BAT\busybox" sort -k2 | "%~dp0BAT\busybox" sed -e "s/\(.\{15\}\)./\1/" | "%~dp0BAT\busybox" sed "/__\./d" > "%~dp0LOG\PARTITION_PS2_GAMES_NON_HIDDEN.txt"
    type "%~dp0LOG\PARTITION_PS2_GAMES_NON_HIDDEN.txt"
	)

IF defined @pfs_pphidePS1Games (
	"%~dp0BAT\hdl_dump" toc %@hdl_path% | "%~dp0BAT\busybox" grep -e "\.POPS\." | "%~dp0BAT\busybox" cut -c30-250 | "%~dp0BAT\busybox" sed "s/.\{15\}/& /" | "%~dp0BAT\busybox" sort -k2 | "%~dp0BAT\busybox" sed -e "s/\(.\{15\}\)./\1/" | "%~dp0BAT\busybox" sed "/__\./d" > "%~dp0LOG\PARTITION_PS1_GAMES_NON_HIDDEN.txt"
    type "%~dp0LOG\PARTITION_PS1_GAMES_NON_HIDDEN.txt"
	)

echo ----------------------------------------------------	
"%~dp0BAT\Diagbox" gd 06
echo Copy Name of the partition. Example: PP.SLES-50507..HALF_LIFE
echo.
"%~dp0BAT\Diagbox" gd 07

set /p "pphide=Enter the partition name you want to hide:"
IF "!pphide!"=="" (goto HDDOSDPartManagement)
 
IF %@pfs_pphide%==yes (
cls
echo\
echo\
echo Hide %pphide% Partition:
echo ----------------------------------------------------
echo\

    echo        Hide partitions...
	"%~dp0BAT\hdl_dump" modify %@hdl_path% "%pphide%" -hide
	echo        Partition %pphide% Hide...	
	) else ( cls & echo          Canceled... )

rmdir /Q/S "%~dp0TMP" >nul 2>&1

echo\
echo\
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo Partition Completed...
echo\
echo\
"%~dp0BAT\Diagbox" gd 07

pause & (goto HDDOSDPartManagement)

REM ##############################################################################################################################################
:ppunhide

cls
mkdir "%~dp0TMP" >nul 2>&1
mkdir "%~dp0LOG" >nul 2>&1

"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning for Playstation 2 HDDs:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "Playstation 2 HDD"
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "Playstation 2 HDD" | "%~dp0BAT\busybox" grep -o "hdd[0-9]:\|hdd[0-9][0-9]:" > "%~dp0TMP\hdl-hdd.txt"

set /P @hdl_path=<"%~dp0TMP\hdl-hdd.txt"
REM del "%~dp0TMP\hdl-hdd.txt" >nul 2>&1
IF "!@hdl_path!"=="" ( 
"%~dp0BAT\Diagbox" gd 0c
		echo         Playstation 2 HDD Not Detected
		echo         Drive Must Be Formatted First
		echo\
		echo\
"%~dp0BAT\Diagbox" gd 07
		rmdir /Q/S "%~dp0TMP" >nul 2>&1
        pause & (goto HDDOSDPartManagement)
	)
	
"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Scan already hidden partitions:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1) Yes
"%~dp0BAT\Diagbox" gd 0c
echo         2) No
"%~dp0BAT\Diagbox" gd 0e
REM echo         3) Yes PS1 Games
"%~dp0BAT\Diagbox" gd 07
echo\
CHOICE /C 12 /M "Select Option:"

IF %ERRORLEVEL%==1 set @pfs_ppunhidePS2Games=yes & set @pfs_ppunhide=yes
IF %ERRORLEVEL%==2 (goto HDDOSDPartManagement)
REM IF %ERRORLEVEL%==3 set @pfs_ppunhidePS1Games=yes & set @pfs_ppunhide=yes

cls
echo\
echo\
echo Scanning Partitions games hidden:
echo ----------------------------------------------------

if defined @pfs_ppunhidePS2Games (
    "%~dp0BAT\hdl_dump" toc %@hdl_path% | "%~dp0BAT\busybox" grep "0x1337" | "%~dp0BAT\busybox" cut -c30-250 | "%~dp0BAT\busybox" sed "/PP./d" | "%~dp0BAT\busybox" sed "s/.\{15\}/& /" | "%~dp0BAT\busybox" sort -k2 | "%~dp0BAT\busybox" sed -e "s/\(.\{15\}\)./\1/" > "%~dp0LOG\PARTITION_PS2_GAMES_HIDDEN.txt"
    type "%~dp0LOG\PARTITION_PS2_GAMES_HIDDEN.txt"
	)

if defined @pfs_ppunhidePS1Games (
	"%~dp0BAT\hdl_dump" toc %@hdl_path% | "%~dp0BAT\busybox" grep -e "\.POPS\." | "%~dp0BAT\busybox" sed "/__.POPS/d" | "%~dp0BAT\busybox" sed "/PP./d" | "%~dp0BAT\busybox" cut -c30-250 | "%~dp0BAT\busybox" sed "s/.\{14\}/& /" | "%~dp0BAT\busybox" sort -k2 | "%~dp0BAT\busybox" sed -e "s/\(.\{14\}\)./\1/" > "%~dp0LOG\PARTITION_PS1_GAMES_HIDDEN.txt"
    type "%~dp0LOG\PARTITION_PS1_GAMES_HIDDEN.txt"
	)

echo ----------------------------------------------------	
"%~dp0BAT\Diagbox" gd 06
echo Copy Name of the partition. Example: __.SLES-50507..HALF_LIFE
echo.

"%~dp0BAT\Diagbox" gd 07
set /p "ppunhide=Enter the partition name you want to Unhide:"
IF "!ppunhide!"=="" (goto HDDOSDPartManagement)

IF %@pfs_ppunhide%==yes (
cls
echo\
echo\
echo Unhide %ppunhide% Partition:
echo ----------------------------------------------------
echo\

    echo        Unhide partitions...
	"%~dp0BAT\hdl_dump" modify %@hdl_path% "%ppunhide%" -unhide
	echo        Partition %ppunhide% Unhide...	
	) else ( cls & echo          Canceled... )	

rmdir /Q/S "%~dp0TMP" >nul 2>&1

echo\
echo\
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo Partition Unhide Completed...
echo\
echo\
"%~dp0BAT\Diagbox" gd 07

pause & (goto HDDOSDPartManagement)

REM ####################################################################################################################################################
:RenameTitleHDDOSD

cd "%~dp0"
cls

mkdir "%~dp0TMP" >nul 2>&1

"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning for Playstation 2 HDDs:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "Playstation 2 HDD"
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "Playstation 2 HDD" | "%~dp0BAT\busybox" grep -o "hdd[0-9]:\|hdd[0-9][0-9]:" > "%~dp0TMP\hdl-hdd.txt" & "%~dp0BAT\busybox" cat "%~dp0TMP\hdl-hdd.txt" > "%~dp0TMP\hdl-hdd2.txt"
"%~dp0BAT\busybox" sed -i "s/hdd/\\\\.\\\PhysicalDrive/g; s/://g" "%~dp0TMP\hdl-hdd2.txt" >nul 2>&1

set /P @hdl_path2=<"%~dp0TMP\hdl-hdd2.txt"
set /P @hdl_path=<"%~dp0TMP\hdl-hdd.txt"
::del "%~dp0TMP\hdl-hdd.txt" >nul 2>&1
IF "!@hdl_path!"=="" ( 
"%~dp0BAT\Diagbox" gd 0c
		echo         Playstation 2 HDD Not Detected
		echo         Drive Must Be Formatted First
		echo\
		echo\
"%~dp0BAT\Diagbox" gd 07
		rmdir /Q/S "%~dp0TMP" >nul 2>&1
		pause & if defined @GameManagementMenu (goto GamesManagement) else (goto HDDOSDPartManagement)
	)

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Rename a title partitions:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1) Yes PS2 Games
"%~dp0BAT\Diagbox" gd 0c
echo         2) No
"%~dp0BAT\Diagbox" gd 0e
echo         3) Yes PS1 Games
echo\
"%~dp0BAT\Diagbox" gd 07
CHOICE /C 123 /M "Select Option:"

IF %ERRORLEVEL%==1 (goto RenamePS2GamesOSD) 
IF %ERRORLEVEL%==2 if defined @GameManagementMenu (goto GamesManagement) else (goto HDDOSDPartManagement)
IF %ERRORLEVEL%==3 (goto RenamePS1GamesOSD)

REM ####################################################################################################################################################
:CustomPPHeader

cls
mkdir "%~dp0TMP" >nul 2>&1
IF NOT EXIST "%~dp0HDD-OSD\PP.HEADER" MD "%~dp0HDD-OSD\PP.HEADER\res\image"
cd /d "%~dp0HDD-OSD\PP.HEADER"

"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning for Playstation 2 HDDs:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "Playstation 2 HDD"
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "Playstation 2 HDD" | "%~dp0BAT\busybox" grep -o "hdd[0-9]:\|hdd[0-9][0-9]:" > "%~dp0TMP\hdl-hdd.txt" & "%~dp0BAT\busybox" cat "%~dp0TMP\hdl-hdd.txt" > "%~dp0TMP\hdl-hdd2.txt"
"%~dp0BAT\busybox" sed -i "s/hdd/\\\\.\\\PhysicalDrive/g; s/://g" "%~dp0TMP\hdl-hdd2.txt" >nul 2>&1

set /P @hdl_path2=<"%~dp0TMP\hdl-hdd2.txt"
set /P @hdl_path=<"%~dp0TMP\hdl-hdd.txt"
::del "%~dp0TMP\hdl-hdd.txt" >nul 2>&1
IF "!@hdl_path!"=="" ( 
"%~dp0BAT\Diagbox" gd 0c
		echo         Playstation 2 HDD Not Detected
		echo         Drive Must Be Formatted First
		echo\
		echo\
"%~dp0BAT\Diagbox" gd 07
		rmdir /Q/S "%~dp0TMP" >nul 2>&1
		pause & (goto HDDOSDPartManagement)
	)
	
"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Dump or Inject Header:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1) Yes Dump header
"%~dp0BAT\Diagbox" gd 0c
echo         2) No
"%~dp0BAT\Diagbox" gd 0e
echo         3) Yes Inject header
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
echo         1) Partition PS1 Games
echo         2) Partition PS2 Games
echo         3) Partition System
echo\
CHOICE /C 123 /M "Select Option:"
IF %ERRORLEVEL%==1 set ShowPS1GamePartitionList=yes
IF %ERRORLEVEL%==2 set ShowPS2GamePartitionList=yes
IF %ERRORLEVEL%==3 set ShowSystemPartitionList=yes

"%~dp0BAT\Diagbox" gd 0e
cls
echo\
echo\
if defined ShowPS1GamePartitionList (
echo Scanning Partitions PS1 Games:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
	"%~dp0BAT\hdl_dump" toc %@hdl_path% | "%~dp0BAT\busybox" grep -e "\.POPS\." | "%~dp0BAT\busybox" sed "s/.\{48\}/& /" | "%~dp0BAT\busybox" sort -k6 | "%~dp0BAT\busybox" sed -e "s/\(.\{48\}\)./\1/" | "%~dp0BAT\busybox" cut -c30-250 > "%~dp0LOG\PARTITION_PS1_GAMES.txt"
	type "%~dp0LOG\PARTITION_PS1_GAMES.txt"
)

if defined ShowPS2GamePartitionList (
echo Scanning Partitions PS2 Games:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
    "%~dp0BAT\hdl_dump" toc %@hdl_path% | "%~dp0BAT\busybox" grep -e "0x1337" | "%~dp0BAT\busybox" sed "s/.\{44\}/& /" | "%~dp0BAT\busybox" sort -k6 | "%~dp0BAT\busybox" sed -e "s/\(.\{44\}\)./\1/" | "%~dp0BAT\busybox" cut -c30-250 > "%~dp0LOG\PARTITION_PS2_GAMES.txt"
	type "%~dp0LOG\PARTITION_PS2_GAMES.txt"
)

if defined ShowSystemPartitionList (
echo Scanning Partitions System:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
    "%~dp0BAT\hdl_dump" toc %@hdl_path% | "%~dp0BAT\busybox" grep -e "0x0100" | "%~dp0BAT\busybox" grep -e "PP\." | "%~dp0BAT\busybox" sed "/\.POPS\./d" | "%~dp0BAT\busybox" cut -c30-250 > "%~dp0TMP\hdd-prt.txt"
	type "%~dp0TMP\hdd-prt.txt"
)
"%~dp0BAT\Diagbox" gd 0e
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0f
    
	if defined ShowPS2GamePartitionList (
	echo NOTE For PSBBN ^& XMB users: 
	echo Partitions HDL with prefix __. will be linked to the PP. PFS partition 
	echo The name should match the name of the installed game. except the first three characters should be PP.
	echo which means that if you Inject or Dump the partition __. it will also Inject Or Dump PP. PFS partition
	)
    echo\
    set /p PPNameHeader=Enter the partition name:
    IF "!PPNameHeader!"=="" (goto HDDOSDPartManagement)
    echo\
	echo !PPNameHeader!| "%~dp0BAT\busybox" sed -e "s/__\./PP\./g" > "%~dp0TMP\PPBBNXMB.txt" & set /P PPNameHeader=<"%~dp0TMP\PPBBNXMB.txt"

if !PPHeader!==Dump (

set size=0
for /f "tokens=*" %%x in ('dir /s /a /b %1') do set /a size+=%%~zx

        if !size! GTR 1 set noempty=yes
		if defined noempty (
		"%~dp0BAT\Diagbox" gd 06
        echo Warning Files exist, they will be overwritten
		"%~dp0BAT\Diagbox" gd 0f
		choice /c YN /M "Do you want to continue?:"
		if errorlevel 2 (goto HDDOSDPartManagement)
		)
cls
echo\
echo\
echo Dump !PPNameHeader! Header:
echo ----------------------------------------------------
echo\

	echo         Extraction Header...
	REM HDD-OSD Header
	"%~dp0BAT\hdl_dump_fix" dump_header %@hdl_path% "!PPNameHeader!" >nul 2>&1
	
    cd "%~dp0TMP"
	echo         Extraction Resources Header...
	echo device %@hdl_path2% > "%~dp0TMP\pfs-log.txt"
	echo mount "!PPNameHeader!" >> "%~dp0TMP\pfs-log.txt"
	echo cd res >> "%~dp0TMP\pfs-log.txt"
	echo ls -l >> "%~dp0TMP\pfs-log.txt"
	echo umount >> "%~dp0TMP\pfs-log.txt"
	echo exit >> "%~dp0TMP\pfs-log.txt"
	type "%~dp0TMP\pfs-log.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" grep -i -e "-rw-" -e "-rwx" | "%~dp0BAT\busybox" cut -c42-500 > "%~dp0TMP\pfs-tmp.log"

	echo device %@hdl_path2% > "%~dp0TMP\pfs-log.txt"
	echo mount "!PPNameHeader!" >> "%~dp0TMP\pfs-log.txt"
	echo mkdir res >> "%~dp0TMP\pfs-log.txt"
	echo cd res >> "%~dp0TMP\pfs-log.txt"
	echo mkdir image >> "%~dp0TMP\pfs-log.txt"
	echo cd image >> "%~dp0TMP\pfs-log.txt"
	echo ls -l >> "%~dp0TMP\pfs-log.txt"
	echo umount >> "%~dp0TMP\pfs-log.txt"
	echo exit >> "%~dp0TMP\pfs-log.txt"
	type "%~dp0TMP\pfs-log.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" grep -i -e "-rw-" -e "-rwx" | "%~dp0BAT\busybox" cut -c42-500 > "%~dp0TMP\pfs-tmp2.log"

	echo device %@hdl_path2% > "%~dp0TMP\pfs-header.txt"
	echo mount "!PPNameHeader!" >> "%~dp0TMP\pfs-header.txt"
	echo lcd "%~dp0HDD-OSD\PP.HEADER" >> "%~dp0TMP\pfs-header.txt"
	echo get EXECUTE.KELF >> "%~dp0TMP\pfs-header.txt"
	
	echo cd res >> "%~dp0TMP\pfs-header.txt"
	mkdir "%~dp0HDD-OSD\PP.HEADER\res" >nul 2>&1
	echo lcd "%~dp0HDD-OSD\PP.HEADER\res" >> "%~dp0TMP\pfs-header.txt"
	for /f "tokens=*" %%f in (pfs-tmp.log) do (echo get "%%f" >> "%~dp0TMP\pfs-header.txt")
	
	echo cd image >> "%~dp0TMP\pfs-header.txt"
	mkdir "%~dp0HDD-OSD\PP.HEADER\res\image" >nul 2>&1
	echo lcd "%~dp0HDD-OSD\PP.HEADER\res\image" >> "%~dp0TMP\pfs-header.txt"
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

cd /d "%~dp0HDD-OSD\PP.HEADER"

	echo         Inject Header...
	REM HDD-OSD Header
	"%~dp0BAT\hdl_dump_fix" modify_header %@hdl_path% "!PPNameHeader!" >nul 2>&1
    echo !PPNameHeader!| "%~dp0BAT\busybox" sed -e "s/PP\./__\./g" > "%~dp0TMP\PPBBNXMB.txt" & set /P PPNameHeader2=<"%~dp0TMP\PPBBNXMB.txt"
	"%~dp0BAT\hdl_dump_fix" modify_header %@hdl_path% "!PPNameHeader2!" >nul 2>&1
	
	echo         Inject Resources Header...
	echo device %@hdl_path2% > "%~dp0TMP\pfs-headerbbn.txt"
	echo mount "!PPNameHeader!" >> "%~dp0TMP\pfs-headerbbn.txt"
	echo lcd "%~dp0HDD-OSD\PP.HEADER" >> "%~dp0TMP\pfs-headerbbn.txt"
	echo put EXECUTE.KELF >> "%~dp0TMP\pfs-headerbbn.txt"
	echo lcd "%~dp0HDD-OSD\PP.HEADER\res" >> "%~dp0TMP\pfs-headerbbn.txt"
	echo mkdir res >> "%~dp0TMP\pfs-headerbbn.txt"
	echo cd res >> "%~dp0TMP\pfs-headerbbn.txt"
	
	cd /d "%~dp0HDD-OSD\PP.HEADER\res"
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

cd /d "%~dp0"
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
echo         1) Yes (For PS2 Games)
"%~dp0BAT\Diagbox" gd 0c
echo         2) No
"%~dp0BAT\Diagbox" gd 0e
echo         3) Yes (For PS1 Games)
echo\
"%~dp0BAT\Diagbox" gd 07
CHOICE /C 123 /M "Select Option:"

IF %ERRORLEVEL%==1 set ARTType=PS2
IF %ERRORLEVEL%==2 (goto DownloadsMenu)
IF %ERRORLEVEL%==3 set ARTType=PS1

cls
if !ARTType!==PS2 (
"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning for Playstation 2 HDDs:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "Playstation 2 HDD"
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "Playstation 2 HDD" | "%~dp0BAT\busybox" grep -o "hdd[0-9]:\|hdd[0-9][0-9]:" > "%~dp0TMP\hdl-hdd.txt"

set /P @hdl_path=<"%~dp0TMP\hdl-hdd.txt"
::del "%~dp0TMP\hdl-hdd.txt" >nul 2>&1
IF "!@hdl_path!"=="" ( 
"%~dp0BAT\Diagbox" gd 0c
		echo         Playstation 2 HDD Not Detected
		echo         Drive Must Be Formatted First
		echo\
		echo\
"%~dp0BAT\Diagbox" gd 07
		rmdir /Q/S "%~dp0TMP" >nul 2>&1
		pause & (goto DownloadsMenu)
	)
)

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
"%~dp0BAT\Diagbox" gd 0f
if !ARTType!==PS1 echo Downloads ARTs For .VCD In the POPS folder ?
if !ARTType!==PS2 echo Download ARTs for all installed games?
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1) Yes
"%~dp0BAT\Diagbox" gd 0c
echo         2) No
"%~dp0BAT\Diagbox" gd 07
echo\
CHOICE /C 12 /M "Select Option:"

IF %ERRORLEVEL%==2 (goto DownloadsMenu)

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
	"%~dp0BAT\wget" -q --show-progress "https://archive.org/download/OPLM_ART_2022_05/OPLM_ART_2022_05.zip/PS1%%2FSCES_000.01%%2FSCES_000.01_COV.jpg" -O "%~dp0TMP\SCES_000.01_COV.jpg" >nul 2>&1
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

"%~dp0BAT\Diagbox" gd 0e
cls
echo\
echo\
echo Scanning Games List:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
setlocal DisableDelayedExpansion

if %ARTType%==PS2 (
"%~dp0BAT\hdl_dump" hdl_toc %@hdl_path% > PARTITION_GAMES.txt

"%~dp0BAT\busybox" sed -i "1d" PARTITION_GAMES.txt
"%~dp0BAT\busybox" sed -i -e "$ d" PARTITION_GAMES.txt
"%~dp0BAT\busybox" cut -c35-500 PARTITION_GAMES.txt | "%~dp0BAT\busybox" sort -k2 > "%~dp0TMP\%ARTType%Games.txt"
)

if %ARTType%==PS1 (
if not exist "%~dp0POPS\*.VCD" (
"%~dp0BAT\Diagbox" gd 06
cls
echo.
echo .VCD NOT DETECTED: Please drop .VCD IN POPS FOLDER.
echo.
"%~dp0BAT\Diagbox" gd 0f
pause & (goto DownloadsMenu)

 ) else (

For %%P in ( "%~dp0POPS\*.VCD" ) do ("%~dp0BAT\POPS-VCD-ID-Extractor" "%%P" >> VCDID.txt) >nul 2>&1
"%~dp0BAT\busybox" sed -i -e "s/-/_/g" "%~dp0TMP\VCDID.txt"
"%~dp0BAT\busybox" ls "%~dp0POPS" | "%~dp0BAT\busybox" grep -ie ".*\.VCD$" > "%~dp0TMP\Name.txt"
"%~dp0BAT\busybox" paste -d " " "%~dp0TMP\VCDID.txt" "%~dp0TMP\Name.txt" > "%~dp0TMP\VCDIDNameTMP.txt"
"%~dp0BAT\busybox" sed "s/.\{12\}/& /" "%~dp0TMP\VCDIDNameTMP.txt" > "%~dp0TMP\%ARTType%Games.txt"
 )
)

type "%~dp0TMP\%ARTType%Games.txt"
"%~dp0BAT\Diagbox" gd 0e
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
setlocal EnableDelayedExpansion

echo Download...

For /f "tokens=1*" %%A in (%ARTType%Games.txt) do (
"%~dp0BAT\Diagbox" gd 0f
echo\
echo %%B
echo %%A
"%~dp0BAT\Diagbox" gd 03

REM Cover
IF !uselocalART!==yes if exist "%~dp0ART.zip" if not exist "%~dp0ART\%%A_COV.jpg" "%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0ART.zip" -o"%~dp0TMP" %ARTType%\%%A\%%A_COV.jpg -r -y & move "%~dp0TMP\%ARTType%\%%A\%%A_COV.jpg" "%~dp0ART" >nul 2>&1
IF !DownloadART!==yes if not exist "%~dp0ART\%%A_COV.jpg" "%~dp0BAT\wget" -q --show-progress "https://archive.org/download/OPLM_ART_2022_05/OPLM_ART_2022_05.zip/%ARTType%%%2F%%A%%2F%%A_COV.jpg" -O "%~dp0ART\%%A_COV.jpg"

cd /d "%~dp0ART" & for %%F in (%%A_COV.jpg) do if %%~zF==0 del "%%F"
if exist %%A_COV.jpg echo Found >nul
"%~dp0BAT\Diagbox" gd 0c
if not exist %%A_COV.jpg echo %%A_COV.jpg   Not found in database 
"%~dp0BAT\Diagbox" gd 03

REM Back Cover
IF !uselocalART!==yes if exist "%~dp0ART.zip" if not exist "%~dp0ART\%%A_COV2.jpg" "%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0ART.zip" -o"%~dp0TMP" %ARTType%\%%A\%%A_COV2.jpg -r -y & move "%~dp0TMP\%ARTType%\%%A\%%A_COV2.jpg" "%~dp0ART" >nul 2>&1
IF !DownloadART!==yes if not exist "%~dp0ART\%%A_COV2.jpg" "%~dp0BAT\wget" -q --show-progress "https://archive.org/download/OPLM_ART_2022_05/OPLM_ART_2022_05.zip/%ARTType%%%2F%%A%%2F%%A_COV2.jpg" -O "%~dp0ART\%%A_COV2.jpg"

cd /d "%~dp0ART" & for %%F in (%%A_COV2.jpg) do if %%~zF==0 del "%%F"
if exist %%A_COV2.jpg echo Found >nul
"%~dp0BAT\Diagbox" gd 0c
if not exist %%A_COV2.jpg echo %%A_COV2.jpg  Not found in database 
"%~dp0BAT\Diagbox" gd 03

REM ICO
IF !uselocalART!==yes if exist "%~dp0ART.zip" "%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0ART.zip" -o"%~dp0TMP" %ARTType%\%%A\%%A_ICO.png -r -y & move "%~dp0TMP\%ARTType%\%%A\%%A_ICO.png" "%~dp0ART" >nul 2>&1
IF !DownloadART!==yes if not exist "%~dp0ART\%%A_ICO.png" "%~dp0BAT\wget" -q --show-progress "https://archive.org/download/OPLM_ART_2022_05/OPLM_ART_2022_05.zip/%ARTType%%%2F%%A%%2F%%A_ICO.png" -O "%~dp0ART\%%A_ICO.png"

cd /d "%~dp0ART" & for %%F in (%%A_ICO.png) do if %%~zF==0 del "%%F"
if exist %%A_ICO.png echo Found >nul
"%~dp0BAT\Diagbox" gd 0c
if not exist %%A_ICO.png echo %%A_ICO.png   Not found in database 
"%~dp0BAT\Diagbox" gd 03

REM LAB
IF !uselocalART!==yes if exist "%~dp0ART.zip" "%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0ART.zip" -o"%~dp0TMP" %ARTType%\%%A\%%A_LAB.jpg -r -y & move "%~dp0TMP\%ARTType%\%%A\%%A_LAB.jpg" "%~dp0ART" >nul 2>&1
IF !DownloadART!==yes if not exist "%~dp0ART\%%A_LAB.jpg" "%~dp0BAT\wget" -q --show-progress "https://archive.org/download/OPLM_ART_2022_05/OPLM_ART_2022_05.zip/%ARTType%%%2F%%A%%2F%%A_LAB.jpg" -O "%~dp0ART\%%A_LAB.jpg"

cd /d "%~dp0ART" & for %%F in (%%A_LAB.jpg) do if %%~zF==0 del "%%F"
if exist %%A_LAB.jpg echo Found >nul
"%~dp0BAT\Diagbox" gd 0c
if not exist %%A_LAB.jpg echo %%A_LAB.jpg   Not found in database 
"%~dp0BAT\Diagbox" gd 03

REM LOGO
IF !uselocalART!==yes if exist "%~dp0ART.zip" "%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0ART.zip" -o"%~dp0TMP" %ARTType%\%%A\%%A_LGO.png -r -y & move "%~dp0TMP\%ARTType%\%%A\%%A_LGO.png" "%~dp0ART" >nul 2>&1
IF !DownloadART!==yes if not exist "%~dp0ART\%%A_LGO.png" "%~dp0BAT\wget" -q --show-progress "https://archive.org/download/OPLM_ART_2022_05/OPLM_ART_2022_05.zip/%ARTType%%%2F%%A%%2F%%A_LGO.png" -O "%~dp0ART\%%A_LGO.png"

cd /d "%~dp0ART" & for %%F in (%%A_LGO.png) do if %%~zF==0 del "%%F"
if exist %%A_LGO.png echo Found >nul
"%~dp0BAT\Diagbox" gd 0c
if not exist %%A_LGO.png echo %%A_LGO.png   Not found in database 
"%~dp0BAT\Diagbox" gd 03
 
REM Background
IF !uselocalART!==yes if exist "%~dp0ART.zip" "%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0ART.zip" -o"%~dp0TMP" %ARTType%\%%A\%%A_BG_00.jpg -r -y & move "%~dp0TMP\%ARTType%\%%A\%%A_BG_00.jpg" "%~dp0ART\%%A_BG.jpg" >nul 2>&1
IF !DownloadART!==yes if not exist "%~dp0ART\%%A_BG.jpg" "%~dp0BAT\wget" -q --show-progress "https://archive.org/download/OPLM_ART_2022_05/OPLM_ART_2022_05.zip/%ARTType%%%2F%%A%%2F%%A_BG_00.jpg" -O "%~dp0ART\%%A_BG.jpg"

cd /d "%~dp0ART" & for %%F in (%%A_BG.jpg) do if %%~zF==0 del "%%F"
if exist %%A_BG.jpg echo Found >nul
"%~dp0BAT\Diagbox" gd 0c
if not exist %%A_BG.jpg echo %%A_BG.jpg    Not found in database 
"%~dp0BAT\Diagbox" gd 03

REM Screenshot 0
IF !uselocalART!==yes if exist "%~dp0ART.zip" "%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0ART.zip" -o"%~dp0TMP" %ARTType%\%%A\%%A_SCR_00.jpg -r -y & move "%~dp0TMP\%ARTType%\%%A\%%A_SCR_00.jpg" "%~dp0ART\%%A_SCR.jpg" >nul 2>&1
IF !DownloadART!==yes if not exist "%~dp0ART\%%A_SCR.jpg" "%~dp0BAT\wget" -q --show-progress "https://archive.org/download/OPLM_ART_2022_05/OPLM_ART_2022_05.zip/%ARTType%%%2F%%A%%2F%%A_SCR_00.jpg" -O "%~dp0ART\%%A_SCR.jpg"

cd /d "%~dp0ART" & for %%F in (%%A_SCR.jpg) do if %%~zF==0 del "%%F"
if exist %%A_SCR.jpg echo Found >nul
"%~dp0BAT\Diagbox" gd 0c
if not exist %%A_SCR.jpg echo %%A_SCR.jpg   Not found in database 
"%~dp0BAT\Diagbox" gd 03

REM Screenshot 1
IF !uselocalART!==yes if exist "%~dp0ART.zip" "%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0ART.zip" -o"%~dp0TMP" %ARTType%\%%A\%%A_SCR_02.jpg -r -y & move "%~dp0TMP\%ARTType%\%%A\%%A_SCR_02.jpg" "%~dp0ART\%%A_SCR2.jpg" >nul 2>&1
IF !DownloadART!==yes if not exist "%~dp0ART\%%A_SCR2.jpg" "%~dp0BAT\wget" -q --show-progress "https://archive.org/download/OPLM_ART_2022_05/OPLM_ART_2022_05.zip/%ARTType%%%2F%%A%%2F%%A_SCR_01.jpg" -O "%~dp0ART\%%A_SCR2.jpg"

cd /d "%~dp0ART" & for %%F in (%%A_SCR2.jpg) do if %%~zF==0 del "%%F"
if exist %%A_SCR2.jpg echo Found >nul
"%~dp0BAT\Diagbox" gd 0c
if not exist %%A_SCR2.jpg echo %%A_SCR2.jpg  Not found in database 
"%~dp0BAT\Diagbox" gd 03

)

echo\
"%~dp0BAT\Diagbox" gd 0f
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo Download completed...
echo\
echo\
"%~dp0BAT\Diagbox" gd 07

endlocal
endlocal
rmdir /Q/S "%~dp0TMP" >nul 2>&1
echo.

pause & (goto DownloadsMenu) 

REM ##########################################################################################################################################################################
:DownloadCFG

cls
mkdir "%~dp0CFG" >nul 2>&1
mkdir "%~dp0TMP" >nul 2>&1
cd /d "%~dp0TMP"

"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning for Playstation 2 HDDs:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "Playstation 2 HDD"
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "Playstation 2 HDD" | "%~dp0BAT\busybox" grep -o "hdd[0-9]:\|hdd[0-9][0-9]:" > "%~dp0TMP\hdl-hdd.txt"

set /P @hdl_path=<"%~dp0TMP\hdl-hdd.txt"
::del "%~dp0TMP\hdl-hdd.txt" >nul 2>&1
IF "!@hdl_path!"=="" ( 
"%~dp0BAT\Diagbox" gd 0c
		echo         Playstation 2 HDD Not Detected
		echo         Drive Must Be Formatted First
		echo\
		echo\
"%~dp0BAT\Diagbox" gd 07
		rmdir /Q/S "%~dp0TMP" >nul 2>&1
		pause & (goto DownloadsMenu)
	)

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
"%~dp0BAT\Diagbox" gd 0f
echo Download CFG for All games installed ?
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1) Yes
"%~dp0BAT\Diagbox" gd 0c
echo         2) No
"%~dp0BAT\Diagbox" gd 0e
echo         3) Yes (Manually Choose the game)
echo\
"%~dp0BAT\Diagbox" gd 07
echo\
CHOICE /C 123 /M "Select Option:"

IF %ERRORLEVEL%==1 set @Downloadcfg=yes
IF %ERRORLEVEL%==2 (goto DownloadsMenu)
IF %ERRORLEVEL%==3 set @Downloadcfg=yesmanually

echo\
echo\
echo Choose your languages of your CFG
echo 1 English 
echo 2 French
echo\
CHOICE /C 12 /M "Select Option:"
IF ERRORLEVEL 1 set language=CFG_en
IF ERRORLEVEL 2 set language=CFG_fr

echo\
echo Download the latest CFGs over internet?
echo NOTE: if you choose No, an offline installation will be performed.
echo Or if you choose Yes, and there is a problem connecting to the website, an offline install will be performed.
echo\
choice /c YN 
echo\

if errorlevel 1 set DownloadDB=yes
if errorlevel 2 set DownloadDB=no

    IF "!DownloadDB!"=="yes" (
    echo Checking internet connection...
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
	)
)

"%~dp0BAT\Diagbox" gd 0e
cls
echo\
echo\
echo List Games
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
setlocal DisableDelayedExpansion

"%~dp0BAT\hdl_dump" hdl_toc %@hdl_path% > PARTITION_GAMES.txt

"%~dp0BAT\busybox" sed -i "1d" PARTITION_GAMES.txt
"%~dp0BAT\busybox" sed -i -e "$ d" PARTITION_GAMES.txt
"%~dp0BAT\busybox" cut -c35-500 PARTITION_GAMES.txt | "%~dp0BAT\busybox" sort -k2 > PARTITION_GAMES_NEW.txt

type PARTITION_GAMES_NEW.txt
"%~dp0BAT\Diagbox" gd 0e
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0f
	
    "%~dp0BAT\busybox" sed -i "s/!/^!/g" PARTITION_GAMES_NEW.txt
    setlocal EnableDelayedExpansion

	IF "!@Downloadcfg!"=="yes" (
	for /f "tokens=1*" %%i in (PARTITION_GAMES_NEW.txt) do (
	set gameid=%%i
	set GameName=%%j

	echo\
	echo !GameName!
	echo !gameid!.cfg
	
	IF "!DownloadDB!"=="no" (
	"%~dp0BAT\Diagbox" gd 03
    "%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0BAT\PS2-OPL-CFG-Database.7z" -o"%~dp0CFG" PS2-OPL-CFG-Database-master\!language!\!gameid!.cfg -r -y
	"%~dp0BAT\Diagbox" gd 0f
	) else (
	md "%~dp0CFG\PS2-OPL-CFG-Database-master\!language!" >nul 2>&1
	"%~dp0BAT\Diagbox" gd 03
    "%~dp0BAT\wget" -q --show-progress "https://raw.githubusercontent.com/GDX-X/PS2-OPL-CFG-Database/master/!language!/!gameid!.cfg" -O "%~dp0CFG\PS2-OPL-CFG-Database-master\!language!\!gameid!.cfg"
    "%~dp0BAT\Diagbox" gd 0f
	)

	cd /d "%~dp0CFG\PS2-OPL-CFG-Database-master\!language!" & for %%F in (!gameid!.cfg ) do if %%~zF==0 del "%%F"
    if not exist !gameid!.cfg (
    "%~dp0BAT\Diagbox" gd 0c
    echo Not found in database 
    "%~dp0BAT\Diagbox" gd 0f
    cd /d "%~dp0TMP"
    ) else (
    "%~dp0BAT\Diagbox" gd 03
    echo Found
    "%~dp0BAT\Diagbox" gd 0f
    cd /d "%~dp0TMP"
	  )
     )
    )
   
	IF "!@Downloadcfg!"=="yesmanually" (
	echo\
    set /p GameName=Enter the GameName:
    IF "!GameName!"=="" (goto DownloadsMenu)
	"%~dp0BAT\busybox" grep -m 1 "!GameName!" PARTITION_GAMES_NEW.txt | "%~dp0BAT\busybox" grep -o "[A-Z][A-Z][A-Z][A-Z]_[0-9][0-9][0-9].[0-9][0-9]" > gameselected.txt & set /P gameid=<gameselected.txt
	echo\

	echo\
	echo !GameName!
	echo !gameid!.cfg
	
	IF "!DownloadDB!"=="no" (
	"%~dp0BAT\Diagbox" gd 03
    "%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0BAT\PS2-OPL-CFG-Database.7z" -o"%~dp0CFG" PS2-OPL-CFG-Database-master\!language!\!gameid!.cfg -r -y
	"%~dp0BAT\Diagbox" gd 0f
	) else (
	md "%~dp0CFG\PS2-OPL-CFG-Database-master\!language!" >nul 2>&1
	"%~dp0BAT\Diagbox" gd 03
    "%~dp0BAT\wget" -q --show-progress "https://raw.githubusercontent.com/GDX-X/PS2-OPL-CFG-Database/master/!language!/!gameid!.cfg" -O "%~dp0CFG\PS2-OPL-CFG-Database-master\!language!\!gameid!.cfg"
    "%~dp0BAT\Diagbox" gd 0f
	)

	cd /d "%~dp0CFG\PS2-OPL-CFG-Database-master\!language!" & for %%F in (!gameid!.cfg ) do if %%~zF==0 del "%%F"
    if not exist !gameid!.cfg (
    "%~dp0BAT\Diagbox" gd 0c
    echo Not found in database 
    "%~dp0BAT\Diagbox" gd 0f
    cd /d "%~dp0TMP"
    ) else (
    "%~dp0BAT\Diagbox" gd 03
    echo Found
    "%~dp0BAT\Diagbox" gd 0f
    cd /d "%~dp0TMP"
	 )
    )
	
	cd /d "%~dp0CFG" & for %%f in (*.cfg) do ("%~dp0BAT\busybox" grep -s -e "\$" -e "Modes=" %%f > "%~dp0CFG\PS2-OPL-CFG-Database-master\!language!\%%fBACKUP")
	cd /d "%~dp0CFG\PS2-OPL-CFG-Database-master\%language%" & for %%f in (*.cfgBACKUP) do ("%~dp0BAT\busybox" sed -i "/Description=\|Title=/d" %%f)
	for %%f in (*.cfg) do ("%~dp0BAT\busybox" cat %%fBACKUP >> %%f) >nul 2>&1
	move "*.cfg" "%~dp0CFG" >nul 2>&1 & cd "%~dp0" & rmdir /Q/S "%~dp0CFG\PS2-OPL-CFG-Database-master\" >nul 2>&1
	"%~dp0BAT\Diagbox" gd 0f

	setlocal DisableDelayedExpansion
    cd /d "%~dp0TMP"
    if %language%==CFG_en copy "%~dp0BAT\TitlesDB\gameidPS2ENG.txt" "%~dp0TMP\gameid.txt" >nul 2>&1
    if %language%==CFG_fr copy "%~dp0BAT\TitlesDB\gameidPS2FRA.txt" "%~dp0TMP\gameid.txt" >nul 2>&1
    "%~dp0BAT\busybox" sed -i "s/\&/\\\&/g" "%~dp0TMP\gameid.txt"
	"%~dp0BAT\busybox" sed -i "s/\^!/\!/g" "%~dp0TMP\gameid.txt" >nul 2>&1
	"%~dp0BAT\busybox" sed -i "s./.\\\/.g" "%~dp0TMP\gameid.txt"
	
    for /f "tokens=1*" %%i in (PARTITION_GAMES_NEW.txt) do (
	set "dbtitle="
	for /f "tokens=1*" %%A in ( 'findstr %%i gameid.txt' ) do (if not defined dbtitle set dbtitle=%%B
	"%~dp0BAT\busybox" sed -i -e "s/\Title=.*/Title=/g; s/Title=/Title=%%B/g" "%~dp0CFG\%%i.cfg" >nul 2>&1
	 )
    )

cd /d "%~dp0"
rmdir /Q/S "%~dp0CFG\%language%" >nul 2>&1
rmdir /Q/S "%~dp0TMP" >nul 2>&1

echo\
echo\
"%~dp0BAT\Diagbox" gd 0f
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo Download completed...
echo\
echo\
"%~dp0BAT\Diagbox" gd 07

 endlocal
endlocal
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
move "%~dp0TMP\DMI.bin" "%~dp0LOG\DumpLOG" >nul 2>&1
move "%~dp0TMP\PFI.bin" "%~dp0LOG\DumpLOG" >nul 2>&1
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
    echo.
	echo.
	echo !gamecount! - %%a

	setlocal disabledelayedexpansion
	set filename=%%a
	set fname=%%~na
	setlocal enabledelayedexpansion 

set "ErrorHash="
REM CRC32
"%~dp0BAT\busybox" crc32 "!filename!" | "%~dp0BAT\busybox" grep -o "[0-9a-f]\{8\}" > "%~dp0TMP\CRC32.TXT" & set /p CRC32=<"%~dp0TMP\CRC32.txt"
"%~dp0BAT\busybox" grep -e !CRC32! "%~dp0BAT\Dats\!gametype!\Redump!gametype!.dat" > "%~dp0TMP\RedumpDB.txt"
if errorlevel 1 ( set ErrorHash=!CRC32! ) else ( echo found !CRC32! ) >nul

REM MD5
"%~dp0BAT\busybox" md5sum "!filename!" | "%~dp0BAT\busybox" grep -o "[0-9a-f]\{32\}" > "%~dp0TMP\MD5.TXT" & set /p MD5=<"%~dp0TMP\MD5.txt"
"%~dp0BAT\busybox" grep -e !MD5! "%~dp0BAT\Dats\!gametype!\Redump!gametype!.dat" > "%~dp0TMP\RedumpDB.txt"
if errorlevel 1 ( set ErrorHash=!MD5! ) else ( echo found !MD5! ) >nul

REM SHA1
"%~dp0BAT\busybox" sha1sum "!filename!" | "%~dp0BAT\busybox" grep -o "[0-9a-f]\{40\}" > "%~dp0TMP\SHA1.TXT" & set /p SHA1=<"%~dp0TMP\SHA1.txt"
"%~dp0BAT\busybox" grep -e !SHA1! "%~dp0BAT\Dats\!gametype!\Redump!gametype!.dat" > "%~dp0TMP\RedumpDB.txt"
if errorlevel 1 ( set ErrorHash=!SHA1! ) else ( echo found !SHA1! ) >nul

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
echo         1) Yes PS2 Games
"%~dp0BAT\Diagbox" gd 0c
echo         2) No
"%~dp0BAT\Diagbox" gd 0e
echo         3) Yes PS1 Games
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

"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning for Playstation 2 HDDs:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "Playstation 2 HDD"
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "Playstation 2 HDD" | "%~dp0BAT\busybox" grep -o "hdd[0-9]:\|hdd[0-9][0-9]:" > "%~dp0TMP\hdl-hdd.txt" & "%~dp0BAT\busybox" cat "%~dp0TMP\hdl-hdd.txt" > "%~dp0TMP\hdl-hdd2.txt"
"%~dp0BAT\busybox" sed -i "s/hdd/\\\\.\\\PhysicalDrive/g; s/://g" "%~dp0TMP\hdl-hdd2.txt" >nul 2>&1

set /P @hdl_path2=<"%~dp0TMP\hdl-hdd2.txt"
set /P @hdl_path=<"%~dp0TMP\hdl-hdd.txt"
::del "%~dp0TMP\hdl-hdd.txt" >nul 2>&1
IF "!@hdl_path!"=="" ( 
"%~dp0BAT\Diagbox" gd 0c
		echo         Playstation 2 HDD Not Detected
		echo         Drive Must Be Formatted First
		echo\
		echo\
"%~dp0BAT\Diagbox" gd 07
		rmdir /Q/S "%~dp0TMP" >nul 2>&1
		pause & (goto GamesManagement)
	)
	
echo\
echo\
"%~dp0BAT\Diagbox" gd 0f
echo Export PS1 Game List ?
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1) Yes (Export All Partition Games list)
"%~dp0BAT\Diagbox" gd 0c
echo         2) No
"%~dp0BAT\Diagbox" gd 0e
echo         3) Yes (Export only the chosen partition)
"%~dp0BAT\Diagbox" gd 0f
echo\
CHOICE /C 123 /M "Select Option:"

IF %ERRORLEVEL%==1 set ExportPS1GamesListPartAll=yes
IF %ERRORLEVEL%==2 (goto GamesManagement)
IF %ERRORLEVEL%==3 set ExportPS1GamesOnlyPart=yes

IF !ExportPS1GamesOnlyPart!==yes (
echo.
echo Choose the partition on which you want to install your .VCDs
echo By default it will be the partition __.POPS
echo.
echo 0.  __.POPS0
echo 1.  __.POPS1
echo 2.  __.POPS2
echo 3.  __.POPS3
echo 4.  __.POPS4
echo 5.  __.POPS5
echo 6.  __.POPS6
echo 7.  __.POPS7
echo 8.  __.POPS8
echo 9.  __.POPS9
echo 10. __.POPS
echo.

set choice=
set /p choice="Select Option:"
IF "!choice!"=="" set "ExportPS1GamesOnlyPart=" & (goto ExportPS1GamesList)

IF "!choice!"=="!choice!" set POPSPART=__.POPS!choice!
IF "!choice!"=="10" set POPSPART=__.POPS
)

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Export...
echo\
	
	if defined ExportPS1GamesListPartAll "%~dp0BAT\hdl_dump" toc !@hdl_path! | "%~dp0BAT\busybox" grep -ie "__\.POPS" | "%~dp0BAT\busybox" cut -c30-500 > "%~dp0TMP\POPSPartTMP.txt"
	if defined ExportPS1GamesOnlyPart echo !POPSPART! > "%~dp0TMP\POPSPartTMP.txt"
	for /f "tokens=*" %%P in (POPSPartTMP.txt) do (set POPSPART=%%P
	echo device !@hdl_path2! > "%~dp0TMP\pfs-log.txt"
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

"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning for Playstation 2 HDDs:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "Playstation 2 HDD"
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "Playstation 2 HDD" | "%~dp0BAT\busybox" grep -o "hdd[0-9]:\|hdd[0-9][0-9]:" > "%~dp0TMP\hdl-hdd.txt"

set /P @hdl_path=<"%~dp0TMP\hdl-hdd.txt"
::del "%~dp0TMP\hdl-hdd.txt" >nul 2>&1
IF "!@hdl_path!"=="" ( 
"%~dp0BAT\Diagbox" gd 0c
		echo         Playstation 2 HDD Not Detected
		echo         Drive Must Be Formatted First
		echo\
		echo\
"%~dp0BAT\Diagbox" gd 07
		rmdir /Q/S "%~dp0TMP" >nul 2>&1
		pause & (goto GamesManagement)
	)

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Export PS2 Game List ?
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1) Yes (Export All Games list)
"%~dp0BAT\Diagbox" gd 0c
echo         2) No
"%~dp0BAT\Diagbox" gd 0e
echo         3) Yes (Export Only CD)
echo         4) Yes (Export Only DVD)
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

if not defined list ("%~dp0BAT\hdl_dump" hdl_toc %@hdl_path% | "%~dp0BAT\busybox" sed "s/.\{31\}/&;/" | "%~dp0BAT\busybox" sort -k6 | "%~dp0BAT\busybox" sed -e "s/;//g" > "%~dp0\GamelistPS2.txt")
if "%list%"=="CD" ("%~dp0BAT\hdl_dump" hdl_toc %@hdl_path% | "%~dp0BAT\busybox" grep -i -e "CD" | "%~dp0BAT\busybox" sed "s/.\{31\}/&;/" | "%~dp0BAT\busybox" sort -k6 | "%~dp0BAT\busybox" sed -e "s/;//g" > "%~dp0\GamelistPS2CD.txt")
if "%list%"=="DVD" ("%~dp0BAT\hdl_dump" hdl_toc %@hdl_path% | "%~dp0BAT\busybox" grep -i -e "DVD" | "%~dp0BAT\busybox" sed "s/.\{31\}/&;/" | "%~dp0BAT\busybox" sort -k6 | "%~dp0BAT\busybox" sed -e "s/;//g" > "%~dp0\GamelistPS2DVD.txt")

echo Output ^> "%~dp0GamelistPS2!list!.txt"

rmdir /Q/S "%~dp0TMP" >nul 2>&1
echo\
pause & (goto GamesManagement) 

REM ####################################################################################################################################################
:RenameChoiceGames

cd /d"%~dp0"
cls
mkdir "%~dp0TMP" >nul 2>&1

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Rename your Games:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1) Yes PS2 Games
"%~dp0BAT\Diagbox" gd 0c
echo         2) No
"%~dp0BAT\Diagbox" gd 0e
echo         3) Yes PS1 Games
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

"%~dp0BAT\Diagbox" gd 0e
cls
echo\
echo\
echo Scanning for Playstation 2 HDDs:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "Playstation 2 HDD"
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "Playstation 2 HDD" | "%~dp0BAT\busybox" grep -o "hdd[0-9]:\|hdd[0-9][0-9]:" > "%~dp0TMP\hdl-hdd.txt" & "%~dp0BAT\busybox" cat "%~dp0TMP\hdl-hdd.txt" > "%~dp0TMP\hdl-hdd2.txt"
"%~dp0BAT\busybox" sed -i "s/hdd/\\\\.\\\PhysicalDrive/g; s/://g" "%~dp0TMP\hdl-hdd2.txt" >nul 2>&1

set /P @hdl_path2=<"%~dp0TMP\hdl-hdd2.txt"
set /P @hdl_path=<"%~dp0TMP\hdl-hdd.txt"
::del "%~dp0TMP\hdl-hdd.txt" >nul 2>&1
IF "!@hdl_path!"=="" (
"%~dp0BAT\Diagbox" gd 0c
		echo         Playstation 2 HDD Not Detected
		echo         Drive Must Be Formatted First
		echo\
		echo\
"%~dp0BAT\Diagbox" gd 07
		rmdir /Q/S "%~dp0TMP" >nul 2>&1
		pause & (goto GamesManagement)
	)
	
"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Rename a PS2 game:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1) Yes
"%~dp0BAT\Diagbox" gd 0c
echo         2) No
"%~dp0BAT\Diagbox" gd 0e
echo         3) Yes (Automatically rename all game titles on hard drive with database)
"%~dp0BAT\Diagbox" gd 0e
echo         4) Yes (Rename Displayed name in HDD-OSD, PSBBN, XMB Menu)
"%~dp0BAT\Diagbox" gd 0f
echo\
CHOICE /C 1234 /M "Select Option:"

IF %ERRORLEVEL%==2 (goto GamesManagement)
IF %ERRORLEVEL%==3 (goto RenamePS2GamesDBTITLE)
IF %ERRORLEVEL%==4 (goto RenamePS2GamesOSD) 

"%~dp0BAT\Diagbox" gd 0e
cls
echo\
echo\
echo Scan Games List:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
setlocal DisableDelayedExpansion

"%~dp0BAT\hdl_dump" hdl_toc %@hdl_path% > PARTITION_GAMES.txt

"%~dp0BAT\busybox" sed -i "1d" PARTITION_GAMES.txt
"%~dp0BAT\busybox" sed -i -e "$ d" PARTITION_GAMES.txt
"%~dp0BAT\busybox" cut -c35-500 PARTITION_GAMES.txt | "%~dp0BAT\busybox" sort -k2 > PARTITION_GAMES_NEW.txt

type PARTITION_GAMES_NEW.txt
"%~dp0BAT\Diagbox" gd 0e
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0f
echo\
echo Enter the full name. Example: NFS Underground
echo\
"%~dp0BAT\Diagbox" gd 03
set /p "RenamePS2Games=Enter the name of the game you want to rename:"
IF "%RenamePS2Games%"=="" (goto GamesManagement)

"%~dp0BAT\Diagbox" gd 0f
echo\
echo Enter the new name. Example: Need For Speed: Underground
echo\
"%~dp0BAT\Diagbox" gd 03
set /p "RenamePS2GamesNEW=Enter the new name of your game:"
IF "%RenamePS2Games%"=="" (goto GamesManagement)

for /f "tokens=5*" %%C in (PARTITION_GAMES.txt) do ( echo %%C )
set %%C=gameid

"%~dp0BAT\Diagbox" gd 0e
cls
echo\
echo\
echo Game Selected "%RenamePS2Games%"
"%~dp0BAT\Diagbox" gd 0f
echo ----------------------------------------------------
echo\
"%~dp0BAT\Diagbox" gd 03

    echo        Renaming...
	echo        "%RenamePS2Games%"
	REM Why first renamed with GAME ID. ? To avoid errors if the name of the game is similar to another
	"%~dp0BAT\hdl_dump" modify %@hdl_path% "%RenamePS2Games%" "%gameid%"
	"%~dp0BAT\hdl_dump" modify %@hdl_path% "%gameid%" "%RenamePS2GamesNEW%"
	echo        "%RenamePS2GamesNEW%"
    echo        Completed...
	) else ( echo          Canceled... )

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

REM ######################################
:RenamePS2GamesDBTITLE
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
IF ERRORLEVEL 1 set language=ENG
IF ERRORLEVEL 2 set language=FRA

"%~dp0BAT\Diagbox" gd 0e
cls
echo\
echo\
echo Scan Games List:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
setlocal DisableDelayedExpansion

"%~dp0BAT\hdl_dump" hdl_toc %@hdl_path% > PARTITION_GAMES.txt

"%~dp0BAT\busybox" sed -i "1d" PARTITION_GAMES.txt
"%~dp0BAT\busybox" sed -i -e "$ d" PARTITION_GAMES.txt
"%~dp0BAT\busybox" cut -c35-500 PARTITION_GAMES.txt | "%~dp0BAT\busybox" sort -k2 > PARTITION_GAMES_NEW.txt

type PARTITION_GAMES_NEW.txt
"%~dp0BAT\Diagbox" gd 0e
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 07
	
    "%~dp0BAT\busybox" sed -i "s/\"//g" "%~dp0TMP\PARTITION_GAMES.txt"
	
	if %language%==ENG "%~dp0BAT\busybox" iconv -f utf8 -t ascii//TRANSLIT//IGNORE "%~dp0BAT\TitlesDB\gameidPS2ENG.txt" > "%~dp0TMP\gameid.txt"
    if %language%==FRA "%~dp0BAT\busybox" iconv -f utf8 -t ascii//TRANSLIT//IGNORE "%~dp0BAT\TitlesDB\gameidPS2FRA.txt" > "%~dp0TMP\gameid.txt"

    for /f "tokens=1*" %%C in (PARTITION_GAMES_NEW.txt) do (
	
	set "dbtitle="
	for /f "tokens=1*" %%A in (' findstr %%C "%~dp0TMP\gameid.txt" ') do (if not defined dbtitle set dbtitle=%%B
	
	"%~dp0BAT\Diagbox" gd 07
	echo\
    echo %%D
	echo %%C
	"%~dp0BAT\Diagbox" gd 03
	echo Rename to original Title: [%%B]
	
    REM Why first renamed with GAME ID. ? To avoid errors if the name of the game is similar to another
	"%~dp0BAT\hdl_dump" modify %@hdl_path% "%%D" "%%C"
	"%~dp0BAT\hdl_dump" modify %@hdl_path% "%%C" "%%B"
	echo\
  )
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

endlocal
pause & (goto GamesManagement)
REM ###############################################################################
:RenamePS2GamesOSD

cd /d "%~dp0TMP"

"%~dp0BAT\Diagbox" gd 0e
cls
echo\
echo\
echo Scanning Partitions Games:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03

"%~dp0BAT\hdl_dump" hdl_toc %@hdl_path% > "%~dp0TMP\PARTITION_GAMES.txt"

"%~dp0BAT\busybox" sed -i "1d" "%~dp0TMP\PARTITION_GAMES.txt"
"%~dp0BAT\busybox" sed -i -e "$ d" "%~dp0TMP\PARTITION_GAMES.txt"
"%~dp0BAT\busybox" cut -c35-500 "%~dp0TMP\PARTITION_GAMES.txt" | "%~dp0BAT\busybox" sort -k2 > "%~dp0TMP\PARTITION_GAMES_NEWX.txt"
"%~dp0BAT\busybox" cut -c35-500 "%~dp0TMP\PARTITION_GAMES.txt" > "%~dp0TMP\PARTITION_GAMES_NEW.txt"

type "%~dp0TMP\PARTITION_GAMES_NEWX.txt"
"%~dp0BAT\Diagbox" gd 0e
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03

   "%~dp0BAT\hdl_dump" toc %@hdl_path% | "%~dp0BAT\busybox" grep -e "0x1337" | "%~dp0BAT\busybox" cut -c30-250 | "%~dp0BAT\busybox" sed -e "s/^/;/" > "%~dp0TMP\PART_GAMES.log"
  
   "%~dp0BAT\busybox" paste -d " " "%~dp0TMP\PARTITION_GAMES_NEW.txt" "%~dp0TMP\PART_GAMES.log" > "%~dp0TMP\PARTITION_GAMES_NEW2.txt"
   "%~dp0BAT\busybox" cut -c14-500 "%~dp0TMP\PARTITION_GAMES_NEW2.txt" > "%~dp0TMP\PARTITION_GAMES_NEW3.txt"
   "%~dp0BAT\busybox" sed -i "s/ ;/;/g" "%~dp0TMP\PARTITION_GAMES_NEW3.txt"

setlocal DisableDelayedExpansion
"%~dp0BAT\Diagbox" gd 06
echo\
echo Keep in mind that the list of titles displayed are not those displayed in HDD-OSD, this is just to help you
echo\
"%~dp0BAT\Diagbox" gd 03
set /p gamename=Enter the name of the game you want to rename:
if "%gamename%"=="" if defined @GameManagementMenu (goto GamesManagement) else (goto HDDOSDPartManagement)
"%~dp0BAT\Diagbox" gd 0f

"%~dp0BAT\busybox" grep -m 1 "%gamename%" "%~dp0TMP\PARTITION_GAMES_NEW3.txt" | "%~dp0BAT\busybox" sed -e "s/__\./PP\./g" > "%~dp0TMP\gameselected.txt"
setlocal EnableDelayedExpansion

for /f "tokens=1* delims=;" %%f in (gameselected.txt) do (set PPName=%%g)

	"%~dp0BAT\hdl_dump_fix" dump_header %@hdl_path% "!PPName!" >nul 2>&1
	
    echo device %@hdl_path2% > "%~dp0TMP\pfs-log.txt"
    echo mount "!PPname!" >> "%~dp0TMP\pfs-log.txt"
	echo cd res >> "%~dp0TMP\pfs-log.txt"
    echo get info.sys >> "%~dp0TMP\pfs-log.txt"
    echo get man.xml >> "%~dp0TMP\pfs-log.txt"
	echo umount >> "%~dp0TMP\pfs-log.txt"
   	echo exit >> "%~dp0TMP\pfs-log.txt"
 	type "%~dp0TMP\pfs-log.txt" | "%~dp0BAT\pfsshell" >nul 2>&1

	"%~dp0BAT\Diagbox" gd 0e
    echo\
    echo\
	echo Titles displayed in PSBBN, XMB menu 
	"%~dp0BAT\Diagbox" gd 0f
    REM This is shit but with cat and grep command cmd don't show letter accent.
	chcp 65001 >nul 2>&1
    "%~dp0BAT\busybox" cat info.sys | "%~dp0BAT\busybox" grep -w "title =" > info.sys2 & type info.sys2
	echo\
	"%~dp0BAT\Diagbox" gd 0e
	echo Titles displayed in HDD-OSD
	"%~dp0BAT\Diagbox" gd 0f
	"%~dp0BAT\busybox" cat icon.sys | "%~dp0BAT\busybox" grep -e "title0" -e "title1"  > icon.sys2 & type icon.sys2
    chcp 1252 >nul 2>&1
	
	echo\
	echo\
	echo What title do you want to edit?
    echo Option: 1 = PSBBN, XMB menu
    echo Option: 2 = HDD-OSD
    CHOICE /C 12 /M "Select Option:"
	
    IF %ERRORLEVEL%==1 set Titletype=PSBBNXMB
    IF %ERRORLEVEL%==2 set Titletype=HDDOSD
	
	if !Titletype!==HDDOSD (
	echo\
    echo\
    echo What title line do you want to edit?
    echo Option: 1 = title0
    echo Option: 2 = title1
    CHOICE /C 12 /M "Select Option:"
    
    IF ERRORLEVEL 1 set title=0
    IF ERRORLEVEL 2 set title=1
	)

	echo\
    echo\
    if !Titletype!==HDDOSD echo 47 Characters max
    set /p newgamenametmp=Enter the New Game Name:
	"%~dp0BAT\Diagbox" gd 03

    echo "!newgamenametmp!"| "%~dp0BAT\busybox" sed -e "s/\&/\\\&/g; s./.\\\/.g" | "%~dp0BAT\busybox" iconv -f windows-1252 -t utf-8 > "%~dp0TMP\newgamenametmp.txt"
    "%~dp0BAT\busybox" sed -i "s/\"//g" "%~dp0TMP\newgamenametmp.txt"
    set /P newgamename=<"%~dp0TMP\newgamenametmp.txt"
    
    if !Titletype!==PSBBNXMB (
	"%~dp0BAT\busybox" sed -i -e "s/title = .*/title =/g; s/title =/title = !newgamename!/g" "%~dp0TMP\info.sys"
	"%~dp0BAT\busybox" sed -i -e "s/\"TOP-TITLE\" label=.*/\"TOP-TITLE\" label=/g; s/\"TOP-TITLE\" label=/\"TOP-TITLE\" label=\"!newgamename!\"/g" "%~dp0TMP\man.xml"
    echo device %@hdl_path2% > "%~dp0TMP\pfs-log.txt"
    echo mount "!PPName!" >> "%~dp0TMP\pfs-log.txt"
	echo cd res >> "%~dp0TMP\pfs-log.txt"
    echo put info.sys >> "%~dp0TMP\pfs-log.txt"
	echo put man.xml >> "%~dp0TMP\pfs-log.txt"
	echo umount >> "%~dp0TMP\pfs-log.txt"
   	echo exit >> "%~dp0TMP\pfs-log.txt"
 	type "%~dp0TMP\pfs-log.txt" | "%~dp0BAT\pfsshell" >nul 2>&1
	)
	
	if !Titletype!==HDDOSD (
    if !title!==0 ("%~dp0BAT\busybox" sed -i -e "s/title0 = .*/title0 = /g; s/title0 = /title0 = !newgamename!/g" "%~dp0TMP\icon.sys")
    if !title!==1 ("%~dp0BAT\busybox" sed -i -e "s/title1 = .*/title1 = /g; s/title1 = /title1 = !newgamename!/g" "%~dp0TMP\icon.sys")
    "%~dp0BAT\hdl_dump" modify_header %@hdl_path% "!PPName!" | findstr "icon.sys"
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

endlocal
endlocal

if defined @GameManagementMenu (pause & goto GamesManagement) else (pause & goto HDDOSDPartManagement)

REM #######################################################################################################################################################################
:RenamePS1GamesHDD

cd "%~dp0"
cls
rmdir /Q/S "%~dp0TMP" >nul 2>&1
mkdir "%~dp0TMP" >nul 2>&1

"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning for Playstation 2 HDDs:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "Playstation 2 HDD"
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "Playstation 2 HDD" | "%~dp0BAT\busybox" grep -o "hdd[0-9]:\|hdd[0-9][0-9]:" > "%~dp0TMP\hdl-hdd.txt" & "%~dp0BAT\busybox" cat "%~dp0TMP\hdl-hdd.txt" > "%~dp0TMP\hdl-hdd2.txt"
"%~dp0BAT\busybox" sed -i "s/hdd/\\\\.\\\PhysicalDrive/g; s/://g" "%~dp0TMP\hdl-hdd2.txt" >nul 2>&1

set /P @hdl_path2=<"%~dp0TMP\hdl-hdd2.txt"
set /P @hdl_path=<"%~dp0TMP\hdl-hdd.txt"
del "%~dp0TMP\hdl-hdd.txt" >nul 2>&1
IF "!@hdl_path!"=="" ( 
"%~dp0BAT\Diagbox" gd 0c
		echo         Playstation 2 HDD Not Detected
		echo         Drive Must Be Formatted First
		echo\
		echo\
"%~dp0BAT\Diagbox" gd 07
		rmdir /Q/S "%~dp0TMP" >nul 2>&1
		pause & (goto GamesManagement)
	)

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Rename a PS1 game:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1) Yes
"%~dp0BAT\Diagbox" gd 0c
echo         2) No
"%~dp0BAT\Diagbox" gd 0e
echo         3) Yes (Manually Choose your Partition)
echo         4) Yes (Rename Displayed name in HDD-OSD, PSBBN, XMB Menu)
echo\
"%~dp0BAT\Diagbox" gd 07
CHOICE /C 1234 /M "Select Option:"

IF %ERRORLEVEL%==1 set @pfs_pop=yes & set POPSPART=__.POPS
IF %ERRORLEVEL%==2 (goto GamesManagement)
IF %ERRORLEVEL%==3 set @pfs_pop=yesmanually
IF %ERRORLEVEL%==4 (goto RenamePS1GamesOSD)

IF %@pfs_pop%==yesmanually (
echo.
echo Choose the partition where your .VCDs to extract are located.
echo By default it will be the partition __.POPS 
echo.
echo 0.  __.POPS0
echo 1.  __.POPS1
echo 2.  __.POPS2
echo 3.  __.POPS3
echo 4.  __.POPS4
echo 5.  __.POPS5
echo 6.  __.POPS6
echo 7.  __.POPS7
echo 8.  __.POPS8
echo 9.  __.POPS9
echo 10. __.POPS
echo.

set choice=
set /p choice="Select Option:"
IF "!choice!"=="" set "@pfs_pop=" & (goto RenamePS1GamesHDD)

IF "!choice!"=="!choice!" set @pfs_pop=yesmanually & set POPSPART=__.POPS!choice!
IF "!choice!"=="10" set @pfs_pop=yes & set "choice=" & set POPSPART=__.POPS
)

"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Detecting POPS Partition:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 07

    echo device !@hdl_path2! > "%~dp0TMP\pfs-prt.txt"
    echo ls >> "%~dp0TMP\pfs-prt.txt"
    echo exit >> "%~dp0TMP\pfs-prt.txt"
    type "%~dp0TMP\pfs-prt.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" grep -o "%POPSPART%/" | "%~dp0BAT\busybox" head -1 > "%~dp0TMP\hdd-prt.txt"

	set /P @hdd_avl=<"%~dp0TMP\hdd-prt.txt"
    IF "!@hdd_avl!"=="%POPSPART%/" (
    "%~dp0BAT\Diagbox" gd 0a
	echo        %POPSPART% - Partition Detected
	"%~dp0BAT\Diagbox" gd 07
	) else (
	"%~dp0BAT\Diagbox" gd 0c
	echo        %POPSPART% - Partition NOT Detected
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

    echo device !@hdl_path2! > "%~dp0TMP\pfs-prt.txt"
	echo mount %POPSPART% >> "%~dp0TMP\pfs-prt.txt"
    echo ls >> "%~dp0TMP\pfs-prt.txt"
    echo exit >> "%~dp0TMP\pfs-prt.txt"
    type "%~dp0TMP\pfs-prt.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" grep -ie ".*\.VCD$" | "%~dp0BAT\busybox" sed "s/\.[^.]*$//" > "%~dp0TMP\%POPSPART%.txt"
	type "%~dp0TMP\%POPSPART%.txt"
	
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
	echo device %@hdl_path2% > "%~dp0TMP\pfs-pops.txt"
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

rmdir /Q/S "%~dp0TMP" >nul 2>&1

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

REM #####################################################
:RenamePS1GamesOSD

cd /d "%~dp0TMP"

"%~dp0BAT\Diagbox" gd 0e
cls
echo\
echo\
echo Scanning Games List:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03

    "%~dp0BAT\hdl_dump" toc %@hdl_path% | "%~dp0BAT\busybox" grep -e "\.POPS\." | "%~dp0BAT\busybox" cut -c30-250 | "%~dp0BAT\busybox" sed "s/.\{15\}/& /" | "%~dp0BAT\busybox" sort -k2 | "%~dp0BAT\busybox" sed -e "s/\(.\{15\}\)./\1/" | "%~dp0BAT\busybox" sed -e "s/\s*$//" > "%~dp0TMP\PART_GAMES.log"
    "%~dp0BAT\busybox" grep -o "[A-Z][A-Z][A-Z][A-Z][-][0-9][0-9][0-9][0-9][0-9]" "%~dp0TMP\PART_GAMES.log" | "%~dp0BAT\busybox" sed "s/-/_/"g | "%~dp0BAT\busybox" sed "s/.\{8\}/&./" > "%~dp0TMP\ID.txt"
	
	"%~dp0BAT\busybox" grep -o "LSP-[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]\|LSP-[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]" "%~dp0TMP\PART_GAMES.log" | "%~dp0BAT\busybox" sed "s/.\{9\}/&./" | "%~dp0BAT\busybox" sed "s/LSP-/LSP/g; s/LSP90712\.7001/907127\.001/g" > "%~dp0TMP\LSPID.txt"
	"%~dp0BAT\busybox" grep "PP\.LSP-" "%~dp0TMP\PART_GAMES.log" > "%~dp0TMP\PART_GAMESLSP.log"
	"%~dp0BAT\busybox" paste -d " " "%~dp0TMP\LSPID.txt" "%~dp0TMP\PART_GAMESLSP.log" > "%~dp0TMP\LSPIDPPName.txt"
	
	"%~dp0BAT\busybox" sed -i "/PP\.LSP-/d" "%~dp0TMP\PART_GAMES.log"
    "%~dp0BAT\busybox" paste -d " " "%~dp0TMP\ID.txt" "%~dp0TMP\PART_GAMES.log" > "%~dp0TMP\IDPPName.txt"
	for /f "tokens=*" %%A in (LSPIDPPName.txt) do (echo %%~A>> "%~dp0TMP\IDPPName.txt")
	for /f "tokens=*" %%A in (PART_GAMESLSP.log) do (echo %%~A>> "%~dp0TMP\PART_GAMES.log")

    for %%F in ( "PART_GAMES.log" ) do if %%~zF==0 del "%%F"
	if exist "%~dp0TMP\PART_GAMES.log" (
	
	for /f "tokens=1*" %%f in (IDPPName.txt) do (set gameid=%%f
	
	findstr !gameid! "%~dp0BAT\TitlesDB\gameidPS1.txt" >nul
	if errorlevel 1 (
	echo %%g >> "%~dp0TMP\GameList.txt"
	)
	
	set "dbtitle="
 	for /f "tokens=1*" %%A in ( 'findstr !gameid! "%~dp0BAT\TitlesDB\gameidPS1.txt"' ) do (
	if not defined dbtitle set dbtitle=%%B
	echo !dbtitle! >> "%~dp0TMP\GameList.txt"
	   )
	  )
	  
   "%~dp0BAT\busybox" sed -i "s/\s*$//" "%~dp0TMP\GameList.txt"
   "%~dp0BAT\busybox" sed -i "s/^/;/" "%~dp0TMP\PART_GAMES.log"
   "%~dp0BAT\busybox" paste -d " " "%~dp0TMP\GameList.txt" "%~dp0TMP\PART_GAMES.log" | "%~dp0BAT\busybox" sort > "%~dp0TMP\GameList2.txt"
   "%~dp0BAT\busybox" sed -i "s/ ;/;/g" "%~dp0TMP\GameList2.txt"
   "%~dp0BAT\busybox" cat "%~dp0TMP\GameList.txt" | "%~dp0BAT\busybox" sort > "%~dp0TMP\GameListPS1.txt"

type "%~dp0TMP\GameListPS1.txt" ) else ( echo No PS1 game partition detected)
 
"%~dp0BAT\Diagbox" gd 0e
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 06

setlocal DisableDelayedExpansion
echo\
echo Keep in mind that the list of titles displayed are not those displayed in HDD-OSD, this is just to help you
echo\
"%~dp0BAT\Diagbox" gd 03
set /p gamename=Enter the name of the game you want to rename:
if "%gamename%"=="" if defined @GameManagementMenu (goto GamesManagement) else (goto HDDOSDPartManagement)
"%~dp0BAT\Diagbox" gd 0f

"%~dp0BAT\busybox" grep -m 1 "%gamename%" "%~dp0TMP\GameList2.txt" > "%~dp0TMP\gameselected.txt"
setlocal EnableDelayedExpansion

for /f "tokens=1* delims=;" %%f in (gameselected.txt) do (set PPName=%%g)

	"%~dp0BAT\hdl_dump_fix" dump_header %@hdl_path% "!PPName!" >nul 2>&1
	
    echo device %@hdl_path2% > "%~dp0TMP\pfs-log.txt"
    echo mount "!PPname!" >> "%~dp0TMP\pfs-log.txt"
	echo cd res >> "%~dp0TMP\pfs-log.txt"
    echo get info.sys >> "%~dp0TMP\pfs-log.txt"
    echo get man.xml >> "%~dp0TMP\pfs-log.txt"
	echo umount >> "%~dp0TMP\pfs-log.txt"
   	echo exit >> "%~dp0TMP\pfs-log.txt"
 	type "%~dp0TMP\pfs-log.txt" | "%~dp0BAT\pfsshell" >nul 2>&1

	"%~dp0BAT\Diagbox" gd 0e
    echo\
    echo\
	echo Titles displayed in PSBBN, XMB menu 
	"%~dp0BAT\Diagbox" gd 0f
    REM This is shit but with cat and grep command cmd don't show letter accent.
	chcp 65001 >nul 2>&1
    "%~dp0BAT\busybox" cat info.sys | "%~dp0BAT\busybox" grep -w "title =" > info.sys2 & type info.sys2
	echo\
	"%~dp0BAT\Diagbox" gd 0e
	echo Titles displayed in HDD-OSD
	"%~dp0BAT\Diagbox" gd 0f
	"%~dp0BAT\busybox" cat icon.sys | "%~dp0BAT\busybox" grep -e "title0" -e "title1"  > icon.sys2 & type icon.sys2
    chcp 1252 >nul 2>&1
	
	echo\
	echo\
	echo What title do you want to edit?
    echo Option: 1 = PSBBN, XMB menu
    echo Option: 2 = HDD-OSD
    CHOICE /C 12 /M "Select Option:"
	
    IF %ERRORLEVEL%==1 set Titletype=PSBBNXMB
    IF %ERRORLEVEL%==2 set Titletype=HDDOSD
	
	if !Titletype!==HDDOSD (
	echo\
    echo\
    echo What title line do you want to edit?
    echo Option: 1 = title0
    echo Option: 2 = title1
    CHOICE /C 12 /M "Select Option:"
    
    IF ERRORLEVEL 1 set title=0
    IF ERRORLEVEL 2 set title=1
	)

	echo\
    echo\
    if !Titletype!==HDDOSD echo 47 Characters max
    set /p newgamenametmp=Enter the New Game Name:
	"%~dp0BAT\Diagbox" gd 03

    echo "!newgamenametmp!"| "%~dp0BAT\busybox" sed -e "s/\&/\\\&/g; s./.\\\/.g" | "%~dp0BAT\busybox" iconv -f windows-1252 -t utf-8 > "%~dp0TMP\newgamenametmp.txt"
    "%~dp0BAT\busybox" sed -i "s/\"//g" "%~dp0TMP\newgamenametmp.txt"
    set /P newgamename=<"%~dp0TMP\newgamenametmp.txt"
    
    if !Titletype!==PSBBNXMB (
	"%~dp0BAT\busybox" sed -i -e "s/title = .*/title =/g; s/title =/title = !newgamename!/g" "%~dp0TMP\info.sys"
	"%~dp0BAT\busybox" sed -i -e "s/\"TOP-TITLE\" label=.*/\"TOP-TITLE\" label=/g; s/\"TOP-TITLE\" label=/\"TOP-TITLE\" label=\"!newgamename!\"/g" "%~dp0TMP\man.xml"
    echo device %@hdl_path2% > "%~dp0TMP\pfs-log.txt"
    echo mount "!PPName!" >> "%~dp0TMP\pfs-log.txt"
	echo cd res >> "%~dp0TMP\pfs-log.txt"
    echo put info.sys >> "%~dp0TMP\pfs-log.txt"
	echo put man.xml >> "%~dp0TMP\pfs-log.txt"
	echo umount >> "%~dp0TMP\pfs-log.txt"
   	echo exit >> "%~dp0TMP\pfs-log.txt"
 	type "%~dp0TMP\pfs-log.txt" | "%~dp0BAT\pfsshell" >nul 2>&1
	)
	
	if !Titletype!==HDDOSD (
    if !title!==0 ("%~dp0BAT\busybox" sed -i -e "s/title0=.*/title0=/g; s/title0=/title0=!newgamename!/g" "%~dp0TMP\icon.sys")
    if !title!==1 ("%~dp0BAT\busybox" sed -i -e "s/title1=.*/title1=/g; s/title1=/title1=!newgamename!/g" "%~dp0TMP\icon.sys")
    "%~dp0BAT\hdl_dump" modify_header %@hdl_path% "!PPName!" | findstr "icon.sys"
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

endlocal
endlocal
if defined @GameManagementMenu (pause & goto GamesManagement) else (pause & goto HDDOSDPartManagement)

REM #######################################################################################################################################################################
:DeleteChoiceGamesHDD

cd "%~dp0"
cls

mkdir "%~dp0TMP" >nul 2>&1

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Choose what type of games you want to delete:
echo ----------------------------------------------------
echo         PS2 Games Not yet available, I recommend you to delete the game directly from OPL
"%~dp0BAT\Diagbox" gd 0c
echo         2) No
"%~dp0BAT\Diagbox" gd 0e
echo         3) Yes PS1 Games (Delete .VCD)
echo\
"%~dp0BAT\Diagbox" gd 07
CHOICE /C 123 /M "Select Option:"

IF %ERRORLEVEL%==1 (goto DeleteChoiceGamesHDD)
IF %ERRORLEVEL%==2 (goto GamesManagement)
IF %ERRORLEVEL%==3 (goto DeletePS1GamesHDD)

REM #######################################################################################################################################################################
:DeletePS1GamesHDD

cd "%~dp0"
cls

mkdir "%~dp0TMP" >nul 2>&1

"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning for Playstation 2 HDDs:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "Playstation 2 HDD"
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "Playstation 2 HDD" | "%~dp0BAT\busybox" grep -o "hdd[0-9]:\|hdd[0-9][0-9]:" > "%~dp0TMP\hdl-hdd.txt"
"%~dp0BAT\busybox" sed -i "s/hdd/\\\\.\\\PhysicalDrive/g; s/://g" "%~dp0TMP\hdl-hdd.txt"

set /P @hdl_path=<"%~dp0TMP\hdl-hdd.txt"
del "%~dp0TMP\hdl-hdd.txt" >nul 2>&1
IF "!@hdl_path!"=="" ( 
"%~dp0BAT\Diagbox" gd 0c
		echo         Playstation 2 HDD Not Detected
		echo         Drive Must Be Formatted First
		echo\
		echo\
"%~dp0BAT\Diagbox" gd 07
		rmdir /Q/S "%~dp0TMP" >nul 2>&1
		pause & (goto GamesManagement)
	)

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Remove .VCD:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1) Yes
"%~dp0BAT\Diagbox" gd 0c
echo         2) No
"%~dp0BAT\Diagbox" gd 0e
echo         3) Yes (Manually Choose your Partition)
echo\
"%~dp0BAT\Diagbox" gd 07
CHOICE /C 123 /M "Select Option:"

IF %ERRORLEVEL%==1 set @pfs_pop=yes & set POPSPART=__.POPS
IF %ERRORLEVEL%==2 (goto GamesManagement)
IF %ERRORLEVEL%==3 set @pfs_pop=yesmanually

IF %@pfs_pop%==yesmanually (
echo.
echo Choose the partition where your .VCDs to extract are located.
echo By default it will be the partition __.POPS 
echo.
echo 0.  __.POPS0
echo 1.  __.POPS1
echo 2.  __.POPS2
echo 3.  __.POPS3
echo 4.  __.POPS4
echo 5.  __.POPS5
echo 6.  __.POPS6
echo 7.  __.POPS7
echo 8.  __.POPS8
echo 9.  __.POPS9
echo 10. __.POPS
echo.

set choice=
set /p choice="Select Option:"
IF "!choice!"=="" set "@pfs_pop=" & (goto DeletePS1GamesHDD)

IF "!choice!"=="!choice!" set @pfs_pop=yesmanually & set POPSPART=__.POPS!choice!
IF "!choice!"=="10" set @pfs_pop=yes & set "choice=" & set POPSPART=__.POPS

)

"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Detecting POPS Partition:
echo ----------------------------------------------------
    "%~dp0BAT\Diagbox" gd 07
    echo device !@hdl_path! > "%~dp0TMP\pfs-prt.txt"
    echo ls >> "%~dp0TMP\pfs-prt.txt"
    echo exit >> "%~dp0TMP\pfs-prt.txt"
    type "%~dp0TMP\pfs-prt.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" grep -o "%POPSPART%/" | "%~dp0BAT\busybox" head -1 > "%~dp0TMP\hdd-prt.txt"

    set /P @hdd_avl=<"%~dp0TMP\hdd-prt.txt"
    IF "!@hdd_avl!"=="%POPSPART%/" (
    "%~dp0BAT\Diagbox" gd 0a
	echo        %POPSPART% - Partition Detected
	"%~dp0BAT\Diagbox" gd 07
	) else (
	"%~dp0BAT\Diagbox" gd 0c
	echo        %POPSPART% - Partition NOT Detected
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

    echo device !@hdl_path! > "%~dp0TMP\pfs-prt.txt"
	echo mount %POPSPART% >> "%~dp0TMP\pfs-prt.txt"
    echo ls >> "%~dp0TMP\pfs-prt.txt"
    echo exit >> "%~dp0TMP\pfs-prt.txt"
    type "%~dp0TMP\pfs-prt.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" grep -ie ".*\.VCD$" > "%~dp0TMP\%POPSPART%.txt"
	type "%~dp0TMP\%POPSPART%.txt"

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
	echo device %@hdl_path% > "%~dp0TMP\pfs-pops.txt"
	echo mount %POPSPART% >> "%~dp0TMP\pfs-pops.txt"
	echo rm "%DeletePS1Games%" >> "%~dp0TMP\pfs-pops.txt"
	echo umount >> "%~dp0TMP\pfs-pops.txt"
	echo exit >> "%~dp0TMP\pfs-pops.txt"
	type "%~dp0TMP\pfs-pops.txt" | "%~dp0BAT\pfsshell" >nul 2>&1
    echo          Completed...
	cd "%~dp0"

rmdir /Q/S "%~dp0TMP" >nul 2>&1

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
    "%~dp0BAT\wget" -q --show-progress https://github.com/PS2-Widescreen/OPL-Widescreen-Cheats/releases/download/Latest/widescreen_hacks.zip -O BAT\PS2-OPL-CHT-Widescreen.zip
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
	
	"%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0BAT\PS2-OPL-CHT-Widescreen.zip" -o"%~dp0CHT\WIDE" !gameidcht!.cht -r -y
	move WIDE\CHT\!gameidcht!.cht "%~dp0CHT\!gameidcht!.chtWIDE" >nul 2>&1
	
	"%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0BAT\PS2-OPL-CHT-Widescreen.zip" -o"%~dp0CHT\WIDE" !gameidcht!_v?.??.cht -r -y
	cd /d "%~dp0CHT\WIDE\CHT" >nul 2>&1 & ren !gameidcht!_v?.??.cht !gameidcht!.chtWIDE2 >nul 2>&1 & move *.chtWIDE2 "%~dp0CHT\WIDE2" >nul 2>&1

	cd /d "%~dp0CHT" & rmdir /Q/S "%~dp0CHT\WIDE\" >nul 2>&1

)

For %%C in (*.cht) do (
"%~dp0BAT\busybox" sed -n "/Mastercode/,/ /p" "%~dp0CHT\%%C" > "%~dp0TMP\Mastercode.txt"
"%~dp0BAT\busybox" sed -i "1d" "%~dp0TMP\Mastercode.txt"
"%~dp0BAT\busybox" sed -i "2,20d" "%~dp0TMP\Mastercode.txt"
"%~dp0BAT\busybox" sed -i "s/\s*$//" "%~dp0TMP\Mastercode.txt"
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

"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning for Playstation 2 HDDs:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "Playstation 2 HDD"
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "Playstation 2 HDD" | "%~dp0BAT\busybox" grep -o "hdd[0-9]:\|hdd[0-9][0-9]:" > "%~dp0TMP\hdl-hdd.txt"

set /P @hdl_path=<"%~dp0TMP\hdl-hdd.txt"
del "%~dp0TMP\hdl-hdd.txt" >nul 2>&1
IF "!@hdl_path!"=="" ( 
"%~dp0BAT\Diagbox" gd 0c
		echo         Playstation 2 HDD Not Detected
		echo         Drive Must Be Formatted First
		echo\
		echo\
"%~dp0BAT\Diagbox" gd 07
		rmdir /Q/S "%~dp0TMP" >nul 2>&1
		pause & (goto GamesManagement)
	)

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Create Virtual Memory Card?
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1) Yes
"%~dp0BAT\Diagbox" gd 0c
echo         2) No
"%~dp0BAT\Diagbox" gd 0e
REM echo         3) Yes (Manually choose the game)
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

"%~dp0BAT\hdl_dump" hdl_toc %@hdl_path% > "%~dp0TMP\PARTITION_GAMES.txt"

"%~dp0BAT\busybox" sed -i "1d" "%~dp0TMP\PARTITION_GAMES.txt"
"%~dp0BAT\busybox" sed -i -e "$ d" "%~dp0TMP\PARTITION_GAMES.txt"
"%~dp0BAT\busybox" cut -c35-500 "%~dp0TMP\PARTITION_GAMES.txt" | "%~dp0BAT\busybox" sort -k2 > "%~dp0TMP\PARTITION_GAMES_NEW.txt"

type "%~dp0TMP\PARTITION_GAMES_NEW.txt"
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
IF ERRORLEVEL 1 set VMC_TYPE=MULTI
IF ERRORLEVEL 2 set VMC_TYPE=GENERIC

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

if !VMC_TYPE!==MULTI (
for /f "tokens=1*" %%f in (PARTITION_GAMES_NEW.txt) do (
set VMC_NAME=%%f

echo\
echo %%g
echo %%f
echo !VMC_SIZE!MB
cd /d "%~dp0VMC" & "%~dp0BAT\genvmc.exe" !VMC_SIZE! !VMC_NAME!_0.bin | findstr "created"
 )
)

if !VMC_TYPE!==GENERIC ( 
echo\
echo Individual !VMC_TYPE!_0
echo !VMC_SIZE!MB
echo\
cd /d "%~dp0VMC" & "%~dp0BAT\genvmc.exe" !VMC_SIZE! GENERIC_0.bin | findstr "created" 
)

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
copy "%~dp0BAT\hdl_dump.exe" "%~dp0TMP" >nul 2>&1
copy "%~dp0BAT\TitlesDB\gameidPS1.txt" "%~dp0TMP\gameid.txt" >nul 2>&1
if exist "%~dp0POPS-Binaries\Hugopocked_POPStarter_Fixes.zip" "%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0POPS-Binaries\Hugopocked_POPStarter_Fixes.zip" -o"%~dp0TMP" id.txt -r -y

"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning for Playstation 2 HDDs:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "Playstation 2 HDD"
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "Playstation 2 HDD" | "%~dp0BAT\busybox" grep -o "hdd[0-9]:\|hdd[0-9][0-9]:" > "%~dp0TMP\hdl-hdd.txt" & "%~dp0BAT\busybox" cat "%~dp0TMP\hdl-hdd.txt" > "%~dp0TMP\hdl-hdd2.txt"
"%~dp0BAT\busybox" sed -i "s/hdd/\\\\.\\\PhysicalDrive/g; s/://g" "%~dp0TMP\hdl-hdd.txt" >nul 2>&1

set /P @hdl_path2=<"%~dp0TMP\hdl-hdd2.txt"
set /P @hdl_path=<"%~dp0TMP\hdl-hdd.txt"
del "%~dp0TMP\hdl-hdd.txt" >nul 2>&1
IF "!@hdl_path!"=="" (
"%~dp0BAT\Diagbox" gd 0c
		echo         Playstation 2 HDD Not Detected
		echo         Drive Must Be Formatted First
		echo\
		echo\
"%~dp0BAT\Diagbox" gd 07
		rmdir /Q/S "%~dp0TMP" >nul 2>&1
        pause & (goto HDDOSDPartManagement)
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
echo         1) Yes (Install each Multi-Disc as a single partition)
"%~dp0BAT\Diagbox" gd 0c
echo         2) No
"%~dp0BAT\Diagbox" gd 0e
echo         3) Yes (Install each Multi-Disc in the same partition as (Disc 1) )
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
	"%~dp0BAT\wget" -q --show-progress "https://archive.org/download/OPLM_ART_2022_05/OPLM_ART_2022_05.zip/PS1%%2FSCES_000.01%%2FSCES_000.01_COV.jpg" -O "%~dp0TMP\SCES_000.01_COV.jpg" >nul 2>&1
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
"%~dp0BAT\POPS-VCD-ID-Extractor" "%~dp0POPS\temp\!appfolder!\!Disc0!" | "%~dp0BAT\busybox" sed -e "s/-/_/g" > "%~dp0TMP\VCDID.txt" & set /P ID=<"%~dp0TMP\VCDID.txt"
"%~dp0BAT\busybox" ls | "%~dp0BAT\busybox" grep -ie ".*\.VCD$" > "%~dp0TMP\Name.txt" & "%~dp0BAT\busybox" sed -i "s/!ID!.//g" "%~dp0TMP\Name.txt"
)
if defined Disc1 (
"%~dp0BAT\POPS-VCD-ID-Extractor" "%~dp0POPS\temp\!appfolder!\!Disc1!" | "%~dp0BAT\busybox" sed -e "s/-/_/g" > "%~dp0TMP\VCDID.txt" & set /P ID=<"%~dp0TMP\VCDID.txt"
"%~dp0BAT\busybox" ls | "%~dp0BAT\busybox" grep -ie "!Disc1!" | "%~dp0BAT\busybox" sed -e "s/!ID!\.//g" | "%~dp0BAT\busybox" sed -e "2,7d" > "%~dp0TMP\Name.txt"
)
"%~dp0BAT\busybox" paste -d " " "%~dp0TMP\VCDID.txt" "%~dp0TMP\Name.txt" | "%~dp0BAT\busybox" sed "s/.\{12\}/&/" > "%~dp0POPS\Temp\!appfolder!\VCDIDName.txt"

if defined Disc1 "%~dp0BAT\busybox" sed -i -e "s/ (Disc [1-6])//g" "%~dp0TMP\gameid.txt"
setlocal DisableDelayedExpansion
for /f "tokens=1*" %%F in (VCDIDName.txt) do (

	 set "PPtitle="
 	 for /f "tokens=1*" %%A in ( 'findstr %%F "%~dp0TMP\gameid.txt"' ) do (if not defined PPtitle set PPtitle=%%B
	 )

if not defined PPtitle set PPtitle=%%~nG

setlocal EnableDelayedExpansion

REM Educational games with LightSpan Sofware PlayStation ID
set "LSPID="
echo %%F| "%~dp0BAT\busybox" grep -o "[0-9][0-9][0-9][0-9][0-9][0-9].[0-9][0-9][0-9]\|[0-9][0-9][0-9][0-9][0-9].[0-9][0-9][0-9]" | "%~dp0BAT\busybox" sed -e "s/\.//g; s/-//g" | "%~dp0BAT\busybox" sed -e "s/^/LSP-/" > "%~dp0TMP\EducID.txt" & set /P LSPID=<"%~dp0TMP\EducID.txt"

if defined LSPID (
echo "!PPtitle!"| "%~dp0BAT\busybox" sed -e "s/\""//g" | "%~dp0BAT\busybox" iconv -f utf8 -t ascii//TRANSLIT//IGNORE | "%~dp0BAT\busybox" sed -e "s/-//g; s/\./_/g; s/LSP-//g" | "%~dp0BAT\busybox" sed -e "s/^/PP.%%F.POPS./" > "%~dp0TMP\PPNameTMP.txt"
"%~dp0BAT\busybox" sed -ie "s/%%F/!LSPID!/g" "%~dp0TMP\PPNameTMP.txt"
"%~dp0BAT\busybox" cut -c0-31 "%~dp0TMP\PPNameTMP.txt" > "%~dp0TMP\PPName.txt"

) else (
echo "!PPtitle!"| "%~dp0BAT\busybox" sed -e "s/\""//g" | "%~dp0BAT\busybox" iconv -f utf8 -t ascii//TRANSLIT//IGNORE | "%~dp0BAT\busybox" sed -e "s/-/_/g; s/\./_/g" | "%~dp0BAT\busybox" sed -e "s/^/PP.%%F.POPS./" | "%~dp0BAT\busybox" cut -c0-32 > "%~dp0TMP\PPName.txt"
"%~dp0BAT\busybox" sed -r -i "s/^(.{11})(.{1})/\1/" "%~dp0TMP\PPName.txt"
"%~dp0BAT\busybox" sed -i "s/.\{8\}/&-/" "%~dp0TMP\PPName.txt"
)

REM Remove illegal character Partition name
"%~dp0BAT\busybox" sed -i "s/\s*$//" "%~dp0TMP\PPName.txt"
"%~dp0BAT\busybox" sed -i "s/ /_/g" "%~dp0TMP\PPName.txt"
"%~dp0BAT\busybox" sed -i "s/?/_/g" "%~dp0TMP\PPName.txt"
"%~dp0BAT\busybox" sed -i "s/'/_/g" "%~dp0TMP\PPName.txt"
"%~dp0BAT\busybox" sed -i "s/`/_/g" "%~dp0TMP\PPName.txt"
"%~dp0BAT\busybox" sed -i "s/,/_/g" "%~dp0TMP\PPName.txt"
"%~dp0BAT\busybox" sed -i "s/;/_/g" "%~dp0TMP\PPName.txt"
"%~dp0BAT\busybox" sed -i "s/:/_/g" "%~dp0TMP\PPName.txt"
"%~dp0BAT\busybox" sed -i "s/?/_/g" "%~dp0TMP\PPName.txt"
"%~dp0BAT\busybox" sed -i "s/?/_/g" "%~dp0TMP\PPName.txt"
"%~dp0BAT\busybox" sed -i "s/\&/_/g" "%~dp0TMP\PPName.txt"
"%~dp0BAT\busybox" sed -i "s/?/_/g" "%~dp0TMP\PPName.txt"
"%~dp0BAT\busybox" sed -i "s/+/_/g" "%~dp0TMP\PPName.txt"
"%~dp0BAT\busybox" sed -i "s/=/_/g" "%~dp0TMP\PPName.txt"
"%~dp0BAT\busybox" sed -i "s/#/_/g" "%~dp0TMP\PPName.txt"
"%~dp0BAT\busybox" sed -i "s/?/_/g" "%~dp0TMP\PPName.txt"
"%~dp0BAT\busybox" sed -i "s/^!/_/g" "%~dp0TMP\PPName.txt"
"%~dp0BAT\busybox" sed -i "s/\$/_/g" "%~dp0TMP\PPName.txt"
"%~dp0BAT\busybox" sed -i "s/?/_/g" "%~dp0TMP\PPName.txt"
"%~dp0BAT\busybox" sed -i "s/~/_/g" "%~dp0TMP\PPName.txt"
"%~dp0BAT\busybox" sed -i "s/@/_/g" "%~dp0TMP\PPName.txt"
"%~dp0BAT\busybox" sed -i "s/\*/_/g" "%~dp0TMP\PPName.txt"
"%~dp0BAT\busybox" sed -i "s/%%/_/g" "%~dp0TMP\PPName.txt"
"%~dp0BAT\busybox" sed -i "s/[{}]/_/g" "%~dp0TMP\PPName.txt"
"%~dp0BAT\busybox" sed -i "s/\[/_/g; s/\]/_/g" "%~dp0TMP\PPName.txt"
"%~dp0BAT\busybox" sed -i "s/(/_/g; s/)/_/g" "%~dp0TMP\PPName.txt"
"%~dp0BAT\busybox" sed -i "s/\^/_/g" "%~dp0TMP\PPName.txt"

"%~dp0BAT\busybox" sed -i "y/abcdefghijklmnopqrstuvwxyz/ABCDEFGHIJKLMNOPQRSTUVWXYZ/" "%~dp0TMP\PPName.txt"
if not defined LSPID "%~dp0BAT\busybox" sed -i "s/\(.\{7\}\)./\1/" "%~dp0TMP\PPName.txt"
REM "%~dp0BAT\busybox" sed -i "s/.\{7\}/&-/" "%~dp0TMP\PPName.txt"
set /P PPName=<"%~dp0TMP\PPName.txt"

REM echo !PPName!

if defined LSPID "%~dp0BAT\busybox" sed -r -i "s/^(.{6})(.{1})/\1/" "%~dp0TMP\PPName.txt"
move "%~dp0TMP\POPSTARTER.KELF" "%~dp0POPS\Temp\!appfolder!\EXECUTE.KELF" >nul 2>&1
move "%~dp0TMP\hdl_dump.exe" "%~dp0POPS\Temp\!appfolder!\" >nul 2>&1

REM PAUSE

echo\
echo\
echo Creating !PPName! Partition:
echo ----------------------------------------------------
echo\

    echo         Getting game information...
    "%~dp0BAT\busybox" grep -o "LSP[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]\|LSP[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]\|[A-Z][A-Z][A-Z][A-Z][-][0-9][0-9][0-9][0-9][0-9]" "%~dp0TMP\PPName.txt" > "%~dp0TMP\DetectID.txt" & set /P gameid2=<"%~dp0TMP\DetectID.txt"

    "%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0BAT\HDD-PSBBN_XMB_SAMPLE_HEADER.zip" -o"%~dp0POPS\Temp\!appfolder!" -r -y >nul 2>&1
	"%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0BAT\PSBBN_XMB_PS1_GAMEINFO_Database.7z" -o"%~dp0TMP" "!gameid2!.html" -r -y >nul 2>&1

    "%~dp0BAT\busybox" awk " NF > 0 " "%~dp0TMP\!gameid2!.html" > "%~dp0POPS\Temp\!appfolder!\!gameid2!.html" 2>&1
	"%~dp0BAT\busybox" sed -i "s/Official Title/OFFICIAL TITLE/g; s/Date Released/DATE RELEASED/g; s/Region/REGION/g; s/Developer/DEVELOPER/g; s/Publisher/PUBLISHER/g; s/Genre/GENRE/g" "%~dp0POPS\Temp\!appfolder!\!gameid2!.html"
    REM "%~dp0BAT\busybox" grep -A2 "REGION" "%~dp0POPS\Temp\!appfolder!\!gameid2!.html" | "%~dp0BAT\busybox" sed "/REGION/d; /<td style=/d" | "%~dp0BAT\busybox" sed "s/&nbsp; / /g; s/^.*;//g; s/<\/td>//g; s|[\t][\t][\t]*||g; s/\s*$//" | "%~dp0BAT\busybox" sed -e "2,20d" > "%~dp0TMP\REGION.txt" & set /P REGIONTMP=<"%~dp0TMP\REGION.txt"
	"%~dp0BAT\busybox" grep -A2 "DATE RELEASED" "%~dp0POPS\Temp\!appfolder!\!gameid2!.html" | "%~dp0BAT\busybox" sed "/DATE RELEASED/d; /<td style=/d" | "%~dp0BAT\busybox" sed "s/&nbsp; / /g; s/^.*;//g; s/<\/td>//g; s|[\t][\t][\t]*||g; s/\s*$//" | "%~dp0BAT\busybox" sed -e "2,20d" > "%~dp0TMP\RELEASE.txt" & set /P RELEASETMP=<"%~dp0TMP\RELEASE.txt"
	"%~dp0BAT\busybox" grep -A2 "DEVELOPER" "%~dp0POPS\Temp\!appfolder!\!gameid2!.html" | "%~dp0BAT\busybox" sed "/DEVELOPER/d; /<td style=/d" | "%~dp0BAT\busybox" sed "s/&nbsp; / /g; s/^.*;//g; s/<\/td>//g; s|[\t][\t][\t]*||g; s/\s*$//" | "%~dp0BAT\busybox" sed -e "2,20d" > "%~dp0TMP\DEVELOPER.txt" & set /P DEVELOPERTMP=<"%~dp0TMP\DEVELOPER.txt"
    "%~dp0BAT\busybox" grep -A2 "PUBLISHER" "%~dp0POPS\Temp\!appfolder!\!gameid2!.html" | "%~dp0BAT\busybox" sed "/PUBLISHER/d; /<td style=/d" | "%~dp0BAT\busybox" sed "s/&nbsp; / /g; s/^.*;//g; s/<\/td>//g; s|[\t][\t][\t]*||g; s/\s*$//" | "%~dp0BAT\busybox" sed -e "2,20d" > "%~dp0TMP\PUBLISHER.txt" & set /P PUBLISHERTMP=<"%~dp0TMP\PUBLISHER.txt"
	"%~dp0BAT\busybox" grep -A2 "GENRE " "%~dp0POPS\Temp\!appfolder!\!gameid2!.html" | "%~dp0BAT\busybox" sed "/GENRE /d; /<td style=/d" | "%~dp0BAT\busybox" sed "s/&nbsp; / /g; s/^.*;//g; s/<\/td>//g; s|[\t][\t][\t]*||g; s/\s*$//" | "%~dp0BAT\busybox" sed -e "2,20d" > "%~dp0TMP\GENRE.txt" & set /P GENRETMP=<"%~dp0TMP\GENRE.txt"

     REM Game ID with PBPX other region than JAP
	 set "REGIONTMP="
     if "%%F"=="PAPX_900.28" set REGIONTMP=E
     if "%%F"=="PAPX_900.44" set REGIONTMP=A
     if "%%F"=="PBPX_950.02" set REGIONTMP=U
     if "%%F"=="PBPX_950.01" set REGIONTMP=E
     if "%%F"=="PBPX_950.03" set REGIONTMP=U
     if "%%F"=="PBPX_950.04" set REGIONTMP=U
     if "%%F"=="PBPX_950.06" set REGIONTMP=U
     if "%%F"=="PBPX_950.07" set REGIONTMP=E
     if "%%F"=="PBPX_950.08" set REGIONTMP=E
     if "%%F"=="PBPX_950.09" set REGIONTMP=U
     if "%%F"=="PBPX_950.10" set REGIONTMP=U
     if "%%F"=="PBPX_950.11" set REGIONTMP=U
	 
	 if not defined REGIONTMP (
	 echo %%F| "%~dp0BAT\busybox" cut -c3-3 > "%~dp0TMP\RegionID.txt" & set /P regionID=<"%~dp0TMP\RegionID.txt"
	 REM A = Asie
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
	 if not defined REGIONTMP set REGIONTMP=X
	 
	REM if %language%==french ("%~dp0BAT\busybox" sed -i "s/January/Janvier/g; s/February/F?ier/g; s/March/Mars/g; s/April/Avril/g; s/May/Mai/g; s/June/Juin/g; s/July/Juillet/g; s/August/Aout/g; s/September/Septembre/g; s/October/Octobre/g; s/November/Novembre/g; s/December/D?mbre/g;" "%~dp0TMP\RELEASE.txt" & set /P RELEASETMP=<"%~dp0TMP\RELEASE.txt")
	
	 set "dbtitleTMP="
 	 for /f "tokens=1*" %%A in ( 'findstr %%F "%~dp0TMP\gameid.txt"' ) do (if not defined dbtitleTMP set dbtitleTMP=%%B
	 )
	 
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

    "%~dp0BAT\busybox" sed -i -e "s/title =.*/title =/g; s/title =/title = !dbtitle!/g" "%~dp0POPS\Temp\!appfolder!\res\info.sys"
 	"%~dp0BAT\busybox" sed -i -e "s/title_id = .*/title_id =/g; s/title_id =/title_id = !gameid2!/g" "%~dp0POPS\Temp\!appfolder!\res\info.sys"
	"%~dp0BAT\busybox" sed -i -e "s/release_date =.*/release_date =/g; s/release_date =/release_date = !RELEASE!/g" "%~dp0POPS\Temp\!appfolder!\res\info.sys"
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

     echo            Download covers...
     if !DownloadART!==yes "%~dp0BAT\wget" -q --show-progress "https://archive.org/download/OPLM_ART_2022_05/OPLM_ART_2022_05.zip/PS1%%2F%%F%%2F%%F_COV.jpg" -O "%~dp0TMP\jkt_001.jpg" >nul 2>&1
     if !uselocalART!==yes if exist "%~dp0ART.zip" "%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0ART.zip" -o"%~dp0TMP" PS1\%%F\%%F_COV.jpg -r -y & move "%~dp0TMP\PS1\%%F\%%F_COV.jpg" "%~dp0TMP\jkt_001.jpg" >nul 2>&1
	 if !DownloadART!==yes "%~dp0BAT\wget" -q --show-progress "https://archive.org/download/OPLM_ART_2022_05/OPLM_ART_2022_05.zip/PS1%%2F%%F%%2F%%F_BG_00.jpg" -O "%~dp0TMP\BG.jpg" >nul 2>&1
	 if !uselocalART!==yes if exist "%~dp0ART.zip" "%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0ART.zip" -o"%~dp0TMP" PS1\%%F\%%F_BG_00.jpg -r -y & move "%~dp0TMP\PS1\%%F\%%F_BG_00.jpg" "%~dp0TMP\BG.jpg" >nul 2>&1
	 if !DownloadART!==yes "%~dp0BAT\wget" -q --show-progress "https://archive.org/download/OPLM_ART_2022_05/OPLM_ART_2022_05.zip/PS1%%2F%%F%%2F%%F_LGO.png" -O "%~dp0TMP\jkt_cp.png" >nul 2>&1
	 if !uselocalART!==yes if exist "%~dp0ART.zip" "%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0ART.zip" -o"%~dp0TMP" PS1\%%F\%%F_LGO.png -r -y & move "%~dp0TMP\PS1\%%F\%%F_LGO.png" "%~dp0TMP\jkt_cp.png" >nul 2>&1
	 if !DownloadART!==yes "%~dp0BAT\wget" -q --show-progress "https://archive.org/download/OPLM_ART_2022_05/OPLM_ART_2022_05.zip/PS1%%2F%%F%%2F%%F_SCR_00.jpg" -O "%~dp0TMP\SCR0.jpg" >nul 2>&1
	 if !uselocalART!==yes if exist "%~dp0ART.zip" "%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0ART.zip" -o"%~dp0TMP" PS1\%%F\%%F_SCR_00.jpg -r -y & move "%~dp0TMP\PS1\%%F\%%F_SCR_00.jpg" "%~dp0TMP\SCR0.jpg" >nul 2>&1
	 if !DownloadART!==yes "%~dp0BAT\wget" -q --show-progress "https://archive.org/download/OPLM_ART_2022_05/OPLM_ART_2022_05.zip/PS1%%2F%%F%%2F%%F_SCR_01.jpg" -O "%~dp0TMP\SCR1.jpg" >nul 2>&1
	 if !uselocalART!==yes if exist "%~dp0ART.zip" "%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0ART.zip" -o"%~dp0TMP" PS1\%%F\%%F_SCR_01.jpg -r -y & move "%~dp0TMP\PS1\%%F\%%F_SCR_01.jpg" "%~dp0TMP\SCR1.jpg" >nul 2>&1
	 REM "%~dp0BAT\wget" -q --show-progress "https://archive.org/download/OPLM_ART_2022_05/OPLM_ART_2022_05.zip/PS1%%2F%%F%%2F%%F_SCR_02.jpg" -O "%~dp0TMP\SCR2.jpg" >nul 2>&1
	 REM "%~dp0BAT\wget" -q --show-progress "https://archive.org/download/OPLM_ART_2022_05/OPLM_ART_2022_05.zip/PS1%%2F%%F%%2F%%F_SCR_03.jpg" -O "%~dp0TMP\SCR3.jpg" >nul 2>&1
	 cd "%~dp0TMP" & for %%F in (*.jpg *.png) do if %%~zF==0 del "%%F"

	 REM Covers
	 if exist "%~dp0TMP\jkt_001.jpg" "%~dp0BAT\nconvert" -overwrite -out png -rtype lanczos -efocus -o "%~dp0TMP\res\jkt_001.png" "%~dp0TMP\jkt_001.jpg" >nul 2>&1
	 if exist "%~dp0TMP\jkt_001.jpg" "%~dp0BAT\nconvert" -overwrite -out png -rtype lanczos -efocus -o "%~dp0TMP\res\jkt_002.png" "%~dp0TMP\jkt_001.jpg" >nul 2>&1
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
     echo device %@hdl_path% > "%~dp0TMP\pfs-log.txt"
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
	 findstr %%F "%~dp0TMP\id.txt" >nul 2>&1
	 if errorlevel 1 (
     REM echo         No need patch
     ) else (
	 set cheats=yes
	 "%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0POPS-Binaries\Hugopocked_POPStarter_Fixes.zip" -o"%~dp0TMP" %%F\CHEATS.TXT -r -y & move "%~dp0TMP\%%F\CHEATS.TXT" "%~dp0POPS\Temp\!appfolder!" >nul 2>&1
	 "%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0POPS-Binaries\Hugopocked_POPStarter_Fixes.zip" -o"%~dp0TMP" %%F\TROJAN_0.BIN -r -y & move "%~dp0TMP\%%F\TROJAN_0.BIN" "%~dp0POPS\Temp\!appfolder!" >nul 2>&1
	 if defined Disc0 "%~dp0BAT\busybox" md5sum "!Disc0!" | "%~dp0BAT\busybox" grep -o "[0-9a-f]\{32\}" > "%~dp0TMP\MD5.txt" & set /p MD5=<"%~dp0TMP\MD5.txt"
	 if defined Disc1 "%~dp0BAT\busybox" md5sum "!Disc1!" | "%~dp0BAT\busybox" grep -o "[0-9a-f]\{32\}" > "%~dp0TMP\MD5.txt" & set /p MD5=<"%~dp0TMP\MD5.txt"
	 "%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0POPS-Binaries\Hugopocked_POPStarter_Fixes.zip" -o"%~dp0TMP" %%F\!MD5!\CHEATS.TXT -r -y & move "%~dp0TMP\%%F\!MD5!\CHEATS.TXT" "%~dp0POPS\Temp\!appfolder!" >nul 2>&1
	 "%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0POPS-Binaries\Hugopocked_POPStarter_Fixes.zip" -o"%~dp0TMP" %%F\!MD5!\TROJAN_0.BIN -r -y & move "%~dp0TMP\%%F\!MD5!\TROJAN_0.BIN" "%~dp0POPS\Temp\!appfolder!" >nul 2>&1
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
     if defined cheats echo put "CHEATS.TXT" >> "%~dp0TMP\pfs-log.txt"
	 if defined cheats echo put "TROJAN_0.BIN" >> "%~dp0TMP\pfs-log.txt"
	 
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

	 md PS1 >nul 2>&1
	 "%~dp0BAT\Diagbox" gd 03
	 if !DownloadARTHDDOSD!==yes "%~dp0BAT\wget" -q "https://archive.org/download/hdd-osd-icons-pack/HDD-OSD-Icons-Pack.zip/PS1%%2F%%F%%2Ficon.sys" -O "%~dp0POPS\Temp\!appfolder!\PS1\icon.sys" >nul
	 if !DownloadARTHDDOSD!==yes "%~dp0BAT\wget" -q "https://archive.org/download/hdd-osd-icons-pack/HDD-OSD-Icons-Pack.zip/PS1%%2F%%F%%2Flist.ico" -O "%~dp0POPS\Temp\!appfolder!\PS1\list.ico" >nul
	 if !DownloadARTHDDOSD!==yes "%~dp0BAT\wget" -q "https://archive.org/download/hdd-osd-icons-pack/HDD-OSD-Icons-Pack.zip/PS1%%2F%%F%%2Fdel.ico" -O "%~dp0POPS\Temp\!appfolder!\PS1\del.ico" >nul
REM  "%~dp0BAT\wget" -q "https://archive.org/download/hdd-osd-icons-pack/HDD-OSD-Icons-Pack.zip/PS1%%2F%%F%%2FPreview.png" -O "%~dp0POPS\Temp\!appfolder!\PS1\Preview.png" >nul

	 if !uselocalARTHDDOSD!==yes if exist "%~dp0HDD-OSD-Icons-Pack.zip" "%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0HDD-OSD-Icons-Pack.zip" -o"%~dp0POPS\Temp\!appfolder!" PS1\%%F\ -r -y & move "%~dp0POPS\Temp\!appfolder!\PS1\%%F\*" "%~dp0POPS\Temp\!appfolder!\" >nul 2>&1
	 "%~dp0BAT\Diagbox" gd 0f
     cd /d "%~dp0POPS\Temp\!appfolder!\PS1" & for %%x in (*) do if %%~zx==0 del %%x
	 move "%~dp0POPS\Temp\!appfolder!\PS1\*" "%~dp0POPS\Temp\!appfolder!" >nul 2>&1

     "%~dp0BAT\busybox" sed -i -e "s/title0=.*/title0=/g; s/title0=/title0=!dbtitle!/g" "%~dp0POPS\Temp\!appfolder!\icon.sys"
 	 "%~dp0BAT\busybox" sed -i -e "s/title1=.*/title1=/g; s/title1=/title1=!gameid2!/g" "%~dp0POPS\Temp\!appfolder!\icon.sys"
	  
	 cd /d "%~dp0POPS\Temp\!appfolder!" & hdl_dump modify_header %@hdl_path2% "!PPName!" >nul 2>&1
	 echo            Completed...
	 echo ----------------------------------------------------
	 move "%~dp0POPS\Temp\!appfolder!\EXECUTE.KELF" "%~dp0TMP\POPSTARTER.KELF" >nul 2>&1
	 move "%~dp0POPS\Temp\!appfolder!\hdl_dump.exe" "%~dp0TMP" >nul 2>&1
     move "%~dp0POPS\Temp\!appfolder!\*.VCD" "%~dp0POPS" >nul 2>&1
     rmdir /Q/S "%~dp0POPS\Temp\!appfolder!" >nul 2>&1
     )
	)
  endlocal
 endlocal
endlocal
 )
) else ( echo        .VCD NOT DETECTED! )
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
:InstallNBDDriver

cls
cd /d %~dp0
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

mkdir "%~dp0TMP" >nul 2>&1
copy "%~dp0BAT\TitlesDB\gameidPS1.txt" "%~dp0TMP\gameid.txt" >nul 2>&1
"%~dp0BAT\busybox" sed -i "s/\^!/\!/g" "%~dp0TMP\gameid.txt" >nul 2>&1

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

For %%P in ( "*.VCD" ) do ( "%~dp0BAT\POPS-VCD-ID-Extractor" "%%P" > VCDID.txt & "%~dp0BAT\busybox" sed -i -e "s/-/_/g" VCDID.txt
set "filename=%%P"

for /f %%i in (VCDID.txt) do (
set gameid=%%i

set "dbtitle="
for /f "tokens=1*" %%A in ( 'findstr %%i "%~dp0TMP\gameid.txt" ' ) do ( if not defined dbtitle set dbtitle=%%B
				
  )
 )

setlocal EnableDelayedExpansion
del "%~dp0POPS\VCDID.txt" >nul 2>&1

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
   )
  )
 )
endlocal
   )
  ) else ( 
"%~dp0BAT\Diagbox" gd 06
cls
echo.
echo .BIN/CUE NOT DETECTED: Please drop .BIN/CUE IN POPS FOLDER.
echo.
"%~dp0BAT\Diagbox" gd 0f
pause & (goto GamesManagement)
)

move "%~dp0POPS\temp\*.VCD" "%~dp0POPS" >nul 2>&1

rmdir /s /q temp >nul 2>&1
echo\

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

echo Apply HugoPocked's ^& El_Patas patches If available?
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
   
   "%~dp0BAT\BIN-ID" "!filename!.bin" | "%~dp0BAT\busybox" sed -e "s/-/_/g" > "%~dp0POPS\Temp\!appfolder!\BINID.txt" & set /p BINID=<"%~dp0POPS\Temp\!appfolder!\BINID.txt"
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
  )
   endlocal
endlocal
)

move "%~dp0POPS\*.bin" "%~dp0POPS\Temp" >nul 2>&1

setlocal DisableDelayedExpansion
echo\
echo -----------------------------------------------------
echo\
echo Convert to VCD... 
for %%f in ( "%~dp0POPS\Temp\*.cue" ) do ( "%~dp0BAT\CUE2POPS_2_3" "%%f" | echo "%%~nf.VCD"
move "%~dp0POPS\Temp\%%~nf.VCD" "%~dp0POPS" >nul 2>&1
)

) else (
"%~dp0BAT\Diagbox" gd 06
echo.
echo .BIN/CUE NOT DETECTED: Please drop .BIN/CUE IN POPS FOLDER.
echo.
"%~dp0BAT\Diagbox" gd 0f
pause & (goto ConversionMenu)
)

endlocal
endlocal
cd /d "%~dp0" & rmdir /s /q "%~dp0POPS\Temp" >nul 2>&1

echo -----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0e
echo\
echo Do you want rename your .VCDs from database?
"%~dp0BAT\Diagbox" gd 0f
choice /c YN /m "Use titles from database?"
echo\
if %errorlevel%==1 set usedbtitleconv=yes & goto RenameVCDDB

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
mkdir "%~dp0POPS\Original" >nul 2>&1

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

move *.bin "%~dp0CD\Original" >nul 2>&1
move *.cue "%~dp0CD\Original" >nul 2>&1
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
if %errorlevel%==1 set "compress=yes" & set "type=.iso" & set type2=.zso
if %errorlevel%==2 set "decompress=yes" & set "type=.zso" & set type2=.iso
if %errorlevel%==3 (goto ConversionMenu)

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
if defined compress "%~dp0BAT\maxcso" --block=2048 --format=zso "!filename!" -o "!fname!!type2!"
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

if exist "%HOMEDRIVE%\Windows\System32\drivers\dokan2.sys" (
if exist "C:\Program Files\Dokan" "%~dp0BAT\busybox" ls "C:\Program Files\Dokan" > "%~dp0TMP\DokanFolder.txt" & set /P DokanFolder=<"%~dp0TMP\DokanFolder.txt"

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
if !mount!==HDD (
"%~dp0BAT\Diagbox" gd 0e
echo Scanning for Playstation 2 HDDs:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "Playstation 2 HDD"
"%~dp0BAT\hdl_dump" query | "%~dp0BAT\busybox" grep "Playstation 2 HDD" | "%~dp0BAT\busybox" grep -o "hdd[0-9]:\|hdd[0-9][0-9]:" > "%~dp0TMP\hdl-hdd.txt" & "%~dp0BAT\busybox" cat "%~dp0TMP\hdl-hdd.txt" > "%~dp0TMP\hdl-hdd2.txt"
"%~dp0BAT\busybox" sed -i "s/hdd/\\\\.\\\PhysicalDrive/g; s/://g" "%~dp0TMP\hdl-hdd2.txt"

set /P @hdl_path2=<"%~dp0TMP\hdl-hdd2.txt"
set /P @hdl_path=<"%~dp0TMP\hdl-hdd.txt"
::del "%~dp0TMP\hdl-hdd.txt" >nul 2>&1
IF "!@hdl_path!"=="" (
"%~dp0BAT\Diagbox" gd 0c
		echo         Playstation 2 HDD Not Detected
		echo         Drive Must Be Formatted First
		echo\
		echo\
"%~dp0BAT\Diagbox" gd 07
		rmdir /Q/S "%~dp0TMP" >nul 2>&1
		pause & (goto PS2HDDExplore)
	)

   "%~dp0BAT\Diagbox" gd 0f
   echo\
   echo\
   echo Scanning Partitions:
   echo ----------------------------------------------------
   "%~dp0BAT\hdl_dump" toc !@hdl_path! | "%~dp0BAT\busybox" grep -e "0x0100" -e "0x0001" > "%~dp0TMP\hdd-prt.txt"
   type "%~dp0TMP\hdd-prt.txt"
   echo ----------------------------------------------------
   echo\
   echo\
   echo Enter the partition name do you want mount
   set /p PartName=Partition name:
   echo\
   echo\
   
   wmic logicaldisk get caption | "%~dp0BAT\busybox" grep -o "[A-Z]:" | "%~dp0BAT\busybox" grep -o "[A-Z]" > "%~dp0TMP\LTR.txt"
   "C:\Program Files\Dokan\!DokanFolder!\dokanctl.exe" /l a >nul 2>&1 | "%~dp0BAT\busybox" grep -o "DosDevices\\[A-Z]:" | "%~dp0BAT\busybox" cut -c12-12 >> "%~dp0TMP\LTR.txt"
   
   echo ABCDEFGHIJKLMNOPQRSTUVWXYZ> "%~dp0TMP\LTRFree.txt"
   for /f "tokens=*" %%a in (LTR.txt) do "%~dp0BAT\busybox" sed -i "s/%%a//g" "%~dp0TMP\LTRFree.txt"
   "%~dp0BAT\busybox" cut -c0-1 "%~dp0TMP\LTRFree.txt" > "%~dp0TMP\LTRSelected.txt" & set /P DeviceLTR=<"%~dp0TMP\LTRSelected.txt"

   echo "%~dp0BAT\pfsfuse" "--partition=!PartName!" !@hdl_path2! !DeviceLTR! -o "volname=!PartName!" > "%~dp0TMP\PFSMount.bat"
   START /MIN CMD.EXE /C "%~dp0TMP\PFSMount.bat"
   start explorer.exe

   "%~dp0BAT\Diagbox" gd 0e
   echo Umount Partition?
   choice /c YN
   if !errorlevel!==1 set "UmountPartition=yes" & cd "%~dp0" & rmdir /Q/S "%~dp0TMP" >nul 2>&1
   
   if !UmountPartition!==yes (
   "C:\Program Files\Dokan\!DokanFolder!\dokanctl.exe" /u !DeviceLTR!
   ) else (
   "%~dp0BAT\Diagbox" gd 06
   echo\
   echo IMPORTANT: Don't forget to umount partition before disconnecting your HDD
   echo\
   "%~dp0BAT\Diagbox" gd 0f
   pause & goto PS2HDDExplore
    )
   )
   
   if !mount!==IMG (
   echo\
   echo\
   echo Enter the path where your image.img is located
   echo Example c:\PS2\Myimage.img
   set /p FullPath=Enter the FullPath:
   echo\
   echo\
   echo Enter the partition name do you want mount
   set /p PartName=Partition name:
   
   wmic logicaldisk get caption | "%~dp0BAT\busybox" grep -o "[A-Z]:" | "%~dp0BAT\busybox" grep -o "[A-Z]" > "%~dp0TMP\LTR.txt"
   "C:\Program Files\Dokan\!DokanFolder!\dokanctl.exe" /l a >nul 2>&1 | "%~dp0BAT\busybox" grep -o "DosDevices\\[A-Z]:" | "%~dp0BAT\busybox" cut -c12-12 >> "%~dp0TMP\LTR.txt"
   
   echo ABCDEFGHIJKLMNOPQRSTUVWXYZ> "%~dp0TMP\LTRFree.txt"
   for /f "tokens=*" %%a in (LTR.txt) do "%~dp0BAT\busybox" sed -i "s/%%a//g" "%~dp0TMP\LTRFree.txt"
   "%~dp0BAT\busybox" cut -c0-1 "%~dp0TMP\LTRFree.txt" > "%~dp0TMP\LTRSelected.txt" & set /P DeviceLTR=<"%~dp0TMP\LTRSelected.txt"
   
   echo "%~dp0BAT\pfsfuse.exe" "--partition=!PartName!" "!FullPath!" !DeviceLTR! -o "volname=!PartName!" > "%~dp0TMP\PFSMount.bat"
   START /MIN CMD.EXE /C "%~dp0TMP\PFSMount.bat"
   start explorer.exe
   
   "%~dp0BAT\Diagbox" gd 0e
   echo Umount Partition?
   choice /c YN
   if !errorlevel!==1 set "UmountPartition=yes" & cd "%~dp0" & rmdir /Q/S "%~dp0TMP" >nul 2>&1
   
   if !UmountPartition!==yes (
   "C:\Program Files\Dokan\!DokanFolder!\dokanctl.exe" /u !DeviceLTR!
   ) else (
   "%~dp0BAT\Diagbox" gd 06
   echo\
   echo IMPORTANT: Don't forget to umount partition before disconnecting your IMAGE
   echo\
   "%~dp0BAT\Diagbox" gd 0f
   cd "%~dp0" & rmdir /Q/S "%~dp0TMP" >nul 2>&1 & pause & goto PS2HDDExplore
    )
   )
  )

if defined UmountManuallyPartition (
   if exist "C:\Program Files\Dokan\" ( 
   "C:\Program Files\Dokan\!DokanFolder!\dokanctl.exe" /l a | "%~dp0BAT\busybox" grep -o "DosDevices\\[A-Z]:" | "%~dp0BAT\busybox" cut -c12-12 > "%~dp0TMP\Listmount.txt"
   for /f "tokens=*" %%m in (Listmount.txt) do ("C:\Program Files\Dokan\!DokanFolder!\dokanctl.exe" /u %%m)
    )
   )
   
   if defined CheckDokanVersion ( cls & if exist "C:\Program Files\Dokan\" "C:\Program Files\Dokan\!DokanFolder!\dokanctl.exe" /v)
   if defined InstallDriver (if exist "%HOMEDRIVE%\Windows\System32\drivers\dokan2.sys" "%~dp0BAT\Diagbox" gd 06 & echo Driver already installed if you want to update it. Uninstall the driver first & "%~dp0BAT\Diagbox" gd 0f)
   
   if not exist "%HOMEDRIVE%\Windows\System32\drivers\dokan2.sys" (
   "%~dp0BAT\Diagbox" gd 06
   if not defined InstallDriver echo Dokan Driver not detected
   "%~dp0BAT\Diagbox" gd 0f
   echo\
   echo Do you want Install Dokan Driver ?
   "%~dp0BAT\Diagbox" gd 0f
   CHOICE /C YN /M "Select Option:"
   if errorlevel 1 set InstallDokanDriver=yes
   if errorlevel 2 cd "%~dp0" & rmdir /Q/S "%~dp0TMP" >nul 2>&1 & (goto PS2HDDExplore)

   if defined InstallDokanDriver (
   "%~dp0BAT\wget" "https://github.com/dokan-dev/dokany/releases.html" >nul 2>&1
   for %%F in ( "releases.html" ) do if %%~zF==0 del "%%F"
   
   if exist releases.html (
   "%~dp0BAT\busybox" grep -m 1 "releases/tag/v" "%~dp0TMP\releases.html" | "%~dp0BAT\busybox" sed "s/ //g" | "%~dp0BAT\busybox" cut -c90-105 | "%~dp0BAT\busybox" sed "s/\"".*//" > "%~dp0TMP\DownloadLatest.txt" & set /p LatestVersion=<"%~dp0TMP\DownloadLatest.txt"
   "%~dp0BAT\wget" "https://github.com/dokan-dev/dokany/releases/download/!LatestVersion!/Dokan_x64.msi" 2>&1 -O "%~dp0BAT\Dokan_x64.msi" >nul 2>&1
   ) else (
   "%~dp0BAT\Diagbox" gd 0c
   echo\
   echo\
   echo Unable to connect to internet Or Website
   echo You will switch to offline mode
   echo\
   "%~dp0BAT\Diagbox" gd 0f
   pause & cls
   )

   echo Installation...
   msiexec.exe /i "%~dp0BAT\Dokan_x64.msi" /QN /L*V "%~dp0LOG\DokanDriverlog.log"
   
   if exist "%HOMEDRIVE%\Windows\System32\drivers\dokan2.sys" (
   "%~dp0BAT\Diagbox" gd 0a
   echo Installation Successfully
   "%~dp0BAT\Diagbox" gd 0f
   ) else (
   "%~dp0BAT\Diagbox" gd 0c
   echo An error has occurred Please check logs.
   "%~dp0BAT\Diagbox" gd 0f
     )
    )
   )

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
PAUSE
cls
(goto mainmenu)

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
pause
cls
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