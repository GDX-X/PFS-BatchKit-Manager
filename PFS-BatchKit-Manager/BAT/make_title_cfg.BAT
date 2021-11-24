@echo off
cd APPS
::
..\BAT\DiagBox.EXE gd 0f
echo title.cfg maker by matias israelson
..\BAT\DiagBox.EXE gd 07
set q=echo ------------------------------------------------------------------------------------------------------------------------
set w=echo ========================================================================================================================
:GET_ELF
echo checking for ELF files in APPS...
dir /b /o:n *.ELF >ISR.ETL 2>nul || echo no ELF Files found
set dea=true
for /f "delims= " %%a in (ISR.ETL) do (
::timeout /t 2 >nul
IF NOT EXIST "%CD%\%%~na\title.cfg" (
																	MD "%%~na"
																	Cd "%%~na"
																		(
																		Echo title=%%~na
																		Echo boot=%%a
																		)>title.cfg
																	echo [%%a]
																	Cd..
																	Move "%%a" "%CD%\%%~na\%%a"
															) ELSE (
															..\BAT\DiagBox.EXE gd 0c
															echo error.
															echo ya existe una aplicacion llamada [%%a]
															..\BAT\DiagBox.EXE gd 07
															)
)
::LOOP###############################################################################################################
IF EXIST ISR.ETL del ISR.ETL
cd ..

REM ###############################################################################################################
..\BAT\DiagBox.EXE gd 0f
echo GDX

REM checking for ELF files exist in ONLY folders NOT subfolders
@echo off
cd APPS
::
..\BAT\DiagBox.EXE gd 07
set q=echo ------------------------------------------------------------------------------------------------------------------------
set w=echo ========================================================================================================================
echo check if there is any dot in the name of the folders
setlocal enabledelayedexpansion
set "under=_"
set "dot=."
for /D /r %%d in (*) do (
set name=%%~nxd
ren "%%d" "!name:%dot%=%under%!"
)
echo checking for ELF files in folders...
for /f "delims= " %%a in ('dir /ad /b') do (
pushd "%%a"
IF EXIST "%CD%\%%~na\title.cfg" del "%CD%\%%~na\title.cfg"
for /f "delims= " %%b in ('dir *.elf /a-d /b') do ren "%%b" "%%a%%~xb" 
popd
::timeout /t 2 >nul
REM IF EXIST "%CD%\%%~na\%%~na.cfg" del "%CD%\%%~na\%%~na.cfg"
IF NOT EXIST "%CD%\%%~na\title.cfg" (
																	Cd "%%~na"
																		(
																		Echo title=%%~na
																		Echo boot=%%~na.elf
																		)>title.cfg
																	echo [%%a]
																	Cd..
															) ELSE (
															..\BAT\DiagBox.EXE gd 0c
															echo error.
															echo ya existe una aplicacion llamada [%%a]
															..\BAT\DiagBox.EXE gd 07
															)
)
::LOOP###############################################################################################################
cd ..
