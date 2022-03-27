REM Small script to create .CHT but What a mess NOT oPtiMIZed but works!

@echo off

setlocal disabledelayedexpansion
del "%~dp0TMP\ISONotFound.txt" >nul 2>&1
mkdir "%~dp0TMP" >nul 2>&1
mkdir "%~dp0CD-DVD" >nul 2>&1

copy "%~dp0BAT\hdl_dump.exe" "%~dp0CD-DVD" >nul 2>&1
move "%~dp0DVD\*.iso" "%~dp0CD-DVD" >nul 2>&1

"%~dp0BAT\Diagbox" gd 06
echo\
if not exist "%~dp0CD-DVD\*.iso" (

echo NO .ISO found in DVD folder

echo ISONOTFOUND > "%~dp0TMP\ISONotFound.txt"

) else (

echo\
"%~dp0BAT\Diagbox" gd 07

cd /d "%~dp0"
for %%F in ("%~dp0CHT\*") do if %%~zF==0 del "%%F"

cd /d "%~dp0CD-DVD"

for %%f in (*.iso) do (
	echo.
	echo.
	echo %%f
	
    echo %%f > "%~dp0TMP\Name.txt"
	"%~dp0BAT\busybox" sed -i "s/\s*$//" "%~dp0TMP\Name.txt"
	"%~dp0BAT\busybox" sed -i -e "s/.iso//g" "%~dp0TMP\Name.txt"
	set /p filename=<"%~dp0TMP\Name.txt" 
	
for /f "tokens=1,2,3,4,5*" %%i in ('hdl_dump cdvd_info2 ".\%%f"') do (

if "%%i"=="CD" ( "%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0CD-DVD\%%f" -o"%~dp0CD-DVD" %%l & echo %%l > "%~dp0TMP\gameidelf.txt"
"%~dp0BAT\busybox" sed -i "s/ //g" "%~dp0TMP\gameidelf.txt" 
"%~dp0BAT\busybox" sed -i "s/\"//g" "%~dp0TMP\gameidelf.txt" 
"%~dp0BAT\busybox" sed -i "s/\s*$//" "%~dp0TMP\gameidelf.txt" 
set /p gameidelf=<"%~dp0TMP\gameidelf.txt"
setlocal Enabledelayedexpansion
"%~dp0BAT\mastercode_finder_cmd" -v !gameidelf! > "%~dp0TMP\report.txt" 
del !gameidelf! >nul 2>&1
endlocal
)

if "%%i"=="DVD" ( "%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0CD-DVD\%%f" -o"%~dp0CD-DVD" %%l & echo %%l > "%~dp0TMP\gameidelf.txt"
"%~dp0BAT\busybox" sed -i "s/ //g" "%~dp0TMP\gameidelf.txt" 
"%~dp0BAT\busybox" sed -i "s/\"//g" "%~dp0TMP\gameidelf.txt" 
"%~dp0BAT\busybox" sed -i "s/\s*$//" "%~dp0TMP\gameidelf.txt" 
set /p gameidelf=<"%~dp0TMP\gameidelf.txt"
setlocal Enabledelayedexpansion
"%~dp0BAT\mastercode_finder_cmd" -v !gameidelf! > "%~dp0TMP\report.txt" 
del !gameidelf! >nul 2>&1
endlocal
)

if "%%i"=="dual-layer" ( "%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0CD-DVD\%%f" -o"%~dp0CD-DVD" %%m & echo %%m > "%~dp0TMP\gameidelf.txt"
"%~dp0BAT\busybox" sed -i "s/ //g" "%~dp0TMP\gameidelf.txt" 
"%~dp0BAT\busybox" sed -i "s/\"//g" "%~dp0TMP\gameidelf.txt" 
"%~dp0BAT\busybox" sed -i "s/\s*$//" "%~dp0TMP\gameidelf.txt"
set /p gameidelf=<"%~dp0TMP\gameidelf.txt"
setlocal Enabledelayedexpansion
"%~dp0BAT\mastercode_finder_cmd" -v !gameidelf! > "%~dp0TMP\report.txt" 
del !gameidelf! >nul 2>&1
endlocal
)

del "%~dp0TMP\SYSTEM.CNF" >nul 2>&1
del "%~dp0TMP\VER.txt" >nul 2>&1

"%~dp0BAT\7-Zip\7z" x -bso0 "%~dp0CD-DVD\%%f" -o"%~dp0TMP" SYSTEM.CNF
"%~dp0BAT\busybox" grep "VER" "%~dp0TMP\SYSTEM.CNF" | "%~dp0BAT\busybox" sed "s/ //g" > "%~dp0TMP\VER.txt"
"%~dp0BAT\busybox" cut -c5-999 "%~dp0TMP\VER.txt" > "%~dp0TMP\VER2.txt"
"%~dp0BAT\busybox" sed -i "s/\s*$//" "%~dp0TMP\VER2.txt"
set /p GAMEVER=<"%~dp0TMP\VER2.txt"

"%~dp0BAT\busybox" grep "Recommended mastercode" "%~dp0TMP\report.txt" | "%~dp0BAT\busybox" cut -c26-999 > "%~dp0TMP\Mastercode.txt"
set /p Mastercode=<"%~dp0TMP\Mastercode.txt"

setlocal Enabledelayedexpansion

echo Mastercode - !Mastercode!
echo GameID  - !gameidelf!
echo Game Version - !GAMEVER!

if not exist "%~dp0CHT\!gameidelf!.cht" (

Echo "!filename! /VER !GAMEVER! /ID !gameidelf!" > "%~dp0CHT\!gameidelf!.cht"
Echo Mastercode >> "%~dp0CHT\!gameidelf!.cht"
Echo !Mastercode! >> "%~dp0CHT\!gameidelf!.cht"
"%~dp0BAT\busybox" sed -i "s/\s*$//" "%~dp0CHT\!gameidelf!.cht"
) else (

"%~dp0BAT\busybox" sed -i "s/\s*$//" "%~dp0CHT\!gameidelf!.cht"
"%~dp0BAT\busybox" sed -n "/Mastercode/,/ /p" "%~dp0CHT\!gameidelf!.cht" > "%~dp0TMP\MastercodeCheck.txt"
"%~dp0BAT\busybox" sed -i "1d" "%~dp0TMP\MastercodeCheck.txt"
"%~dp0BAT\busybox" sed -i "2,20d" "%~dp0TMP\MastercodeCheck.txt"
set /p MastercodeCheck=<"%~dp0TMP\MastercodeCheck.txt"

if !Mastercode! equ !MastercodeCheck! (

"%~dp0BAT\busybox" sed -i "1d" "%~dp0CHT\!gameidelf!.cht"
"%~dp0BAT\busybox" sed -i "1i \"!filename! /VER !GAMEVER! /ID !gameidelf!\" " "%~dp0CHT\!gameidelf!.cht"

) else (

"%~dp0BAT\busybox" sed -i "s/\s*$//" "%~dp0CHT\!gameidelf!.cht"
"%~dp0BAT\busybox" sed -i "$a" "%~dp0CHT\!gameidelf!.cht"
"%~dp0BAT\busybox" sed -i "$a" "%~dp0CHT\!gameidelf!.cht"
"%~dp0BAT\busybox" sed -i "2i $a" "%~dp0CHT\!gameidelf!.cht"
"%~dp0BAT\busybox" sed -i "1d" "%~dp0CHT\!gameidelf!.cht"
"%~dp0BAT\busybox" sed -i "1i \"!filename! /VER !GAMEVER! /ID !gameidelf!\" " "%~dp0CHT\!gameidelf!.cht"
"%~dp0BAT\busybox" sed -i "2d" "%~dp0CHT\!gameidelf!.cht"
"%~dp0BAT\busybox" sed -i "2i Mastercode" "%~dp0CHT\!gameidelf!.cht"
"%~dp0BAT\busybox" sed -i "3i !Mastercode!" "%~dp0CHT\!gameidelf!.cht"
"%~dp0BAT\busybox" sed -i 4"s/.*/\\\\&/" "%~dp0CHT\!gameidelf!.cht"

    )
   )
  )
endlocal
)
"%~dp0BAT\busybox" sed -i -e :a -e "/^\n*$/{$d;N;ba" -e "}" "%~dp0CHT\*.cht"

move "%~dp0CD-DVD\*.iso" "%~dp0DVD" >nul 2>&1
del "%~dp0CD-DVD\hdl_dump.exe" >nul 2>&1
rmdir /Q/S "%~dp0TMP" >nul 2>&1
)
echo\