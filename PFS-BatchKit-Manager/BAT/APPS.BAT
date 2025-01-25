@echo off
if not defined UpdateAPPS cls
title PFS BatchKit Manager v1.2.0 By GDX

set GithubUPDATE=no
mkdir "%rootpath%\TMP" >nul 2>&1

if defined @DownloadwLaunchELF (
"%rootpath%\BAT\Diagbox.EXE" gd 0f
echo\
echo\
echo wLaunchELF LATEST
echo ----------------------------------------------------
echo Version: Latest Development build
echo Release Date:
echo Developer: PS2-Community
echo Descriptions: File manager
echo Source code: https://github.com/ps2homebrew/wLaunchELF
echo ----------------------------------------------------
"%rootpath%\BAT\Diagbox.EXE" gd 0a
echo         1^) Yes ^(Download Only^)
"%rootpath%\BAT\Diagbox.EXE" gd 0c
echo         2^) No
"%rootpath%\BAT\Diagbox.EXE" gd 0e
echo         3^) Yes ^(Download ^& Install as partition for HDD-OSD, PSBBN, XMB^)
echo\
"%rootpath%\BAT\Diagbox" gd 07
CHOICE /C 123 /M "Select Option:"

IF !ERRORLEVEL!==1 set "Download=Yes" & set "DownloadOnly=APPS_000.01" & echo APPS_000.01>> "%rootpath%\TMP\APPIDTMP.txt"
IF !ERRORLEVEL!==2 set @wLaunchELF_LATEST=no
IF !ERRORLEVEL!==3 set "Download=Yes" & set "@APPHDDOSD=Yes" & echo APPS_000.01>> "%rootpath%\TMP\APPIDTMP.txt"

"%rootpath%\BAT\Diagbox.EXE" gd 0f
echo\
echo\
echo wLaunchELF kHn
echo ----------------------------------------------------
echo Version: 4.43a
echo Release Date: 10/08/2020
echo Developer: krHACKen
echo Descriptions: File manager allows to launch .VCD files
echo Source code: Not available
echo ----------------------------------------------------
"%rootpath%\BAT\Diagbox.EXE" gd 0a
echo         1^) Yes ^(Download Only^)
"%rootpath%\BAT\Diagbox.EXE" gd 0c
echo         2^) No
"%rootpath%\BAT\Diagbox.EXE" gd 0e
echo         3^) Yes ^(Download ^& Install as partition for HDD-OSD, PSBBN, XMB^)
echo\
"%rootpath%\BAT\Diagbox" gd 07
CHOICE /C 123 /M "Select Option:"

IF !ERRORLEVEL!==1 set "Download=Yes" & set "DownloadOnly=APPS_000.09" & echo APPS_000.09>> "%rootpath%\TMP\APPIDTMP.txt"
IF !ERRORLEVEL!==2 set @wLaunchELF_kHn=no
IF !ERRORLEVEL!==3 set "Download=Yes" & set "@APPHDDOSD=Yes" & echo APPS_000.09>> "%rootpath%\TMP\APPIDTMP.txt"
)

if defined @DownloadOPL (
"%rootpath%\BAT\Diagbox.EXE" gd 0f
echo\
echo\
echo Open PS2 Loader Latest
echo ----------------------------------------------------
echo Version: Latest Development build
echo Release Date:
echo Developer: PS2-Community
echo Descriptions: Game Loader
echo Source code: https://github.com/ps2homebrew/Open-PS2-Loader
echo ----------------------------------------------------
"%rootpath%\BAT\Diagbox.EXE" gd 0a
echo         1^) Yes ^(Download Only^)
"%rootpath%\BAT\Diagbox.EXE" gd 0c
echo         2^) No
"%rootpath%\BAT\Diagbox.EXE" gd 0e
echo         3^) Yes ^(Download ^& Install as partition for HDD-OSD, PSBBN, XMB^)
echo\
"%rootpath%\BAT\Diagbox" gd 07
CHOICE /C 123 /M "Select Option:"

IF !ERRORLEVEL!==1 set "Download=Yes" & set "DownloadOnly=APPS_000.02" & echo APPS_000.02>> "%rootpath%\TMP\APPIDTMP.txt"
IF !ERRORLEVEL!==2 set @OpenPS2Loader_LATEST=no
IF !ERRORLEVEL!==3 ( set "Download=Yes" & set "@APPHDDOSD=Yes" & echo APPS_000.02>> "%rootpath%\TMP\APPIDTMP.txt"

echo\
echo Do you want to change partition size for this APP^?
echo By default it will be 128MB
CHOICE /C YN
IF !ERRORLEVEL!==1 (
echo\
echo\
echo The size must be multiplied by 128
echo Example: 128 x 5 = 640MB
echo Max size per partition 128GB
echo\
echo Example:
echo If you want a 10GB partition Type: 10G
echo If you want a 512MB partition Type: 512M
echo If you want a 1.5GB partition 1024 + 512 = 1536 Type: 1536M
set /p "partsize=Enter partition size:"
IF "!partsize!"=="" echo 128M> "%rootpath%\TMP\APPS-000.08-SIZE.txt"
echo !partsize!> "%rootpath%\TMP\APPS-00002-SIZE.txt")

echo\
echo Do you want to run your games from HDD-OSD, PSBBN, XMB with this version of OPL?
CHOICE /C YN
IF !ERRORLEVEL!==1 echo OPLELFROOT > "%rootpath%\TMP\APPS_000.02-OPLELFROOT.txt"
 )

"%rootpath%\BAT\Diagbox.EXE" gd 0f
echo\
echo\
echo Open PS2 Loader Stable
echo ----------------------------------------------------
echo Version: v1.2.0-2045
echo Release Date:
echo Developer: PS2-Community
echo Descriptions: Game Loader
echo Source code: https://github.com/ps2homebrew/Open-PS2-Loader
echo ----------------------------------------------------
"%rootpath%\BAT\Diagbox.EXE" gd 0a
echo         1^) Yes ^(Download Only^)
"%rootpath%\BAT\Diagbox.EXE" gd 0c
echo         2^) No
"%rootpath%\BAT\Diagbox.EXE" gd 0e
echo         3^) Yes ^(Download ^& Install as partition for HDD-OSD, PSBBN, XMB^)
echo\
"%rootpath%\BAT\Diagbox" gd 07
CHOICE /C 123 /M "Select Option:"

IF !ERRORLEVEL!==1 set "Download=Yes" & set "DownloadOnly=APPS_000.16" & echo APPS_000.16>> "%rootpath%\TMP\APPIDTMP.txt"
IF !ERRORLEVEL!==2 set @OpenPS2Loader_STABLE=no
IF !ERRORLEVEL!==3 ( set "Download=Yes" & set "@APPHDDOSD=Yes" & echo APPS_000.16>> "%rootpath%\TMP\APPIDTMP.txt"

echo\
echo Do you want to change partition size for this APP^?
echo By default it will be 128MB
CHOICE /C YN
IF !ERRORLEVEL!==1 (
echo\
echo\
echo The size must be multiplied by 128
echo Example: 128 x 5 = 640MB
echo Max size per partition 128GB
echo\
echo Example:
echo If you want a 10GB partition Type: 10G
echo If you want a 512MB partition Type: 512M
echo If you want a 1.5GB partition 1024 + 512 = 1536 Type: 1536M
set /p "partsize=Enter partition size:"
IF "!partsize!"=="" echo 128M> "%rootpath%\TMP\APPS-00016-SIZE.txt"
echo !partsize!> "%rootpath%\TMP\APPS-00016-SIZE.txt")

echo\
echo Do you want to run your games from HDD-OSD, PSBBN, XMB with this version of OPL?
CHOICE /C YN
IF !ERRORLEVEL!==1 echo OPLELFROOT > "%rootpath%\TMP\APPS_000.16-OPLELFROOT.txt"
 )
)

