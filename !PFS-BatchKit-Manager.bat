@echo off

:-------------------------------------
REM  --> Check for permissions
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

REM --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
    echo %ADMIN_PRIV%
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
:--------------------------------------Z
cls
chcp 1252

call "%~dp0BAT\LANG2.BAT"
call "%~dp0BAT\CFG2.BAT"

rmdir /Q/S "%~dp0TMP" >nul 2>&1
del info.sys >nul 2>&1

attrib +h "BAT"

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

IF NOT EXIST "%~dp0POPS-Binaries\"    MD "%~dp0POPS-Binaries\"
IF NOT EXIST "%~dp0HDD-OSD\__sysconf" MD "%~dp0HDD-OSD\__sysconf"
IF NOT EXIST "%~dp0HDD-OSD\__system"  MD "%~dp0"HDD-OSD\__system"
cls

:start
"%~dp0BAT\Diagbox" gd 0f
cls
title PFS BatchKit Manager v1.0.0 By GDX 
echo.Welcome in PFS BatchKit Manager v1.0.0 By GDX 
endlocal
endlocal
setlocal EnableDelayedExpansion
setlocal EnableExtensions
echo.------------------------------------------
echo.
ECHO 1. Transfer PS1 Games
ECHO 2. Transfer PS2 Games
ECHO 3. Transfer APPS,ART,CFG,CHT,VMC,THM
ECHO 4. Transfer POPS Binaries
ECHO.
ECHO.
ECHO.7. Backup PS1 Games
ECHO 8. Backup PS2 Games
ECHO 9. Backup ART,CFG,CHT,VMC
ECHO.
ECHO 10. Advanced Menu
ECHO.
ECHO 11. Exit
ECHO.
ECHO.
ECHO 12. About 
echo.------------------------------------------
set /p choice=Select Option:

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

(goto start)

:About
"%~dp0BAT\Diagbox" gd 0f
cls
title PFS BatchKit Manager v1.0.0 By GDX 
echo.Welcome in PFS BatchKit Manager v1.0.0 By GDX 
endlocal
endlocal
echo.------------------------------------------
ECHO ABOUT ME
echo.
ECHO I was inspired by the scripts of NeMesiS, Dekkit and Rs1n to make this script
ECHO.
ECHO This batch script is intended to help people prepare their hard drive for the PS2!
ECHO. 
ECHO Many thanks to the PS2 community for their contribution to the program used to make this scripts!
ECHO. 
ECHO GDX
ECHO.
echo.------------------------------------------
ECHO 1. My Twitter
ECHO 2. My Discord : GDX#5466
ECHO 3. My Youtube Channel
ECHO 4.
ECHO 5.
ECHO 6.
ECHO 7.
ECHO 8. Officiel PS2 Forum
ECHO 9. Officiel PS2 Discord
ECHO.
ECHO 10. Back to main menu
ECHO 11. Exit
echo.------------------------------------------
set /p choice=Select Option:

if "%choice%"=="1" (start https://twitter.com/GDX_SM)
if "%choice%"=="3" (start https://www.youtube.com/user/GDXTV/videos)
if "%choice%"=="8" (start https://www.psx-place.com/forums/#playstation-2-forums.6)
if "%choice%"=="9" (start https://discord.gg/PWGvKXjRgy)

if "%choice%"=="10" (goto start)
if "%choice%"=="11" exit

if "%choice%"=="99" (goto poop)
if "%choice%"=="100" (goto GDX-X)

(goto About)

:AdvancedMenu
"%~dp0BAT\Diagbox" gd 0f
cls
title PFS BatchKit Manager v1.0.0 By GDX 
echo.Welcome in PFS BatchKit Manager v1.0.0 By GDX 
endlocal
endlocal
setlocal EnableDelayedExpansion
setlocal EnableExtensions
echo.------------------------------------------
ECHO Advanced Menu 
ECHO.
ECHO 1. Conversion Menu
ECHO 2. Dump your PS2 CD-DVD
ECHO 3. Downloads Menu
ECHO 4.
ECHO 5. PC Utility
ECHO 6.
ECHO 7. HDD-OSD/BB Navigator/XMB
ECHO 8. PS2 Online
ECHO 9. HDD Management
ECHO.
ECHO 10. Back to main menu
ECHO 11. Exit
ECHO.
echo.------------------------------------------
set /p choice=Select Option:

if "%choice%"=="1" (goto ConversionMenu)
if "%choice%"=="2" (goto DumpCDDVD)
if "%choice%"=="3" (goto DownloadsMenu)

if "%choice%"=="5" (goto UtilityMenu)

if "%choice%"=="7" (goto HDDOSDMenu)
if "%choice%"=="8" (goto PS2OnlineMenu)
if "%choice%"=="9" (goto HDDManagementMenu)
if "%choice%"=="10" (goto start)
if "%choice%"=="11" exit

(goto AdvancedMenu)

:ConversionMenu
"%~dp0BAT\Diagbox" gd 0f
cls
title PFS BatchKit Manager v1.0.0 By GDX 
echo.Welcome in PFS BatchKit Manager v1.0.0 By GDX 
endlocal
endlocal
setlocal EnableDelayedExpansion
setlocal EnableExtensions
echo.------------------------------------------
ECHO Conversion Menu
ECHO.
ECHO 1. Convert .BIN to .VCD (Multi-Tracks .BIN Compatible)
ECHO 2. Convert .VCD to .BIN
ECHO 3. Convert .BIN to .CHD (Multi-Tracks .BIN Compatible)
ECHO 4. Convert .CHD to .BIN
ECHO 5. Convert .ECM to .BIN
ECHO.
ECHO 7. Convert .BIN to .ISO (Usefull for PCSX2)
ECHO 8. Convert Multi-Tracks .BIN to Single .BIN
ECHO 9. Restore Single .BIN to Multi-Tracks .BIN (If compatible, it will rebuild the original .bin with the Multi-Track)
ECHO.
ECHO 10. Back
ECHO 11. Back to main menu
ECHO 12. Exit
ECHO.
ECHO.
echo.------------------------------------------
set /p choice=Select Option:

if "%choice%"=="1" (goto BIN2VCD)
if "%choice%"=="2" (goto VCD2BIN)
if "%choice%"=="3" (goto BIN2CHD)
if "%choice%"=="4" (goto CHD2BIN)
if "%choice%"=="5" (goto ECM2BIN)

if "%choice%"=="7" (goto BIN2ISO)
if "%choice%"=="8" (goto multibin2bin)
if "%choice%"=="9" (goto bin2split)
if "%choice%"=="10" (goto AdvancedMenu)
if "%choice%"=="11" (goto start)
if "%choice%"=="12" exit

(goto ConversionMenu)

:DownloadsMenu
"%~dp0BAT\Diagbox" gd 0f
cls
title PFS BatchKit Manager v1.0.0 By GDX 
echo.Welcome in PFS BatchKit Manager v1.0.0 By GDX 
endlocal
endlocal
setlocal EnableDelayedExpansion
setlocal EnableExtensions
echo.------------------------------------------
ECHO Downloads Menu 
ECHO.
REM ECHO 1. Download APPS
ECHO 1.
ECHO 2. Download Artworks
REM ECHO 3. Download Config
REM ECHO 4. Download Cheat
ECHO 5.
ECHO 6.
ECHO 7.
ECHO 8.
ECHO 9.
ECHO.
ECHO 10. Back
ECHO 11. Back to main menu
ECHO 12. Exit
ECHO.
echo.------------------------------------------
set /p choice=Select Option:

if "%choice%"=="2" (goto DownloadARTMenu)

REM if "%choice%"=="4" (goto DownloadCheatsMenu)

if "%choice%"=="10" (goto AdvancedMenu)
if "%choice%"=="11" (goto start)
if "%choice%"=="12" exit

(goto DownloadsMenu)

:DownloadARTMenu
"%~dp0BAT\Diagbox" gd 0f
cls
title PFS BatchKit Manager v1.0.0 By GDX 
echo.Welcome in PFS BatchKit Manager v1.0.0 By GDX 
endlocal
endlocal
setlocal EnableDelayedExpansion
setlocal EnableExtensions
echo.------------------------------------------
ECHO Download ART Menu 
ECHO.
REM ECHO 1. Download COV
REM ECHO 2. Download COV2
REM ECHO 3. Download ICO
REM ECHO 4. Download LAB
REM ECHO 5. Download LGO
REM ECHO 6. Download BG
REM ECHO 7. Download SCR
REM ECHO 8. Download SCR2
ECHO 1.
ECHO 2.
ECHO 3.
ECHO 4.
ECHO 5.
ECHO 6.
ECHO 7.
ECHO 8.
ECHO.
ECHO 9 Download All ART
ECHO.
ECHO 10. Back
ECHO 11. Back to main menu
ECHO 12. Exit
ECHO.
echo.------------------------------------------
set /p choice=Select Option:

if "%choice%"=="9" (goto DownloadART)

if "%choice%"=="10" (goto AdvancedMenu)
if "%choice%"=="11" (goto start)
if "%choice%"=="12" exit

(goto DownloadARTMenu)

:DownloadCheatsMenu
"%~dp0BAT\Diagbox" gd 0f
cls
title PFS BatchKit Manager v1.0.0 By GDX 
echo.Welcome in PFS BatchKit Manager v1.0.0 By GDX 
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
ECHO 5. Grand Theft Auto Uncensored blood (European version)
ECHO 6.
ECHO 7.
ECHO 8.
ECHO 9. Widescreen Cheats FIX (4/3 to 16/9)

ECHO.
ECHO 10. Back
ECHO 11. Back to main menu
ECHO 12. Exit
ECHO.
echo.------------------------------------------
set /p choice=Select Option:

if "%choice%"=="9" (goto DownloadART)

if "%choice%"=="10" (goto AdvancedMenu)
if "%choice%"=="11" (goto start)
if "%choice%"=="12" exit

(goto DownloadCheatsMenu)


:UtilityMenu
"%~dp0BAT\Diagbox" gd 0f
cls
title PFS BatchKit Manager v1.0.0 By GDX 
echo.Welcome in PFS BatchKit Manager v1.0.0 By GDX 
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
ECHO 5. HDL Batch Installer
ECHO 6.
ECHO 7.
ECHO 8.
ECHO 9.
ECHO.
ECHO 10. Back
ECHO 11. Back to main menu
ECHO 12. Exit
ECHO.
echo.------------------------------------------
set /p choice=Select Option:

if "%choice%"=="1" (start https://github.com/ShendoXT/memcardrex/releases)
if "%choice%"=="2" (start https://www.psx-place.com/resources/mymc-dual-by-joack.675) 
if "%choice%"=="3" (start https://oplmanager.com/site)
if "%choice%"=="5" (start https://github.com/israpps/HDL-Batch-installer/releases)


if "%choice%"=="10" (goto AdvancedMenu)
if "%choice%"=="11" (goto start)
if "%choice%"=="12" exit

(goto UtilityMenu)

:HDDOSDMenu
"%~dp0BAT\Diagbox" gd 0f
cls
title PFS BatchKit Manager v1.0.0 By GDX 
echo.Welcome in PFS BatchKit Manager v1.0.0 By GDX 
endlocal
endlocal
setlocal EnableDelayedExpansion
setlocal EnableExtensions
echo.------------------------------------------
ECHO HDD-OSD/BB Navigator/XMB
ECHO.
ECHO 1. Install HDD-OSD
ECHO 2. Uninstall HDD-OSD
ECHO 3. Inject MiniOPL (Launch game in HDD-OSD)
ECHO 4. Hide Game (Hide games in HDD-OSD)
ECHO 5. Unhide Game (Unhide games in HDD-OSD)
ECHO 7.
ECHO 8.
ECHO 9.
ECHO.
ECHO 10. Back
ECHO 11. Back to main menu
ECHO 12. Exit
ECHO.
echo.------------------------------------------
set /p choice=Select Option:

if "%choice%"=="1" (goto InstallHDDOSD)
if "%choice%"=="2" (goto UnInstallHDDOSD)
if "%choice%"=="3" (goto injectbootkelf)
if "%choice%"=="4" (goto pphide)
if "%choice%"=="5" (goto ppunhide)


if "%choice%"=="10" (goto AdvancedMenu)
if "%choice%"=="11" (goto start)
if "%choice%"=="12" exit

(goto HDDOSDMenu)

:PS2OnlineMenu
"%~dp0BAT\Diagbox" gd 0f
cls
title PFS BatchKit Manager v1.0.0 By GDX 
echo.Welcome in PFS BatchKit Manager v1.0.0 By GDX 
endlocal
endlocal
setlocal EnableDelayedExpansion
setlocal EnableExtensions
echo.------------------------------------------
ECHO Online Menu
ECHO.
REM ECHO 1. Patch DNAS MODE 1 = sceDNAS2GetStatus injection fake deinit, error 0, status 5
REM ECHO 2. Patch DNAS MODE 2 = sceDNAS2GetStatus injection status 5
REM ECHO 3. Patch DNAS MODE 3 = SetStatus patch status 5 semi-forcing
REM ECHO 4. Patch DNAS MODE 4 = SetStatus patch status 5 instead of 6 (DNASrep required)
REM ECHO 5. DNAS MODE 5 = scan-only, no patching, output codes when possible
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
set /p choice=Select Option:

if "%choice%"=="9" (start https://docs.google.com/spreadsheets/d/1bbxOGm4dPxZ4Vbzyu3XxBnZmuPx3Ue-cPqBeTxtnvkQ)
if "%choice%"=="10" (goto AdvancedMenu)
if "%choice%"=="11" (goto start)
if "%choice%"=="12" exit

(goto PS2OnlineMenu)

:HDDManagementMenu
"%~dp0BAT\Diagbox" gd 0f
cls
title PFS BatchKit Manager v1.0.0 By GDX 
echo.Welcome in PFS BatchKit Manager v1.0.0 By GDX 
endlocal
endlocal
setlocal EnableDelayedExpansion
setlocal EnableExtensions
echo.------------------------------------------
ECHO HDD Management 
ECHO.
ECHO 1. Create Partition
ECHO 2. Delete Partition
ECHO 3. Blank  Partition (Format only partition) 
ECHO 4. Show System Partition Table
ECHO 5. Show Games Partition Table
ECHO 6. Scan Partition Errors
ECHO 7.
"%~dp0BAT\Diagbox" gd 06
ECHO 8. Hack your HDD To PS2 Format (Temporarily BOOT From wLaunchELF)
"%~dp0BAT\Diagbox" gd 0c
ECHO 9. Format HDD To PS2 Format
"%~dp0BAT\Diagbox" gd 0f
ECHO.
ECHO 10. Back
ECHO 11. Back to main menu
ECHO 12. Exit
ECHO.
echo.------------------------------------------
set /p choice=Select Option:

if "%choice%"=="1"  (goto CreatePART)
if "%choice%"=="2"  (goto DeletePART)
if "%choice%"=="3"  (goto BlankPART)
if "%choice%"=="4"  (goto partitionlist) 
if "%choice%"=="5"  (goto partitionGAMElist)
if "%choice%"=="6"  (goto DIAGPARTERROR)

if "%choice%"=="8"  (goto hackHDDtoPS2)
if "%choice%"=="9"  (goto formatHDDtoPS2)
if "%choice%"=="10" (goto AdvancedMenu)
if "%choice%"=="11" (goto start)
if "%choice%"=="12" exit

(goto HDDManagementMenu)

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
cd /d "%~dp0CD-DVD"

del gameid.txt
copy "%~dp0BAT\boot.kelf" "%~dp0CD-DVD" >nul 2>&1
copy "%~dp0BAT\hdl_svr_093.elf" "%~dp0CD-DVD" >nul 2>&1
copy "%~dp0BAT\DB\gameidENG.txt" "%~dp0CD-DVD" >nul 2>&1
copy "%~dp0BAT\hdl_dump.exe" "%~dp0CD-DVD" >nul 2>&1
REM copy "%~dp0BAT\hdl_dump_093.exe" "%~dp0CD-DVD\hdl_dump.exe"
ren gameidENG.txt gameid.txt
cls

if "%TEST%"=="NO" (
	REM echo WARNING: Make sure to run this program using "Run as Administrator"
"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning for Playstation 2 HDDs:
echo ----------------------------------------------------
    "%~dp0BAT\Diagbox" gd 03
	"%~dp0BAT\hdl_dump" query | findstr "Playstation"
	"%~dp0BAT\Diagbox" gd 07
    echo.
    echo ----------------------------------------------------
	"%~dp0BAT\Diagbox" gd 06
	echo NOTE: If no PS2 HDDs are found, quit and retry after disconnecting
	echo all disk drives EXCEPT for your PC boot drive and the PS2 HDDs.
	"%~dp0BAT\Diagbox" gd 0f
	echo. 
	echo PLAYSTATION 2 HDD INSTALLATION
	echo 	1. hdd1:
	echo 	2. hdd2:
	echo 	3. hdd3:
	echo 	4. hdd4:
	echo 	5. hdd5:
	echo 	6. hdd6:
	echo 	7. Network
	echo 	8. Quit Program
	choice /c 12345678 /m "Select your PS2 HDD"

	if errorlevel 8 (goto start)
	if errorlevel 7 (
		set /p "hdlhdd=Enter IP of the Playstation 2: "
		ping -n 1 -w 2000 !hdlhdd!
		if errorlevel 1 (
		"%~dp0BAT\Diagbox" gd 0c
			echo Unable to ping !hdlhdd! ... ending script.
			"%~dp0BAT\Diagbox" gd 07
            pause & goto TransferPS2Games)
			
	) else (
		if errorlevel 1 set hdlhdd=hdd1:
		if errorlevel 2 set hdlhdd=hdd2:
		if errorlevel 3 set hdlhdd=hdd3:
		if errorlevel 4 set hdlhdd=hdd4:
		if errorlevel 5 set hdlhdd=hdd5:
		if errorlevel 6 set hdlhdd=hdd6:
	)
)

cls		
echo Choice language Game title
echo.
echo 1 English
echo 2 French
echo 3 Spanish
echo.
choice /c 123
if errorlevel 3 (goto spanish)
if errorlevel 2 (goto french)
if errorlevel 1 (goto english)
:english
del gameid.txt
copy "%~dp0BAT\DB\gameidENG.txt" "%~dp0CD-DVD" >nul 2>&1
cls
ren gameidENG.txt gameid.txt
echo English Language selected
(goto fin)
:french
del gameid.txt
copy "%~dp0BAT\DB\gameidFRA.txt" "%~dp0CD-DVD" >nul 2>&1
cls
ren gameidFRA.txt gameid.txt
echo French Language selected
(goto fin)
:spanish
del gameid.txt
copy "%~dp0BAT\DB\gameidSPA.txt" "%~dp0CD-DVD" >nul 2>&1
cls
ren gameidSPA.txt gameid.txt
echo Spanish Language selected
(goto fin)

:fin
cls
set usedb=no
if exist gameid.txt (
	echo.
	echo Game title database found.
	choice /c YN /m "Use titles from gameid.txt? "
	if errorlevel 2 ( set usedb=no) else ( set usedb=yes)
) else (
	"%~dp0BAT\Diagbox" gd 0e
	echo.
	echo NOTE: No game title database found. Using file names as titles.
	"%~dp0BAT\Diagbox" gd 07
	pause
)

cls

REM %~dp0BAT\7z.exe x -bso0 "%~dp0CD-DVD\*.zip"

REM CHECK IF .CUE IS MISSING FOR .BIN IF IT IS NOT DETECTED IT WILL BE CREATED
cd "%~dp0CD"
if not exist "%%~nf.cue" call "%~dp0BAT\cuemaker.bat"
move *.bin "%~dp0CD-DVD" >nul 2>&1
move *.cue "%~dp0CD-DVD" >nul 2>&1
move *.iso "%~dp0CD-DVD" >nul 2>&1

cd "%~dp0DVD"
move *.iso "%~dp0CD-DVD" >nul 2>&1
cd "%~dp0CD-DVD"

set /a gamecount=0
for %%f in (*.iso *.cue *.nrg *.gi *.iml) do (
	set /a gamecount+=1
    echo.
	echo.
	echo !gamecount! - %%f

	setlocal disabledelayedexpansion
	set filename=%%f
	for /f "tokens=1,2,3,4,5*" %%i in ('hdl_dump cdvd_info2 ".\%%f"') do (

		set fname=%%f

		setlocal enabledelayedexpansion
		set fnheader=%%f

		if "!fnheader!"==%%l (
			set title=%%f
		) else (
			if "!fnheader!"==%%m ( set title=%%f) else ( set title=%%f)
		)
		
		set disctype=unknown
		if "%%i"=="CD" ( set disctype=inject_cd && set gameid=%%l)
		if "%%i"=="DVD" ( set disctype=inject_dvd && set gameid=%%l)
		if "%%i"=="dual-layer" ( if "%%j"=="DVD" ( set disctype=inject_dvd && set gameid=%%m))
		if "!disctype!"=="unknown" (
		"%~dp0BAT\Diagbox" gd 0c
			echo	WARNING: Unable to determine disc type! File ignored.
			
		"%~dp0BAT\Diagbox" gd 07
		) else (
                
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
			echo 	Install type: !disctype!	ID: !gameid!
			echo 	Title: !title!
			"%~dp0BAT\Diagbox" gd 0d
			if "%TEST%"=="NO" hdl_dump !disctype! !hdlhdd! "!title!" "!filename!" *u4
			"%~dp0BAT\Diagbox" gd 07
		)
		endlocal
	)
	endlocal
)
endlocal
echo\

cd "%~dp0CD-DVD"
move *.bin "%~dp0CD" >nul 2>&1
move *.cue "%~dp0CD" >nul 2>&1
move *.iso "%~dp0DVD" >nul 2>&1
cd "%~dp0"
rmdir /Q/S "%~dp0CD-DVD" >nul 2>&1

pause & (goto start)

REM ########################################################################################################################################################################
:TransferAPPSARTCFGCHTTHMVMC

cd "%~dp0"
cls

mkdir "%~dp0TMP" >nul 2>&1
"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo %HDD_SCAN%
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | findstr "hdd" | "%~dp0BAT\busybox" grep "Playstation 2 HDD"
"%~dp0BAT\hdl_dump" query | findstr "hdd" | "%~dp0BAT\busybox" grep "Playstation 2 HDD" | "%~dp0BAT\busybox" cut -c2-6 > "%~dp0TMP\hdl-hdd.txt"
"%~dp0BAT\busybox" sed -i "s/hdd/\\\\.\\\PhysicalDrive/g; s/://g" "%~dp0TMP\hdl-hdd.txt"

REM OLD Replace 
REM set "search=hdd"
REM set "replace=\\.\PhysicalDrive"
REM set "search2=:"
REM set "replace2="
REM set "textFile=hdl-hdd.txt"
REM set "rootDir="%~dp0TMP"
REM ::for /R "%rootDir%" %%j in ("%textFile%") do (
REM for %%j in ("%rootDir%\%textFile%") do (
REM     for /f "delims=" %%i in ('type "%%~j" ^& break ^> "%%~j"') do (
REM         set "line=%%i"
REM         setlocal EnableDelayedExpansion
REM         set "line=!line:%search%=%replace%!"
REM 		set "line=!line:%search2%=%replace2%!"
REM         >>"%%~j" echo(!line!
REM         
REM 		)
REM  )

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
		del info.sys >nul 2>&1
	    pause & (goto start)
	)
		
"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo %Transfer% %Applications%
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1) %YES%
"%~dp0BAT\Diagbox" gd 0c
echo         2) %NO%
"%~dp0BAT\Diagbox" gd 0e
echo		3) %TCF%
"%~dp0BAT\Diagbox" gd 07
echo\
CHOICE /C 123 /M %BASIC_CHOICE%

IF ERRORLEVEL 1 set @pfs_apps=yes
IF ERRORLEVEL 2 set @pfs_apps=no
IF ERRORLEVEL 3 set @pfs_apps=yes & call "%~dp0BAT\make_title_cfg.BAT" & cd /d "%~dp0"
"%~dp0BAT\Diagbox" gd 0f


echo\
echo\
echo %Transfer% %Artwork%
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1) %YES%
"%~dp0BAT\Diagbox" gd 0c
echo         2) %NO%
echo\
"%~dp0BAT\Diagbox" gd 07
CHOICE /C 12 /M %BASIC_CHOICE%

IF ERRORLEVEL 1 set @pfs_art=yes
IF ERRORLEVEL 2 set @pfs_art=no


"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo %Transfer% %Configs%
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1) %YES%
"%~dp0BAT\Diagbox" gd 0c
echo         2) %NO%
"%~dp0BAT\Diagbox" gd 07
echo\
CHOICE /C 12 /M %BASIC_CHOICE%

IF ERRORLEVEL 1 set @pfs_cfg=yes
IF ERRORLEVEL 2 set @pfs_cfg=no


"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo %Transfer% %Cheats%
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1) %YES%
"%~dp0BAT\Diagbox" gd 0c
echo         2) %NO%
"%~dp0BAT\Diagbox" gd 0e
echo         3) %INST_WIDE%
"%~dp0BAT\Diagbox" gd 07
echo\
CHOICE /C 123 /M %BASIC_CHOICE%

IF ERRORLEVEL 1 set @pfs_cht=yes
IF ERRORLEVEL 2 set @pfs_cht=no
IF ERRORLEVEL 3 (
"%~dp0BAT\Diagbox" gd 0e
	echo %DOWNLOAD_CHEATS%
	choice
	if ERRORLEVEL 1 (
	echo %INTERNET_CHECK%
	Ping www.google.nl -n 1 -w 1000 >nul
	if errorlevel 1 (
		
		echo %NO_INTERNET%
		
	) else (
	"%~dp0BAT\Diagbox" gd 0d
	"%~dp0BAT\wget" -q --show-progress https://github.com/PS2-Widescreen/OPL-Widescreen-Cheats/releases/download/Latest/widescreen_hacks.zip -O BAT\WIDE.ZIP
	"%~dp0BAT\Diagbox" gd 07
	)) 
	
	"%~dp0BAT\Diagbox" gd 0e
		echo %EXTRACTING_WIDE%
		timeout 2 >nul
	"%~dp0BAT\Diagbox" gd 07
		::echo %EXTRACTED_WIDE%
	"%~dp0BAT\Diagbox" gd 0f
	"%~dp0BAT\7z.exe" x -bso0 "%~dp0BAT\WIDE.ZIP" *.cht -r
		echo .
	"%~dp0BAT\Diagbox" gd 07
	set @pfs_cht=yes
)
"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo %Transfer% VMCs:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1) %YES%
"%~dp0BAT\Diagbox" gd 0c
echo         2) %NO%
"%~dp0BAT\Diagbox" gd 07
echo\
CHOICE /C 123 /M %BASIC_CHOICE%

IF ERRORLEVEL 1 set @pfs_vmc=yes
IF ERRORLEVEL 2 set @pfs_vmc=no

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo %Transfer% %Themes%
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1) %YES%
"%~dp0BAT\Diagbox" gd 0c
echo         2) %NO%
"%~dp0BAT\Diagbox" gd 07
echo\
CHOICE /C 12 /M %BASIC_CHOICE%

IF ERRORLEVEL 1 set @pfs_thm=yes
IF ERRORLEVEL 2 set @pfs_thm=no

echo\
echo\
echo %EST_FILE_SIZE%
echo ----------------------------------------------------
REM APPS INFO

IF %@pfs_apps%==yes (
	IF /I EXIST "%~dp0APPS\*" (
	dir /s /a APPS | "%~dp0BAT\busybox" tail -4 | "%~dp0BAT\busybox" grep "File(s)" | "%~dp0BAT\busybox" head -1 | "%~dp0BAT\busybox" sed "s/ File(s).*//" | "%~dp0BAT\busybox" tr -d " " > "%~dp0TMP\appsfiles.txt"
	dir /s /a APPS | "%~dp0BAT\busybox" tail -4 | "%~dp0BAT\busybox" grep "File(s)" | "%~dp0BAT\busybox" head -1 | "%~dp0BAT\busybox" sed "s/.*File(s)//" | "%~dp0BAT\busybox" sed "s/bytes//" | "%~dp0BAT\busybox" tr -d " " | "%~dp0BAT\busybox" tr -d "," > "%~dp0TMP\appssize.txt"
	"%~dp0BAT\busybox" cat "%~dp0TMP\appssize.txt" | "%~dp0BAT\busybox" awk "{ foo = $1 / 1024 / 1024 ; print foo }" | "%~dp0BAT\busybox" sed "s/\..*$//"  > "%~dp0TMP\appssizeMB.txt"
	REM "%~dp0BAT\busybox" cat "%~dp0TMP\appssize.txt" | "%~dp0BAT\busybox" awk "{ bar = $1 / 1024 / 1024 / 1024 ; print bar }" | "%~dp0BAT\busybox" sed -re "s/([0-9]+\.[0-9]{2})[0-9]+/\1/g" > "%~dp0TMP\appssizeGB.txt"
	set /P @apps_file=<"%~dp0TMP\appsfiles.txt"
	set /P @apps_size=<"%~dp0TMP\appssizeMB.txt"
	del "%~dp0TMP\appsfiles.txt" "%~dp0TMP\appssize.txt" "%~dp0TMP\appssizeMB.txt" >nul 2>&1
	echo         APPS - %Files% !@apps_file! %Size% !@apps_size! Mb
	) else ( echo         APPS - %IS_EMPTY% )
)

REM ART INFO

