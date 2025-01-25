@echo off
cls
chcp 1252 >nul 2>&1
mkdir "%rootpath%\TMP" >nul 2>&1

echo\
"%rootpath%\BAT\Diagbox" gd 0e
echo Do you want to change the default directory^?
"%rootpath%\BAT\Diagbox" gd 07
echo ^(Useful if your games are on another hard drive or path^)
CHOICE /C YN
echo\
if !errorlevel!==1 (
echo Example: E:\
set /p "HDDPATH=Enter the path where yours CD DVD folder located:"
if "!HDDPATH!"=="" set "HDDPATH="
)
if not defined HDDPATH set HDDPATH=%rootpath%

set filepath="!HDDPATH!\DVD\*.iso" "!HDDPATH!\DVD\*.cue" "!HDDPATH!\CD\*.iso" "!HDDPATH!\CD\*.cue"

if not exist "!HDDPATH!\CHT" md "!HDDPATH!\CHT" >nul 2>&1
if exist "!HDDPATH!\CHT\*.cht" (
echo\
"%rootpath%\BAT\Diagbox" gd 0e
echo CHTs have been detected, they will be modified, do you want to continue^?
"%rootpath%\BAT\Diagbox" gd 07
CHOICE /C YN /M "Select Option:"
if !errorlevel!==1 set overwrittenCHT=yes
if !errorlevel!==2 set overwrittenCHT=no
) else (set overwrittenCHT=yes)

if !overwrittenCHT!==yes (
cd /d "!HDDPATH!\CHT" & for %%F in (*.cht) do if %%~zF==0 (del "%%F" >nul 2>&1)

REM Get iso file
"%rootpath%\BAT\busybox" ls -p !filepath! 2>&1| "%rootpath%\BAT\busybox" grep -v /| "%rootpath%\BAT\busybox" sed "/No such file or directory/d" | "%rootpath%\BAT\busybox" sed "s/.*\\\(.*\)/\1\t&/" >>"%rootpath%\TMP\GameslistTMP.txt" & type "%rootpath%\TMP\GameslistTMP.txt" | "%rootpath%\BAT\busybox" sort | "%rootpath%\BAT\busybox" cut -f 2- >"%rootpath%\TMP\Gameslist.txt"
for %%F in ("%rootpath%\TMP\Gameslist.txt") do if %%~zF==0 (
echo\
echo\
echo No .ISO file was found in CD Or DVD Folder.
echo\
) else (

for /f "usebackq delims=" %%f in ("%rootpath%\TMP\Gameslist.txt") do (

    setlocal DisableDelayedExpansion
    set fpath=%%f
	set filename=%%~nxf
    set fname=%%~nf
    setlocal EnableDelayedExpansion
	
	echo\
	echo\
	echo !filename!
	
	if "!filename!"=="!fname!.cue" (
	"%rootpath%\BAT\7-Zip\7z" x -bso0 "!fpath!" -o"%rootpath%\TMP" "!fname!.iso" -r -y
	set "fpath=!rootpath!\TMP\!fname!.iso"
	)
	
	REM Get Gameid from SYSTEM.CNF
	"%rootpath%\BAT\7-Zip\7z" x -bso0 "!fpath!" -o"%rootpath%\TMP" SYSTEM.CNF -r -y >nul 2>&1 
	"%rootpath%\BAT\busybox" grep -o "[A-Z][A-Z][A-Z][A-Z]_[0-9][0-9][0-9].[0-9][0-9]" "%rootpath%\TMP\SYSTEM.CNF" > "%rootpath%\TMP\gameidelf.txt" & set /p gameidelf=<"%rootpath%\TMP\gameidelf.txt"
	
	REM Get ELF
	"%rootpath%\BAT\7-Zip\7z" x -bso0 "!fpath!" -o"%rootpath%\TMP" !gameidelf! -r -y >nul 2>&1
	REM Get mastercode
    "%rootpath%\BAT\mastercode_finder_cmd" -v "%rootpath%\TMP\!gameidelf!" | "%rootpath%\BAT\busybox" grep "Recommended mastercode" | "%rootpath%\BAT\busybox" cut -c26-999 > "%rootpath%\TMP\Mastercode.txt" & set /p Mastercode=<"%rootpath%\TMP\Mastercode.txt"
	REM Get Game Version
	"%rootpath%\BAT\busybox" grep "VER" "%rootpath%\TMP\SYSTEM.CNF" | "%rootpath%\BAT\busybox" sed "s/ //g" | "%rootpath%\BAT\busybox" cut -c5-999 | "%rootpath%\BAT\busybox" sed "s/\s*$//" > "%rootpath%\TMP\VER.txt" & set /p GAMEVER=<"%rootpath%\TMP\VER.txt"
	REM Get CRC
	"%rootpath%\BAT\PS2ELFCRC.exe" "%rootpath%\TMP\!gameidelf!" | "%rootpath%\BAT\busybox" sed "s/[^:]*://g; s/ //g" > "%rootpath%\TMP\CRC.txt" & set /p CRC=<"%rootpath%\TMP\CRC.txt"
	
	echo Mastercode:   [!Mastercode!]
    echo Gameid:       [!gameidelf!]
    echo Game Version: [!GAMEVER!]
	echo CRC:          [!CRC!]
    
	copy "!HDDPATH!\CHT\!gameidelf!.cht" "%rootpath%\TMP\!gameidelf!.cht" >nul 2>&1
	
    echo "!fname! /VER !GAMEVER! /ID !gameidelf! /CRC !CRC!"| "%rootpath%\BAT\busybox" iconv -f windows-1252 -t utf-8 > "!HDDPATH!\CHT\!gameidelf!.cht"
    echo Mastercode>> "!HDDPATH!\CHT\!gameidelf!.cht"
    echo !Mastercode!>> "!HDDPATH!\CHT\!gameidelf!.cht"
	
	if exist "%rootpath%\TMP\!gameidelf!.cht" (
	"%rootpath%\BAT\busybox" sed -i "1d" "%rootpath%\TMP\!gameidelf!.cht"
	"%rootpath%\BAT\busybox" sed -i -e "/Mastercode/{N;d;}" "%rootpath%\TMP\!gameidelf!.cht"
	"%rootpath%\BAT\busybox" sed -i "$a" "!HDDPATH!\CHT\!gameidelf!.cht"
	"%rootpath%\BAT\busybox" sed -i "/./,$^!d" "%rootpath%\TMP\!gameidelf!.cht"
	type "%rootpath%\TMP\!gameidelf!.cht" >> "!HDDPATH!\CHT\!gameidelf!.cht"
	)
	for %%f in ("%rootpath%\TMP\*") do del "%%f" >nul 2>&1
		endlocal
	endlocal
	)
REM Removes only blank lines from the last line of a file
"%rootpath%\BAT\busybox" sed -i -e :a -e "/^^\n*$/{$d;N;ba" -e "}" "!HDDPATH!\CHT\*.cht"
)
rmdir /Q/S "%rootpath%\TMP" >nul 2>&1
echo\
echo\
PAUSE
)