if defined @DownloadUtilities (
"%rootpath%\BAT\Diagbox.EXE" gd 0f
echo\
echo\
echo Memory Card Annihilator
echo ----------------------------------------------------
echo Version: 2.0a
echo Release Date: 22/01/2022
echo Developer: ffgriever
echo Descriptions: Formatting/Unformatting memory cards
echo Source code:
echo ----------------------------------------------------
"%rootpath%\BAT\Diagbox.EXE" gd 0a
echo         1^) Yes ^(Download Only^)
"%rootpath%\BAT\Diagbox.EXE" gd 0c
echo         2^) No
"%rootpath%\BAT\Diagbox.EXE" gd 0e
echo         3^) Yes ^(Download ^& Install as partition for HDD-OSD, PSBBN, XMB^)
echo\
"%rootpath%\BAT\Diagbox" gd 07
CHOICE /C 123 /M "Select Option:"

IF !ERRORLEVEL!==1 set "Download=Yes" & set "DownloadOnly=APPS_000.03" & echo APPS_000.03>> "%rootpath%\TMP\APPIDTMP.txt"
IF !ERRORLEVEL!==2 set @MemoryCardAnnihilator=no
IF !ERRORLEVEL!==3 set "Download=Yes" & set "@APPHDDOSD=Yes" & echo APPS_000.03>> "%rootpath%\TMP\APPIDTMP.txt"

"%rootpath%\BAT\Diagbox.EXE" gd 0f
echo\
echo\
echo Apollo Save Tool
echo ----------------------------------------------------
echo Version: 0.7.0
echo Release Date: 03/02/2022
echo Developer: bucanero
echo Descriptions: Apollo Save Tool is an application to manage save-game files
echo Source code: https://github.com/bucanero/apollo-ps2
echo ----------------------------------------------------
"%rootpath%\BAT\Diagbox.EXE" gd 0a
echo         1^) Yes ^(Download Only^)
"%rootpath%\BAT\Diagbox.EXE" gd 0c
echo         2^) No
"%rootpath%\BAT\Diagbox.EXE" gd 0e
echo         3^) Yes ^(Download ^& Install as partition for HDD-OSD, PSBBN, XMB^)
echo\
"%rootpath%\BAT\Diagbox" gd 07
CHOICE /C 123 /M "Select Option:"

IF !ERRORLEVEL!==1 set "Download=Yes" & set "DownloadOnly=APPS_000.20" & echo APPS_000.20>> "%rootpath%\TMP\APPIDTMP.txt"
IF !ERRORLEVEL!==2 set @ApolloSaveTool=no
IF !ERRORLEVEL!==3 set "Download=Yes" & set "@APPHDDOSD=Yes" & echo APPS_000.20>> "%rootpath%\TMP\APPIDTMP.txt"

"%rootpath%\BAT\Diagbox.EXE" gd 0f
echo\
echo\
echo HDD Checker
echo ----------------------------------------------------
echo Version: 0.964
echo Release Date: 13/04/2019
echo Developer: SP193
echo Descriptions: HDD Diagnostic tool
echo Source code: https://github.com/ps2homebrew/HDDChecker
echo ----------------------------------------------------
"%rootpath%\BAT\Diagbox.EXE" gd 0a
echo         1^) Yes ^(Download Only^)
"%rootpath%\BAT\Diagbox.EXE" gd 0c
echo         2^) No
"%rootpath%\BAT\Diagbox.EXE" gd 0e
echo         3^) Yes ^(Download ^& Install as partition for HDD-OSD, PSBBN, XMB^)
echo\
"%rootpath%\BAT\Diagbox" gd 07
CHOICE /C 123 /M "Select Option:"

IF !ERRORLEVEL!==1 set "Download=Yes" & set "DownloadOnly=APPS_000.04" & echo APPS_000.04>> "%rootpath%\TMP\APPIDTMP.txt"
IF !ERRORLEVEL!==2 set @HDDChecker_LATEST=no
IF !ERRORLEVEL!==3 set "Download=Yes" & set "@APPHDDOSD=Yes" & echo APPS_000.04>> "%rootpath%\TMP\APPIDTMP.txt"

"%rootpath%\BAT\Diagbox.EXE" gd 0f
echo\
echo\
echo PlayStation 2 Identification tool
echo ----------------------------------------------------
echo Version: Latest Development build
echo Release Date:
echo Developer: PS2-Community
echo Descriptions: PS2Ident allows dumps of a PlayStation 2 console's ROM chips and MECHACON NVRAM
echo Source code: https://github.com/ps2homebrew/PS2Ident
echo ----------------------------------------------------
"%rootpath%\BAT\Diagbox.EXE" gd 0a
echo         1^) Yes ^(Download Only^)
"%rootpath%\BAT\Diagbox.EXE" gd 0c
echo         2^) No
"%rootpath%\BAT\Diagbox.EXE" gd 0e
REM echo         3^) Yes ^(Download ^& Install as partition for HDD-OSD, PSBBN, XMB^)
echo\
"%rootpath%\BAT\Diagbox" gd 07
CHOICE /C 12 /M "Select Option:"

IF !ERRORLEVEL!==1 set "Download=Yes" & set "DownloadOnly=APPS_000.05" & echo APPS_000.05>> "%rootpath%\TMP\APPIDTMP.txt"
IF !ERRORLEVEL!==2 set @PS2IDENT_LATEST=no
REM IF !ERRORLEVEL!==3 set "Download=Yes" & set "@APPHDDOSD=Yes" & echo APPS_000.05>> "%rootpath%\TMP\APPIDTMP.txt"

"%rootpath%\BAT\Diagbox.EXE" gd 0f
echo\
echo\
echo Graphics Synthesizer Mode Selector
echo ----------------------------------------------------
echo Version: 0.38
echo Release Date: 24/08/2014
echo Developer: doctorxyz, dlanor, SP193, reprep
echo Descriptions: GSM allows upscaling
echo Source code: https://github.com/doctorxyz/gsm
echo ----------------------------------------------------
"%rootpath%\BAT\Diagbox.EXE" gd 0a
echo         1^) Yes ^(Download Only^)
"%rootpath%\BAT\Diagbox.EXE" gd 0c
echo         2^) No
"%rootpath%\BAT\Diagbox.EXE" gd 0e
echo         3^) Yes ^(Download ^& Install as partition for HDD-OSD, PSBBN, XMB^)
echo\
"%rootpath%\BAT\Diagbox" gd 07
CHOICE /C 123 /M "Select Option:"

IF !ERRORLEVEL!==1 set "Download=Yes" & set "DownloadOnly=APPS_000.06" & echo APPS_000.06>> "%rootpath%\TMP\APPIDTMP.txt"
IF !ERRORLEVEL!==2 set @GSM=no
IF !ERRORLEVEL!==3 set "Download=Yes" & set "@APPHDDOSD=Yes" & echo APPS_000.06>> "%rootpath%\TMP\APPIDTMP.txt"