IF %@pfs_art%==yes (
IF /I EXIST "%~dp0ART\*.*" (
	dir /s /a "%~dp0ART\*" | "%~dp0BAT\busybox" grep "File(s)" | "%~dp0BAT\busybox" head -1 | "%~dp0BAT\busybox" sed "s/ File(s).*//" | "%~dp0BAT\busybox" tr -d " " > "%~dp0TMP\artfiles.txt"
	dir /s /a "%~dp0ART\*" | "%~dp0BAT\busybox" grep "File(s)" | "%~dp0BAT\busybox" head -1 | "%~dp0BAT\busybox" sed "s/.*File(s)//" | "%~dp0BAT\busybox" sed "s/bytes//" | "%~dp0BAT\busybox" tr -d " " | "%~dp0BAT\busybox" tr -d "," > "%~dp0TMP\artsize.txt"
	"%~dp0BAT\busybox" cat "%~dp0TMP\artsize.txt" | "%~dp0BAT\busybox" awk "{ foo = $1 / 1024 / 1024 ; print foo }" | "%~dp0BAT\busybox" sed "s/\..*$//"  > "%~dp0TMP\artsizeMB.txt"
	REM "%~dp0BAT\busybox" cat "%~dp0TMP\artsize.txt" | "%~dp0BAT\busybox" awk "{ bar = $1 / 1024 / 1024 / 1024 ; print bar }" | "%~dp0BAT\busybox" sed -re "s/([0-9]+\.[0-9]{2})[0-9]+/\1/g" > "%~dp0TMP\artsizeGB.txt"
	set /P @art_file=<"%~dp0TMP\artfiles.txt"
	set /P @art_size=<"%~dp0TMP\artsizeMB.txt"
	del "%~dp0TMP\artfiles.txt" "%~dp0TMP\artsize.txt" "%~dp0TMP\artsizeMB.txt" >nul 2>&1
	echo         ART - %Files% !@art_file! %Size% !@art_size! Mb
	) else ( echo         ART - %IS_EMPTY% )
)

REM CFG INFO

IF %@pfs_cfg%==yes (
	IF /I EXIST "%~dp0CFG\*.cfg" (
	dir /s /a "%~dp0CFG\*.cfg" | "%~dp0BAT\busybox" grep "File(s)" | "%~dp0BAT\busybox" head -1 | "%~dp0BAT\busybox" sed "s/ File(s).*//" | "%~dp0BAT\busybox" tr -d " " > "%~dp0TMP\cfgfiles.txt"
	dir /s /a "%~dp0CFG\*.cfg" | "%~dp0BAT\busybox" grep "File(s)" | "%~dp0BAT\busybox" head -1 | "%~dp0BAT\busybox" sed "s/.*File(s)//" | "%~dp0BAT\busybox" sed "s/bytes//" | "%~dp0BAT\busybox" tr -d " " | "%~dp0BAT\busybox" tr -d "," > "%~dp0TMP\cfgsize.txt"
	"%~dp0BAT\busybox" cat "%~dp0TMP\cfgsize.txt" | "%~dp0BAT\busybox" awk "{ foo = $1 / 1024 / 1024 ; print foo }" | "%~dp0BAT\busybox" sed "s/\..*$//"  > "%~dp0TMP\cfgsizeMB.txt"
	REM "%~dp0BAT\busybox" cat "%~dp0TMP\cfgsize.txt" | "%~dp0BAT\busybox" awk "{ bar = $1 / 1024 / 1024 / 1024 ; print bar }" | "%~dp0BAT\busybox" sed -re "s/([0-9]+\.[0-9]{2})[0-9]+/\1/g" > "%~dp0TMP\cfgsizeGB.txt"
	set /P @cfg_file=<"%~dp0TMP\cfgfiles.txt"
	set /P @cfg_size=<"%~dp0TMP\cfgsizeMB.txt"
	del "%~dp0TMP\cfgfiles.txt" "%~dp0TMP\cfgsize.txt" "%~dp0TMP\cfgsizeMB.txt" >nul 2>&1
	echo         CFG - %Files% !@cfg_file! %Size% !@cfg_size! Mb
	) else ( echo         CFG - %CFG_EMPTY% )
)

REM CHT INFO

IF %@pfs_cht%==yes (
	IF /I EXIST "%~dp0CHT\*.cht" (
	dir /s /a "%~dp0CHT\*.cht" | "%~dp0BAT\busybox" grep "File(s)" | "%~dp0BAT\busybox" head -1 | "%~dp0BAT\busybox" sed "s/ File(s).*//" | "%~dp0BAT\busybox" tr -d " " > "%~dp0TMP\chtfiles.txt"
	dir /s /a "%~dp0CHT\*.cht" | "%~dp0BAT\busybox" grep "File(s)" | "%~dp0BAT\busybox" head -1 | "%~dp0BAT\busybox" sed "s/.*File(s)//" | "%~dp0BAT\busybox" sed "s/bytes//" | "%~dp0BAT\busybox" tr -d " " | "%~dp0BAT\busybox" tr -d "," > "%~dp0TMP\chtsize.txt"
	"%~dp0BAT\busybox" cat "%~dp0TMP\chtsize.txt" | "%~dp0BAT\busybox" awk "{ foo = $1 / 1024 / 1024 ; print foo }" | "%~dp0BAT\busybox" sed "s/\..*$//"  > "%~dp0TMP\chtsizeMB.txt"
	REM "%~dp0BAT\busybox" cat "%~dp0TMP\chtsize.txt" | "%~dp0BAT\busybox" awk "{ bar = $1 / 1024 / 1024 / 1024 ; print bar }" | "%~dp0BAT\busybox" sed -re "s/([0-9]+\.[0-9]{2})[0-9]+/\1/g" > "%~dp0TMP\chtsizeGB.txt"
	set /P @cht_file=<"%~dp0TMP\chtfiles.txt"
	set /P @cht_size=<"%~dp0TMP\chtsizeMB.txt"
	del "%~dp0TMP\chtfiles.txt" "%~dp0TMP\chtsize.txt" "%~dp0TMP\chtsizeMB.txt" >nul 2>&1
	echo         CHT - %Files% !@cht_file! %Size% !@cht_size! Mb
	) else ( echo         CHT - %CHT_EMPTY% )
)

REM VMC INFO

IF %@pfs_vmc%==yes (
IF /I EXIST "%~dp0VMC\*.bin" (
	dir /s /a "%~dp0VMC\*.bin" | "%~dp0BAT\busybox" grep "File(s)" | "%~dp0BAT\busybox" head -1 | "%~dp0BAT\busybox" sed "s/ File(s).*//" | "%~dp0BAT\busybox" tr -d " " > "%~dp0TMP\vmcfiles.txt"
	dir /s /a "%~dp0VMC\*.bin" | "%~dp0BAT\busybox" grep "File(s)" | "%~dp0BAT\busybox" head -1 | "%~dp0BAT\busybox" sed "s/.*File(s)//" | "%~dp0BAT\busybox" sed "s/bytes//" | "%~dp0BAT\busybox" tr -d " " | "%~dp0BAT\busybox" tr -d "," > "%~dp0TMP\vmcsize.txt"
	"%~dp0BAT\busybox" cat "%~dp0TMP\vmcsize.txt" | "%~dp0BAT\busybox" awk "{ foo = $1 / 1024 / 1024 ; print foo }" | "%~dp0BAT\busybox" sed "s/\..*$//"  > "%~dp0TMP\vmcsizeMB.txt"
	REM "%~dp0BAT\busybox" cat "%~dp0TMP\vmcsize.txt" | "%~dp0BAT\busybox" awk "{ bar = $1 / 1024 / 1024 / 1024 ; print bar }" | "%~dp0BAT\busybox" sed -re "s/([0-9]+\.[0-9]{2})[0-9]+/\1/g" > "%~dp0TMP\vmcsizeGB.txt"
	set /P @vmc_file=<"%~dp0TMP\vmcfiles.txt"
	set /P @vmc_size=<"%~dp0TMP\vmcsizeMB.txt"
	del "%~dp0TMP\vmcfiles.txt" "%~dp0TMP\vmcsize.txt" "%~dp0TMP\vmcsizeMB.txt" >nul 2>&1
	echo         VMC - %Files% !@vmc_file! %Size% !@vmc_size! Mb
	) else ( echo         VMC - %VMC_EMPTY% )
)

REM THM INFO

IF %@pfs_thm%==yes (
	IF /I EXIST "%~dp0THM\*" (
	dir /s /a THM | "%~dp0BAT\busybox" tail -4 | "%~dp0BAT\busybox" grep "File(s)" | "%~dp0BAT\busybox" head -1 | "%~dp0BAT\busybox" sed "s/ File(s).*//" | "%~dp0BAT\busybox" tr -d " " > "%~dp0TMP\thmfiles.txt"
	dir /s /a THM | "%~dp0BAT\busybox" tail -4 | "%~dp0BAT\busybox" grep "File(s)" | "%~dp0BAT\busybox" head -1 | "%~dp0BAT\busybox" sed "s/.*File(s)//" | "%~dp0BAT\busybox" sed "s/bytes//" | "%~dp0BAT\busybox" tr -d " " | "%~dp0BAT\busybox" tr -d "," > "%~dp0TMP\thmsize.txt"
	"%~dp0BAT\busybox" cat "%~dp0TMP\thmsize.txt" | "%~dp0BAT\busybox" awk "{ foo = $1 / 1024 / 1024 ; print foo }" | "%~dp0BAT\busybox" sed "s/\..*$//"  > "%~dp0TMP\thmsizeMB.txt"
	REM "%~dp0BAT\busybox" cat "%~dp0TMP\thmsize.txt" | "%~dp0BAT\busybox" awk "{ bar = $1 / 1024 / 1024 / 1024 ; print bar }" | "%~dp0BAT\busybox" sed -re "s/([0-9]+\.[0-9]{2})[0-9]+/\1/g" > "%~dp0TMP\thmsizeGB.txt"
	set /P @thm_file=<"%~dp0TMP\thmfiles.txt"
	set /P @thm_size=<"%~dp0TMP\thmsizeMB.txt"
	del "%~dp0TMP\thmfiles.txt" "%~dp0TMP\thmsize.txt" "%~dp0TMP\thmsizeMB.txt" >nul 2>&1
	echo         THM - %Files% !@thm_file! %Size% !@thm_size! Mb
	) else ( echo         THM - %IS_EMPTY% )
)

REM TOTAL INFO

set /a "@ttl_file=!@art_file!+!@cfg_file!+!@cht_file!+!@vmc_file!+!@thm_file!+!@apps_file!+0"
set /a "@ttl_size=!@art_size!+!@cfg_size!+!@cht_size!+!@vmc_size!+!@thm_size!+!@apps_file!+0"
echo         TTL - %Files% !@ttl_file! %Size% !@ttl_size! Mb

"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo %SEARCHING_OPLPART% [%OPLPART%]
echo ----------------------------------------------------

	echo device !@hdl_path! > "%~dp0TMP\pfs-prt.txt"
	echo ls >> "%~dp0TMP\pfs-prt.txt"
	echo exit >> "%~dp0TMP\pfs-prt.txt"
	type "%~dp0TMP\pfs-prt.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" tee > "%~dp0TMP\pfs-prt.log"
	"%~dp0BAT\busybox" cat "%~dp0TMP\pfs-prt.log" | "%~dp0BAT\busybox" grep "+OPL" | "%~dp0BAT\busybox" sed "s/.*+OPL/+OPL/" | "%~dp0BAT\busybox" tr -d " " | "%~dp0BAT\busybox" head -1 > "%~dp0TMP\hdd-prt.txt"
	set /P @hdd_avl=<"%~dp0TMP\hdd-prt.txt"
	del "%~dp0TMP\pfs-prt.txt" "%~dp0TMP\pfs-prt.log" >nul 2>&1 "%~dp0TMP\hdd-prt.txt"

	IF "!@hdd_avl!"=="+OPL" (
	"%~dp0BAT\Diagbox" gd 0a
		echo         %OPLPART% - %DETECTED_OPLPART%
		"%~dp0BAT\Diagbox" gd 07
		) else (
		"%~dp0BAT\Diagbox" gd 0c
		echo         %OPLPART% - %MISSING_OPLPART%
		"%~dp0BAT\Diagbox" gd 07
		echo         %FORMAT_OPLPART%
		echo\
		echo\
		rmdir /Q/S "%~dp0TMP" >nul 2>&1
		del info.sys >nul 2>&1
	    pause & (goto start)
		)
	)

echo\
echo\
pause
cls

REM OPL APPS