"%rootpath%\BAT\Diagbox.EXE" gd 0f
echo\
echo\
echo ESR
echo ----------------------------------------------------
echo Version: R10F
echo Release Date: 20/07/2020
echo Developer: ffgriever
echo Descriptions: Load game backups and homebrew software from DVD
echo Source code: https://gitlab.com/ffgriever/esr/
echo ----------------------------------------------------
"%rootpath%\BAT\Diagbox.EXE" gd 0a
echo         1^) Yes ^(Download Only^)
"%rootpath%\BAT\Diagbox.EXE" gd 0c
echo         2^) No
"%rootpath%\BAT\Diagbox.EXE" gd 0e
echo         3^) Yes ^(Download ^& Install as partition for HDD-OSD, PSBBN, XMB^)
echo\
"%rootpath%\BAT\Diagbox" gd 07
CHOICE /C 123 /M "Select Option:"

IF !ERRORLEVEL!==1 set "Download=Yes" & set "DownloadOnly=APPS_000.07" & echo APPS_000.07>> "%rootpath%\TMP\APPIDTMP.txt"
IF !ERRORLEVEL!==2 set @ESR=no
IF !ERRORLEVEL!==3 set "Download=Yes" & set "@APPHDDOSD=Yes" & echo APPS_000.07>> "%rootpath%\TMP\APPIDTMP.txt"

"%rootpath%\BAT\Diagbox.EXE" gd 0f
echo\
echo\
echo Cheat Device PS2 [NTSC-U]
echo ----------------------------------------------------
echo Version: 1.7.5
echo Release Date: 16/06/2020
echo Developer: root670
echo Descriptions: Load game cheats like Action Replay, GameShark, and CodeBreaker
echo Source code: https://github.com/root670/CheatDevicePS2
echo ----------------------------------------------------
"%rootpath%\BAT\Diagbox.EXE" gd 0a
echo         1^) Yes ^(Download Only^)
"%rootpath%\BAT\Diagbox.EXE" gd 0c
echo         2^) No
"%rootpath%\BAT\Diagbox.EXE" gd 0e
echo         3^) Yes ^(Download ^& Install as partition for HDD-OSD, PSBBN, XMB^)
echo\
"%rootpath%\BAT\Diagbox" gd 07
CHOICE /C 123 /M "Select Option:"

IF !ERRORLEVEL!==1 set "Download=Yes" & set "DownloadOnly=APPS_000.18" & echo APPS_000.18>> "%rootpath%\TMP\APPIDTMP.txt"
IF !ERRORLEVEL!==2 set @CheatDVPS2=no
IF !ERRORLEVEL!==3 set "Download=Yes" & set "@APPHDDOSD=Yes" & echo APPS_000.18>> "%rootpath%\TMP\APPIDTMP.txt"

"%rootpath%\BAT\Diagbox.EXE" gd 0f
echo\
echo\
echo Cheat Device PS2 [PAL]
echo ----------------------------------------------------
echo Version: 1.7.5
echo Release Date: 16/06/2020
echo Developer: root670
echo Descriptions: Load game cheats like Action Replay, GameShark, and CodeBreaker
echo Source code: https://github.com/root670/CheatDevicePS2
echo ----------------------------------------------------
"%rootpath%\BAT\Diagbox.EXE" gd 0a
echo         1^) Yes ^(Download Only^)
"%rootpath%\BAT\Diagbox.EXE" gd 0c
echo         2^) No
"%rootpath%\BAT\Diagbox.EXE" gd 0e
echo         3^) Yes ^(Download ^& Install as partition for HDD-OSD, PSBBN, XMB^)
echo\
"%rootpath%\BAT\Diagbox" gd 07
CHOICE /C 123 /M "Select Option:"

IF !ERRORLEVEL!==1 set "Download=Yes" & set "DownloadOnly=APPS_000.17" & echo APPS_000.17>> "%rootpath%\TMP\APPIDTMP.txt"
IF !ERRORLEVEL!==2 set @CheatDVPS2=no
IF !ERRORLEVEL!==3 set "Download=Yes" & set "@APPHDDOSD=Yes" & echo APPS_000.17>> "%rootpath%\TMP\APPIDTMP.txt"
)

if defined @DownloadEmulators (
"%rootpath%\BAT\Diagbox.EXE" gd 0f
echo\
echo\
echo RetroArch
echo ----------------------------------------------------
echo Version: Latest Development build
echo Release Date: !date!
echo Developer: Libretro
echo Descriptions: Load Multiple emulators
echo Source code: https://github.com/libretro/RetroArch
echo ----------------------------------------------------
"%rootpath%\BAT\Diagbox.EXE" gd 0a
echo         1^) Yes ^(Download Only^)
"%rootpath%\BAT\Diagbox.EXE" gd 0c
echo         2^) No
"%rootpath%\BAT\Diagbox.EXE" gd 0e
echo         3^) Yes ^(Download ^& Install as partition for HDD-OSD, PSBBN, XMB^)
echo\
"%rootpath%\BAT\Diagbox" gd 07
CHOICE /C 123 /M "Select Option:"

IF !ERRORLEVEL!==1 set "Download=Yes" & set "DownloadOnly=APPS_000.10" & echo APPS_000.10>> "%rootpath%\TMP\APPIDTMP.txt"
IF !ERRORLEVEL!==2 set @RetroArch_LATEST=no
IF !ERRORLEVEL!==3 ( set "Download=Yes" & set "@APPHDDOSD=Yes" & echo APPS_000.10>> "%rootpath%\TMP\APPIDTMP.txt"

echo\
echo Do you want to change partition size for this APP^?
echo By default it will be 128MB
CHOICE /C YN
IF !ERRORLEVEL!==1 (
echo\
echo\
echo The size must be multiplied by 128
echo Example: 128 x 5 = 640MB
echo Max size per partition 128GB
echo\
echo Example:
echo If you want a 10GB partition Type: 10G
echo If you want a 512MB partition Type: 512M
echo If you want a 1.5GB partition 1024 + 512 = 1536 Type: 1536M
set /p "partsize=Enter partition size:"
IF "!partsize!"=="" echo !partsize!> "%rootpath%\TMP\APPS-00010-SIZE.txt"
echo !partsize!> "%rootpath%\TMP\APPS-00010-SIZE.txt")
 )
)


if defined @DownloadMultiMedia (
"%rootpath%\BAT\Diagbox.EXE" gd 0f
echo\
echo\
echo Simple Media System
echo ----------------------------------------------------
echo Version: 2.9 ^(Rev4^)
echo Release Date: 09/11/2009
echo Developer: Eugene Plotnikov
echo Descriptions: Media Player
echo Source code: https://github.com/ps2homebrew/SMS
echo ----------------------------------------------------
"%rootpath%\BAT\Diagbox.EXE" gd 0a
echo         1^) Yes ^(Download Only^)
"%rootpath%\BAT\Diagbox.EXE" gd 0c
echo         2^) No
"%rootpath%\BAT\Diagbox.EXE" gd 0e
echo         3^) Yes ^(Download ^& Install as partition for HDD-OSD, PSBBN, XMB^)
echo\
"%rootpath%\BAT\Diagbox" gd 07
CHOICE /C 123 /M "Select Option:"

IF !ERRORLEVEL!==1 set "Download=Yes" & set "DownloadOnly=APPS_000.08" & echo APPS_000.08>> "%rootpath%\TMP\APPIDTMP.txt"
IF !ERRORLEVEL!==2 set @SMS=no
IF !ERRORLEVEL!==3 ( set "Download=Yes" & set "@APPHDDOSD=Yes" & echo APPS_000.08>> "%rootpath%\TMP\APPIDTMP.txt"

echo\
echo Do you want to change partition size for this APP^?
echo By default it will be 128MB
CHOICE /C YN
IF !ERRORLEVEL!==1 (
echo\
echo\
echo The size must be multiplied by 128
echo Example: 128 x 5 = 640MB
echo Max size per partition 128GB
echo\
echo Example:
echo If you want a 10GB partition Type: 10G
echo If you want a 512MB partition Type: 512M
echo If you want a 1.5GB partition 1024 + 512 = 1536 Type: 1536M
set /p "partsize=Enter partition size:"
IF "!partsize!"=="" echo 128M> "%rootpath%\TMP\APPS-000.08-SIZE.txt"
echo !partsize!> "%rootpath%\TMP\APPS-000.08-SIZE.txt")
 )
)


if defined @DownloadHardware (
"%rootpath%\BAT\Diagbox.EXE" gd 0f
echo\
echo\
echo MechaPwn
echo ----------------------------------------------------
echo Version: 3.0RC4
echo Release Date: 07/10/2022
echo Developer: Balázs Triszka
echo Descriptions: Unlock Region from CD-DVD player
echo Source code: https://github.com/MechaResearch/MechaPwn
"%rootpath%\BAT\Diagbox.EXE" gd 06
echo WARNING: This application can damage your console if not used correctly.
"%rootpath%\BAT\Diagbox.EXE" gd 0f
echo ----------------------------------------------------
"%rootpath%\BAT\Diagbox.EXE" gd 0a
echo         1^) Yes ^(Download Only^)
"%rootpath%\BAT\Diagbox.EXE" gd 0c
echo         2^) No
"%rootpath%\BAT\Diagbox.EXE" gd 0e
echo\
"%rootpath%\BAT\Diagbox" gd 07
CHOICE /C 12 /M "Select Option:"

IF !ERRORLEVEL!==1 set "Download=Yes" & set "DownloadOnly=APPS_000.11" & echo APPS_000.11>> "%rootpath%\TMP\APPIDTMP.txt"
IF !ERRORLEVEL!==2 set @MechaPwn=no

"%rootpath%\BAT\Diagbox.EXE" gd 0f
echo\
echo\
echo Lens Changer
echo ----------------------------------------------------
echo Version: 1.2b
echo Release Date: 11/07/2018
echo Developer: Dampro
echo Descriptions: Reprogram the EEPROM
echo Source code:
"%rootpath%\BAT\Diagbox.EXE" gd 06
echo WARNING: This application can damage your console if not used correctly.
"%rootpath%\BAT\Diagbox.EXE" gd 0f
echo ----------------------------------------------------
"%rootpath%\BAT\Diagbox.EXE" gd 0a
echo         1^) Yes ^(Download Only^)
"%rootpath%\BAT\Diagbox.EXE" gd 0c
echo         2^) No
"%rootpath%\BAT\Diagbox.EXE" gd 0e
echo\
"%rootpath%\BAT\Diagbox" gd 07
CHOICE /C 123 /M "Select Option:"

IF !ERRORLEVEL!==1 set "Download=Yes" & set "DownloadOnly=APPS_000.12" & echo APPS_000.12>> "%rootpath%\TMP\APPIDTMP.txt"
IF !ERRORLEVEL!==2 set @LensChanger=no

"%rootpath%\BAT\Diagbox.EXE" gd 0f
echo\
echo\
echo PS2 RDRAM Test
echo ----------------------------------------------------
echo Version: 1.2b
echo Release Date: 07/03/2020
echo Developer: krat0s
echo Descriptions: RAM Health Diagnostic
echo Source code: Included in archive
echo ----------------------------------------------------
"%rootpath%\BAT\Diagbox.EXE" gd 0a
echo         1^) Yes ^(Download Only^)
"%rootpath%\BAT\Diagbox.EXE" gd 0c
echo         2^) No
"%rootpath%\BAT\Diagbox.EXE" gd 0e
echo\
"%rootpath%\BAT\Diagbox" gd 07
CHOICE /C 123 /M "Select Option:"

IF !ERRORLEVEL!==1 set "Download=Yes" & set "DownloadOnly=APPS_000.13" & echo APPS_000.13>> "%rootpath%\TMP\APPIDTMP.txt"
IF !ERRORLEVEL!==2 set @PS2RDRAMTest=no

"%rootpath%\BAT\Diagbox.EXE" gd 0f
echo\
echo\
echo PS2 Controller Tester
echo ----------------------------------------------------
echo Version: 1.0
echo Release Date: 18/07/2018
echo Developer: jbit
echo Descriptions: Testing PS1 ^& PS2 Controller
echo Source code:
echo ----------------------------------------------------
"%rootpath%\BAT\Diagbox.EXE" gd 0a
echo         1^) Yes ^(Download Only^)
"%rootpath%\BAT\Diagbox.EXE" gd 0c
echo         2^) No
"%rootpath%\BAT\Diagbox.EXE" gd 0e
echo\
"%rootpath%\BAT\Diagbox" gd 07
CHOICE /C 123 /M "Select Option:"

IF !ERRORLEVEL!==1 set "Download=Yes" & set "DownloadOnly=APPS_000.14" & echo APPS_000.14>> "%rootpath%\TMP\APPIDTMP.txt"
IF !ERRORLEVEL!==2 set @PS2ControllerTester=no


"%rootpath%\BAT\Diagbox.EXE" gd 0f
echo\
echo\
echo PS2 Temperature
echo ----------------------------------------------------
echo Version: 0.1
echo Release Date: 18/01/2020
echo Developer: krat0s
echo Descriptions: Display the temperatures of your PS2
echo Source code: Included in archive
echo ----------------------------------------------------
"%rootpath%\BAT\Diagbox.EXE" gd 0a
echo         1^) Yes ^(Download Only^)
"%rootpath%\BAT\Diagbox.EXE" gd 0c
echo         2^) No
"%rootpath%\BAT\Diagbox.EXE" gd 0e
echo\
"%rootpath%\BAT\Diagbox" gd 07
CHOICE /C 123 /M "Select Option:"

IF !ERRORLEVEL!==1 set "Download=Yes" & set "DownloadOnly=APPS_000.15" & echo APPS_000.15>> "%rootpath%\TMP\APPIDTMP.txt"
IF !ERRORLEVEL!==2 set @PS2Temp=no
)