IF %@pfs_apps%==yes (

echo\
echo\
echo %INSTALLING% %Applications%
echo ----------------------------------------------------
echo\

IF /I EXIST "%~dp0APPS\*" (
	cd "%~dp0APPS
	echo         Creating Que

	REM MOUNT OPL

	echo device !@hdl_path! > "%~dp0TMP\pfs-apps.txt"
	echo mount %OPLPART% >> "%~dp0TMP\pfs-apps.txt"

	REM PARENT DIR (OPL\APPS)

	echo mkdir APPS >> "%~dp0TMP\pfs-apps.txt"
	echo cd APPS >> "%~dp0TMP\pfs-apps.txt"
	
    REM APPS FILES (OPL\APPS\files.xxx)
	
 	for %%0 in (*) do (echo put "%%0") >> "%~dp0TMP\pfs-apps.txt"

	REM APPS 1 DIR (OPL\APPS\APP)

	for /D %%a in (*) do (
	echo mkdir "%%~na" >> "%~dp0TMP\pfs-apps.txt"
	echo lcd "%%~na" >> "%~dp0TMP\pfs-apps.txt"
 	echo cd "%%~na" >> "%~dp0TMP\pfs-apps.txt"
 	cd "%%~na"

	REM APPS FILES (OPL\APPS\APP\files.xxx)

 	for %%1 in (*) do (echo put "%%1") >> "%~dp0TMP\pfs-apps.txt"

	REM APPS 2 SUBDIR (OPL\APPS\APP\SUBDIR)

	for /D %%b in (*) do (
	echo mkdir "%%~nb" >> "%~dp0TMP\pfs-apps.txt"
	echo lcd "%%~nb" >> "%~dp0TMP\pfs-apps.txt"
	echo cd "%%~nb" >> "%~dp0TMP\pfs-apps.txt"
	cd "%%~nb"

	REM APPS SUBDIR FILES (OPL\APPS\APP\SUBDIR\files.xxx)

	for %%2 in (*) do (echo put "%%2") >> "%~dp0TMP\pfs-apps.txt"
	
	REM APPS 3 SUBDIR (OPL\APPS\APP\SUBDIR\SUBDIR)

	for /D %%c in (*) do (
	echo mkdir "%%~nc" >> "%~dp0TMP\pfs-apps.txt"
	echo lcd "%%~nc" >> "%~dp0TMP\pfs-apps.txt"
	echo cd "%%~nc" >> "%~dp0TMP\pfs-apps.txt"
	cd "%%~nc"
	
	REM APPS SUBDIR FILES (OPL\APPS\APP\SUBDIR\SUBDIR\files.xxx)
	
	for %%3 in (*) do (echo put "%%3") >> "%~dp0TMP\pfs-apps.txt"
	
    REM APPS 4 SUBDIR (OPL\APPS\APP\SUBDIR\SUBDIR\SUBDIR\SUBDIR)

	for /D %%e in (*) do (
	echo mkdir "%%~ne" >> "%~dp0TMP\pfs-apps.txt"
	echo lcd "%%~ne" >> "%~dp0TMP\pfs-apps.txt"
	echo cd "%%~ne" >> "%~dp0TMP\pfs-apps.txt"
	cd "%%~ne"
	
	REM APPS SUBDIR FILES (OPL\APPS\APP\SUBDIR\SUBDIR\SUBDIR\files.xxx)
	
	for %%4 in (*) do (echo put "%%h") >> "%~dp0TMP\pfs-apps.txt"
	
	REM APPS 5 SUBDIR (OPL\APPS\APP\SUBDIR\SUBDIR\SUBDIR\SUBDIR\)

	for /D %%f in (*) do (
	echo mkdir "%%~nf" >> "%~dp0TMP\pfs-apps.txt"
	echo lcd "%%~nf" >> "%~dp0TMP\pfs-apps.txt"
	echo cd "%%~nf" >> "%~dp0TMP\pfs-apps.txt"
	cd "%%~nf"
	
	REM APPS SUBDIR FILES (OPL\APPS\APP\SUBDIR\SUBDIR\SUBDIR\SUBDIR\files.xxx)
	
	for %%5 in (*) do (echo put "%%5") >> "%~dp0TMP\pfs-apps.txt"
	
	REM APPS 6 SUBDIR (OPL\APPS\APP\SUBDIR\SUBDIR\SUBDIR\SUBDIR\)

	for /D %%g in (*) do (
	echo mkdir "%%~ng" >> "%~dp0TMP\pfs-apps.txt"
	echo lcd "%%~ng" >> "%~dp0TMP\pfs-apps.txt"
	echo cd "%%~ng" >> "%~dp0TMP\pfs-apps.txt"
	cd "%%~ng"
	
	REM APPS SUBDIR FILES (OPL\APPS\APP\SUBDIR\SUBDIR\SUBDIR\SUBDIR\SUBDIR\files.xxx)
	
	for %%6 in (*) do (echo put "%%6") >> "%~dp0TMP\pfs-apps.txt"
	
	REM APPS 7 SUBDIR (OPL\APPS\APP\SUBDIR\SUBDIR\SUBDIR\SUBDIR\SUBDIR\SUBDIR\)

	for /D %%h in (*) do (
	echo mkdir "%%~nh" >> "%~dp0TMP\pfs-apps.txt"
	echo lcd "%%~nh" >> "%~dp0TMP\pfs-apps.txt"
	echo cd "%%~nh" >> "%~dp0TMP\pfs-apps.txt"
	cd "%%~nh"
	
	REM APPS SUBDIR FILES (OPL\APPS\APP\SUBDIR\SUBDIR\SUBDIR\SUBDIR\SUBDIR\SUBDIR\files.xxx)
	
	for %%7 in (*) do (echo put "%%7") >> "%~dp0TMP\pfs-apps.txt"
	
	REM APPS 8 SUBDIR (OPL\APPS\APP\SUBDIR\SUBDIR\SUBDIR\SUBDIR\SUBDIR\SUBDIR\SUBDIR\)

	for /D %%i in (*) do (
	echo mkdir "%%~ni" >> "%~dp0TMP\pfs-apps.txt"
	echo lcd "%%~ni" >> "%~dp0TMP\pfs-apps.txt"
	echo cd "%%~ni" >> "%~dp0TMP\pfs-apps.txt"
	cd "%%~ni"
	
	REM APPS SUBDIR FILES (OPL\APPS\APP\SUBDIR\SUBDIR\SUBDIR\SUBDIR\SUBDIR\SUBDIR\SUBDIR\files.xxx)
	
	for %%8 in (*) do (echo put "%%8") >> "%~dp0TMP\pfs-apps.txt"
	
	REM APPS 9 SUBDIR (OPL\APPS\APP\SUBDIR\SUBDIR\SUBDIR\SUBDIR\SUBDIR\SUBDIR\SUBDIR\SUBDIR\)

	for /D %%j in (*) do (
	echo mkdir "%%~nj" >> "%~dp0TMP\pfs-apps.txt"
	echo lcd "%%~nj" >> "%~dp0TMP\pfs-apps.txt"
	echo cd "%%~nj" >> "%~dp0TMP\pfs-apps.txt"
	cd "%%~nj"
	
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

	REM UNMOUNT OPL

	)
	echo umount >> "%~dp0TMP\pfs-apps.txt"
	echo exit >> "%~dp0TMP\pfs-apps.txt"

	echo         %INSTALLING% Que
	type "%~dp0TMP\pfs-apps.txt" | "%~dp0BAT\pfsshell" >nul 2>&1
	del "%~dp0TMP\pfs-apps.txt" >nul 2>&1
	echo         %CREAT_LOG%
	echo device !@hdl_path! > "%~dp0TMP\pfs-log.txt"
	echo mount %OPLPART% >> "%~dp0TMP\pfs-log.txt"
	echo cd APPS >> "%~dp0TMP\pfs-log.txt"
	echo ls >> "%~dp0TMP\pfs-log.txt"
	echo umount >> "%~dp0TMP\pfs-log.txt"
	echo exit >> "%~dp0TMP\pfs-log.txt"
	type "%~dp0TMP\pfs-log.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" tee > "%~dp0TMP\pfs-tmp.log"
	mkdir "%~dp0LOG" >nul 2>&1
	"%~dp0BAT\busybox" grep -i -e "apps_" "%~dp0TMP\pfs-tmp.log" > "%~dp0LOG\PFS-APPS.log"
	del "%~dp0TMP\pfs-log.txt" "%~dp0TMP\pfs-tmp.log" >nul 2>&1
	echo         APPS %COMPLETED%	
	cd "%~dp0"
	) else ( echo         APPS - %IS_EMPTY% )
)


REM OPL ARTWORK

IF %@pfs_art%==yes (

echo\
echo\
echo %INSTALLING% %Artwork%
echo ----------------------------------------------------
echo\

IF /I EXIST "%~dp0ART\*.*" (
	cd "%~dp0ART"
	echo         Creating Que
	echo device !@hdl_path! > "%~dp0TMP\pfs-art.txt"
	echo mount %OPLPART% >> "%~dp0TMP\pfs-art.txt"
	echo mkdir ART >> "%~dp0TMP\pfs-art.txt"
	echo cd ART >> "%~dp0TMP\pfs-art.txt"
	for %%f in (*) do (echo put "%%f") >> "%~dp0TMP\pfs-art.txt"
	echo umount >> "%~dp0TMP\pfs-art.txt"
	echo exit >> "%~dp0TMP\pfs-art.txt"
	echo         %INSTALLING% Que
	type "%~dp0TMP\pfs-art.txt" | "%~dp0BAT\pfsshell" >nul 2>&1
	del "%~dp0TMP\pfs-art.txt" >nul 2>&1
	echo         %CREAT_LOG%
	echo device !@hdl_path! > "%~dp0TMP\pfs-log.txt"
	echo mount %OPLPART% >> "%~dp0TMP\pfs-log.txt"
	echo cd ART >> "%~dp0TMP\pfs-log.txt"
	echo ls >> "%~dp0TMP\pfs-log.txt"
	echo umount >> "%~dp0TMP\pfs-log.txt"
	echo exit >> "%~dp0TMP\pfs-log.txt"
	type "%~dp0TMP\pfs-log.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" tee > "%~dp0TMP\pfs-tmp.log"
	mkdir "%~dp0LOG" >nul 2>&1
	"%~dp0BAT\busybox" grep -i -e ".png" -e ".jpg" "%~dp0TMP\pfs-tmp.log" > "%~dp0LOG\PFS-ART.log"
	del "%~dp0TMP\pfs-log.txt" "%~dp0TMP\pfs-tmp.log" >nul 2>&1
	echo         ART %COMPLETED%	
	cd "%~dp0"
	) else ( echo         ART - %IS_EMPTY% )
)


REM OPL CONFIGS

IF %@pfs_cfg%==yes (

echo\
echo\
echo %INSTALLING% %Configs%
echo ----------------------------------------------------
echo\

IF /I EXIST "%~dp0CFG\*.*" (
	cd "%~dp0CFG"
	echo         Creating Que
	echo device !@hdl_path! > "%~dp0TMP\pfs-cfg.txt"
	echo mount %OPLPART% >> "%~dp0TMP\pfs-cfg.txt"
	echo mkdir CFG >> "%~dp0TMP\pfs-cfg.txt"
	echo cd CFG >> "%~dp0TMP\pfs-cfg.txt"
	for %%f in (*.cfg) do (echo put "%%f") >> "%~dp0TMP\pfs-cfg.txt"
	echo umount >> "%~dp0TMP\pfs-cfg.txt"
	echo exit >> "%~dp0TMP\pfs-cfg.txt"
	echo         %INSTALLING% Que
	type "%~dp0TMP\pfs-cfg.txt" | "%~dp0BAT\pfsshell" >nul 2>&1
	del "%~dp0TMP\pfs-cfg.txt" >nul 2>&1
	echo         %CREAT_LOG%
	echo device !@hdl_path! > "%~dp0TMP\pfs-log.txt"
	echo mount %OPLPART% >> "%~dp0TMP\pfs-log.txt"
	echo cd CFG >> "%~dp0TMP\pfs-log.txt"
	echo ls >> "%~dp0TMP\pfs-log.txt"
	echo umount >> "%~dp0TMP\pfs-log.txt"
	echo exit >> "%~dp0TMP\pfs-log.txt"
	type "%~dp0TMP\pfs-log.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" tee > "%~dp0TMP\pfs-tmp.log"
	mkdir "%~dp0LOG" >nul 2>&1
	"%~dp0BAT\busybox" grep -i -e ".cfg" "%~dp0TMP\pfs-tmp.log" > "%~dp0LOG\PFS-CFG.log"
	del "%~dp0TMP\pfs-log.txt" "%~dp0TMP\pfs-tmp.log" >nul 2>&1
	echo         CFG %COMPLETED%	
	cd "%~dp0"
	) else ( echo         CFG - %CFG_EMPTY% )
)

REM OPL CHEATS

IF %@pfs_cht%==yes (

echo\
echo\
echo %INSTALLING% %Cheats%
echo ----------------------------------------------------
echo\

IF /I EXIST "%~dp0CHT\*.*" (
	cd "%~dp0CHT"
	echo         Creating Que
	echo device !@hdl_path! > "%~dp0TMP\pfs-cht.txt"
	echo mount %OPLPART% >> "%~dp0TMP\pfs-cht.txt"
	echo mkdir CHT >> "%~dp0TMP\pfs-cht.txt"
	echo cd CHT >> "%~dp0TMP\pfs-cht.txt"
	for %%f in (*.cht) do (echo put "%%f") >> "%~dp0TMP\pfs-cht.txt"
	echo umount >> "%~dp0TMP\pfs-cht.txt"
	echo exit >> "%~dp0TMP\pfs-cht.txt"
	echo         %INSTALLING% Que
	type "%~dp0TMP\pfs-cht.txt" | "%~dp0BAT\pfsshell" >nul 2>&1
	del "%~dp0TMP\pfs-cht.txt" >nul 2>&1
	echo         %CREAT_LOG%
	echo device !@hdl_path! > "%~dp0TMP\pfs-log.txt"
	echo mount %OPLPART% >> "%~dp0TMP\pfs-log.txt"
	echo cd CHT >> "%~dp0TMP\pfs-log.txt"
	echo ls >> "%~dp0TMP\pfs-log.txt"
	echo umount >> "%~dp0TMP\pfs-log.txt"
	echo exit >> "%~dp0TMP\pfs-log.txt"
	type "%~dp0TMP\pfs-log.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" tee > "%~dp0TMP\pfs-tmp.log"
	mkdir "%~dp0LOG" >nul 2>&1
	"%~dp0BAT\busybox" grep -i -e ".cht" "%~dp0TMP\pfs-tmp.log" > "%~dp0LOG\PFS-CHT.log"
	del "%~dp0TMP\pfs-log.txt" "%~dp0TMP\pfs-tmp.log" >nul 2>&1
	echo         CHT %COMPLETED%	
	cd "%~dp0"
	) else ( echo         CHT - %CHT_EMPTY% )
)


REM OPL VMC

IF %@pfs_vmc%==yes (

echo\
echo\
echo %INSTALLING% VirtualMC:
echo ----------------------------------------------------
echo\

IF /I EXIST "%~dp0VMC\*.*" (
	cd "%~dp0VMC"
	echo         Creating Que
	echo device !@hdl_path! > "%~dp0TMP\pfs-vmc.txt"
	echo mount %OPLPART% >> "%~dp0TMP\pfs-vmc.txt"
	echo mkdir VMC >> "%~dp0TMP\pfs-vmc.txt"
	echo cd VMC >> "%~dp0TMP\pfs-vmc.txt"
	for %%f in (*.bin) do (echo put "%%f") >> "%~dp0TMP\pfs-vmc.txt"
	echo umount >> "%~dp0TMP\pfs-vmc.txt"
	echo exit >> "%~dp0TMP\pfs-vmc.txt"
	echo         %INSTALLING% Que
	type "%~dp0TMP\pfs-vmc.txt" | "%~dp0BAT\pfsshell" >nul 2>&1
	del "%~dp0TMP\pfs-vmc.txt" >nul 2>&1
	echo         %CREAT_LOG%
	echo device !@hdl_path! > "%~dp0TMP\pfs-log.txt"
	echo mount %OPLPART% >> "%~dp0TMP\pfs-log.txt"
	echo cd VMC >> "%~dp0TMP\pfs-log.txt"
	echo ls >> "%~dp0TMP\pfs-log.txt"
	echo umount >> "%~dp0TMP\pfs-log.txt"
	echo exit >> "%~dp0TMP\pfs-log.txt"
	type "%~dp0TMP\pfs-log.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" tee > "%~dp0TMP\pfs-tmp.log"
	mkdir "%~dp0LOG" >nul 2>&1
	"%~dp0BAT\busybox" grep -i -e ".bin" "%~dp0TMP\pfs-tmp.log" > "%~dp0LOG\PFS-VMC.log"
	del "%~dp0TMP\pfs-log.txt" "%~dp0TMP\pfs-tmp.log" >nul 2>&1
	echo         VMC %COMPLETED%	
	cd "%~dp0"
	) else ( echo         VMC - %VMC_EMPTY% )
)


REM OPL THM

IF %@pfs_thm%==yes (

echo\
echo\
echo %INSTALLING% %Themes:%
echo ----------------------------------------------------
echo\

IF /I EXIST "%~dp0THM\*" (
	cd "%~dp0THM"
	echo         Creating Que

	REM MOUNT OPL

	echo device !@hdl_path! > "%~dp0TMP\pfs-thm.txt"
	echo mount %OPLPART% >> "%~dp0TMP\pfs-thm.txt"

	REM PARENT DIR (OPL\THM)

	echo mkdir THM >> "%~dp0TMP\pfs-thm.txt"
	echo cd THM >> "%~dp0TMP\pfs-thm.txt"

	REM THEME DIR (OPL\THM\THEME)

	for /D %%x in (*) do (
	echo mkdir "%%~nx" >> "%~dp0TMP\pfs-thm.txt"
	echo lcd "%%~nx" >> "%~dp0TMP\pfs-thm.txt"
 	echo cd "%%~nx" >> "%~dp0TMP\pfs-thm.txt"
 	cd "%%~nx"

	REM THEME FILES (OPL\THM\THEME\files.xxx)

 	for %%f in (*) do (echo put "%%f") >> "%~dp0TMP\pfs-thm.txt"

	REM THEME SUBDIR (OPL\THM\THEME\SUBDIR)

	for /D %%y in (*) do (
	echo mkdir "%%~ny" >> "%~dp0TMP\pfs-thm.txt"
	echo lcd "%%~ny" >> "%~dp0TMP\pfs-thm.txt"
	echo cd "%%~ny" >> "%~dp0TMP\pfs-thm.txt"
	cd "%%~ny"

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

	REM UNMOUNT OPL

	)
	echo umount >> "%~dp0TMP\pfs-thm.txt"
	echo exit >> "%~dp0TMP\pfs-thm.txt"

	echo         %INSTALLING% Que
	type "%~dp0TMP\pfs-thm.txt" | "%~dp0BAT\pfsshell" >nul 2>&1
	del "%~dp0TMP\pfs-thm.txt" >nul 2>&1
	echo         %CREAT_LOG%
	echo device !@hdl_path! > "%~dp0TMP\pfs-log.txt"
	echo mount %OPLPART% >> "%~dp0TMP\pfs-log.txt"
	echo cd THM >> "%~dp0TMP\pfs-log.txt"
	echo ls >> "%~dp0TMP\pfs-log.txt"
	echo umount >> "%~dp0TMP\pfs-log.txt"
	echo exit >> "%~dp0TMP\pfs-log.txt"
	type "%~dp0TMP\pfs-log.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" tee > "%~dp0TMP\pfs-tmp.log"
	mkdir "%~dp0LOG" >nul 2>&1
	"%~dp0BAT\busybox" grep -i -e "thm_" "%~dp0TMP\pfs-tmp.log" > "%~dp0LOG\PFS-THM.log"
	del "%~dp0TMP\pfs-log.txt" "%~dp0TMP\pfs-tmp.log" >nul 2>&1
	echo         THM %COMPLETED%	
	cd "%~dp0"
	) else ( echo         THM - %IS_EMPTY% )
)

rmdir /Q/S "%~dp0TMP" >nul 2>&1
del info.sys >nul 2>&1

echo\
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo Installations %COMPLETED%
echo\
echo\
"%~dp0BAT\Diagbox" gd 07

pause & (goto start)

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
"%~dp0BAT\hdl_dump" query | findstr "hdd" | "%~dp0BAT\busybox" grep "Playstation 2 HDD"
"%~dp0BAT\hdl_dump" query | findstr "hdd" | "%~dp0BAT\busybox" grep "Playstation 2 HDD" | "%~dp0BAT\busybox" cut -c2-6 > "%~dp0TMP\hdl-hdd.txt"
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
		del info.sys >nul 2>&1
		pause & (goto start)
	)
"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Transfer VCD:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1) %YES%
"%~dp0BAT\Diagbox" gd 0c
echo         2) %NO%
"%~dp0BAT\Diagbox" gd 0e
echo         3) %YES% (Manually choose the partition where you want to install your .VCDs)
echo\
"%~dp0BAT\Diagbox" gd 07
CHOICE /C 123 /M "Select Option:"

IF ERRORLEVEL 1 set @pfs_pop=yes
IF ERRORLEVEL 2 set @pfs_pop=no
IF ERRORLEVEL 3 set @pfs_pop=yesmanually
IF ERRORLEVEL 3 (goto partpopsname)

"%~dp0BAT\Diagbox" gd 0f

:popspartinstalldefault
echo\
echo\
echo Estimating File Size:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 07
REM IF %@pfs_pop%==yes (
IF /I EXIST "%~dp0POPS\*.VCD" (
	dir /s /a "%~dp0POPS\*.VCD" | "%~dp0BAT\busybox" grep "File(s)" | "%~dp0BAT\busybox" head -1 | "%~dp0BAT\busybox" sed "s/ File(s).*//" | "%~dp0BAT\busybox" tr -d " " > "%~dp0TMP\popsfiles.txt"
	dir /s /a "%~dp0POPS\*.VCD" | "%~dp0BAT\busybox" grep "File(s)" | "%~dp0BAT\busybox" head -1 | "%~dp0BAT\busybox" sed "s/.*File(s)//" | "%~dp0BAT\busybox" sed "s/bytes//" | "%~dp0BAT\busybox" tr -d " " | "%~dp0BAT\busybox" tr -d "," > "%~dp0TMP\popssize.txt"
	"%~dp0BAT\busybox" cat "%~dp0TMP\popssize.txt" | "%~dp0BAT\busybox" awk "{ foo = $1 / 1024 / 1024 ; print foo }" | "%~dp0BAT\busybox" sed "s/\..*$//"  > "%~dp0TMP\popssizeMB.txt"
	REM "%~dp0BAT\busybox" cat "%~dp0TMP\popsize.txt" | "%~dp0BAT\busybox" awk "{ bar = $1 / 1024 / 1024 / 1024 ; print bar }" | "%~dp0BAT\busybox" sed -re "s/([0-9]+\.[0-9]{2})[0-9]+/\1/g" > "%~dp0TMP\popsizeGB.txt"
	set /P @pop_file=<"%~dp0TMP\popsfiles.txt"
	set /P @pop_size=<"%~dp0TMP\popssizeMB.txt"
	del "%~dp0TMP\popsfiles.txt" "%~dp0TMP\popssize.txt" "%~dp0TMP\popssizeMB.txt" >nul 2>&1
	echo         VCD - Files: !@pops_file! Size: !@pops_size! Mb
	) else ( echo        .VCD - Source Not Detected... )
REM )
"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Detecting POPS Partition:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 07

echo device !@hdl_path! > "%~dp0TMP\pfs-prt.txt"
echo ls >> "%~dp0TMP\pfs-prt.txt"
echo exit >> "%~dp0TMP\pfs-prt.txt"
type "%~dp0TMP\pfs-prt.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" tee > "%~dp0TMP\pfs-prt.log"
"%~dp0BAT\busybox" cat "%~dp0TMP\pfs-prt.log" | "%~dp0BAT\busybox" grep "__.POPS" | "%~dp0BAT\busybox" sed "s/.*__.POPS/__.POPS/" | "%~dp0BAT\busybox" tr -d " " > "%~dp0TMP\hdd-prt.txt"
"%~dp0BAT\busybox" sed "/[0-9]/d" "%~dp0TMP\hdd-prt.txt" > "%~dp0TMP\hdd-prt-pops.txt"

set /P @hdd_avl=<"%~dp0TMP\hdd-prt-pops.txt"
REM del "%~dp0TMP\pfs-prt.txt" "%~dp0TMP\pfs-prt.log" >nul 2>&1 "%~dp0TMP\hdd-prt.txt"

IF "!@hdd_avl!"=="__.POPS" (
"%~dp0BAT\Diagbox" gd 0a
	echo         POPS - Partition Detected
	"%~dp0BAT\Diagbox" gd 07
	) else (
	"%~dp0BAT\Diagbox" gd 0c
	echo         POPS - Partition NOT Detected
	echo       Partition Must Be Formatted Or Created
	echo\
	echo\
	"%~dp0BAT\Diagbox" gd 07
    rmdir /Q/S "%~dp0TMP" >nul 2>&1
    del info.sys >nul 2>&1
	pause & (goto start)
  )
)

echo\
echo\
pause
cls
"%~dp0BAT\Diagbox" gd 0f
IF %@pfs_pop%==yes (
echo\
echo\
echo Installing VCD:
echo ----------------------------------------------------
echo\
"%~dp0BAT\Diagbox" gd 07
IF /I EXIST "%~dp0POPS\*.VCD" (
	cd "%~dp0POPS"
	echo         Creating Que
	echo device !@hdl_path! > "%~dp0TMP\pfs-pops.txt"
	echo mount __.POPS >> "%~dp0TMP\pfs-pops.txt"
	for %%f in (*.VCD) do (echo put "%%f") >> "%~dp0TMP\pfs-pops.txt"
	echo umount >> "%~dp0TMP\pfs-pops.txt"
	echo exit >> "%~dp0TMP\pfs-pops.txt"
	echo         %INSTALLING% Que
	type "%~dp0TMP\pfs-pops.txt" | "%~dp0BAT\pfsshell" >nul 2>&1
	del "%~dp0TMP\pfs-pops.txt" >nul 2>&1
	echo         %CREAT_LOG%
	echo device !@hdl_path! > "%~dp0TMP\pfs-log.txt"
	echo mount __.POPS >> "%~dp0TMP\pfs-log.txt"
	echo ls >> "%~dp0TMP\pfs-log.txt"
	echo umount >> "%~dp0TMP\pfs-log.txt"
	echo exit >> "%~dp0TMP\pfs-log.txt"
	type "%~dp0TMP\pfs-log.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" tee > "%~dp0TMP\pfs-tmp.log"
	mkdir "%~dp0LOG" >nul 2>&1
	"%~dp0BAT\busybox" grep -i -e ".vcd" "%~dp0TMP\pfs-tmp.log" > "%~dp0LOG\PFS-POPS.log"
	del "%~dp0TMP\pfs-log.txt" "%~dp0TMP\pfs-tmp.log" >nul 2>&1
	echo         POPS %COMPLETED%	
	cd "%~dp0"
	) else ( echo         .VCD - %IS_EMPTY% )
)

rmdir /Q/S "%~dp0TMP" >nul 2>&1
del info.sys >nul 2>&1

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo Installation Completed...
echo\
echo\
"%~dp0BAT\Diagbox" gd 07

pause & (goto start)


:partpopsname
IF %@pfs_pop%==yesmanually (
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
set /p choice=Select Option:
IF "!choice!"=="" set @pfs_pop=yes & (goto popspartinstalldefault)

IF "!choice!"=="0" set popspartinstall=__.POPS0
IF "!choice!"=="1" set popspartinstall=__.POPS1
IF "!choice!"=="2" set popspartinstall=__.POPS2
IF "!choice!"=="3" set popspartinstall=__.POPS3
IF "!choice!"=="4" set popspartinstall=__.POPS4
IF "!choice!"=="5" set popspartinstall=__.POPS5
IF "!choice!"=="6" set popspartinstall=__.POPS6
IF "!choice!"=="7" set popspartinstall=__.POPS7
IF "!choice!"=="8" set popspartinstall=__.POPS8
IF "!choice!"=="9" set popspartinstall=__.POPS9
IF "!choice!"=="!choice!" set popspartinstall=__.POPS!choice!
IF "!choice!"=="10" set @pfs_pop=yes & (goto popspartinstalldefault)

IF "!choice!"=="__.POPS0" set popspartinstall=__.POPS0
IF "!choice!"=="__.POPS1" set popspartinstall=__.POPS1
IF "!choice!"=="__.POPS2" set popspartinstall=__.POPS2
IF "!choice!"=="__.POPS3" set popspartinstall=__.POPS3
IF "!choice!"=="__.POPS4" set popspartinstall=__.POPS4
IF "!choice!"=="__.POPS5" set popspartinstall=__.POPS5
IF "!choice!"=="__.POPS6" set popspartinstall=__.POPS6
IF "!choice!"=="__.POPS7" set popspartinstall=__.POPS7
IF "!choice!"=="__.POPS8" set popspartinstall=__.POPS8
IF "!choice!"=="__.POPS9" set popspartinstall=__.POPS9
IF "!choice!"=="__.POPS" set @pfs_pop=yes & (goto popspartinstalldefault)

)

echo\
echo\
echo Estimating File Size:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 07
IF /I EXIST "%~dp0POPS\*.VCD" (
	dir /s /a "%~dp0POPS\*.VCD" | "%~dp0BAT\busybox" grep "File(s)" | "%~dp0BAT\busybox" head -1 | "%~dp0BAT\busybox" sed "s/ File(s).*//" | "%~dp0BAT\busybox" tr -d " " > "%~dp0TMP\popsfiles.txt"
	dir /s /a %~dp0POPS\*.VCD | "%~dp0BAT\busybox" grep "File(s)" | "%~dp0BAT\busybox" head -1 | "%~dp0BAT\busybox" sed "s/.*File(s)//" | "%~dp0BAT\busybox" sed "s/bytes//" | "%~dp0BAT\busybox" tr -d " " | "%~dp0BAT\busybox" tr -d "," > "%~dp0TMP\popssize.txt"
	"%~dp0BAT\busybox" cat "%~dp0TMP\popssize.txt" | "%~dp0BAT\busybox" awk "{ foo = $1 / 1024 / 1024 ; print foo }" | "%~dp0BAT\busybox" sed "s/\..*$//"  > "%~dp0TMP\popssizeMB.txt"
	REM "%~dp0BAT\busybox" cat "%~dp0TMP\popsize.txt" | "%~dp0BAT\busybox" awk "{ bar = $1 / 1024 / 1024 / 1024 ; print bar }" | "%~dp0BAT\busybox" sed -re "s/([0-9]+\.[0-9]{2})[0-9]+/\1/g" > "%~dp0TMP\popsizeGB.txt"
	set /P @pop_file=<"%~dp0TMP\popsfiles.txt"
	set /P @pop_size=<"%~dp0TMP\popssizeMB.txt"
	del "%~dp0TMP\popsfiles.txt" "%~dp0TMP\popssize.txt" "%~dp0TMP\popssizeMB.txt" >nul 2>&1
	echo         VCD - Files: !@pops_file! Size: !@pops_size! Mb
	) else ( echo        .VCD - Source Not Detected... )
	
"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Detecting POPS Partition:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 07
echo device !@hdl_path! > "%~dp0TMP\pfs-prt.txt"
echo ls >> "%~dp0TMP\pfs-prt.txt"
echo exit >> "%~dp0TMP\pfs-prt.txt"
type "%~dp0TMP\pfs-prt.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" tee > "%~dp0TMP\pfs-prt.log"
"%~dp0BAT\busybox" cat "%~dp0TMP\pfs-prt.log" | "%~dp0BAT\busybox" grep "%popspartinstall%" | "%~dp0BAT\busybox" sed "s/.*%popspartinstall%/%popspartinstall%/" | "%~dp0BAT\busybox" tr -d " " | "%~dp0BAT\busybox" head -1 > "%~dp0TMP\hdd-prt.txt"
set /P @hdd_avl=<"%~dp0TMP\hdd-prt.txt"
REM del "%~dp0TMP\pfs-prt.txt" "%~dp0TMP\pfs-prt.log" >nul 2>&1 "%~dp0TMP\hdd-prt.txt"

IF "!@hdd_avl!"=="%popspartinstall%" (
"%~dp0BAT\Diagbox" gd 0a
	echo          POPS - Partition Detected
	"%~dp0BAT\Diagbox" gd 07
	) else (
	"%~dp0BAT\Diagbox" gd 0c
	echo           POPS - Partition NOT Detected
	echo        Partition Must Be Formatted Or Created
	echo\
	echo\
	"%~dp0BAT\Diagbox" gd 07
	rmdir /Q/S "%~dp0TMP" >nul 2>&1
	del info.sys >nul 2>&1
	pause & (goto start)
	)
)
echo\
echo\
pause
cls
"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Installing VCD:
echo ----------------------------------------------------
echo\
"%~dp0BAT\Diagbox" gd 07
IF /I EXIST "%~dp0POPS\*.VCD" (
	cd "%~dp0POPS"
	echo         Creating Que
	echo device !@hdl_path! > "%~dp0TMP\pfs-pops.txt"
	echo mount %popspartinstall% >> "%~dp0TMP\pfs-pops.txt"
	for %%f in (*.VCD) do (echo put "%%f") >> "%~dp0TMP\pfs-pops.txt"
	echo umount >> "%~dp0TMP\pfs-pops.txt"
	echo exit >> "%~dp0TMP\pfs-pops.txt"
	echo         %INSTALLING% Que
	type "%~dp0TMP\pfs-pops.txt" | "%~dp0BAT\pfsshell" >nul 2>&1
	del "%~dp0TMP\pfs-pops.txt" >nul 2>&1
	echo         %CREAT_LOG%
	echo device !@hdl_path! > "%~dp0TMP\pfs-log.txt"
	echo mount %popspartinstall% >> "%~dp0TMP\pfs-log.txt"
	echo ls >> "%~dp0TMP\pfs-log.txt"
	echo umount >> "%~dp0TMP\pfs-log.txt"
	echo exit >> "%~dp0TMP\pfs-log.txt"
	type "%~dp0TMP\pfs-log.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" tee > "%~dp0TMP\pfs-tmp.log"
	mkdir "%~dp0LOG" >nul 2>&1
	"%~dp0BAT\busybox" grep -i -e ".vcd" "%~dp0TMP\pfs-tmp.log" > "%~dp0LOG\PFS-POPS.log"
	del "%~dp0TMP\pfs-log.txt" "%~dp0TMP\pfs-tmp.log" >nul 2>&1
	echo         POPS %COMPLETED%	
	cd "%~dp0"
	) else ( echo         .VCD - %IS_EMPTY% )

rmdir /Q/S "%~dp0TMP" >nul 2>&1
del info.sys >nul 2>&1
"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo Installation Completed...
echo\
echo\
"%~dp0BAT\Diagbox" gd 07

pause & (goto start)

REM ########################################################################################################################################################################
:BackupARTCFGCHTVMC

cd "%~dp0"
cls

mkdir "%~dp0TMP" >nul 2>&1
"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning for Playstation 2 HDDs:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | findstr "hdd" | "%~dp0BAT\busybox" grep "Playstation 2 HDD"
"%~dp0BAT\hdl_dump" query | findstr "hdd" | "%~dp0BAT\busybox" grep "Playstation 2 HDD" | "%~dp0BAT\busybox" cut -c2-6 > "%~dp0TMP\hdl-hdd.txt"
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
		REM rmdir /Q/S "%~dp0TMP" >nul 2>&1
		del info.sys >nul 2>&1
		pause & (goto start)
	)
"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Extract Artwork:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1) %YES%
"%~dp0BAT\Diagbox" gd 0c
echo         2) %NO%
"%~dp0BAT\Diagbox" gd 07
echo\
CHOICE /C 12 /M "Select Option:"

IF ERRORLEVEL 1 set @pfs_art=yes
IF ERRORLEVEL 2 set @pfs_art=no

echo\
echo\
echo Extract Configs:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1) %YES%
"%~dp0BAT\Diagbox" gd 0c
echo         2) %NO%
"%~dp0BAT\Diagbox" gd 07
echo\
CHOICE /C 12 /M "Select Option:"

IF ERRORLEVEL 1 set @pfs_cfg=yes
IF ERRORLEVEL 2 set @pfs_cfg=no

echo\
echo\
echo Extract Cheats:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1) %YES%
"%~dp0BAT\Diagbox" gd 0c
echo         2) %NO%
"%~dp0BAT\Diagbox" gd 07
echo\
CHOICE /C 12 /M "Select Option:"

IF ERRORLEVEL 1 set @pfs_cht=yes
IF ERRORLEVEL 2 set @pfs_cht=no

echo\
echo\
echo Extract VMCs:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1) %YES%
"%~dp0BAT\Diagbox" gd 0c
echo         2) %NO%
"%~dp0BAT\Diagbox" gd 07
echo\
CHOICE /C 12 /M "Select Option:"

IF ERRORLEVEL 1 set @pfs_vmc=yes
IF ERRORLEVEL 2 set @pfs_vmc=no

"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Detecting %OPLPART% Partition:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 07

	echo device !@hdl_path! > "%~dp0TMP\pfs-prt.txt"
	echo ls >> "%~dp0TMP\pfs-prt.txt"
	echo exit >> "%~dp0TMP\pfs-prt.txt"
	type "%~dp0TMP\pfs-prt.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" tee > "%~dp0TMP\pfs-prt.log"
	"%~dp0BAT\busybox" cat "%~dp0TMP\pfs-prt.log" | "%~dp0BAT\busybox" grep "+OPL" | "%~dp0BAT\busybox" sed "s/.*+OPL/+OPL/" | "%~dp0BAT\busybox" tr -d " " | "%~dp0BAT\busybox" head -1 > "%~dp0TMP\hdd-prt.txt"
	set /P @hdd_avl=<"%~dp0TMP\hdd-prt.txt"
	del "%~dp0TMP\pfs-prt.txt" "%~dp0TMP\pfs-prt.log" >nul 2>&1 "%~dp0TMP\hdd-prt.txt"

	IF "!@hdd_avl!"=="+OPL" (
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
		REM rmdir /Q/S "%~dp0TMP" >nul 2>&1
		del info.sys >nul 2>&1
		pause & (goto start)
		)
	)

echo\
echo\
pause

cls

REM OPL ARTWORK

IF %@pfs_art%==yes (

echo\
echo\
echo Extract Artwork:
echo ----------------------------------------------------
echo\

	cd "%~dp0ART"
    echo         Files scan...
	echo device !@hdl_path! > "%~dp0TMP\pfs-log.txt"
	echo mount %OPLPART% >> "%~dp0TMP\pfs-log.txt"
	echo cd ART >> "%~dp0TMP\pfs-log.txt"
	echo ls >> "%~dp0TMP\pfs-log.txt"
    echo umount >> "%~dp0TMP\pfs-log.txt"
	echo exit >> "%~dp0TMP\pfs-log.txt"
	type "%~dp0TMP\pfs-log.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" tee > "%~dp0TMP\pfs-tmp.log"
	mkdir "%~dp0LOG" >nul 2>&1 
	"%~dp0BAT\busybox" grep -i -e ".png" -e ".jpg"  "%~dp0TMP\pfs-tmp.log" > "%~dp0LOG\PFS-ART.log"
	
    "%~dp0BAT\busybox" cut -c40-100 "%~dp0LOG\PFS-ART.log" > "%~dp0TMP\pfs-art-new.txt"
	"%~dp0BAT\busybox" sed -i -e "s/^/get /" "%~dp0TMP\pfs-art-new.txt"
	
	echo         Extraction...
	echo device !@hdl_path! > "%~dp0TMP\pfs-art.txt"
	echo mount %OPLPART% >> "%~dp0TMP\pfs-art.txt"
	echo cd ART >> "%~dp0TMP\pfs-art.txt"
	type "%~dp0TMP\pfs-art-new.txt" >> "%~dp0TMP\pfs-art.txt"
	echo umount >> "%~dp0TMP\pfs-art.txt"
	echo exit >> "%~dp0TMP\pfs-art.txt"
	type "%~dp0TMP\pfs-art.txt" | "%~dp0BAT\pfsshell" >nul 2>&1
	
	) else ( echo         ART - Source Not Detected... )

REM OPL CONFIGS

IF %@pfs_cfg%==yes (

echo\
echo\
echo Extraction Configs Files:
echo ----------------------------------------------------
echo\

	cd "%~dp0CFG"
    echo         Files scan...
	echo device !@hdl_path! > "%~dp0TMP\pfs-log.txt"
	echo mount %OPLPART% >> "%~dp0TMP\pfs-log.txt"
	echo cd CFG >> "%~dp0TMP\pfs-log.txt"
	echo ls >> "%~dp0TMP\pfs-log.txt"
    echo umount >> "%~dp0TMP\pfs-log.txt"
	echo exit >> "%~dp0TMP\pfs-log.txt"
	type "%~dp0TMP\pfs-log.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" tee > "%~dp0TMP\pfs-tmp.log"
	mkdir "%~dp0LOG" >nul 2>&1 
	"%~dp0BAT\busybox" grep -i -e ".cfg" "%~dp0TMP\pfs-tmp.log" > "%~dp0LOG\PFS-CFG.log"
    
    "%~dp0BAT\busybox" cut -c40-100 "%~dp0LOG\PFS-CFG.log" > "%~dp0TMP\pfs-cfg-new.txt"
	"%~dp0BAT\busybox" sed -i -e "s/^/get /" "%~dp0TMP\pfs-cfg-new.txt"
	
	echo         Extraction...
	echo device !@hdl_path! > "%~dp0TMP\pfs-cfg.txt"
	echo mount %OPLPART% >> "%~dp0TMP\pfs-cfg.txt"
	echo cd CFG >> "%~dp0TMP\pfs-cfg.txt"
	type "%~dp0TMP\pfs-cfg-new.txt" >> "%~dp0TMP\pfs-cfg.txt"
	echo umount >> "%~dp0TMP\pfs-cfg.txt"
	echo exit >> "%~dp0TMP\pfs-cfg.txt"
	type "%~dp0TMP\pfs-cfg.txt" | "%~dp0BAT\pfsshell" >nul 2>&1
	
	) else ( echo         CFG - Source Not Detected... )

IF %@pfs_cht%==yes (

echo\
echo\
echo Extraction Cheat Files:
echo ----------------------------------------------------
echo\

	cd "%~dp0CHT"
    echo         Files scan...
	echo device !@hdl_path! > "%~dp0TMP\pfs-log.txt"
	echo mount %OPLPART% >> "%~dp0TMP\pfs-log.txt"
	echo cd CHT >> "%~dp0TMP\pfs-log.txt"
	echo ls >> "%~dp0TMP\pfs-log.txt"
    echo umount >> "%~dp0TMP\pfs-log.txt"
	echo exit >> "%~dp0TMP\pfs-log.txt"
	type "%~dp0TMP\pfs-log.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" tee > "%~dp0TMP\pfs-tmp.log"
	mkdir "%~dp0LOG" >nul 2>&1 
	"%~dp0BAT\busybox" grep -i -e ".cht" "%~dp0TMP\pfs-tmp.log" > "%~dp0LOG\PFS-CHT.log"
	
    "%~dp0BAT\busybox" cut -c40-100 "%~dp0LOG\PFS-CHT.log" > "%~dp0TMP\pfs-cht-new.txt"
	"%~dp0BAT\busybox" sed -i -e "s/^/get /" "%~dp0TMP\pfs-CHT-new.txt"
	
	echo         Extraction...
	echo device !@hdl_path! > "%~dp0TMP\pfs-cht.txt"
	echo mount %OPLPART% >> "%~dp0TMP\pfs-cht.txt"
	echo cd CHT >> "%~dp0TMP\pfs-cht.txt"
	type "%~dp0TMP\pfs-cht-new.txt" >> "%~dp0TMP\pfs-cht.txt"
	echo umount >> "%~dp0TMP\pfs-cht.txt"
	echo exit >> "%~dp0TMP\pfs-cht.txt"
	type "%~dp0TMP\pfs-cht.txt" | "%~dp0BAT\pfsshell" >nul 2>&1
	
	) else ( echo         CHT - Source Not Detected... )

REM OPL VMC

IF %@pfs_vmc%==yes (

echo\
echo\
echo Extraction VirtualMC Files:
echo ----------------------------------------------------
echo\

	cd "%~dp0VMC
    echo         Files scan...
	echo device !@hdl_path! > "%~dp0TMP\pfs-log.txt"
	echo mount %OPLPART% >> "%~dp0TMP\pfs-log.txt"
	echo cd VMC >> "%~dp0TMP\pfs-log.txt"
	echo ls >> "%~dp0TMP\pfs-log.txt"
	echo umount >> "%~dp0TMP\pfs-log.txt"
	echo exit >> "%~dp0TMP\pfs-log.txt"
	type "%~dp0TMP\pfs-log.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" tee > "%~dp0TMP\pfs-tmp.log"
	mkdir "%~dp0LOG" >nul 2>&1 
	"%~dp0BAT\busybox" grep -i -e ".bin" "%~dp0TMP\pfs-tmp.log" > "%~dp0LOG\PFS-VMC.log"
    
    "%~dp0BAT\busybox" cut -c40-100 "%~dp0LOG\PFS-VMC.log" > "%~dp0TMP\pfs-vmc-new.txt"
	"%~dp0BAT\busybox" sed -i -e "s/^/get /" "%~dp0TMP\pfs-VMC-new.txt"
	
	echo         Extraction...
	echo device !@hdl_path! > "%~dp0TMP\pfs-vmc.txt"
	echo mount %OPLPART% >> "%~dp0TMP\pfs-vmc.txt"
	echo cd VMC >> "%~dp0TMP\pfs-vmc.txt"
	type "%~dp0TMP\pfs-vmc-new.txt" >> "%~dp0TMP\pfs-vmc.txt"
	echo umount >> "%~dp0TMP\pfs-vmc.txt"
	echo exit >> "%~dp0TMP\pfs-vmc.txt"
	type "%~dp0TMP\pfs-vmc.txt" | "%~dp0BAT\pfsshell" >nul 2>&1
	cd "%~dp0"
	
	) else ( echo         VMC - Source Not Detected... )
	
rmdir /Q/S "%~dp0TMP" >nul 2>&1
del info.sys >nul 2>&1

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo Extraction Completed...
echo\
echo\
"%~dp0BAT\Diagbox" gd 07

pause & (goto start)

REM ########################################################################################################################################################################
:BackupPS1Games

cd "%~dp0"
cls

mkdir "%~dp0TMP" >nul 2>&1

"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning for Playstation 2 HDDs:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | findstr "hdd" | "%~dp0BAT\busybox" grep "Playstation 2 HDD"
"%~dp0BAT\hdl_dump" query | findstr "hdd" | "%~dp0BAT\busybox" grep "Playstation 2 HDD" | "%~dp0BAT\busybox" cut -c2-6 > "%~dp0TMP\hdl-hdd.txt"
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
		del info.sys >nul 2>&1	
		pause & (goto start)
	)
"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Extract All .VCD:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1) %YES%
"%~dp0BAT\Diagbox" gd 0c
echo         2) %NO%
"%~dp0BAT\Diagbox" gd 0e
echo         3) %YES% (Manually Choose the partition where your .VCDs to extract are located.)
echo\
"%~dp0BAT\Diagbox" gd 07
CHOICE /C 123 /M "Select Option:"

IF ERRORLEVEL 1 set @pfs_pop=yes
IF ERRORLEVEL 2 set @pfs_pop=no
IF ERRORLEVEL 3 set @pfs_pop=yesmanually
IF ERRORLEVEL 3 (goto extractpartpopsname)