if defined @APPHDDOSD (
if exist "%rootpath%\HDD-OSD-Icons-Pack.zip" (

cd /d "%rootpath%\TMP"
echo\
"%rootpath%\BAT\Diagbox" gd 0e
echo HDD-OSD-Icons-Pack.zip detected do you want use it?
"%rootpath%\BAT\Diagbox" gd 0f
CHOICE /C YN /M "Select Option:"
IF ERRORLEVEL 1 set uselocalARTHDDOSD=yes
IF ERRORLEVEL 2 set uselocalARTHDDOSD=no
) else (set uselocalARTHDDOSD=no)

if !uselocalARTHDDOSD!==no (
    echo\
	echo Checking internet Or Website connection... For HDD-OSD ART
	ping -n 1 -w 2000 archive.org >nul
	if errorlevel 1 (
			"%rootpath%\BAT\Diagbox" gd 0c
			echo Unable to PING^^!
			if exist "%rootpath%\HDD-OSD-Icons-Pack.zip" set uselocalARTHDDOSD=yes
			"%rootpath%BAT\Diagbox" gd 07
			) else (
			
	"%rootpath%\BAT\wget" -q --show-progress "https://archive.org/download/hdd-osd-icons-pack/HDD-OSD-Icons-Pack.zip/PS1%%2FSCES_000.01%%2FPreview.png" -O "%rootpath%\TMP\Preview.png" >nul 2>&1
	for %%F in (Preview.png) do if %%~zF==0 del "%%F"

if not exist "%rootpath%\TMP\Preview.png" (
"%rootpath%\BAT\Diagbox" gd 0c
    echo\
	echo Unable to connect to internet Or Website
	if exist "%rootpath%\HDD-OSD-Icons-Pack.zip" set uselocalARTHDDOSD=yes
	echo You will switch to offline mode
	echo\
	echo\
"%rootpath%\BAT\Diagbox" gd 0f
	pause
			) else (set DownloadARTHDDOSD=yes)
		)
	)
)
"%rootpath%\BAT\Diagbox.EXE" gd 0f
cd /d "%rootpath%"
cls

if !Download!==Yes (
echo\
echo\
echo Downloading
echo ----------------------------------------------------
echo\

	setlocal DisableDelayedExpansion
	cd /d "%rootpath%\TMP" & for /f "tokens=*" %%i in (APPIDTMP.txt) do (
	for /f "tokens=1*" %%A in ( 'findstr %%i "%rootpath%\BAT\TitlesDB\TitlesDB_APP.txt"' ) do (
	endlocal
	set "appfolder=%%B"
	set "Titleid=%%i"
	setlocal EnableDelayedExpansion

  rmdir /Q/S "%rootpath%\APPS\!appfolder!" >nul 2>&1
  md "%rootpath%\APPS\!appfolder!" >nul 2>&1
  
  echo\
  echo !appfolder!
  "%rootpath%\BAT\7-Zip\7z" x -bso0 "%rootpath%\BAT\APPS.zip" -o"%rootpath%" "APPS\!appfolder!" -r -y
  
  REM Download Latest development builds
  if !Titleid!==APPS_000.01 "%rootpath%\BAT\wget.exe" -q --show-progress https://github.com/ps2homebrew/wLaunchELF/releases/download/latest/BOOT.ELF >nul 2>&1 -O "%rootpath%\APPS\!appfolder!\BOOT.ELF"
  
  if !Titleid!==APPS_000.02 (
  del "%rootpath%\APPS\!appfolder!\*.elf"
  "%rootpath%\BAT\wget.exe" -q --show-progress https://github.com/ps2homebrew/Open-PS2-Loader/releases/download/latest/OPNPS2LD.7z >nul 2>&1 -O "%rootpath%\TMP\Open PS2 Loader Latest.7z"
  "%rootpath%\BAT\7-Zip\7z" x -bso0 "%rootpath%\TMP\Open PS2 Loader Latest.7z" -o"%rootpath%\TMP" * -r -y >nul 2>&1
  move "%rootpath%\TMP\OPNPS2LD\*" "%rootpath%\APPS\Open PS2 Loader Latest\" >nul 2>&1
  )
  
  if !Titleid!==APPS_000.10 (
  "%rootpath%\BAT\wget" "https://buildbot.libretro.com/nightly/playstation/ps2/RetroArch_elf.7z" >nul 2>&1 -O "%rootpath%\TMP\RetroArch.7z"
  "%rootpath%\BAT\7-Zip\7z" x -bso0 "%rootpath%\TMP\RetroArch.7z" -o"%rootpath%\TMP\" -r -y >nul 2>&1
   ROBOCOPY /E /MOVE "%rootpath%\TMP\retroarch" "%rootpath%\APPS\RetroArch" >nul 2>&1
  )
   
   for %%f in ("%rootpath%\APPS\!appfolder!\*.elf") do if %%~zf==0 (del "%%f")
   
   if not exist "%rootpath%\APPS\!appfolder!\*.elf" (
   "%rootpath%\BAT\Diagbox.EXE" gd 0c
   echo An error occurred while downloading. An earlier version will be downloaded instead.
   "%rootpath%\BAT\7-Zip\7z" x -bso0 "%rootpath%\BAT\APPS.zip" -o"%rootpath%" "APPS\!appfolder!" -r -y
   "%rootpath%\BAT\Diagbox.EXE" gd 0f
   ) else (
   "%rootpath%\BAT\Diagbox.EXE" gd 0a
   echo 100%% Done
   "%rootpath%\BAT\Diagbox.EXE" gd 0f
   )
   
   REM Some parameter
   if !Titleid!==APPS_000.02 ren "%rootpath%\APPS\!appfolder!\*.elf" OPNPS2LD.ELF
   if !Titleid!==APPS_000.16 ren "%rootpath%\APPS\!appfolder!\*.elf" OPNPS2LD.ELF
   
   if !DownloadOnly!==!Titleid! "%rootpath%\BAT\busybox" sed -i "/!Titleid!/d" "%rootpath%/TMP/APPIDTMP.txt"
    )
   )
  )
 
  if !USEOPL!==LATEST (
  "%rootpath%\BAT\wget.exe" -q --show-progress https://github.com/ps2homebrew/Open-PS2-Loader/releases/download/latest/OPNPS2LD.7z >nul 2>&1 -O "%rootpath%\TMP\Open PS2 Loader Latest.7z"
  "%rootpath%\BAT\7-Zip\7z" x -bso0 "%rootpath%\TMP\Open PS2 Loader Latest.7z" -o"%rootpath%\TMP" * -r -y >nul 2>&1
  move "%rootpath%\TMP\OPNPS2LD\*.ELF" "%rootpath%\TMP\OPNPS2LD.ELF" >nul 2>&1
  )
  if !USEOPL!==STABLE "%rootpath%\BAT\7-Zip\7z" x -bso0 "%rootpath%\BAT\APPS.zip" -o"%rootpath%\TMP" "APPS\Open PS2 Loader Stable" -r -y & move "%rootpath%\TMP\APPS\Open PS2 Loader Stable\*.ELF" "%rootpath%\TMP\OPNPS2LD.ELF" >nul 2>&1
  endlocal