:popspartextractdefault
echo\
echo\
echo Detecting POPS Partition:
echo ----------------------------------------------------
    
    echo device !@hdl_path! > "%~dp0TMP\pfs-prt.txt"
    echo ls >> "%~dp0TMP\pfs-prt.txt"
    echo exit >> "%~dp0TMP\pfs-prt.txt"
    type "%~dp0TMP\pfs-prt.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" tee > "%~dp0TMP\pfs-prt.log"
    "%~dp0BAT\busybox" cat "%~dp0TMP\pfs-prt.log" | "%~dp0BAT\busybox" grep "__.POPS" | "%~dp0BAT\busybox" sed "s/.*__.POPS/__.POPS/" | "%~dp0BAT\busybox" tr -d " " > "%~dp0TMP\hdd-prt.txt"
    "%~dp0BAT\busybox" sed "/[0-9]/d" "%~dp0TMP\hdd-prt.txt" > "%~dp0TMP\hdd-prt-pops.txt"
	
	 set /P @hdd_avl=<"%~dp0TMP\hdd-prt-pops.txt"
    REM del "%~dp0TMP\pfs-prt.txt" "%~dp0TMP\pfs-prt.log" >nul 2>&1 "%~dp0TMP\hdd-prt.txt"

IF "!@hdd_avl!"=="__.POPS" (
"%~dp0BAT\Diagbox" gd 0a
	echo         POPS - Partition Detected
	"%~dp0BAT\Diagbox" gd 07
	) else (
	"%~dp0BAT\Diagbox" gd 0c
	echo         POPS - Partition NOT Detected
	echo         Partition Must Be Formatted Or Created
	echo\
	echo\
	"%~dp0BAT\Diagbox" gd 07
	rmdir /Q/S "%~dp0TMP" >nul 2>&1
	del info.sys >nul 2>&1
	pause & (goto start)
	)
)
echo\
echo\
pause
cls
IF %@pfs_pop%==yes (
echo\
echo\
echo Extraction VCD:
echo ----------------------------------------------------
echo\

    cd "%~dp0POPS"
    echo         Files scan...
	echo device !@hdl_path! > "%~dp0TMP\pfs-log.txt"
	echo mount __.POPS >> "%~dp0TMP\pfs-log.txt"
	echo ls >> "%~dp0TMP\pfs-log.txt"
	echo umount >> "%~dp0TMP\pfs-log.txt"
	echo exit >> "%~dp0TMP\pfs-log.txt"
	type "%~dp0TMP\pfs-log.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" tee > "%~dp0TMP\pfs-tmp.log"
	mkdir "%~dp0LOG" >nul 2>&1 
	"%~dp0BAT\busybox" grep -i -e ".vcd" "%~dp0TMP\pfs-tmp.log" > "%~dp0LOG\PFS-POPS.log"

	"%~dp0BAT\busybox" cut -c40-254 "%~dp0LOG\PFS-POPS.log" > "%~dp0POPS\PFS-POPS-NEW.txt"
	"%~dp0BAT\busybox" sed -i -e "s/^/get /" "%~dp0POPS\PFS-POPS-NEW.txt"

	echo         Extraction...
	echo device !@hdl_path! > "%~dp0TMP\pfs-pops.txt"
	echo mount __.POPS >> "%~dp0TMP\pfs-pops.txt"
	type "%~dp0POPS\PFS-POPS-NEW.txt" >> "%~dp0TMP\pfs-pops.txt"
	echo umount >> "%~dp0TMP\pfs-pops.txt"
	echo exit >> "%~dp0TMP\pfs-pops.txt"
	del "%~dp0POPS\PFS-POPS-NEW.txt" >nul 2>&1
	del "%~dp0POPS\PFS-POPS-NEW.bat" >nul 2>&1
	type "%~dp0TMP\pfs-popS.txt" | "%~dp0BAT\pfsshell" >nul 2>&1
	cd "%~dp0"

	) else ( echo         POPS - Source Not Detected... )

rmdir /Q/S "%~dp0TMP" >nul 2>&1
del info.sys >nul 2>&1

echo\
echo\
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo Extraction Completed...
echo\
echo\
"%~dp0BAT\Diagbox" gd 07

pause & (goto start)

:extractpartpopsname
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
set /p choice=Select Option:
IF "!choice!"=="" set @pfs_pop=yes & (goto popspartextractdefault)

IF "!choice!"=="0" set popspartextract=__.POPS0
IF "!choice!"=="1" set popspartextract=__.POPS1
IF "!choice!"=="2" set popspartextract=__.POPS2
IF "!choice!"=="3" set popspartextract=__.POPS3
IF "!choice!"=="4" set popspartextract=__.POPS4
IF "!choice!"=="5" set popspartextract=__.POPS5
IF "!choice!"=="6" set popspartextract=__.POPS6
IF "!choice!"=="7" set popspartextract=__.POPS7
IF "!choice!"=="8" set popspartextract=__.POPS8
IF "!choice!"=="9" set popspartextract=__.POPS9
IF "!choice!"=="!choice!" set popspartinstall=__.POPS!choice!
IF "!choice!"=="10" set @pfs_pop=yes & (goto popspartextractdefault)

IF "!choice!"=="__.POPS0" set popspartextract=__.POPS0
IF "!choice!"=="__.POPS1" set popspartextract=__.POPS1
IF "!choice!"=="__.POPS2" set popspartextract=__.POPS2
IF "!choice!"=="__.POPS3" set popspartextract=__.POPS3
IF "!choice!"=="__.POPS4" set popspartextract=__.POPS4
IF "!choice!"=="__.POPS5" set popspartextract=__.POPS5
IF "!choice!"=="__.POPS6" set popspartextract=__.POPS6
IF "!choice!"=="__.POPS7" set popspartextract=__.POPS7
IF "!choice!"=="__.POPS8" set popspartextract=__.POPS8
IF "!choice!"=="__.POPS9" set popspartextract=__.POPS9
IF "!choice!"=="__.POPS" set @pfs_pop=yes & (goto popspartextractdefault)

)

echo\
echo\
echo Detecting POPS Partition:
echo ----------------------------------------------------
    "%~dp0BAT\Diagbox" gd 07
    echo device !@hdl_path! > "%~dp0TMP\pfs-prt.txt"
    echo ls >> "%~dp0TMP\pfs-prt.txt"
    echo exit >> "%~dp0TMP\pfs-prt.txt"
    type "%~dp0TMP\pfs-prt.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" tee > "%~dp0TMP\pfs-prt.log"
    "%~dp0BAT\busybox" cat "%~dp0TMP\pfs-prt.log" | "%~dp0BAT\busybox" grep "%popspartextract%" | "%~dp0BAT\busybox" sed "s/.*%popspartextract%/%popspartextract%/" | "%~dp0BAT\busybox" tr -d " " | "%~dp0BAT\busybox" head -1 > "%~dp0TMP\hdd-prt.txt"
    set /P @hdd_avl=<"%~dp0TMP\hdd-prt.txt"
    REM del "%~dp0TMP\pfs-prt.txt" "%~dp0TMP\pfs-prt.log" >nul 2>&1 "%~dp0TMP\hdd-prt.txt"

IF "!@hdd_avl!"=="%popspartextract%" (
"%~dp0BAT\Diagbox" gd 0a
	echo         POPS - Partition Detected
	"%~dp0BAT\Diagbox" gd 07
	) else (
	"%~dp0BAT\Diagbox" gd 0c
	echo           POPS - Partition NOT Detected
	echo        Partition Must Be Formatted Or Created
	echo\
	echo\
	"%~dp0BAT\Diagbox" gd 07
	rmdir /Q/S "%~dp0TMP" >nul 2>&1
	del info.sys >nul 2>&1
	pause & (goto start)
	)
)
echo\
echo\
pause
cls
echo\
echo\
echo Extraction VCD:
echo ----------------------------------------------------
echo\

    cd "%~dp0POPS"
    echo         Files scan...
	echo device !@hdl_path! > "%~dp0TMP\pfs-log.txt"
	echo mount %popspartextract% >> "%~dp0TMP\pfs-log.txt"
	echo ls >> "%~dp0TMP\pfs-log.txt"
	echo umount >> "%~dp0TMP\pfs-log.txt"
	echo exit >> "%~dp0TMP\pfs-log.txt"
	type "%~dp0TMP\pfs-log.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" tee > "%~dp0TMP\pfs-tmp.log"
	mkdir "%~dp0LOG" >nul 2>&1 
	"%~dp0BAT\busybox" grep -i -e ".vcd" "%~dp0TMP\pfs-tmp.log" > "%~dp0LOG\PFS-POPS.log"

    "%~dp0BAT\busybox" cut -c40-254 "%~dp0LOG\PFS-POPS.log" > "%~dp0POPS\PFS-POPS-NEW.txt"
	"%~dp0BAT\busybox" sed -i -e "s/^/get /" "%~dp0POPS\PFS-POPS-NEW.txt"

	cd "%~dp0POPS"
	echo         Extraction...
	echo device !@hdl_path! > "%~dp0TMP\pfs-pops.txt"
	echo mount %popspartextract% >> "%~dp0TMP\pfs-pops.txt"
	type "%~dp0POPS\PFS-POPS-NEW.txt" >> "%~dp0TMP\pfs-pops.txt"
	echo umount >> "%~dp0TMP\pfs-pops.txt"
	echo exit >> "%~dp0TMP\pfs-pops.txt"
	del "%~dp0POPS\PFS-POPS-NEW.txt" >nul 2>&1
	del "%~dp0POPS\PFS-POPS-NEW.bat" >nul 2>&1
	type "%~dp0TMP\pfs-pops.txt" | "%~dp0BAT\pfsshell" >nul 2>&1
	cd "%~dp0"

	) else ( echo         POPS - Source Not Detected... )

rmdir /Q/S "%~dp0TMP" >nul 2>&1
del info.sys >nul 2>&1

echo\
echo\
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo Extraction Completed...
echo\
echo\
"%~dp0BAT\Diagbox" gd 07

pause & (goto start)

REM ########################################################################################################################################################################
:TransferPOPSBinaries

cd "%~dp0"
cls

mkdir "%~dp0TMP" >nul 2>&1
"%~dp0BAT\Diagbox" gd 0e

echo\
echo\
echo Scanning for Playstation 2 HDDs:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | findstr "hdd" | "%~dp0BAT\busybox" grep "Playstation 2 HDD"
"%~dp0BAT\hdl_dump" query | findstr "hdd" | "%~dp0BAT\busybox" grep "Playstation 2 HDD" | "%~dp0BAT\busybox" cut -c2-6 > "%~dp0TMP\hdl-hdd.txt"
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
		del info.sys >nul 2>&1	
		pause & (goto start)
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

IF ERRORLEVEL 1 set @pfs_pops=yes
IF ERRORLEVEL 2 set @pfs_pops=NO
IF ERRORLEVEL 2 (goto start)
"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo\
echo POPS Binaries MD5 CHECKING:
echo ----------------------------------------------------
set "file=%~dp0POPS-Binaries\POPS.ELF"
if not exist "%file%" (goto notfound)
call "%~dp0BAT\md5.bat" "%file%" md5 !md5!

if %md5% equ 355a892a8ce4e4a105469d4ef6f39a42 (
  "%~dp0BAT\Diagbox" gd 0a
   echo POPS.ELF     - MD5 Match : !md5!
  goto checkIOP
) else (
"%~dp0BAT\Diagbox" gd 0c
  echo POPS.ELF     - MD5 Does not match : !md5!
  goto checkIOP
  )
  
:check2POPS
set "file=%~dp0POPS-Binaries\POPS.ELF"
call "%~dp0BAT\md5.bat" "%file%" md5 %md5%

if %md5% equ 355a892a8ce4e4a105469d4ef6f39a42 (
  echo\ 
  goto matchALL
) else (
  goto notfound)
  
:checkIOP
set "file=%~dp0POPS-Binaries\IOPRP252.IMG"
if not exist "%file%" (goto notfound)
call "%~dp0BAT\md5.bat" "%file%" md5 !md5!

if %md5% equ 1db9c6020a2cd445a7bb176a1a3dd418 (
  "%~dp0BAT\Diagbox" gd 0a
   echo IOPRP252.IMG - MD5 Match : !md5!
  goto check2POPS
) else (
"%~dp0BAT\Diagbox" gd 0c
echo IOPRP252.IMG - MD5 Does not match : !md5!
"%~dp0BAT\Diagbox" gd 0f
  goto notfound)

pause & (goto start)

:notfound
"%~dp0BAT\Diagbox" gd 0c
echo\
echo BINARIES POPS NOT DETECTED IN POPS-Binaries FOLDER
echo\
echo YOU NEED TO FIND THESE FILES FOR POPSTARTER WORKS!
echo\
"%~dp0BAT\Diagbox" gd 07
echo POPS.ELF     - MD5 : 355a892a8ce4e4a105469d4ef6f39a42
echo IOPRP252.IMG - MD5 : 1db9c6020a2cd445a7bb176a1a3dd418
echo\

pause & (goto start)

:matchALL
"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Detecting __common Partition:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 07

    echo device !@hdl_path! > "%~dp0TMP\pfs-prt.txt"
    echo ls >> "%~dp0TMP\pfs-prt.txt"
    echo exit >> "%~dp0TMP\pfs-prt.txt"
    type "%~dp0TMP\pfs-prt.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" tee > "%~dp0TMP\pfs-prt.log"
    "%~dp0BAT\busybox" cat "%~dp0TMP\pfs-prt.log" | "%~dp0BAT\busybox" grep "__common" | "%~dp0BAT\busybox" sed "s/.*__common/__common/" | "%~dp0BAT\busybox" tr -d " " | "%~dp0BAT\busybox" head -1 > "%~dp0TMP\hdd-prt.txt"
    set /P @hdd_avl=<"%~dp0TMP\hdd-prt.txt"
    REM del "%~dp0TMP\pfs-prt.txt" "%~dp0TMP\pfs-prt.log" >nul 2>&1 "%~dp0TMP\hdd-prt.txt"
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
	del info.sys >nul 2>&1
	
	pause & (goto start)
	
	)
)

echo\
echo\
pause
cls
"%~dp0BAT\Diagbox" gd 0f
IF %@pfs_pops%==yes (
echo\
echo\
echo Installing POPS Binaries:
echo ----------------------------------------------------
echo\
REM POPS BINARIES
"%~dp0BAT\Diagbox" gd 07

IF /I EXIST "%~dp0POPS-Binaries\*" (

	cd "%~dp0POPS-Binaries"
	echo         Creating Que
	echo device !@hdl_path! > "%~dp0TMP\pfs-pops-binaries.txt"
	echo mount __common >> "%~dp0TMP\pfs-pops-binaries.txt"
	echo mkdir POPS >> "%~dp0TMP\pfs-pops-binaries.txt"
	echo cd POPS >> "%~dp0TMP\pfs-pops-binaries.txt"
	for %%f in (POPS.ELF IOPRP252.IMG POPSTARTER.ELF TROJAN_7.BIN *.TM2) do (echo put "%%f") >> "%~dp0TMP\pfs-pops-binaries.txt"
	echo umount >> "%~dp0TMP\pfs-pops-binaries.txt"
	echo exit >> "%~dp0TMP\pfs-pops-binaries.txt"
	
	echo         Installing Que
	type "%~dp0TMP\pfs-pops-binaries.txt" | "%~dp0BAT\pfsshell" >nul 2>&1
	del "%~dp0TMP\pfs-pops-binaries.txt" >nul 2>&1
	
	echo         Creating Log
	echo device !@hdl_path! > "%~dp0TMP\pfs-log.txt"
	echo mount __common >> "%~dp0TMP\pfs-log.txt"
	echo cd POPS >> "%~dp0TMP\pfs-log.txt"
	echo ls >> "%~dp0TMP\pfs-log.txt"
	echo umount >> "%~dp0TMP\pfs-log.txt"
	echo exit >> "%~dp0TMP\pfs-log.txt"
	type "%~dp0TMP\pfs-log.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" tee > "%~dp0TMP\pfs-tmp.log"
	mkdir "%~dp0LOG" >nul 2>&1
	"%~dp0BAT\busybox" grep -i -e ".ELF" -e ".IMG" -e ".BIN" -e ".TM2" "%~dp0TMP\pfs-tmp.log" > "%~dp0LOG\PFS-POPS-Binaries.log"
	echo         POPS Binaries Completed...	
	cd "%~dp0"


REM POPS FOR OPL APPS
REM	echo         Creating Que
    cd "%~dp0POPS-Binaries"
	echo device !@hdl_path! > "%~dp0TMP\pfs-pops-binaries.txt"
	echo mount +OPL >> "%~dp0TMP\pfs-pops-binaries.txt"
	echo mkdir POPS >> "%~dp0TMP\pfs-pops-binaries.txt"
	echo cd POPS >> "%~dp0TMP\pfs-pops-binaries.txt"
	for %%g in (POPSTARTER.ELF) do (echo put "%%g") >> "%~dp0TMP\pfs-pops-binaries.txt"
	echo umount >> "%~dp0TMP\pfs-pops-binaries.txt"
	echo exit >> "%~dp0TMP\pfs-pops-binaries.txt"
REM	echo         Installing Que
	type "%~dp0TMP\pfs-pops-binaries.txt" | "%~dp0BAT\pfsshell" >nul 2>&1
	cd "%~dp0"
	) else ( echo         POPS Binaries - Source Not Detected... )
)

rmdir /Q/S "%~dp0TMP" >nul 2>&1
del info.sys >nul 2>&1

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo ----------------------------------------------------
 "%~dp0BAT\Diagbox" gd 0a
echo Installation Completed...
echo\
echo\
"%~dp0BAT\Diagbox" gd 07

pause & (goto start)

REM ########################################################################################################################################################################
:BackupPS2Games

mkdir "%~dp0CD-DVD" >nul 2>&1

copy "%~dp0BAT\hdl_dump.exe" "%~dp0CD-DVD\hdl_dump.exe"
copy "%~dp0BAT\hdl_svr_093.elf" "%~dp0CD-DVD"

cd /d "%~dp0CD-DVD"
cls

"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning HDDs:
echo ----------------------------------------------------
    "%~dp0BAT\Diagbox" gd 03
	"%~dp0BAT\hdl_dump" query | findstr "Playstation"
	"%~dp0BAT\Diagbox" gd 07
    echo.
    echo ----------------------------------------------------
    "%~dp0BAT\Diagbox" gd 06
	echo NOTE: If no PS2 HDDs are found, quit and retry after disconnecting
	echo all disk drives EXCEPT for your PC boot drive and the PS2 HDDs.
	"%~dp0BAT\Diagbox" gd 0f
	echo.
	echo. 
	echo PLAYSTATION 2 HDD Extraction
	echo 	1. hdd1: 
	echo 	2. hdd2:
	echo 	3. hdd3:
	echo 	4. hdd4: 
	echo 	5. hdd5:
	echo 	6. hdd6:
	echo 	7. Network
	echo 	8. Quit Program
	choice /c 12345678 /m "Choice the number of your PS2 HDD."	
	    
		if errorlevel 8 (goto start)
		if errorlevel 1 set hdlhdd=hdd1:
		if errorlevel 2 set hdlhdd=hdd2:
		if errorlevel 3 set hdlhdd=hdd3:
		if errorlevel 4 set hdlhdd=hdd4:
		if errorlevel 5 set hdlhdd=hdd5:
		if errorlevel 6 set hdlhdd=hdd6:
		if errorlevel 7 (goto extractnetwork)

cls
"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Prepare HDD for extraction:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | findstr "%hdlhdd%"
(goto extract)

:extractnetwork
cls
"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Prepare HDD Network for extraction:
echo ----------------------------------------------------
echo.
     "%~dp0BAT\Diagbox" gd 0f
     set /p "hdlhdd=Enter IP of the Playstation 2: "
     ping -n 1 -w 2000 !hdlhdd!
     if errorlevel 1 (
     "%~dp0BAT\Diagbox" gd 0c
     	echo Unable to ping !hdlhdd! ... ending script.
     	"%~dp0BAT\Diagbox" gd 07
		echo.
		pause & (goto BackupPS2Games)
     	)
		
:extract
echo\
echo\
"%~dp0BAT\Diagbox" gd 0f
echo Extract All .ISO ?
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1) %YES%
"%~dp0BAT\Diagbox" gd 0c
echo         2) %NO%
"%~dp0BAT\Diagbox" gd 07
echo\
CHOICE /C 12 /M "Select Option:"

IF ERRORLEVEL 2 (goto BackupPS2Games)

"%~dp0BAT\Diagbox" gd 0e
cls
echo\
echo\
echo Extraction iso...
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
setlocal DisableDelayedExpansion

hdl_dump hdl_toc %hdlhdd% > .PARTITION_GAMES.txt

more +1 .PARTITION_GAMES.txt >file.txt
move /y file.txt PARTITION_GAMES_NEW.txt >nul

"%~dp0BAT\busybox" sed -i -e "$ d" PARTITION_GAMES_NEW.txt"
type PARTITION_GAMES_NEW.txt"
"%~dp0BAT\Diagbox" gd 0e
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03

For %%Z in (PARTITION_GAMES_NEW.txt) do (
 (for /f "tokens=2,5*" %%A in (%%Z) do echo hdl_dump.exe extract %hdlhdd% "%%C" %%B.iso) > PARTITION_GAMES_NEW.bat)
 
echo on & call PARTITION_GAMES_NEW.bat

@echo off
"%~dp0BAT\busybox" sed -i "s/\"//g" "%~dp0CD-DVD\PARTITION_GAMES_NEW.txt"

For %%Z in (PARTITION_GAMES_NEW.txt) do (
 (for /f "tokens=2,5*" %%A in (%%Z) do echo ren %%B.iso "%%C.iso") > RenameISO.bat)
 
"%~dp0BAT\busybox" sed -i "s/:/-/g; s/?//g; s/\!//g; s/\\//g; s/\///g; s/\*//g; s/>//g; s/<//g" "%~dp0CD-DVD\RenameISO.bat"
"%~dp0BAT\busybox" sed -i "s/|//g" "%~dp0CD-DVD\RenameISO.bat"

REM Old 
REM setlocal enabledelayedexpansion
REM 
REM set "FileName=Rename.txt"
REM set "OutFile=RenameISO.bat"
REM (
REM for /f "usebackq delims=*" %%a IN ("%FileName%") DO (
REM  set "line=%%a"
REM  set "line=!line::=-!"
REM  set "line=!line:?=-!"
REM  set "line=!line:/=-!"
REM  set "line=!line:\=-!"
REM  set "line=!line:>=-!"
REM  set "line=!line:<=-!"
REM  echo !line!
REM )
REM )>"%OutFile%"

ren *. *.iso >nul 2>&1
call RenameISO.bat

del gameid.txt >nul 2>&1
del hdl_dump.exe >nul 2>&1
del hdl_svr_093.elf >nul 2>&1
del boot.kelf >nul 2>&1
del PARTITION_GAMES_NEW.txt >nul 2>&1
del PARTITION_GAMES_NEW.bat >nul 2>&1
del Rename.txt >nul 2>&1
del RenameISO.bat >nul 2>&1

echo\
echo\
"%~dp0BAT\Diagbox" gd 0f
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo Extraction Completed...
echo\
echo\
"%~dp0BAT\Diagbox" gd 07

pause & (goto start)

REM  For HDL_DUMP_093
REM For %%Z in (PARTITION_GAMES_NEW.txt") do (
REM  (for /f "tokens=2-4*" %%A in (%%Z) do echo hdl_dump.exe extract "%%D" %%C.iso) > "PARTITION_GAMES_NEW.bat")
REM 
REM For %%Z in (PARTITION_GAMES_NEW.txt") do (
REM  (for /f "tokens=2-4*" %%A in (%%Z) do echo ren %%C.iso "%%D.iso") > "Rename.txt")

REM ####################################################################################################################################################
:CreatePART

mkdir "%~dp0TMP" >nul 2>&1
"%~dp0BAT\Diagbox" gd 0e
cls
echo\
echo\
echo Scanning for Playstation 2 HDDs:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | findstr "hdd" | "%~dp0BAT\busybox" grep "Playstation 2 HDD"
"%~dp0BAT\hdl_dump" query | findstr "hdd" | "%~dp0BAT\busybox" grep "Playstation 2 HDD" | "%~dp0BAT\busybox" cut -c2-6 > "%~dp0TMP\hdl-hdd.txt"
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
		del info.sys >nul 2>&1
        pause & (goto HDDManagementMenu)
	)

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\

echo Create Partition:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1) %YES%
"%~dp0BAT\Diagbox" gd 0c
echo         2) %NO%
"%~dp0BAT\Diagbox" gd 07
echo\
CHOICE /C 12 /M "Select Option:"

IF ERRORLEVEL 1 set @pfs_part=yes
IF ERRORLEVEL 2 set @pfs_part=no

IF %@pfs_part%==yes (
echo.
echo Example: +OPL
echo.
set /p "partname=Enter partition Name:" 

echo.
echo.
echo The size must be multiplied by 128
echo Example size: "(Max size per partition 128GB)" 
echo.
echo 128mb = 128
echo 256mb = 256
echo 384mb = 384
echo 512mb = 512
echo.
set /p "partsize=Enter partition size:" 
)

cls
IF %@pfs_part%==yes (
echo\
echo\
echo Creating %partname% Partition:
echo ----------------------------------------------------
echo\

    echo        Creating partitions...
  	echo device %@hdl_path% > "%~dp0TMP\pfs-log.txt"
	echo mkpart %partname% %partsize% >> "%~dp0TMP\pfs-log.txt"
	echo mkfs %partname% >> "%~dp0TMP\pfs-log.txt"
  	echo exit >> "%~dp0TMP\pfs-log.txt"
	type "%~dp0TMP\pfs-log.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" tee > "%~dp0TMP\pfs-tmp.log"
	echo        partition %partname% completed...
	
	) else ( echo          Canceled... )

rmdir /Q/S "%~dp0TMP" >nul 2>&1
del info.sys >nul 2>&1

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
"%~dp0BAT\hdl_dump" query | findstr "hdd" | "%~dp0BAT\busybox" grep "Playstation 2 HDD"
"%~dp0BAT\hdl_dump" query | findstr "hdd" | "%~dp0BAT\busybox" grep "Playstation 2 HDD" | "%~dp0BAT\busybox" cut -c2-6 > "%~dp0TMP\hdl-hdd.txt"
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
		del info.sys >nul 2>&1
	    pause & (goto HDDManagementMenu)
	)
	
"%~dp0BAT\Diagbox" gd 0f
echo\
echo\

echo Scan Partition:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1) %YES%
"%~dp0BAT\Diagbox" gd 0c
echo         2) %NO%
"%~dp0BAT\Diagbox" gd 07
echo\
CHOICE /C 12 /M "Select Option:"

IF ERRORLEVEL 1 set @pfs_partdel=yes
IF ERRORLEVEL 2 set @pfs_partdel=no

IF %@pfs_partdel%==yes (
echo\
echo\
echo Partition List:
echo ----------------------------------------------------
    echo device %@hdl_path% > "%~dp0TMP\pfs-prt.txt"
    echo ls >> "%~dp0TMP\pfs-prt.txt"
    echo exit >> "%~dp0TMP\pfs-prt.txt"
    type "%~dp0TMP\pfs-prt.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" tee > "%~dp0TMP\pfs-prt.log"
    "%~dp0BAT\busybox" cat "%~dp0TMP\pfs-prt.log" | "%~dp0BAT\busybox" grep -e "0x0100" -e "0x0001" > "%~dp0TMP\hdd-prt.txt"
	type "%~dp0TMP\hdd-prt.txt"
echo ----------------------------------------------------
	echo.
    set /p "partnamedel=Enter the partition name you want to delete:" 
	"%~dp0BAT\Diagbox" gd 07
	)

cls
IF %@pfs_partdel%==yes (
echo\
echo\
echo Deleting %partnamedel% Partition:
echo ----------------------------------------------------
echo\

    echo        Deleting partitions...
  	echo device %@hdl_path% > "%~dp0TMP\pfs-log.txt"
	echo rmpart %partnamedel% >> "%~dp0TMP\pfs-log.txt"
  	echo exit >> "%~dp0TMP\pfs-log.txt"
	type "%~dp0TMP\pfs-log.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" tee > "%~dp0TMP\pfs-tmp.log"
	echo        Partition %partnamedel% Deleted...	
	) else ( echo          Canceled... )

rmdir /Q/S "%~dp0TMP" >nul 2>&1
del info.sys >nul 2>&1

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
:BlankPART

cls
mkdir "%~dp0TMP" >nul 2>&1
"%~dp0BAT\Diagbox" gd 0e

echo\
echo\
echo Scanning for Playstation 2 HDDs:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | findstr "hdd" | "%~dp0BAT\busybox" grep "Playstation 2 HDD"
"%~dp0BAT\hdl_dump" query | findstr "hdd" | "%~dp0BAT\busybox" grep "Playstation 2 HDD" | "%~dp0BAT\busybox" cut -c2-6 > "%~dp0TMP\hdl-hdd.txt"
"%~dp0BAT\busybox" sed -i "s/hdd/\\\\.\\\PhysicalDrive/g; s/://g" "%~dp0TMP\hdl-hdd.txt"

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
		del info.sys >nul 2>&1
		pause & (goto HDDManagementMenu)
	)
	
"%~dp0BAT\Diagbox" gd 0f
echo\
echo\

echo Scan Partition:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1) %YES%
"%~dp0BAT\Diagbox" gd 0c
echo         2) %NO%
"%~dp0BAT\Diagbox" gd 07
echo\
CHOICE /C 12 /M "Select Option:"

IF ERRORLEVEL 1 set @pfs_partblank=yes
IF ERRORLEVEL 2 set @pfs_partblank=no

IF %@pfs_partblank%==yes (
echo\
echo\
echo Partition List:
echo ----------------------------------------------------
    echo device %@hdl_path% > "%~dp0TMP\pfs-prt.txt"
    echo ls >> "%~dp0TMP\pfs-prt.txt"
    echo exit >> "%~dp0TMP\pfs-prt.txt"
    type "%~dp0TMP\pfs-prt.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" tee > "%~dp0TMP\pfs-prt.log"
    "%~dp0BAT\busybox" cat "%~dp0TMP\pfs-prt.log" | "%~dp0BAT\busybox" grep -e "0x0100" -e "0x0001" > "%~dp0TMP\hdd-prt.txt"
	type "%~dp0TMP\hdd-prt.txt"
echo ----------------------------------------------------
	echo.
    set /p "partnameblank=Enter the partition name you want to blank:" 
	"%~dp0BAT\Diagbox" gd 07
	)

cls
IF %@pfs_partblank%==yes (
echo\
echo\
echo Blank %partnameblank% Partition:
echo ----------------------------------------------------
echo\

    echo        Blank partitions...
  	echo device %@hdl_path% > "%~dp0TMP\pfs-log.txt"
	echo mkfs %partnameblank% >> "%~dp0TMP\pfs-log.txt"
  	echo exit >> "%~dp0TMP\pfs-log.txt"
	type "%~dp0TMP\pfs-log.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" tee > "%~dp0TMP\pfs-tmp.log"
	echo        Partition %partnameblank% Empty...	
	) else ( echo          Canceled... )

rmdir /Q/S "%~dp0TMP" >nul 2>&1
del info.sys >nul 2>&1

echo\
echo\
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo Partition Completed...
echo\
echo\
"%~dp0BAT\Diagbox" gd 07

pause & (goto HDDManagementMenu)
REM #######################################################################################################################################################################################
:partitionlist

cls
mkdir "%~dp0TMP" >nul 2>&1
"%~dp0BAT\Diagbox" gd 0e

echo\
echo\
echo Scanning for Playstation 2 HDDs:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | findstr "hdd" | "%~dp0BAT\busybox" grep "Playstation 2 HDD"
"%~dp0BAT\hdl_dump" query | findstr "hdd" | "%~dp0BAT\busybox" grep "Playstation 2 HDD" | "%~dp0BAT\busybox" cut -c2-6 > "%~dp0TMP\hdl-hdd.txt"
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
		del info.sys >nul 2>&1
        pause & (goto HDDManagementMenu)
	)
	
"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Partition List:
echo ----------------------------------------------------
    echo device %@hdl_path% > "%~dp0TMP\pfs-prt.txt"
    echo ls >> "%~dp0TMP\pfs-prt.txt"
    echo exit >> "%~dp0TMP\pfs-prt.txt"
    type "%~dp0TMP\pfs-prt.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" tee > "%~dp0TMP\pfs-prt.log"
    "%~dp0BAT\busybox" cat "%~dp0TMP\pfs-prt.log" | "%~dp0BAT\busybox" grep -e "0x0100" -e "0x0001" > "%~dp0TMP\hdd-prt.txt"
	type "%~dp0TMP\hdd-prt.txt"
echo ----------------------------------------------------
	
rmdir /Q/S "%~dp0TMP" >nul 2>&1
del info.sys >nul 2>&1

echo.
pause & (goto HDDManagementMenu) 

REM #######################################################################################################################################
:partitionGAMElist

cls
mkdir "%~dp0TMP" >nul 2>&1
mkdir "%~dp0LOG" >nul 2>&1
"%~dp0BAT\Diagbox" gd 0e

echo\
echo\
echo Scanning for Playstation 2 HDDs:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | findstr "hdd" | "%~dp0BAT\busybox" grep "Playstation 2 HDD"
"%~dp0BAT\hdl_dump" query | findstr "hdd" | "%~dp0BAT\busybox" grep "Playstation 2 HDD" | "%~dp0BAT\busybox" cut -c2-6 > "%~dp0TMP\hdl-hdd.txt"

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
		del info.sys >nul 2>&1     
		pause & (goto HDDManagementMenu)
	)
	
"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Partition Games List:
echo ----------------------------------------------------

    "%~dp0BAT\hdl_dump" toc %@hdl_path% > "%~dp0TMP\PARTITION_GAMES.txt"
	"%~dp0BAT\busybox" cat "%~dp0TMP\PARTITION_GAMES.txt" | "%~dp0BAT\busybox" grep -e "0x1337" | "%~dp0BAT\busybox" cut -c23-250> "%~dp0LOG\PARTITION_GAMES.txt"
	type "%~dp0LOG\PARTITION_GAMES.txt"
	
rmdir /Q/S "%~dp0TMP" >nul 2>&1
del info.sys >nul 2>&1

echo.

pause & (goto HDDManagementMenu) 

REM #######################################################################################################################################
:DIAGPARTERROR

cls
mkdir "%~dp0TMP" >nul 2>&1
mkdir "%~dp0LOG" >nul 2>&1
"%~dp0BAT\Diagbox" gd 0e

echo\
echo\
echo Scanning for Playstation 2 HDDs:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | findstr "hdd" | "%~dp0BAT\busybox" grep "Playstation 2 HDD"
"%~dp0BAT\hdl_dump" query | findstr "hdd" | "%~dp0BAT\busybox" grep "Playstation 2 HDD" | "%~dp0BAT\busybox" cut -c2-6 > "%~dp0TMP\hdl-hdd.txt"

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
		del info.sys >nul 2>&1    
		pause & (goto HDDManagementMenu)
	)
	
"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Scanning Partition Errors:
"%~dp0BAT\Diagbox" gd 06
echo.
echo NOTE: If nothing appears there is no error in the partitions
echo.
"%~dp0BAT\Diagbox" gd 0f
echo ----------------------------------------------------

    "%~dp0BAT\hdl_dump" diag %@hdl_path% > "%~dp0LOG\PARTITION_SCAN_ERROR.txt"
	type "%~dp0LOG\PARTITION_SCAN_ERROR.txt"
	
rmdir /Q/S "%~dp0TMP" >nul 2>&1
del info.sys >nul 2>&1

echo.

pause & (goto HDDManagementMenu) 

REM ###########################################################################################################################################################################################
:formatHDDtoPS2

cls
"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning HDDs:
echo ----------------------------------------------------
    "%~dp0BAT\Diagbox" gd 03
	"%~dp0BAT\hdl_dump" query | findstr "hdd1: hdd2: hdd3: hdd4: hdd5: hdd6:"
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
	echo. 
	"%~dp0BAT\Diagbox" gd 07
	echo PLAYSTATION 2 HDD FORMAT
	echo 	1. hdd1: 
	echo 	2. hdd2:
	echo 	3. hdd3:
	echo 	4. hdd4: 
	echo 	5. hdd5:
	echo 	6. hdd6:
	echo 	7. Quit Program
	choice /c 1234567 /m "Select your HDD you want to format."	
	
	if errorlevel 1 set hdlhdd=hdd1:
	if errorlevel 2 set hdlhdd=hdd2:
	if errorlevel 3 set hdlhdd=hdd3:
	if errorlevel 4 set hdlhdd=hdd4:
	if errorlevel 5 set hdlhdd=hdd5:
	if errorlevel 6 set hdlhdd=hdd6:
	if errorlevel 7 (goto HDDManagementMenu)

mkdir "%~dp0TMP" >nul 2>&1
"%~dp0BAT\Diagbox" gd 00
echo\
echo\
echo Prepare HDD for formatting: >nul 2>&1
echo ---------------------------------------------------- >nul 2>&1
"%~dp0BAT\hdl_dump" query | findstr "%hdlhdd%"
"%~dp0BAT\hdl_dump" query | findstr "%hdlhdd%" | "%~dp0BAT\busybox" cut -c2-6 > "%~dp0TMP\hdl-hdd.txt"
"%~dp0BAT\busybox" sed -i "s/hdd/\\\\.\\\PhysicalDrive/g; s/://g" "%~dp0TMP\hdl-hdd.txt"

set /P @hdl_path=<"%~dp0TMP\hdl-hdd.txt"

copy "%~dp0TMP\hdl-hdd.txt" "%~dp0TMP\hdl-hddinfo.txt" >nul 2>&1
"%~dp0BAT\busybox" sed -i "s/\\\\.\\\PhysicalDrive/PHYSICALDRIVE/g; s/://g" "%~dp0TMP\hdl-hddinfo.txt"

set /P @hdl_pathinfo=<"%~dp0TMP\hdl-hddinfo.txt"

REM del "%~dp0TMP\hdl-hdd.txt" >nul 2>&1
cls
"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo HDD Selected:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | findstr "%hdlhdd%"
"%~dp0BAT\Diagbox" gd 0f
echo.

    wmic diskdrive get name,model,status > "%~dp0TMP\hdl-hddinfolog.txt"
    type "%~dp0TMP\hdl-hddinfolog.txt" | findstr "Model %@hdl_pathinfo%"
	
"%~dp0BAT\Diagbox" gd 0c	
echo\
echo\
echo Are you sure you want to format this hard drive to PS2 format ?:
"%~dp0BAT\Diagbox" gd 0f
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1) %YES%
"%~dp0BAT\Diagbox" gd 0c
echo         2) %NO%
"%~dp0BAT\Diagbox" gd 07
echo\
CHOICE /C 12 /M "Select Option:"

IF ERRORLEVEL 1 set @pfs_formathdd=yes
IF ERRORLEVEL 2 set @pfs_formathdd=no
IF ERRORLEVEL 2 (goto formatHDDtoPS2)

echo.

CHOICE /C YN /m "Confirm"
IF ERRORLEVEL 2 (goto formatHDDtoPS2)

cls
IF %@pfs_formathdd%==yes (
echo\
echo\
echo Formatting HDD:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | findstr "%hdlhdd%"
"%~dp0BAT\Diagbox" gd 0f
echo\

    echo         Formatting in Progress...
	echo device %@hdl_path% > "%~dp0TMP\pfs-log.txt"
    echo initialize yes >> "%~dp0TMP\pfs-log.txt"
  	echo exit >> "%~dp0TMP\pfs-log.txt"
	type "%~dp0TMP\pfs-log.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" tee > "%~dp0TMP\pfs-tmp.log"
	
	echo %@hdl_path% > "%~dp0TMP\disk-log.txt"
	"%~dp0BAT\busybox" sed -i "s/\\\\.\\\PhysicalDrive/select disk /g" "%~dp0TMP\disk-log.txt"
	echo offline disk >> "%~dp0TMP\disk-log.txt"
	type "%~dp0TMP\disk-log.txt" | "diskpart" >nul 2>&1
	
	echo %@hdl_path% > "%~dp0TMP\disk-log.txt"
	"%~dp0BAT\busybox" sed -i "s/\\\\.\\\PhysicalDrive/select disk /g" "%~dp0TMP\disk-log.txt"
	echo online disk >> "%~dp0TMP\disk-log.txt"
	type "%~dp0TMP\disk-log.txt" | "diskpart" >nul 2>&1
	
	echo device %@hdl_path% > "%~dp0TMP\pfs-log.txt"
    echo initialize yes >> "%~dp0TMP\pfs-log.txt"
    echo         Generating PFS filesystem for system partitions...
    echo mkfs __net >> "%~dp0TMP\pfs-log.txt"
    echo mkfs __sysconf >> "%~dp0TMP\pfs-log.txt"
    echo mkfs __system >> "%~dp0TMP\pfs-log.txt"
    echo mkfs __common >> "%~dp0TMP\pfs-log.txt"
REM echo mkpart +OPL 256 >> "%~dp0TMP\pfs-log.txt"
REM echo mkfs +OPL >> "%~dp0TMP\pfs-log.txt"
  	echo exit >> "%~dp0TMP\pfs-log.txt"
	type "%~dp0TMP\pfs-log.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" tee > "%~dp0TMP\pfs-tmp.log"
	echo         Formatting HDD completed...
	
	) else ( echo          HDD - Not Detected... )

rmdir /Q/S "%~dp0TMP" >nul 2>&1
del info.sys >nul 2>&1

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
"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning HDDs:
echo ----------------------------------------------------
    "%~dp0BAT\Diagbox" gd 03
	"%~dp0BAT\hdl_dump" query | findstr "hdd1: hdd2: hdd3: hdd4: hdd5: hdd6:"
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
	echo. 
	"%~dp0BAT\Diagbox" gd 07
	echo PLAYSTATION 2 HDD
	echo 	1. hdd1: 
	echo 	2. hdd2:
	echo 	3. hdd3:
	echo 	4. hdd4: 
	echo 	5. hdd5:
	echo 	6. hdd6:
	echo 	7. Quit Program
	choice /c 1234567 /m "Select your HDD you want to hack."	
	
	if errorlevel 1 set hdlhdd=hdd1:
	if errorlevel 2 set hdlhdd=hdd2:
	if errorlevel 3 set hdlhdd=hdd3:
	if errorlevel 4 set hdlhdd=hdd4:
	if errorlevel 5 set hdlhdd=hdd5:
	if errorlevel 6 set hdlhdd=hdd6:
	if errorlevel 7 (goto HDDManagementMenu)

mkdir "%~dp0TMP" >nul 2>&1
"%~dp0BAT\Diagbox" gd 00
echo\
echo\
echo Prepare HDD for formatting: >nul 2>&1
echo ---------------------------------------------------- >nul 2>&1
"%~dp0BAT\hdl_dump" query | findstr "%hdlhdd%"
"%~dp0BAT\hdl_dump" query | findstr "%hdlhdd%" | "%~dp0BAT\busybox" cut -c2-6 > "%~dp0TMP\hdl-hdd.txt"
"%~dp0BAT\busybox" sed -i "s/hdd/\\\\.\\\PhysicalDrive/g; s/://g" "%~dp0TMP\hdl-hdd.txt"

set /P @hdl_path=<"%~dp0TMP\hdl-hdd.txt"

copy "%~dp0TMP\hdl-hdd.txt" "%~dp0TMP\hdl-hddinfo.txt" >nul 2>&1
"%~dp0BAT\busybox" sed -i "s/\\\\.\\\PhysicalDrive/PHYSICALDRIVE/g; s/://g" "%~dp0TMP\hdl-hddinfo.txt"

set /P @hdl_pathinfo=<"%~dp0TMP\hdl-hddinfo.txt"

REM del "%~dp0TMP\hdl-hdd.txt" >nul 2>&1
cls
"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo HDD Selected:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | findstr "%hdlhdd%"
"%~dp0BAT\Diagbox" gd 0f
echo.

    wmic diskdrive get name,model,status > "%~dp0TMP\hdl-hddinfolog.txt"
    type "%~dp0TMP\hdl-hddinfolog.txt" | findstr "Model %@hdl_pathinfo%"

"%~dp0BAT\Diagbox" gd 0c 
echo\
echo\
echo Are you sure you want to HACK this hard drive ? this is irreversible:
echo.
echo (1) After the hacking put your HDD in your PS2 and format your hard drive with wLaunchELF
echo.
echo (2) Install FreeMcBoot (From Memory Card) or FreeHDBoot (From HDD) or both 
echo.
echo (3) Your hard drive will be properly formatted and hacked after that
echo.
echo (4) Have Fun
echo.
"%~dp0BAT\Diagbox" gd 0f
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1) %YES%
"%~dp0BAT\Diagbox" gd 0c
echo         2) %NO%
"%~dp0BAT\Diagbox" gd 07
echo\
CHOICE /C 12 /M "Select Option:"

IF ERRORLEVEL 1 set @pfs_hackhdd=yes
IF ERRORLEVEL 2 set @pfs_hackhdd=no
IF ERRORLEVEL 2 (goto hackHDDtoPS2)

echo.

CHOICE /C YN /m "Confirm"
IF ERRORLEVEL 2 (goto hackHDDtoPS2)


cls
IF %@pfs_hackhdd%==yes (
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
	
	) else ( echo          HDD - Not Detected... )

rmdir /Q/S "%~dp0TMP" >nul 2>&1
del info.sys >nul 2>&1

echo\
echo\
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo Hack Completed...
echo\
echo\
"%~dp0BAT\Diagbox" gd 07

pause & (goto HDDManagementMenu)

REM ##############################################################################################################################################################
:InstallHDDOSD

cd "%~dp0"

IF NOT EXIST "%~dp0HDD-OSD\__sysconf" MD "%~dp0HDD-OSD\__sysconf"
IF NOT EXIST "%~dp0HDD-OSD\__system" MD "%~dp0"HDD-OSD\__system"

cls
echo\
echo\
echo Checking Files For HDDOSD-1.10U...
echo ----------------------------------------------------
timeout 1 >nul

REM __system\osd100\FNTOSD
if not exist "%~dp0HDD-OSD\__system\osd100\FNTOSD" (
"%~dp0BAT\Diagbox" gd 0c
echo Files "__system\osd100\FNTOSD"
echo Missing
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
)

set "file=%~dp0HDD-OSD\__system\osd100\FNTOSD"
call "%~dp0BAT\md5.bat" "%file%" md5 %md5%

if %md5% equ 17c8ec6119192ca01e949e05f6f246e4 (
"%~dp0BAT\Diagbox" gd 0e
echo Files "__system\osd100\FNTOSD"
"%~dp0BAT\Diagbox" gd 0a                    
echo %md5% Confirmed 
echo\
   ) else (
"%~dp0BAT\Diagbox" gd 0c
echo Files "__system\osd100\FNTOSD"
echo MD5 not Match Your file is probably corrupted
echo\
pause & (goto  HDDOSDMenu)
echo\
 )

REM __system\osd100\hosdsys.elf
if not exist "%~dp0HDD-OSD\__system\osd100\hosdsys.elf" (
"%~dp0BAT\Diagbox" gd 0c
echo Files "__system\osd100\hosdsys.elf"
echo Missing
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
)

set "file=%~dp0HDD-OSD\__system\osd100\hosdsys.elf"
call "%~dp0BAT\md5.bat" "%file%" md5 %md5%

if %md5% equ ca9ab553e8b51259ccf1ca4ea2d1bc00 (
"%~dp0BAT\Diagbox" gd 0e
echo Files "__system\osd100\hosdsys.elf"
"%~dp0BAT\Diagbox" gd 0a                   
echo %md5% Confirmed 
echo\
   ) else (
"%~dp0BAT\Diagbox" gd 0c
echo Files "__system\osd100\hosdsys.elf"
echo MD5 not Match Your file is probably corrupted
echo\
pause & (goto  HDDOSDMenu)
 )
 
REM __system\osd100\ICOIMAGE
if not exist "%~dp0HDD-OSD\__system\osd100\ICOIMAGE" (
"%~dp0BAT\Diagbox" gd 0c
echo Files "__system\osd100\ICOIMAGE"
echo Missing
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
)

set "file=%~dp0HDD-OSD\__system\osd100\ICOIMAGE"
call "%~dp0BAT\md5.bat" "%file%" md5 %md5%

if %md5% equ 33a3a304d2ec3892e24d7a5aab9dbc03 (
"%~dp0BAT\Diagbox" gd 0e
echo Files "__system\osd100\ICOIMAGE"
"%~dp0BAT\Diagbox" gd 0a                     
echo %md5% Confirmed 
echo\
   ) else (
"%~dp0BAT\Diagbox" gd 0c
echo Files "__system\osd100\ICOIMAGE" 
echo MD5 not Match Your file is probably corrupted
echo\
pause & (goto  HDDOSDMenu)
 )
 
REM __system\osd100\SKBIMAGE
if not exist "%~dp0HDD-OSD\__system\osd100\SKBIMAGE" (
"%~dp0BAT\Diagbox" gd 0c
echo Files "__system\osd100\SKBIMAGE"
echo Missing
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
)

set "file=%~dp0HDD-OSD\__system\osd100\SKBIMAGE"
call "%~dp0BAT\md5.bat" "%file%" md5 %md5%

if %md5% equ 99220367a205fc45e743895759e79281 (
"%~dp0BAT\Diagbox" gd 0e
echo Files "__system\osd100\SKBIMAGE"
"%~dp0BAT\Diagbox" gd 0a                     
echo %md5% Confirmed 
echo\
   ) else (
"%~dp0BAT\Diagbox" gd 0c
echo Files "__system\osd100\SKBIMAGE" 
echo MD5 not Match Your file is probably corrupted
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
 )
 
REM __system\osd100\SNDIMAGE
if not exist "%~dp0HDD-OSD\__system\osd100\SNDIMAGE" (
"%~dp0BAT\Diagbox" gd 0c
echo Files "__system\osd100\SNDIMAGE"
echo Missing
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
)

set "file=%~dp0HDD-OSD\__system\osd100\SNDIMAGE"
call "%~dp0BAT\md5.bat" "%file%" md5 %md5%

if %md5% equ 784bd4bb1e8327ef2907dfc8c574cda4 (
"%~dp0BAT\Diagbox" gd 0e
echo Files "__system\osd100\SNDIMAGE"
"%~dp0BAT\Diagbox" gd 0a                     
echo %md5% Confirmed 
echo\
   ) else (
"%~dp0BAT\Diagbox" gd 0c
echo Files "__system\osd100\SNDIMAGE"
echo MD5 not Match Your file is probably corrupted
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
 )
 
REM __system\osd100\TEXIMAGE
if not exist "%~dp0HDD-OSD\__system\osd100\TEXIMAGE" (
"%~dp0BAT\Diagbox" gd 0c
echo Files "__system\osd100\TEXIMAGE"
echo Missing
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
)

set "file=%~dp0HDD-OSD\__system\osd100\TEXIMAGE"
call "%~dp0BAT\md5.bat" "%file%" md5 %md5%

if %md5% equ 08e42817da1d2480e883851e5d88f0e5 (
"%~dp0BAT\Diagbox" gd 0e
echo Files "__system\osd100\TEXIMAGE"
"%~dp0BAT\Diagbox" gd 0a                    
echo %md5% Confirmed 
echo\
   ) else (
"%~dp0BAT\Diagbox" gd 0c
echo Files "__system\osd100\TEXIMAGE"
echo MD5 not Match Your file is probably corrupted
echo\
pause & (goto  HDDOSDMenu)
 )
 
REM __system\fsck100\FSCK_A.XLF
if not exist "%~dp0HDD-OSD\__system\fsck100\FSCK_A.XLF" (
"%~dp0BAT\Diagbox" gd 0c
echo Files "__system\osd100\FSCK_A.XLF"
echo Missing
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
)

set "file=%~dp0HDD-OSD\__system\fsck100\FSCK_A.XLF"
call "%~dp0BAT\md5.bat" "%file%" md5 %md5%

if %md5% equ 3618ec7d45413f12a13a63ceada96620 (
"%~dp0BAT\Diagbox" gd 0e
echo Files "__system\fsck100\FSCK_A.XLF"
"%~dp0BAT\Diagbox" gd 0a                   
echo %md5% Confirmed 
echo\
   ) else (
"%~dp0BAT\Diagbox" gd 0c
echo Files "__system\fsck100\FSCK_A.XLF"
echo MD5 not Match Your file is probably corrupted
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
 )
 
REM __system\fsck100\files\FILES_A.PAK
if not exist "%~dp0HDD-OSD\__system\fsck100\files\FILES_A.PAK" (
"%~dp0BAT\Diagbox" gd 0c
echo Files "__system\osd100\FSCK_A.XLF"
echo Missing
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
)

set "file=%~dp0HDD-OSD\__system\fsck100\files\FILES_A.PAK"
call "%~dp0BAT\md5.bat" "%file%" md5 %md5%

if %md5% equ c7b28caaee8c91e17ee663bdca179108 (
"%~dp0BAT\Diagbox" gd 0e
echo Files "__system\fsck100\files\FILES_A.PAK"
"%~dp0BAT\Diagbox" gd 0a          
echo %md5% Confirmed 
echo\
   ) else (
"%~dp0BAT\Diagbox" gd 0c
echo Files "__system\fsck100\files\FILES_A.PAK"
echo MD5 not Match Your file is probably corrupted
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
 )
 
REM __sysconf\CONF\FILETYPE.INI
if not exist "%~dp0HDD-OSD\__sysconf\CONF\FILETYPE.INI" (
"%~dp0BAT\Diagbox" gd 0c
echo Files "__sysconf\CONF\FILETYPE.INI"
echo Missing
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
)

set "file=%~dp0HDD-OSD\__sysconf\CONF\FILETYPE.INI"
call "%~dp0BAT\md5.bat" "%file%" md5 %md5%

if %md5% equ 3b0c10c058f0f630973dd07db2ea8860 (
"%~dp0BAT\Diagbox" gd 0e
echo Files "__sysconf\CONF\FILETYPE.INI"
"%~dp0BAT\Diagbox" gd 0a         
echo %md5% Confirmed 
echo\
   ) else (
"%~dp0BAT\Diagbox" gd 0c
echo Files "__sysconf\CONF\FILETYPE.INI"
echo MD5 not Match Your file is probably corrupted
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
 )
 
REM __sysconf\CONF\SYSTEM.INI
if not exist "%~dp0HDD-OSD\__sysconf\CONF\SYSTEM.INI" (
"%~dp0BAT\Diagbox" gd 0c
echo Files "__sysconf\CONF\SYSTEM.INI" 
echo Missing
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
)

set "file=%~dp0HDD-OSD\__sysconf\CONF\SYSTEM.INI"
call "%~dp0BAT\md5.bat" "%file%" md5 %md5%

if %md5% equ 895fad012365b59e47a3f563daadbb86 (
"%~dp0BAT\Diagbox" gd 0e
echo Files "__sysconf\CONF\SYSTEM.INI"
"%~dp0BAT\Diagbox" gd 0a         
echo %md5% Confirmed 
echo\
   ) else (
"%~dp0BAT\Diagbox" gd 0c
echo Files "__sysconf\CONF\SYSTEM.INI"
echo MD5 not Match Your file is probably corrupted
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
 )
 
REM __sysconf\CONF\SYSTEM101.INI
if not exist "%~dp0HDD-OSD\__sysconf\CONF\SYSTEM101.INI" (
"%~dp0BAT\Diagbox" gd 0c
echo Files "__sysconf\CONF\SYSTEM101.INI" 
echo Missing
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
)

set "file=%~dp0HDD-OSD\__sysconf\CONF\SYSTEM101.INI"
call "%~dp0BAT\md5.bat" "%file%" md5 %md5%

if %md5% equ 184207759080a81779b8e124ee340075 (
"%~dp0BAT\Diagbox" gd 0e
echo Files "__sysconf\CONF\SYSTEM101.INI"
"%~dp0BAT\Diagbox" gd 0a         
echo %md5% Confirmed 
echo\
   ) else (
"%~dp0BAT\Diagbox" gd 0c
echo Files "__sysconf\CONF\SYSTEM101.INI"
echo MD5 not Match Your file is probably corrupted
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
 )
 
REM __sysconf\CONF\SYSTEMDUT.INI
if not exist "%~dp0HDD-OSD\__sysconf\CONF\SYSTEMDUT.INI" (
"%~dp0BAT\Diagbox" gd 0c
echo Files "__sysconf\CONF\SYSTEMDUT.INI" 
echo Missing
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
)

set "file=%~dp0HDD-OSD\__sysconf\CONF\SYSTEMDUT.INI"
call "%~dp0BAT\md5.bat" "%file%" md5 %md5%

if %md5% equ 7fbbd9c08962866504d633e1e219872e (
"%~dp0BAT\Diagbox" gd 0e
echo Files "__sysconf\CONF\SYSTEMDUT.INI"
"%~dp0BAT\Diagbox" gd 0a         
echo %md5% Confirmed 
echo\
   ) else (
"%~dp0BAT\Diagbox" gd 0c
echo Files "__sysconf\CONF\SYSTEMDUT.INI"
echo MD5 not Match Your file is probably corrupted
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
 )
 
REM __sysconf\CONF\SYSTEMEUK.INI
if not exist "%~dp0HDD-OSD\__sysconf\CONF\SYSTEMEUK.INI" (
"%~dp0BAT\Diagbox" gd 0c
echo Files "__sysconf\CONF\SYSTEMEUK.INI" 
echo Missing
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
)

set "file=%~dp0HDD-OSD\__sysconf\CONF\SYSTEMEUK.INI"
call "%~dp0BAT\md5.bat" "%file%" md5 %md5%

if %md5% equ fe9a4764c855dc6fa0284efe36463680 (
"%~dp0BAT\Diagbox" gd 0e
echo Files "__sysconf\CONF\SYSTEMEUK.INI"
"%~dp0BAT\Diagbox" gd 0a          
echo %md5% Confirmed 
echo\
   ) else (
"%~dp0BAT\Diagbox" gd 0c
echo Files "__sysconf\CONF\SYSTEMEUK.INI"
echo MD5 not Match Your file is probably corrupted
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
 )
 
REM __sysconf\CONF\SYSTEMFCA.INI
if not exist "%~dp0HDD-OSD\__sysconf\CONF\SYSTEMFCA.INI" (
"%~dp0BAT\Diagbox" gd 0c
echo Files "__sysconf\CONF\SYSTEMFCA.INI" 
echo Missing
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
)

set "file=%~dp0HDD-OSD\__sysconf\CONF\SYSTEMFCA.INI"
call "%~dp0BAT\md5.bat" "%file%" md5 %md5%

if %md5% equ 1d1a89b210b1620c7530451ca3211cac (
"%~dp0BAT\Diagbox" gd 0e
echo Files "__sysconf\CONF\SYSTEMFCA.INI"
"%~dp0BAT\Diagbox" gd 0a           
echo %md5% Confirmed 
echo\
   ) else (
"%~dp0BAT\Diagbox" gd 0c
echo Files "__sysconf\CONF\SYSTEMFCA.INI"
echo MD5 not Match Your file is probably corrupted
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
 )
 
REM __sysconf\CONF\SYSTEMFRE.INI
if not exist "%~dp0HDD-OSD\__sysconf\CONF\SYSTEMFRE.INI" (
"%~dp0BAT\Diagbox" gd 0c
echo Files "__sysconf\CONF\SYSTEMFRE.INI" 
echo Missing
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
)

set "file=%~dp0HDD-OSD\__sysconf\CONF\SYSTEMFRE.INI"
call "%~dp0BAT\md5.bat" "%file%" md5 %md5%

if %md5% equ 74db7d226eba87daca9036c79928c787 (
"%~dp0BAT\Diagbox" gd 0e
echo Files "__sysconf\CONF\SYSTEMFRE.INI"   
"%~dp0BAT\Diagbox" gd 0a          
echo %md5% Confirmed 
echo\
   ) else (
"%~dp0BAT\Diagbox" gd 0c
echo Files "__sysconf\CONF\SYSTEMFRE.INI"
echo MD5 not Match Your file is probably corrupted
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
 )
 