title PFS BatchKit Manager v1.2.0 By GDX
REM HDD-OSD, PSBBN, XMB
IF !@APPHDDOSD!==Yes (
echo\
echo\
pause

cls
IF NOT DEFINED @hdl_path ( rmdir /Q/S "%rootpath%\TMP" >nul 2>&1 & call "%rootpath%\^!PFS-BatchKit-Manager.bat" ) else (
"%rootpath%\BAT\Diagbox" gd 0e
echo\
echo\
echo Scanning for Playstation 2 HDDs:
echo ----------------------------------------------------
"%rootpath%\BAT\Diagbox" gd 03
"%rootpath%\BAT\hdl_dump" query | "%rootpath%\BAT\busybox" grep "!@hdl_path!" | "%rootpath%\BAT\busybox" grep "Playstation 2 HDD" >nul
if errorlevel 1 set "@hdl_path=" & call "%rootpath%\^!PFS-BatchKit-Manager.bat"
echo       [!@hdl_path! !@TotalHDD_Size! - !@ModelePS2HDD!]
)

    REM if exist "%USERPROFILE%\PS2KEYS.DAT" copy "%USERPROFILE%\PS2KEYS.DAT" "%rootpath%\BAT" >nul 2>&1
	
	setlocal DisableDelayedExpansion
	cd /d "%rootpath%\TMP" & for /f "tokens=*" %%i in (APPIDTMP.txt) do (
	
	for /f "tokens=1*" %%A in ( 'findstr %%i "%rootpath%\BAT\TitlesDB\TitlesDB_APP.txt"' ) do (
	set "appfolder=%%B"
	set "Titleid2=%%i"
	set "Contentweb="
	)
	
	setlocal EnableDelayedExpansion
    echo !Titleid2!| "%rootpath%\BAT\busybox" sed -e "s/_/-/g; s/\.//g" > "%rootpath%\TMP\APPIDTMP2.txt" & set /P Titleid=<"%rootpath%\TMP\APPIDTMP2.txt"

"%rootpath%\BAT\Diagbox" gd 0f
echo\
echo\
if not defined UpdateAPPS echo Installing !appfolder!
if defined UpdateAPPS echo Updating !appfolder!
"%rootpath%\BAT\Diagbox" gd 0e
echo ----------------------------------------------------
"%rootpath%\BAT\Diagbox" gd 03
cd /d "%rootpath%\APPS\!appfolder!"

    "%rootpath%\BAT\7-Zip\7z" x -bso0 "%rootpath%\BAT\HDD-PSBBN_XMB_SAMPLE_HEADER.zip" res\* -o"%rootpath%\APPS\!appfolder!" -r- -y >nul 2>&1
	"%rootpath%\BAT\7-Zip\7z" x -bso0 "%rootpath%\BAT\HDD-OSD_SAMPLE_HEADER.zip" -o"%rootpath%\TMP" APP\* -r -y >nul 2>&1
	
	REM Get infos
	"%rootpath%\BAT\busybox" sed -n "/<game serial=\"!Titleid!\">/,/<\/game>/ {s/.*<PartName>\(.*\)<\/PartName>.*/\1/p}" "%rootpath%\BAT\APPDB.xml" > "%rootpath%\TMP\PartName.txt" & set /P PartName=<"%rootpath%\TMP\PartName.txt"
	"%rootpath%\BAT\busybox" sed -n "/<game serial=\"!Titleid!\">/,/<\/game>/ {s/.*<Title>\(.*\)<\/Title>.*/\1/p}" "%rootpath%\BAT\APPDB.xml" > "%rootpath%\TMP\Title.txt" & set /P Title=<"%rootpath%\TMP\Title.txt"
	"%rootpath%\BAT\busybox" sed -n "/<game serial=\"!Titleid!\">/,/<\/game>/ {s/.*<Release>\(.*\)<\/Release>.*/\1/p}" "%rootpath%\BAT\APPDB.xml" > "%rootpath%\TMP\Release.txt" & set /P Release=<"%rootpath%\TMP\Release.txt"
	"%rootpath%\BAT\busybox" sed -n "/<game serial=\"!Titleid!\">/,/<\/game>/ {s/.*<Developer>\(.*\)<\/Developer>.*/\1/p}" "%rootpath%\BAT\APPDB.xml" > "%rootpath%\TMP\Devloper.txt" & set /P Devloper=<"%rootpath%\TMP\Devloper.txt"
	"%rootpath%\BAT\busybox" sed -n "/<game serial=\"!Titleid!\">/,/<\/game>/ {s/.*<Publisher>\(.*\)<\/Publisher>.*/\1/p}" "%rootpath%\BAT\APPDB.xml" > "%rootpath%\TMP\Publisher.txt" & set /P Publisher=<"%rootpath%\TMP\Publisher.txt"
	"%rootpath%\BAT\busybox" sed -n "/<game serial=\"!Titleid!\">/,/<\/game>/ {s/.*<Genre>\(.*\)<\/Genre>.*/\1/p}" "%rootpath%\BAT\APPDB.xml" > "%rootpath%\TMP\Genre.txt" & set /P Genre=<"%rootpath%\TMP\Genre.txt"
	"%rootpath%\BAT\busybox" sed -n "/<game serial=\"!Titleid!\">/,/<\/game>/ {s/.*<Contentweb>\(.*\)<\/Contentweb>.*/\1/p}" "%rootpath%\BAT\APPDB.xml" > "%rootpath%\TMP\Contentweb.txt" & set /P Contentweb=<"%rootpath%\TMP\Contentweb.txt"

	echo Title:     [!Title!]
	echo Appid:     [!Titleid!]
	REM echo Release:   [!Release!]
	echo Developer: [!Devloper!]
	echo Publisher: [!Publisher!]
	echo Genre:     [!Genre!]
	echo Source:    [!Contentweb!]

"%rootpath%\BAT\Diagbox" gd 0e
echo ----------------------------------------------------
"%rootpath%\BAT\Diagbox" gd 0f

    echo            Downloading resources...
	md "%rootpath%\TMP\APP\!Titleid2!\res\image"
	
	REM Default list.ico
    if !uselocalARTHDDOSD!==yes (
	"%rootpath%\BAT\7-Zip\7z" x -bso0 "%rootpath%\HDD-OSD-Icons-Pack.zip" -o"%rootpath%\TMP" "APP\!Titleid2!" -r -y >nul 2>&1
	for %%f in (icon.sys list.ico del.ico) do move "%rootpath%\TMP\APP\!Titleid2!\%%f" "%rootpath%\TMP\APP" >nul 2>&1
	)

	if !DownloadARTHDDOSD!==yes (
	REM HDD-OSD
	for %%f in (icon.sys list.ico del.ico) do "%rootpath%\BAT\wget" -q "https://archive.org/download/hdd-osd-icons-pack/HDD-OSD-Icons-Pack.zip/APP%%2F!Titleid2!%%2F%%f" -O "%rootpath%\TMP\APP\!Titleid2!\%%f" >nul
	cd /d "%rootpath%\TMP\APP\!Titleid2!" & for %%F in (*) do if %%~zF==0 (del "%%F") else (move * "%rootpath%\TMP\APP" >nul 2>&1)

	REM PSBBN, XMB
	for %%f in (jkt_001.png jkt_002.png jkt_cp.png) do "%rootpath%\BAT\wget" -q "https://archive.org/download/hdd-osd-icons-pack/HDD-OSD-Icons-Pack.zip/APP%%2F!Titleid2!%%2Fres%%2F%%f" -O "%rootpath%\TMP\APP\!Titleid2!\%%f" >nul
	cd /d "%rootpath%\TMP\APP\!Titleid2!" & for %%F in (*) do if %%~zF==0 (del "%%F") else (move * "%rootpath%\TMP\APP\!Titleid2!\res" >nul 2>&1)
    
	for %%f in (0.png 1.png 2.png) do "%rootpath%\BAT\wget" -q "https://archive.org/download/hdd-osd-icons-pack/HDD-OSD-Icons-Pack.zip/APP%%2F!Titleid2!%%2Fres%%2Fimage%%2F%%f" -O "%rootpath%\TMP\APP\!Titleid2!\%%f" >nul
	cd /d "%rootpath%\TMP\APP\!Titleid2!" & for %%F in (*) do if %%~zF==0 (del "%%F") else (move * "%rootpath%\TMP\APP\!Titleid2!\res\image" >nul 2>&1)
	)

	REM Covers
	if exist "%rootpath%\TMP\APP\!Titleid2!\res\jkt_001.png" "%rootpath%\BAT\nconvert" -overwrite -out png -resize 256 256 -rtype lanczos -efocus -colors 256 -o "%rootpath%\APPS\!appfolder!\res\jkt_001.png" "%rootpath%\TMP\APP\!Titleid2!\res\jkt_001.png" >nul 2>&1
	if exist "%rootpath%\TMP\APP\!Titleid2!\res\jkt_001.png" "%rootpath%\BAT\nconvert" -overwrite -out png -resize 76 108 -rtype lanczos -efocus -colors 256 -o "%rootpath%\APPS\!appfolder!\res\jkt_002.png" "%rootpath%\TMP\APP\!Titleid2!\res\jkt_001.png" >nul 2>&1
	if exist "%rootpath%\TMP\APP\!Titleid2!\res\jkt_cp.png" "%rootpath%\BAT\nconvert" -overwrite -out png -rtype lanczos -efocus -colors 256 -o "%rootpath%\APPS\!appfolder!\res\jkt_cp.png" "%rootpath%\TMP\APP\!Titleid2!\res\jkt_cp.png" >nul 2>&1
	
	REM Screenshot
	if exist "%rootpath%\TMP\APP\!Titleid2!\res\image\0.png" "%rootpath%\BAT\nconvert" -overwrite -out png -resize 640 350 -rtype lanczos -efocus -colors 256 -o "%rootpath%\APPS\!appfolder!\res\image\0.png" "%rootpath%\TMP\APP\!Titleid2!\res\image\0.png" >nul 2>&1

	if exist "%rootpath%\TMP\APP\!Titleid2!\res\image\1.png" "%rootpath%\BAT\nconvert" -overwrite -out png -resize 640 350 -rtype lanczos -efocus -colors 256 -o "%rootpath%\APPS\!appfolder!\res\image\1.png" "%rootpath%\TMP\APP\!Titleid2!\res\image\1.png" >nul 2>&1
	if exist "%rootpath%\TMP\APP\!Titleid2!\res\image\2.png" "%rootpath%\BAT\nconvert" -overwrite -out png -resize 640 350 -rtype lanczos -efocus -colors 256 -o "%rootpath%\APPS\!appfolder!\res\image\2.png" "%rootpath%\TMP\APP\!Titleid2!\res\image\2.png" >nul 2>&1

    cd /d "%rootpath%\APPS\!appfolder!"
    
	if exist "%rootpath%\TMP\!Titleid!-SIZE.txt" (set /P partsize=<"%rootpath%\TMP\!Titleid!-SIZE.txt") else (set "partsize=")
	
    if not defined UpdateAPPS echo            Creating Partition
	echo device !@pfsshell_path! > "%rootpath%\TMP\pfs-apps.txt"
	if defined partsize echo mkpart !PartName! !partsize! PFS >> "%rootpath%\TMP\pfs-apps.txt"
	if not defined partsize echo mkpart !PartName! 128M PFS >> "%rootpath%\TMP\pfs-apps.txt"
	echo mount !PartName! >> "%rootpath%\TMP\pfs-apps.txt"
	echo rm BOOT.ELF >> "%rootpath%\TMP\pfs-apps.txt"
	echo rm EXECUTE.KELF >> "%rootpath%\TMP\pfs-apps.txt"

	REM Fix shity illegal chars for busybox like: /.&
    if defined Contentweb "%rootpath%\BAT\busybox" sed -i "s/\&/\\\&/g; s./.\\\/.g" "%rootpath%\TMP\Contentweb.txt" & set /P Contentweb=<"%rootpath%\TMP\Contentweb.txt"

	REM HDD-OSD Infos
	"%rootpath%\BAT\busybox" sed -ie "s/ = /=/g; s/=/ = /g; s/  =/ = /g" "%rootpath%\TMP\APP\icon.sys"
	"%rootpath%\BAT\busybox" sed -ie "s/title0 =.*/title0 =/g; s/title0 =/title0 = !Title!/g" "%rootpath%\TMP\APP\icon.sys"
 	"%rootpath%\BAT\busybox" sed -ie "s/title1 =.*/title1 =/g; s/title1 =/title1 = !Genre!/g" "%rootpath%\TMP\APP\icon.sys"
	"%rootpath%\BAT\busybox" sed -ie "s/\s*$//" "%rootpath%\TMP\APP\icon.sys"

	REM PSBBN, XMB Infos 
	"%rootpath%\BAT\busybox" sed -i -e "s/title =.*/title =/g; s/title =/title = !Title!/g" "%rootpath%\APPS\!appfolder!\res\info.sys"
 	"%rootpath%\BAT\busybox" sed -i -e "s/title_id =.*/title_id =/g; s/title_id =/title_id = !Titleid!/g" "%rootpath%\APPS\!appfolder!\res\info.sys"
	REM "%rootpath%\BAT\busybox" sed -i -e "s/release_date =.*/release_date =/g; s/release_date =/release_date = !date!/g" "%rootpath%\APPS\!appfolder!\res\info.sys"
	"%rootpath%\BAT\busybox" sed -i -e "s/area =.*/area =/g; s/area =/area = X/g" "%rootpath%\APPS\!appfolder!\res\info.sys"
    "%rootpath%\BAT\busybox" sed -i -e "s/developer_id =.*/developer_id =/g; s/developer_id =/developer_id = !Devloper!/g" "%rootpath%\APPS\!appfolder!\res\info.sys"
	"%rootpath%\BAT\busybox" sed -i -e "s/publisher_id =.*/publisher_id =/g; s/publisher_id =/publisher_id = !Publisher!/g" "%rootpath%\APPS\!appfolder!\res\info.sys"
    if defined Contentweb "%rootpath%\BAT\busybox" sed -i -e "s/content_web =.*/content_web =/g; s/content_web =/content_web = !Contentweb!/g" "%rootpath%\APPS\!appfolder!\res\info.sys"
	"%rootpath%\BAT\busybox" sed -i -e "s/genre =.*/genre =/g; s/genre =/genre = !Genre!/g" "%rootpath%\APPS\!appfolder!\res\info.sys"
	
	REM Disable jkt_cp.png
	"%rootpath%\BAT\busybox" sed -i -e "s/copyright_imgcount =.*/copyright_imgcount =/g; s/copyright_imgcount =/copyright_imgcount = 0/g" "%rootpath%\APPS\!appfolder!\res\info.sys"
	REM Manual
	"%rootpath%\BAT\busybox" sed -i -e "s/label=\"APartName\"/label=\"!Title!\"/g; s/\&/\&amp;/g" "%rootpath%\APPS\!appfolder!\res\man.xml"
	
	if not exist "%rootpath%\APPS\!appfolder!\*.KELF" (
	echo            Sign KELF...
	
	if !Titleid!==APPS-00007 (
	ren "%rootpath%\APPS\!appfolder!\esr_r10f_direct_off.elf" "BOOT.ELF" >nul 2>&1
	ren "%rootpath%\APPS\!appfolder!\esr_r10f_direct_off.KELF" "EXECUTE.KELF" >nul 2>&1
	)
	
	if not exist "%rootpath%\APPS\!appfolder!\BOOT.ELF" ren "%rootpath%\APPS\!appfolder!\*.elf" "BOOT.ELF" >nul 2>&1
	
	if exist "%rootpath%\BAT\PS2KEYS.DAT" (
	copy "%rootpath%\BAT\PS2KEYS.DAT" "%USERPROFILE%\PS2KEYS.DAT" >nul 2>&1
	"%rootpath%\BAT\kelftool.exe" encrypt mbr "%rootpath%\APPS\!appfolder!\BOOT.ELF" "%rootpath%\APPS\!appfolder!\EXECUTE.KELF" >nul 2>&1
	) else (
	"%rootpath%\BAT\SCEDoormat_NoME.exe" "%rootpath%\APPS\!appfolder!\BOOT.ELF" "%rootpath%\APPS\!appfolder!\EXECUTE.KELF" >nul 2>&1
	)
	
	) else (
	if !Titleid!==APPS-00007 (
	REM Why ESR Already signed?. Because SCEDoormat cannot sign the ESR correctly
	ren "%rootpath%\APPS\!appfolder!\esr_r10f_direct_off.elf" "BOOT.ELF" >nul 2>&1
	ren "%rootpath%\APPS\!appfolder!\esr_r10f_direct_off.KELF" "EXECUTE.KELF" >nul 2>&1
	 )
	)

	REM RESOURCES DIR (APPS\APPFolder\*)
	for %%0 in (*) do (echo put "%%0") >> "%rootpath%\TMP\pfs-apps.txt"
	
	REM RESOURCES DIR (APPS\APPFolder\res)
	for /D %%x in (*) do (
	echo mkdir "%%x" >> "%rootpath%\TMP\pfs-apps.txt"
	echo lcd "%%x" >> "%rootpath%\TMP\pfs-apps.txt"
 	echo cd "%%x" >> "%rootpath%\TMP\pfs-apps.txt"
 	cd "%%x"
	
	REM RESOURCES DIR (APPS\APPFolder\res\files.xxx)
 	for %%1 in (*) do (echo put "%%1") >> "%rootpath%\TMP\pfs-apps.txt"
	
	REM RESOURCES DIR (APPS\APPFolder\res\image)
	for /D %%y in (*) do (
	echo mkdir "%%y" >> "%rootpath%\TMP\pfs-apps.txt"
	echo lcd "%%y" >> "%rootpath%\TMP\pfs-apps.txt"
	echo cd "%%y" >> "%rootpath%\TMP\pfs-apps.txt"
	cd "%%y"

	REM RESOURCES DIR (APPS\APPFolder\res\image\files.xxx)
	for %%2 in (*) do (echo put "%%2") >> "%rootpath%\TMP\pfs-apps.txt"
	
	REM RESOURCES DIR (APPS\APPFolder\subfolder\subfolder\subfolder)
	for /D %%z in (*) do (
	echo mkdir "%%z" >> "%rootpath%\TMP\pfs-apps.txt"
	echo lcd "%%z" >> "%rootpath%\TMP\pfs-apps.txt"
	echo cd "%%z" >> "%rootpath%\TMP\pfs-apps.txt"
	cd "%%z"

	REM RESOURCES DIR (APPS\APPFolder\subfolder\subfolder\subfolder\files.xxx)
	for %%3 in (*) do (echo put "%%3") >> "%rootpath%\TMP\pfs-apps.txt"
	
	echo lcd .. >> "%rootpath%\TMP\pfs-apps.txt"
	echo cd .. >> "%rootpath%\TMP\pfs-apps.txt"
	cd ..
	)
	
	echo lcd .. >> "%rootpath%\TMP\pfs-apps.txt"
	echo cd .. >> "%rootpath%\TMP\pfs-apps.txt"
	cd ..
	)
	
	echo lcd .. >> "%rootpath%\TMP\pfs-apps.txt"
	echo cd .. >> "%rootpath%\TMP\pfs-apps.txt"
	cd ..
	)
	
	echo umount >> "%rootpath%\TMP\pfs-apps.txt"	
	echo exit >> "%rootpath%\TMP\pfs-apps.txt"

	echo            Installing...
	type "%rootpath%\TMP\pfs-apps.txt" | "%rootpath%\BAT\pfsshell" >nul 2>&1
	
    if exist "%rootpath%\TMP\!Titleid2!-OPLELFROOT.txt" copy BOOT.ELF "%rootpath%\TMP\OPNPS2LD.ELF" >nul 2>&1

	cd /d "%rootpath%\TMP\APP" & "%rootpath%\BAT\hdl_dump" modify_header !@hdl_path! "!PartName!" >nul 2>&1
	cd /d "%rootpath%" & rmdir /Q/S "%rootpath%\APPS\!appfolder!" >nul 2>&1
	echo            Completed...
	
  endlocal
 )
endlocal

REM Reloading HDD Cache
call "%rootpath%\BAT\__ReloadHDD_cache.bat" >nul 2>&1
)

    cd /d "%rootpath%\TMP" & if exist "%rootpath%\TMP\OPNPS2LD.ELF" (
	echo\
	echo\
	echo Installing OPNPS2LD.ELF In OPL Root Partition
	echo ----------------------------------------------------
    
	echo            Installing...
	echo device !@pfsshell_path! > "%rootpath%\TMP\pfs-OPLconfig.txt"
    echo mount !OPLPART! >> "%rootpath%\TMP\pfs-OPLconfig.txt"
	if defined CUSTOM_OPLPART echo mkdir OPL >> "%rootpath%\TMP\pfs-OPLconfig.txt"
    if defined CUSTOM_OPLPART echo cd OPL >> "%rootpath%\TMP\pfs-OPLconfig.txt"
	echo rm OPNPS2LD.ELF >> "%rootpath%\TMP\pfs-OPLconfig.txt"
	echo lcd "%rootpath%\TMP" >> "%rootpath%\TMP\pfs-OPLconfig.txt"
	echo put OPNPS2LD.ELF >> "%rootpath%\TMP\pfs-OPLconfig.txt"
	echo lcd .. >> "%rootpath%\TMP\pfs-OPLconfig.txt"
	echo umount >> "%rootpath%\TMP\pfs-OPLconfig.txt"	 
    echo exit >> "%rootpath%\TMP\pfs-OPLconfig.txt"
    type "%rootpath%\TMP\pfs-OPLconfig.txt" | "%rootpath%\BAT\pfsshell" >nul 2>&1
	del "%rootpath%\TMP\OPNPS2LD.ELF" >nul 2>&1
	echo            Completed...
    )

cd /d "%rootpath%" & rmdir /Q/S "%rootpath%\TMP" >nul 2>&1

echo\
echo\
echo ----------------------------------------------------
"%rootpath%\BAT\Diagbox" gd 0a
echo Completed...
echo\
echo\
"%rootpath%\BAT\Diagbox" gd 07

PAUSE