REM __sysconf\CONF\SYSTEMGER.INI
if not exist "%~dp0HDD-OSD\__sysconf\CONF\SYSTEMGER.INI" (
"%~dp0BAT\Diagbox" gd 0c
echo Files "__sysconf\CONF\SYSTEMGER.INI" 
echo Missing
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
)

set "file=%~dp0HDD-OSD\__sysconf\CONF\SYSTEMGER.INI"
call "%~dp0BAT\md5.bat" "%file%" md5 %md5%

if %md5% equ a7eb2f27f3e8f5a3351fba38709e6384 (
"%~dp0BAT\Diagbox" gd 0e
echo Files "__sysconf\CONF\SYSTEMGER.INI"
"%~dp0BAT\Diagbox" gd 0a          
echo %md5% Confirmed 
echo\
   ) else (
"%~dp0BAT\Diagbox" gd 0c
echo Files "__sysconf\CONF\SYSTEMGER.INI"
echo MD5 not Match Your file is probably corrupted
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
 )


REM __sysconf\CONF\SYSTEMITA.INI
if not exist "%~dp0HDD-OSD\__sysconf\CONF\SYSTEMITA.INI" (
"%~dp0BAT\Diagbox" gd 0c
echo Files "__sysconf\CONF\SYSTEMITA.INI" 
echo Missing
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
)

set "file=%~dp0HDD-OSD\__sysconf\CONF\SYSTEMITA.INI"
call "%~dp0BAT\md5.bat" "%file%" md5 %md5%

if %md5% equ b0ad0dbc751369e5f4b200a62b5acbd0 (
"%~dp0BAT\Diagbox" gd 0e
echo Files "__sysconf\CONF\SYSTEMITA.INI"
"%~dp0BAT\Diagbox" gd 0a           
echo %md5% Confirmed 
echo\
   ) else (
"%~dp0BAT\Diagbox" gd 0c
echo Files "__sysconf\CONF\SYSTEMITA.INI"
echo MD5 not Match Your file is probably corrupted
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
 )
 
REM __sysconf\CONF\SYSTEMPOR.INI
if not exist "%~dp0HDD-OSD\__sysconf\CONF\SYSTEMPOR.INI" (
"%~dp0BAT\Diagbox" gd 0c
echo Files "__sysconf\CONF\SYSTEMPOR.INI" 
echo Missing
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
)

set "file=%~dp0HDD-OSD\__sysconf\CONF\SYSTEMPOR.INI"
call "%~dp0BAT\md5.bat" "%file%" md5 %md5%

if %md5% equ 215627b9bc74418a6982b9ea8e4ce786 (
"%~dp0BAT\Diagbox" gd 0e
echo Files "__sysconf\CONF\SYSTEMPOR.INI"
"%~dp0BAT\Diagbox" gd 0a          
echo %md5% Confirmed 
echo\
   ) else (
"%~dp0BAT\Diagbox" gd 0c
echo Files "__sysconf\CONF\SYSTEMPOR.INI"
echo MD5 not Match Your file is probably corrupted
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
 )

REM __sysconf\CONF\SYSTEMSPA.INI
if not exist "%~dp0HDD-OSD\__sysconf\CONF\SYSTEMSPA.INI" (
"%~dp0BAT\Diagbox" gd 0c
echo Files "__sysconf\CONF\SYSTEMSPA.INI" 
echo Missing
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
)

set "file=%~dp0HDD-OSD\__sysconf\CONF\SYSTEMSPA.INI"
call "%~dp0BAT\md5.bat" "%file%" md5 %md5%

if %md5% equ d950838548cdbe10a08a9daf3d109da8 (
"%~dp0BAT\Diagbox" gd 0e
echo Files "__sysconf\CONF\SYSTEMSPA.INI"    
"%~dp0BAT\Diagbox" gd 0a         
echo %md5% Confirmed 
echo\
   ) else (
"%~dp0BAT\Diagbox" gd 0c
echo Files "__sysconf\CONF\SYSTEMSPA.INI"
echo MD5 not Match Your file is probably corrupted
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
 )
 
REM __sysconf\FONT\SYSTEMSPA.INI
if not exist "%~dp0HDD-OSD\__sysconf\FONT\S22I646.GF" (
"%~dp0BAT\Diagbox" gd 0c
echo Files "__sysconf\FONT\S22I646.GF" 
echo Missing
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
)

set "file=%~dp0HDD-OSD\__sysconf\FONT\S22I646.GF"
call "%~dp0BAT\md5.bat" "%file%" md5 %md5%

if %md5% equ e4eb6119e6c6aaa6e948769b1a11c825 (
"%~dp0BAT\Diagbox" gd 0e
echo Files "__sysconf\FONT\S22I646.GF"
"%~dp0BAT\Diagbox" gd 0a          
echo %md5% Confirmed 
echo\
   ) else (
"%~dp0BAT\Diagbox" gd 0c
echo Files "__sysconf\FONT\S22I646.GF"
echo MD5 not Match Your file is probably corrupted
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
 )
 
REM __sysconf\FONT\S22J201.GF
if not exist "%~dp0HDD-OSD\__sysconf\FONT\S22J201.GF" (
"%~dp0BAT\Diagbox" gd 0c
echo Files "__sysconf\FONT\S22I646.GF" 
echo Missing
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
)

set "file=%~dp0HDD-OSD\__sysconf\FONT\S22J201.GF"
call "%~dp0BAT\md5.bat" "%file%" md5 %md5%

if %md5% equ 13d29bcb4c7c9b1d56a415003fae0da8 (
"%~dp0BAT\Diagbox" gd 0e
echo Files "__sysconf\FONT\S22J201.GF"      
"%~dp0BAT\Diagbox" gd 0a      
echo %md5% Confirmed 
echo\
   ) else (
"%~dp0BAT\Diagbox" gd 0c
echo Files "__sysconf\FONT\S22J201.GF"
echo MD5 not Match Your file is probably corrupted
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
 )

REM __sysconf\FONT\S22J213.GF
if not exist "%~dp0HDD-OSD\__sysconf\FONT\S22J213.GF" (
"%~dp0BAT\Diagbox" gd 0c
echo Files "__sysconf\FONT\S22J213.GF" 
echo Missing
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
)

set "file=%~dp0HDD-OSD\__sysconf\FONT\S22J213.GF"
call "%~dp0BAT\md5.bat" "%file%" md5 %md5%

if %md5% equ 0dd5bbcc387db16eb4c954be89888fcf (
"%~dp0BAT\Diagbox" gd 0e
echo Files "__sysconf\FONT\S22J213.GF"      
"%~dp0BAT\Diagbox" gd 0a      
echo %md5% Confirmed 
echo\
   ) else (
"%~dp0BAT\Diagbox" gd 0c
echo Files "__sysconf\FONT\S22J213.GF"
echo MD5 not Match Your file is probably corrupted
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
 )
 
REM __sysconf\FONT\S22ULST.GF
if not exist "%~dp0HDD-OSD\__sysconf\FONT\S22ULST.GF" (
"%~dp0BAT\Diagbox" gd 0c
echo Files "__sysconf\FONT\S22ULST.GF" 
echo Missing
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
)

set "file=%~dp0HDD-OSD\__sysconf\FONT\S22ULST.GF"
call "%~dp0BAT\md5.bat" "%file%" md5 %md5%

if %md5% equ e489297f6100819b0b9b68bc1b5181aa (
"%~dp0BAT\Diagbox" gd 0e
echo Files "__sysconf\FONT\S22ULST.GF"      
"%~dp0BAT\Diagbox" gd 0a      
echo %md5% Confirmed 
echo\
   ) else (
"%~dp0BAT\Diagbox" gd 0c
echo Files "__sysconf\FONT\S22ULST.GF"
echo MD5 not Match Your file is probably corrupted
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
 )

REM __sysconf\FONT\S26I646.GF
if not exist "%~dp0HDD-OSD\__sysconf\FONT\S26I646.GF" (
"%~dp0BAT\Diagbox" gd 0c
echo Files "__sysconf\FONT\S26I646.GF" 
echo Missing
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
)

set "file=%~dp0HDD-OSD\__sysconf\FONT\S26I646.GF"
call "%~dp0BAT\md5.bat" "%file%" md5 %md5%

if %md5% equ 26edc62c3c9cbbc0227dba1135d2bffb (
"%~dp0BAT\Diagbox" gd 0e
echo Files "__sysconf\FONT\S26I646.GF"      
"%~dp0BAT\Diagbox" gd 0a      
echo %md5% Confirmed 
echo\
   ) else (
"%~dp0BAT\Diagbox" gd 0c
echo Files "__sysconf\FONT\S26I646.GF"
echo MD5 not Match Your file is probably corrupted
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
 )

REM __sysconf\FONT\S26J201.GF
if not exist "%~dp0HDD-OSD\__sysconf\FONT\S26J201.GF" (
"%~dp0BAT\Diagbox" gd 0c
echo Files "__sysconf\FONT\S26J201.GF" 
echo Missing
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
)

set "file=%~dp0HDD-OSD\__sysconf\FONT\S26J201.GF"
call "%~dp0BAT\md5.bat" "%file%" md5 %md5%

if %md5% equ 17a03c0088d2cc48d95c40d445b2afe6 (
"%~dp0BAT\Diagbox" gd 0e
echo Files "__sysconf\FONT\S26J201.GF"      
"%~dp0BAT\Diagbox" gd 0a      
echo %md5% Confirmed
echo\
   ) else (
"%~dp0BAT\Diagbox" gd 0c
echo Files "__sysconf\FONT\S26J201.GF"
echo MD5 not Match Your file is probably corrupted
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
 )
 
REM __sysconf\FONT\S26J213.GF
if not exist "%~dp0HDD-OSD\__sysconf\FONT\S26J213.GF" (
"%~dp0BAT\Diagbox" gd 0c
echo Files "__sysconf\FONT\S26J213.GF" 
echo Missing
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
)

set "file=%~dp0HDD-OSD\__sysconf\FONT\S26J213.GF"
call "%~dp0BAT\md5.bat" "%file%" md5 %md5%

if %md5% equ 7ccb142ed25afb8f483202a9c713636c (
"%~dp0BAT\Diagbox" gd 0e
echo Files "__sysconf\FONT\S26J213.GF"      
"%~dp0BAT\Diagbox" gd 0a      
echo %md5% Confirmed
echo\
   ) else (
"%~dp0BAT\Diagbox" gd 0c
echo Files "__sysconf\FONT\S26J213.GF"
echo MD5 not Match Your file is probably corrupted
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
 )

REM __sysconf\FONT\S26ULST.GF
if not exist "%~dp0HDD-OSD\__sysconf\FONT\S26ULST.GF" (
"%~dp0BAT\Diagbox" gd 0c
echo Files "__sysconf\FONT\S26ULST.GF" 
echo Missing
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
)

set "file=%~dp0HDD-OSD\__sysconf\FONT\S26ULST.GF"
call "%~dp0BAT\md5.bat" "%file%" md5 %md5%

if %md5% equ 3ae70fdd7db7cda669b6dbfbdf8a6368 (
"%~dp0BAT\Diagbox" gd 0e
echo Files "__sysconf\FONT\S26ULST.GF"      
"%~dp0BAT\Diagbox" gd 0a      
echo %md5% Confirmed
echo\
   ) else (
"%~dp0BAT\Diagbox" gd 0c
echo Files "__sysconf\FONT\S26ULST.GF"
echo MD5 not Match Your file is probably corrupted
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
 )
 
REM __sysconf\FONT\SCE20I22.GF
if not exist "%~dp0HDD-OSD\__sysconf\FONT\SCE20I22.GF" (
"%~dp0BAT\Diagbox" gd 0c
echo Files "__sysconf\FONT\SCE20I22.GF" 
echo Missing
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
)

set "file=%~dp0HDD-OSD\__sysconf\FONT\SCE20I22.GF"
call "%~dp0BAT\md5.bat" "%file%" md5 %md5%

if %md5% equ b7be6961ba83a8f8b411b18fe30a02cc (
"%~dp0BAT\Diagbox" gd 0e
echo Files "__sysconf\FONT\SCE20I22.GF"      
"%~dp0BAT\Diagbox" gd 0a      
echo %md5% Confirmed
echo\
   ) else (
"%~dp0BAT\Diagbox" gd 0c
echo Files "__sysconf\FONT\SCE20I22.GF"
echo MD5 not Match Your file is probably corrupted
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
 )

REM __sysconf\FONT\SCE24I26.GF
if not exist "%~dp0HDD-OSD\__sysconf\FONT\SCE24I26.GF" (
"%~dp0BAT\Diagbox" gd 0c
echo Files "__sysconf\FONT\SCE24I26.GF" 
echo Missing
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
)

set "file=%~dp0HDD-OSD\__sysconf\FONT\SCE24I26.GF"
call "%~dp0BAT\md5.bat" "%file%" md5 %md5%

if %md5% equ 941335d6e6f3befe4aa7b58ef228b831 (
"%~dp0BAT\Diagbox" gd 0e
echo Files "__sysconf\FONT\SCE24I26.GF"      
"%~dp0BAT\Diagbox" gd 0a      
echo %md5% Confirmed
echo\
   ) else (
"%~dp0BAT\Diagbox" gd 0c
echo Files "__sysconf\FONT\SCE24I26.GF"
echo MD5 not Match Your file is probably corrupted
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
 )
 
REM __sysconf\ICON\ICON.SYS
if not exist "%~dp0HDD-OSD\__sysconf\ICON\ICON.SYS" (
"%~dp0BAT\Diagbox" gd 0c
echo Files "__sysconf\ICON\ICON.SYS" 
echo Missing
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
)

set "file=%~dp0HDD-OSD\__sysconf\ICON\ICON.SYS"
call "%~dp0BAT\md5.bat" "%file%" md5 %md5%

if %md5% equ b2d4de12ed4c2c80a3594b2fb3655edb (
"%~dp0BAT\Diagbox" gd 0e
echo Files "__sysconf\ICON\ICON.SYS"      
"%~dp0BAT\Diagbox" gd 0a      
echo %md5% Confirmed
echo\
   ) else (
"%~dp0BAT\Diagbox" gd 0c
echo Files "__sysconf\ICON\ICON.SYS"
echo MD5 not Match Your file is probably corrupted
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
 )
 
REM __sysconf\ICON\OTHERS.ICO
if not exist "%~dp0HDD-OSD\__sysconf\ICON\OTHERS.ICO" (
"%~dp0BAT\Diagbox" gd 0c
echo Files "__sysconf\ICON\OTHERS.ICO" 
echo Missing
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
)

set "file=%~dp0HDD-OSD\__sysconf\ICON\OTHERS.ICO"
call "%~dp0BAT\md5.bat" "%file%" md5 %md5%

if %md5% equ 737c0a56b22f3d116ab6420885754335 (
"%~dp0BAT\Diagbox" gd 0e
echo Files "__sysconf\ICON\OTHERS.ICO"      
"%~dp0BAT\Diagbox" gd 0a      
echo %md5% Confirmed
echo\
   ) else (
"%~dp0BAT\Diagbox" gd 0c
echo Files "__sysconf\ICON\OTHERS.ICO"
echo MD5 not Match Your file is probably corrupted
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
 )
 
REM __sysconf\ICON\AUDIO\AUDIO.ICO
if not exist "%~dp0HDD-OSD\__sysconf\ICON\AUDIO\AUDIO.ICO" (
"%~dp0BAT\Diagbox" gd 0c
echo Files "__sysconf\ICON\AUDIO\AUDIO.ICO" 
echo Missing
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
)

set "file=%~dp0HDD-OSD\__sysconf\ICON\AUDIO\AUDIO.ICO"
call "%~dp0BAT\md5.bat" "%file%" md5 %md5%

if %md5% equ 8c0452693ae78eaa6d8f59c364b0e338 (
"%~dp0BAT\Diagbox" gd 0e
echo Files "__sysconf\ICON\AUDIO\AUDIO.ICO"      
"%~dp0BAT\Diagbox" gd 0a      
echo %md5% Confirmed
echo\
   ) else (
"%~dp0BAT\Diagbox" gd 0c
echo Files "__sysconf\ICON\AUDIO\AUDIO.ICO"
echo MD5 not Match Your file is probably corrupted
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
 )

REM __sysconf\ICON\AUDIO\ICON.SYS
if not exist "%~dp0HDD-OSD\__sysconf\ICON\AUDIO\ICON.SYS" (
"%~dp0BAT\Diagbox" gd 0c
echo Files "__sysconf\ICON\AUDIO\ICON.SYS" 
echo Missing
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
)

set "file=%~dp0HDD-OSD\__sysconf\ICON\AUDIO\ICON.SYS"
call "%~dp0BAT\md5.bat" "%file%" md5 %md5%

if %md5% equ ef7e169fb0d3f620b80399de9437f9b5 (
"%~dp0BAT\Diagbox" gd 0e
echo Files "__sysconf\ICON\AUDIO\ICON.SYS"      
"%~dp0BAT\Diagbox" gd 0a      
echo %md5% Confirmed
echo\
   ) else (
"%~dp0BAT\Diagbox" gd 0c
echo Files "__sysconf\ICON\AUDIO\ICON.SYS"
echo MD5 not Match Your file is probably corrupted
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
 ) 


REM __sysconf\ICON\HTML\HTML.ICO
if not exist "%~dp0HDD-OSD\__sysconf\ICON\HTML\HTML.ICO" (
"%~dp0BAT\Diagbox" gd 0c
echo Files "__sysconf\ICON\HTML\HTML.ICO" 
echo Missing
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
)

set "file=%~dp0HDD-OSD\__sysconf\ICON\HTML\HTML.ICO"
call "%~dp0BAT\md5.bat" "%file%" md5 %md5%

if %md5% equ 3cb7f0536457667b87c98dfc3a9c615f (
"%~dp0BAT\Diagbox" gd 0e
echo Files "__sysconf\ICON\HTML\HTML.ICO"      
"%~dp0BAT\Diagbox" gd 0a      
echo %md5% Confirmed
echo\
   ) else (
"%~dp0BAT\Diagbox" gd 0c
echo Files "__sysconf\ICON\HTML\HTML.ICO"
echo MD5 not Match Your file is probably corrupted
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
 )

REM __sysconf\ICON\HTML\ICON.SYS
if not exist "%~dp0HDD-OSD\__sysconf\ICON\HTML\ICON.SYS" (
"%~dp0BAT\Diagbox" gd 0c
echo Files "__sysconf\ICON\HTML\ICON.SYS" 
echo Missing
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
)

set "file=%~dp0HDD-OSD\__sysconf\ICON\HTML\ICON.SYS"
call "%~dp0BAT\md5.bat" "%file%" md5 %md5%

if %md5% equ b8759abc47cf4c46f7d4c3891a44faec (
"%~dp0BAT\Diagbox" gd 0e
echo Files "__sysconf\ICON\HTML\ICON.SYS"      
"%~dp0BAT\Diagbox" gd 0a      
echo %md5% Confirmed
echo\
   ) else (
"%~dp0BAT\Diagbox" gd 0c
echo Files "__sysconf\ICON\HTML\ICON.SYS"
echo MD5 not Match Your file is probably corrupted
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
 )

REM __sysconf\ICON\IMAGE\IMAGE.ICO
if not exist "%~dp0HDD-OSD\__sysconf\ICON\IMAGE\IMAGE.ICO" (
"%~dp0BAT\Diagbox" gd 0c
echo Files "__sysconf\ICON\IMAGE\IMAGE.ICO" 
echo Missing
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
)

set "file=%~dp0HDD-OSD\__sysconf\ICON\IMAGE\IMAGE.ICO"
call "%~dp0BAT\md5.bat" "%file%" md5 %md5%

if %md5% equ f0e2c7768b367b96ff37752a39ce9cf5 (
"%~dp0BAT\Diagbox" gd 0e
echo Files "__sysconf\ICON\IMAGE\IMAGE.ICO"      
"%~dp0BAT\Diagbox" gd 0a      
echo %md5% Confirmed
echo\
   ) else (
"%~dp0BAT\Diagbox" gd 0c
echo Files "__sysconf\ICON\IMAGE\IMAGE.ICO"
echo MD5 not Match Your file is probably corrupted
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
 )

REM __sysconf\ICON\IMAGE\ICON.SYS
if not exist "%~dp0HDD-OSD\__sysconf\ICON\IMAGE\ICON.SYS" (
"%~dp0BAT\Diagbox" gd 0c
echo Files "__sysconf\ICON\IMAGE\ICON.SYS" 
echo Missing
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
)

set "file=%~dp0HDD-OSD\__sysconf\ICON\IMAGE\ICON.SYS"
call "%~dp0BAT\md5.bat" "%file%" md5 %md5%

if %md5% equ 35a674261d885a875db976900b945181 (
"%~dp0BAT\Diagbox" gd 0e
echo Files "__sysconf\ICON\IMAGE\ICON.SYS"      
"%~dp0BAT\Diagbox" gd 0a      
echo %md5% Confirmed
echo\
   ) else (
"%~dp0BAT\Diagbox" gd 0c
echo Files "__sysconf\ICON\IMAGE\ICON.SYS"
echo MD5 not Match Your file is probably corrupted
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
 )
 
REM __sysconf\ICON\TEXT\TEXT.ICO
if not exist "%~dp0HDD-OSD\__sysconf\ICON\TEXT\TEXT.ICO" (
"%~dp0BAT\Diagbox" gd 0c
echo Files "__sysconf\ICON\TEXT\TEXT.ICO" 
echo Missing
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
)

set "file=%~dp0HDD-OSD\__sysconf\ICON\TEXT\TEXT.ICO"
call "%~dp0BAT\md5.bat" "%file%" md5 %md5%

if %md5% equ 555b113797ad185d4187e17e27df9c9e (
"%~dp0BAT\Diagbox" gd 0e
echo Files "__sysconf\ICON\TEXT\TEXT.ICO"      
"%~dp0BAT\Diagbox" gd 0a      
echo %md5% Confirmed
echo\
   ) else (
"%~dp0BAT\Diagbox" gd 0c
echo Files "__sysconf\ICON\TEXT\TEXT.ICO"
echo MD5 not Match Your file is probably corrupted
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
 )

REM __sysconf\ICON\TEXT\ICON.SYS
if not exist "%~dp0HDD-OSD\__sysconf\ICON\TEXT\ICON.SYS" (
"%~dp0BAT\Diagbox" gd 0c
echo Files "__sysconf\ICON\TEXT\ICON.SYS" 
echo Missing
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
)

set "file=%~dp0HDD-OSD\__sysconf\ICON\TEXT\ICON.SYS"
call "%~dp0BAT\md5.bat" "%file%" md5 %md5%

if %md5% equ 6bbe982a18e25d7d7863a741f56e0e2a (
"%~dp0BAT\Diagbox" gd 0e
echo Files "__sysconf\ICON\TEXT\ICON.SYS"      
"%~dp0BAT\Diagbox" gd 0a      
echo %md5% Confirmed
echo\
   ) else (
"%~dp0BAT\Diagbox" gd 0c
echo Files "__sysconf\ICON\TEXT\ICON.SYS"
echo MD5 not Match Your file is probably corrupted
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
 )
 
REM __sysconf\ICON\VIDEO\VIDEO.ICO
if not exist "%~dp0HDD-OSD\__sysconf\ICON\VIDEO\VIDEO.ICO" (
"%~dp0BAT\Diagbox" gd 0c
echo Files "__sysconf\ICON\VIDEO\VIDEO.ICO" 
echo Missing
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
)

set "file=%~dp0HDD-OSD\__sysconf\ICON\VIDEO\VIDEO.ICO"
call "%~dp0BAT\md5.bat" "%file%" md5 %md5%

if %md5% equ 1bb1f10cb944212ce602eb317a85cef0 (
"%~dp0BAT\Diagbox" gd 0e
echo Files "__sysconf\ICON\VIDEO\VIDEO.ICO"      
"%~dp0BAT\Diagbox" gd 0a      
echo %md5% Confirmed
echo\
   ) else (
"%~dp0BAT\Diagbox" gd 0c
echo Files "__sysconf\ICON\VIDEO\VIDEO.ICO"
echo MD5 not Match Your file is probably corrupted
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
 )
 
REM __sysconf\ICON\VIDEO\ICON.SYS
if not exist "%~dp0HDD-OSD\__sysconf\ICON\VIDEO\ICON.SYS" (
"%~dp0BAT\Diagbox" gd 0c
echo Files "__sysconf\ICON\VIDEO\ICON.SYS" 
echo Missing
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
)

set "file=%~dp0HDD-OSD\__sysconf\ICON\VIDEO\ICON.SYS"
call "%~dp0BAT\md5.bat" "%file%" md5 %md5%

if %md5% equ e99de68551b255f180ade8e64d812d2b (
"%~dp0BAT\Diagbox" gd 0e
echo Files "__sysconf\ICON\VIDEO\ICON.SYS"      
"%~dp0BAT\Diagbox" gd 0a      
echo %md5% Confirmed
echo\
   ) else (
"%~dp0BAT\Diagbox" gd 0c
echo Files "__sysconf\ICON\VIDEO\ICON.SYS"
echo MD5 not Match Your file is probably corrupted
echo\
"%~dp0BAT\Diagbox" gd 0f
pause & (goto  HDDOSDMenu)
 )

"%~dp0BAT\Diagbox" gd 0f
pause
cls
mkdir "%~dp0TMP" >nul 2>&1
"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning for Playstation 2 HDDs:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | findstr "hdd" | "%~dp0BAT\busybox" grep "Playstation 2 HDD"
"%~dp0BAT\hdl_dump" query | findstr "hdd" | "%~dp0BAT\busybox" grep "Playstation 2 HDD" | "%~dp0BAT\busybox" cut -c2-6 > "%~dp0TMP\hdl-hdd.txt"
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
		del info.sys >nul 2>&1
        pause & (goto HDDOSDMenu)
	)
"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo Install HDD-OSD:
"%~dp0BAT\Diagbox" gd 0c 
echo\
echo MAKE SURE You have Installed FreeHDBoot (From HDD) 
"%~dp0BAT\Diagbox" gd 0f
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1) Yes
"%~dp0BAT\Diagbox" gd 0c
echo         2) No
"%~dp0BAT\Diagbox" gd 0f
echo\
CHOICE /C 12 /M "Select Option:"

IF ERRORLEVEL 1 set @pfs_installhddosd=yes
IF ERRORLEVEL 2 set @pfs_installhddosd=no

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
	"%~dp0BAT\busybox" cat "%~dp0TMP\pfs-prt.log" | "%~dp0BAT\busybox" grep "__sysconf" | "%~dp0BAT\busybox" sed "s/.*__sysconf/__sysconf/" | "%~dp0BAT\busybox" tr -d " " | "%~dp0BAT\busybox" head -1 > "%~dp0TMP\hdd-prt.txt"
	set /P @hdd_avl=<"%~dp0TMP\hdd-prt.txt"
	del "%~dp0TMP\pfs-prt.txt" "%~dp0TMP\pfs-prt.log" >nul 2>&1 "%~dp0TMP\hdd-prt.txt"

	IF "!@hdd_avl!"=="__sysconf" (
	"%~dp0BAT\Diagbox" gd 0a
		echo         __system - Partition Detected
		) else (
		"%~dp0BAT\Diagbox" gd 0c
		echo         __sysconf - Partition NOT Detected
		echo         Partition Must Be Formatted Or Created
		echo\
		echo\
		rmdir /Q/S "%~dp0TMP" >nul 2>&1
		del info.sys >nul 2>&1
		pause & (goto HDDOSDMenu)
		)
	)
"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Detecting __system Partition:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0f

	echo device !@hdl_path! > "%~dp0TMP\pfs-prt.txt"
	echo ls >> "%~dp0TMP\pfs-prt.txt"
	echo exit >> "%~dp0TMP\pfs-prt.txt"
	type "%~dp0TMP\pfs-prt.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" tee > "%~dp0TMP\pfs-prt.log"
	"%~dp0BAT\busybox" cat "%~dp0TMP\pfs-prt.log" | "%~dp0BAT\busybox" grep "__system" | "%~dp0BAT\busybox" sed "s/.*__system/__system/" | "%~dp0BAT\busybox" tr -d " " | "%~dp0BAT\busybox" head -1 > "%~dp0TMP\hdd-prt.txt"
	set /P @hdd_avl=<"%~dp0TMP\hdd-prt.txt"
	del "%~dp0TMP\pfs-prt.txt" "%~dp0TMP\pfs-prt.log" >nul 2>&1 "%~dp0TMP\hdd-prt.txt"

	IF "!@hdd_avl!"=="__system" (
	"%~dp0BAT\Diagbox" gd 0a
		echo         __system - Partition Detected
		"%~dp0BAT\Diagbox" gd 0c
		) else (
		echo         __system - Partition NOT Detected
		echo         Partition Must Be Formatted Or Created
		echo\
		echo\
		rmdir /Q/S "%~dp0TMP" >nul 2>&1
		del info.sys >nul 2>&1
	    pause & (goto HDDOSDMenu)
		)
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

	REM HDDOSD 1 DIR (__sysconf\FOLDER)

	for /D %%a in (*) do (
	echo mkdir "%%~na" >> "%~dp0TMP\pfs-hddosd.txt"
	echo lcd "%%~na" >> "%~dp0TMP\pfs-hddosd.txt"
 	echo cd "%%~na" >> "%~dp0TMP\pfs-hddosd.txt"
 	cd "%%~na"

	REM HDD-OSD FILES (__sysconf\FOLDER\files.xxx)

 	for %%1 in (*) do (echo put "%%1") >> "%~dp0TMP\pfs-hddosd.txt"

	REM HDDOSD 2 SUBDIR (__sysconf\FOLDER\SUBDIR)

	for /D %%b in (*) do (
	echo mkdir "%%~nb" >> "%~dp0TMP\pfs-hddosd.txt"
	echo lcd "%%~nb" >> "%~dp0TMP\pfs-hddosd.txt"
	echo cd "%%~nb" >> "%~dp0TMP\pfs-hddosd.txt"
	cd "%%~nb"

	REM HDDOSD SUBDIR FILES (__sysconf\FOLDER\SUBDIR\files.xxx)

	for %%2 in (*) do (echo put "%%2") >> "%~dp0TMP\pfs-hddosd.txt"
	
	REM HDDOSD 3 SUBDIR (__sysconf\FOLDER\SUBDIR\SUBDIR)

	for /D %%c in (*) do (
	echo mkdir "%%~nc" >> "%~dp0TMP\pfs-hddosd.txt"
	echo lcd "%%~nc" >> "%~dp0TMP\pfs-hddosd.txt"
	echo cd "%%~nc" >> "%~dp0TMP\pfs-hddosd.txt"
	cd "%%~nc"
	
	REM HDDOSD SUBDIR FILES (__sysconf\FOLDER\SUBDIR\SUBDIR\files.xxx)
	
	for %%3 in (*) do (echo put "%%3") >> "%~dp0TMP\pfs-hddosd.txt"
	
    REM HDDOSD 4 SUBDIR (__sysconf\FOLDER\SUBDIR\SUBDIR\SUBDIR\SUBDIR)

	for /D %%e in (*) do (
	echo mkdir "%%~ne" >> "%~dp0TMP\pfs-hddosd.txt"
	echo lcd "%%~ne" >> "%~dp0TMP\pfs-hddosd.txt"
	echo cd "%%~ne" >> "%~dp0TMP\pfs-hddosd.txt"
	cd "%%~ne"
	
	REM HDDOSD SUBDIR FILES (__sysconf\FOLDER\SUBDIR\SUBDIR\SUBDIR\files.xxx)
	
	for %%4 in (*) do (echo put "%%h") >> "%~dp0TMP\pfs-hddosd.txt"
	
	REM HDDOSD 5 SUBDIR (__sysconf\FOLDER\SUBDIR\SUBDIR\SUBDIR\SUBDIR\)

	for /D %%f in (*) do (
	echo mkdir "%%~nf" >> "%~dp0TMP\pfs-hddosd.txt"
	echo lcd "%%~nf" >> "%~dp0TMP\pfs-hddosd.txt"
	echo cd "%%~nf" >> "%~dp0TMP\pfs-hddosd.txt"
	cd "%%~nf"
	
	REM HDDOSD SUBDIR FILES (__sysconf\FOLDER\SUBDIR\SUBDIR\SUBDIR\SUBDIR\files.xxx)
	
	for %%5 in (*) do (echo put "%%5") >> "%~dp0TMP\pfs-hddosd.txt"
	
	REM HDDOSD 6 SUBDIR (__sysconf\FOLDER\SUBDIR\SUBDIR\SUBDIR\SUBDIR\)

	for /D %%g in (*) do (
	echo mkdir "%%~ng" >> "%~dp0TMP\pfs-hddosd.txt"
	echo lcd "%%~ng" >> "%~dp0TMP\pfs-hddosd.txt"
	echo cd "%%~ng" >> "%~dp0TMP\pfs-hddosd.txt"
	cd "%%~ng"
	
	REM HDDOSD SUBDIR FILES (__sysconf\FOLDER\SUBDIR\SUBDIR\SUBDIR\SUBDIR\SUBDIR\files.xxx)
	
	for %%6 in (*) do (echo put "%%6") >> "%~dp0TMP\pfs-hddosd.txt"
	
	REM HDDOSD 7 SUBDIR (__sysconf\FOLDER\SUBDIR\SUBDIR\SUBDIR\SUBDIR\SUBDIR\SUBDIR\)

	for /D %%h in (*) do (
	echo mkdir "%%~nh" >> "%~dp0TMP\pfs-hddosd.txt"
	echo lcd "%%~nh" >> "%~dp0TMP\pfs-hddosd.txt"
	echo cd "%%~nh" >> "%~dp0TMP\pfs-hddosd.txt"
	cd "%%~nh"
	
	REM HDDOSD SUBDIR FILES (__sysconf\FOLDER\SUBDIR\SUBDIR\SUBDIR\SUBDIR\SUBDIR\SUBDIR\files.xxx)
	
	for %%7 in (*) do (echo put "%%7") >> "%~dp0TMP\pfs-hddosd.txt"
	
	REM HDDOSD 8 SUBDIR (__sysconf\FOLDER\SUBDIR\SUBDIR\SUBDIR\SUBDIR\SUBDIR\SUBDIR\SUBDIR\)

	for /D %%i in (*) do (
	echo mkdir "%%~ni" >> "%~dp0TMP\pfs-hddosd.txt"
	echo lcd "%%~ni" >> "%~dp0TMP\pfs-hddosd.txt"
	echo cd "%%~ni" >> "%~dp0TMP\pfs-hddosd.txt"
	cd "%%~ni"
	
	REM HDDOSD SUBDIR FILES (__sysconf\FOLDER\SUBDIR\SUBDIR\SUBDIR\SUBDIR\SUBDIR\SUBDIR\SUBDIR\files.xxx)
	
	for %%8 in (*) do (echo put "%%8") >> "%~dp0TMP\pfs-hddosd.txt"
	
	REM HDDOSD 9 SUBDIR (__sysconf\FOLDER\SUBDIR\SUBDIR\SUBDIR\SUBDIR\SUBDIR\SUBDIR\SUBDIR\SUBDIR\)

	for /D %%j in (*) do (
	echo mkdir "%%~nj" >> "%~dp0TMP\pfs-hddosd.txt"
	echo lcd "%%~nj" >> "%~dp0TMP\pfs-hddosd.txt"
	echo cd "%%~nj" >> "%~dp0TMP\pfs-hddosd.txt"
	cd "%%~nj"
	
	REM HDDOSD SUBDIR FILES (__sysconf\FOLDER\SUBDIR\SUBDIR\SUBDIR\SUBDIR\SUBDIR\SUBDIR\SUBDIR\SUBDIR\files.xxx)
	
	for %%9 in (*) do (echo put "%%9") >> "%~dp0TMP\pfs-hddosd.txt"

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
	del "%~dp0TMP\pfs-hddosd.txt" >nul 2>&1
	del "%~dp0TMP\pfs-log.txt" "%~dp0TMP\pfs-tmp.log" >nul 2>&1
	echo         Partition __sysconf Completed...	
	cd "%~dp0"
	) else ( echo         HDDOSD - FOLDER __SYSCONF Not Detected... )


REM __SYSTEM 

	IF /I EXIST "%~dp0HDD-OSD\__system\*" (
	cd "%~dp0"HDD-OSD\__system"

	REM MOUNT __SYSTEM

	echo device !@hdl_path! > "%~dp0TMP\pfs-hddosd.txt"
	echo mount __system >> "%~dp0TMP\pfs-hddosd.txt"
	
	echo         Installing Que
    for %%0 in (*) do (echo put "%%0") >> "%~dp0TMP\pfs-hddosd.txt"

	REM HDDOSD 1 DIR (__system\APP)

	for /D %%a in (*) do (
	echo mkdir "%%~na" >> "%~dp0TMP\pfs-hddosd.txt"
	echo lcd "%%~na" >> "%~dp0TMP\pfs-hddosd.txt"
 	echo cd "%%~na" >> "%~dp0TMP\pfs-hddosd.txt"
 	cd "%%~na"

	REM HDDOSD FILES (__system\APP\files.xxx)

 	for %%1 in (*) do (echo put "%%1") >> "%~dp0TMP\pfs-hddosd.txt"

	REM HDDOSD 2 SUBDIR (__system\APP\SUBDIR)

	for /D %%b in (*) do (
	echo mkdir "%%~nb" >> "%~dp0TMP\pfs-hddosd.txt"
	echo lcd "%%~nb" >> "%~dp0TMP\pfs-hddosd.txt"
	echo cd "%%~nb" >> "%~dp0TMP\pfs-hddosd.txt"
	cd "%%~nb"

	REM HDDOSD SUBDIR FILES (__system\APP\SUBDIR\files.xxx)

	for %%2 in (*) do (echo put "%%2") >> "%~dp0TMP\pfs-hddosd.txt"
	
	REM HDDOSD 3 SUBDIR (__system\APP\SUBDIR\SUBDIR)

	for /D %%c in (*) do (
	echo mkdir "%%~nc" >> "%~dp0TMP\pfs-hddosd.txt"
	echo lcd "%%~nc" >> "%~dp0TMP\pfs-hddosd.txt"
	echo cd "%%~nc" >> "%~dp0TMP\pfs-hddosd.txt"
	cd "%%~nc"
	
	REM HDDOSD SUBDIR FILES (__system\APP\SUBDIR\SUBDIR\files.xxx)
	
	for %%3 in (*) do (echo put "%%3") >> "%~dp0TMP\pfs-hddosd.txt"
	
    REM HDDOSD 4 SUBDIR (__system\APP\SUBDIR\SUBDIR\SUBDIR\SUBDIR)

	for /D %%e in (*) do (
	echo mkdir "%%~ne" >> "%~dp0TMP\pfs-hddosd.txt"
	echo lcd "%%~ne" >> "%~dp0TMP\pfs-hddosd.txt"
	echo cd "%%~ne" >> "%~dp0TMP\pfs-hddosd.txt"
	cd "%%~ne"
	
	REM HDDOSD SUBDIR FILES (__system\APP\SUBDIR\SUBDIR\SUBDIR\files.xxx)
	
	for %%4 in (*) do (echo put "%%h") >> "%~dp0TMP\pfs-hddosd.txt"
	
	REM HDDOSD 5 SUBDIR (__system\APP\SUBDIR\SUBDIR\SUBDIR\SUBDIR\)

	for /D %%f in (*) do (
	echo mkdir "%%~nf" >> "%~dp0TMP\pfs-hddosd.txt"
	echo lcd "%%~nf" >> "%~dp0TMP\pfs-hddosd.txt"
	echo cd "%%~nf" >> "%~dp0TMP\pfs-hddosd.txt"
	cd "%%~nf"
	
	REM HDDOSD SUBDIR FILES (__system\APP\SUBDIR\SUBDIR\SUBDIR\SUBDIR\files.xxx)
	
	for %%5 in (*) do (echo put "%%5") >> "%~dp0TMP\pfs-hddosd.txt"
	
	REM HDDOSD 6 SUBDIR (__system\APP\SUBDIR\SUBDIR\SUBDIR\SUBDIR\)

	for /D %%g in (*) do (
	echo mkdir "%%~ng" >> "%~dp0TMP\pfs-hddosd.txt"
	echo lcd "%%~ng" >> "%~dp0TMP\pfs-hddosd.txt"
	echo cd "%%~ng" >> "%~dp0TMP\pfs-hddosd.txt"
	cd "%%~ng"
	
	REM HDDOSD SUBDIR FILES (__system\APP\SUBDIR\SUBDIR\SUBDIR\SUBDIR\SUBDIR\files.xxx)
	
	for %%6 in (*) do (echo put "%%6") >> "%~dp0TMP\pfs-hddosd.txt"
	
	REM HDDOSD 7 SUBDIR (__system\APP\SUBDIR\SUBDIR\SUBDIR\SUBDIR\SUBDIR\SUBDIR\)

	for /D %%h in (*) do (
	echo mkdir "%%~nh" >> "%~dp0TMP\pfs-hddosd.txt"
	echo lcd "%%~nh" >> "%~dp0TMP\pfs-hddosd.txt"
	echo cd "%%~nh" >> "%~dp0TMP\pfs-hddosd.txt"
	cd "%%~nh"
	
	REM HDDOSD SUBDIR FILES (__system\APP\SUBDIR\SUBDIR\SUBDIR\SUBDIR\SUBDIR\SUBDIR\files.xxx)
	
	for %%7 in (*) do (echo put "%%7") >> "%~dp0TMP\pfs-hddosd.txt"
	
	REM HDDOSD 8 SUBDIR (__system\APP\SUBDIR\SUBDIR\SUBDIR\SUBDIR\SUBDIR\SUBDIR\SUBDIR\)

	for /D %%i in (*) do (
	echo mkdir "%%~ni" >> "%~dp0TMP\pfs-hddosd.txt"
	echo lcd "%%~ni" >> "%~dp0TMP\pfs-hddosd.txt"
	echo cd "%%~ni" >> "%~dp0TMP\pfs-hddosd.txt"
	cd "%%~ni"
	
	REM HDDOSD SUBDIR FILES (__system\APP\SUBDIR\SUBDIR\SUBDIR\SUBDIR\SUBDIR\SUBDIR\SUBDIR\files.xxx)
	
	for %%8 in (*) do (echo put "%%8") >> "%~dp0TMP\pfs-hddosd.txt"
	
	REM HDDOSD 9 SUBDIR (__system\APP\SUBDIR\SUBDIR\SUBDIR\SUBDIR\SUBDIR\SUBDIR\SUBDIR\SUBDIR\)

	for /D %%j in (*) do (
	echo mkdir "%%~nj" >> "%~dp0TMP\pfs-hddosd.txt"
	echo lcd "%%~nj" >> "%~dp0TMP\pfs-hddosd.txt"
	echo cd "%%~nj" >> "%~dp0TMP\pfs-hddosd.txt"
	cd "%%~nj"
	
	REM HDDOSD SUBDIR FILES (__system\APP\SUBDIR\SUBDIR\SUBDIR\SUBDIR\SUBDIR\SUBDIR\SUBDIR\SUBDIR\files.xxx)
	
	for %%9 in (*) do (echo put "%%9") >> "%~dp0TMP\pfs-hddosd.txt"

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

	REM UNMOUNT __system

	)
	echo umount >> "%~dp0TMP\pfs-hddosd.txt"
	echo exit >> "%~dp0TMP\pfs-hddosd.txt"
	type "%~dp0TMP\pfs-hddosd.txt" | "%~dp0BAT\pfsshell" >nul 2>&1
	del "%~dp0TMP\pfs-hddosd.txt" >nul 2>&1
	del "%~dp0TMP\pfs-log.txt" "%~dp0TMP\pfs-tmp.log" >nul 2>&1
	echo         Partition __system Completed...
	echo.
	echo         HDD-OSD Completed...	
	cd "%~dp0"
   
REM Copy OPL Files For Launch Games From HDD-OSD
cd "%~dp0HDD-OSD\__common\OPL"
    echo device !@hdl_path! > "%~dp0TMP\pfs-hddosd.txt"
	echo mount __common >> "%~dp0TMP\pfs-hddosd.txt"
	echo mkdir OPL >> "%~dp0TMP\pfs-hddosd.txt"
	echo cd OPL >> "%~dp0TMP\pfs-hddosd.txt"
 	echo put conf_hdd.cfg >> "%~dp0TMP\pfs-hddosd.txt"
    echo umount >> "%~dp0TMP\pfs-hddosd.txt"
	echo exit >> "%~dp0TMP\pfs-hddosd.txt"
	type "%~dp0TMP\pfs-hddosd.txt" | "%~dp0BAT\pfsshell" >nul 2>&1
	cd "%~dp0"
	
cd "%~dp0"HDD-OSD\"
    echo device !@hdl_path! > "%~dp0TMP\pfs-hddosd.txt"
	echo mount %OPLPART% >> "%~dp0TMP\pfs-hddosd.txt"
 	echo put OPNPS2LD.ELF >> "%~dp0TMP\pfs-hddosd.txt"
    echo umount >> "%~dp0TMP\pfs-hddosd.txt"
	echo exit >> "%~dp0TMP\pfs-hddosd.txt"
	type "%~dp0TMP\pfs-hddosd.txt" | "%~dp0BAT\pfsshell" >nul 2>&1
	cd "%~dp0"
	) else ( echo         HDDOSD - FOLDER __SYSTEM Not Detected... )
 )

rmdir /Q/S "%~dp0TMP" >nul 2>&1
del info.sys >nul 2>&1

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


cd "%~dp0"

IF NOT EXIST HDD-OSD\ MD HDD-OSD

cls
mkdir "%~dp0TMP" >nul 2>&1
"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning for Playstation 2 HDDs:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | findstr "hdd" | "%~dp0BAT\busybox" grep "Playstation 2 HDD"
"%~dp0BAT\hdl_dump" query | findstr "hdd" | "%~dp0BAT\busybox" grep "Playstation 2 HDD" | "%~dp0BAT\busybox" cut -c2-6 > "%~dp0TMP\hdl-hdd.txt"
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
		del info.sys >nul 2>&1
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

IF ERRORLEVEL 1 set @pfs_uninhddosd=yes
IF ERRORLEVEL 2 set @pfs_uninhddosd=no

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
	"%~dp0BAT\busybox" cat "%~dp0TMP\pfs-prt.log" | "%~dp0BAT\busybox" grep "__sysconf" | "%~dp0BAT\busybox" sed "s/.*__sysconf/__sysconf/" | "%~dp0BAT\busybox" tr -d " " | "%~dp0BAT\busybox" head -1 > "%~dp0TMP\hdd-prt.txt"
	set /P @hdd_avl=<"%~dp0TMP\hdd-prt.txt"
	del "%~dp0TMP\pfs-prt.txt" "%~dp0TMP\pfs-prt.log" >nul 2>&1 "%~dp0TMP\hdd-prt.txt"

	IF "!@hdd_avl!"=="__sysconf" (
	"%~dp0BAT\Diagbox" gd 0a
		echo         __system - Partition Detected
		) else (
		"%~dp0BAT\Diagbox" gd 0c
		echo         __sysconf - Partition NOT Detected
		echo         Partition Must Be Formatted Or Created
		echo\
		echo\
		rmdir /Q/S "%~dp0TMP" >nul 2>&1
		del info.sys >nul 2>&1	
		pause & (goto HDDOSDMenu)
		)
	)
"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Detecting __system Partition:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0f

	echo device !@hdl_path! > "%~dp0TMP\pfs-prt.txt"
	echo ls >> "%~dp0TMP\pfs-prt.txt"
	echo exit >> "%~dp0TMP\pfs-prt.txt"
	type "%~dp0TMP\pfs-prt.txt" | "%~dp0BAT\pfsshell" 2>&1 | "%~dp0BAT\busybox" tee > "%~dp0TMP\pfs-prt.log"
	"%~dp0BAT\busybox" cat "%~dp0TMP\pfs-prt.log" | "%~dp0BAT\busybox" grep "__system" | "%~dp0BAT\busybox" sed "s/.*__system/__system/" | "%~dp0BAT\busybox" tr -d " " | "%~dp0BAT\busybox" head -1 > "%~dp0TMP\hdd-prt.txt"
	set /P @hdd_avl=<"%~dp0TMP\hdd-prt.txt"
	del "%~dp0TMP\pfs-prt.txt" "%~dp0TMP\pfs-prt.log" >nul 2>&1 "%~dp0TMP\hdd-prt.txt"

	IF "!@hdd_avl!"=="__system" (
	"%~dp0BAT\Diagbox" gd 0a
		echo         __system - Partition Detected
		"%~dp0BAT\Diagbox" gd 0c
		) else (
		echo         __system - Partition NOT Detected
		echo         Partition Must Be Formatted Or Created
		echo\
		echo\
		rmdir /Q/S "%~dp0TMP" >nul 2>&1
		del info.sys >nul 2>&1
		pause & (goto HDDOSDMenu)
		)
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
	cd "%~dp0"
 
REM Delete OPNPS2LD.ELF
    echo device !@hdl_path! > "%~dp0TMP\pfs-hddosd.txt"
	echo mount %OPLPART% >> "%~dp0TMP\pfs-hddosd.txt"
 	echo rm OPNPS2LD.ELF >> "%~dp0TMP\pfs-hddosd.txt"
    echo umount >> "%~dp0TMP\pfs-hddosd.txt"
	echo exit >> "%~dp0TMP\pfs-hddosd.txt"
	type "%~dp0TMP\pfs-hddosd.txt" | "%~dp0BAT\pfsshell" >nul 2>&1
	cd "%~dp0"
	) else ( echo         HDDOSD - Source Not Detected... )

rmdir /Q/S "%~dp0TMP" >nul 2>&1
del info.sys >nul 2>&1

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
:injectbootkelf

cls
mkdir "%~dp0TMP" >nul 2>&1
mkdir "%~dp0CD-DVD" >nul 2>&1
cd /d "%~dp0CD-DVD"

copy "%~dp0BAT\boot.kelf" "%~dp0CD-DVD" >nul 2>&1
copy "%~dp0BAT\hdl_svr_093.elf" "%~dp0CD-DVD" >nul 2>&1
copy "%~dp0BAT\hdl_dump.exe" "%~dp0CD-DVD" >nul 2>&1
"%~dp0BAT\Diagbox" gd 0e

cls
"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning HDDs:
echo ----------------------------------------------------
    "%~dp0BAT\Diagbox" gd 03
	"%~dp0BAT\hdl_dump" query | findstr "Playstation"
	"%~dp0BAT\Diagbox" gd 07
    echo.
    echo ----------------------------------------------------
    "%~dp0BAT\Diagbox" gd 06
	echo NOTE: If no PS2 HDDs are found, quit and retry after disconnecting
	echo all disk drives EXCEPT for your PC boot drive and the PS2 HDDs.
	"%~dp0BAT\Diagbox" gd 0f
	echo.
	echo. 
	echo PLAYSTATION 2 HDD
	echo 	1. hdd1: 
	echo 	2. hdd2:
	echo 	3. hdd3:
	echo 	4. hdd4: 
	echo 	5. hdd5:
	echo 	6. hdd6:
	echo 	7. Network
	echo 	8. Quit Program
	choice /c 12345678 /m "Choice the number of your PS2 HDD."	
	    
		if errorlevel 8 (goto HDDOSDMenu)
		if errorlevel 1 set hdlhdd=hdd1:
		if errorlevel 2 set hdlhdd=hdd2:
		if errorlevel 3 set hdlhdd=hdd3:
		if errorlevel 4 set hdlhdd=hdd4:
		if errorlevel 5 set hdlhdd=hdd5:
		if errorlevel 6 set hdlhdd=hdd6:
		if errorlevel 7 (goto injectkelfnetwork)

cls
"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Prepare HDD for Inject KELF:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | findstr "%hdlhdd%"
(goto injectkelf)

:injectkelfnetwork
cls
"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Prepare HDD Network for Inject KELF:
echo ----------------------------------------------------
echo.
     "%~dp0BAT\Diagbox" gd 0f
     set /p "hdlhdd=Enter IP of the Playstation 2: "
     ping -n 1 -w 2000 !hdlhdd!
     if errorlevel 1 (
     "%~dp0BAT\Diagbox" gd 0c
     	echo Unable to ping !hdlhdd! ... ending script.
     	"%~dp0BAT\Diagbox" gd 07
		echo.
        pause & goto injectbootkelf)
		
:injectkelf
echo\
echo\
"%~dp0BAT\Diagbox" gd 0f
echo Inject MiniOPL (boot.kelf) ?
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1) %YES% (For every installed game) 
"%~dp0BAT\Diagbox" gd 0c
echo         2) %NO%
"%~dp0BAT\Diagbox" gd 0e
echo         3) Yes (Manually)
"%~dp0BAT\Diagbox" gd 07
echo\
CHOICE /C 123 /M "Select Option:"

IF ERRORLEVEL 3 set @pfs_ppinjectkelf=yes
IF ERRORLEVEL 3 (goto injectbootkelfmanually)
IF ERRORLEVEL 2 (goto HDDOSDMenu)


"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Partition List:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
    "%~dp0BAT\hdl_dump" toc %hdlhdd% > "%~dp0TMP\HDL_PART_GAMES.log"
	"%~dp0BAT\busybox" cat "%~dp0TMP\HDL_PART_GAMES.log" | "%~dp0BAT\busybox" grep -e "0x1337" > "%~dp0CD-DVD\HDL_PART_GAMES.txt"
	"%~dp0BAT\busybox" sed -i "s/\s*$//" "%~dp0CD-DVD\HDL_PART_GAMES.txt"
	type "%~dp0CD-DVD\HDL_PART_GAMES.txt"
"%~dp0BAT\Diagbox" gd 0e
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03

For %%Z in (HDL_PART_GAMES.txt) do (
 (for /f "tokens=1,5" %%A in (%%Z) do echo hdl_dump modify_header %hdlhdd% "%%B") > "InjectHeader.bat")

@echo on & call InjectHeader.bat

@echo off 
"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo Injection Completed...
echo\
echo\
"%~dp0BAT\Diagbox" gd 07

cd "%~dp0"
rmdir /Q/S "%~dp0CD-DVD" >nul 2>&1
rmdir /Q/S "%~dp0TMP" >nul 2>&1

echo.
pause & (goto HDDOSDMenu)


:injectbootkelfmanually
"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Partition Games List:
"%~dp0BAT\Diagbox" gd 0f
echo ----------------------------------------------------
    "%~dp0BAT\hdl_dump" toc !hdlhdd! | "%~dp0BAT\busybox" grep "PP." | "%~dp0BAT\busybox" cut -c30-250 > "%~dp0LOG\PARTITION_GAMES.txt"
	type "%~dp0LOG\PARTITION_GAMES.txt"
echo ----------------------------------------------------	
"%~dp0BAT\Diagbox" gd 06

echo Copy Name of the partition. Example: PP.SLES-50507..HALF_LIFE
echo.
"%~dp0BAT\Diagbox" gd 0f

set /p "ppinjectkelf=Enter the partition name you want to Launch in HDD-OSD:"

)

cls
echo\
echo\
echo Inject boot.kelf %ppinjectkelf% Partition:
echo ----------------------------------------------------
echo\

    echo        Inject boot.kelf in partitions...
	"%~dp0BAT\hdl_dump" modify_header !hdlhdd! "%ppinjectkelf%"
	echo.
	echo        Partition %ppinjectkelf% KELF Injected...	
	) else ( echo          Canceled... )

rmdir /Q/S "%~dp0TMP" >nul 2>&1
del info.sys >nul 2>&1
echo\
echo\
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo Injection Completed...
echo\
echo\
"%~dp0BAT\Diagbox" gd 07

cd "%~dp0"
rmdir /Q/S "%~dp0CD-DVD" >nul 2>&1
rmdir /Q/S "%~dp0TMP" >nul 2>&1

echo.
pause & (goto HDDOSDMenu)

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
"%~dp0BAT\hdl_dump" query | findstr "hdd" | "%~dp0BAT\busybox" grep "Playstation 2 HDD"
"%~dp0BAT\hdl_dump" query | findstr "hdd" | "%~dp0BAT\busybox" grep "Playstation 2 HDD" | "%~dp0BAT\busybox" cut -c2-6 > "%~dp0TMP\hdl-hdd.txt"

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
		del info.sys >nul 2>&1		
        pause & (goto HDDOSDMenu)
	)

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\

echo Scan for non-hidden partitions:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1) %YES%
"%~dp0BAT\Diagbox" gd 0c
echo         2) %NO%
"%~dp0BAT\Diagbox" gd 07
echo\
CHOICE /C 12 /M "Select Option:"

IF ERRORLEVEL 1 set @pfs_pphide=yes
IF ERRORLEVEL 2 set @pfs_pphide=no

IF %@pfs_pphide%==yes (
echo\
echo\
echo Partition Games List:
echo ----------------------------------------------------
    "%~dp0BAT\hdl_dump" toc %@hdl_path% | "%~dp0BAT\busybox" grep "PP." | "%~dp0BAT\busybox" cut -c30-250 > "%~dp0LOG\PARTITION_GAMES.txt"
	type "%~dp0LOG\PARTITION_GAMES.txt"
echo ----------------------------------------------------	
"%~dp0BAT\Diagbox" gd 06
echo Copy Name of the partition. Example: PP.SLES-50507..HALF_LIFE
echo.
"%~dp0BAT\Diagbox" gd 07

set /p "pphide=Enter the partition name you want to hide:"

)

cls
IF %@pfs_pphide%==yes (
echo\
echo\
echo Hide %pphide% Partition:
echo ----------------------------------------------------
echo\

    echo        Hide partitions...
	"%~dp0BAT\hdl_dump" modify %@hdl_path% "%pphide%" -hide
	echo        Partition %pphide% Hide...	
	) else ( echo          Canceled... )

rmdir /Q/S "%~dp0TMP" >nul 2>&1
del info.sys >nul 2>&1

echo\
echo\
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo Partition Completed...
echo\
echo\
"%~dp0BAT\Diagbox" gd 07

pause & (goto HDDOSDMenu)

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
"%~dp0BAT\hdl_dump" query | findstr "hdd" | "%~dp0BAT\busybox" grep "Playstation 2 HDD"
"%~dp0BAT\hdl_dump" query | findstr "hdd" | "%~dp0BAT\busybox" grep "Playstation 2 HDD" | "%~dp0BAT\busybox" cut -c2-6 > "%~dp0TMP\hdl-hdd.txt"

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
		del info.sys >nul 2>&1
        pause & (goto HDDOSDMenu)
	)
	
"%~dp0BAT\Diagbox" gd 0f
echo\
echo\

echo Scan already hidden partitions:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1) %YES%
"%~dp0BAT\Diagbox" gd 0c
echo         2) %NO%
"%~dp0BAT\Diagbox" gd 07
echo\
CHOICE /C 12 /M "Select Option:"

IF ERRORLEVEL 1 set @pfs_pphide=yes
IF ERRORLEVEL 2 set @pfs_pphide=no

IF %@pfs_pphide%==yes (
echo\
echo\
echo Partition game list hidden:
echo ----------------------------------------------------
    "%~dp0BAT\hdl_dump" toc %@hdl_path% | "%~dp0BAT\busybox" grep "0x1337" | "%~dp0BAT\busybox" cut -c30-250 | "%~dp0BAT\busybox" sed "/PP./d" > "%~dp0LOG\PARTITION_GAMES_HIDDEN.txt"
	type "%~dp0LOG\PARTITION_GAMES_HIDDEN.txt"
echo ----------------------------------------------------	
"%~dp0BAT\Diagbox" gd 06
echo Copy Name of the partition. Example: __.SLES-50507..HALF_LIFE
echo.
"%~dp0BAT\Diagbox" gd 07
set /p "pphide=Enter the partition name you want to Unhide:"

)

cls
IF %@pfs_pphide%==yes (
echo\
echo\
echo Unhide %pphide% Partition:
echo ----------------------------------------------------
echo\

    echo        Unhide partitions...
	"%~dp0BAT\hdl_dump" modify %@hdl_path% "%pphide%" -unhide
	echo        Partition %pphide% Unhide...	
	) else ( echo          Canceled... )

rmdir /Q/S "%~dp0TMP" >nul 2>&1
del info.sys >nul 2>&1

echo\
echo\
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo Partition Unhide Completed...
echo\
echo\
"%~dp0BAT\Diagbox" gd 07

pause & (goto HDDOSDMenu)

REM ####################################################################################################################################################
:DownloadART

mkdir "%~dp0ART" >nul 2>&1
mkdir "%~dp0TMP" >nul 2>&1

cls
cd /d "%~dp0TMP"

"%~dp0BAT\Diagbox" gd 0e

echo\
echo\
echo Scanning for Playstation 2 HDDs:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
"%~dp0BAT\hdl_dump" query | findstr "hdd" | "%~dp0BAT\busybox" grep "Playstation 2 HDD"
"%~dp0BAT\hdl_dump" query | findstr "hdd" | "%~dp0BAT\busybox" grep "Playstation 2 HDD" | "%~dp0BAT\busybox" cut -c2-6 > "%~dp0TMP\hdl-hdd.txt"

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
		del info.sys >nul 2>&1 
		pause & (goto DownloadARTMenu)
	)

"%~dp0BAT\Diagbox" gd 0f
echo\
echo\
"%~dp0BAT\Diagbox" gd 0f
echo Download ART For All Game installed ?
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo         1) %YES%
"%~dp0BAT\Diagbox" gd 0c
echo         2) %NO%
"%~dp0BAT\Diagbox" gd 07
echo\
CHOICE /C 12 /M "Select Option:"

IF ERRORLEVEL 2 (goto DownloadARTMenu)

"%~dp0BAT\Diagbox" gd 0e
cls
echo\
echo\
echo List Games
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
setlocal DisableDelayedExpansion

"%~dp0BAT\hdl_dump" hdl_toc %@hdl_path% > .PARTITION_GAMES.txt

more +1 .PARTITION_GAMES.txt > file.txt
move /y file.txt PARTITION_GAMES_NEW.txt >nul

"%~dp0BAT\busybox" sed -i -e "$ d" PARTITION_GAMES_NEW.txt
type PARTITION_GAMES_NEW.txt
"%~dp0BAT\Diagbox" gd 0e
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03
echo Download...

REM Cov
For %%Z in (PARTITION_GAMES_NEW.txt) do (
 (for /f "tokens=2,5*" %%A in (%%Z) do echo "%~dp0BAT\wget" -q --show-progress "https://ia804505.us.archive.org/view_archive.php?archive=/9/items/OPLM_ART_2021_07/OPLM_ART_2021_07.zip&file=PS2%%%%2F%%B%%%%2F%%B_COV.jpg" -O "%~dp0ART\%%B_COV.jpg") > PARTITION_GAMES_COV.bat)

call PARTITION_GAMES_COV.bat

"%~dp0BAT\Diagbox" gd 0e
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03

REM Front Cover
For %%Z in (PARTITION_GAMES_NEW.txt) do (
 (for /f "tokens=2,5*" %%A in (%%Z) do echo "%~dp0BAT\wget" -q --show-progress "https://ia804505.us.archive.org/view_archive.php?archive=/9/items/OPLM_ART_2021_07/OPLM_ART_2021_07.zip&file=PS2%%%%2F%%B%%%%2F%%B_COV2.jpg" -O "%~dp0ART\%%B_COV2.jpg") > PARTITION_GAMES_COV2.bat)
 
call PARTITION_GAMES_COV2.bat

"%~dp0BAT\Diagbox" gd 0e
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03

REM Back Cover
For %%Z in (PARTITION_GAMES_NEW.txt) do (
 (for /f "tokens=2,5*" %%A in (%%Z) do echo "%~dp0BAT\wget" -q --show-progress "https://ia804505.us.archive.org/view_archive.php?archive=/9/items/OPLM_ART_2021_07/OPLM_ART_2021_07.zip&file=PS2%%%%2F%%B%%%%2F%%B_ICO.png" -O "%~dp0ART\%%B_ICO.png") > PARTITION_GAMES_ICO.bat)
 
call PARTITION_GAMES_ICO.bat 

"%~dp0BAT\Diagbox" gd 0e
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03

REM LAB
For %%Z in (PARTITION_GAMES_NEW.txt) do (
 (for /f "tokens=2,5*" %%A in (%%Z) do echo "%~dp0BAT\wget" -q --show-progress "https://ia804505.us.archive.org/view_archive.php?archive=/9/items/OPLM_ART_2021_07/OPLM_ART_2021_07.zip&file=PS2%%%%2F%%B%%%%2F%%B_LAB.jpg" -O "%~dp0ART\%%B_LAB.jpg") > PARTITION_GAMES_LAB.bat)
 
call PARTITION_GAMES_LAB.bat 

"%~dp0BAT\Diagbox" gd 0e
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03

REM Logo
For %%Z in (PARTITION_GAMES_NEW.txt) do (
 (for /f "tokens=2,5*" %%A in (%%Z) do echo "%~dp0BAT\wget" -q --show-progress "https://ia804505.us.archive.org/view_archive.php?archive=/9/items/OPLM_ART_2021_07/OPLM_ART_2021_07.zip&file=PS2%%%%2F%%B%%%%2F%%B_LGO.png" -O "%~dp0ART\%%B_LGO.png") > PARTITION_GAMES_LGO.bat)
 
call PARTITION_GAMES_LGO.bat 

"%~dp0BAT\Diagbox" gd 0e
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03

REM Background
For %%Z in (PARTITION_GAMES_NEW.txt) do (
 (for /f "tokens=2,5*" %%A in (%%Z) do echo "%~dp0BAT\wget" -q --show-progress "https://ia804505.us.archive.org/view_archive.php?archive=/9/items/OPLM_ART_2021_07/OPLM_ART_2021_07.zip&file=PS2%%%%2F%%B%%%%2F%%B_BG_00.jpg" -O "%~dp0ART\%%B_BG.jpg") > PARTITION_GAMES_BG.bat)
 
call PARTITION_GAMES_BG.bat 

"%~dp0BAT\Diagbox" gd 0e
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03

REM Screenshot 1
For %%Z in (PARTITION_GAMES_NEW.txt) do (
 (for /f "tokens=2,5*" %%A in (%%Z) do echo "%~dp0BAT\wget" -q --show-progress "https://ia804505.us.archive.org/view_archive.php?archive=/9/items/OPLM_ART_2021_07/OPLM_ART_2021_07.zip&file=PS2%%%%2F%%B%%%%2F%%B_SCR_00.jpg" -O "%~dp0ART\%%B_SCR.jpg") > PARTITION_GAMES_SCR00.bat)
 
call PARTITION_GAMES_SCR00.bat 
"%~dp0BAT\Diagbox" gd 0e
 
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 03

REM Screenshot 2
For %%Z in (PARTITION_GAMES_NEW.txt) do (
 (for /f "tokens=2,5*" %%A in (%%Z) do echo "%~dp0BAT\wget" -q --show-progress "https://ia804505.us.archive.org/view_archive.php?archive=/9/items/OPLM_ART_2021_07/OPLM_ART_2021_07.zip&file=PS2%%%%2F%%B%%%%2F%%B_SCR_01.jpg" -O "%~dp0ART\%%B_SCR2.jpg") > PARTITION_GAMES_SCR01.bat)
 
call PARTITION_GAMES_SCR01.bat 

cd "%~dp0"
for %%F in ("%~dp0ART\*") do if %%~zF==0 del "%%F"

rmdir /Q/S "%~dp0TMP" >nul 2>&1
echo.

pause & (goto DownloadARTMenu) 

REM ####################################################################################################################################################
:DumpCDDVD
@echo off

mkdir "%~dp0CD-DVD" >nul 2>&1
mkdir "%~dp0TMP" >nul 2>&1

copy "%~dp0BAT\hdl_dump.exe" "%~dp0CD-DVD\hdl_dump.exe" >nul 2>&1

cd /d "%~dp0CD-DVD"
cls

"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning Optical Drives:
echo ----------------------------------------------------
    "%~dp0BAT\Diagbox" gd 03
	"%~dp0BAT\hdl_dump" query | findstr "cd0: cd1: cd2: cd3: cd4: cd5 cd:6"
	"%~dp0BAT\Diagbox" gd 07
    echo.
    echo ----------------------------------------------------
    "%~dp0BAT\Diagbox" gd 06
	echo Prepare your DISC for DUMP
	echo.
	echo NOTE: If your optical drive is not visible, rerun this batch after inserting your disc
	"%~dp0BAT\Diagbox" gd 0f
	echo.
	echo    Optical Drives
	echo 	0. CD0:
	echo 	1. CD1:
	echo 	2. CD2:
	echo 	3. CD3: 
	echo 	4. CD4:
	echo 	5. CD5:
	echo 	6. CD6:
	echo 	7. Quit Program
    set choice=
    set /p choice="Choice the number of your Optical Drives.:"
        
		IF "!choice!"=="0" set hdlcddvd=cd!choice!:
		IF "!choice!"=="1" set hdlcddvd=cd!choice!:
		IF "!choice!"=="2" set hdlcddvd=cd!choice!:
		IF "!choice!"=="3" set hdlcddvd=cd!choice!:
		IF "!choice!"=="4" set hdlcddvd=cd!choice!:
		IF "!choice!"=="5" set hdlcddvd=cd!choice!:
		IF "!choice!"=="6" set hdlcddvd=cd!choice!:
		IF "!choice!"=="7" (goto AdvancedMenu)
cls
"%~dp0BAT\Diagbox" gd 0e
echo\
echo\
echo Disc Dump:
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0f

echo Dump in progress...
echo Please be patient, it may take some time
echo.

hdl_dump dump %hdlcddvd% "game.iso"
hdl_dump cdvd_info2 "game.iso" > "%~dp0CD-DVD\Info_dump.txt"

For %%Z in (Info_dump.txt) do (
 (for /f "tokens=2,3*" %%A in (%%Z) do echo %%C) > "%~dp0TMP\info2.txt")


"%~dp0BAT\busybox" sed -i "s/\"//g" "%~dp0TMP\info2.txt"
"%~dp0BAT\busybox" sed "s/ //g" "%~dp0TMP\info2.txt" > "%~dp0TMP\info2tmp.txt"
"%~dp0BAT\busybox" sed -i s/$/.iso/ "%~dp0TMP\info2tmp.txt"
set /P dump=<"%~dp0TMP\info2tmp.txt"
ren game.iso %dump%

"%~dp0BAT\Diagbox" gd 0f
echo.
echo.
echo Output ^> \CD-DVD\%dump%

echo.
echo Do you want to check MD5 of your dump ?
choice /c YN

IF ERRORLEVEL 1 set @checkmd5=yes
IF ERRORLEVEL 2 (goto EndRedumpMatch)

IF %@checkmd5%==yes (

"%~dp0BAT\Diagbox" gd 0e
echo.
echo Download Latest Redump Database ?
choice /c YN 

IF ERRORLEVEL 1 set @checkmd5=yes
IF ERRORLEVEL 2 (goto md5processingdump)

"%~dp0BAT\Diagbox" gd 0d
"%~dp0BAT\wget" -q --show-progress http://redump.org/datfile/ps2/ -O "%~dp0BAT\Dats\RedumpPS2.zip"
"%~dp0BAT\Diagbox" gd 07

"%~dp0BAT\Diagbox" gd 0e
	timeout 2 >nul
"%~dp0BAT\Diagbox" gd 0f
"%~dp0BAT\7z.exe" x -bso0 "%~dp0BAT\Dats\RedumpPS2.zip" -so > "%~dp0BAT\Dats\PS2\RedumpPS2.dat"
)

:md5processingdump
"%~dp0BAT\Diagbox" gd 0f
echo\
echo PROCESSING...
echo\

REM MD5
set "file=%dump%"
if not exist "%file%" (goto notfoundisc)
call "%~dp0BAT\md5.bat" "%file%" md5 %md5%
findstr %md5% "%~dp0BAT\Dats\PS2\RedumpPS2.dat" > "%~dp0TMP\RedumpDB.txt"

REM CRC32
"%~dp0BAT\crc32" %dump% > "%~dp0TMP\crc32tmp.txt"
"%~dp0BAT\busybox" sed "y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/" "%~dp0TMP\crc32tmp.txt" > "%~dp0TMP\crc32tmp2.txt"
"%~dp0BAT\busybox" cut -c3-11 "%~dp0TMP\crc32tmp2.txt" > "%~dp0TMP\crc32tmp3.txt"
set /P CRC32=<"%~dp0TMP\crc32tmp3.txt"
findstr %CRC32% "%~dp0BAT\Dats\PS2\RedumpPS2.dat" > "%~dp0TMP\CRC32.txt"

REM SHA1
call "%~dp0BAT\sha1.bat" "%file%" sha1 %sha1%
findstr %sha1% "%~dp0BAT\Dats\PS2\RedumpPS2.dat" > "%~dp0TMP\SHA1.txt"

if %errorlevel%==0 (

"%~dp0BAT\Diagbox" gd 0a
echo MD5 Match With Redump Database : %md5%
(goto MatchREDUMP)
"%~dp0BAT\Diagbox" gd 0f

) else ( 

(goto MatchNoRedump)
)

:MatchREDUMP
setlocal DisableDelayedExpansion
REM Name 
"%~dp0BAT\busybox" sed "s/.iso/\n/g" "%~dp0TMP\RedumpDB.txt" > "%~dp0TMP\RedumpNameDB.txt"
"%~dp0BAT\busybox" sed -i "2d" "%~dp0TMP\RedumpNameDB.txt"
"%~dp0BAT\busybox" cut -c13-1000 "%~dp0TMP\RedumpNameDB.txt" > "%~dp0TMP\RedumpNameDBClean.txt"
"%~dp0BAT\busybox" sed -i "s/.iso//g; s/\"//g; s/amp;//g" "%~dp0TMP\RedumpNameDBClean.txt"
set /P redump=<"%~dp0TMP\RedumpNameDBClean.txt"
ren %dump% "%redump%.iso"

REM CRC
REM "%~dp0BAT\busybox" sed "s/.iso/\n/g" "%~dp0TMP\RedumpDB.txt" > "%~dp0TMP\RedumpDBCRC.txt"
REM "%~dp0BAT\busybox" sed -i "1d" "%~dp0TMP\RedumpDBCRC.txt"
REM "%~dp0BAT\busybox" cut -c26-33 "%~dp0TMP\RedumpDBCRC.txt" > "%~dp0TMP\CRC.txt"
REM set /P CRC=<"%~dp0TMP\CRC.txt"

REM SHA1
REM "%~dp0BAT\busybox" sed "s/.iso/\n/g" "%~dp0TMP\RedumpDB.txt" > "%~dp0TMP\RedumpDBSHA1.txt"
REM "%~dp0BAT\busybox" sed -i "1d" "%~dp0TMP\RedumpDBSHA1.txt"
REM "%~dp0BAT\busybox" cut -c81-120 "%~dp0TMP\RedumpDBSHA1.txt" > "%~dp0TMP\SHA1.txt"
REM set /P SHA1=<"%~dp0TMP\SHA1.txt"

REM SIZE
REM "%~dp0BAT\busybox" sed "s/.iso/\n/g" "%~dp0TMP\RedumpDB.txt" > "%~dp0TMP\RedumpDBSIZE.txt"
REM "%~dp0BAT\busybox" sed -i "1d" "%~dp0TMP\RedumpDBSIZE.txt"
REM "%~dp0BAT\busybox" cut -c9-18 "%~dp0TMP\RedumpDBSIZE.txt" > "%~dp0TMP\SIZE.txt"
REM set /P SIZE=<"%~dp0TMP\SIZE.txt"

"%~dp0BAT\Diagbox" gd 0f
echo\
echo DETAIL
echo **********************************************
"%~dp0BAT\Diagbox" gd 0a
echo "%redump%"
echo\
echo ^|CRC: %CRC32%
echo ^|MD5: %MD5%
echo ^|SHA: %SHA1%
REM echo ^|SIZE: %SIZE%
"%~dp0BAT\Diagbox" gd 0f
echo **********************************************
(goto EndRedumpMatch)

:notfoundisc
cls
"%~dp0BAT\Diagbox" gd 06
echo.
echo Insert your disc into your optical drive
echo.
"%~dp0BAT\Diagbox" gd 0f
pause & (goto AdvancedMenu)

:MatchNoRedump
"%~dp0BAT\Diagbox" gd 0c
echo.
echo MD5 NO MATCH WITH Redump Database : %md5%
echo.
"%~dp0BAT\Diagbox" gd 06
echo There can be several reasons
echo.
echo This could be due to a bad dump or to a CD-ROM. 
echo How to differentiate a DVD-ROM from a CD-ROM In general, the CD-ROM is only 700MB 
echo and CD-ROMs are often colored blue under the disc.
echo.
echo Where you have a copy of a game that has never been dumped for more info visit redump.org
echo.
"%~dp0BAT\Diagbox" gd 0f

:EndRedumpMatch
del "%~dp0CD-DVD\hdl_dump.exe" >nul 2>&1
rmdir /Q/S "%~dp0TMP" >nul 2>&1

echo\
"%~dp0BAT\Diagbox" gd 0f
echo ----------------------------------------------------
"%~dp0BAT\Diagbox" gd 0a
echo Dump Completed...
echo\
echo\
"%~dp0BAT\Diagbox" gd 07

pause & (goto AdvancedMenu)

REM ####################################################################################################################################################
:BIN2VCD
cls
cd "%~dp0POPS"

if exist rmdir /s /q temp >nul 2>&1
if exist *.zip %~dp0BAT\7z.exe x -bso0 %~dp0POPS\*.zip
if exist *.rar %~dp0BAT\7z.exe x -bso0 %~dp0POPS\*.rar
if exist *.7z  %~dp0BAT\7z.exe x -bso0 %~dp0POPS\*.7z
if not exist *.cue (goto failmultibin)
md temp >nul 2>&1
md Original >nul 2>&1

for %%f in (*.cue) do %~dp0BAT\binmerge "%%f" "temp\%%~nf"
move *.bin %~dp0POPS\Original >nul 2>&1
move *.cue %~dp0POPS\Original >nul 2>&1

cd "%~dp0POPS\temp"
"%~dp0BAT\busybox" find . -type f -name "*.cue" -exec sed -i "s:temp\\::g" {} + >nul 2>&1
move *.bin "%~dp0POPS" >nul 2>&1
move *.cue "%~dp0POPS" >nul 2>&1
cd "%~dp0POPS"

for %%f in (*.cue) do %~dp0BAT\CUE2POPS_2_3 "%%f"
move *.bin "%~dp0POPS\temp" >nul 2>&1
move *.cue "%~dp0POPS\temp" >nul 2>&1

rmdir /s /q temp >nul 2>&1
echo.

pause & (goto ConversionMenu)

REM ####################################################################################################################################################
:VCD2BIN
cls
cd "%~dp0POPS"

if exist rmdir /s /q temp >nul 2>&1
if exist *.zip %~dp0BAT\7z.exe x -bso0 %~dp0POPS\*.zip
if exist *.rar %~dp0BAT\7z.exe x -bso0 %~dp0POPS\*.rar
if exist *.7z  %~dp0BAT\7z.exe x -bso0 %~dp0POPS\*.7z
if not exist *.vcd (goto failVCD)
md temp >nul 2>&1
md Original >nul 2>&1

for %%f in (*.vcd) do %~dp0BAT\POPS2CUE.EXE "%%f"
move *.vcd "%~dp0POPS\Original" >nul 2>&1

REM ZIP Multiple Tracks
::for %%# in (*.cue) do %~dp0BAT\7z.exe a -bso0 "%%~n#.zip" "%%#" "%%~n# (Track ?).bin" "%%~n# (Track ??).bin"

REM Move BIN/CUE in FOLDER
for %%# in (*.cue) do md "%%~n#" >nul 2>&1
for %%# in (*.cue) do move "%%~n#.bin" "%%~n#" >nul 2>&1
for %%# in (*.cue) do move "%%~n#.cue" "%%~n#" >nul 2>&1

rmdir /s /q temp >nul 2>&1
echo.

pause & (goto ConversionMenu)

:failVCD
"%~dp0BAT\Diagbox" gd 06
echo.
echo .VCD NOT DETECTED: Please drop .VCD IN POPS FOLDER.
echo.
"%~dp0BAT\Diagbox" gd 0f

pause & (goto ConversionMenu)

REM #########################################################################################################################################################
:ECM2BIN
cd "%~dp0POPS"
if exist *.zip %~dp0BAT\7z.exe x -bso0 %~dp0POPS\*.zip
if exist *.rar %~dp0BAT\7z.exe x -bso0 %~dp0POPS\*.rar
if exist *.7z  %~dp0BAT\7z.exe x -bso0 %~dp0POPS\*.7z
if not exist *.ecm (goto failECM)
md temp >nul 2>&1
md Original >nul 2>&1

move *.ecm temp >nul 2>&1
move *.cue temp >nul 2>&1
cd temp >nul 2>&1

for %%f in (*.ecm) do %~dp0BAT\unecm.exe "%%f" "%%~nf"
if not exist "%%~nf.cue" call "%~dp0BAT\cuemaker.bat"

move *.bin %~dp0POPS >nul 2>&1
move *.cue %~dp0POPS >nul 2>&1
move *.ecm %~dp0POPS\Original >nul 2>&1
cd "%~dp0POPS"

rmdir /s /q temp >nul 2>&1
echo.


pause & (goto ConversionMenu)

:failECM
cls
"%~dp0BAT\Diagbox" gd 06
echo.
echo .ECM NOT DETECTED: Please drop .ECM IN POPS FOLDER.
echo.
"%~dp0BAT\Diagbox" gd 0f

pause & (goto ConversionMenu)

REM ##########################################################################################################################################################
:BIN2CHD
cd "%~dp0POPS"
if exist *.zip %~dp0BAT\7z.exe x -bso0 %~dp0POPS\*.zip
if exist *.rar %~dp0BAT\7z.exe x -bso0 %~dp0POPS\*.rar
if exist *.7z  %~dp0BAT\7z.exe x -bso0 %~dp0POPS\*.7z
if not exist *.cue (goto failbin2CHD)
md Original >nul 2>&1

for %%i in (*.cue) do %~dp0BAT\chdman.exe createcd -i "%%i" -o "%%~ni.chd" 
move *.bin %~dp0POPS\Original >nul 2>&1
move *.cue %~dp0POPS\Original >nul 2>&1

echo.

pause & (goto ConversionMenu)

:failCHD2BIN
cls
"%~dp0BAT\Diagbox" gd 06
echo.
echo .CHD NOT DETECTED: Please drop .CHD IN POPS FOLDER.
echo.
"%~dp0BAT\Diagbox" gd 0f

pause & (goto ConversionMenu)

REM ##########################################################################################################################################################
:CHD2BIN
cd "%~dp0POPS"
if exist *.zip %~dp0BAT\7z.exe x -bso0 %~dp0POPS\*.zip
if exist *.rar %~dp0BAT\7z.exe x -bso0 %~dp0POPS\*.rar
if exist *.7z  %~dp0BAT\7z.exe x -bso0 %~dp0POPS\*.7z
if not exist *.chd (goto failCHD2bin)
md Original >nul 2>&1

for %%h in (*.chd) do %~dp0BAT\chdman.exe extractcd -i "%%h" -o "%%~nh.cue"
move *.CHD %~dp0POPS\Original >nul 2>&1

echo.

pause & (goto ConversionMenu)

:failBIN2CHD
cls
"%~dp0BAT\Diagbox" gd 06
echo.
echo .BIN/.CUE NOT DETECTED: Please drop .BIN IN POPS FOLDER.
echo.
"%~dp0BAT\Diagbox" gd 0f

pause & (goto ConversionMenu)

REM ##########################################################################################################################################################
:multibin2bin
cls
cd "%~dp0POPS"

if exist rmdir /s /q temp >nul 2>&1
if exist *.zip %~dp0BAT\7z.exe x -bso0 %~dp0POPS\*.zip
if exist *.rar %~dp0BAT\7z.exe x -bso0 %~dp0POPS\*.rar
if exist *.7z  %~dp0BAT\7z.exe x -bso0 %~dp0POPS\*.7z
if not exist *.cue (goto failmultibin)
md temp >nul 2>&1
md Original >nul 2>&1

for %%f in (*.cue) do %~dp0BAT\binmerge "%%f" "temp\%%~nf"
move *.bin %~dp0POPS\Original >nul 2>&1
move *.cue %~dp0POPS\Original >nul 2>&1

cd "%~dp0POPS\temp"
"%~dp0BAT\busybox" find . -type f -name "*.cue" -exec sed -i "s:temp\\::g" {} + >nul 2>&1
move *.bin "%~dp0POPS" >nul 2>&1
move *.cue "%~dp0POPS" >nul 2>&1
cd "%~dp0POPS"

rmdir /s /q temp >nul 2>&1
echo.

pause & (goto ConversionMenu)

:failmultibin
cls 

"%~dp0BAT\Diagbox" gd 06
echo. 
echo .BIN/.CUE NOT DETECTED: Please drop .BIN/.CUE with the same name in the POPS folder.
echo Also check that the name matches inside the .cue
echo. 
"%~dp0BAT\Diagbox" gd 07

pause & (goto ConversionMenu)

REM ##########################################################################################################################################################
:bin2split
cls
cd "%~dp0POPS"

if exist rmdir /s /q temp >nul 2>&1
if exist *.zip %~dp0BAT\7z.exe x -bso0 %~dp0POPS\*.zip
if exist *.rar %~dp0BAT\7z.exe x -bso0 %~dp0POPS\*.rar
if exist *.7z  %~dp0BAT\7z.exe x -bso0 %~dp0POPS\*.7z
if not exist *.cue (goto failbinsplit)
md temp >nul 2>&1
md Original >nul 2>&1

for %%f in (*.cue) do "%~dp0BAT\binmerge" -s "%%f" "temp\%%~nf"
move *.bin %~dp0POPS\Original >nul 2>&1
move *.cue %~dp0POPS\Original >nul 2>&1

cd "%~dp0POPS\temp"
"%~dp0BAT\busybox" find . -type f -name "*.cue" -exec sed -i "s:temp\\::g" {} + >nul 2>&1
move *.bin "%~dp0POPS" >nul 2>&1
move *.cue "%~dp0POPS" >nul 2>&1
cd "%~dp0POPS"

REM ZIP Multiple Tracks
::for %%# in (*.cue) do %~dp0BAT\7z.exe a -bso0 "%%~n#.zip" "%%#" "%%~n# (Track ?).bin" "%%~n# (Track ??).bin"

REM Move Multiple Tracks in FOLDER
for %%# in (*.cue) do md "%%~n#" >nul 2>&1
for %%# in (*.cue) do move "%%~n# (Track *).bin" "%%~n#" >nul 2>&1
for %%# in (*.cue) do move "%%~n#.cue" "%%~n#" >nul 2>&1

rmdir /s /q temp >nul 2>&1
echo.

pause & (goto ConversionMenu)

:failbinsplit
cls 

"%~dp0BAT\Diagbox" gd 06
echo. 
echo .BIN/.CUE NOT DETECTED: Please drop .BIN/.CUE with the same name in the POPS folder.
echo Also check that the name matches inside the .cue
echo. 
"%~dp0BAT\Diagbox" gd 07

pause & (goto ConversionMenu)

REM OLD Replace
REM setlocal EnableExtensions DisableDelayedExpansion
REM 
REM set "search=temp\"
REM set "replace="
REM 
REM set "textFile=*.cue"
REM set "rootDir=."
REM for /R "%rootDir%" %%j in ("%textFile%") do (
REM for %%j in ("%rootDir%\%textFile%") do (
REM     for /f "delims=" %%i in ('type "%%~j" ^& break ^> "%%~j"') do (
REM         set "line=%%i"
REM         setlocal EnableDelayedExpansion
REM         set "line=!line:%search%=%replace%!"
REM         >>"%%~j" echo(!line!
REM         
REM     )
REM )

REM ###########################################################################################################################################################
:BIN2ISO
cd "%~dp0CD"
if exist *.zip %~dp0BAT\7z.exe x -bso0 %~dp0POPS\*.zip
if exist *.rar %~dp0BAT\7z.exe x -bso0 %~dp0POPS\*.rar
if exist *.7z  %~dp0BAT\7z.exe x -bso0 %~dp0POPS\*.7z
if not exist *.bin (goto failBIN2ISO)
md Original >nul 2>&1

if not exist "%%~nf.cue" call "%~dp0BAT\cuemaker.bat"

echo Converting... .BIN To .ISO
for %%f in (*.bin) do (
"%~dp0BAT\bchunk" "%%~nf.bin" "%%~nf.cue" "%%~nf" >nul 2>&1 
move "%%~nf01.iso" "%%~nf.iso" >nul 2>&1
)

move *.bin "%~dp0CD\Original" >nul 2>&1
move *.cue "%~dp0CD\Original" >nul 2>&1

echo.
echo Conversion completed
echo.

pause & (goto ConversionMenu)

:failBIN2ISO
cls
"%~dp0BAT\Diagbox" gd 06
echo.
echo .BIN/.CUE NOT DETECTED: Please drop .BIN IN CD FOLDER.
echo.
"%~dp0BAT\Diagbox" gd 0f

pause & (goto ConversionMenu)

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
(goto start)
cls

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
echo @@@@@@@@@@@/////////////////////////FUCK-PS2-HOME////////////////////@@@@@@@@@@@
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
